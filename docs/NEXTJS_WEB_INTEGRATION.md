# Next.js Web Integration Guide

Complete guide for integrating the Next.js web application with the Flutter mobile app.

## 📋 Table of Contents
1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Configuration](#configuration)
5. [Running the App](#running-the-app)
6. [Architecture](#architecture)
7. [Features](#features)
8. [Deployment](#deployment)

## 🎯 Overview

The Next.js web application provides a browser-based interface for the AudiraNET ISP management system. It shares the same Firebase backend as the Flutter mobile app, ensuring data synchronization across platforms.

### Key Features:
- ✅ **Shared Firebase Backend**: Same authentication, Firestore, and storage
- ✅ **Role-Based Access**: Admin, Customer, Teknisi dashboards
- ✅ **Real-Time Sync**: Changes reflect instantly across web and mobile
- ✅ **Responsive Design**: Works on desktop, tablet, and mobile browsers
- ✅ **TypeScript**: Type-safe development
- ✅ **Modern Stack**: Next.js 14 + App Router + Tailwind CSS

## 📦 Prerequisites

Before starting, ensure you have:
- **Node.js**: v18.x or later
- **npm**: v9.x or later
- **Firebase Project**: `audiranet-d4f68` (already configured)
- **Firebase CLI**: `npm install -g firebase-tools`

Check versions:
```bash
node --version  # Should be v18+ 
npm --version   # Should be v9+
firebase --version
```

## 🚀 Installation

### Step 1: Navigate to Web Folder
```bash
cd f:\AUDIRANET\audiranet-web
```

### Step 2: Install Dependencies
```bash
npm install
```

This installs:
- Next.js 14 (framework)
- React 18 (UI library)
- Firebase SDK (auth + Firestore)
- Tailwind CSS (styling)
- TypeScript (type safety)
- date-fns (date formatting)

Installation should take 2-3 minutes.

## ⚙️ Configuration

### Step 3: Create Environment File

Copy the example file:
```bash
cp .env.local.example .env.local
```

### Step 4: Add Firebase Credentials

Open `.env.local` and fill in these values:

```env
# Firebase Client Configuration (Public)
NEXT_PUBLIC_FB_API_KEY=AIzaSy...your_api_key
NEXT_PUBLIC_FB_AUTH_DOMAIN=audiranet-d4f68.firebaseapp.com
NEXT_PUBLIC_FB_PROJECT_ID=audiranet-d4f68
NEXT_PUBLIC_FB_STORAGE_BUCKET=audiranet-d4f68.appspot.com
NEXT_PUBLIC_FB_MSG_SENDER_ID=123456789
NEXT_PUBLIC_FB_APP_ID=1:123456789:web:abcdef

# Firebase Admin SDK (Optional - for server-side operations)
FB_ADMIN_PROJECT_ID=audiranet-d4f68
FB_ADMIN_CLIENT_EMAIL=firebase-adminsdk@audiranet-d4f68.iam.gserviceaccount.com
FB_ADMIN_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

**Where to find these values:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project `audiranet-d4f68`
3. Go to **Project Settings** ⚙️ > **General**
4. Scroll to "Your apps" section
5. Click on the web app (or create one if it doesn't exist)
6. Copy the config values

### Step 5: Verify Configuration

Check if Firebase is properly configured:
```bash
npm run dev
```

Open http://localhost:3000

If you see the login page, configuration is correct! ✅

## 🏃 Running the App

### Development Mode
```bash
npm run dev
```
- Opens on http://localhost:3000
- Hot reload enabled (changes appear instantly)
- Console shows errors and warnings

### Production Build
```bash
npm run build
npm run start
```
- Optimized for performance
- Opens on http://localhost:3000

### Linting
```bash
npm run lint
```

## 🏗️ Architecture

### Folder Structure

```
audiranet-web/
├── app/                          # Next.js App Router
│   ├── layout.tsx               # Root layout
│   ├── page.tsx                 # Home (redirects to dashboard)
│   ├── auth/
│   │   ├── login/page.tsx       # Login page
│   │   └── logout/route.ts      # Logout API route
│   ├── dashboard/
│   │   ├── customer/page.tsx    # Customer dashboard
│   │   ├── admin/page.tsx       # Admin dashboard
│   │   └── teknisi/page.tsx     # Teknisi dashboard
│   ├── payments/page.tsx        # Payment history
│   ├── upgrades/page.tsx        # Package upgrades
│   ├── tickets/page.tsx         # Support tickets
│   ├── wifi/page.tsx            # WiFi management
│   └── api/health/route.ts      # Health check endpoint
├── components/
│   └── auth/AuthGuard.tsx       # Role-based access control
├── hooks/
│   └── useAuth.ts               # Authentication hook
├── lib/
│   └── firebase/
│       └── client.ts            # Firebase initialization
├── styles/
│   └── globals.css              # Global styles + Tailwind
├── .env.local                   # Environment variables (not in git)
├── package.json                 # Dependencies
├── tsconfig.json                # TypeScript config
├── tailwind.config.js           # Tailwind CSS config
└── next.config.js               # Next.js config
```

### Data Flow

```
┌─────────────────────┐
│  Next.js Web App    │
│  (Browser)          │
└──────┬──────────────┘
       │
       │ Firebase SDK
       │ (Auth + Firestore)
       │
       ▼
┌─────────────────────┐
│  Firebase Backend   │
│  audiranet-d4f68    │
│  ├── Authentication │
│  ├── Firestore DB   │
│  └── Storage        │
└──────┬──────────────┘
       │
       │ Real-time Sync
       │
       ▼
┌─────────────────────┐
│  Flutter Mobile App │
│  (Android/iOS)      │
└─────────────────────┘
```

### Authentication Flow

1. User enters email + password on `/auth/login`
2. `signInWithEmailAndPassword()` called
3. Firebase verifies credentials
4. ID token retrieved with custom claims (role)
5. User redirected to appropriate dashboard:
   - `admin` → `/dashboard/admin`
   - `customer` → `/dashboard/customer`
   - `teknisi` → `/dashboard/teknisi`
6. `AuthGuard` component protects routes
7. `useAuth()` hook provides user state

### Real-Time Data Sync

All pages use Firestore `onSnapshot()` listeners:

```typescript
// Example: Real-time payments
useEffect(() => {
  const q = query(
    collection(db, 'payments'),
    where('customerId', '==', user.uid),
    orderBy('createdAt', 'desc')
  );

  const unsubscribe = onSnapshot(q, (snapshot) => {
    const data = snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data()
    }));
    setPayments(data);
  });

  return () => unsubscribe();
}, [user]);
```

Changes made in Flutter app appear instantly in web, and vice versa.

## 🎨 Features

### 1. Customer Dashboard (`/dashboard/customer`)
**Features:**
- View payment history (last 5 transactions)
- Quick actions: Payments, WiFi, Tickets
- Real-time updates from Firestore
- Logout functionality

**Data Sources:**
- `payments` collection (filtered by `customerId`)
- Real-time listener with `onSnapshot()`

### 2. Admin Dashboard (`/dashboard/admin`)
**Features:**
- Total revenue calculation
- Pending payments count
- Customer & teknisi statistics
- Quick actions: Manage payments, tickets, upgrades

**Data Sources:**
- `payments` collection (all records)
- `users` collection (filtered by role)
- Real-time aggregation

### 3. Teknisi Dashboard (`/dashboard/teknisi`)
**Features:**
- Assigned tickets list
- Ticket status tracking
- Active tickets counter
- Real-time ticket updates

**Data Sources:**
- `tickets` collection (filtered by `assignedTo`)
- Real-time listener

### 4. WiFi Management (`/wifi`)
**Features:**
- View current SSID & password
- Update network credentials
- Change security type (WPA2/WPA3)
- Select band (2.4GHz/5GHz/Dual)
- Show/hide password toggle

**Data Sources:**
- `wifi_configs/{userId}` document
- `updateDoc()` for changes

### 5. Payments (`/payments`)
**Features:**
- Full payment history table
- Filter by status (paid/pending/overdue)
- Date, amount, method columns
- Role-based view (admin sees all, customer sees own)

**Data Sources:**
- `payments` collection
- Ordered by `createdAt DESC`

### 6. Tickets (`/tickets`)
**Features:**
- Support ticket listing
- Status badges (open/in_progress/resolved)
- Priority & category display
- Create new ticket button (customer only)

**Data Sources:**
- `tickets` collection
- Role-based filtering

### 7. Upgrades (`/upgrades`)
**Features:**
- Package upgrade request history
- Current → New package display
- Status tracking (pending/approved/rejected)
- Request upgrade button (customer only)

**Data Sources:**
- `package_upgrade_requests` collection
- Ordered by `requestedAt DESC`

## 🚢 Deployment

### Option 1: Vercel (Recommended)

1. **Install Vercel CLI:**
```bash
npm install -g vercel
```

2. **Login:**
```bash
vercel login
```

3. **Deploy:**
```bash
cd f:\AUDIRANET\audiranet-web
vercel
```

4. **Add Environment Variables in Vercel Dashboard:**
- Go to Vercel project settings
- Add all `NEXT_PUBLIC_*` variables
- Redeploy

5. **Access:**
- Your app will be live at `https://audiranet-web.vercel.app`

### Option 2: Firebase Hosting

1. **Build the app:**
```bash
npm run build
```

2. **Initialize Firebase Hosting:**
```bash
firebase init hosting
```
- Select `audiranet-d4f68` project
- Public directory: `out`
- Configure as single-page app: Yes
- Set up automatic builds: No

3. **Update `next.config.js`:**
```javascript
const nextConfig = {
  output: 'export',  // Enable static export
  images: {
    unoptimized: true,
  },
}
```

4. **Rebuild and deploy:**
```bash
npm run build
firebase deploy --only hosting
```

5. **Access:**
- Your app will be live at `https://audiranet-d4f68.web.app`

### Option 3: Custom Server

1. **Build:**
```bash
npm run build
```

2. **Copy files to server:**
```bash
scp -r .next package.json package-lock.json user@server:/var/www/audiranet-web/
```

3. **On server, install and run:**
```bash
cd /var/www/audiranet-web
npm install --production
npm run start
```

4. **Set up Nginx reverse proxy:**
```nginx
server {
    listen 80;
    server_name audiranet.com;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## 🔧 Troubleshooting

### Issue: "Firebase not initialized"
**Solution:**
1. Check `.env.local` exists
2. Verify all `NEXT_PUBLIC_*` variables are set
3. Restart dev server: `npm run dev`

### Issue: "Permission denied" errors
**Solution:**
1. Check Firestore security rules in Firebase Console
2. Verify user has correct role claim
3. Ensure user is authenticated

### Issue: Build errors
**Solution:**
```bash
rm -rf .next node_modules
npm install
npm run build
```

### Issue: Data not syncing
**Solution:**
1. Check Firestore indexes are deployed
2. Verify collection names match Flutter app
3. Check browser console for errors

## 📚 Additional Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Firebase Web SDK](https://firebase.google.com/docs/web/setup)
- [Tailwind CSS](https://tailwindcss.com/docs)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)

## 🤝 Integration with Flutter

### Shared Firebase Resources:
- **Project**: `audiranet-d4f68`
- **Authentication**: Same user pool with custom claims
- **Firestore**: Same collections and documents
- **Storage**: Same storage bucket (if needed)
- **Security Rules**: Shared rules for both platforms

### Collections Used:
- `users` - User profiles
- `payments` - Payment records
- `tickets` - Support tickets
- `wifi_configs` - WiFi configurations
- `package_upgrade_requests` - Upgrade requests
- `work_schedules` - Teknisi schedules
- `inventory_items` - Equipment inventory
- `points_transactions` - Loyalty points
- `rewards` - Reward catalog

### Data Consistency:
Changes made in either platform are **instantly reflected** in the other due to Firestore real-time listeners (`onSnapshot()`).

**Example:**
1. Admin approves payment in web app → Customer sees updated status in mobile app
2. Customer updates WiFi password in mobile app → Web app shows new password immediately
3. Teknisi marks ticket as resolved in mobile app → Admin dashboard updates in real-time

## ✅ Testing

### Login Test Accounts:

```
Admin:
  Email: admin@audiranet.com
  Password: password123
  Access: Full system access

Customer:
  Email: customer1@example.com
  Password: password123
  Access: Personal data only

Teknisi:
  Email: teknisi1@example.com
  Password: password123
  Access: Assigned tickets only
```

### Test Checklist:
- [ ] Login with each role
- [ ] Verify dashboard loads correctly
- [ ] Check payment history displays
- [ ] Test WiFi configuration update
- [ ] Create and view support ticket
- [ ] Test real-time sync (open web + mobile simultaneously)
- [ ] Verify logout functionality
- [ ] Test responsive layout on mobile browser

## 📞 Support

For issues or questions:
1. Check [Troubleshooting](#troubleshooting) section
2. Review Firebase Console logs
3. Check browser console for errors
4. Verify Firestore indexes are deployed

---

**Version**: 1.0.0  
**Last Updated**: 2024  
**Status**: ✅ Production Ready
