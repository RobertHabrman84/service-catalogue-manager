#!/bin/bash
# ============================================================================
# Service Catalogue Manager - Start All (BASH Version)
# ============================================================================
# Bash verze kompatibilní s původním PowerShell skriptem
# ============================================================================

# Defaultní hodnoty
USE_DOCKER=false
RECREATE_DB=false

# Zpracování parametrů
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--docker)
            USE_DOCKER=true
            shift
            ;;
        -r|--recreate)
            RECREATE_DB=true
            shift
            ;;
        -h|--help)
            echo "Použití: $0 [OPTIONS]"
            echo "Options:"
            echo "  -d, --docker     Použít Docker"
            echo "  -r, --recreate    Převytvořit databázi"
            echo "  -h, --help        Zobrazit nápovědu"
            exit 0
            ;;
        *)
            echo "Neznámý parametr: $1"
            echo "Použijte -h nebo --help pro nápovědu"
            exit 1
            ;;
    esac
done

echo "🚀 Spouštím Service Catalogue Manager (BASH Version)"
echo "============================================="
echo ""

# Kontrola Dockeru
if ! command -v docker &> /dev/null; then
    echo "❌ Docker není nainstalován nebo není v PATH"
    exit 1
fi

# Spuštění SQL Server kontejneru
echo "ℹ️  Spouštím SQL Server kontejner..."
if docker ps | grep -q "scm-sqlserver"; then
    echo "✅ SQL Server kontejner již běží"
elif docker ps -a | grep -q "scm-sqlserver"; then
    echo "ℹ️  Startuji existující SQL Server kontejner..."
    docker start scm-sqlserver
    sleep 10
else
    echo "📦 Vytvářím nový SQL Server kontejner..."
    docker run -d \
        --name scm-sqlserver \
        -e 'ACCEPT_EULA=Y' \
        -e 'SA_PASSWORD=YourStrong@Passw0rd' \
        -p 1433:1433 \
        mcr.microsoft.com/mssql/server:2022-latest
    
    echo "⏳ Čekám na inicializaci SQL Serveru..."
    sleep 30
fi

# Kontrola, zda SQL Server běží
echo "ℹ️  Kontroluji SQL Server..."
for i in {1..30}; do
    if docker exec scm-sqlserver /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "YourStrong@Passw0rd" -Q "SELECT 1" -C -h -1 2>/dev/null | grep -q "1"; then
        echo "✅ SQL Server je připraven"
        break
    fi
    
    if [ $i -eq 30 ]; then
        echo "❌ SQL Server není připraven po 30 sekundách"
        exit 1
    fi
    
    echo "   Čekám... ($i/30)"
    sleep 2
done

# Nastavení databáze
echo "ℹ️  Nastavuji databázi..."
SCRIPT_DIR="$(dirname "$0")"

if [ "$RECREATE_DB" = true ]; then
    echo "🔄 Převytvářím databázi..."
    bash "$SCRIPT_DIR/setup-db-bash.sh" -f
else
    bash "$SCRIPT_DIR/setup-db-bash.sh"
fi

# Kontrola výsledku
if [ $? -eq 0 ]; then
    echo "✅ Databáze úspěšně nastavena"
else
    echo "❌ Chyba při nastavování databáze"
    exit 1
fi

# Závěrečné informace
echo ""
echo "🎉 Service Catalogue Manager je připraven!"
echo ""
echo "📋 Informace o připojení:"
echo "   Server: localhost,1433"
echo "   Databáze: ServiceCatalogueManager"
echo "   Uživatel: sa"
echo "   Heslo: YourStrong@Passw0rd"
echo ""
echo "🔗 Připojovací řetězec:"
echo "   Server=localhost,1433;Database=ServiceCatalogueManager;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True"
echo ""
echo "🧪 Pro testování spusťte:"
echo "   bash $SCRIPT_DIR/test-db-bash.sh"
echo ""
echo "📁 Schémata jsou v: $SCRIPT_DIR/../schema/"
echo ""

# Zobrazení statusu
echo "ℹ️  Status kontejnerů:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(scm-sqlserver|NAMES)"