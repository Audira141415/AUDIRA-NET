# Firebase Migration Guide - Audira App

## ✅ Langkah yang Sudah Diselesaikan

### 1. Dependencies (COMPLETED)
- ✅ firebase_core: ^3.8.1
- ✅ cloud_firestore: ^5.5.1
- ✅ firebase_auth: ^5.3.3

### 2. Services (COMPLETED)
- ✅ `lib/services/firebase_service.dart` - Created with full CRUD operations
- ✅ `lib/services/auth_service.dart` - Migrated to use Firebase Authentication
- ✅ `lib/main.dart` - Updated to initialize Firebase

## 📋 Langkah Berikutnya

### 3. Setup Firebase Project (REQUIRED)

Anda harus membuat Firebase project dan menambahkan konfigurasi:

#### A. Create Firebase Project
1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik "Add project" atau "Create a project"
3. Nama project: `audiranet` atau nama pilihan Anda
4. Ikuti wizard setup (enable Google Analytics opsional)

#### B. Add Android App
1. Di Firebase Console, klik ⚙️ (Settings) > Project Settings
2. Klik tab "Your apps"
3. Klik ikon Android untuk add Android app
4. **Android package name**: `com.example.audira_app` (check di `android/app/build.gradle.kts`)
5. **App nickname**: Audira App (opsional)
6. **Debug signing certificate SHA-1**: Opsional untuk development
7. Klik "Register app"

#### C. Download google-services.json
1. Setelah register app, download file `google-services.json`
2. **PENTING**: Copy file ini ke folder: `android/app/google-services.json`

#### D. Add Firebase SDK to Android
Edit `android/build.gradle.kts`:
```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

Edit `android/app/build.gradle.kts`:
```kotlin
plugins {
    // ... existing plugins
    id("com.google.gms.google-services")
}
```

#### E. Enable Firestore Database
1. Di Firebase Console, buka "Build" > "Firestore Database"
2. Klik "Create database"
3. Start in **test mode** (untuk development)
4. Pilih location: `asia-southeast1` (Singapura - terdekat)

#### F. Enable Firebase Authentication
1. Di Firebase Console, buka "Build" > "Authentication"
2. Klik "Get started"
3. Tab "Sign-in method"
4. Enable "Email/Password"

#### G. Firestore Security Rules (Test Mode)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // TEST MODE - change later!
    }
  }
}
```

**⚠️ IMPORTANT**: Test mode membolehkan akses tanpa autentikasi. Untuk production, gunakan:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 4. Initialize Demo Data di Firestore

Setelah Firebase setup, Anda perlu populate database dengan data demo. Buat script atau gunakan Firebase Console:

#### Users Collection
```json
{
  "email": "admin@audiranet.com",
  "name": "Admin Audira",
  "phone": "081234567890",
  "role": "admin"
}

{
  "email": "teknisi@audiranet.com",
  "name": "Teknisi Support",
  "phone": "081345678901",
  "role": "teknisi"
}

{
  "email": "customer@example.com",
  "name": "John Doe",
  "phone": "081456789012",
  "role": "customer"
}
```

#### Customers Collection
```json
{
  "userId": "<user_id_from_firebase_auth>",
  "customerId": "ADN-2025-001",
  "internetNumber": "INT-2025-001",
  "address": "Jl. Sudirman No. 123, Jakarta",
  "packageName": "100 Mbps - Unlimited",
  "speed": 100,
  "price": 500000,
  "status": "active",
  "installDate": "2025-01-15"
}
```

### 5. Create Firebase Auth Users

Di Firebase Console > Authentication > Users, tambahkan users dengan password:
- admin@audiranet.com (password: admin123)
- teknisi@audiranet.com (password: teknisi123)
- customer@example.com (password: customer123)

**IMPORTANT**: UID dari Firebase Auth harus match dengan userId di Firestore users collection.

### 6. Update Screens (IN PROGRESS)

Saya sudah membuat `firebase_service.dart` yang memiliki methods yang sama dengan `database_service.dart`, tapi ada beberapa perbedaan:

#### DatabaseService → FirebaseService Migration:

**Before (SQLite):**
```dart
import 'services/database_service.dart';
final bills = await DatabaseService.instance.getBillsByCustomerId(customerId);
```

**After (Firebase):**
```dart
import 'services/firebase_service.dart';
final bills = await FirebaseService.instance.getBillsByCustomerId(customerId);
```

#### Files yang Perlu Diupdate:
- ✅ `lib/services/auth_service.dart` (DONE)
- ✅ `lib/main.dart` (DONE)
- ⏳ `lib/screens/customer/customer_home.dart`
- ⏳ `lib/screens/teknisi/teknisi_home.dart`
- ⏳ `lib/screens/admin/admin_home.dart`
- ⏳ `lib/screens/customer/maintenance_alert_page.dart`
- ⏳ `lib/screens/customer/bandwidth_usage_page.dart`
- ⏳ All other screens that use DatabaseService

## 🔧 Quick Migration Script

Replace all `DatabaseService` with `FirebaseService`:

```powershell
# Find all files using DatabaseService
Get-ChildItem -Path "F:\AUDIRANET\lib" -Recurse -Filter "*.dart" | Select-String -Pattern "DatabaseService" | Select-Object -ExpandProperty Path -Unique

# Replace in each file (example):
$file = "F:\AUDIRANET\lib\screens\customer\customer_home.dart"
(Get-Content $file) -replace "import 'package:audira_app/services/database_service.dart';", "import 'package:audira_app/services/firebase_service.dart';" -replace "DatabaseService\.instance", "FirebaseService.instance" | Set-Content $file
```

## 📊 Migration Checklist

- [x] Add Firebase dependencies to pubspec.yaml
- [x] Create FirebaseService with Firestore operations
- [x] Migrate AuthService to Firebase Auth
- [x] Update main.dart to initialize Firebase
- [ ] Create Firebase project in console
- [ ] Download and add google-services.json
- [ ] Update android/build.gradle.kts
- [ ] Update android/app/build.gradle.kts
- [ ] Enable Firestore Database
- [ ] Enable Firebase Authentication
- [ ] Create Firebase Auth users
- [ ] Populate Firestore with demo data
- [ ] Replace DatabaseService with FirebaseService in all screens
- [ ] Test authentication flow
- [ ] Test data fetching and updates
- [ ] Update Firestore security rules for production

## 🚀 Testing

After migration:
1. `flutter pub get`
2. `flutter clean`
3. `flutter run`
4. Test login with Firebase Auth users
5. Verify data loads from Firestore
6. Test CRUD operations

## ⚠️ Important Notes

1. **Firebase Configuration Required**: App WILL NOT run until you add `google-services.json`
2. **Data Migration**: Your SQLite data will NOT automatically transfer. You need to export and import manually
3. **Offline Support**: Firestore has offline persistence by default, but behavior differs from SQLite
4. **Cost**: Firebase free tier generous, but monitor usage at [Firebase Console](https://console.firebase.google.com/)
5. **Security Rules**: Start with test mode, update to production rules before launching

## 📞 Support

Jika ada error selama migration:
1. Check `google-services.json` di path yang benar
2. Check Firebase Console bahwa Firestore & Auth sudah enabled
3. Check logs: `flutter run --verbose`
4. Common error: "FirebaseApp not initialized" = missing google-services.json
