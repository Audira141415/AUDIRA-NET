# 🌐 WEB INTEGRATION GUIDE

**Status**: ✅ Integrasi Backend - Flutter Web Ready  
**Platform**: Next.js Web + Flutter Web + NestJS Backend

---

## 📋 Overview

Aplikasi AudiraNet mendukung 2 jenis web interface:

### 1️⃣ Next.js Admin Web (Port 3000)
- **Framework**: Next.js 14 (Pages Router)
- **Backend**: NestJS API (Port 4000)
- **Database**: PostgreSQL
- **Status**: ✅ Production Ready
- **Location**: `D:\PJTBillingByAudira\apps\frontend`

### 2️⃣ Flutter Web (Planned)
- **Framework**: Flutter Web
- **Backend**: Firebase + NestJS API (Hybrid)
- **Status**: 🚧 Ready for deployment
- **Location**: `F:\PJTAUDIRANETANDBILLING\PJTAudiraNet\web`

---

## 🚀 Running Web Applications

### Start Next.js Admin Web
```powershell
cd F:\PJTAUDIRANETANDBILLING\PJTBillingByAudira
.\start-servers.bat
```

Access:
- **Admin Panel**: http://localhost:3000
- **Backend API**: http://localhost:4000

Login credentials:
- Email: `admin@audira.net`
- Password: `admin123`

### Deploy Flutter Web
```powershell
cd F:\PJTAUDIRANETANDBILLING\PJTAudiraNet
flutter build web --release
```

Built files akan ada di: `build/web/`

---

## 🔗 Integration Architecture

```
┌─────────────────────────────────────────────────────┐
│                 WEB INTERFACES                      │
├─────────────────────────────────────────────────────┤
│  Next.js Admin (3000)    │    Flutter Web (8080)    │
│  - Dashboard             │    - Customer Portal     │
│  - Billing Management    │    - Mobile-like UI      │
│  - Analytics             │    - Progressive Web App │
└──────────────┬───────────┴───────────┬──────────────┘
               │                       │
               │   HTTP REST API       │
               └───────────┬───────────┘
                           │
               ┌───────────▼───────────┐
               │   NestJS Backend      │
               │   Port 4000           │
               │   87 API Endpoints    │
               └───────────┬───────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                      │
   ┌────▼────┐                          ┌─────▼─────┐
   │Firebase │                          │PostgreSQL │
   │Firestore│                          │   5433    │
   └─────────┘                          └───────────┘
```

---

## 🔧 Configuration

### Next.js Web Environment
**File**: `D:\PJTBillingByAudira\apps\frontend\.env.local`

```env
NEXT_PUBLIC_API_URL=http://localhost:4000
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your-secret-key
```

### Flutter Web Configuration
**File**: `F:\PJTAUDIRANETANDBILLING\PJTAudiraNet\lib\config\api_config.dart`

```dart
static const String devBaseUrl = 'http://localhost:4000';
static const String prodBaseUrl = 'https://api.audiranet.com';
```

---

## 📱 Flutter Web Deployment Options

### Option 1: Standalone Web Server
```powershell
# Build
flutter build web --release

# Serve with any HTTP server
cd build/web
python -m http.server 8080
```

Access: http://localhost:8080

### Option 2: Firebase Hosting
```powershell
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Deploy
cd F:\PJTAUDIRANETANDBILLING\PJTAudiraNet
flutter build web --release
firebase deploy --only hosting
```

### Option 3: Nginx/Apache
Copy `build/web` folder to web server root

Nginx config:
```nginx
server {
    listen 80;
    server_name audiranet.com;
    root /var/www/audiranet/build/web;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## 🎯 Features Comparison

| Feature | Next.js Admin | Flutter Web |
|---------|--------------|-------------|
| **Target User** | Admin, Staff | Customer, Teknisi |
| **UI Style** | Desktop Dashboard | Mobile-first PWA |
| **Authentication** | Session-based | Firebase Auth |
| **Data Source** | PostgreSQL | Hybrid (Firebase + PostgreSQL) |
| **Real-time** | Polling | Firebase Streams |
| **Offline Support** | ❌ No | ✅ Yes (PWA) |
| **Mobile Optimized** | ⚠️ Responsive | ✅ Native-like |

---

## 🔐 Authentication Flow

### Next.js Admin Web
1. User enters credentials
2. Backend validates via PostgreSQL
3. Session cookie created
4. All requests include session cookie

### Flutter Web
1. User enters credentials
2. Firebase Authentication
3. Get Firebase ID token
4. Send token to backend
5. Backend validates & creates session
6. Hybrid service uses both Firebase + Backend

---

## 🌐 API Integration

Both web apps menggunakan **same Backend API** (Port 4000):

### Shared Endpoints
- `POST /auth/login` - Authentication
- `GET /analytics/dashboard` - Dashboard stats
- `GET /pelanggan` - Get customers
- `GET /invoices` - Get invoices
- `POST /payments` - Create payment
- `GET /analytics/revenue` - Revenue data

### Web-specific Implementation

**Next.js** (TypeScript):
```typescript
const response = await fetch('http://localhost:4000/pelanggan', {
  credentials: 'include',
  headers: {
    'Content-Type': 'application/json',
  },
});
const data = await response.json();
```

**Flutter Web** (Dart):
```dart
import 'package:audira_app/services/backend_api_service.dart';

final response = await BackendApiService.instance.getCustomers(
  page: 1,
  limit: 10,
);
```

---

## 🚀 Quick Start (Full Integration)

Run semua services sekaligus:

```powershell
cd F:\PJTAUDIRANETANDBILLING\PJTAudiraNet
.\start-full-integration.bat
```

This will start:
1. ✅ PostgreSQL Database (Docker)
2. ✅ NestJS Backend (Port 4000)
3. ✅ Next.js Admin Web (Port 3000)
4. ✅ Flutter Desktop App

---

## 🧪 Testing Web Integration

### Test Next.js Web
1. Open http://localhost:3000
2. Login: `admin@audira.net` / `admin123`
3. Navigate Dashboard
4. Check data displays correctly

### Test Flutter Web
1. Build: `flutter build web`
2. Serve: `python -m http.server 8080` (from build/web)
3. Open http://localhost:8080
4. Login with Firebase credentials
5. Navigate to Backend Integration Test
6. Run all tests

---

## 📊 Monitoring & Debugging

### Backend API Logs
Check terminal window "Backend Services"

### Next.js Logs
Check terminal window "Next.js Frontend"

### Flutter Web Logs
Open browser DevTools (F12) → Console

### Health Checks
- Backend: http://localhost:4000/health
- Next.js: http://localhost:3000
- Flutter Web: http://localhost:8080

---

## 🔄 Data Sync Strategy

### Real-time Sync (Flutter Web)
- Uses Firebase real-time listeners
- Automatic UI updates
- Offline queue for writes

### Polling Sync (Next.js)
- Periodic API calls
- Manual refresh option
- No offline support

### Hybrid Approach (Recommended)
Flutter Web app dapat sync data:
1. Write to Backend API (primary)
2. Backup to Firebase (fallback)
3. Listen Firebase for real-time updates

---

## 📚 Related Documentation

- [FLUTTER_BACKEND_INTEGRATION.md](FLUTTER_BACKEND_INTEGRATION.md) - Flutter integration
- [../PJTBillingByAudira/INTEGRASI_SELESAI.md](../../PJTBillingByAudira/INTEGRASI_SELESAI.md) - Backend integration
- [NEXTJS_WEB_INTEGRATION.md](NEXTJS_WEB_INTEGRATION.md) - Next.js web setup (if exists)

---

## ✅ Checklist

- [x] Backend API running
- [x] Next.js Admin Web accessible
- [x] Flutter Web buildable
- [x] API endpoints configured
- [x] Authentication integrated
- [x] CORS enabled for web
- [x] Documentation complete

---

## 🎉 Kesimpulan

**Web integration telah siap!**

✅ **2 Web Interfaces**:
- Next.js Admin (Desktop-first)
- Flutter Web (Mobile-first PWA)

✅ **Unified Backend**:
- Single NestJS API
- Shared PostgreSQL database
- Consistent data across platforms

✅ **Flexible Deployment**:
- Standalone servers
- Firebase Hosting
- Traditional web servers

**Semua platform dapat berkomunikasi seamlessly!** 🌐
