@echo off
title AUDIRANET - Quick Start
color 0A

:menu
cls
echo ========================================
echo    AUDIRANET - Quick Start Menu
echo ========================================
echo.
echo    1. Start Web App Only
echo    2. Start Flutter App Only
echo    3. Start All (Web + Flutter)
echo    4. Stop All Services
echo    5. Install/Update Dependencies
echo    6. Setup Environment
echo    7. Open Web Browser
echo    8. Exit
echo.
echo ========================================
choice /C 12345678 /N /M "Pilih opsi (1-8): "

if errorlevel 8 goto :exit
if errorlevel 7 goto :browser
if errorlevel 6 goto :setup
if errorlevel 5 goto :install
if errorlevel 4 goto :stop
if errorlevel 3 goto :all
if errorlevel 2 goto :flutter
if errorlevel 1 goto :web

:web
cls
echo [INFO] Starting Web Application...
cd /d "%~dp0audiranet-web"
echo [INFO] Checking port 3000...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3000" ^| find "LISTENING"') do (
    echo [INFO] Killing process on port 3000 (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)
start "AudiraNET Web" cmd /k "npm run dev"
echo.
echo Web app started! Opening browser...
timeout /t 3 /nobreak >nul
start http://localhost:3000
goto :menu

:flutter
cls
echo [INFO] Starting Flutter Application...
cd /d "%~dp0"
start "AudiraNET Flutter" cmd /k "flutter run"
goto :menu

:all
cls
echo [INFO] Starting All Services...
echo [INFO] Checking port 3000...
cd /d "%~dp0audiranet-web"
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3000" ^| find "LISTENING"') do (
    echo [INFO] Killing process on port 3000 (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)
cd /d "%~dp0"
call "%~dp0start-all.bat"
goto :menu

:stop
cls
echo [INFO] Stopping All Services...
call "%~dp0stop-all.bat"
goto :menu

:install
cls
echo [INFO] Installing/Updating Dependencies...
echo.
echo [1/2] Web App Dependencies...
cd /d "%~dp0audiranet-web"
call npm install
echo.
echo [2/2] Flutter Dependencies...
cd /d "%~dp0"
call flutter pub get
echo.
echo Dependencies updated!
pause
goto :menu

:setup
cls
echo [INFO] Setup Environment...
cd /d "%~dp0audiranet-web"
if not exist ".env.local" (
    echo Creating .env.local...
    (
        echo NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSyBqg7L_example_key
        echo NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=audiranet-d4f68.firebaseapp.com
        echo NEXT_PUBLIC_FIREBASE_PROJECT_ID=audiranet-d4f68
        echo NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=audiranet-d4f68.appspot.com
        echo NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789
        echo NEXT_PUBLIC_FIREBASE_APP_ID=1:123456789:web:example
    ) > .env.local
    echo.
    echo .env.local created! Opening for edit...
    notepad .env.local
) else (
    echo .env.local already exists! Opening for edit...
    notepad .env.local
)
pause
goto :menu

:browser
start http://localhost:3001
goto :menu

:exit
cls
echo.
echo Terima kasih telah menggunakan AUDIRANET!
echo.
timeout /t 2 /nobreak >nul
exit

