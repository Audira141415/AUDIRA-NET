# 🔥 SETUP FIREBASE - Audira App

## ✅ YANG SUDAH DIKERJAKAN

### 1. Firebase Dependencies (SELESAI ✅)
```yaml
firebase_core: ^3.8.1
cloud_firestore: ^5.5.1
firebase_auth: ^5.3.3
```

### 2. Services Migration (SELESAI ✅)
- ✅ `FirebaseService` - Complete dengan semua CRUD operations
- ✅ `AuthService` - Menggunakan Firebase Authentication
- ✅ `AlertCenterService` - Updated untuk Firestore queries
- ✅ Semua screens updated (customer_home, teknisi_home, dll)

### 3. Android Configuration (SELESAI ✅)
- ✅ `android/build.gradle.kts` - Google Services plugin added
- ✅ `android/app/build.gradle.kts` - Plugin applied
- ✅ `android/app/google-services.json` - Placeholder created

### 4. Main.dart (SELESAI ✅)
```dart
await Firebase.initializeApp();
```

## 🚀 LANGKAH YANG HARUS ANDA LAKUKAN

### STEP 1: Buat Firebase Project

1. **Buka Firebase Console**
   - Go to: https://console.firebase.google.com/
   - Klik "Add project" atau "Create a project"

2. **Setup Project**
   - Project name: `audiranet` (atau nama pilihan Anda)
   - Google Analytics: Optional (boleh enable atau disable)
   - Klik "Create project"
   - Tunggu sampai project ready

### STEP 2: Add Android App ke Firebase

1. **Di Firebase Console**:
   - Klik ⚙️ (Settings) > Project Settings
   - Scroll ke bawah, pilih tab "Your apps"
   - Klik icon **Android** (robot hijau)

2. **Register App**:
   ```
   Android package name: com.example.audira_app
   App nickname (optional): Audira App
   Debug signing certificate SHA-1: (skip untuk development)
   ```
   - Klik "Register app"

3. **Download google-services.json**:
   - Setelah register, akan muncul tombol "Download google-services.json"
   - **DOWNLOAD file ini**
   - **REPLACE** file di: `android/app/google-services.json`
   - ⚠️ **SANGAT PENTING**: File placeholder harus diganti dengan file asli!

4. **Continue**:
   - Klik "Next" pada step "Add Firebase SDK" (sudah dikerjakan)
   - Klik "Next" lagi
   - Klik "Continue to console"

### STEP 3: Enable Firestore Database

1. **Di Firebase Console**:
   - Klik menu "Build" > "Firestore Database"
   - Klik "Create database"

2. **Setup Firestore**:
   - **Location**: Pilih `asia-southeast1` (Singapore - terdekat Indonesia)
   - **Security rules**: Start in **test mode**
   - Klik "Enable"

3. **Security Rules** (Default - Test Mode):
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true; // TEST MODE
       }
     }
   }
   ```
   
   ⚠️ **UNTUK PRODUCTION**, ganti dengan:
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

### STEP 4: Enable Firebase Authentication

1. **Di Firebase Console**:
   - Klik menu "Build" > "Authentication"
   - Klik "Get started"

2. **Enable Email/Password**:
   - Tab "Sign-in method"
   - Klik "Email/Password"
   - **Enable** toggle ON
   - Klik "Save"

### STEP 5: Create Users di Firebase Authentication

1. **Di Firebase Console > Authentication > Users**:
   - Klik "Add user"

2. **Buat 3 users**:
   
   **Admin:**
   ```
   Email: admin@audiranet.com
   Password: admin123
   ```
   
   **Teknisi:**
   ```
   Email: teknisi@audiranet.com
   Password: teknisi123
   ```
   
   **Customer:**
   ```
   Email: customer@example.com
   Password: customer123
   ```

3. **CATAT UID** dari setiap user (akan dibutuhkan untuk Step 6)

### STEP 6: Populate Firestore dengan Data

1. **Di Firebase Console > Firestore Database**:
   - Klik "Start collection"

#### Collection: `users`

**Document 1** (gunakan UID dari admin@audiranet.com):
```json
{
  "email": "admin@audiranet.com",
  "name": "Admin Audira",
  "phone": "081234567890",
  "role": "admin",
  "createdAt": [current timestamp]
}
```

**Document 2** (gunakan UID dari teknisi@audiranet.com):
```json
{
  "email": "teknisi@audiranet.com",
  "name": "Teknisi Support",
  "phone": "081345678901",
  "role": "teknisi",
  "createdAt": [current timestamp]
}
```

**Document 3** (gunakan UID dari customer@example.com):
```json
{
  "email": "customer@example.com",
  "name": "John Doe",
  "phone": "081456789012",
  "role": "customer",
  "createdAt": [current timestamp]
}
```

#### Collection: `customers`

**Document 1**:
```json
{
  "userId": "[UID customer dari Firebase Auth]",
  "customerId": "ADN-2025-001",
  "internetNumber": "INT-2025-001",
  "address": "Jl. Sudirman No. 123, Jakarta Pusat",
  "packageName": "100 Mbps - Unlimited",
  "speed": 100,
  "price": 500000,
  "status": "active",
  "installDate": [timestamp untuk 2025-01-15],
  "createdAt": [current timestamp]
}
```

#### Collection: `bills`

**Document 1** (Unpaid Bill):
```json
{
  "customerId": "[document ID dari customer di atas]",
  "billMonth": "November 2025",
  "amount": 500000,
  "dueDate": [timestamp untuk 2025-11-30],
  "status": "unpaid",
  "createdAt": [current timestamp]
}
```

**Document 2** (Paid Bill):
```json
{
  "customerId": "[document ID dari customer di atas]",
  "billMonth": "Oktober 2025",
  "amount": 500000,
  "dueDate": [timestamp untuk 2025-10-31],
  "status": "paid",
  "paidDate": [timestamp untuk 2025-10-25],
  "createdAt": [timestamp 30 hari lalu]
}
```

### STEP 7: Test Application

1. **Clean Build**:
   ```powershell
   flutter clean
   flutter pub get
   ```

2. **Verify google-services.json**:
   - Check file `android/app/google-services.json`
   - Harus berisi konfigurasi asli dari Firebase (bukan placeholder)

3. **Run App**:
   ```powershell
   flutter run
   ```

4. **Test Login**:
   - Login sebagai Customer: customer@example.com / customer123
   - Login sebagai Teknisi: teknisi@audiranet.com / teknisi123
   - Login sebagai Admin: admin@audiranet.com / admin123

## 🔍 TROUBLESHOOTING

### Error: "FirebaseApp not initialized"
**Solusi**: google-services.json belum diganti dengan file asli dari Firebase Console

### Error: "No matching client found for package name"
**Solusi**: Package name di Firebase Console harus `com.example.audira_app`

### Error: "Firebase project not found"
**Solusi**: google-services.json dari project Firebase yang salah

### Login gagal terus
**Solusi**: 
1. Pastikan users sudah dibuat di Firebase Authentication
2. Pastikan users collection di Firestore punya document dengan UID yang sama
3. Cek email/password yang diinput

### Data tidak muncul
**Solusi**:
1. Cek Firestore security rules (test mode: allow read, write: if true)
2. Pastikan collections sudah dibuat (users, customers, bills)
3. Cek Firebase Console > Firestore Database untuk verify data ada

## 📊 STRUKTUR FIRESTORE

```
firestore
├── users (collection)
│   ├── {uid} (document)
│   │   ├── email: string
│   │   ├── name: string
│   │   ├── phone: string
│   │   ├── role: string (admin/teknisi/customer)
│   │   └── createdAt: timestamp
│
├── customers (collection)
│   ├── {customerId} (document)
│   │   ├── userId: string
│   │   ├── customerId: string
│   │   ├── address: string
│   │   ├── packageName: string
│   │   ├── speed: number
│   │   ├── price: number
│   │   ├── status: string
│   │   └── createdAt: timestamp
│
├── bills (collection)
│   ├── {billId} (document)
│   │   ├── customerId: string
│   │   ├── billMonth: string
│   │   ├── amount: number
│   │   ├── dueDate: timestamp
│   │   ├── status: string (paid/unpaid)
│   │   └── createdAt: timestamp
│
├── tickets (collection)
├── payments (collection)
├── installations (collection)
├── checkins (collection)
├── rewards (collection)
├── maintenance_schedules (collection)
└── bandwidth_usage (collection)
```

## ⚡ QUICK CHECKLIST

- [ ] Firebase project created
- [ ] Android app registered di Firebase
- [ ] google-services.json downloaded dan replace placeholder
- [ ] Firestore Database enabled (asia-southeast1)
- [ ] Firebase Authentication enabled (Email/Password)
- [ ] 3 users created di Authentication
- [ ] users collection populated dengan 3 documents
- [ ] customers collection created dengan 1 customer
- [ ] bills collection created dengan 2 bills
- [ ] Security rules set to test mode
- [ ] flutter clean && flutter pub get
- [ ] flutter run berhasil
- [ ] Login test berhasil

## 🎯 NEXT STEPS AFTER SETUP

1. **Populate More Data**: Tambahkan lebih banyak customers, bills, tickets
2. **Test All Features**: Test semua fitur (tickets, installations, payments)
3. **Production Security Rules**: Update Firestore rules sebelum production
4. **Backup Strategy**: Setup Firebase backup/export
5. **Monitoring**: Enable Firebase Analytics & Crashlytics

---

**📧 Butuh Bantuan?**
- Firebase Documentation: https://firebase.google.com/docs
- Flutter Firebase: https://firebase.flutter.dev/

**CATATAN PENTING:**
- App TIDAK AKAN JALAN sampai `google-services.json` asli ditambahkan
- Test mode security rules = siapa saja bisa akses data (JANGAN di production!)
- UID di Firebase Auth HARUS MATCH dengan userId di Firestore collections
