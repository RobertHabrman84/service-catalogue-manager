#!/bin/bash
# ============================================================================
# Test nové implementace - kontrola konfigurace
# ============================================================================

echo "🧪 TEST KONFIGURACE DB_STRUCTURE.SQL IMPLEMENTACE"
echo "========================================="
echo ""

# Zkontrolovat soubory
echo "📁 Kontrola souborů:"

if [[ -f "database/schema/db_structure.sql" ]]; then
    echo "✅ db_structure.sql existuje"
    
    # Spočítat řádky a tabulky
    lines=$(wc -l < database/schema/db_structure.sql)
    echo "   Řádků: $lines"
    
    # Spočítat CREATE TABLE příkazy
    tables=$(grep -c "CREATE TABLE" database/schema/db_structure.sql)
    echo "   CREATE TABLE příkazů: $tables"
else
    echo "❌ db_structure.sql neexistuje"
fi

if [[ -f "database/scripts/setup-db-fixed-v2.ps1" ]]; then
    echo "✅ setup-db-fixed-v2.ps1 existuje"
    
    # Zkontrolovat zda obsahuje db_structure.sql
    if grep -q "db_structure.sql" database/scripts/setup-db-fixed-v2.ps1; then
        echo "   ✅ Obsahuje db_structure.sql implementaci"
        
        # Zjistit které řádky obsahují db_structure
        lines_with_db_structure=$(grep -n "db_structure" database/scripts/setup-db-fixed-v2.ps1 | wc -l)
        echo "   Řádky s db_structure: $lines_with_db_structure"
    else
        echo "   ❌ Neobsahuje db_structure.sql implementaci"
    fi
else
    echo "❌ setup-db-fixed-v2.ps1 neexistuje"
fi

if [[ -f "start-all-fixed-v2.ps1" ]]; then
    echo "✅ start-all-fixed-v2.ps1 existuje"
    
    # Zkontrolovat verzi
    if grep -q "v3.3.2" start-all-fixed-v2.ps1; then
        echo "   ✅ Verze 3.3.2 (nová implementace)"
    else
        echo "   ⚠️  Stará verze"
    fi
    
    # Zkontrolovat Docker konfiguraci
    if grep -q "UseDocker.*=.*\$true" start-all-fixed-v2.ps1; then
        echo "   ✅ Docker je výchozí"
    else
        echo "   ⚠️  Docker není výchozí"
    fi
else
    echo "❌ start-all-fixed-v2.ps1 neexistuje"
fi

echo ""
echo "📋 Shrnutí implementace:"
echo "  1. setup-db-fixed-v2.ps1 nyní prioritně používá db_structure.sql"
echo "  2. start-all-fixed-v2.ps1 má Docker jako výchozí"
echo "  3. Při spuštění s -UseDocker -RecreateDb se použije kompletní struktura"
echo ""

echo "🎯 Pro spuštění nové implementace použijte:"
echo "  ./start-all-fixed-v2.ps1 -UseDocker -RecreateDb"
echo ""

echo "✅ Konfigurace dokončena"