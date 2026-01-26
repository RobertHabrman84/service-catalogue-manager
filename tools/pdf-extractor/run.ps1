# PDF Extractor Runner Script (PowerShell)
# ==========================================

Write-Host "🚀 Service Catalog PDF Extractor" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check if Python is installed
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonCmd) {
    Write-Host "❌ Python is not installed" -ForegroundColor Red
    Write-Host "   Please install Python 3.8 or higher" -ForegroundColor Yellow
    exit 1
}

# Check if API key is set
if (-not $env:ANTHROPIC_API_KEY) {
    Write-Host "❌ ANTHROPIC_API_KEY is not set" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please set your API key:" -ForegroundColor Yellow
    Write-Host '  $env:ANTHROPIC_API_KEY="your-api-key-here"' -ForegroundColor White
    Write-Host ""
    Write-Host "Or create a .env file with:" -ForegroundColor Yellow
    Write-Host "  ANTHROPIC_API_KEY=your-api-key-here" -ForegroundColor White
    exit 1
}

# Check if dependencies are installed
Write-Host "📦 Checking dependencies..." -ForegroundColor Yellow
try {
    python -c "import anthropic" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Dependencies not installed"
    }
    Write-Host "✅ Dependencies OK" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Dependencies not installed" -ForegroundColor Yellow
    Write-Host "   Installing from requirements.txt..." -ForegroundColor Yellow
    pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

# Run the extractor
python extract_services.py

exit $LASTEXITCODE
