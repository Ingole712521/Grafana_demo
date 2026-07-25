#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$TerraformDir = Join-Path $Root "terraform"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  MONITORING STACK - AUTOMATED DESTROY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $TerraformDir

terraform init -upgrade
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

terraform destroy -auto-approve
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "All AWS resources removed." -ForegroundColor Green
Write-Host ""
