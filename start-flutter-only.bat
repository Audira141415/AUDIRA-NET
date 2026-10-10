@echo off
title Flutter App - AudiraNet
color 0B

cd /d "%~dp0"

echo.
echo ================================================
echo   STARTING FLUTTER APPLICATION
echo ================================================
echo.

REM Check if in correct directory
if not exist "pubspec.yaml" (
    color 0C
    echo [ERROR] Not in Flutter project directory!
    echo Current: %CD%
    echo.
    pause
    exit /b 1
)

echo [1] Checking Flutter installation...
flutter --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo.
    echo [ERROR] Flutter not found! Please install Flutter first.
    pause
    exit /b 1
)
echo [OK] Flutter found

echo.
echo [2] Getting Flutter dependencies...
flutter pub get

echo.
echo [3] Starting Flutter application...
echo.
echo ================================================
echo   Choose Platform:
echo ================================================
echo   1. Windows Desktop (Recommended)
echo   2. Android Emulator
echo   3. Chrome Web
echo   4. Auto-detect
echo ================================================
echo.
set /p choice="Enter your choice (default: 1): "

if "%choice%"=="" set choice=1

if "%choice%"=="1" (
    echo.
    echo Starting Flutter on Windows Desktop...
    flutter run -d windows
) else if "%choice%"=="2" (
    echo.
    echo Starting Flutter on Android Emulator...
    flutter run -d android
) else if "%choice%"=="3" (
    echo.
    echo Starting Flutter on Chrome...
    flutter run -d chrome
) else (
    echo.
    echo Auto-detecting device...
    flutter run
)

echo.
pause
