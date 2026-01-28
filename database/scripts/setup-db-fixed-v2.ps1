#!/usr/bin/env pwsh
# ============================================================================
# Service Catalogue Manager - Database Setup (FIXED V2)
# ============================================================================
# Opravená verze kompatibilní s start-all-fixed.ps1
# ============================================================================

param(
    [switch]$Force = $false,
    [string]$DbName = "ServiceCatalogueManager",
    [string]$ContainerName = "scm-sqlserver",
    [switch]$NoEFCore = $false
)

$ErrorActionPreference = "Stop"

$SA_PASSWORD = "YourStrong@Passw0rd"
$SERVER = "localhost,1433"
$SCHEMA_DIR = Join-Path $PSScriptRoot "..\schema"
# Optional: echo explicit NO EF mode for tracing
if ($NoEFCore) { Write-Host "Mode: NO EF CORE (pure SQL)" -ForegroundColor Cyan }

Write-Host "🗄️  Service Catalogue Database Setup (FIXED V2)" -ForegroundColor Cyan
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
$dbExists = ($dbExistsResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)

if ($dbExists -eq "1") {
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

if (-not $NoEFCore) {
    # Try EF Core migrations first (preferred method)
    Write-Host "ℹ️  Attempting EF Core migrations..." -ForegroundColor Cyan
    $backendDir = Join-Path $PSScriptRoot "..\..\src\backend\ServiceCatalogueManager.Api"
    try {
        Push-Location $backendDir
        
        # Check if EF Core tools are available
        $efAvailable = $null -ne (Get-Command "dotnet-ef" -ErrorAction SilentlyContinue)
        if (-not $efAvailable) {
            Write-Host "ℹ️  Installing EF Core tools..." -ForegroundColor Cyan
            dotnet tool install --global dotnet-ef --version 8.* 2>$null | Out-Null
        }
        
        # Zkontrolovat, zda projekt existuje
        $projectFile = Join-Path $backendDir "ServiceCatalogueManager.Api.csproj"
        if (-not (Test-Path $projectFile)) {
            Write-Host "⚠️  EF Core project not found at $projectFile" -ForegroundColor Yellow
            Write-Host "Falling back to SQL scripts..." -ForegroundColor Yellow
            throw "EF Core project not found"
        }
        
        # Set environment variable for EF Core to find the connection string
        $connectionString = "Server=$SERVER;Database=$DbName;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True"
        $env:AzureSQL__ConnectionString = $connectionString
        $env:ConnectionStrings__AzureSQL = $connectionString
        $env:ConnectionStrings__DefaultConnection = $connectionString
        
        Write-Host "ℹ️  Applying EF Core migrations..." -ForegroundColor Cyan
        Write-Host "Connection String: $connectionString" -ForegroundColor Gray
        
        # Try to run EF Core migrations with explicit project specification
        Write-Host "ℹ️  Running: dotnet ef database update --connection \"$env:AzureSQL__ConnectionString\"" -ForegroundColor Gray
        $migrationResult = dotnet ef database update --connection "$env:AzureSQL__ConnectionString" 2>&1
        Write-Host "EF Core output: $migrationResult" -ForegroundColor Gray
        
        # Kontrola na chybu s '*' (wildcard expansion error)
        if ($migrationResult -like "*'*' is not recognized*" -or $migrationResult -like "*wildcard*") {
            Write-Host "⚠️  EF Core migrace selhala kvůli syntaktické chybě, zkouším alternativní přístup..." -ForegroundColor Yellow
            
            # Alternativní přístup - použití příkazu bez problémových parametrů
            $env:DOTNET_ENVIRONMENT = "Docker"
            $migrationResult = dotnet ef database update 2>&1
            Write-Host "Alternative EF Core output: $migrationResult" -ForegroundColor Gray
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ EF Core migrations applied successfully" -ForegroundColor Green
            
            # Ověření EF Core migrací
            Write-Host "ℹ️  Verifying EF Core migration tables..." -ForegroundColor Cyan
            
            # Zkontrolovat, zda existuje tabulka migrací
            $efTableExistsQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '__EFMigrationsHistory' AND TABLE_CATALOG = '$DbName'"
            $efTableExistsResult = Invoke-SqlCommand -Query $efTableExistsQuery
            $efTableExists = ($efTableExistsResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
            
            if ($efTableExists -eq "1") {
                $efCountQuery = "SELECT COUNT(*) FROM [$DbName].[__EFMigrationsHistory]"
                $efCountResult = Invoke-SqlCommand -Query $efCountQuery
                $efMigrationCount = ($efCountResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
                Write-Host "✅ EF Core migrations table exists with $efMigrationCount migrations" -ForegroundColor Green
            } else {
                Write-Host "⚠️  EF Core migrations table not found" -ForegroundColor Yellow
            }
            
            # Verify tables
            Write-Host "ℹ️  Verifying tables..." -ForegroundColor Cyan
            $countQuery = "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '$DbName'"
            $tableCountResult = Invoke-SqlCommand -Query $countQuery
            $tableCount = ($tableCountResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
            
            Write-Host "✅ Database setup complete!" -ForegroundColor Green
            Write-Host "   Tables created: $tableCount" -ForegroundColor Green
            Write-Host ""
            Write-Host "Connection String:" -ForegroundColor Cyan
            Write-Host "Server=$SERVER;Database=$DbName;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True" -ForegroundColor White
            Write-Host ""
            exit 0
        } else {
            Write-Host "⚠️  EF Core migrations failed, falling back to SQL script..." -ForegroundColor Yellow
            Write-Host "EF Core error: $migrationResult" -ForegroundColor Red
        }
    } catch {
        Write-Host "⚠️  EF Core migrations failed: $_" -ForegroundColor Yellow
        Write-Host "Falling back to SQL script..." -ForegroundColor Yellow
    } finally {
        Pop-Location
    }
} else {
    Write-Host "ℹ️  NO EF CORE mode: skipping EF Core migrations, using pure SQL scripts" -ForegroundColor Cyan
}

# Fallback to SQL scripts - nová struktura z db_structure.sql
Write-Host "📝 Implementuji novou SQL strukturu databáze..." -ForegroundColor Cyan

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
    Write-Host "⚠️  Hlavní struktura db_structure.sql nebyla nalezena, používám záložní skripty..." -ForegroundColor Yellow
    
    # Záložní starší skripty (pouze když není db_structure.sql)
    $schemaFiles = @(
        "001_initial_schema.sql",
        "002_lookup_tables.sql", 
        "003_lookup_data.sql"
    )
    
    foreach ($schemaFile in $schemaFiles) {
        $fullSchemaPath = Join-Path $SCHEMA_DIR $schemaFile
        
        if (Test-Path $fullSchemaPath) {
            Write-Host "ℹ️  Aplikuji $schemaFile..." -ForegroundColor Cyan
            
            $schemaResult = Invoke-SqlFile -FilePath $fullSchemaPath -Database $DbName
            
            if ($LASTEXITCODE -ne 0) {
                Write-Host "⚠️  Skript $schemaFile měl varování (může být v pořádku)" -ForegroundColor Yellow
            } else {
                Write-Host "✅ $schemaFile úspěšně aplikován" -ForegroundColor Green
            }
        } else {
            Write-Host "⚠️  Skript nebyl nalezen: $fullSchemaPath" -ForegroundColor Yellow
        }
    }
}

# Ověření tabulek - specifické pro novou strukturu
Write-Host "ℹ️  Ověřuji novou strukturu databáze..." -ForegroundColor Cyan

# Hlavní kontrola všech tabulek
$countQuery = "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '$DbName'"
$tableCountResult = Invoke-SqlCommand -Query $countQuery

# Lepší extrakce čísla z výsledku
try {
    if ($tableCountResult -match '(\d+)') {
        $tableCount = $matches[1]
    } else {
        $tableCount = 0
    }
} catch {
    $tableCount = 0
}

# Specifická kontrola hlavních tabulek nové struktury
Write-Host "ℹ️  Kontrola integrity nové struktury..." -ForegroundColor Cyan

# Načtení a kontrola všech tabulek ze souboru
try {
    $dbStructureContent = Get-Content -Path $mainSchemaFile -Raw -ErrorAction SilentlyContinue
    if ($dbStructureContent) {
        # Extrakce názvů tabulek ze souboru
        $tableMatches = [regex]::Matches($dbStructureContent, "CREATE TABLE \\[(\w+)\\]\")
        $expectedTables = $tableMatches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
        
        Write-Host "ℹ️  V souboru nalezeno $($expectedTables.Count) tabulek:" -ForegroundColor Cyan
        Write-Host "   $($expectedTables -join ', ')" -ForegroundColor Gray
        
        # Kontrola každé tabulky
        $foundTables = @()
        $missingTables = @()
        
        foreach ($table in $expectedTables) {
            $checkQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '$table' AND TABLE_CATALOG = '$DbName'"
            $checkResult = Invoke-SqlCommand -Query $checkQuery
            $exists = ($checkResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
            
            if ($exists -eq "1") {
                $foundTables += $table
            } else {
                $missingTables += $table
            }
        }
        
        Write-Host "✅ Vytvořeno tabulek: $($foundTables.Count)" -ForegroundColor Green
        
        if ($missingTables.Count -gt 0) {
            Write-Host "⚠️  Chybějící tabulky: $($missingTables.Count)" -ForegroundColor Yellow
            Write-Host "   $($missingTables -join ', ')" -ForegroundColor Gray
            
            # Detailní kontrola chybějících tabulek
            Write-Host "ℹ️  Kontrola detailů pro chybějící tabulky..." -ForegroundColor Cyan
            foreach ($table in $missingTables) {
                Write-Host "   - $table" -ForegroundColor Gray
            }
        }
    }
} catch {
    Write-Host "⚠️  Nepodařilo se načíst soubor pro kontrolu integrity: $_" -ForegroundColor Yellow
}

# Základní kontrola pomocí INFORMATION_SCHEMA
$countQuery = "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '$DbName'"
$tableCountResult = Invoke-SqlCommand -Query $countQuery

# Lepší extrakce čísla z výsledku
try {
    if ($tableCountResult -match '(\d+)') {
        $tableCount = $matches[1]
    } else {
        $tableCount = 0
    }
} catch {
    $tableCount = 0
}

Write-Host "✅ Databáze úspěšně nastavena!" -ForegroundColor Green
Write-Host "   Celkový počet tabulek: $tableCount" -ForegroundColor Green
if ($foundTables.Count -gt 0) {
    Write-Host "   Úspěšně vytvořeno: $($foundTables.Count) tabulek ze struktury" -ForegroundColor Green
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
        $exists = ($checkResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
        
        if ($exists -ne "1") {
            $missingTables += $table
        }
    }
}

if ($missingTables.Count -eq 0) {
    Write-Host "✅ Všechny klíčové tabulky nové struktury byly úspěšně vytvořeny!" -ForegroundColor Green
} else {
    Write-Host "⚠️  Chybějící tabulky: $($missingTables -join ', ')" -ForegroundColor Yellow
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

# Dodatečná kontrola EF Core migrací
Write-Host "ℹ️  Kontrola EF Core migrací..." -ForegroundColor Cyan
$efCheckQuery = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '__EFMigrationsHistory' AND TABLE_CATALOG = '$DbName'"
$efCheckResult = Invoke-SqlCommand -Query $efCheckQuery
$efExists = ($efCheckResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)

if ($efExists -eq "1") {
    $efCountQuery = "SELECT COUNT(*) FROM [$DbName].[__EFMigrationsHistory]"
    $efCountResult = Invoke-SqlCommand -Query $efCountQuery
    $efMigrationCount = ($efCountResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
    Write-Host "✅ EF Core migrace: $efMigrationCount aplikováno" -ForegroundColor Green
} else {
    Write-Host "ℹ️  EF Core migrace nebyly použity (používá se SQL struktura)" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Připojovací řetězec:" -ForegroundColor Cyan
Write-Host "Server=$SERVER;Database=$DbName;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True" -ForegroundColor White
Write-Host ""

if (-not $useSqlCmd) {
    Write-Host "💡 Tip: To connect from outside Docker, install SQL Server Command Line Utilities" -ForegroundColor Cyan
    Write-Host "   Download: https://aka.ms/sqlcmd" -ForegroundColor Cyan
}