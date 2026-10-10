@echo off
title AudiraNet - Complete System Startup
color 0E

cd /d "%~dp0"

echo.
echo ========================================================
echo            AUDIRANET COMPLETE SYSTEM
echo              Full Stack Integration
echo ========================================================
echo.
echo   Starting all services:
echo   [1] PostgreSQL Database (Docker)
echo   [2] NestJS Backend API (Port 3218)
echo   [3] Next.js Admin Web (Port 3217)
echo   [4] Flutter Desktop Application
echo.
echo ========================================================
echo.
echo Press any key to start all services...
pause >nul

REM ============================================
REM STEP 1: Start Backend Services
REM ============================================
echo.
echo [STEP 1/4] Starting Backend Services...
echo ========================================================
echo.

if not exist "%~dp0..\AUDIRA-BILLING\start-servers.bat" (
    color 0C
    echo [ERROR] Backend startup script not found!
    echo Path: %~dp0..\AUDIRA-BILLING\start-servers.bat
    pause
    exit /b 1
)

echo Starting PostgreSQL, Backend API, and Admin Web...
start "Backend Services" "%~dp0..\AUDIRA-BILLING\start-servers.bat"

echo Waiting 25 seconds for backend to initialize...
timeout /t 25 /nobreak

REM ============================================
REM STEP 2: Verify Backend Health
REM ============================================
echo.
echo [STEP 2/4] Verifying Backend Health...
echo ========================================================
echo.

ping 127.0.0.1 -n 3 >nul
curl -s http://localhost:3218/health >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Backend still starting...
    echo Waiting additional 15 seconds...
    timeout /t 15 /nobreak
    curl -s http://localhost:3218/health >nul 2>&1
    if errorlevel 1 (
        echo [WARNING] Backend may need more time
    ) else (
        echo [SUCCESS] Backend is now ready!
    )
) else (
    echo [SUCCESS] Backend is healthy and ready!
)

REM ============================================
REM STEP 3: Start Flutter Application
REM ============================================
echo.
echo [STEP 3/4] Starting Flutter Application...
echo ========================================================
echo.

if not exist "%~dp0pubspec.yaml" (
    color 0C
    echo [ERROR] Flutter project not found!
    echo Path: %~dp0
    pause
    exit /b 1
)

echo Getting Flutter dependencies...
cd /d "%~dp0"
flutter pub get >nul 2>&1

echo Launching Flutter app on Windows...
start "Flutter Application" cmd /k "cd /d "%~dp0" && color 0B && title Flutter App && flutter run -d windows"

timeout /t 5 /nobreak

REM ============================================
REM STEP 4: Summary
REM ============================================
echo.
echo [STEP 4/4] Opening Service Dashboard...
echo ========================================================
echo.

echo Starting browser for backend health check...
timeout /t 3 /nobreak
start http://localhost:3218/health

echo.
echo ========================================================
echo            ALL SERVICES STARTED!
echo ========================================================
echo.
echo   Backend API:       http://localhost:3218
echo   Admin Web:         http://localhost:3217
echo   Flutter App:       Starting in separate window
echo   Health Check:      http://localhost:3218/health
echo.
echo   Integration Test:  Navigate to "Backend Integration Test"
echo                      in Flutter app to verify connection
echo.
echo ========================================================
echo.
echo Press any key to view this window's processes...
pause >nul

echo.
echo Active Windows:
echo   - Backend Services (PostgreSQL + NestJS + Next.js)
echo   - Flutter Application (Windows Desktop)
echo   - This Control Window
echo.
echo To stop all services:
echo   1. Close all terminal windows
echo   2. Or run: stop-all-services.bat
echo.
echo ========================================================
echo.
pause
