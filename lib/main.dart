import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'config/routes.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'package:provider/provider.dart';
import 'utils/theme_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils/seed_isp_users.dart';
import 'utils/seed_customers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
  };

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // SEED: Isi data sample ISP users (hanya jika berhasil / skip jika permission denied)
  try {
    await seedISPUsers();
  } catch (e) {
    print('⚠️ Seed ISP Users skipped: $e');
  }

  // SEED: Isi data sample Customers (hanya jika berhasil / skip jika permission denied)
  try {
    await seedCustomers();
  } catch (e) {
    print('⚠️ Seed Customers skipped: $e');
  }

  // TEST: Cek koneksi Firestore dan tampilkan semua users
  try {
    await _testFirestoreConnection();
  } catch (e) {
    print('⚠️ Test Firestore Connection skipped: $e');
  }

  // Database sekarang menggunakan Firestore
  // SQLite sudah tidak digunakan

  // Inisialisasi notification service
  await NotificationService().initialize();
  await NotificationService().requestPermissions();

  runApp(const AudiraApp());
}

/// Test koneksi Firestore dan tampilkan users
Future<void> _testFirestoreConnection() async {
  try {
    print('\n🔍 Testing Firestore Connection...');
    final firestore = FirebaseFirestore.instance;

    // Query semua users
    final snapshot = await firestore.collection('users').get();

    print('✅ Firestore Connected!');
    print('📊 Total Users: ${snapshot.docs.length}');

    if (snapshot.docs.isEmpty) {
      print('⚠️  WARNING: Collection "users" is EMPTY!');
      print('   Please add users to Firebase Console:');
      print(
        '   https://console.firebase.google.com/project/datacenter-checklist-prod/firestore',
      );
    } else {
      print('\n👥 USER LIST:');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('📝 ID: ${doc.id}');
        print('   👤 Name: ${data['name'] ?? 'N/A'}');
        print('   📧 Email: ${data['email'] ?? 'N/A'}');
        print('   🔑 Role: ${data['role'] ?? 'N/A'}');
        print('   🏢 Company: ${data['company'] ?? 'N/A'}');
        print('   📍 Zone: ${data['zone'] ?? 'N/A'}');
        print('   ─────────────────────────────────────');
      }
    }
  } catch (e) {
    print('❌ Firestore Connection ERROR: $e');
    print('   Check your Firebase configuration!');
  }
}

class AudiraApp extends StatelessWidget {
  const AudiraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Audira Digital Network',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: Routes.unifiedLogin, // NEW: Single login page
            onGenerateRoute: RouteGenerator.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
