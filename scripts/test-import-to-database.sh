#!/bin/bash

##############################################################################
# JSON Import to MSSQL Database Verification Script
# 
# This script verifies that JSON import data is actually saved to MSSQL database
# 
# Usage:
#   ./scripts/test-import-to-database.sh [json_file] [api_url]
# 
# Example:
#   ./scripts/test-import-to-database.sh examples/MINIMAL-VALID-EXAMPLE.json http://localhost:7071/api
##############################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
JSON_FILE="${1:-examples/MINIMAL-VALID-EXAMPLE.json}"
API_URL="${2:-http://localhost:7071/api}"
DB_SERVER="${DB_SERVER:-localhost}"
DB_NAME="${DB_NAME:-ServiceCatalogueManager}"
DB_USER="${DB_USER:-sa}"
DB_PASSWORD="${DB_PASSWORD:-YourStrong@Passw0rd}"

echo -e "${CYAN}========================================"
echo "JSON Import to MSSQL Database Test"
echo -e "========================================${NC}"
echo ""

# Check if sqlcmd is available
if ! command -v sqlcmd &> /dev/null; then
    echo -e "${RED}✗ sqlcmd not found${NC}"
    echo "  Please install SQL Server command-line tools"
    echo "  Visit: https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools"
    exit 1
fi

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo -e "${RED}✗ curl not found${NC}"
    echo "  Please install curl: sudo apt-get install curl"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ jq not found (optional, but recommended)${NC}"
    echo "  Install for better JSON parsing: sudo apt-get install jq"
fi

# Function to test SQL connection
test_sql_connection() {
    echo -e "${YELLOW}[1/5] Testing SQL Server connection...${NC}"
    
    if sqlcmd -S "$DB_SERVER" -U "$DB_USER" -P "$DB_PASSWORD" -d "$DB_NAME" -Q "SELECT @@VERSION" -h -1 > /dev/null 2>&1; then
        echo -e "${GREEN}✓ SQL Server connected successfully${NC}"
        VERSION=$(sqlcmd -S "$DB_SERVER" -U "$DB_USER" -P "$DB_PASSWORD" -d "$DB_NAME" -Q "SELECT @@VERSION" -h -1 | head -n 1)
        echo -e "  Version: ${VERSION}"
        return 0
    else
        echo -e "${RED}✗ Failed to connect to SQL Server${NC}"
        echo "  Server: $DB_SERVER"
        echo "  Database: $DB_NAME"
        echo "  User: $DB_USER"
        return 1
    fi
}

# Function to count services
get_service_count() {
    sqlcmd -S "$DB_SERVER" -U "$DB_USER" -P "$DB_PASSWORD" -d "$DB_NAME" \
        -Q "SELECT COUNT(*) FROM ServiceCatalogItem" -h -1 | tr -d ' '
}

# Function to check if service exists
check_service_exists() {
    local service_code="$1"
    
    COUNT=$(sqlcmd -S "$DB_SERVER" -U "$DB_USER" -P "$DB_PASSWORD" -d "$DB_NAME" \
        -Q "SELECT COUNT(*) FROM ServiceCatalogItem WHERE ServiceCode = '$service_code'" -h -1 | tr -d ' ')
    
    if [ "$COUNT" -gt 0 ]; then
        return 0
    else
        return 1
    fi
}

# Function to get service details
get_service_details() {
    local service_code="$1"
    
    sqlcmd -S "$DB_SERVER" -U "$DB_USER" -P "$DB_PASSWORD" -d "$DB_NAME" \
        -Q "SET NOCOUNT ON; 
            SELECT 
                s.ServiceId,
                s.ServiceCode,
                s.ServiceName,
                s.Version,
                s.CreatedDate,
                (SELECT COUNT(*) FROM UsageScenario WHERE ServiceId = s.ServiceId) as UsageScenariosCount,
                (SELECT COUNT(*) FROM ServiceInput WHERE ServiceId = s.ServiceId) as InputsCount,
                (SELECT COUNT(*) FROM ServiceOutputCategory WHERE ServiceId = s.ServiceId) as OutputCategoriesCount,
                (SELECT COUNT(*) FROM ServicePrerequisite WHERE ServiceId = s.ServiceId) as PrerequisitesCount
            FROM ServiceCatalogItem s
            WHERE s.ServiceCode = '$service_code'" -h -1
}

# Function to import JSON via API
import_json() {
    local json_file="$1"
    local api_url="$2"
    
    echo -e "${YELLOW}[3/5] Importing service from JSON...${NC}"
    
    if [ ! -f "$json_file" ]; then
        echo -e "${RED}✗ JSON file not found: $json_file${NC}"
        return 1
    fi
    
    echo "  Reading JSON file: $json_file"
    
    # Extract service code from JSON
    if command -v jq &> /dev/null; then
        SERVICE_CODE=$(jq -r '.serviceCode' "$json_file")
        SERVICE_NAME=$(jq -r '.serviceName' "$json_file")
        echo "  Service Code: $SERVICE_CODE"
        echo "  Service Name: $SERVICE_NAME"
    fi
    
    echo "  Posting to: ${api_url}/services/import"
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "${api_url}/services/import" \
        -H "Content-Type: application/json" \
        -d @"$json_file")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo -e "${GREEN}✓ Import successful!${NC}"
        if command -v jq &> /dev/null; then
            SERVICE_ID=$(echo "$BODY" | jq -r '.serviceId')
            echo "  Service ID: $SERVICE_ID"
        else
            echo "  Response: $BODY"
        fi
        return 0
    else
        echo -e "${RED}✗ Import failed (HTTP $HTTP_CODE)${NC}"
        echo "  Response: $BODY"
        return 1
    fi
}

# Main execution
main() {
    # Step 1: Test SQL connection
    if ! test_sql_connection; then
        echo ""
        echo -e "${RED}❌ Cannot proceed without database connection${NC}"
        exit 1
    fi
    
    echo ""
    
    # Step 2: Get initial service count
    echo -e "${YELLOW}[2/5] Checking current database state...${NC}"
    INITIAL_COUNT=$(get_service_count)
    echo -e "${GREEN}✓ Current services in database: $INITIAL_COUNT${NC}"
    
    echo ""
    
    # Extract service code from JSON
    if command -v jq &> /dev/null; then
        SERVICE_CODE=$(jq -r '.serviceCode' "$JSON_FILE")
    else
        SERVICE_CODE="UNKNOWN"
    fi
    
    # Check if service already exists
    if check_service_exists "$SERVICE_CODE"; then
        echo -e "${YELLOW}  ⚠ Service '$SERVICE_CODE' already exists in database${NC}"
        echo -n "  Would you like to delete it first? (y/n): "
        read -r answer
        
        if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
            echo "  Deleting existing service..."
            sqlcmd -S "$DB_SERVER" -U "$DB_USER" -P "$DB_PASSWORD" -d "$DB_NAME" \
                -Q "DELETE FROM ServiceCatalogItem WHERE ServiceCode = '$SERVICE_CODE'" > /dev/null
            echo -e "${GREEN}  ✓ Service deleted${NC}"
        else
            echo ""
            echo -e "${RED}❌ Test cancelled - service already exists${NC}"
            exit 1
        fi
    fi
    
    echo ""
    
    # Step 3: Import service
    if ! import_json "$JSON_FILE" "$API_URL"; then
        echo ""
        echo -e "${RED}❌ Import failed - cannot verify database${NC}"
        exit 1
    fi
    
    echo ""
    
    # Step 4: Wait for transaction
    echo -e "${YELLOW}[4/5] Waiting for transaction to complete...${NC}"
    sleep 2
    echo -e "${GREEN}✓ Ready to verify${NC}"
    
    echo ""
    
    # Step 5: Verify in database
    echo -e "${YELLOW}[5/5] Verifying data in database...${NC}"
    
    if check_service_exists "$SERVICE_CODE"; then
        echo -e "${GREEN}✓ Service found in database!${NC}"
        echo ""
        echo -e "${CYAN}═══════════════════════════════════════"
        echo "  Database Verification Details"
        echo -e "═══════════════════════════════════════${NC}"
        
        # Get and display service details
        get_service_details "$SERVICE_CODE"
        
        echo -e "${CYAN}═══════════════════════════════════════${NC}"
        echo ""
        echo -e "${GREEN}✅ SUCCESS: Data from JSON was successfully saved to MSSQL database!${NC}"
        echo ""
        
        # Final count
        FINAL_COUNT=$(get_service_count)
        echo "  Total services now in database: $FINAL_COUNT"
        if [ -n "$INITIAL_COUNT" ]; then
            NEW_COUNT=$((FINAL_COUNT - INITIAL_COUNT))
            echo "  New services added: $NEW_COUNT"
        fi
        
        exit 0
    else
        echo -e "${RED}✗ Service NOT found in database!${NC}"
        echo ""
        echo -e "${RED}❌ FAILED: Data was not saved to database${NC}"
        echo "  This indicates an issue with the import or database save process"
        exit 1
    fi
}

# Run main function
main
