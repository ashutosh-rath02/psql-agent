# Odoo.sh AI Agent - Windows Helper Script
# Usage: .\run-odoo-agent.ps1 "Your question here"
#        .\run-odoo-agent.ps1 --interactive
#        .\run-odoo-agent.ps1 --test-connection

param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
)

# Check if venv exists
if (-not (Test-Path "venv\Scripts\python.exe")) {
    Write-Host "Virtual environment not found. Creating..." -ForegroundColor Yellow
    python -m venv venv
    
    Write-Host "Installing dependencies..." -ForegroundColor Yellow
    .\venv\Scripts\pip.exe install -r requirements.txt
}

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "Creating .env file from template..." -ForegroundColor Yellow
    Copy-Item env.example .env
    Write-Host "Please edit .env and add your Odoo.sh credentials!" -ForegroundColor Red
    Write-Host "See ODOO-SETUP.md for detailed instructions." -ForegroundColor Yellow
    pause
}

# Run the Odoo agent with the venv Python
& ".\venv\Scripts\python.exe" odoo_agent.py $Arguments


