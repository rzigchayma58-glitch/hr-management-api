@echo off
echo 🎯 TEST DIRECT DES ENDPOINTS FLUTTER
echo =====================================

echo.
echo 📡 1. LOGIN TEST
curl -X POST http://localhost:3000/api/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"usernameOrEmail\": \"aa.bb@xtensus.com\", \"password\": \"123456\"}" ^
  --silent --show-error

echo.
echo.
echo 📡 2. TYPES DE CONGE TEST  
curl -X GET http://localhost:3000/api/conge-types/actifs ^
  -H "Content-Type: application/json" ^
  --silent --show-error

echo.
echo.
echo 📡 3. SERVER STATUS TEST
curl -X GET http://localhost:3000/api/flutter/test ^
  -H "Content-Type: application/json" ^
  --silent --show-error

echo.
echo.
echo ✅ Tests terminés !
pause