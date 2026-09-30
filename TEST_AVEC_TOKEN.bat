@echo off
echo 🎯 TEST AVEC TOKEN COMPLET
echo =========================

echo.
echo 📡 1. TYPES DE CONGÉ avec token
curl -X GET http://localhost:3000/api/conge-types/actifs ^
  -H "Content-Type: application/json" ^
  -H "Authorization: Bearer eyJhbGciOiJIUzM4NCJ9.eyJzdWIiOiJhYS5iYiIsInVzZXJJZCI6MTUsInVzZXJuYW1lIjoiYWEuYmIiLCJyb2xlIjoiRU1QTE9ZRUUiLCJpYXQiOjE3OTAzNTMxNzksImV4cCI6MTc5MDM1Njc3OX0.r_1duEciSuj3uA5jnrd4VahzPIbJEQkeCHzFY1OGLwFfGBdKjAcU9k-9TLc7Ku_m" ^
  --silent --show-error

echo.
echo.
echo ✅ Test terminé !
pause