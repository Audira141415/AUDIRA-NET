@echo off
setlocal enabledelayedexpansion

title AUDIRA-NET - Git Auto Save and Push
cd /d "%~dp0"

echo ===================================================
echo     AUDIRA-NET - GIT AUTO COMMIT & PUSH TO GITHUB
echo ===================================================
echo Target Remote : https://github.com/Audira141415/AUDIRA-NET.git
echo Working Dir   : %cd%
echo ===================================================

:: Check if git is installed
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git tidak ditemukan di PATH sistem. Mohon instal Git terlebih dahulu.
    exit /b 1
)

:: Initialize git repository if not already initialized
if not exist ".git" (
    echo [INFO] Inisialisasi Git repository baru di AUDIRA-NET...
    git init
    if %errorlevel% neq 0 (
        echo [ERROR] Gagal inisialisasi git repository.
        exit /b 1
    )
)

:: Set/Update Remote Origin
set REPO_URL=https://github.com/Audira141415/AUDIRA-NET.git
git remote get-url origin >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Menambahkan remote origin: %REPO_URL%
    git remote add origin %REPO_URL%
) else (
    echo [INFO] Memperbarui remote origin ke: %REPO_URL%
    git remote set-url origin %REPO_URL%
)

:: Set default branch to main
git branch -M main

:: Determine Commit Message
set "COMMIT_MSG=%~1"
if "%COMMIT_MSG%"=="" (
    set "COMMIT_MSG=Update AUDIRA-NET: %date% %time%"
)

echo.
echo [1/4] Menyiapkan dan menambahkan perubahan (git add) ...
git add .

echo.
echo [2/4] Melakukan commit dengan pesan: "%COMMIT_MSG%" ...
git commit -m "%COMMIT_MSG%"

echo.
echo [3/4] Menghubungkan ke GitHub dan sinkronisasi cabang 'main' ...
git ls-remote --exit-code origin main >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Mengambil pembaruan terbaru dari remote (pull --rebase) ...
    git pull origin main --rebase
)

echo.
echo [4/4] Melakukan push ke origin main ...
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
