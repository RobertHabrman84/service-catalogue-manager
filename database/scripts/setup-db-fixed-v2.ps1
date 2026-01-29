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

$NoEFCoreMode = $NoEFCore.IsPresent -or ($PSBoundParameters.ContainsKey('NoEFCore') -and [bool]$NoEFCore)

$SA_PASSWORD = "YourStrong@Passw0rd"
$SERVER = "localhost,1433"
$SCHEMA_DIR = Join-Path $PSScriptRoot "..\schema"
# Optional: echo explicit NO EF mode for tracing
if ($NoEFCoreMode) { Write-Host "Mode: NO EF CORE (pure SQL)" -ForegroundColor Cyan }

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
        Write-Host "ℹ️  Executing SQL file locally with sqlcmd..." -ForegroundColor Cyan
        Write-Host "   File: $FilePath" -ForegroundColor Gray
        
        # FIX #4: Add GO batch separators for local execution too
        $tempFile = [System.IO.Path]::GetTempFileName()
        try {
            Write-Host "ℹ️  Preparing SQL script with GO separators..." -ForegroundColor Cyan
            $content = Get-Content $FilePath -Raw -Encoding UTF8
            
            # Count statements
            $createTableCount = ([regex]::Matches($content, "CREATE TABLE", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
            $createIndexCount = ([regex]::Matches($content, "CREATE INDEX", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
            Write-Host "   Found: $createTableCount CREATE TABLE, $createIndexCount CREATE INDEX statements" -ForegroundColor Gray
            
            # FIX #5: Add GO after the entire CLEANUP section (all DROP statements together)
            $content = $content -replace '(?sm)(-- CLEANUP.*?)(-- Lookup tables.*?LU_ServiceCategory.*?\;)[\r\n]+', "`$1`$2`nGO`n`n"
            
            # Add GO batch separators (excluding DROP statements)
            $content = $content -replace '(?m)^\);[\r\n]+(?=\s*(CREATE|INSERT|--|$))', ");\nGO\n"
            $content = $content -replace '(?im)(CREATE\s+INDEX\s+[^\;]+\;)[\r\n]+', "`$1`nGO`n`n"
            $content = $content -replace '(?im)(CREATE\s+OR\s+ALTER\s+(VIEW|PROCEDURE|FUNCTION)\s+[^\;]+\;)[\r\n]+', "`$1`nGO`n`n"
            $content = $content -replace '(?im)(INSERT\s+INTO\s+[^;]+\;)[\r\n]+(?!INSERT)', "`$1`nGO`n`n"
            $content = $content -replace '(?m)^GO[\r\n]+GO[\r\n]+', "GO`n"
            
            $goCount = ([regex]::Matches($content, "^GO", [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
            Write-Host "   Added: $goCount GO batch separators" -ForegroundColor Green
            
            # Write temp file
            $utf8Bom = New-Object System.Text.UTF8Encoding $true
            [System.IO.File]::WriteAllText($tempFile, $content, $utf8Bom)
            
            # Execute with sqlcmd
            if ($Database) {
                $result = sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -d $Database -i $tempFile -C 2>&1
            } else {
                $result = sqlcmd -S $SERVER -U sa -P $SA_PASSWORD -i $tempFile -C 2>&1
            }
            
            return $result
        } finally {
            if (Test-Path $tempFile) {
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            }
        }
    } else {
        # For Docker exec, we need to copy file into container first
        Write-Host "ℹ️  Preparing SQL file for Docker container..." -ForegroundColor Cyan
        Write-Host "   Source: $FilePath" -ForegroundColor Gray
        
        # FIX #1: Convert Windows CRLF to Unix LF line endings before copying to Docker
        # This is critical for sqlcmd in Linux container to parse the file correctly
        $tempFile = [System.IO.Path]::GetTempFileName()
        try {
            Write-Host "ℹ️  Preparing SQL script for execution..." -ForegroundColor Cyan
            $content = Get-Content $FilePath -Raw -Encoding UTF8
            
            # FIX #4: Add GO batch separators for proper SQL batch execution
            # Problem: db_structure.sql has all CREATE TABLE statements in one batch
            # Solution: Insert GO after each statement to ensure proper execution
            # FIX #5: Exclude IF OBJECT_ID DROP statements from GO insertion
            Write-Host "ℹ️  Adding GO batch separators..." -ForegroundColor Cyan
            
            # Count statements before processing
            $createTableCount = ([regex]::Matches($content, "CREATE TABLE", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
            $createIndexCount = ([regex]::Matches($content, "CREATE INDEX", [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)).Count
            Write-Host "   Found: $createTableCount CREATE TABLE, $createIndexCount CREATE INDEX statements" -ForegroundColor Gray
            
            # FIX #5: Add GO after the entire CLEANUP section (all DROP statements together)
            # Match the CLEANUP block and add GO at the end
            $content = $content -replace '(?sm)(-- CLEANUP.*?)(-- Lookup tables.*?LU_ServiceCategory.*?\;)[\r\n]+', "`$1`$2`nGO`n`n"
            
            # Add GO after CREATE TABLE statements (after closing );)
            # BUT: Make sure we're not in a DROP context
            # Pattern: ); at end of line, followed by blank lines or CREATE/INSERT (not DROP)
            $content = $content -replace '(?m)^\);[\r\n]+(?=\s*(CREATE|INSERT|--|$))', ");\nGO\n"
            
            # Add GO after CREATE INDEX statements
            # Pattern: CREATE INDEX ... ON table(column); followed by newline
            $content = $content -replace '(?im)(CREATE\s+INDEX\s+[^\;]+\;)[\r\n]+', "`$1`nGO`n`n"
            
            # Add GO after CREATE OR ALTER VIEW/PROCEDURE/FUNCTION statements
            $content = $content -replace '(?im)(CREATE\s+OR\s+ALTER\s+(VIEW|PROCEDURE|FUNCTION)\s+[^\;]+\;)[\r\n]+', "`$1`nGO`n`n"
            
            # Add GO after INSERT INTO statements (multi-line inserts)
            $content = $content -replace '(?im)(INSERT\s+INTO\s+[^;]+\;)[\r\n]+(?!INSERT)', "`$1`nGO`n`n"
            
            # Ensure GO statements are on their own line and remove duplicates
            $content = $content -replace '(?m)^GO[\r\n]+GO[\r\n]+', "GO`n"
            
            # Count GO statements after processing
            $goCount = ([regex]::Matches($content, "^GO", [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count
            Write-Host "   Added: $goCount GO batch separators" -ForegroundColor Green
            
            # Replace CRLF with LF for Linux container
            Write-Host "ℹ️  Converting line endings (CRLF → LF)..." -ForegroundColor Cyan
            $content = $content -replace "`r`n", "`n"
            # Also remove any trailing CR that might be left
            $content = $content -replace "`r", ""
            
            # Write with UTF8 encoding without BOM
            $utf8NoBom = New-Object System.Text.UTF8Encoding $false
            [System.IO.File]::WriteAllText($tempFile, $content, $utf8NoBom)
            Write-Host "✅ SQL script prepared successfully" -ForegroundColor Green
            
            Write-Host "ℹ️  Copying schema file to container..." -ForegroundColor Cyan
            $copyResult = docker cp $tempFile "${ContainerName}:/tmp/schema.sql" 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "❌ Failed to copy file to container!" -ForegroundColor Red
                Write-Host "   Error: $copyResult" -ForegroundColor Red
                return $copyResult
            }
            Write-Host "✅ File copied successfully" -ForegroundColor Green
            
            # FIX #2: Add verbose output and better error detection
            Write-Host "ℹ️  Executing SQL script in container..." -ForegroundColor Cyan
            Write-Host "   Database: $Database" -ForegroundColor Gray
            
            $sqlcmdOutput = $null
            if ($Database) {
                $sqlcmdOutput = docker exec $ContainerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -d $Database -i /tmp/schema.sql 2>&1
            } else {
                $sqlcmdOutput = docker exec $ContainerName /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P $SA_PASSWORD -i /tmp/schema.sql 2>&1
            }
            
            # FIX #3: Display detailed output for debugging
            if ($sqlcmdOutput) {
                Write-Host "📋 SQL Execution Output:" -ForegroundColor Cyan
                Write-Host "----------------------------------------" -ForegroundColor DarkGray
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
                Write-Host "----------------------------------------" -ForegroundColor DarkGray
            }
            
            return $sqlcmdOutput
            
        } finally {
            # Clean up temp file
            if (Test-Path $tempFile) {
                Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
            }
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

if (-not $NoEFCoreMode) {
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
        
        # FIX #3: Improved error detection with better categorization
        Write-Host ""
        Write-Host "🔍 Analýza výsledku SQL skriptu..." -ForegroundColor Cyan
        
        # Count different types of messages
        $errorCount = 0
        $warningCount = 0
        $successCount = 0
        
        if ($schemaResult) {
            # Check for SQL errors (Level 16+ are errors, Level 0-10 are informational)
            $errorMatches = $schemaResult | Select-String -Pattern "Msg \d+.*Level (1[6-9]|2[0-5])" -AllMatches
            $errorCount = if ($errorMatches) { $errorMatches.Matches.Count } else { 0 }
            
            # Check for warnings (Level 11-15)
            $warningMatches = $schemaResult | Select-String -Pattern "Msg \d+.*Level (1[1-5])" -AllMatches
            $warningCount = if ($warningMatches) { $warningMatches.Matches.Count } else { 0 }
            
            # Check for success indicators
            if ($schemaResult -like "*PRINT*" -or $schemaResult -like "*created successfully*") {
                $successCount++
            }
        }
        
        Write-Host "   Chyby (Level 16+): $errorCount" -ForegroundColor $(if ($errorCount -gt 0) { "Red" } else { "Green" })
        Write-Host "   Varování (Level 11-15): $warningCount" -ForegroundColor $(if ($warningCount -gt 0) { "Yellow" } else { "Green" })
        Write-Host "   Exit Code: $LASTEXITCODE" -ForegroundColor Gray
        
        # Determine overall success
        $hasErrors = $errorCount -gt 0
        $hasWarnings = $warningCount -gt 0
        $exitCodeOk = ($LASTEXITCODE -eq 0) -or ($null -eq $LASTEXITCODE)
        
        if ($hasErrors) {
            Write-Host ""
            Write-Host "❌ SQL skript obsahuje CHYBY!" -ForegroundColor Red
            Write-Host "   Databáze nemusí být kompletní." -ForegroundColor Yellow
            
            # Show first few errors for debugging
            $errorLines = $schemaResult | Select-String -Pattern "Msg \d+.*Level (1[6-9]|2[0-5])" -Context 0,2
            if ($errorLines) {
                Write-Host ""
                Write-Host "📋 První chyby:" -ForegroundColor Red
                $errorLines | Select-Object -First 3 | ForEach-Object {
                    Write-Host "   $($_.Line)" -ForegroundColor Red
                }
            }
        } elseif ($hasWarnings) {
            Write-Host ""
            Write-Host "⚠️  SQL skript obsahuje varování" -ForegroundColor Yellow
            Write-Host "   To může být v pořádku (např. drop neexistujících objektů)" -ForegroundColor Cyan
            
            if ($exitCodeOk) {
                Write-Host "✅ Exit code je OK, pokračuji..." -ForegroundColor Green
            }
        } elseif ($exitCodeOk -and $successCount -gt 0) {
            Write-Host ""
            Write-Host "✅ Kompletní struktura databáze byla úspěšně aplikována" -ForegroundColor Green
        } elseif ($exitCodeOk) {
            Write-Host ""
            Write-Host "✅ SQL skript dokončen bez chyb" -ForegroundColor Green
        } else {
            Write-Host ""
            Write-Host "⚠️  Neočekávaný výsledek při aplikaci struktury" -ForegroundColor Yellow
            Write-Host "   Exit Code: $LASTEXITCODE" -ForegroundColor Gray
        }
        
    } catch {
        Write-Host ""
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
    $tableCount = 0
    $tableCountLines = @()
    if ($null -ne $tableCountResult) {
        if ($tableCountResult -is [array]) {
            $tableCountLines = $tableCountResult
        } else {
            $tableCountLines = @($tableCountResult)
        }
    }
    $numericLine = $tableCountLines |
        ForEach-Object { $_.ToString().Trim() } |
        Where-Object { $_ -match '^\d+$' } |
        Select-Object -First 1
    if (-not [int]::TryParse($numericLine, [ref]$tableCount)) {
        $joined = ($tableCountLines | ForEach-Object { $_.ToString() }) -join ' '
        $match = [regex]::Match($joined, '\d+')
        if ($match.Success) {
            [void][int]::TryParse($match.Value, [ref]$tableCount)
        }
    }
} catch {
    $tableCount = 0
}

# Specifická kontrola hlavních tabulek nové struktury
Write-Host "ℹ️  Kontrola integrity nové struktury..." -ForegroundColor Cyan

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
                $exists = ($checkResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)

                if ($exists -eq '1') {
                    $foundTables += $table
                } else {
                    $missingTables += $table
                }
            }

            Write-Host "✅ Vytvořeno tabulek: $($foundTables.Count)" -ForegroundColor Green

            if ($missingTables.Count -gt 0) {
                Write-Host "⚠️  Chybějící tabulky: $($missingTables.Count)" -ForegroundColor Yellow
                Write-Host "   $($missingTables -join ', ')" -ForegroundColor Gray
                Write-Host "ℹ️  Kontrola detailů pro chybějící tabulky..." -ForegroundColor Cyan
                foreach ($table in $missingTables) {
                    Write-Host "   - $table" -ForegroundColor Gray
                }
            }
        }
    } catch {
        Write-Host "⚠️  Nepodařilo se načíst soubor pro kontrolu integrity: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  Soubor se strukturou databáze nebyl nalezen, přeskočena kontrola integrity souboru" -ForegroundColor Yellow
}

# Základní kontrola pomocí INFORMATION_SCHEMA
$countQuery = "SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_CATALOG = '$DbName'"
$tableCountResult = Invoke-SqlCommand -Query $countQuery

# Lepší extrakce čísla z výsledku
try {
    $tableCount = 0
    $tableCountLines = @()
    if ($null -ne $tableCountResult) {
        if ($tableCountResult -is [array]) {
            $tableCountLines = $tableCountResult
        } else {
            $tableCountLines = @($tableCountResult)
        }
    }
    $numericLine = $tableCountLines |
        ForEach-Object { $_.ToString().Trim() } |
        Where-Object { $_ -match '^\d+$' } |
        Select-Object -First 1
    if (-not [int]::TryParse($numericLine, [ref]$tableCount)) {
        $joined = ($tableCountLines | ForEach-Object { $_.ToString() }) -join ' '
        $match = [regex]::Match($joined, '\d+')
        if ($match.Success) {
            [void][int]::TryParse($match.Value, [ref]$tableCount)
        }
    }
} catch {
    $tableCount = 0
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
        $exists = ($checkResult | Select-String -Pattern "\d+" | ForEach-Object { $_.Matches.Value } | Select-Object -First 1)
        
        if ($exists -ne "1") {
            $missingTables += $table
        }
    }
}

$structureSuccess = ($missingTables.Count -eq 0 -and $tableCount -ge 40)

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
if ($structureSuccess) {
    Write-Host "✅ DATABASE SETUP SUCCESSFUL!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "✅ Všechny klíčové tabulky nové struktury byly úspěšně vytvořeny!" -ForegroundColor Green
    Write-Host "   Celkový počet tabulek: $tableCount" -ForegroundColor Green
    Write-Host "   Vytvořeno z db_structure.sql: $($foundTables.Count) tabulek" -ForegroundColor Green
} else {
    Write-Host "⚠️  DATABASE SETUP INCOMPLETE!" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
    if ($missingTables.Count -gt 0) {
        Write-Host "⚠️  Chybějící tabulky ($($missingTables.Count)):" -ForegroundColor Yellow
        Write-Host "   $($missingTables -join ', ')" -ForegroundColor Gray
    } else {
        Write-Host "⚠️  Databáze obsahuje pouze $tableCount tabulek (očekáváno 42)" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "   To znamená, že SQL struktura nebyla kompletně aplikována." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   📋 Doporučené kroky pro diagnostiku:" -ForegroundColor Cyan
    Write-Host "   1. Zkontrolujte výše uvedený SQL Output pro chyby" -ForegroundColor White
    Write-Host "   2. Ověřte formát souboru db_structure.sql" -ForegroundColor White
    Write-Host "   3. Zkuste spustit setup s -Force parametrem znovu" -ForegroundColor White
    Write-Host "   4. Zkontrolujte Docker logs: docker logs $ContainerName" -ForegroundColor White
    Write-Host ""
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
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 CONNECTION INFORMATION" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server: $SERVER" -ForegroundColor White
Write-Host "Database: $DbName" -ForegroundColor White
Write-Host "User: sa" -ForegroundColor White
Write-Host ""
Write-Host "Connection String:" -ForegroundColor Cyan
Write-Host "Server=$SERVER;Database=$DbName;User Id=sa;Password=$SA_PASSWORD;TrustServerCertificate=True" -ForegroundColor White
Write-Host ""

if (-not $useSqlCmd) {
    Write-Host "💡 Tip: To connect from outside Docker, install SQL Server Command Line Utilities" -ForegroundColor Cyan
    Write-Host "   Download: https://aka.ms/sqlcmd" -ForegroundColor Cyan
    Write-Host ""
}

# Final exit code based on success
if ($structureSuccess) {
    Write-Host "✅ Setup completed successfully!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Setup completed with errors - database may be incomplete!" -ForegroundColor Red
    Write-Host "   Please review the output above and fix any issues." -ForegroundColor Yellow
    exit 1
}
