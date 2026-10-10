@echo off
echo ========================================
echo    AUDIRANET - Stop All Services
echo ========================================
echo.

echo [INFO] Menghentikan semua Node.js processes...
taskkill /F /IM node.exe >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Node.js processes dihentikan
) else (
    echo [INFO] Tidak ada Node.js process yang berjalan
)

echo.
echo [INFO] Menghentikan semua Flutter processes...
taskkill /F /IM flutter.exe >nul 2>nul
taskkill /F /IM dart.exe >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Flutter processes dihentikan
) else (
    echo [INFO] Tidak ada Flutter process yang berjalan
)

echo.
echo ========================================
echo    Semua Services Dihentikan
echo ========================================
echo.
pause
