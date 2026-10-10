@echo off
echo ========================================
echo  GET SHA FINGERPRINT FOR FIREBASE
echo ========================================
echo.
echo This will generate SHA-1 and SHA-256 fingerprints
echo needed for Firebase Console configuration
echo.
pause

echo.
echo [METHOD 1] Using Gradle (Recommended)
echo ========================================
cd android
call gradlew signingReport
cd ..

echo.
echo ========================================
echo [METHOD 2] Using keytool (Debug Keystore)
echo ========================================
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android

echo.
echo ========================================
echo  NEXT STEPS:
echo ========================================
echo.
echo 1. Copy SHA-1 and SHA-256 from above
echo 2. Go to: https://console.firebase.google.com/project/audiranet-d4f68/settings/general
echo 3. Select your Android app
echo 4. Click "Add fingerprint"
echo 5. Paste SHA-1 and SHA-256
echo 6. Download new google-services.json
echo 7. Replace android/app/google-services.json
echo 8. Rebuild app: flutter clean && flutter run
echo.
pause
