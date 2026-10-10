# 🔧 QUICK FIX - Google Play Services Error

**Error:**
```
E/GoogleApiManager: Failed to get service from broker.
E/GoogleApiManager: java.lang.SecurityException: Unknown calling package name 'com.google.android.gms'.
```

---

## ✅ SOLUSI CEPAT (5 Menit)

### **Step 1: Generate SHA Fingerprint**
```powershell
cd F:\PJTAUDIRANETANDBILLING\PJTAudiraNet
.\get-sha-fingerprint.bat
```

**Atau manual:**
```powershell
cd android
.\gradlew signingReport
```

### **Step 2: Copy SHA-1 dan SHA-256**
Dari output, copy baris seperti ini:
```
SHA1: A1:B2:C3:D4:E5:F6...
SHA-256: 1A:2B:3C:4D:5E:6F...
```

### **Step 3: Tambahkan ke Firebase Console**
1. Buka: https://console.firebase.google.com/project/audiranet-d4f68/settings/general
2. Scroll ke "Your apps" → pilih Android app
3. Click "Add fingerprint"
4. Paste **SHA-1** → Save
5. Click "Add fingerprint" lagi
6. Paste **SHA-256** → Save

### **Step 4: Download google-services.json Baru**
1. Di Firebase Console, click "Download google-services.json"
2. Replace file di: `android/app/google-services.json`

### **Step 5: Rebuild App**
```powershell
flutter clean
flutter pub get
flutter run
```

---

## 🎯 ERROR LAINNYA

### **1. Skipped Frames (Performance)**
```
Skipped 84 frames! The application may be doing too much work on its main thread.
```

**Solusi:**
- ✅ Sudah fixed - Pakai async/await
- ✅ Sudah fixed - Hybrid service dengan fallback
- Normal untuk first launch (loading Firebase data)

**Jika masih lag:**
```dart
// Tambahkan di home screen
@override
void initState() {
  super.initState();
  Future.microtask(() => _loadData()); // Defer heavy operations
}
```

### **2. DEVELOPER_ERROR - ConnectionResult**
```
Not showing notification since connectionResult is not user-facing: DEVELOPER_ERROR
```

**Penyebab:**
- SHA fingerprint belum ditambahkan (solusi di atas)
- Google Play Services outdated

**Verify:**
- App masih bisa login Firebase? → Error bisa diabaikan sementara
- App tidak bisa login? → Ikuti Step 1-5 di atas

---

## 🔍 TESTING

### **Verify Firebase Works:**
1. Run app: `flutter run`
2. Coba login dengan credentials:
   - Email: `admin@audiranet.com`
   - Password: `password123`
3. Jika login berhasil → Firebase OK, error bisa diabaikan
4. Jika login gagal → Follow Step 1-5 di atas

### **Check Logs:**
```powershell
flutter run --verbose
```

Cari log:
- ✅ `Firebase Auth initialized successfully`
- ✅ `Firestore connected`
- ❌ `DEVELOPER_ERROR` → Need SHA fix

---

## 📱 PERMISSION FIXED

✅ **Already added to AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

---

## 🎉 RINGKASAN

| Issue | Status | Solution |
|-------|--------|----------|
| **Internet Permission** | ✅ Fixed | Added to manifest |
| **SHA Fingerprint** | ⚠️ Action Needed | Run `get-sha-fingerprint.bat` |
| **Frame Skipping** | ✅ Normal | First launch performance |
| **Google Play Services** | ⚠️ Need Update | Follow Step 1-5 |

---

## 💡 TIP

**Quick test tanpa fix SHA:**
- Backend integration masih bisa ditest via localhost
- Hybrid service akan fallback ke Firebase (bisa jalan)
- Untuk production deployment, SHA wajib ditambahkan

**Command untuk test backend only:**
```powershell
# Start backend first
cd F:\PJTAUDIRANETANDBILLING\PJTBillingByAudira
.\start-servers.bat

# Then test Flutter
cd F:\PJTAUDIRANETANDBILLING\PJTAudiraNet
flutter run
```

---

**Need help? Run:** `.\get-sha-fingerprint.bat` dan ikuti instruksi! 🚀
