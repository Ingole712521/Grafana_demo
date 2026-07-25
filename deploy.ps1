#Requires -Version 5.1
param(
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$TerraformDir = Join-Path $Root "terraform"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  MONITORING STACK - AUTOMATED DEPLOY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $TerraformDir

Write-Host "[1/3] Initializing Terraform..." -ForegroundColor Yellow
terraform init -upgrade
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "[2/3] Deploying to AWS (fully automated, no prompts)..." -ForegroundColor Yellow
terraform apply -auto-approve
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "[3/3] Deployment summary" -ForegroundColor Yellow
terraform output deployment_summary

$grafanaUrl = terraform output -raw grafana_url

if (-not $NoBrowser) {
    Write-Host "Opening Grafana in your browser..." -ForegroundColor Green
    Start-Process $grafanaUrl
}

Write-Host ""
Write-Host "Done! Dashboard: Dashboards -> Demo App Monitoring" -ForegroundColor Green
Write-Host ""
