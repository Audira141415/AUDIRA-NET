@echo off
title Quick Test - Backend Integration
color 0D

cd /d "%~dp0"

echo.
echo ========================================================
echo        QUICK INTEGRATION TEST
echo ========================================================
echo.
echo   Testing connections:
echo   - Backend API (Port 4000)
echo   - Admin Web (Port 3000)
echo   - PostgreSQL Database
echo.
echo ========================================================
echo.

REM Test backend health
echo [1] Testing Backend API...
echo ========================================================
where curl >nul 2>&1
if errorlevel 1 (
    echo [WARNING] curl not found, using basic test...
    ping -n 1 127.0.0.1 >nul
    netstat -an | findstr "4000" | findstr "LISTENING" >nul 2>&1
    if errorlevel 1 (
        color 0C
        echo [ERROR] Backend not listening on port 4000!
        goto :backend_error
    ) else (
        echo [OK] Backend port is open
    )
) else (
    curl -s -o nul -w "%%{http_code}" http://localhost:4000/health | findstr "200" >nul 2>&1
    if errorlevel 1 (
        color 0C
        echo [ERROR] Backend not responding!
        :backend_error
        echo.
        echo Please start backend first:
        echo   start-backend-only.bat
        echo.
        pause
        exit /b 1
    ) else (
        echo [SUCCESS] Backend is healthy!
    )
)

echo.
echo [2] Testing Database Connection...
echo ========================================================
curl -s http://localhost:4000/analytics/dashboard >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Dashboard endpoint not responding
) else (
    echo [SUCCESS] Database is connected!
)

echo.
echo [3] Testing Next.js Admin Web...
echo ========================================================
curl -s http://localhost:3000 >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Admin web not running
) else (
    echo [SUCCESS] Admin web is accessible!
)

echo.
echo ========================================================
echo        TEST RESULTS SUMMARY
echo ========================================================
echo.
echo   Backend API:      http://localhost:4000       [OK]
echo   Admin Web:        http://localhost:3000       [CHECK]
echo   Database:         PostgreSQL                  [CHECK]
echo.
echo ========================================================
echo.
echo Next Steps:
echo   1. Run Flutter app: start-flutter-only.bat
echo   2. Navigate to "Backend Integration Test"
echo   3. Click all test buttons
echo   4. Verify green checkmarks
echo.
echo ========================================================
echo.
echo Press any key to open URLs in browser...
pause >nul

start http://localhost:4000/health
timeout /t 2 /nobreak >nul
start http://localhost:3000

echo.
pause
