#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - Database Setup (FIXED V3)
# ============================================================================
# Opravená verze kompatibilní s start-all-fixed-v3.ps1
# TRUE NO EF CORE - pouze SQL skripty
# ============================================================================

param(
    [switch]$Force = $false,
    [string]$DbName = "ServiceCatalogueManager",
    [string]$ContainerName = "scm-sqlserver",
    [switch]$NoEFCore = $true  # Vždy TRUE pro tuto verzi
)

$ErrorActionPreference = "Stop"

# Vynutit NoEFCore režim
$NoEFCoreMode = $true

$SA_PASSWORD = "YourStrong@Passw0rd"
$SERVER = "localhost,1433"
$SCHEMA_DIR = Join-Path $PSScriptRoot "..\schema"

Write-Host "🗄️  Service Catalogue Database Setup (FIXED V3 - TRUE NO EF CORE)" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

# Check if sqlcmd is available locally or use Docker exec
$useSqlCmd = $null -ne (Get-Command "sqlcmd" -ErrorAction SilentlyContinue)

if (-not $useSqlCmd) {
    Write-Host "ℹ️  Using Docker exec (sqlcmd not found locally)" -ForegroundColor Cyan
}

# Helper function to run SQL commands
function Invoke-SqlCommand {
    param(
        [string]$Query,
        [string]$Database = $null
    )
    
    if ($useSqlCmd) {
        if ($Database) {
            sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $Database -Q $Query -C -h -1 2>&1
        } else {
            sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -Q $Query -C -h -1 2>&1
        }
    } else {
        if ($Database) {
            docker exec $ContainerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -d $Database -Q $Query -C -h -1 2>&1
        } else {
            docker exec $ContainerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -Q $Query -C -h -1 2>&1
        }
    }
}

function Invoke-SqlFile {
    param(
        [string]$FilePath,
        [string]$Database = $null
    )
    
    if ($useSqlCmd) {
        if ($Database) {
            sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $Database -i $FilePath -C 2>&1
        } else {
            sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -i $FilePath -C 2>&1
        }
    } else {
        # For Docker exec, we need to copy file into container first
        Write-Host "ℹ️  Copying schema file to container..." -ForegroundColor Cyan
        docker cp $FilePath "${ContainerName}:/tmp/schema.sql" 2>&1 | Out-Null
        
        if ($Database) {
            docker exec $ContainerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -d $Database -i /tmp/schema.sql -C 2>&1
        } else {
            docker exec $ContainerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -i /tmp/schema.sql -C 2>&1
        }
    }
}

# Check if SQL Server is running
Write-Host "ℹ️  Checking SQL Server connection..." -ForegroundColor Cyan
try {
    $testResult = Invoke-SqlCommand -Query "SELECT 1"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Connection failed"
    }
    
    Write-Host "✅ SQL Server is running" -ForegroundColor Green
} catch {
    Write-Host "❌ SQL Server is not accessible!" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    Write-Host "   Make sure Docker container is running:" -ForegroundColor Yellow
    Write-Host "   docker ps" -ForegroundColor Yellow
    Write-Host "   docker start $ContainerName" -ForegroundColor Yellow
    Write-Host "   or check container logs:" -ForegroundColor Yellow
    Write-Host "   docker logs $ContainerName" -ForegroundColor Yellow
    exit 1
}

# Check if database exists
Write-Host "ℹ️  Checking if database '$DbName' exists..." -ForegroundColor Cyan
$checkDbQuery = "SELECT COUNT(*) FROM sys.databases WHERE name = '$DbName'"
$dbExistsResult = Invoke-SqlCommand -Query $checkDbQuery

# OPRAVA: Správná extrakce čísla z výsledku
$dbExists = $false
if ($dbExistsResult -ne $null) {
    if ($dbExistsResult -is [array]) {
        foreach ($line in $dbExistsResult) {
            if ($line -match '(\d+)') {
                $dbExists = ($matches[1] -eq "1")
                break
            }
        }
    } else {
        if ($dbExistsResult -match '(\d+)') {
            $dbExists = ($matches[1] -eq "1")
        }
    }
}

if ($dbExists) {
    if (-not $Force) {
        Write-Host "⚠️  Database $DbName already exists!" -ForegroundColor Yellow
        Write-Host "   Use -Force to recreate it" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "⚠️  Dropping existing database..." -ForegroundColor Yellow
    $dropQuery = "DROP DATABASE [$DbName]"
    Invoke-SqlCommand -Query $dropQuery | Out-Null
    Start-Sleep -Seconds 2
}

# Create database
Write-Host "📦 Creating database '$DbName'..." -ForegroundColor Cyan
try {
    $createQuery = "CREATE DATABASE [$DbName]"
    Invoke-SqlCommand -Query $createQuery | Out-Null
    Write-Host "✅ Database created" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to create database: $_" -ForegroundColor Red
    Write-Host "   Query: $createQuery" -ForegroundColor Gray
    exit 1
}

# Wait a moment for database to be ready
Start-Sleep -Seconds 2

# TRUE NO EF CORE - přeskočit EF Core migrace úplně
Write-Host "ℹ️  TRUE NO EF CORE mode: skipping EF Core migrations, using pure SQL scripts" -ForegroundColor Cyan

# Použít novou kompletní strukturu z db_structure.sql (přednostní)
$mainSchemaFile = Join-Path $SCHEMA_DIR "db_structure.sql"
if (Test-Path $mainSchemaFile) {
    Write-Host "ℹ️  Aplikuji kompletní strukturu databáze z db_structure.sql..." -ForegroundColor Cyan
    Write-Host "   Soubor: $mainSchemaFile" -ForegroundColor Gray
    
    try {
        $schemaResult = Invoke-SqlFile -FilePath $mainSchemaFile -Database $DbName
        
        # Zkontrolovat, zda výsledek obsahuje chyby
        $hasErrors = $schemaResult -like "*Msg*" -or $schemaResult -like "*Error*" -or $schemaResult -like "*Exception*"
        $hasSuccess = $schemaResult -like "*PRINT*" -or $schemaResult -like "*(1 row affected)*" -or $LASTEXITCODE -eq 0
        
        if ($hasErrors) {
            Write-Host "⚠️  Aplikace struktury skončila s varováními nebo chybami:" -ForegroundColor Yellow
            Write-Host "   Detail: $schemaResult" -ForegroundColor Gray
            Write-Host "   ExitCode: $LASTEXITCODE" -ForegroundColor Gray
            
            # Pokud jsou to jen varování, pokračujeme
            if ($schemaResult -like "*already exists*" -or $schemaResult -like "*Cannot drop*") {
                Write-Host "ℹ️  Varování jsou očekávaná (tabulky již mohou existovat)" -ForegroundColor Cyan
            }
        } elseif ($hasSuccess -or $LASTEXITCODE -eq 0) {
            Write-Host "✅ Kompletní struktura databáze byla úspěšně aplikována" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Neočekávaný výsledek při aplikaci struktury" -ForegroundColor Yellow
            Write-Host "   Výsledek: $schemaResult" -ForegroundColor Gray
        }
    } catch {
        Write-Host "❌ Chyba při aplikaci struktury databáze: $_" -ForegroundColor Red
        Write-Host "Pokračuji s záložními skripty..." -ForegroundColor Yellow
        $mainSchemaFile = $null  # Vynutit použití záložních skriptů
    }
} else {
    Write-Host "⚠️  Hlavní struktura db_structure.sql nebyla nalezena!" -ForegroundColor Red
    Write-Host "   Očekávaná cesta: $mainSchemaFile" -ForegroundColor Red
    exit 1
}

# OPRAVA: Správná kontrola počtu tabulek
Write-Host "ℹ️  Ověřuji novou strukturu databáze..." -ForegroundColor Cyan

# Hlavní kontrola všech tabulek
$countQuery = "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '$DbName'"
$tableCountResult = Invoke-SqlCommand -Query $countQuery

# OPRAVA: Lepší extrakce čísla z výsledku
$tableCount = 0
try {
    $tableCountLines = @()
    if ($tableCountResult -ne $null) {
        if ($tableCountResult -is [array]) {
            $tableCountLines = $tableCountResult
        } else {
            $tableCountLines = @($tableCountResult)
        }
    }
    
    # Najít první číslo v jakémkoli řádku
    foreach ($line in $tableCountLines) {
        if ($line -match '(\d+)') {
            $tableCount = [int]::Parse($matches[1])
            break
        }
    }
} catch {
    $tableCount = 0
}

# Načtení a kontrola všech tabulek ze souboru
$expectedTables = @()
$foundTables = @()
$missingTables = @()

if ($mainSchemaFile -and (Test-Path $mainSchemaFile)) {
    try {
        $dbStructureContent = Get-Content -Path $mainSchemaFile -Raw -ErrorAction Stop
        if ($dbStructureContent) {
            $tableMatches = [regex]::Matches(
                $dbStructureContent,
                'CREATE\s+TABLE\s+(?:\[\s*(?<schema>\w+)\s*\]\.|(?<schema>\w+)\.)?\[?(?<name>\w+)\]?'
            )
            $expectedTables = $tableMatches |
                ForEach-Object { $_.Groups['name'].Value } |
                Where-Object { $_ } |
                Sort-Object -Unique

            if ($expectedTables.Count -gt 0) {
                Write-Host "ℹ️  V souboru nalezeno $($expectedTables.Count) tabulek:" -ForegroundColor Cyan
                Write-Host "   $($expectedTables -join ', ')" -ForegroundColor Gray
            } else {
                Write-Host "⚠️  Ve struktuře nebyly nalezeny žádné tabulky" -ForegroundColor Yellow
            }

            foreach ($table in $expectedTables) {
                $checkQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$table' AND TABLE_CATALOG = '$DbName'"
                $checkResult = Invoke-SqlCommand -Query $checkQuery
                
                # OPRAVA: Správná kontrola existence tabulky
                $exists = $false
                if ($checkResult -ne $null) {
                    if ($checkResult -is [array]) {
                        foreach ($line in $checkResult) {
                            if ($line -match '(\d+)') {
                                $exists = ($matches[1] -eq "1")
                                break
                            }
                        }
                    } else {
                        if ($checkResult -match '(\d+)') {
                            $exists = ($matches[1] -eq "1")
                        }
                    }
                }

                if ($exists) {
                    $foundTables += $table
                } else {
                    $missingTables += $table
                }
            }

            Write-Host "✅ Vytvořeno tabulek: $($foundTables.Count)" -ForegroundColor Green

            if ($missingTables.Count -gt 0) {
                Write-Host "⚠️  Chybějící tabulky: $($missingTables.Count)" -ForegroundColor Yellow
                Write-Host "   $($missingTables -join ', ')" -ForegroundColor Gray
            }
        }
    } catch {
        Write-Host "⚠️  Nepodařilo se načíst soubor pro kontrolu integrity: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Soubor se strukturou databáze nebyl nalezen, přeskočena kontrola integrity souboru" -ForegroundColor Yellow
}

Write-Host "📊 Souhrn struktury databáze" -ForegroundColor Cyan
Write-Host "   Celkový počet tabulek: $tableCount" -ForegroundColor Gray
if ($foundTables.Count -gt 0) {
    Write-Host "   Úspěšně vytvořeno: $($foundTables.Count) tabulek ze struktury" -ForegroundColor Gray
}
if ($missingTables.Count -gt 0) {
    Write-Host "   ⚠️  Chybí: $($missingTables.Count) tabulek" -ForegroundColor Yellow
}
Write-Host ""

# Zvláštní kontrola pro novou strukturu - ověření klíčových tabulek
Write-Host "ℹ️  Kontrola integrity nové struktury..." -ForegroundColor Cyan

# Pokud máme seznam nalezených tabulek, použijeme ho, jinak základní kontrolu
if ($foundTables.Count -eq 0) {
    # Záložní základní kontrola
    $requiredTables = @(
        "ServiceCatalogItem",
        "LU_ServiceCategory", 
        "LU_SizeOption",
        "LU_CloudProvider",
        "LU_DependencyType",
        "ServiceDependency",
        "ServiceScopeCategory",
        "ServiceScopeItem",
        "ServiceInput",
        "ServiceOutputCategory",
        "ServiceOutputItem"
    )

    $missingTables = @()
    foreach ($table in $requiredTables) {
        $checkQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$table' AND TABLE_CATALOG = '$DbName'"
        $checkResult = Invoke-SqlCommand -Query $checkQuery
        
        # OPRAVA: Správná kontrola existence tabulky
        $exists = $false
        if ($checkResult -ne $null) {
            if ($checkResult -is [array]) {
                foreach ($line in $checkResult) {
                    if ($line -match '(\d+)') {
                        $exists = ($matches[1] -eq "1")
                        break
                    }
                }
            } else {
                if ($checkResult -match '(\d+)') {
                    $exists = ($matches[1] -eq "1")
                }
            }
        }
        
        if ($exists) {
            $foundTables += $table
        } else {
            $missingTables += $table
        }
    }
}

$structureSuccess = ($missingTables.Count -eq 0 -and $tableCount -ge 40)

if ($structureSuccess) {
    Write-Host "✅ Všechny klíčové tabulky nové struktury byly úspěšně vytvořeny!" -ForegroundColor Green
} else {
    if ($missingTables.Count -gt 0) {
        Write-Host "⚠️  Chybějící tabulky: $($missingTables -join ', ')" -ForegroundColor Yellow
    } else {
        Write-Host "⚠️  Databáze obsahuje pouze $tableCount tabulek (očekáváno 40+)" -ForegroundColor Yellow
    }
    Write-Host "   To může znamenat, že struktura nebyla kompletně aplikována." -ForegroundColor Yellow
    Write-Host "   Doporučení:" -ForegroundColor Cyan
    Write-Host "   1. Zkontrolujte, zda soubor db_structure.sql obsahuje všechny tabulky" -ForegroundColor Cyan
    Write-Host "   2. Zkontrolujte logy SQL serveru pro případné chyby" -ForegroundColor Cyan
    Write-Host "   3. Zkuste aplikovat strukturu ručně pomocí SQL Management Studio" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Připojovací řetězec:" -ForegroundColor Cyan
Write-Host "Server=$SERVER;Database=$DbName;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True" -ForegroundColor White
Write-Host ""

# TRUE NO EF CORE - kontrola, že EF Core migrace nebyly použity
Write-Host "ℹ️  Kontrola EF Core migrací (TRUE NO EF CORE)..." -ForegroundColor Cyan
$efCheckQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '__EFMigrationsHistory' AND TABLE_CATALOG = '$DbName'"
$efCheckResult = Invoke-SqlCommand -Query $efCheckQuery

# OPRAVA: Správná kontrola existence EF Core tabulky
$efExists = $false
if ($efCheckResult -ne $null) {
    if ($efCheckResult -is [array]) {
        foreach ($line in $efCheckResult) {
            if ($line -match '(\d+)') {
                $efExists = ($matches[1] -eq "1")
                break
            }
        }
    } else {
        if ($efCheckCheckResult -match '(\d+)') {
            $efExists = ($matches[1] -eq "1")
        }
    }
}

if ($efExists) {
    Write-Host "⚠️  EF Core migrace byly detekovány!" -ForegroundColor Yellow
    Write-Host "   To je v rozporu s TRUE NO EF CORE režimem." -ForegroundColor Yellow
} else {
    Write-Host "✅ EF Core migrace nebyly použity (používá se SQL struktura)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Připojovací řetězec:" -ForegroundColor Cyan
Write-Host "Server=$SERVER;Database=$DbName;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True" -ForegroundColor White
Write-Host ""

if (-not $useSqlCmd) {
    Write-Host "💡 Tip: To connect from outside Docker, install SQL Server Command Line Utilities" -ForegroundColor Cyan
    Write-Host "   Download: https://aka.ms/sqlcmd" -ForegroundColor Cyan
}

if ($structureSuccess) {
    exit 0
}

exit 2