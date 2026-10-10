@echo off
echo ========================================
echo    AUDIRANET - Start All Services
echo ========================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Node.js tidak ditemukan!
    echo Silakan install Node.js dari https://nodejs.org/
    pause
    exit /b 1
)

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [WARNING] Flutter tidak ditemukan!
    echo Flutter app tidak akan berjalan.
    echo.
)

echo [INFO] Memulai semua layanan...
echo.

REM Start Web Application
echo ========================================
echo [1/2] Starting Web Application...
echo ========================================
cd /d "%~dp0audiranet-web"

REM Check if node_modules exists
if not exist "node_modules\" (
    echo [INFO] Installing dependencies...
    call npm install
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Gagal install dependencies!
        pause
        exit /b 1
    )
)

REM Check if .env.local exists
if not exist ".env.local" (
    echo [WARNING] File .env.local tidak ditemukan!
    echo Membuat .env.local dari template...
    echo NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key_here > .env.local
    echo NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com >> .env.local
    echo NEXT_PUBLIC_FIREBASE_PROJECT_ID=your_project_id >> .env.local
    echo NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your_project.appspot.com >> .env.local
    echo NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id >> .env.local
    echo NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id >> .env.local
    echo.
    echo [ACTION REQUIRED] Silakan edit .env.local dengan Firebase credentials Anda!
    notepad .env.local
    pause
)

REM Kill process on port 3000 if exists
echo [INFO] Checking port 3000...
for /f "tokens=5" %%a in ('netstat -aon ^| find ":3000" ^| find "LISTENING"') do (
    echo [INFO] Killing process on port 3000 (PID: %%a)
    taskkill /F /PID %%a >nul 2>&1
)

echo [INFO] Starting Next.js development server...
start "AudiraNET Web App" cmd /k "npm run dev"
timeout /t 3 /nobreak >nul

echo.
echo ========================================
echo [2/2] Starting Flutter Application...
echo ========================================
cd /d "%~dp0"

where flutter >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [INFO] Checking Flutter devices...
    flutter devices
    echo.
    
    choice /C YN /M "Jalankan Flutter app"
    if errorlevel 2 goto :skip_flutter
    if errorlevel 1 goto :run_flutter
    
    :run_flutter
    echo [INFO] Starting Flutter app...
    start "AudiraNET Flutter App" cmd /k "flutter run"
    timeout /t 2 /nobreak >nul
    
    :skip_flutter
) else (
    echo [SKIP] Flutter tidak terinstall, skip Flutter app.
)

echo.
echo ========================================
echo    Semua Layanan Berhasil Dimulai!
echo ========================================
echo.
echo [Web App]     http://localhost:3001
echo [Flutter App] Check emulator/device
echo.
echo Tekan tombol apapun untuk membuka browser...
pause >nul

REM Open browser
start http://localhost:3001

echo.
echo ========================================
echo    Services Running
echo ========================================
echo.
echo - Web Application: Running di terminal terpisah
echo - Flutter App: Running di terminal terpisah (jika dipilih)
echo.
echo Tutup terminal yang berjalan untuk menghentikan service.
echo.
pause
