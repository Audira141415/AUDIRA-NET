import 'backend_api_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'logger_service.dart';

/// Hybrid Authentication Service
/// Integrates Firebase Auth with Backend API
class HybridAuthService {
  static final HybridAuthService instance = HybridAuthService._init();
  HybridAuthService._init();

  final BackendApiService _backendApi = BackendApiService.instance;
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  /// Login with Firebase and sync with backend
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      LoggerService.info('🔐 Starting hybrid login for: $email');

      // 1. Authenticate with Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return {'success': false, 'error': 'Firebase authentication failed'};
      }

      LoggerService.info('✅ Firebase login successful');

      // 2. Get Firebase ID token
      final idToken = await credential.user!.getIdToken();

      // 3. Set token for backend API
      _backendApi.setAuthToken(idToken);

      // 4. Try to sync with backend (optional - doesn't fail if backend is down)
      try {
        final backendResponse = await _backendApi.post('/auth/firebase-login', {
          'idToken': idToken,
          'email': email,
        });

        if (backendResponse['success'] == true) {
          LoggerService.info('✅ Backend sync successful');
        }
      } catch (e) {
        LoggerService.warning(
          '⚠️ Backend sync failed (continuing with Firebase): $e',
        );
      }

      // 5. Get user data
      final userData = await _getUserData(credential.user!.uid);

      return {
        'success': true,
        'user': credential.user,
        'userData': userData,
        'token': idToken,
      };
    } catch (e) {
      LoggerService.error('❌ Hybrid login error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Register with Firebase and sync with backend
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      LoggerService.info('📝 Starting hybrid registration for: $email');

      // 1. Create Firebase account
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        return {'success': false, 'error': 'Firebase registration failed'};
      }

      // 2. Update Firebase profile
      await credential.user!.updateDisplayName(name);

      LoggerService.info('✅ Firebase registration successful');

      // 3. Get ID token
      final idToken = await credential.user!.getIdToken();
      _backendApi.setAuthToken(idToken);

      // 4. Try to sync with backend
      try {
        final backendResponse = await _backendApi.post('/auth/register', {
          'email': email,
          'name': name,
          'role': role,
          'firebaseUid': credential.user!.uid,
        });

        if (backendResponse['success'] == true) {
          LoggerService.info('✅ Backend registration successful');
        }
      } catch (e) {
        LoggerService.warning('⚠️ Backend sync failed (continuing): $e');
      }

      return {'success': true, 'user': credential.user, 'token': idToken};
    } catch (e) {
      LoggerService.error('❌ Hybrid registration error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Logout from both Firebase and backend
  Future<void> logout() async {
    try {
      LoggerService.info('👋 Logging out...');

      // 1. Notify backend (optional)
      try {
        await _backendApi.post('/auth/logout', {});
      } catch (e) {
        LoggerService.warning('⚠️ Backend logout failed: $e');
      }

      // 2. Clear backend token
      _backendApi.setAuthToken(null);

      // 3. Sign out from Firebase
      await _firebaseAuth.signOut();

      LoggerService.info('✅ Logout successful');
    } catch (e) {
      LoggerService.error('❌ Logout error: $e');
    }
  }

  /// Get current user
  auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _firebaseAuth.currentUser != null;

  /// Get Firebase ID token
  Future<String?> getIdToken() async {
    return await _firebaseAuth.currentUser?.getIdToken();
  }

  /// Refresh Firebase token and update backend
  Future<void> refreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final newToken = await user.getIdToken(true); // Force refresh
        _backendApi.setAuthToken(newToken);
        LoggerService.info('🔄 Token refreshed');
      }
    } catch (e) {
      LoggerService.error('❌ Token refresh error: $e');
    }
  }

  /// Get user data (from Firebase or backend)
  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    // Try backend first
    try {
      final response = await _backendApi.get('/users/$uid');
      if (response['success'] == true) {
        return response['data'] as Map<String, dynamic>?;
      }
    } catch (e) {
      LoggerService.warning('⚠️ Backend user data fetch failed: $e');
    }

    // Fallback to Firebase user data
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return {
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
      };
    }

    return null;
  }

  /// Listen to auth state changes
  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
