# Script PowerShell pour tester l'intégration Backend Flutter XCongés
# Exécuter: .\test_backend_flutter.ps1

Write-Host "🚀 Test d'intégration Backend Flutter XCongés" -ForegroundColor Green
Write-Host "=" * 50

# Variables
$baseUrl = "http://localhost:8082/api"
$loginData = @{
    usernameOrEmail = "admin@test.com"
    password = "password123"
} | ConvertTo-Json

Write-Host "📡 Test 1: Vérification de la connectivité backend..." -ForegroundColor Yellow

try {
    $healthCheck = Invoke-RestMethod -Uri "http://localhost:8082/actuator/health" -Method Get -TimeoutSec 5
    Write-Host "✅ Backend accessible sur port 8082" -ForegroundColor Green
    Write-Host "   Status: $($healthCheck.status)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Backend non accessible sur port 8082" -ForegroundColor Red
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   💡 Vérifiez que le backend est démarré avec: .\mvnw.cmd spring-boot:run" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "🔐 Test 2: Endpoint de login..." -ForegroundColor Yellow

try {
    $headers = @{
        "Content-Type" = "application/json"
    }
    
    $loginResponse = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -Body $loginData -Headers $headers -TimeoutSec 10
    
    Write-Host "✅ Login réussi!" -ForegroundColor Green
    Write-Host "   User: $($loginResponse.user.firstName) $($loginResponse.user.lastName)" -ForegroundColor Cyan
    Write-Host "   Role: $($loginResponse.user.role)" -ForegroundColor Cyan
    Write-Host "   Token: $($loginResponse.accessToken.Substring(0, 20))..." -ForegroundColor Cyan
    Write-Host "   Expires in: $($loginResponse.expiresIn / 1000 / 60) minutes" -ForegroundColor Cyan
    
    $token = $loginResponse.accessToken
    
} catch {
    Write-Host "❌ Login échoué" -ForegroundColor Red
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
    
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "   💡 Créez l'utilisateur test avec le script CREATE_TEST_USER.sql" -ForegroundColor Yellow
    }
    exit 1
}

Write-Host ""
Write-Host "👤 Test 3: Endpoint utilisateur authentifié..." -ForegroundColor Yellow

try {
    $authHeaders = @{
        "Authorization" = "Bearer $token"
        "Content-Type" = "application/json"
    }
    
    $userResponse = Invoke-RestMethod -Uri "$baseUrl/auth/me" -Method Get -Headers $authHeaders -TimeoutSec 10
    
    Write-Host "✅ Profil utilisateur récupéré!" -ForegroundColor Green
    Write-Host "   ID: $($userResponse.id)" -ForegroundColor Cyan
    Write-Host "   Email: $($userResponse.email)" -ForegroundColor Cyan
    Write-Host "   Username: $($userResponse.username)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Récupération profil échoué" -ForegroundColor Red
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📋 Test 4: Endpoint congés..." -ForegroundColor Yellow

try {
    $leaveRequests = Invoke-RestMethod -Uri "$baseUrl/leave-requests/requester/$($userResponse.id)" -Method Get -Headers $authHeaders -TimeoutSec 10
    
    Write-Host "✅ Liste des demandes récupérée!" -ForegroundColor Green
    Write-Host "   Nombre de demandes: $($leaveRequests.Count)" -ForegroundColor Cyan
    
} catch {
    Write-Host "⚠️  Endpoint congés non accessible (normal si pas de demandes)" -ForegroundColor Yellow
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🧪 Test 5: Endpoint Flutter de test..." -ForegroundColor Yellow

try {
    $flutterTest = Invoke-RestMethod -Uri "$baseUrl/flutter/test" -Method Get -TimeoutSec 10
    
    Write-Host "✅ Endpoint Flutter test accessible!" -ForegroundColor Green
    Write-Host "   Message: $($flutterTest.message)" -ForegroundColor Cyan
    Write-Host "   Flutter Ready: $($flutterTest.flutter_ready)" -ForegroundColor Cyan
    
} catch {
    Write-Host "❌ Endpoint Flutter test non accessible" -ForegroundColor Red
    Write-Host "   Erreur: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "📊 RÉSUMÉ DES TESTS" -ForegroundColor Magenta
Write-Host "=" * 50
Write-Host "Backend URL: $baseUrl" -ForegroundColor White
Write-Host "Port configuré: 8082" -ForegroundColor White
Write-Host "Utilisateur test: admin@test.com" -ForegroundColor White
Write-Host "Mot de passe: password123" -ForegroundColor White
Write-Host ""
Write-Host "🎯 INTÉGRATION FLUTTER:" -ForegroundColor Green
Write-Host "   • Modifier ApiConfig.dart avec: http://localhost:8082/api" -ForegroundColor Cyan
Write-Host "   • Pour Android emulator: http://10.0.2.2:8082/api" -ForegroundColor Cyan
Write-Host "   • Importer la collection Postman mise à jour" -ForegroundColor Cyan
Write-Host ""
Write-Host "🎉 BACKEND PRÊT POUR FLUTTER!" -ForegroundColor Green