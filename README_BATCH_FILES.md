# 🚀 AUDIRANET - Batch Files Guide

## 📁 File Batch yang Tersedia

### 1. **quick-start.bat** ⭐ RECOMMENDED
Menu interaktif untuk mengelola semua services.

**Fitur:**
- Start Web App Only
- Start Flutter App Only  
- Start All Services
- Stop All Services
- Install/Update Dependencies
- Setup Environment (.env.local)
- Open Browser
- Exit

**Cara Pakai:**
```cmd
quick-start.bat
```
Pilih opsi dari menu (1-8)

---

### 2. **start-all.bat**
Menjalankan semua services sekaligus (Web + Flutter).

**Fitur:**
- ✅ Auto-check Node.js & Flutter
- ✅ Auto-install dependencies jika belum ada
- ✅ Auto-create .env.local jika belum ada
- ✅ Membuka 2 terminal terpisah
- ✅ Auto-open browser

**Cara Pakai:**
```cmd
start-all.bat
```

**Output:**
- Terminal 1: Web App (http://localhost:3001)
- Terminal 2: Flutter App (emulator/device)
- Browser: Auto-open web app

---

### 3. **stop-all.bat**
Menghentikan semua Node.js & Flutter processes.

**Fitur:**
- ✅ Kill semua node.exe
- ✅ Kill semua flutter.exe & dart.exe
- ✅ Clean shutdown

**Cara Pakai:**
```cmd
stop-all.bat
```

---

### 4. **audiranet-web/start-web.bat**
Menjalankan Web App saja (Next.js).

**Fitur:**
- ✅ Check Node.js
- ✅ Auto-install dependencies
- ✅ Check .env.local
- ✅ Start dev server

**Cara Pakai:**
```cmd
cd audiranet-web
start-web.bat
```

---

### 5. **audiranet-web/run.bat**
Menu interaktif untuk Web App.

**Opsi:**
1. Start Development Server
2. Build for Production
3. Install Dependencies
4. Setup Environment
5. Clean Install
6. Open Browser
7. Exit

**Cara Pakai:**
```cmd
cd audiranet-web
run.bat
```

---

## 🎯 Workflow Rekomendasi

### Pertama Kali Setup
```cmd
# 1. Setup environment
quick-start.bat
# Pilih: 6 (Setup Environment)
# Edit .env.local dengan Firebase credentials

# 2. Install dependencies
quick-start.bat
# Pilih: 5 (Install/Update Dependencies)

# 3. Start all services
quick-start.bat
# Pilih: 3 (Start All)
```

### Development Harian
```cmd
# Quick start
quick-start.bat
# Pilih: 3 (Start All)

# Atau langsung
start-all.bat
```

### Stop Services
```cmd
# Via menu
quick-start.bat
# Pilih: 4 (Stop All)

# Atau langsung
stop-all.bat
```

---

## 🔧 Troubleshooting

### Error: Node.js not found
```cmd
# Install Node.js dari:
https://nodejs.org/

# Restart terminal setelah install
```

### Error: Flutter not found
```cmd
# Install Flutter dari:
https://flutter.dev/

# Tambahkan ke PATH:
# C:\flutter\bin
```

### Error: Port 3000 already in use
Web app akan otomatis gunakan port 3001.

### Error: .env.local tidak ada
```cmd
quick-start.bat
# Pilih: 6 (Setup Environment)
# Atau jalankan: audiranet-web\setup-env.bat
```

---

## 📊 Lokasi File

```
F:\AUDIRANET\
├── quick-start.bat         (Menu utama)
├── start-all.bat           (Start semua)
├── stop-all.bat            (Stop semua)
└── audiranet-web\
    ├── start-web.bat       (Start web only)
    ├── run.bat             (Web menu)
    ├── build-web.bat       (Build production)
    ├── install-dependencies.bat
    └── setup-env.bat
```

---

## 🎨 Quick Commands

| Task | Command |
|------|---------|
| Start Everything | `start-all.bat` |
| Start Web Only | `cd audiranet-web && start-web.bat` |
| Stop Everything | `stop-all.bat` |
| Interactive Menu | `quick-start.bat` |
| Web Menu | `cd audiranet-web && run.bat` |
| Open Browser | `start http://localhost:3001` |

---

## ✅ Checklist Sebelum Mulai

- [ ] Node.js terinstall (v18+)
- [ ] Flutter terinstall (optional)
- [ ] Firebase credentials siap
- [ ] .env.local sudah dikonfigurasi
- [ ] Dependencies sudah terinstall
- [ ] Port 3001 tersedia

---

**Developed by**: GitHub Copilot  
**Date**: 2 Desember 2025
