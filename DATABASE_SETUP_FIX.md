# Database Setup Fix - Oprava SQL Script Execution

## 🐛 Problém

SQL skript `db_structure.sql` se nespouštěl správně v Docker kontejneru přes `sqlcmd`, což vedlo k vytvoření databáze bez tabulek.

### Symptomy:
- ✅ Databáze byla vytvořena
- ❌ Žádné tabulky nebyly vytvořeny (0 z 42 očekávaných)
- ⚠️ Setup skript hlásil "aplikováno", ale tabulky chyběly
- 🔍 Chyběl debug výstup pro diagnostiku

## 🔧 Implementované opravy

### 1. **Konverze Line Endings (CRLF → LF)**
**Problém:** SQL soubor obsahoval Windows line endings (`\r\n`), které způsobovaly problémy v Linux Docker kontejneru.

**Řešení:**
```powershell
# Před docker cp - konvertovat line endings
$tempFile = [System.IO.Path]::GetTempFileName()
$content = Get-Content $FilePath -Raw -Encoding UTF8
$content = $content -replace "`r`n", "`n"  # CRLF → LF
$content = $content -replace "`r", ""      # Remove stray CRs
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($tempFile, $content, $utf8NoBom)
docker cp $tempFile "${ContainerName}:/tmp/schema.sql"
```

### 2. **Verbose Debug Output**
**Problém:** Nebylo vidět, co se děje během SQL execution.

**Řešení:**
```powershell
Write-Host "📋 SQL Execution Output:" -ForegroundColor Cyan
$sqlcmdOutput | ForEach-Object { 
    $line = $_.ToString()
    if ($line -match "Msg \d+.*Level \d+") {
        Write-Host "   $line" -ForegroundColor Red
    } elseif ($line -match "^(Changed database context|PRINT|rows? affected)") {
        Write-Host "   $line" -ForegroundColor Green
    } else {
        Write-Host "   $line" -ForegroundColor Gray
    }
}
```

### 3. **Improved Error Detection**
**Problém:** Špatná detekce chyb vs. varování.

**Řešení:**
```powershell
# Rozlišení SQL error levels:
# Level 16-25: Chyby (skutečné problémy)
# Level 11-15: Varování (lze ignorovat)
# Level 0-10: Informace

$errorMatches = $schemaResult | Select-String -Pattern "Msg \d+.*Level (1[6-9]|2[0-5])"
$warningMatches = $schemaResult | Select-String -Pattern "Msg \d+.*Level (1[1-5])"
```

### 4. **Better Status Reporting**
Přidán strukturovaný výstup na konci setupu:

```
═══════════════════════════════════════════════════════════
✅ DATABASE SETUP SUCCESSFUL!
═══════════════════════════════════════════════════════════

✅ Všechny klíčové tabulky nové struktury byly úspěšně vytvořeny!
   Celkový počet tabulek: 42
   Vytvořeno z db_structure.sql: 42 tabulek
```

## 📊 Změněné soubory

- `database/scripts/setup-db-fixed-v2.ps1` - Hlavní setup skript s opravami

## 🧪 Testování

Pro otestování opravy:

```powershell
# V PowerShell z kořenové složky projektu
.\start-all.ps1 -UseDocker -RecreateDb

# Nebo přímo setup script
.\database\scripts\setup-db-fixed-v2.ps1 -Force -NoEFCore
```

### Očekávaný výsledek:
```
✅ Kompletní struktura databáze byla úspěšně aplikována
✅ Vytvořeno tabulek: 42
✅ DATABASE SETUP SUCCESSFUL!
```

## 🔍 Diagnostika problémů

Pokud stále vidíte problémy:

1. **Zkontrolujte SQL Output sekci** - obsahuje přesný výstup sqlcmd
2. **Ověřte Docker logs**: `docker logs scm-sqlserver`
3. **Zkontrolujte line endings**: `file database/schema/db_structure.sql`
4. **Manuální test v kontejneru**:
   ```bash
   docker exec -it scm-sqlserver bash
   /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P 'YourStrong@Passw0rd'
   SELECT name FROM sys.databases;
   GO
   USE ServiceCatalogueManager;
   GO
   SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
   GO
   ```

## 📝 Poznámky

- Oprava je backwards compatible - funguje i se starými SQL skripty
- Temp soubory jsou automaticky čištěny po použití
- Exit code správně indikuje úspěch (0) nebo selhání (1)
- Všechny opravy jsou zakomentovány s `FIX #N` pro snadné vyhledání

## 🎯 Impact

- ✅ SQL skripty nyní fungují v Docker prostředí
- ✅ Lepší error reporting pro diagnostiku
- ✅ Správné line ending handling
- ✅ Clear status reporting pro uživatele
