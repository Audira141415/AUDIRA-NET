@echo off
setlocal enabledelayedexpansion
title AUDIRA NETWORKS - ISP Mobile Client Launcher [Target: Emulator ISP]

echo ========================================================
echo   AUDIRA NETWORKS - ISP Mobile Client Launcher
echo   Target Device: Android Emulator [AVD: ISP]
echo   Founder: Agus Dwi Rianto - https://audira.my.id
echo ========================================================
echo.

REM 1. Set environment paths
set "SCRIPT_DIR=%~dp0"
if exist "%SCRIPT_DIR%AUDIRA-NET\pubspec.yaml" (
    set "PROJECT_ROOT=%SCRIPT_DIR%"
    set "FLUTTER_DIR=%SCRIPT_DIR%AUDIRA-NET"
) else if exist "%SCRIPT_DIR%pubspec.yaml" (
    set "PROJECT_ROOT=%SCRIPT_DIR%..\"
    set "FLUTTER_DIR=%SCRIPT_DIR%"
) else (
    set "PROJECT_ROOT=%SCRIPT_DIR%"
    set "FLUTTER_DIR=%SCRIPT_DIR%AUDIRA-NET"
)

if exist "%LOCALAPPDATA%\Android\Sdk\platform-tools" (
    set "PATH=%LOCALAPPDATA%\Android\Sdk\platform-tools;%PATH%"
)
if defined ANDROID_HOME (
    if exist "%ANDROID_HOME%\platform-tools" (
        set "PATH=%ANDROID_HOME%\platform-tools;%PATH%"
    )
)

echo [1/4] Memeriksa Flutter SDK dan Android ADB...
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter SDK tidak ditemukan di PATH sistem
    echo Pastikan Flutter SDK sudah terpasang.
    pause
    exit /b 1
)
echo  - Flutter SDK: TERSEDIA

where adb >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [PERINGATAN] ADB command tidak ditemukan di PATH.
) else (
    echo  - Android ADB: TERSEDIA
)
echo.

echo [2/4] Mendeteksi Android Emulator khusus proyek ISP...
set "TARGET_EMU="
set "ISP_FOUND=0"

for /f "tokens=1" %%d in ('adb devices ^| findstr /R "emulator-[0-9]*"') do (
    for /f "tokens=1" %%a in ('adb -s %%d emu avd name 2^>nul ^| findstr /V /I "^OK"') do (
        if /I "%%a"=="ISP" (
            set "TARGET_EMU=%%d"
            set "ISP_FOUND=1"
            echo  - [TERPILIH] Menemukan Emulator ISP aktif pada ID: %%d [AVD: ISP]
        ) else (
            echo  - [SKIP] Mengabaikan %%d [AVD: %%a - Proyek Lain, Jangan Digunakan]
        )
    )
)

if "%ISP_FOUND%"=="0" (
    echo.
    echo  --------------------------------------------------------
    echo  [PERINGATAN] Emulator dengan AVD bernama 'ISP' TIDAK DITEMUKAN.
    echo  Emulator yang aktif saat ini adalah milik proyek lain [MDA / DC].
    echo  Sesuai aturan isolasi sistem, proyek AUDIRA-NET TIDAK BOLEH
    echo  dijalankan pada emulator proyek lain.
    echo  --------------------------------------------------------
    echo.
    echo  Mencari AVD 'ISP' di daftar Android Studio...
    emulator -list-avds 2>nul | findstr /I ISP >nul 2>nul
    if !ERRORLEVEL! EQU 0 (
        echo  - Menemukan AVD 'ISP'. Meluncurkan emulator ISP...
        start "" "%LOCALAPPDATA%\Android\Sdk\emulator\emulator.exe" -avd ISP
        echo  - Menunggu emulator ISP terhubung...
        adb wait-for-device
        for /f "tokens=1" %%d in ('adb devices ^| findstr /R "emulator-[0-9]*"') do (
            for /f "tokens=1" %%a in ('adb -s %%d emu avd name 2^>nul ^| findstr /V /I "^OK"') do (
                if /I "%%a"=="ISP" (
                    set "TARGET_EMU=%%d"
                    set "ISP_FOUND=1"
                )
            )
        )
    ) else (
        echo  [ERROR] AVD bernama 'ISP' belum dibuat di Android Studio.
        echo  Silakan buat AVD bernama 'ISP' atau nyalakan emulator ISP Anda.
        echo.
        pause
        exit /b 1
    )
)
echo.

echo [3/4] Mengonfigurasi Reverse Port [Network ISP Bridge] ke %TARGET_EMU%...
echo  - Reverse port TCP 3218 [Backend NestJS API]...
adb -s %TARGET_EMU% reverse tcp:3218 tcp:3218 >nul 2>nul
echo  - Reverse port TCP 3217 [Admin Panel]...
adb -s %TARGET_EMU% reverse tcp:3217 tcp:3217 >nul 2>nul
echo  - Reverse port TCP 3219 [Customer Portal]...
adb -s %TARGET_EMU% reverse tcp:3219 tcp:3219 >nul 2>nul
echo  - Menyalakan layar emulator ISP...
adb -s %TARGET_EMU% shell input keyevent 224 >nul 2>nul
adb -s %TARGET_EMU% shell input keyevent 82 >nul 2>nul
echo [OK] Reverse port aktif. Mobile app dapat mengakses API di http://localhost:3218
echo.

echo [4/4] Memeriksa status Backend API AUDIRA ISP [Port 3218]...
netstat -ano | findstr :3218 | findstr LISTENING >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo  - Backend API terdeteksi AKTIF di http://localhost:3218
) else (
    echo  - Backend API belum aktif di Port 3218.
    echo  - Membuka jendela server Backend API di background...
    start "AUDIRA ISP - Backend API" cmd /k "title AUDIRA Backend API - Port 3218 && color 0B && cd /d "%PROJECT_ROOT%AUDIRA-BILLING\apps\backend" && npm run dev"
    ping -n 4 127.0.0.1 >nul 2>&1
)
echo.

echo ========================================================
echo   MELUNCURKAN APLIKASI ISP FLUTTER KE EMULATOR ISP [%TARGET_EMU%]
echo ========================================================
echo   * Petunjuk Hotkey Interaktif di Konsol Ini:
echo     - Tekan 'r' : Hot Reload [Pembaruan UI seketika]
echo     - Tekan 'R' : Hot Restart [Reset state aplikasi]
echo     - Tekan 'v' : Buka Flutter DevTools di browser
echo     - Tekan 'h' : Bantuan daftar perintah Flutter
echo     - Tekan 'q' : Berhenti / Keluar dari aplikasi
echo ========================================================
echo.

cd /d "%FLUTTER_DIR%"
flutter run -d %TARGET_EMU%

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Gagal menjalankan aplikasi Flutter di emulator %TARGET_EMU%.
    pause
)
