#!/bin/bash
# ============================================================================
# Test nové implementace db_structure.sql pro Linux
# ============================================================================

echo "🧪 TEST NOVÉ IMPLEMENTACE DB_STRUCTURE.SQL (Linux)"
echo "========================================="
echo ""

# Zastavit případný běžící container
docker stop scm-sqlserver 2>/dev/null
docker rm scm-sqlserver 2>/dev/null

echo "📋 Parametry testu:"
echo "  - UseDocker: true"
echo "  - RecreateDb: true"
echo ""

# Spustit nový skript
echo "🚀 Spouštím start-all-fixed-v2.ps1 s novou implementací..."

start_time=$(date +%s)

# Spustit skript a čekat na výsledek
pwsh -File "./start-all-fixed-v2.ps1" -UseDocker -RecreateDb -DbOnly

end_time=$(date +%s)
duration=$((end_time - start_time))

echo ""
echo "⏱️  Test dokončen za ${duration} sekund"
echo ""

# Kontrola výsledků
echo "🔍 Kontrola výsledků:"

# Zkontrolovat zda container běží
if docker ps --filter "name=scm-sqlserver" --format "{{.Names}}" | grep -q "scm-sqlserver"; then
    echo "✅ SQL Server container běží"
else
    echo "❌ SQL Server container neběží"
fi

# Zkontrolovat databázi a tabulky
echo ""
echo "📊 Kontrola databáze a tabulek:"

# Počet tabulek v databázi
table_count=$(docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0" -h -1 2>/dev/null | tr -d ' ')

if [[ "$table_count" =~ ^[0-9]+$ ]]; then
    echo "✅ Počet uživatelských tabulek: $table_count"
    
    if [[ $table_count -ge 42 ]]; then
        echo "✅ Struktura databáze obsahuje očekávaných 42+ tabulek"
    else
        echo "⚠️  Databáze obsahuje pouze $table_count tabulek (očekáváno 42+)"
    fi
else
    echo "⚠️  Nepodařilo se zjistit počet tabulek"
fi

# Zkontrolovat konkrétní tabulky
echo ""
echo "🔍 Kontrola konkrétních tabulek:"

test_tables=("ServiceCatalog" "ServiceCategory" "ServiceStatus" "ServicePriority")

for table in "${test_tables[@]}"; do
    if docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -d ServiceCatalogueManager -Q "SELECT TOP 1 1 FROM [$table]" -h -1 2>/dev/null; then
        echo "✅ Tabulka $table existuje"
    else
        echo "❌ Tabulka $table neexistuje"
    fi
done

echo ""
echo "📋 Souhrn testu:"
echo "  Nová implementace používá db_structure.sql pro vytvoření kompletní databázové struktury."
echo "  Oproti EF Core migracím, které vytvoří pouze základní tabulky."
echo ""

# Vyčistit
echo "🧹 Čištění prostředí..."
docker stop scm-sqlserver 2>/dev/null
docker rm scm-sqlserver 2>/dev/null

echo ""
echo "✅ Test dokončen"