# Firebase Phase 3 Setup Scripts

This directory contains scripts to deploy Firebase Firestore indexes for Phase 3 features.

## Scripts Available

### 1. **deploy_firebase_indexes.ps1** (Recommended for Windows)
Complete deployment script with validation and status checking.

**Usage:**
```powershell
.\deploy_firebase_indexes.ps1
```

**Features:**
- ✅ Checks Firebase CLI installation
- ✅ Validates authentication
- ✅ Shows index summary before deployment
- ✅ Provides status link after deployment

---

### 2. **setup_firebase_phase3.ps1** (Full Setup)
Complete setup script including Flutter build and Firebase configuration.

**Usage:**
```powershell
.\setup_firebase_phase3.ps1
```

**What it does:**
1. Checks prerequisites (Firebase CLI, Flutter, Node.js)
2. Authenticates with Firebase
3. Deploys Firestore indexes
4. Cleans and rebuilds Flutter app
5. Provides testing instructions

---

### 3. **deploy_indexes.sh** (For Linux/Mac)
Quick deployment script for Unix-based systems.

**Usage:**
```bash
chmod +x deploy_indexes.sh
./deploy_indexes.sh
```

---

## Prerequisites

Before running any script, ensure you have:

1. **Firebase CLI** installed:
   ```bash
   npm install -g firebase-tools
   ```

2. **Firebase Authentication**:
   ```bash
   firebase login
   ```

3. **Project Access**: Ensure you have access to `datacenter-checklist-prod`

---

## Firestore Indexes

The following indexes will be created:

### Payment System
- **Collection:** `payments`
- **Fields:** `customerId` (ASC), `createdAt` (DESC)
- **Purpose:** Query customer payment history

### Loyalty Program
- **Collection:** `points_transactions`
- **Fields:** `customerId` (ASC), `createdAt` (DESC)
- **Purpose:** Transaction history for loyalty points

- **Collection:** `rewards`
- **Fields:** `isActive` (ASC), `pointsCost` (ASC)
- **Purpose:** Filter active rewards sorted by cost

### Smart Scheduling
- **Collection:** `work_schedules`
- **Fields:** `teknisiId` (ASC), `date` (ASC)
- **Purpose:** Query teknisi schedules by date

### Inventory Management
- **Collection:** `inventory_items`
- **Fields:** `assignedTo` (ASC), `status` (ASC)
- **Purpose:** Query items by teknisi and status

- **Collection:** `stock_requests`
- **Fields:** `teknisiId` (ASC), `createdAt` (DESC)
- **Purpose:** Request history for teknisi

---

## Manual Deployment

If you prefer manual deployment:

1. Open Firebase Console:
   ```
   https://console.firebase.google.com/project/datacenter-checklist-prod/firestore/indexes
   ```

2. Click "Create Index" for each collection

3. Or use Firebase CLI directly:
   ```bash
   firebase deploy --only firestore:indexes
   ```

---

## Troubleshooting

### "Firebase CLI not found"
```bash
npm install -g firebase-tools
```

### "Not authenticated"
```bash
firebase login --reauth
```

### "Permission denied"
Contact project admin to grant Firestore access

### "Index already exists"
This is normal - Firebase will skip existing indexes

---

## After Deployment

1. Wait 5-10 minutes for indexes to build
2. Check status at Firebase Console
3. Run `flutter run` to test app
4. Test features:
   - Customer: Loyalty & Rewards
   - Teknisi: Jadwal Saya & Inventory

---

## Support

For issues or questions:
1. Check Firebase Console for index status
2. Review error messages in deployment output
3. Verify `firestore.indexes.json` is valid JSON
