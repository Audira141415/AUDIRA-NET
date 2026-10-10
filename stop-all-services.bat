@echo off
title Stop All AudiraNet Services
color 0C

cd /d "%~dp0"

echo.
echo ========================================================
echo          STOPPING ALL AUDIRANET SERVICES
echo ========================================================
echo.
echo   This will stop:
echo   [1] Flutter Applications
echo   [2] Backend Services (via stop-servers.bat)
echo   [3] All remaining processes
echo.
echo ========================================================
echo.
echo Press any key to stop all services...
pause >nul

echo.
echo [1/3] Stopping Flutter Applications...
echo ========================================================
taskkill /F /IM flutter.exe >nul 2>&1
taskkill /F /IM dart.exe >nul 2>&1
taskkill /F /IM audira_app.exe >nul 2>&1
echo [OK] Flutter processes stopped.

echo.
echo [2/3] Stopping Backend Services...
echo ========================================================
if exist "%~dp0..\PJTBillingByAudira\stop-servers.bat" (
    call "%~dp0..\PJTBillingByAudira\stop-servers.bat"
    echo [OK] Backend services stopped.
) else (
    echo [WARNING] Backend stop script not found, killing processes manually...
    taskkill /FI "WindowTitle eq AudiraNET Backend*" /F >nul 2>&1
    taskkill /FI "WindowTitle eq AudiraNET Frontend*" /F >nul 2>&1
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :3000 ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>&1
    for /f "tokens=5" %%a in ('netstat -aon ^| findstr :4000 ^| findstr LISTENING') do taskkill /F /PID %%a >nul 2>&1
    echo [OK] Processes killed.
)

echo.
echo [3/3] Final cleanup...
echo ========================================================
taskkill /FI "WindowTitle eq Backend Services*" /F >nul 2>&1
taskkill /FI "WindowTitle eq Flutter Application*" /F >nul 2>&1
echo [OK] Cleanup complete.

echo.
echo ========================================================
echo          ALL SERVICES STOPPED!
echo ========================================================
echo.
echo   You can now:
echo   - Restart services using start-all-services.bat
echo   - Start individual components separately
echo.
echo ========================================================
echo.
pause
