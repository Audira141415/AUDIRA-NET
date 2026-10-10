@echo off
title Backend Services - AudiraNet
color 0A

echo.
echo ================================================
echo   STARTING BACKEND SERVICES
echo ================================================
echo.
echo [1] PostgreSQL Database (Docker)
echo [2] NestJS Backend API (Port 3218)
echo [3] Next.js Admin Web (Port 3217)
echo.
echo ================================================
echo.

REM Check if backend folder exists
if not exist "%~dp0..\AUDIRA-BILLING" (
    color 0C
    echo [ERROR] Backend folder not found!
    echo Expected: %~dp0..\AUDIRA-BILLING
    echo.
    pause
    exit /b 1
)

REM Navigate to backend folder and call start script
cd /d "%~dp0..\AUDIRA-BILLING"

echo Starting backend services...
echo.
start "" "%~dp0..\AUDIRA-BILLING\start-servers.bat"

echo.
echo Waiting for services to start (20 seconds)...
timeout /t 20 /nobreak

echo.
echo ================================================
echo   BACKEND SERVICES STARTED!
echo ================================================
echo.
echo Backend API:    http://localhost:3218
echo Admin Web:      http://localhost:3217
echo Health Check:   http://localhost:3218/health
echo.
echo Press any key to open health check...
pause >nul
start http://localhost:3218/health

echo.
cd /d "%~dp0"
pause
