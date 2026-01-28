#!/bin/bash
# ============================================================================
# Test Database Setup - Bash Version
# ============================================================================

echo "🧪 Testuji databázové připojení..."

# Test připojení k SQL Serveru
if command -v sqlcmd &> /dev/null; then
    echo "✅ sqlcmd je k dispozici lokálně"
    TEST_RESULT=$(sqlcmd -S localhost,1433 -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1" -C -h -1 2>&1)
else
    echo "ℹ️  Používám Docker exec"
    TEST_RESULT=$(docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1" -C -h -1 2>&1)
fi

if echo "$TEST_RESULT" | grep -q "1"; then
    echo "✅ SQL Server je dostupný"
else
    echo "❌ SQL Server není dostupný"
    echo "Výsledek: $TEST_RESULT"
    exit 1
fi

# Test existence databáze
echo "ℹ️  Testuji existenci databáze ServiceCatalogueManager..."
if command -v sqlcmd &> /dev/null; then
    DB_EXISTS=$(sqlcmd -S localhost,1433 -U sa -P "YourStrong@Passw0rd" -Q "SELECT COUNT(*) FROM sys.databases WHERE name = 'ServiceCatalogueManager'" -C -h -1 2>&1 | grep -o '[0-9]')
else
    DB_EXISTS=$(docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT COUNT(*) FROM sys.databases WHERE name = 'ServiceCatalogueManager'" -C -h -1 2>&1 | grep -o '[0-9]')
fi

if [ "$DB_EXISTS" = "1" ]; then
    echo "✅ Databáze ServiceCatalogueManager existuje"
    
    # Test tabulek
    echo "ℹ️  Testuji tabulky v databázi..."
    if command -v sqlcmd &> /dev/null; then
        TABLE_COUNT=$(sqlcmd -S localhost,1433 -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'" -C -h -1 2>&1 | grep -o '[0-9]')
    else
        TABLE_COUNT=$(docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'" -C -h -1 2>&1 | grep -o '[0-9]')
    fi
    
    echo "📊 Počet tabulek: $TABLE_COUNT"
    
    # Test konkrétních tabulek
    echo "ℹ️  Testuji konkrétní tabulky..."
    for table in "ServiceCatalogItem" "LU_ServiceCategory" "LU_SizeOption" "LU_CloudProvider"; do
        if command -v sqlcmd &> /dev/null; then
            EXISTS=$(sqlcmd -S localhost,1433 -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$table'" -C -h -1 2>&1 | grep -o '[0-9]')
        else
            EXISTS=$(docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$table'" -C -h -1 2>&1 | grep -o '[0-9]')
        fi
        
        if [ "$EXISTS" = "1" ]; then
            echo "✅ Tabulka $table existuje"
        else
            echo "❌ Tabulka $table neexistuje"
        fi
    done
    
    # Test EF Core migrací
    echo "ℹ️  Testuji EF Core migrace..."
    if command -v sqlcmd &> /dev/null; then
        EF_EXISTS=$(sqlcmd -S localhost,1433 -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '__EFMigrationsHistory'" -C -h -1 2>&1 | grep -o '[0-9]')
    else
        EF_EXISTS=$(docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '__EFMigrationsHistory'" -C -h -1 2>&1 | grep -o '[0-9]')
    fi
    
    if [ "$EF_EXISTS" = "1" ]; then
        echo "✅ EF Core migrace jsou k dispozici"
        if command -v sqlcmd &> /dev/null; then
            EF_COUNT=$(sqlcmd -S localhost,1433 -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT COUNT(*) FROM [__EFMigrationsHistory]" -C -h -1 2>&1 | grep -o '[0-9]')
        else
            EF_COUNT=$(docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT COUNT(*) FROM [__EFMigrationsHistory]" -C -h -1 2>&1 | grep -o '[0-9]')
        fi
        echo "📊 Počet EF migrací: $EF_COUNT"
    else
        echo "ℹ️  EF Core migrace nejsou k dispozici (používá se SQL struktura)"
    fi
    
else
    echo "⚠️  Databáze ServiceCatalogueManager neexistuje"
    echo "   Spusťte setup skript pro vytvoření databáze"
fi

echo ""
echo "✅ Test dokončen"