@echo off
echo 🎯 TEST APRÈS CORRECTION TYPES DE CONGÉ
echo =======================================

echo.
echo 📡 1. LOGIN (récupérer token)
FOR /F "delims=" %%i IN ('curl -s -X POST http://localhost:3000/api/auth/login -H "Content-Type: application/json" -d "{\"usernameOrEmail\": \"aa.bb@xtensus.com\", \"password\": \"123456\"}"') DO SET LOGIN_RESPONSE=%%i
echo %LOGIN_RESPONSE%

echo.
echo 📡 2. TYPES DE CONGÉ
curl -X GET http://localhost:3000/api/conge-types/actifs ^
  -H "Content-Type: application/json" ^
  --silent --show-error

echo.
echo.
echo 📡 3. TEST CRÉATION DEMANDE AVEC TYPE ID 1
curl -X POST http://localhost:3000/api/leave-requests ^
  -H "Content-Type: application/json" ^
  -d "{\"requesterId\": 15, \"leaveTypeId\": 1, \"startDate\": \"2026-09-26\", \"endDate\": \"2026-09-26\", \"requestedDays\": 1.0, \"reason\": \"Test correction Flutter\"}" ^
  --silent --show-error

echo.
echo.
echo ✅ Tests terminés !
pause