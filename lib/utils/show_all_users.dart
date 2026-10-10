import 'package:cloud_firestore/cloud_firestore.dart';

/// Fungsi untuk menampilkan semua user dari Firestore
/// Returns: Map dengan total user dan list data
Future<Map<String, dynamic>> getAllUsers() async {
  final firestore = FirebaseFirestore.instance;

  print('\n============================================');
  print('SEMUA USER DI FIRESTORE');
  print('============================================\n');

  try {
    // Ambil semua dokumen dari collection 'users'
    final querySnapshot = await firestore.collection('users').get();

    if (querySnapshot.docs.isEmpty) {
      print('❌ Tidak ada user ditemukan di database.');
      return {'total': 0, 'users': []};
    }

    print('📊 Total: ${querySnapshot.docs.length} user\n');

    List<Map<String, dynamic>> usersList = [];
    int index = 1;
    for (var doc in querySnapshot.docs) {
      final data = doc.data();

      // Tambahkan ke list
      usersList.add({'id': doc.id, ...data});

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('User #$index');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📝 Document ID: ${doc.id}');
      print('👤 Nama       : ${data['name'] ?? '-'}');
      print('📧 Email      : ${data['email'] ?? '-'}');
      print('🔑 Role       : ${data['role'] ?? '-'}');
      print('🏢 Perusahaan : ${data['company'] ?? '-'}');
      print('📍 Zona       : ${data['zone'] ?? '-'}');
      print('📱 Telepon    : ${data['phone'] ?? '-'}');

      // Timestamp
      if (data['createdAt'] != null) {
        final timestamp = data['createdAt'] as Timestamp;
        print('🕒 Dibuat     : ${timestamp.toDate()}');
      }

      if (data['updatedAt'] != null) {
        final timestamp = data['updatedAt'] as Timestamp;
        print('🔄 Diupdate   : ${timestamp.toDate()}');
      }

      print('');
      index++;
    }

    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('✅ Selesai menampilkan ${querySnapshot.docs.length} user');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    return {'total': querySnapshot.docs.length, 'users': usersList};
  } catch (e) {
    print('❌ Error: $e');
    return {'total': 0, 'users': [], 'error': e.toString()};
  }
}
