@echo off
setlocal enabledelayedexpansion

title AUDIRA-NET - Git Auto Save and Push
cd /d "%~dp0"

echo ===================================================
echo     AUDIRA-NET - GIT AUTO COMMIT AND PUSH TO GITHUB
echo ===================================================
echo Target Remote : https://github.com/Audira141415/AUDIRA-NET.git
echo Working Dir   : %cd%
echo ===================================================

REM Check git
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git tidak ditemukan di PATH sistem. Mohon instal Git terlebih dahulu.
    exit /b 1
)

REM Initialize git if needed
if not exist ".git" (
    echo [INFO] Inisialisasi Git repository baru di AUDIRA-NET...
    git init
    if %errorlevel% neq 0 (
        echo [ERROR] Gagal inisialisasi git repository.
        exit /b 1
    )
)

REM Configure remote origin
set REPO_URL=https://github.com/Audira141415/AUDIRA-NET.git
git remote get-url origin >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Menambahkan remote origin: %REPO_URL%
    git remote add origin %REPO_URL%
) else (
    echo [INFO] Memperbarui remote origin ke: %REPO_URL%
    git remote set-url origin %REPO_URL%
)

REM Set default branch to main
git branch -M main

REM Determine commit message
set "COMMIT_MSG=%~1"
if "%COMMIT_MSG%"=="" (
    set "COMMIT_MSG=Update AUDIRA-NET: %date% %time%"
)

echo.
echo [1/4] Staging file (git add) ...
git add .

echo.
echo [2/4] Commit perubahan ...
git commit -m "%COMMIT_MSG%"

echo.
echo [3/4] Menghubungkan cabang main ke remote ...
git branch -M main

echo.
echo [4/4] Push ke GitHub (origin main) ...
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ===================================================
    echo  [SUKSES] Berhasil menyimpan dan push ke GitHub!
    echo  Repositori: %REPO_URL%
    echo ===================================================
) else (
    echo.
    echo ===================================================
    echo  [GAGAL] Push ke GitHub mengalami kendala.
    echo  Pastikan kredensial GitHub Anda valid dan memiliki hak akses ke repo.
    echo ===================================================
)

echo.
