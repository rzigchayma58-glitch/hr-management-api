# Test simple du backend
Write-Host "Test Backend XConges sur port 8082" -ForegroundColor Green

try {
    $response = Invoke-RestMethod -Uri "http://localhost:8082/actuator/health" -Method Get -TimeoutSec 5
    Write-Host "✓ Backend accessible!" -ForegroundColor Green
    Write-Host "Status: $($response.status)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ Backend non accessible" -ForegroundColor Red
    Write-Host "Erreur: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Configuration Flutter:" -ForegroundColor Yellow
Write-Host "URL PC: http://localhost:8082/api" -ForegroundColor Cyan
Write-Host "URL Android emulator: http://10.0.2.2:8082/api" -ForegroundColor Cyan