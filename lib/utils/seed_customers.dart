import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Seed Customer Users & Customer Data
/// Run this once to create sample customers for testing
Future<void> seedCustomers() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  print('🌐 SEEDING CUSTOMER DATA...');

  // Check if customers already exist
  final existingCustomers = await firestore
      .collection('customers')
      .limit(1)
      .get();
  if (existingCustomers.docs.isNotEmpty) {
    print('!  Customers already exist. Skipping seed.');
    return;
  }

  // Sample customers data
  final List<Map<String, dynamic>> customers = [
    {
      'email': 'customer1@gmail.com',
      'password': 'customer123',
      'name': 'Ahmad Hidayat',
      'phone': '081234567890',
      'address': 'Jl. Sudirman No. 123, Jakarta Selatan',
      'package': 'Home 50 Mbps',
      'monthlyFee': 350000,
      'status': 'active',
      'zone': 'Jakarta Selatan',
    },
    {
      'email': 'customer2@gmail.com',
      'password': 'customer123',
      'name': 'Siti Nurhaliza',
      'phone': '081234567891',
      'address': 'Jl. Gatot Subroto No. 45, Jakarta Utara',
      'package': 'Home 100 Mbps',
      'monthlyFee': 500000,
      'status': 'active',
      'zone': 'Jakarta Utara',
    },
    {
      'email': 'customer3@gmail.com',
      'password': 'customer123',
      'name': 'Budi Setiawan',
      'phone': '081234567892',
      'address': 'Jl. Thamrin No. 78, Jakarta Timur',
      'package': 'Home 20 Mbps',
      'monthlyFee': 250000,
      'status': 'active',
      'zone': 'Jakarta Timur',
    },
    {
      'email': 'customer4@gmail.com',
      'password': 'customer123',
      'name': 'Dewi Lestari',
      'phone': '081234567893',
      'address': 'Jl. Kebon Jeruk No. 12, Jakarta Barat',
      'package': 'Home 50 Mbps',
      'monthlyFee': 350000,
      'status': 'active',
      'zone': 'Jakarta Barat',
    },
    {
      'email': 'customer5@gmail.com',
      'password': 'customer123',
      'name': 'Rudi Hartono',
      'phone': '081234567894',
      'address': 'Jl. BSD Raya No. 99, Tangerang',
      'package': 'Business 200 Mbps',
      'monthlyFee': 1500000,
      'status': 'active',
      'zone': 'Tangerang',
    },
    {
      'email': 'customer6@gmail.com',
      'password': 'customer123',
      'name': 'Linda Wijaya',
      'phone': '081234567895',
      'address': 'Jl. Summarecon No. 56, Bekasi',
      'package': 'Home 100 Mbps',
      'monthlyFee': 500000,
      'status': 'active',
      'zone': 'Bekasi',
    },
  ];

  int successCount = 0;

  for (var customerData in customers) {
    try {
      // 1. Create Firebase Auth user
      final UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(
            email: customerData['email'],
            password: customerData['password'],
          );

      final String userId = userCredential.user!.uid;

      // 2. Create user document in 'users' collection
      await firestore.collection('users').doc(userId).set({
        'email': customerData['email'],
        'name': customerData['name'],
        'role': 'customer',
        'phone': customerData['phone'],
        'createdAt': FieldValue.serverTimestamp(),
        'company': 'Audira Digital Network',
      });

      // 3. Create customer document in 'customers' collection
      await firestore.collection('customers').doc(userId).set({
        'userId': userId,
        'name': customerData['name'],
        'email': customerData['email'],
        'phone': customerData['phone'],
        'address': customerData['address'],
        'package': customerData['package'],
        'monthlyFee': customerData['monthlyFee'],
        'status': customerData['status'],
        'zone': customerData['zone'],
        'installationDate': DateTime.now()
            .subtract(Duration(days: 30))
            .toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Create sample bill for each customer
      await firestore.collection('bills').add({
        'customerId': userId,
        'customerName': customerData['name'],
        'amount': customerData['monthlyFee'],
        'dueDate': DateTime.now()
            .add(Duration(days: 15))
            .toIso8601String()
            .split('T')[0],
        'status': 'unpaid',
        'period': DateTime.now().toIso8601String().substring(0, 7), // YYYY-MM
        'createdAt': FieldValue.serverTimestamp(),
      });

      print(
        '✅ Created customer: ${customerData['name']} (${customerData['email']})',
      );
      successCount++;

      // Sign out after creating each user
      await auth.signOut();
    } catch (e) {
      print('❌ Error creating customer ${customerData['email']}: $e');
    }
  }

  print('');
  print('✅ Successfully created $successCount customers!');
  print('');
  print('📋 CUSTOMER LOGIN CREDENTIALS:');
  print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  for (var customer in customers) {
    print('📧 ${customer['email']}');
    print('   🔑 Password: ${customer['password']}');
    print('   👤 Name: ${customer['name']}');
    print('   📦 Package: ${customer['package']}');
    print('   📍 Zone: ${customer['zone']}');
    print('   ─────────────────────────────────────');
  }
}
