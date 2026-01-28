#!/bin/bash

# Testovací skript pro ověření struktury db_structure.sql
# Tento skript analyzuje SQL soubor a ověří jeho strukturu

echo "🔍 Analýza db_structure.sql"
echo "============================="

# Cesta k souboru
DB_STRUCTURE="/home/user/webapp/database/schema/db_structure.sql"

if [[ ! -f "$DB_STRUCTURE" ]]; then
    echo "❌ Soubor $DB_STRUCTURE neexistuje!"
    exit 1
fi

echo "✅ Soubor nalezen: $DB_STRUCTURE"
echo ""

# Spočítat řádky
echo "📊 Statistiky souboru:"
line_count=$(wc -l < "$DB_STRUCTURE")
echo "   Počet řádků: $line_count"

# Spočítat tabulky
echo "📋 Analýza tabulek:"
table_count=$(grep -c "CREATE TABLE" "$DB_STRUCTURE")
echo "   Počet CREATE TABLE příkazů: $table_count"

# Extrahovat názvy tabulek
echo "🔍 Nalezené tabulky:"
grep "CREATE TABLE" "$DB_STRUCTURE" | sed 's/.*CREATE TABLE \[\?\?\?\?\?\?\?\?\?\?\?\]\.\?\?\?\?\?\?\?\?\?\?\?\[\?\?\?\?\?\?\?\?\?\?\?\]\.\?\?\?\?\?\?\?\?\?\?\?\[\?\?\?\?\?\?\?\?\?\?\?\]//' | sed 's/.*CREATE TABLE \[dbo\]\.\[//' | sed 's/\].*//' | nl

# Spočítat lookup tabulky
lu_count=$(grep -c "CREATE TABLE.*LU_" "$DB_STRUCTURE")
echo "   Počet lookup tabulek (LU_*): $lu_count"

# Spočítat pohledy
view_count=$(grep -c "CREATE VIEW" "$DB_STRUCTURE")
echo "   Počet CREATE VIEW příkazů: $view_count"

# Ověřit strukturu - základní kontrola
echo ""
echo "🔍 Kontrola struktury:"

# Kontrola na DROP TABLE
drop_count=$(grep -c "DROP TABLE" "$DB_STRUCTURE")
echo "   Počet DROP TABLE: $drop_count"

# Kontrola na FOREIGN KEY
fk_count=$(grep -c "FOREIGN KEY" "$DB_STRUCTURE")
echo "   Počet FOREIGN KEY omezení: $fk_count"

# Kontrola na PRIMARY KEY
pk_count=$(grep -c "PRIMARY KEY" "$DB_STRUCTURE")
echo "   Počet PRIMARY KEY: $pk_count"

# Kontrola seed dat
seed_count=$(grep -c "INSERT INTO \[dbo\]\.\[LU_" "$DB_STRUCTURE")
echo "   Počet INSERT příkazů pro LU_* tabulky: $seed_count"

echo ""
echo "✅ Analýza dokončena!"
echo "   Celkově: $tableCount tabulek, $lu_count lookup tabulek, $view_count pohledů"