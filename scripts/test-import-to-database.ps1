#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Test script to verify JSON import data is actually saved to MSSQL database
.DESCRIPTION
    This script:
    1. Checks if database is accessible
    2. Imports a test service from JSON
    3. Verifies the data was saved in the database
    4. Provides detailed report
.EXAMPLE
    ./scripts/test-import-to-database.ps1
#>

param(
    [string]$Environment = "Development",
    [string]$JsonFile = "examples/MINIMAL-VALID-EXAMPLE.json",
    [string]$ApiUrl = "http://localhost:7071/api",
    [string]$ConnectionString = "Server=localhost;Database=ServiceCatalogueManager;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;"
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "JSON Import to MSSQL Database Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check SQL Server connection
function Test-SqlConnection {
    param([string]$ConnectionString)
    
    Write-Host "[1/5] Testing SQL Server connection..." -ForegroundColor Yellow
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
        $connection.Open()
        
        $command = $connection.CreateCommand()
        $command.CommandText = "SELECT @@VERSION"
        $version = $command.ExecuteScalar()
        
        $connection.Close()
        
        Write-Host "✓ SQL Server connected successfully" -ForegroundColor Green
        Write-Host "  Version: $($version.Split("`n")[0])" -ForegroundColor Gray
        return $true
    }
    catch {
        Write-Host "✗ Failed to connect to SQL Server" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to count services in database
function Get-ServiceCount {
    param([string]$ConnectionString)
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
        $connection.Open()
        
        $command = $connection.CreateCommand()
        $command.CommandText = "SELECT COUNT(*) FROM ServiceCatalogItem"
        $count = $command.ExecuteScalar()
        
        $connection.Close()
        
        return $count
    }
    catch {
        Write-Host "  Warning: Could not count services: $($_.Exception.Message)" -ForegroundColor Yellow
        return -1
    }
}

# Function to check if service exists in database
function Test-ServiceInDatabase {
    param(
        [string]$ConnectionString,
        [string]$ServiceCode
    )
    
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
        $connection.Open()
        
        $command = $connection.CreateCommand()
        $command.CommandText = @"
SELECT 
    s.ServiceId,
    s.ServiceCode,
    s.ServiceName,
    s.Version,
    s.Description,
    s.CreatedDate,
    (SELECT COUNT(*) FROM UsageScenario WHERE ServiceId = s.ServiceId) as UsageScenariosCount,
    (SELECT COUNT(*) FROM ServiceInput WHERE ServiceId = s.ServiceId) as InputsCount,
    (SELECT COUNT(*) FROM ServiceOutputCategory WHERE ServiceId = s.ServiceId) as OutputCategoriesCount,
    (SELECT COUNT(*) FROM ServicePrerequisite WHERE ServiceId = s.ServiceId) as PrerequisitesCount,
    (SELECT COUNT(*) FROM ServiceDependency WHERE ServiceId = s.ServiceId) as DependenciesCount,
    (SELECT COUNT(*) FROM ServiceScopeCategory WHERE ServiceId = s.ServiceId) as ScopeCategoriesCount
FROM ServiceCatalogItem s
WHERE s.ServiceCode = @ServiceCode
"@
        
        $command.Parameters.AddWithValue("@ServiceCode", $ServiceCode) | Out-Null
        
        $reader = $command.ExecuteReader()
        
        if ($reader.Read()) {
            $result = @{
                ServiceId = $reader["ServiceId"]
                ServiceCode = $reader["ServiceCode"]
                ServiceName = $reader["ServiceName"]
                Version = $reader["Version"]
                Description = $reader["Description"].ToString().Substring(0, [Math]::Min(100, $reader["Description"].ToString().Length))
                CreatedDate = $reader["CreatedDate"]
                UsageScenariosCount = $reader["UsageScenariosCount"]
                InputsCount = $reader["InputsCount"]
                OutputCategoriesCount = $reader["OutputCategoriesCount"]
                PrerequisitesCount = $reader["PrerequisitesCount"]
                DependenciesCount = $reader["DependenciesCount"]
                ScopeCategoriesCount = $reader["ScopeCategoriesCount"]
            }
            
            $reader.Close()
            $connection.Close()
            
            return $result
        }
        
        $reader.Close()
        $connection.Close()
        
        return $null
    }
    catch {
        Write-Host "  Error checking database: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Function to import JSON via API
function Invoke-ServiceImport {
    param(
        [string]$ApiUrl,
        [string]$JsonFile
    )
    
    Write-Host "[3/5] Importing service from JSON..." -ForegroundColor Yellow
    
    if (-not (Test-Path $JsonFile)) {
        Write-Host "✗ JSON file not found: $JsonFile" -ForegroundColor Red
        return $null
    }
    
    Write-Host "  Reading JSON file: $JsonFile" -ForegroundColor Gray
    $jsonContent = Get-Content $JsonFile -Raw
    $jsonObject = $jsonContent | ConvertFrom-Json
    
    Write-Host "  Service Code: $($jsonObject.serviceCode)" -ForegroundColor Gray
    Write-Host "  Service Name: $($jsonObject.serviceName)" -ForegroundColor Gray
    
    try {
        $importUrl = "$ApiUrl/services/import"
        Write-Host "  Posting to: $importUrl" -ForegroundColor Gray
        
        $response = Invoke-RestMethod -Uri $importUrl -Method Post -Body $jsonContent -ContentType "application/json"
        
        Write-Host "✓ Import successful!" -ForegroundColor Green
        Write-Host "  Service ID: $($response.serviceId)" -ForegroundColor Gray
        
        return $response
    }
    catch {
        Write-Host "✗ Import failed" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $responseBody = $reader.ReadToEnd()
            Write-Host "  Response: $responseBody" -ForegroundColor Red
        }
        
        return $null
    }
}

# Main execution
try {
    # Step 1: Test SQL connection
    if (-not (Test-SqlConnection -ConnectionString $ConnectionString)) {
        Write-Host ""
        Write-Host "❌ Cannot proceed without database connection" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    
    # Step 2: Get initial service count
    Write-Host "[2/5] Checking current database state..." -ForegroundColor Yellow
    $initialCount = Get-ServiceCount -ConnectionString $ConnectionString
    if ($initialCount -ge 0) {
        Write-Host "✓ Current services in database: $initialCount" -ForegroundColor Green
    }
    
    Write-Host ""
    
    # Read service code from JSON
    $jsonContent = Get-Content $JsonFile -Raw
    $jsonObject = $jsonContent | ConvertFrom-Json
    $testServiceCode = $jsonObject.serviceCode
    
    # Check if service already exists
    $existingService = Test-ServiceInDatabase -ConnectionString $ConnectionString -ServiceCode $testServiceCode
    if ($existingService) {
        Write-Host "  ⚠ Service '$testServiceCode' already exists in database" -ForegroundColor Yellow
        Write-Host "  Would you like to delete it first? (Y/N): " -NoNewline -ForegroundColor Yellow
        $answer = Read-Host
        
        if ($answer -eq "Y" -or $answer -eq "y") {
            Write-Host "  Deleting existing service..." -ForegroundColor Gray
            
            $connection = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
            $connection.Open()
            
            $command = $connection.CreateCommand()
            $command.CommandText = "DELETE FROM ServiceCatalogItem WHERE ServiceCode = @ServiceCode"
            $command.Parameters.AddWithValue("@ServiceCode", $testServiceCode) | Out-Null
            $command.ExecuteNonQuery() | Out-Null
            
            $connection.Close()
            
            Write-Host "  ✓ Service deleted" -ForegroundColor Green
        }
        else {
            Write-Host ""
            Write-Host "❌ Test cancelled - service already exists" -ForegroundColor Red
            exit 1
        }
    }
    
    Write-Host ""
    
    # Step 3: Import service
    $importResult = Invoke-ServiceImport -ApiUrl $ApiUrl -JsonFile $JsonFile
    
    if (-not $importResult) {
        Write-Host ""
        Write-Host "❌ Import failed - cannot verify database" -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    
    # Step 4: Wait a moment for transaction to complete
    Write-Host "[4/5] Waiting for transaction to complete..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    Write-Host "✓ Ready to verify" -ForegroundColor Green
    
    Write-Host ""
    
    # Step 5: Verify in database
    Write-Host "[5/5] Verifying data in database..." -ForegroundColor Yellow
    
    $serviceInDb = Test-ServiceInDatabase -ConnectionString $ConnectionString -ServiceCode $testServiceCode
    
    if ($serviceInDb) {
        Write-Host "✓ Service found in database!" -ForegroundColor Green
        Write-Host ""
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "  Database Verification Details" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "  Service ID:         $($serviceInDb.ServiceId)" -ForegroundColor White
        Write-Host "  Service Code:       $($serviceInDb.ServiceCode)" -ForegroundColor White
        Write-Host "  Service Name:       $($serviceInDb.ServiceName)" -ForegroundColor White
        Write-Host "  Version:            $($serviceInDb.Version)" -ForegroundColor White
        Write-Host "  Created Date:       $($serviceInDb.CreatedDate)" -ForegroundColor White
        Write-Host "  Description:        $($serviceInDb.Description)..." -ForegroundColor Gray
        Write-Host ""
        Write-Host "  Related Data:" -ForegroundColor Cyan
        Write-Host "    - Usage Scenarios:  $($serviceInDb.UsageScenariosCount)" -ForegroundColor White
        Write-Host "    - Inputs:           $($serviceInDb.InputsCount)" -ForegroundColor White
        Write-Host "    - Output Categories: $($serviceInDb.OutputCategoriesCount)" -ForegroundColor White
        Write-Host "    - Prerequisites:    $($serviceInDb.PrerequisitesCount)" -ForegroundColor White
        Write-Host "    - Dependencies:     $($serviceInDb.DependenciesCount)" -ForegroundColor White
        Write-Host "    - Scope Categories: $($serviceInDb.ScopeCategoriesCount)" -ForegroundColor White
        Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
        
        Write-Host ""
        Write-Host "✅ SUCCESS: Data from JSON was successfully saved to MSSQL database!" -ForegroundColor Green
        Write-Host ""
        
        # Final count
        $finalCount = Get-ServiceCount -ConnectionString $ConnectionString
        if ($finalCount -ge 0) {
            Write-Host "  Total services now in database: $finalCount" -ForegroundColor Gray
            if ($initialCount -ge 0) {
                Write-Host "  New services added: $($finalCount - $initialCount)" -ForegroundColor Gray
            }
        }
        
        exit 0
    }
    else {
        Write-Host "✗ Service NOT found in database!" -ForegroundColor Red
        Write-Host ""
        Write-Host "❌ FAILED: Data was not saved to database" -ForegroundColor Red
        Write-Host "  This indicates an issue with the import or database save process" -ForegroundColor Yellow
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "❌ Test failed with exception" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
    exit 1
}
