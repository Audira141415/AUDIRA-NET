import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';
import 'logger_service.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  User? _currentUser;
  Map<String, dynamic>? _currentUserData;

  User? get currentUser => _currentUser;
  Map<String, dynamic>? get currentUserData => _currentUserData;
  bool get isLoggedIn => _currentUser != null;

  // Get current user data (async version for consistency)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (_currentUserData != null) {
      return _currentUserData;
    }

    // Fallback: get from Firebase if not cached
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      final userData = await FirebaseService.instance.getUserById(
        firebaseUser.uid,
      );
      return userData;
    }

    return null;
  }

  // Login dengan Firebase Authentication
  Future<bool> login(String email, String password, UserRole role) async {
    try {
      LoggerService.authInfo('🔐 AuthService.login() called with:');
      LoggerService.authInfo('   Email: $email');
      LoggerService.authInfo('   Password: $password');
      LoggerService.authInfo('   Expected Role: $role');

      // Authenticate with Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        LoggerService.authInfo('   ❌ Firebase authentication failed');
        return false;
      }

      // Get user data from Firestore
      final userData = await FirebaseService.instance.getUserById(
        credential.user!.uid,
      );
      LoggerService.authInfo(
        '   FirebaseService.getUserById() result: ${userData != null ? 'SUCCESS' : 'FAILED'}',
      );

      if (userData != null) {
        LoggerService.authInfo(
          '   Firebase returned user: ${userData['name']} (${userData['role']})',
        );

        // Validasi role
        final userRole = userData['role'] == 'admin'
            ? UserRole.admin
            : userData['role'] == 'teknisi'
            ? UserRole.teknisi
            : UserRole.customer;

        LoggerService.authInfo('   Parsed role from Firestore: $userRole');
        LoggerService.authInfo('   Expected role: $role');
        LoggerService.authInfo('   Role match: ${userRole == role}');

        if (userRole != role) {
          LoggerService.authInfo('   ❌ Role validation FAILED');
          await _firebaseAuth.signOut();
          return false; // Role tidak sesuai
        }

        _currentUserData = userData;
        _currentUser = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          phone: userData['phone'] ?? '',
          role: userRole,
          createdAt:
              (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );

        // Ensure customer data exists for customer role
        if (userRole == UserRole.customer) {
          await _ensureCustomerDataExists(userData);
        }

        LoggerService.authInfo('   ✅ Login SUCCESS');
        return true;
      }

      LoggerService.authInfo(
        '   ❌ FirebaseService.getUserById() returned null',
      );
      await _firebaseAuth.signOut();
      return false;
    } on auth.FirebaseAuthException catch (e) {
      LoggerService.authInfo(
        '   💥 Firebase Auth ERROR: ${e.code} - ${e.message}',
      );
      return false;
    } catch (e) {
      LoggerService.authInfo('   💥 Login ERROR: $e');
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    _currentUserData = null;
  }

  /// Simple sign in with email and password (for unified login)
  /// Returns User credential if successful, null otherwise
  Future<auth.User?> signInWithEmail(String email, String password) async {
    try {
      LoggerService.authInfo('🔐 AuthService.signInWithEmail() called');
      LoggerService.authInfo('   Email: $email');

      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        LoggerService.authInfo('   ✅ Firebase authentication SUCCESS');
        return credential.user;
      }

      LoggerService.authInfo('   ❌ Firebase authentication failed');
      return null;
    } on auth.FirebaseAuthException catch (e) {
      LoggerService.authInfo('   💥 Firebase Auth ERROR: ${e.code} - ${e.message}');
      rethrow; // Re-throw to let caller handle specific error messages
    } catch (e) {
      LoggerService.authInfo('   💥 Sign in ERROR: $e');
      return null;
    }
  }

  /// Set current user data after successful authentication
  /// This is used by unified login to store user info
  Future<void> setCurrentUserData(Map<String, dynamic> userData) async {
    try {
      _currentUserData = userData;

      // Parse role
      final userRole = userData['role'] == 'admin'
          ? UserRole.admin
          : userData['role'] == 'teknisi'
          ? UserRole.teknisi
          : UserRole.customer;

      _currentUser = User(
        id: userData['id'],
        name: userData['name'],
        email: userData['email'],
        phone: userData['phone'] ?? '',
        role: userRole,
        createdAt:
            (userData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      // Ensure customer data exists for customer role
      if (userRole == UserRole.customer) {
        await _ensureCustomerDataExists(userData);
      }

      LoggerService.authInfo('✅ Current user data set: ${userData['name']} (${userData['role']})');
    } catch (e) {
      LoggerService.authInfo('💥 Error setting current user data: $e');
    }
  }

  // Register customer baru
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String packageName,
    required int speed,
    required int price,
  }) async {
    try {
      // Cek apakah email sudah digunakan
      try {
        await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on auth.FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          return {'success': false, 'message': 'Email sudah terdaftar'};
        }
        return {'success': false, 'message': 'Error: ${e.message}'};
      }

      final userId = _firebaseAuth.currentUser!.uid;

      // Create user document in Firestore
      await FirebaseService.instance.createUser({
        'email': email,
        'name': name,
        'phone': phone,
        'role': 'customer',
      });

      // Generate customer ID
      final customersSnapshot = await FirebaseService
          .instance
          .customersCollection
          .get();
      final customerId =
          'ADN-2025-${(customersSnapshot.docs.length + 1).toString().padLeft(3, '0')}';

      // Insert customer data
      await FirebaseService.instance.createCustomer({
        'userId': userId,
        'customerId': customerId,
        'address': address,
        'packageName': packageName,
        'speed': speed,
        'price': price,
        'status': 'active',
      });

      return {
        'success': true,
        'message': 'Registrasi berhasil',
        'customerId': customerId,
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on auth.FirebaseAuthException catch (e) {
      LoggerService.authInfo('Reset password error: ${e.message}');
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get customer data dari user yang login
  Map<String, dynamic>? getCustomerData() {
    if (_currentUserData != null && _currentUserData!.containsKey('customer')) {
      return _currentUserData!['customer'] as Map<String, dynamic>;
    }
    return null;
  }

  // Ensure customer data exists for customer users
  Future<void> _ensureCustomerDataExists(Map<String, dynamic> userData) async {
    try {
      LoggerService.authInfo('Auth operation completed');

      final customerData = await FirebaseService.instance.getCustomerByUserId(
        userData['id'],
      );

      if (customerData == null) {
        LoggerService.authInfo('   ❌ No customer data found, creating...');

        // Create customer data
        final customersSnapshot = await FirebaseService
            .instance
            .customersCollection
            .get();
        final customerId =
            'ADN-2025-${(customersSnapshot.docs.length + 1).toString().padLeft(3, '0')}';

        await FirebaseService.instance.createCustomer({
          'userId': userData['id'],
          'customerId': customerId,
          'internetNumber':
              'INT-2025-${(customersSnapshot.docs.length + 1).toString().padLeft(3, '0')}',
          'address': 'Jl. Contoh No. 123, Jakarta',
          'packageName': '50 Mbps - Unlimited',
          'speed': 50,
          'price': 350000,
          'status': 'active',
          'installDate': Timestamp.fromDate(DateTime(2025, 1, 15)),
        });

        LoggerService.authInfo('   ✅ Customer data created: $customerId');

        // Create sample bills
        await _createSampleBills(userData['id']);
      } else {
        LoggerService.authInfo(
          '📄 Creating sample bills for customer: ${customerData['customerId']}',
        );
      }
    } catch (e) {
      LoggerService.authInfo('   ❌ Error ensuring customer data: $e');
    }
  }

  // Create sample bills for customer
  Future<void> _createSampleBills(String userId) async {
    try {
      LoggerService.authInfo('   📄 Creating sample bills...');

      // Get customer ID from Firestore
      final customerData = await FirebaseService.instance.getCustomerByUserId(
        userId,
      );
      if (customerData != null) {
        final customerId = customerData['id'];

        // Check if bills already exist
        final existingBills = await FirebaseService.instance
            .getBillsByCustomerId(customerId);

        if (existingBills.isEmpty) {
          // Create current month bill (unpaid)
          await FirebaseService.instance.createBill({
            'customerId': customerId,
            'billMonth': 'November 2025',
            'amount': 350000,
            'dueDate': Timestamp.fromDate(DateTime(2025, 11, 30)),
            'status': 'unpaid',
          });

          // Create previous month bill (paid)
          await FirebaseService.instance.createBill({
            'customerId': customerId,
            'billMonth': 'Oktober 2025',
            'amount': 350000,
            'dueDate': Timestamp.fromDate(DateTime(2025, 10, 31)),
            'status': 'paid',
            'paidDate': Timestamp.fromDate(DateTime(2025, 10, 25)),
          });

          LoggerService.authInfo('   ✅ Sample bills created');
        } else {
          LoggerService.authInfo(
            '   📋 Bills already exist: ${existingBills.length}',
          );
        }
      }
    } catch (e) {
      LoggerService.authInfo('   ❌ Error creating sample bills: $e');
    }
  }
}
