import 'package:firebase_core/firebase_core.dart';
import 'package:audira_app/firebase_options.dart';
import 'package:audira_app/utils/show_all_users.dart';

/// Script untuk menampilkan semua user yang terdaftar di Firebase Firestore
void main() async {
  print('\n🔥 AUDIRANET - Menampilkan User Terdaftar...\n');

  try {
    // Inisialisasi Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Panggil fungsi untuk menampilkan semua user
    await getAllUsers();
  } catch (e) {
    print('❌ ERROR: $e\n');
    print('💡 Kemungkinan penyebab:');
    print('   1. File google-services.json belum ada atau tidak valid');
    print('   2. Firebase belum di-setup dengan benar');
    print('   3. Koneksi internet tidak aktif\n');
    print('📝 Solusi:');
    print('   - Pastikan sudah setup Firebase (lihat FIREBASE_SETUP_GUIDE.md)');
    print('   - Atau jalankan: flutter run -d windows\n');
  }
}
