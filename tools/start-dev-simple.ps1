# Jekyll Blog Startup Script
# Simple version without special characters

param(
    [switch]$Production,
    [switch]$Draft,      
    [int]$Port = 4000,   
    [switch]$Help
)

if ($Help) {
    Write-Host "Jekyll Blog Startup Script" -ForegroundColor Blue
    Write-Host "Usage:"
    Write-Host "  .\start-dev.ps1                # Development mode"
    Write-Host "  .\start-dev.ps1 -Draft        # Include drafts"
    Write-Host "  .\start-dev.ps1 -Production   # Production mode" 
    Write-Host "  .\start-dev.ps1 -Port 3000    # Custom port"
    exit
}

Write-Host "Starting YoFat Jekyll Blog..." -ForegroundColor Blue

# Check dependencies
if (!(Get-Command bundle -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: bundler not found. Please install Ruby and Bundler" -ForegroundColor Red
    exit 1
}

# Install/update dependencies
Write-Host "Checking dependencies..." -ForegroundColor Yellow
bundle install

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to install dependencies" -ForegroundColor Red
    exit 1
}

# Clean old build
if (Test-Path "_site") {
    Write-Host "Cleaning old build..." -ForegroundColor Yellow
    Remove-Item "_site" -Recurse -Force
}

# Prepare Jekyll arguments
$jekyllArgs = @("exec", "jekyll", "serve")
$jekyllArgs += "--host", "127.0.0.1"
$jekyllArgs += "--port", $Port.ToString()
$jekyllArgs += "--livereload"

if ($Production) {
    Write-Host "Starting in PRODUCTION mode..." -ForegroundColor Green
    $jekyllArgs += "--config", "_config.yml"
} else {
    Write-Host "Starting in DEVELOPMENT mode..." -ForegroundColor Green
    $jekyllArgs += "--config", "_config.yml"
}

if ($Draft) {
    Write-Host "Including drafts..." -ForegroundColor Cyan
    $jekyllArgs += "--drafts"
}

# Display startup info
Write-Host ("=" * 50) -ForegroundColor Gray
Write-Host "Local URL: http://localhost:$Port" -ForegroundColor Green
Write-Host "Live reload: ENABLED" -ForegroundColor Green
Write-Host ("Working directory: " + (Get-Location)) -ForegroundColor Gray
Write-Host ("Start time: " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')) -ForegroundColor Gray
Write-Host ("=" * 50) -ForegroundColor Gray
Write-Host ""
Write-Host "TIP: Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Start Jekyll
try {
    & bundle @jekyllArgs
} catch {
    Write-Host ("ERROR: Jekyll failed to start: " + $_) -ForegroundColor Red
    exit 1
}