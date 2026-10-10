# 🔐 Unified Login Implementation Guide

## 📋 Overview

Aplikasi AUDIRANET telah diupgrade dengan **Single Login Form** yang menggunakan **Auto-Detection Role**. Tidak perlu lagi memilih role sebelum login - sistem akan otomatis mendeteksi role dari database setelah user berhasil login.

---

## ✅ What Changed

### Before (Old Flow)
```
Splash Screen
    ↓
Role Selection Page (Choose: Customer/Admin/Teknisi)
    ↓
Login Page (Specific to selected role)
    ↓
Dashboard (Based on role)
```

### After (New Flow) ⭐
```
Splash Screen
    ↓
Unified Login Page (Single form for all roles)
    ↓
Auto-detect role from Firestore
    ↓
Dashboard (Customer/Admin/Teknisi based on detected role)
```

---

## 🆕 New Files Created

### 1. `lib/screens/auth/unified_login_page.dart`
**Single login form with auto-detection role**

**Key Features:**
- ✅ Modern glassmorphism UI
- ✅ Email & password validation
- ✅ Auto-detect role from Firestore
- ✅ Auto-route to appropriate dashboard
- ✅ Forgot password functionality
- ✅ Error handling with specific messages
- ✅ Loading states
- ✅ Help dialog

**How it works:**
```dart
1. User enters email & password
2. Authenticate with Firebase Auth
3. Fetch user data from Firestore (includes 'role' field)
4. Auto-detect role: admin/teknisi/customer
5. Navigate to appropriate dashboard:
   - admin → Routes.adminHome
   - teknisi → Routes.teknisiHome
   - customer → Routes.customerHome
```

---

## 🔧 Modified Files

### 1. `lib/services/auth_service.dart`
**Added 2 new methods:**

#### Method 1: `signInWithEmail(String email, String password)`
```dart
/// Simple sign in without role validation
/// Returns User credential if successful
/// Used by unified login for authentication only
Future<auth.User?> signInWithEmail(String email, String password)
```

**Purpose:** Pure authentication without role checking. Returns Firebase User object.

#### Method 2: `setCurrentUserData(Map<String, dynamic> userData)`
```dart
/// Set current user data after successful authentication
/// Stores user info in memory for app-wide access
Future<void> setCurrentUserData(Map<String, dynamic> userData)
```

**Purpose:** Store authenticated user data in AuthService singleton.

### 2. `lib/config/routes.dart`
**Updated routes:**

```dart
// NEW: Unified login as default
static const String unifiedLogin = '/';

// OLD: Role selection (kept for fallback)
static const String roleSelection = '/role-selection';
```

**Added route handler:**
```dart
case Routes.unifiedLogin:
  return MaterialPageRoute(builder: (_) => const UnifiedLoginPage());
```

### 3. `lib/main.dart`
**Changed initial route:**

```dart
// Before
initialRoute: Routes.roleSelection,

// After
initialRoute: Routes.unifiedLogin, // NEW: Single login page
```

---

## 🎯 How to Use

### For End Users

#### Customer Login
```
1. Open app
2. Enter email: customer@example.com
3. Enter password: ******
4. Click "LOGIN"
5. → Automatically routed to Customer Dashboard
```

#### Admin Login
```
1. Open app
2. Enter email: admin@audiranet.com
3. Enter password: ******
4. Click "LOGIN"
5. → Automatically routed to Admin Dashboard
```

#### Teknisi Login
```
1. Open app
2. Enter email: teknisi@audiranet.com
3. Enter password: ******
4. Click "LOGIN"
5. → Automatically routed to Teknisi Dashboard
```

### For Developers

#### Test Credentials Setup in Firestore

Ensure your Firestore `users` collection has documents with this structure:

```json
// Customer Example
{
  "id": "user123",
  "name": "John Doe",
  "email": "customer@example.com",
  "phone": "08123456789",
  "role": "customer",  // ← IMPORTANT: Must be lowercase
  "createdAt": Timestamp
}

// Admin Example
{
  "id": "admin001",
  "name": "Admin User",
  "email": "admin@audiranet.com",
  "phone": "08123456789",
  "role": "admin",  // ← Role field determines dashboard
  "createdAt": Timestamp
}

// Teknisi Example
{
  "id": "tek001",
  "name": "Teknisi Budi",
  "email": "teknisi@audiranet.com",
  "phone": "08123456789",
  "role": "teknisi",  // ← Can also be "tech" or "technician"
  "createdAt": Timestamp
}
```

**Role Detection Logic:**
```dart
// In unified_login_page.dart
switch (role) {
  case 'admin':
    Navigate to AdminHomePage
  
  case 'teknisi':
  case 'tech':
  case 'technician':
    Navigate to TeknisiHomePage
  
  case 'customer':
  case 'pelanggan':
  case 'user':
  default:
    Navigate to CustomerHomePage
}
```

---

## 🔒 Security Features

### 1. Role Stored Server-Side
```
✅ Role determined by Firestore data
✅ User CANNOT choose their own role
✅ No client-side role manipulation
```

### 2. Validation Flow
```
1. Firebase Authentication (email/password)
   ↓
2. Fetch user data from Firestore
   ↓
3. Validate role field exists
   ↓
4. Store in AuthService
   ↓
5. Route to appropriate dashboard
```

### 3. Error Handling
```dart
// Specific error messages for common issues
- "No account found with this email"
- "Incorrect password. Please try again"
- "Network error. Please check your connection"
- "User data not found. Please contact administrator"
```

---

## 🧪 Testing Checklist

### Basic Login Tests
- [ ] Customer login works → routes to CustomerHomePage
- [ ] Admin login works → routes to AdminHomePage
- [ ] Teknisi login works → routes to TeknisiHomePage
- [ ] Invalid email shows validation error
- [ ] Invalid password shows error message
- [ ] Empty fields show validation errors

### Role Detection Tests
- [ ] User with role="customer" → Customer dashboard
- [ ] User with role="admin" → Admin dashboard
- [ ] User with role="teknisi" → Teknisi dashboard
- [ ] User with role="tech" → Teknisi dashboard (alias)
- [ ] User with no role → Customer dashboard (default)

### Error Handling Tests
- [ ] Wrong password → shows "Incorrect password" error
- [ ] Non-existent email → shows "No account found" error
- [ ] Network offline → shows "Network error" message
- [ ] User exists in Auth but not Firestore → shows "User data not found"

### UI/UX Tests
- [ ] Loading indicator shows during login
- [ ] Success message shows after login
- [ ] Forgot password dialog works
- [ ] Help dialog displays contact info
- [ ] Remember me checkbox works
- [ ] Form validation works correctly

---

## 🎨 UI Features

### Glassmorphism Design
```dart
✅ Transparent background with blur
✅ Gradient borders
✅ Smooth animations
✅ Modern tech aesthetic
```

### Animated Components
```dart
✅ AnimatedTextField (email & password)
✅ AnimatedLoginButton (with loading state)
✅ TechAnimationBackground (particle effects)
✅ GlassmorphismCard (frosted glass effect)
```

### User Feedback
```dart
✅ SnackBar success message: "Welcome, [Name]!"
✅ Error dialogs with specific messages
✅ Loading spinner during authentication
✅ Info banner: "Your role will be automatically detected"
```

---

## 🔄 Fallback to Old Flow

**Old role selection page still available at:**
```dart
Navigator.pushNamed(context, Routes.roleSelection);
```

**Use case:**
- Testing specific role logins
- Demo purposes
- Troubleshooting

**To revert to old flow:**
```dart
// In main.dart
initialRoute: Routes.roleSelection, // Change back
```

---

## 📊 Database Schema Requirements

### Required Firestore Collections

#### 1. `users` Collection
```
Required fields:
- id (String): Unique user ID
- email (String): User email
- name (String): Full name
- role (String): "customer", "admin", or "teknisi"
- phone (String): Phone number
- createdAt (Timestamp): Registration date

Optional fields:
- company (String): For teknisi/admin
- zone (String): Service area
```

#### 2. `customers` Collection (for customer role)
```
Required fields:
- userId (String): Reference to users.id
- customerId (String): Customer ID (e.g., "ADN-2025-001")
- address (String): Installation address
- packageName (String): Internet package name
- speed (int): Package speed (Mbps)
- monthlyFee (int): Monthly price
- status (String): "active", "inactive", "suspended"
```

---

## 🚀 Next Steps After Implementation

### 1. Test with Real Users
```bash
# Create test accounts in Firebase Console
1. Go to Authentication → Add User
2. Add email/password
3. Go to Firestore → users → Add Document
4. Add user data with role field
5. Test login
```

### 2. Monitor Logs
```dart
// AuthService logs all authentication attempts
// Check console for:
LoggerService.authInfo('🔐 AuthService.signInWithEmail() called');
LoggerService.authInfo('✅ Firebase authentication SUCCESS');
LoggerService.authInfo('✅ Current user data set: [Name] ([Role])');
```

### 3. Handle Edge Cases
- [ ] User changes role in Firestore (should update on next login)
- [ ] User deleted from Firestore but exists in Auth
- [ ] Multiple users with same email (shouldn't happen with Auth)

---

## 💡 Best Practices

### For Admin
```
✅ Always set correct 'role' field in Firestore
✅ Use lowercase for role values: "admin", "customer", "teknisi"
✅ Never delete users from Firestore without deleting from Auth
✅ Always test new users before giving credentials
```

### For Developers
```
✅ Use AuthService.instance.currentUserData to access user info
✅ Check role before showing role-specific features
✅ Handle null userData gracefully
✅ Log authentication events for debugging
```

### For Support Team
```
✅ If user can't login: Check Firestore 'role' field exists
✅ If wrong dashboard: Verify 'role' value is correct
✅ If "User data not found": Check Firestore users collection
```

---

## 📞 Troubleshooting

### Issue 1: Login succeeds but app crashes
**Solution:** Check Firestore user document has all required fields

### Issue 2: Routes to wrong dashboard
**Solution:** Verify 'role' field value in Firestore (must be lowercase)

### Issue 3: "User data not found" error
**Solution:** 
1. Check if user exists in Firestore `users` collection
2. Verify user.id matches Firebase Auth UID
3. Re-create user document if missing

### Issue 4: Forgot password doesn't work
**Solution:** Ensure Firebase Auth email templates are configured

---

## 📚 Related Documentation

- `ROLE_FEATURES_AUDIT.md` - Role-specific features breakdown
- `IMPLEMENTATION_PHASE1.md` - Package Upgrade & Broadcast features
- `IMPLEMENTATION_PHASE2.md` - Analytics & Reporting features
- `FIREBASE_SETUP_GUIDE.md` - Firebase configuration guide

---

## ✅ Summary

### What You Get
✅ **Better UX** - One less screen, faster login
✅ **More Secure** - Role not exposed in UI
✅ **Easier Maintenance** - Single login form
✅ **Professional** - Industry-standard approach
✅ **Scalable** - Easy to add new roles

### Migration Path
1. ✅ Unified login page created
2. ✅ AuthService updated with new methods
3. ✅ Routes configured
4. ✅ Main.dart updated to use unified login
5. ✅ Old role selection kept as fallback
6. ⏳ Test with users
7. ⏳ Remove old flow (optional)

---

**Status:** ✅ Implementation Complete - Ready for Testing

**Next Action:** Test login with all 3 roles (Customer, Admin, Teknisi)

**Estimated Time Saved:** ~2 seconds per login × number of daily logins 🚀
