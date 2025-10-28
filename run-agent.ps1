# PostgreSQL AI Agent - Windows Helper Script
# Usage: .\run-agent.ps1 "Your question here"
#        .\run-agent.ps1 --interactive

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

# Run the agent with the venv Python
& ".\venv\Scripts\python.exe" agent.py $Arguments

