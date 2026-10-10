@echo off
title Service Status - AudiraNet
color 0F

:menu
cls
cd /d "%~dp0"
echo.
echo ========================================================
echo          AUDIRANET SERVICE STATUS CHECKER
echo ========================================================
echo.
echo   Checking all services...
echo.

REM Check Backend API
echo [Backend API - Port 4000]
netstat -an | findstr "4000" | findstr "LISTENING" >nul 2>&1
if errorlevel 1 (
    echo   Status: [OFFLINE] NOT RUNNING
) else (
    echo   Status: [ONLINE] RUNNING
    echo   URL:    http://localhost:4000
)

echo.
REM Check Admin Web
echo [Admin Web - Port 3000]
netstat -an | findstr "3000" | findstr "LISTENING" >nul 2>&1
if errorlevel 1 (
    echo   Status: [OFFLINE] NOT RUNNING
) else (
    echo   Status: [ONLINE] RUNNING
    echo   URL:    http://localhost:3000
)

echo.
REM Check PostgreSQL Docker
echo [PostgreSQL Database]
docker ps | findstr sebilling-postgres >nul 2>&1
if errorlevel 1 (
    echo   Status: [OFFLINE] Container not running
) else (
    echo   Status: [ONLINE] Container running
    echo   Port:   5433
)

echo.
REM Check Flutter Process
echo [Flutter Application]
tasklist | findstr /I "flutter.exe" >nul 2>&1
if errorlevel 1 (
    tasklist | findstr /I "audira_app.exe" >nul 2>&1
    if errorlevel 1 (
        echo   Status: [OFFLINE] NOT RUNNING
    ) else (
        echo   Status: [ONLINE] RUNNING
    )
) else (
    echo   Status: [ONLINE] RUNNING
)

echo.
echo ========================================================
echo.
echo Actions:
echo   [1] Start All Services
echo   [2] Stop All Services
echo   [3] Refresh Status
echo   [4] Open Backend Health Check
echo   [5] Open Admin Web
echo   [6] Exit
echo.
echo ========================================================
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" (
    start-all-services.bat
    goto menu
)
if "%choice%"=="2" (
    call stop-all-services.bat
    goto menu
)
if "%choice%"=="3" (
    goto menu
)
if "%choice%"=="4" (
    start http://localhost:4000/health
    goto menu
)
if "%choice%"=="5" (
    start http://localhost:3000
    goto menu
)
if "%choice%"=="6" (
    exit
)

goto menu
