@echo off
echo ========================================
echo  AUDIRANET FULL INTEGRATION STARTER
echo ========================================
echo.

REM Check if backend folder exists
if not exist "F:\PJTAUDIRANETANDBILLING\PJTBillingByAudira" (
    echo [ERROR] Backend folder not found!
    echo Please ensure PJTBillingByAudira exists
    pause
    exit /b 1
)

echo [1/4] Starting Backend Services...
echo.
cd /d F:\PJTAUDIRANETANDBILLING\PJTBillingByAudira
start "Backend Services" cmd /k ".\start-servers.bat"
timeout /t 5 /nobreak >nul

echo.
echo [2/4] Waiting for backend to initialize...
timeout /t 10 /nobreak

echo.
echo [3/4] Testing backend health...
curl -s http://localhost:4000/health >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Backend might still be starting...
    echo Continuing anyway...
) else (
    echo [SUCCESS] Backend is healthy!
)

echo.
echo [4/4] Starting Flutter Application...
echo.
cd /d F:\PJTAUDIRANETANDBILLING\PJTAudiraNet
start "Flutter App" cmd /k "flutter run -d windows"

echo.
echo ========================================
echo  ALL SERVICES STARTING!
echo ========================================
echo.
echo Backend API:      http://localhost:4000
echo Backend Admin:    http://localhost:3000
echo Flutter App:      Starting...
echo.
echo Integration Test: Navigate to Backend Integration Test in app
echo.
echo Press any key to open backend health check in browser...
pause >nul
start http://localhost:4000/health

echo.
echo Press any key to exit this launcher...
pause >nul
