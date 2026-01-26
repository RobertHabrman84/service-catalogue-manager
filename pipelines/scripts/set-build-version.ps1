<#
.SYNOPSIS
    Sets the build version based on Git tags and branch information.

.DESCRIPTION
    This script calculates the build version using semantic versioning principles:
    - For tagged commits: uses the tag as version
    - For main/master: major.minor.patch-build
    - For develop: major.minor.patch-beta.build
    - For feature branches: major.minor.patch-alpha.build

.PARAMETER SourceBranch
    The source branch name (e.g., refs/heads/main)

.PARAMETER BuildId
    The Azure DevOps build ID

.PARAMETER DefaultVersion
    Default version if no tags found (default: 1.0.0)

.EXAMPLE
    .\set-build-version.ps1 -SourceBranch "refs/heads/main" -BuildId "12345"
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$SourceBranch = $env:BUILD_SOURCEBRANCH,
    
    [Parameter(Mandatory = $false)]
    [string]$BuildId = $env:BUILD_BUILDID,
    
    [Parameter(Mandatory = $false)]
    [string]$DefaultVersion = "1.0.0"
)

$ErrorActionPreference = "Stop"

Write-Host "=== Build Version Calculator ===" -ForegroundColor Cyan
Write-Host "Source Branch: $SourceBranch"
Write-Host "Build ID: $BuildId"

# Extract branch name
$branchName = $SourceBranch -replace "refs/heads/", ""
Write-Host "Branch Name: $branchName"

# Try to get the latest Git tag
try {
    $latestTag = git describe --tags --abbrev=0 2>$null
    if ($latestTag) {
        $baseVersion = $latestTag -replace "^v", ""
        Write-Host "Latest Tag: $latestTag"
    }
    else {
        $baseVersion = $DefaultVersion
        Write-Host "No tags found, using default: $baseVersion"
    }
}
catch {
    $baseVersion = $DefaultVersion
    Write-Host "Error getting tags, using default: $baseVersion"
}

# Parse semantic version
$versionParts = $baseVersion -split "\."
$major = [int]($versionParts[0] -replace "[^0-9]", "")
$minor = if ($versionParts.Length -gt 1) { [int]($versionParts[1] -replace "[^0-9]", "") } else { 0 }
$patch = if ($versionParts.Length -gt 2) { [int]($versionParts[2] -replace "[^0-9]", "") } else { 0 }

Write-Host "Base Version: $major.$minor.$patch"

# Calculate version based on branch
switch -Regex ($branchName) {
    "^(main|master)$" {
        $version = "$major.$minor.$patch"
        $informationalVersion = "$version+build.$BuildId"
        $prerelease = ""
    }
    "^develop$" {
        $version = "$major.$minor.$patch"
        $informationalVersion = "$version-beta.$BuildId"
        $prerelease = "beta"
    }
    "^release/" {
        $releaseVersion = $branchName -replace "release/", ""
        $version = $releaseVersion
        $informationalVersion = "$version-rc.$BuildId"
        $prerelease = "rc"
    }
    "^hotfix/" {
        $version = "$major.$minor.$($patch + 1)"
        $informationalVersion = "$version-hotfix.$BuildId"
        $prerelease = "hotfix"
    }
    "^feature/" {
        $version = "$major.$minor.$patch"
        $featureName = ($branchName -replace "feature/", "") -replace "[^a-zA-Z0-9]", ""
        $featureName = $featureName.Substring(0, [Math]::Min(10, $featureName.Length))
        $informationalVersion = "$version-alpha.$featureName.$BuildId"
        $prerelease = "alpha"
    }
    default {
        $version = "$major.$minor.$patch"
        $informationalVersion = "$version-dev.$BuildId"
        $prerelease = "dev"
    }
}

# Get Git commit info
try {
    $commitHash = git rev-parse --short HEAD 2>$null
    $commitCount = git rev-list --count HEAD 2>$null
}
catch {
    $commitHash = "unknown"
    $commitCount = "0"
}

# Build number for Azure DevOps
$buildNumber = "$version.$BuildId"

Write-Host ""
Write-Host "=== Version Information ===" -ForegroundColor Green
Write-Host "Version:              $version"
Write-Host "Informational:        $informationalVersion"
Write-Host "Build Number:         $buildNumber"
Write-Host "Prerelease:           $prerelease"
Write-Host "Commit:               $commitHash"
Write-Host "Commit Count:         $commitCount"
Write-Host "==========================="

# Set Azure DevOps variables
Write-Host "##vso[task.setvariable variable=Version]$version"
Write-Host "##vso[task.setvariable variable=InformationalVersion]$informationalVersion"
Write-Host "##vso[task.setvariable variable=Prerelease]$prerelease"
Write-Host "##vso[task.setvariable variable=CommitHash]$commitHash"
Write-Host "##vso[task.setvariable variable=CommitCount]$commitCount"

# Update build number
Write-Host "##vso[build.updatebuildnumber]$buildNumber"

# Output for use in subsequent steps
Write-Host "##vso[task.setvariable variable=Version;isOutput=true]$version"
Write-Host "##vso[task.setvariable variable=InformationalVersion;isOutput=true]$informationalVersion"

Write-Host ""
Write-Host "Build version set successfully!" -ForegroundColor Green
