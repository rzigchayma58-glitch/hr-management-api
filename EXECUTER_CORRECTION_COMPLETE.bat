@echo off
echo ===============================================
echo    🔧 CORRECTION COMPLETE XCONGES FLUTTER
echo ===============================================
echo.

echo 1️⃣ Test connectivité backend...
curl -s http://localhost:3000/api/flutter/test
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Backend non accessible - Vérifiez qu'il est démarré
    pause
    exit /b 1
)
echo ✅ Backend accessible sur port 3000
echo.

echo 2️⃣ Correction de la base MySQL...
echo Exécution des scripts SQL...

mysql -u root -p --database=rh_xtensus < CORRIGER_BASE_MYSQL_COMPLETE.sql
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Erreur lors de l'exécution du script principal
    echo Vérifiez vos identifiants MySQL et que la base rh_xtensus existe
    pause
    exit /b 1
)

mysql -u root -p --database=rh_xtensus < CREATE_USER_TEST_COMPLET.sql
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Erreur lors de la création des utilisateurs de test
    pause
    exit /b 1
)

echo ✅ Base MySQL corrigée et utilisateurs créés
echo.

echo 3️⃣ Test complet d'intégration...
dart test_create_leave_request.dart
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Test d'intégration échoué
    pause
    exit /b 1
)

echo.
echo 🎉 ===============================================
echo    ✅ CORRECTION TERMINÉE AVEC SUCCÈS !
echo ===============================================
echo.
echo Votre système XCongés est maintenant opérationnel :
echo ✅ Backend Spring Boot sur port 3000
echo ✅ Base MySQL synchronisée
echo ✅ Utilisateurs de test créés
echo ✅ Intégration Flutter fonctionnelle
echo.
echo Comptes de test disponibles :
echo - admin@test.com / password123
echo - employe@test.com / password123  
echo - manager@test.com / password123
echo.
echo 🚀 Lancez votre app Flutter et testez !
echo.
pause