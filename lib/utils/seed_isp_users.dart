import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Script untuk seed data sample users ISP
/// Jalankan dari main.dart saat pertama kali setup
Future<void> seedISPUsers() async {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  print('\n🌐 SEEDING ISP USERS DATA...\n');

  try {
    // Cek apakah sudah ada users
    final existing = await firestore.collection('users').get();
    if (existing.docs.isNotEmpty) {
      print(
        '⚠️  Users already exist (${existing.docs.length} users). Skipping seed.',
      );
      return;
    }

    // Sample ISP Users
    final List<Map<String, dynamic>> ispUsers = [
      // Admin ISP
      {
        'name': 'Admin ISP',
        'email': 'admin@audiranet.id',
        'password': 'admin123', // Temporary password
        'role': 'admin',
        'company': 'Audira Digital Network',
        'phone': '081234567890',
        'zone': 'Pusat',
        'active': true,
        'permissions': ['all'],
      },

      // Teknisi Field - Zona Jakarta Utara
      {
        'name': 'Budi Santoso',
        'email': 'budi.teknisi@audiranet.id',
        'password': 'teknisi123',
        'role': 'teknisi',
        'company': 'Audira Digital Network',
        'phone': '081234567891',
        'zone': 'Jakarta Utara',
        'active': true,
        'skills': ['instalasi', 'troubleshooting', 'maintenance'],
      },

      // Teknisi Field - Zona Jakarta Selatan
      {
        'name': 'Andi Wijaya',
        'email': 'andi.teknisi@audiranet.id',
        'password': 'teknisi123',
        'role': 'teknisi',
        'company': 'Audira Digital Network',
        'phone': '081234567892',
        'zone': 'Jakarta Selatan',
        'active': true,
        'skills': ['instalasi', 'fiber optic', 'routing'],
      },

      // Teknisi Field - Zona Jakarta Barat
      {
        'name': 'Dedi Kurniawan',
        'email': 'dedi.teknisi@audiranet.id',
        'password': 'teknisi123',
        'role': 'teknisi',
        'company': 'Audira Digital Network',
        'phone': '081234567893',
        'zone': 'Jakarta Barat',
        'active': true,
        'skills': ['maintenance', 'troubleshooting', 'network config'],
      },

      // Teknisi Field - Zona Jakarta Timur
      {
        'name': 'Eko Prasetyo',
        'email': 'eko.teknisi@audiranet.id',
        'password': 'teknisi123',
        'role': 'teknisi',
        'company': 'Audira Digital Network',
        'phone': '081234567894',
        'zone': 'Jakarta Timur',
        'active': true,
        'skills': ['instalasi', 'customer service', 'troubleshooting'],
      },

      // Teknisi Field - Zona Tangerang
      {
        'name': 'Fahmi Rahman',
        'email': 'fahmi.teknisi@audiranet.id',
        'password': 'teknisi123',
        'role': 'teknisi',
        'company': 'Audira Digital Network',
        'phone': '081234567895',
        'zone': 'Tangerang',
        'active': true,
        'skills': ['instalasi', 'fiber optic', 'mikrotik'],
      },

      // Teknisi Field - Zona Bekasi
      {
        'name': 'Gilang Ramadhan',
        'email': 'gilang.teknisi@audiranet.id',
        'password': 'teknisi123',
        'role': 'teknisi',
        'company': 'Audira Digital Network',
        'phone': '081234567896',
        'zone': 'Bekasi',
        'active': true,
        'skills': ['maintenance', 'network optimization', 'troubleshooting'],
      },

      // Supervisor Teknisi
      {
        'name': 'Hendra Gunawan',
        'email': 'hendra.spv@audiranet.id',
        'password': 'supervisor123',
        'role': 'supervisor',
        'company': 'Audira Digital Network',
        'phone': '081234567897',
        'zone': 'Semua',
        'active': true,
        'manages_zones': [
          'Jakarta Utara',
          'Jakarta Selatan',
          'Jakarta Barat',
          'Jakarta Timur',
          'Tangerang',
          'Bekasi',
        ],
      },

      // Customer Service
      {
        'name': 'Intan Permata',
        'email': 'cs@audiranet.id',
        'password': 'cs123',
        'role': 'customer_service',
        'company': 'Audira Digital Network',
        'phone': '081234567898',
        'zone': 'Pusat',
        'active': true,
        'department': 'Customer Support',
      },

      // Network Operations Center (NOC)
      {
        'name': 'Joko Widodo',
        'email': 'noc@audiranet.id',
        'password': 'noc123',
        'role': 'noc',
        'company': 'Audira Digital Network',
        'phone': '081234567899',
        'zone': 'Pusat',
        'active': true,
        'department': 'Network Operations',
        'shift': 'Day Shift',
      },
    ];

    print('📋 Creating ${ispUsers.length} ISP users...\n');

    int success = 0;
    int failed = 0;

    for (var userData in ispUsers) {
      try {
        // Extract password (jangan disimpan di Firestore)
        final password = userData['password'] as String;
        userData.remove('password');

        // Create Firebase Auth user
        UserCredential userCredential;
        try {
          userCredential = await auth.createUserWithEmailAndPassword(
            email: userData['email'],
            password: password,
          );
        } catch (authError) {
          // Jika user sudah ada di Auth, coba sign in
          print(
            '   ⚠️  Auth user exists for ${userData['email']}, trying to sign in...',
          );
          userCredential = await auth.signInWithEmailAndPassword(
            email: userData['email'],
            password: password,
          );
        }

        final userId = userCredential.user!.uid;

        // Tambahkan metadata
        userData['createdAt'] = FieldValue.serverTimestamp();
        userData['updatedAt'] = FieldValue.serverTimestamp();
        userData['authUid'] = userId;

        // Simpan ke Firestore dengan UID dari Auth
        await firestore.collection('users').doc(userId).set(userData);

        print(
          '   ✅ Created: ${userData['name']} (${userData['role']}) - ${userData['email']}',
        );
        success++;
      } catch (e) {
        print('   ❌ Failed: ${userData['email']} - Error: $e');
        failed++;
      }
    }

    // Sign out after seeding
    await auth.signOut();

    print('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ SEEDING COMPLETE!');
    print('   Success: $success users');
    if (failed > 0) print('   Failed: $failed users');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('\n📝 LOGIN CREDENTIALS:');
    print('   Admin: admin@audiranet.id / admin123');
    print('   Teknisi: budi.teknisi@audiranet.id / teknisi123');
    print('   NOC: noc@audiranet.id / noc123');
    print('   CS: cs@audiranet.id / cs123');
    print('\n');
  } catch (e) {
    print('❌ SEEDING ERROR: $e');
    rethrow;
  }
}

/// Fungsi helper untuk menampilkan semua zones yang ada
Future<List<String>> getISPZones() async {
  final zones = [
    'Jakarta Utara',
    'Jakarta Selatan',
    'Jakarta Barat',
    'Jakarta Timur',
    'Jakarta Pusat',
    'Tangerang',
    'Tangerang Selatan',
    'Bekasi',
    'Depok',
    'Bogor',
  ];
  return zones;
}
