import 'dart:developer' as developer;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'firebase_service.dart';
import 'auth_service.dart';

/// AI Chatbot Service menggunakan Gemini AI
/// Untuk customer support ISP dengan kemampuan:
/// - FAQ umum tentang layanan internet
/// - Troubleshooting koneksi
/// - Cek status tagihan
/// - Cek status tiket
class ChatbotService {
  // API Key Gemini AI
  static const String _apiKey = 'AIzaSyCdvbZnmUCujp-QZXF4MfgPRDvluLYjKZQ';

  late final GenerativeModel _model;
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService.instance;

  // Conversation history untuk context
  final List<Content> _conversationHistory = [];

  ChatbotService() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(_getSystemPrompt()),
    );
  }

  String _getSystemPrompt() {
    return """
Kamu adalah Audi, asisten virtual untuk Audira Digital Network (AudiraNET), penyedia layanan internet (ISP) di Indonesia.

IDENTITAS:
- Nama: Audi (AI Assistant)
- Perusahaan: Audira Digital Network
- Layanan: Internet Service Provider (ISP)
- Moto: "Koneksi Cepat, Pelayanan Ramah"

TUGAS UTAMA:
1. Bantu pelanggan dengan pertanyaan umum tentang layanan internet
2. Troubleshooting masalah koneksi internet dengan solusi praktis
3. Informasi paket & harga yang jelas
4. Cara pembayaran tagihan
5. Panduan membuat tiket gangguan
6. Informasi zona layanan

ZONA LAYANAN KAMI:
- Jakarta Utara
- Jakarta Selatan
- Jakarta Timur
- Jakarta Barat
- Tangerang
- Bekasi

PAKET INTERNET TERSEDIA:
1. 📱 Paket Home 20 Mbps - Rp 250.000/bulan
   → Cocok untuk browsing & streaming (1-2 perangkat)
   
2. 🏠 Paket Home 50 Mbps - Rp 350.000/bulan
   → Ideal untuk keluarga (3-4 perangkat)
   
3. 🚀 Paket Home 100 Mbps - Rp 500.000/bulan
   → Super cepat untuk gaming & 4K streaming (5-6 perangkat)
   
4. 💼 Paket Business 200 Mbps - Rp 1.500.000/bulan
   → Untuk kantor & bisnis (10+ perangkat)

KEUNGGULAN AUDIRANET:
✓ Internet stabil & cepat
✓ Customer service 24/7
✓ Teknisi profesional & responsif
✓ Tidak ada FUP (Fair Usage Policy)
✓ Gratis instalasi & pemasangan
✓ Garansi uptime 99.5%

METODE PEMBAYARAN:
1. 🏦 Transfer Bank: BCA, Mandiri, BNI, BRI
2. 💳 Virtual Account (otomatis)
3. 💰 E-wallet: GoPay, OVO, Dana, ShopeePay
4. 🏪 Minimarket: Indomaret, Alfamart
5. 📱 Mobile Banking & Internet Banking

TROUBLESHOOTING LENGKAP:

🔴 INTERNET LAMBAT:
1. Restart modem/router:
   - Cabut power adapter dari modem
   - Tunggu 10-15 detik
   - Colokkan kembali & tunggu lampu menyala semua
2. Cek kabel yang longgar (dari modem ke dinding)
3. Test speed di aplikasi (menu Speed Test)
4. Pastikan tidak ada banyak perangkat tersambung bersamaan
5. Cek tagihan sudah dibayar atau belum
6. Jika masih lambat → buat tiket gangguan, teknisi akan datang

🔴 TIDAK BISA CONNECT INTERNET:
1. Cek lampu indikator modem:
   - Power: harus menyala hijau/biru
   - PON/LOS: harus hijau (jika merah = masalah sinyal)
   - LAN: harus berkedip saat ada aktivitas
2. Restart modem & perangkat Anda
3. Cek kabel fiber optik tidak tertekuk/putus
4. Pastikan tagihan sudah lunas
5. Cek apakah ada maintenance terjadwal
6. Jika masih tidak bisa → buat tiket gangguan SEGERA

🔴 WiFi TIDAK TERDETEKSI:
1. Restart modem (cabut power 10 detik)
2. Cek jarak perangkat dari router (maksimal 10 meter)
3. Pastikan WiFi di modem sudah ON (ada lampu WiFi menyala)
4. Cek SSID & password WiFi benar (case sensitive)
5. Coba forget network & connect ulang
6. Ganti channel WiFi jika terlalu banyak tetangga pakai WiFi sama

🔴 KONEKSI PUTUS-PUTUS:
1. Cek kabel yang kendor atau rusak
2. Pindahkan router ke posisi lebih tinggi & terbuka
3. Kurangi perangkat yang tersambung
4. Update firmware router (hubungi CS)
5. Buat tiket jika terus terjadi

CARA BUAT TIKET GANGGUAN:
1. Buka aplikasi AudiraNET
2. Pilih menu "Bantuan"
3. Klik "Buat Tiket Baru"
4. Isi detail masalah dengan jelas
5. Upload foto jika perlu (lampu modem, kabel, dll)
6. Submit → Teknisi akan respon maksimal 2 jam
7. Teknisi datang ke lokasi maksimal 24 jam

CARA BAYAR TAGIHAN:
1. Buka menu "Tagihan" di aplikasi
2. Pilih tagihan yang belum dibayar
3. Pilih metode pembayaran
4. Ikuti instruksi pembayaran
5. Konfirmasi otomatis setelah bayar
6. Internet tetap aktif setelah pembayaran dikonfirmasi

KOMUNIKASI:
✓ Gunakan bahasa Indonesia yang ramah, natural & profesional
✓ Berikan jawaban singkat tapi jelas (2-5 kalimat)
✓ Jika pelanggan frustasi, tunjukkan empati
✓ Gunakan emoji sesekali untuk friendly 😊
✓ Jangan bertele-tele, langsung ke solusi
✓ Jika sudah berikan data real (tagihan/tiket/paket), jangan ulang lagi
✓ Jika tidak yakin, arahkan untuk hubungi CS atau buat tiket

BATASAN:
✗ Jangan bahas politik, agama, atau hal sensitif
✗ Jangan berikan nomor telepon pribadi atau alamat
✗ Jangan berikan diskon tanpa konfirmasi admin
✗ Jangan janji teknisi datang dalam waktu spesifik (selalu "maksimal 24 jam")
✗ Fokus HANYA pada layanan ISP AudiraNET

SPECIAL DETECTION:
Jika pelanggan menyebut:
- "tagihan", "bill", "bayar", "pembayaran" → Sistem akan otomatis cek tagihan mereka
- "tiket", "ticket", "gangguan", "keluhan" → Sistem akan otomatis cek status tiket
- "paket saya", "langganan saya" → Sistem akan otomatis cek info paket mereka

STYLE JAWABAN:
- Ramah tapi profesional
- Empati ke masalah pelanggan
- Berikan solusi konkret step-by-step
- Tutup dengan pertanyaan "Ada yang bisa saya bantu lagi?"
- Jangan gunakan bahasa formal berlebihan (hindari "Bapak/Ibu")

Contoh jawaban bagus:
"Internet lambat bisa karena beberapa hal. Coba restart modem dulu ya (cabut power 10 detik). Kalau masih lambat, cek di menu Speed Test. Biasanya itu sudah cukup. Tapi kalau masih bermasalah, buat tiket aja biar teknisi kami yang cek langsung ke lokasi. Ada yang bisa saya bantu lagi? 😊"

Ingat: Kamu adalah Audi yang helpful dan solution-oriented! 🚀
""";
  }

  /// Send message dan dapat response dari AI
  Future<String> sendMessage(String userMessage) async {
    try {
      // Tambahkan user message ke history
      _conversationHistory.add(Content.text(userMessage));

      // Deteksi special commands
      final lowerMessage = userMessage.toLowerCase();

      // Dapatkan data customer untuk context
      final userData = await _authService.getCurrentUser();
      String? customerContext;

      if (userData != null && userData['role'] == 'customer') {
        final customer = await _firebaseService.getCustomerByUserId(
          userData['id'],
        );
        if (customer != null) {
          customerContext =
              """
DATA PELANGGAN SAAT INI:
- Nama: ${customer['name']}
- Paket: ${customer['package']}
- Biaya Bulanan: Rp ${customer['monthlyFee']}/bulan
- Zona: ${customer['zone']}
- Alamat: ${customer['address']}
""";
        }
      }

      // Cek tagihan
      if (lowerMessage.contains('tagihan') ||
          lowerMessage.contains('bill') ||
          lowerMessage.contains('bayar') ||
          lowerMessage.contains('pembayaran')) {
        final billInfo = await _checkUserBills();
        if (billInfo != null) {
          final response =
              'Baik, saya cek tagihan Anda:\n\n$billInfo\n\nAda yang bisa saya bantu lagi? 😊';
          _conversationHistory.add(Content.model([TextPart(response)]));
          return response;
        }
      }

      // Cek tiket
      if (lowerMessage.contains('tiket') ||
          lowerMessage.contains('ticket') ||
          lowerMessage.contains('gangguan') ||
          lowerMessage.contains('keluhan')) {
        final ticketInfo = await _checkUserTickets();
        if (ticketInfo != null) {
          final response =
              'Ini status tiket Anda:\n\n$ticketInfo\n\nAda yang bisa saya bantu lagi? 😊';
          _conversationHistory.add(Content.model([TextPart(response)]));
          return response;
        }
      }

      // Cek info paket customer
      if ((lowerMessage.contains('paket') && lowerMessage.contains('saya')) ||
          lowerMessage.contains('paket saya') ||
          lowerMessage.contains('langganan saya')) {
        final packageInfo = await _getCustomerPackageInfo();
        if (packageInfo != null) {
          final response = packageInfo;
          _conversationHistory.add(Content.model([TextPart(response)]));
          return response;
        }
      }

      // Generate response dari AI dengan context
      String enhancedPrompt = userMessage;
      if (customerContext != null) {
        enhancedPrompt =
            """$customerContext

PERTANYAAN PELANGGAN: $userMessage

Jawab berdasarkan data pelanggan di atas jika relevan.""";
      }

      final chat = _model.startChat(
        history: _conversationHistory
            .take(_conversationHistory.length - 1)
            .toList(),
      );
      final response = await chat.sendMessage(Content.text(enhancedPrompt));

      final aiResponse =
          response.text ??
          'Maaf, saya tidak mengerti. Bisa diulang pertanyaannya?';

      // Tambahkan AI response ke history
      _conversationHistory.add(Content.model([TextPart(aiResponse)]));

      // Batasi history maksimal 20 pesan (10 bolak-balik)
      if (_conversationHistory.length > 20) {
        _conversationHistory.removeRange(0, _conversationHistory.length - 20);
      }

      return aiResponse;
    } catch (e) {
      developer.log('Error in chatbot: $e', name: 'ChatbotService');

      // Fallback response jika API error
      if (e.toString().contains('API_KEY')) {
        return 'Maaf, chatbot sedang dalam tahap konfigurasi. Silakan hubungi customer service kami atau buat tiket di menu Bantuan. 🙏';
      }

      return 'Maaf, saya mengalami gangguan. Silakan coba lagi atau hubungi customer service kami. 🙏';
    }
  }

  /// Cek tagihan user yang sedang login
  Future<String?> _checkUserBills() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return null;

      final bills = await _firebaseService.getBillsByCustomerId(
        currentUser['id'],
      );

      if (bills.isEmpty) {
        return '✅ Anda tidak memiliki tagihan yang belum dibayar.';
      }

      final unpaidBills = bills
          .where((bill) => bill['status'] == 'unpaid')
          .toList();

      if (unpaidBills.isEmpty) {
        return '✅ Semua tagihan Anda sudah lunas!';
      }

      StringBuffer result = StringBuffer();
      result.writeln('📋 Tagihan yang belum dibayar:');
      result.writeln();

      for (var bill in unpaidBills.take(3)) {
        final amount = bill['amount'] ?? 0;
        final dueDate = bill['dueDate'] ?? 'N/A';
        result.writeln(
          '💰 Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
        );
        result.writeln('📅 Jatuh tempo: $dueDate');
        result.writeln();
      }

      result.writeln('Silakan bayar melalui menu Tagihan di aplikasi.');

      return result.toString().trim();
    } catch (e) {
      developer.log('Error checking bills: $e', name: 'ChatbotService');
      return null;
    }
  }

  /// Cek status tiket user yang sedang login
  Future<String?> _checkUserTickets() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return null;

      final tickets = await _firebaseService.getTicketsByCustomerId(
        currentUser['id'],
      );

      if (tickets.isEmpty) {
        return '✅ Anda belum memiliki tiket gangguan.\n\nJika ada masalah, silakan buat tiket di menu Bantuan.';
      }

      final activeTickets = tickets
          .where((t) => t['status'] != 'selesai' && t['status'] != 'ditutup')
          .toList();

      if (activeTickets.isEmpty) {
        return '✅ Semua tiket Anda sudah selesai.\n\nJika ada masalah baru, silakan buat tiket di menu Bantuan.';
      }

      StringBuffer result = StringBuffer();
      result.writeln('🎫 Tiket aktif Anda:');
      result.writeln();

      for (var ticket in activeTickets.take(3)) {
        final title = ticket['title'] ?? 'Tanpa judul';
        final status = ticket['status'] ?? 'unknown';
        final createdAt = ticket['createdAt'] ?? 'N/A';

        String statusEmoji = '⏳';
        if (status == 'dikerjakan') statusEmoji = '🔧';
        if (status == 'pending') statusEmoji = '⏸️';

        result.writeln('$statusEmoji $title');
        result.writeln('   Status: ${status.toUpperCase()}');
        result.writeln('   Dibuat: $createdAt');
        result.writeln();
      }

      result.writeln('Lihat detail di menu Bantuan → Tiket Saya.');

      return result.toString().trim();
    } catch (e) {
      developer.log('Error checking tickets: $e', name: 'ChatbotService');
      return null;
    }
  }

  /// Cek info paket pelanggan yang sedang login
  Future<String?> _getCustomerPackageInfo() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return null;

      final customer = await _firebaseService.getCustomerByUserId(
        currentUser['id'],
      );

      if (customer == null) {
        return 'Maaf, data pelanggan tidak ditemukan. Silakan hubungi customer service.';
      }

      final name = customer['name'] ?? 'N/A';
      final packageName = customer['package'] ?? 'N/A';
      final monthlyFee = customer['monthlyFee'] ?? 0;
      final zone = customer['zone'] ?? 'N/A';
      final address = customer['address'] ?? 'N/A';
      final phone = customer['phone'] ?? 'N/A';

      StringBuffer result = StringBuffer();
      result.writeln('📦 INFORMASI PAKET ANDA');
      result.writeln('━━━━━━━━━━━━━━━━━━━━━━━━');
      result.writeln('👤 Nama: $name');
      result.writeln('📡 Paket: $packageName');
      result.writeln(
        '💰 Biaya: Rp ${monthlyFee.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}/bulan',
      );
      result.writeln('📍 Zona: $zone');
      result.writeln('🏠 Alamat: $address');
      result.writeln('📞 Telp: $phone');
      result.writeln();
      result.writeln('Butuh upgrade paket? Hubungi customer service kami! 😊');

      return result.toString().trim();
    } catch (e) {
      developer.log(
        'Error getting customer package info: $e',
        name: 'ChatbotService',
      );
      return null;
    }
  }

  /// Reset conversation history
  void resetConversation() {
    _conversationHistory.clear();
  }

  /// Get suggested questions untuk quick start
  List<String> getSuggestedQuestions() {
    return [
      'Apa paket internet yang tersedia?',
      'Cara bayar tagihan?',
      'Internet saya lambat, kenapa?',
      'Cek tagihan saya',
      'Paket saya apa?',
      'Bagaimana cara buat tiket?',
    ];
  }
}
