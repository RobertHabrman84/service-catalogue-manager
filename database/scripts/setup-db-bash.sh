#!/bin/bash
# ============================================================================
# Service Catalogue Manager - Database Setup (BASH Version)
# ============================================================================
# Bash verze kompatibilní s původním PowerShell skriptem
# ============================================================================

# Defaultní hodnoty
FORCE=false
DB_NAME="ServiceCatalogueManager"
CONTAINER_NAME="scm-sqlserver"
SA_PASSWORD="YourStrong@Passw0rd"
SERVER="localhost,1433"
SCHEMA_DIR="$(dirname "$0")/../schema"

# Zpracování parametrů
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=true
            shift
            ;;
        -d|--dbname)
            DB_NAME="$2"
            shift 2
            ;;
        -c|--container)
            CONTAINER_NAME="$2"
            shift 2
            ;;
        *)
            echo "Neznámý parametr: $1"
            echo "Použití: $0 [-f|--force] [-d|--dbname jméno_db] [-c|--container jméno_kontejneru]"
            exit 1
            ;;
    esac
done

echo "🗄️  Service Catalogue Database Setup (BASH Version)"
echo "============================================="
echo ""

# Funkce pro spuštění SQL příkazů
invoke_sql_command() {
    local query="$1"
    local database="$2"
    
    if command -v sqlcmd &> /dev/null; then
        if [ -n "$database" ]; then
            sqlcmd -S "$SERVER" -U sa -P "$SA_PASSWORD" -d "$database" -Q "$query" -C -h -1 2>&1
        else
            sqlcmd -S "$SERVER" -U sa -P "$SA_PASSWORD" -Q "$query" -C -h -1 2>&1
        fi
    else
        if [ -n "$database" ]; then
            docker exec "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$SA_PASSWORD" -d "$database" -Q "$query" -C -h -1 2>&1
        else
            docker exec "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$SA_PASSWORD" -Q "$query" -C -h -1 2>&1
        fi
    fi
}

# Funkce pro spuštění SQL souboru
invoke_sql_file() {
    local file_path="$1"
    local database="$2"
    
    if command -v sqlcmd &> /dev/null; then
        if [ -n "$database" ]; then
            sqlcmd -S "$SERVER" -U sa -P "$SA_PASSWORD" -d "$database" -i "$file_path" -C 2>&1
        else
            sqlcmd -S "$SERVER" -U sa -P "$SA_PASSWORD" -i "$file_path" -C 2>&1
        fi
    else
        # Pro Docker exec potřebujeme nejdřív zkopírovat soubor do kontejneru
        echo "ℹ️  Kopíruji schéma do kontejneru..."
        docker cp "$file_path" "${CONTAINER_NAME}:/tmp/schema.sql" 2>&1 | grep -v "^$"
        
        if [ -n "$database" ]; then
            docker exec "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$SA_PASSWORD" -d "$database" -i /tmp/schema.sql -C 2>&1
        else
            docker exec "$CONTAINER_NAME" /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "$SA_PASSWORD" -i /tmp/schema.sql -C 2>&1
        fi
    fi
}

# Kontrola, zda je SQL Server spuštěn
echo "ℹ️  Kontroluji připojení k SQL Server..."
if ! invoke_sql_command "SELECT 1" | grep -q "1"; then
    echo "❌ SQL Server není dostupný!"
    echo "   Zkontrolujte, zda je Docker kontejner spuštěn:"
    echo "   docker ps"
    echo "   docker start $CONTAINER_NAME"
    exit 1
fi

echo "✅ SQL Server běží"

# Kontrola existence databáze
echo "ℹ️  Kontroluji existenci databáze '$DB_NAME'..."
check_db_query="SELECT COUNT(*) FROM sys.databases WHERE name = '$DB_NAME'"
db_exists=$(invoke_sql_command "$check_db_query" | grep -o '[0-9]')

if [ "$db_exists" = "1" ]; then
    if [ "$FORCE" = false ]; then
        echo "⚠️  Databáze $DB_NAME již existuje!"
        echo "   Použijte -f nebo --force pro převytvoření"
        exit 0
    fi
    
    echo "⚠️  Mažu existující databázi..."
    drop_query="DROP DATABASE [$DB_NAME]"
    invoke_sql_command "$drop_query" > /dev/null
    sleep 2
fi

# Vytvoření databáze
echo "📦 Vytvářím databázi '$DB_NAME'..."
create_query="CREATE DATABASE [$DB_NAME]"
if invoke_sql_command "$create_query" > /dev/null; then
    echo "✅ Databáze vytvořena"
else
    echo "❌ Chyba při vytváření databáze"
    exit 1
fi

sleep 2

# Pokus o EF Core migrace (pouze pokud existuje dotnet)
backend_dir="$(dirname "$0")/../../src/backend/ServiceCatalogueManager.Api"
if command -v dotnet &> /dev/null && [ -d "$backend_dir" ] && [ -f "$backend_dir/ServiceCatalogueManager.Api.csproj" ]; then
    echo "ℹ️  Pokouším se o EF Core migrace..."
    cd "$backend_dir"
    
    connection_string="Server=$SERVER;Database=$DB_NAME;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True"
    export AzureSQL__ConnectionString="$connection_string"
    export ConnectionStrings__AzureSQL="$connection_string"
    export ConnectionStrings__DefaultConnection="$connection_string"
    
    # Instalace EF Core tools
    if ! dotnet tool list --global | grep -q dotnet-ef; then
        echo "ℹ️  Instaluji EF Core nástroje..."
        dotnet tool install --global dotnet-ef --version 8.* 2>/dev/null
    fi
    
    echo "ℹ️  Aplikuji EF Core migrace..."
    if dotnet ef database update --connection "$connection_string" 2>&1; then
        echo "✅ EF Core migrace úspěšně aplikovány"
        
        # Ověření EF Core migrací
        ef_table_query="SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '__EFMigrationsHistory' AND TABLE_CATALOG = '$DB_NAME'"
        ef_exists=$(invoke_sql_command "$ef_table_query" | grep -o '[0-9]')
        
        if [ "$ef_exists" = "1" ]; then
            ef_count_query="SELECT COUNT(*) FROM [$DB_NAME].[__EFMigrationsHistory]"
            ef_count=$(invoke_sql_command "$ef_count_query" | grep -o '[0-9]')
            echo "✅ Tabulka EF migrací existuje s $ef_count migracemi"
        fi
        
        # Kontrola tabulek
        count_query="SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '$DB_NAME'"
        table_count=$(invoke_sql_command "$count_query" | grep -o '[0-9]')
        
        echo "✅ Nastavení databáze dokončeno!"
        echo "   Vytvořených tabulek: $table_count"
        echo ""
        echo "Připojovací řetězec:"
        echo "Server=$SERVER;Database=$DB_NAME;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True"
        exit 0
    else
        echo "⚠️  EF Core migrace selhaly, pokračuji SQL skripty..."
    fi
fi

# Fallback na SQL skripty
echo "📝 Implementuji SQL strukturu databáze..."

# Použití nové struktury z db_structure.sql
main_schema_file="$SCHEMA_DIR/db_structure.sql"
if [ -f "$main_schema_file" ]; then
    echo "ℹ️  Aplikuji kompletní strukturu z db_structure.sql..."
    if schema_result=$(invoke_sql_file "$main_schema_file" "$DB_NAME" 2>&1); then
        echo "✅ Kompletní struktura databáze byla úspěšně aplikována"
    else
        echo "⚠️  Struktura byla aplikována s varováními"
        echo "   Detail: $schema_result"
    fi
else
    echo "⚠️  Hlavní struktura db_structure.sql nebyla nalezena, používám záložní skripty..."
    
    # Záložní starší skripty
    schema_files=("001_initial_schema.sql" "002_lookup_tables.sql" "003_lookup_data.sql")
    
    for schema_file in "${schema_files[@]}"; do
        full_schema_path="$SCHEMA_DIR/$schema_file"
        
        if [ -f "$full_schema_path" ]; then
            echo "ℹ️  Aplikuji $schema_file..."
            
            if invoke_sql_file "$full_schema_path" "$DB_NAME" > /dev/null; then
                echo "✅ $schema_file úspěšně aplikován"
            else
                echo "⚠️  Skript $schema_file měl varování"
            fi
        else
            echo "⚠️  Skript nebyl nalezen: $full_schema_path"
        fi
    done
fi

# Ověření tabulek
echo "ℹ️  Ověřuji novou strukturu databáze..."

# Hlavní kontrola všech tabulek
count_query="SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '$DB_NAME'"
table_count=$(invoke_sql_command "$count_query" | grep -o '[0-9]')

# Specifická kontrola hlavních tabulek
main_tables_query="SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME IN ('ServiceCatalogItem', 'LU_ServiceCategory', 'LU_SizeOption', 'LU_CloudProvider') AND TABLE_CATALOG = '$DB_NAME'"
main_tables_count=$(invoke_sql_command "$main_tables_query" | grep -o '[0-9]')

# Kontrola lookup tabulek
lookup_tables_query="SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'LU_%' AND TABLE_CATALOG = '$DB_NAME'"
lookup_tables_count=$(invoke_sql_command "$lookup_tables_query" | grep -o '[0-9]')

echo "✅ Databáze úspěšně nastavena!"
echo "   Celkový počet tabulek: $table_count"
echo "   Hlavní tabulky: $main_tables_count"
echo "   Lookup tabulky: $lookup_tables_count"
echo ""

# Kontrola klíčových tabulek
required_tables=("ServiceCatalogItem" "LU_ServiceCategory" "LU_SizeOption" "LU_CloudProvider" "LU_DependencyType" "ServiceDependency" "ServiceScopeCategory" "ServiceScopeItem" "ServiceInput" "ServiceOutputCategory" "ServiceOutputItem")

missing_tables=()
for table in "${required_tables[@]}"; do
    check_query="SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$table' AND TABLE_CATALOG = '$DB_NAME'"
    exists=$(invoke_sql_command "$check_query" | grep -o '[0-9]')
    
    if [ "$exists" != "1" ]; then
        missing_tables+=("$table")
    fi
done

if [ ${#missing_tables[@]} -eq 0 ]; then
    echo "✅ Všechny klíčové tabulky nové struktury byly úspěšně vytvořeny!"
else
    echo "⚠️  Chybějící tabulky: ${missing_tables[*]}"
    echo "   To může znamenat, že struktura nebyla kompletně aplikována."
fi

echo ""
echo "Připojovací řetězec:"
echo "Server=$SERVER;Database=$DB_NAME;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True"
echo ""

# Dodatečná kontrola EF Core migrací
echo "ℹ️  Kontrola EF Core migrací..."
ef_check_query="SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '__EFMigrationsHistory' AND TABLE_CATALOG = '$DB_NAME'"
ef_exists=$(invoke_sql_command "$ef_check_query" | grep -o '[0-9]')

if [ "$ef_exists" = "1" ]; then
    ef_count_query="SELECT COUNT(*) FROM [$DB_NAME].[__EFMigrationsHistory]"
    ef_migration_count=$(invoke_sql_command "$ef_count_query" | grep -o '[0-9]')
    echo "✅ EF Core migrace: $ef_migration_count aplikováno"
else
    echo "ℹ️  EF Core migrace nebyly použity (používá se SQL struktura)"
fi

echo ""
if ! command -v sqlcmd &> /dev/null; then
    echo "💡 Tip: Pro připojení zvenčí nainstalujte SQL Server Command Line Utilities"
    echo "   Stáhnout: https://aka.ms/sqlcmd"
fi