@echo off
echo ==============================================
echo    DIAGNOSTIC BACKEND XCONGES - PORT 3000
echo ==============================================
echo.

echo 1. Test de connexion backend...
powershell -Command "try { $response = Invoke-RestMethod -Uri 'http://localhost:3000/api/flutter/test' -Method GET; Write-Host '✅ Backend répond:' -ForegroundColor Green; Write-Host \"   Port: $($response.port)\" -ForegroundColor Cyan; Write-Host \"   Message: $($response.message)\" -ForegroundColor Cyan; Write-Host \"   Heure: $($response.timestamp)\" -ForegroundColor Cyan } catch { Write-Host '❌ Backend inaccessible sur port 3000' -ForegroundColor Red; Write-Host \"   Erreur: $($_.Exception.Message)\" -ForegroundColor Red }"

echo.
echo 2. Test du compte admin...
powershell -Command "try { $body = @{ usernameOrEmail='admin'; password='password123' } | ConvertTo-Json; $response = Invoke-RestMethod -Uri 'http://localhost:3000/api/auth/login' -Method POST -Body $body -ContentType 'application/json'; Write-Host '✅ Login admin réussi' -ForegroundColor Green; Write-Host '   Token reçu !' -ForegroundColor Cyan } catch { Write-Host '❌ Erreur de login admin' -ForegroundColor Red; Write-Host \"   Erreur: $($_.Exception.Message)\" -ForegroundColor Red }"

echo.
echo 3. Configuration Flutter recommandée:
echo    baseUrl: http://10.148.173.19:3000/api
echo    Compte test: admin@test.com / password123
echo.

echo ==============================================
echo    RÉSULTAT DU DIAGNOSTIC
echo ==============================================
echo.
echo Si vous voyez deux ✅, votre backend fonctionne parfaitement !
echo Utilisez le fichier SOLUTION_DEFINITIVE_LOGIN.dart dans Flutter.
echo.
pause