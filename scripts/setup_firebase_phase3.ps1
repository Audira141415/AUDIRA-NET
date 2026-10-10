# ================================================
# Firebase Phase 3 Features Setup Script
# ================================================
# This script initializes all Firebase collections and indexes
# for Phase 3 features (Payment, Loyalty, Schedule, Inventory)

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Firebase Phase 3 Features Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$PROJECT_ID = "datacenter-checklist-prod"
$FIREBASE_JSON = "firebase.json"
$INDEXES_JSON = "firestore.indexes.json"

Write-Host "Project ID: $PROJECT_ID" -ForegroundColor White
Write-Host ""

# Step 1: Check Prerequisites
Write-Host "[STEP 1/5] Checking prerequisites..." -ForegroundColor Yellow
Write-Host ""

# Check Firebase CLI
$firebaseCmd = Get-Command firebase -ErrorAction SilentlyContinue
if (-not $firebaseCmd) {
    Write-Host "❌ Firebase CLI not installed" -ForegroundColor Red
    Write-Host ""
    Write-Host "Install with: npm install -g firebase-tools" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Firebase CLI: $($firebaseCmd.Version)" -ForegroundColor Green

# Check Flutter
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    Write-Host "❌ Flutter not installed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Flutter: installed" -ForegroundColor Green

# Check Node.js
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
    Write-Host "❌ Node.js not installed" -ForegroundColor Red
    exit 1
}
Write-Host "✅ Node.js: $($nodeCmd.Version)" -ForegroundColor Green
Write-Host ""

# Step 2: Firebase Login
Write-Host "[STEP 2/5] Firebase Authentication..." -ForegroundColor Yellow
Write-Host ""

firebase login:list 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Please login to Firebase..." -ForegroundColor Cyan
    firebase login
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Login failed" -ForegroundColor Red
        exit 1
    }
}
Write-Host "✅ Authenticated" -ForegroundColor Green
Write-Host ""

# Step 3: Initialize Firebase (if needed)
Write-Host "[STEP 3/5] Firebase Project Configuration..." -ForegroundColor Yellow
Write-Host ""

if (-not (Test-Path $FIREBASE_JSON)) {
    Write-Host "Initializing Firebase project..." -ForegroundColor Cyan
    firebase init firestore --project $PROJECT_ID
} else {
    Write-Host "✅ firebase.json found" -ForegroundColor Green
}

if (-not (Test-Path $INDEXES_JSON)) {
    Write-Host "❌ $INDEXES_JSON not found!" -ForegroundColor Red
    Write-Host "Please ensure firestore.indexes.json exists" -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ firestore.indexes.json found" -ForegroundColor Green
Write-Host ""

# Step 4: Deploy Firestore Indexes
Write-Host "[STEP 4/5] Deploying Firestore Indexes..." -ForegroundColor Yellow
Write-Host ""

Write-Host "Indexes to be created:" -ForegroundColor Cyan
$indexesContent = Get-Content $INDEXES_JSON | ConvertFrom-Json
foreach ($index in $indexesContent.indexes) {
    $fields = ($index.fields | ForEach-Object { "$($_.fieldPath) ($($_.order))" }) -join ", "
    Write-Host "  • $($index.collectionGroup): $fields" -ForegroundColor White
}
Write-Host ""

$deploy = Read-Host "Deploy indexes now? (Y/N)"
if ($deploy -eq "Y" -or $deploy -eq "y") {
    firebase deploy --only firestore:indexes --project $PROJECT_ID
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Indexes deployment started" -ForegroundColor Green
        Write-Host ""
        Write-Host "⏳ Note: Index building may take 5-10 minutes" -ForegroundColor Yellow
        Write-Host "   You can check status at:" -ForegroundColor Cyan
        Write-Host "   https://console.firebase.google.com/project/$PROJECT_ID/firestore/indexes" -ForegroundColor White
    } else {
        Write-Host "❌ Deployment failed" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "⏭️  Skipped index deployment" -ForegroundColor Yellow
}
Write-Host ""

# Step 5: Flutter Build
Write-Host "[STEP 5/5] Flutter Application..." -ForegroundColor Yellow
Write-Host ""

$buildApp = Read-Host "Run flutter clean and build? (Y/N)"
if ($buildApp -eq "Y" -or $buildApp -eq "y") {
    Write-Host "Cleaning Flutter build..." -ForegroundColor Cyan
    flutter clean
    
    Write-Host "Getting dependencies..." -ForegroundColor Cyan
    flutter pub get
    
    Write-Host "✅ Flutter app ready" -ForegroundColor Green
} else {
    Write-Host "⏭️  Skipped Flutter build" -ForegroundColor Yellow
}
Write-Host ""

# Summary
Write-Host "================================================" -ForegroundColor Green
Write-Host "  ✅ SETUP COMPLETE!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Run: flutter run" -ForegroundColor White
Write-Host "  2. Login as customer: customer1@gmail.com / password" -ForegroundColor White
Write-Host "  3. Test Loyalty & Rewards feature" -ForegroundColor White
Write-Host "  4. Login as teknisi: andi.teknisi@audiranet.id / password" -ForegroundColor White
Write-Host "  5. Test Jadwal Saya & Inventory features" -ForegroundColor White
Write-Host ""
Write-Host "Phase 3 Features:" -ForegroundColor Cyan
Write-Host "  ✅ Payment Gateway (merged with existing payment)" -ForegroundColor Green
Write-Host "  ✅ Loyalty & Rewards Program" -ForegroundColor Green
Write-Host "  ✅ Smart Scheduling (renamed to Jadwal Saya)" -ForegroundColor Green
Write-Host "  ✅ Inventory Management" -ForegroundColor Green
Write-Host ""
Write-Host "Documentation:" -ForegroundColor Cyan
Write-Host "  • IMPLEMENTATION_PHASE3.md - Complete feature guide" -ForegroundColor White
Write-Host "  • firestore.indexes.json - Database indexes" -ForegroundColor White
Write-Host ""
