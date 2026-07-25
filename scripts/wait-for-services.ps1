param(
    [string]$PublicIp,
    [int]$GrafanaPort = 3000,
    [int]$PrometheusPort = 9090,
    [int]$AppPort = 8080,
    [int]$MaxAttempts = 60,
    [int]$SleepSeconds = 10
)

$ErrorActionPreference = "Continue"

$checks = @(
    @{ Name = "Demo App";    Url = "http://${PublicIp}:${AppPort}/health" },
    @{ Name = "Prometheus";  Url = "http://${PublicIp}:${PrometheusPort}/-/ready" },
    @{ Name = "Grafana";     Url = "http://${PublicIp}:${GrafanaPort}/api/health" }
)

Write-Host ""
Write-Host "Waiting for AWS services to become healthy..." -ForegroundColor Cyan
Write-Host "Public IP: $PublicIp"
Write-Host ""

for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
    $allHealthy = $true

    foreach ($check in $checks) {
        try {
            $response = Invoke-WebRequest -Uri $check.Url -UseBasicParsing -TimeoutSec 5
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 300) {
                Write-Host "[OK] $($check.Name)" -ForegroundColor Green
            } else {
                Write-Host "[..] $($check.Name) (HTTP $($response.StatusCode))" -ForegroundColor Yellow
                $allHealthy = $false
            }
        } catch {
            Write-Host "[..] $($check.Name) (not ready)" -ForegroundColor Yellow
            $allHealthy = $false
        }
    }

    if ($allHealthy) {
        Write-Host ""
        Write-Host "All services are healthy!" -ForegroundColor Green
        exit 0
    }

    Write-Host "Attempt $attempt/$MaxAttempts - retrying in ${SleepSeconds}s..."
    Start-Sleep -Seconds $SleepSeconds
}

Write-Host ""
Write-Host "Timed out waiting for services. They may still be starting." -ForegroundColor Yellow
Write-Host "Check EC2 logs: ssh in and run: sudo tail -f /var/log/user-data.log"
exit 0
