# ================================================
# Firebase Firestore Indexes Deployment Script
# ================================================
# This script deploys Firestore indexes for Phase 3 features
# Run this after implementing new features that require composite indexes

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Firebase Firestore Indexes Deployment" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if Firebase CLI is installed
Write-Host "[1/4] Checking Firebase CLI..." -ForegroundColor Yellow
$firebaseCmd = Get-Command firebase -ErrorAction SilentlyContinue

if (-not $firebaseCmd) {
    Write-Host "❌ Firebase CLI not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Firebase CLI first:" -ForegroundColor Yellow
    Write-Host "  npm install -g firebase-tools" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host "✅ Firebase CLI found: $($firebaseCmd.Version)" -ForegroundColor Green
Write-Host ""

# Check if user is logged in
Write-Host "[2/4] Checking Firebase authentication..." -ForegroundColor Yellow
$loginStatus = firebase login:list 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not logged in to Firebase!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Logging in..." -ForegroundColor Yellow
    firebase login
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Login failed!" -ForegroundColor Red
        exit 1
    }
}

Write-Host "✅ Authenticated" -ForegroundColor Green
Write-Host ""

# Check if firestore.indexes.json exists
Write-Host "[3/4] Checking firestore.indexes.json..." -ForegroundColor Yellow
if (-not (Test-Path "firestore.indexes.json")) {
    Write-Host "❌ firestore.indexes.json not found!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ File found" -ForegroundColor Green
Write-Host ""

# Deploy indexes
Write-Host "[4/4] Deploying Firestore indexes..." -ForegroundColor Yellow
Write-Host ""
Write-Host "This will create the following indexes:" -ForegroundColor Cyan
Write-Host "  • payments (customerId, createdAt)" -ForegroundColor White
Write-Host "  • points_transactions (customerId, createdAt)" -ForegroundColor White
Write-Host "  • rewards (isActive, pointsCost)" -ForegroundColor White
Write-Host "  • work_schedules (teknisiId, date)" -ForegroundColor White
Write-Host "  • inventory_items (assignedTo, status)" -ForegroundColor White
Write-Host "  • stock_requests (teknisiId, createdAt)" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Continue? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host "❌ Deployment cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
firebase deploy --only firestore:indexes

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Green
    Write-Host "  ✅ DEPLOYMENT SUCCESSFUL!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Index creation started in Firebase Console." -ForegroundColor Cyan
    Write-Host "Building indexes may take a few minutes..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "You can check the status here:" -ForegroundColor Cyan
    Write-Host "  https://console.firebase.google.com/project/datacenter-checklist-prod/firestore/indexes" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Deployment failed!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Check if you have access to the Firebase project" -ForegroundColor White
    Write-Host "  2. Verify firestore.indexes.json is valid JSON" -ForegroundColor White
    Write-Host "  3. Run: firebase login --reauth" -ForegroundColor White
    Write-Host ""
    exit 1
}
