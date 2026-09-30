@echo off
echo 🔍 TEST HISTORIQUE DIRECT
echo ==========================

echo.
echo 📡 1. LOGIN pour récupérer le token
FOR /F "tokens=*" %%i IN ('curl -X POST http://localhost:3000/api/auth/login -H "Content-Type: application/json" -d "{\"usernameOrEmail\": \"aa.bb@xtensus.com\", \"password\": \"123456\"}" --silent') DO SET LOGIN_RESPONSE=%%i
echo %LOGIN_RESPONSE%

echo.
echo 📡 2. Test historique pour user ID 15 (aa.bb@xtensus.com)
curl -X GET http://localhost:3000/api/leave-requests/requester/15 ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  --silent --show-error

echo.
echo 📡 3. Test historique pour user ID 2 
curl -X GET http://localhost:3000/api/leave-requests/requester/2 ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer YOUR_TOKEN_HERE" ^
  --silent --show-error

echo.
echo ✅ Tests terminés !
pause