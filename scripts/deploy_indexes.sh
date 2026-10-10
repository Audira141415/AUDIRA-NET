#!/bin/bash

# ================================================
# Quick Firebase Index Deployment (Cross-platform)
# ================================================

echo "================================================"
echo "  Firebase Indexes Quick Deploy"
echo "================================================"
echo ""

# Check Firebase CLI
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found!"
    echo ""
    echo "Install with:"
    echo "  npm install -g firebase-tools"
    exit 1
fi

echo "✅ Firebase CLI found"
echo ""

# Deploy indexes
echo "Deploying Firestore indexes..."
echo ""

firebase deploy --only firestore:indexes

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    echo "Check status at:"
    echo "https://console.firebase.google.com/project/datacenter-checklist-prod/firestore/indexes"
else
    echo ""
    echo "❌ Deployment failed!"
    exit 1
fi
