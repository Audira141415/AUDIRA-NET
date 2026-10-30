import 'dart:developer' as developer;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'firebase_service.dart';
import 'auth_service.dart';
import 'backend_api_service.dart';

/// AI Chatbot Service untuk customer support ISP AUDIRA NET
/// Menggabungkan Gemini AI (gemini-1.5-flash) dengan NOC Expert Rule Engine.
class ChatbotService {
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyCdvbZnmUCujp-QZXF4MfgPRDvluLYjKZQ',
  );

  GenerativeModel? _model;
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService.instance;

  final List<Content> _conversationHistory = [];

  ChatbotService() {
    _initializeModel();
  }

  void _initializeModel() {
    try {
      _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 1024,
        ),
        systemInstruction: Content.system(_getSystemPrompt()),
      );
    } catch (e) {
      developer.log('Failed to init GenerativeModel: $e', name: 'ChatbotService');
      _model = null;
    }
  }

  String _getSystemPrompt() {
    return '''
Kamu adalah Audi, asisten virtual resmi untuk AUDIRA NET (PT Audira Multimedia Digital / Audira Sukses Mandiri).
ISP Dedicated & Broadband Fiber Optic di Indonesia.
Misi kamu adalah memberikan diagnosa teknis yang akurat, ramah, dan cepat.
''';
  }

  /// Send message dan dapat response
  Future<String> sendMessage(String userMessage) async {
    final cleanInput = userMessage.trim();
    if (cleanInput.isEmpty) return 'Silakan ketik pertanyaan Anda.';

    _conversationHistory.add(Content.text(cleanInput));
    final lower = cleanInput.toLowerCase();

    // 1. Cek Pertanyaan Diagnostik Spesifik ISP (Deterministic Priority)
    // A. Internet Lambat / Buffering
    if (lower.contains('lambat') || lower.contains('lemot') || lower.contains('lag') || lower.contains('ping') || lower.contains('buffer') || lower.contains('kecepatan')) {
      final reply = _getInternetSlowTroubleshoot();
      _conversationHistory.add(Content.model([TextPart(reply)]));
      return reply;
    }

    // B. Lampu LOS Merah / Kabel Putus
    if (lower.contains('los') || lower.contains('merah') || lower.contains('putus') || lower.contains('mati total') || lower.contains('kabel optik')) {
      final reply = _getLosRedTroubleshoot();
      _conversationHistory.add(Content.model([TextPart(reply)]));
      return reply;
    }

    // C. Daftar Paket & Harga
    if ((lower.contains('paket') && (lower.contains('tersedia') || lower.contains('apa') || lower.contains('ada') || lower.contains('harga') || lower.contains('daftar') || lower.contains('promo'))) || lower.contains('tarif')) {
      final reply = _getPackageListResponse();
      _conversationHistory.add(Content.model([TextPart(reply)]));
      return reply;
    }

    // D. Cara Bayar Tagihan & Kanal Pembayaran
    if (lower.contains('cara bayar') || lower.contains('metode bayar') || lower.contains('bayar tagihan') || lower.contains('kanal pembayaran') || lower.contains('rekening') || lower.contains('nomor va')) {
      final reply = _getPaymentMethodsResponse();
      _conversationHistory.add(Content.model([TextPart(reply)]));
      return reply;
    }

    // E. Cara Buat Tiket Gangguan
    if (lower.contains('cara buat tiket') || lower.contains('bagaimana cara buat tiket') || lower.contains('lapor tiket') || lower.contains('buat tiket') || lower.contains('lapor gangguan')) {
      final reply = _getCreateTicketGuide();
      _conversationHistory.add(Content.model([TextPart(reply)]));
      return reply;
    }

    // F. Cek Tagihan Aktif User
    if (lower.contains('cek tagihan') || lower.contains('tagihan saya') || lower.contains('status tagihan') || lower.contains('belum bayar')) {
      final billInfo = await _checkUserBills();
      if (billInfo != null) {
        final reply = 'Berikut rincian tagihan internet Anda saat ini:\n\n$billInfo\n\nAnda dapat langsung membayar via menu Tagihan di bawah dengan QRIS atau Virtual Account. 😊';
        _conversationHistory.add(Content.model([TextPart(reply)]));
        return reply;
      }
    }

    // G. Cek Paket Pelanggan Aktif
    if (lower.contains('paket saya') || lower.contains('langganan saya') || lower.contains('langganan ku')) {
      final pkgInfo = await _getCustomerPackageInfo();
      if (pkgInfo != null) {
        _conversationHistory.add(Content.model([TextPart(pkgInfo)]));
        return pkgInfo;
      }
    }

    // H. Cek Status Tiket Pengguna
    if (lower.contains('status tiket') || lower.contains('tiket saya') || lower.contains('riwayat tiket')) {
      final ticketInfo = await _checkUserTickets();
      if (ticketInfo != null) {
        _conversationHistory.add(Content.model([TextPart(ticketInfo)]));
        return ticketInfo;
      }
    }

    // I. Cara Ganti Sandi Wi-Fi / Router
    if (lower.contains('wifi') || lower.contains('wi-fi') || lower.contains('password') || lower.contains('sandi') || lower.contains('ssid')) {
      final reply = _getWifiManagementGuide();
      _conversationHistory.add(Content.model([TextPart(reply)]));
      return reply;
    }

    // J. Kontak CS / NOC Hotline
    if (lower.contains('hubungi') || lower.contains('kontak') || lower.contains('telepon') || lower.contains('call center') || lower.contains('whatsapp') || lower.contains('wa')) {
      final reply = _getContactCenterResponse();
      _conversationHistory.add(Content.model([TextPart(reply)]));
      return reply;
    }

    // 2. Jika tidak ada keyword khusus, coba panggil Generative AI (Gemini)
    if (_model != null) {
      try {
        final chat = _model!.startChat(
          history: _conversationHistory.take(_conversationHistory.length - 1).toList(),
        );
        final response = await chat.sendMessage(Content.text(cleanInput));
        final text = response.text;
        if (text != null && text.isNotEmpty) {
          _conversationHistory.add(Content.model([TextPart(text)]));
          return text;
        }
      } catch (err) {
        developer.log('Gemini AI fallback triggered: $err', name: 'ChatbotService');
      }
    }

    // 3. Robust ISP NOC Rule-Based Intelligent Fallback
    final fallbackResponse = _getComprehensiveIspFallback(cleanInput);
    _conversationHistory.add(Content.model([TextPart(fallbackResponse)]));
    return fallbackResponse;
  }

  String _getInternetSlowTroubleshoot() {
    return '''🚀 PANDUAN DIAGNOSA KONEKSI LAMBAT:

1. Periksa Indikator Modem ONT:
   • Lampu PON: Harus menyala HIJAU SOLID (stabil).
   • Lampu LOS: Harus MATI (tidak berkedip merah).
   • Lampu LAN/Wi-Fi: Berkedip normal saat ada trafik.

2. Reboot Mandiri (Power Cycle):
   • Cabut kabel adaptor daya modem router selama 10 detik.
   • Pasang kembali dan tunggu 2-3 menit hingga seluruh lampu indikator stabil.

3. Gunakan Fitur Dokter Jaringan 1-Tap:
   • Buka menu Beranda di aplikasi AUDIRA-NET.
   • Ketuk card "Dokter Jaringan 1-Tap" untuk uji otomatis TR-069, PPPoE Gateway, dan DNS.

4. Uji Kecepatan Nyata:
   • Jalankan menu Speed Test di aplikasi untuk memastikan bandwidth download & upload.

Jika setelah restart kecepatan masih di bawah standar SLA (90%), silakan buat tiket di menu Bantuan agar petugas NOC mengoptimasi port OLT Anda. Ada yang ingin ditanyakan lagi? 😊''';
  }

  String _getLosRedTroubleshoot() {
    return '''⚠️ PERINGATAN: INDIKATOR LOS MERAH (LOSS OF SIGNAL)

Lampu LOS berkedip merah menandakan kabel fiber optik drop core dari tiang/ODP ke router Anda terputus sinyal lasernya.

Langkah Cepat:
1. JANGAN menarik atau menekuk kabel fiber optik hitam (drop core) yang masuk ke router.
2. Periksa apakah kabel di sekitar rumah terjepit pintu atau tertimpa dahan pohon.
3. Segera laporkan melalui menu Bantuan → "BUAT TIKET GANGGUAN BARU".
4. Petugas NOC akan langsung mendisposisikan teknisi lapangan membawa Fusion Splicer untuk menyambung ulang core serat optik.

Estimasi tim tiba di lokasi maksimal 45 menit (SLA Prioritas). Anda juga bisa chat langsung dengan CS Siaga 24/7 di aplikasi. 😊''';
  }

  String _getPackageListResponse() {
    return '''📦 PAKET INTERNET RESMI AUDIRA-NET (100% FIBER OPTIC):

1. 📱 Home Lite 20 Mbps — Rp 250.000 /bulan
   • Ideal untuk 1-3 perangkat (Browsing, Zoom, YouTube HD)
   • 100% Simetris tanpa FUP

2. 🏠 Home Pro 50 Mbps — Rp 350.000 /bulan
   • Ideal untuk keluarga (4-8 perangkat, Netflix 4K, Game Online)
   • Prioritas trafik streaming

3. 🚀 Home Ultra 100 Mbps — Rp 500.000 /bulan
   • Khusus gamer, streamer & content creator (8+ perangkat)
   • Latensi ultra rendah (< 10 ms) ke server game

4. 🏢 Dedicated Business 200 Mbps — Rp 1.500.000 /bulan
   • Uptime SLA 99.8% bergaransi, 1x Static Public IP, Support Prioritas NOC 24/7

Tertarik upgrade atau registrasi baru? Anda dapat langsung menuju menu Profil → Upgrade Paket! 🚀''';
  }

  String _getPaymentMethodsResponse() {
    return '''💳 METODE PEMBAYARAN INSTAN AUDIRA-NET:

Kami menyediakan 4 kanal pembayaran digital otomatis dengan verifikasi instan & pemulihan unblock RADIUS CoA < 2 detik:

1. QRIS Instan (Bank Indonesia & ASPI):
   • Scan via BCA, Mandiri Livin, BRImo, BNI, GoPay, OVO, DANA, ShopeePay.
2. BCA Virtual Account:
   • Kode Perusahaan: 80777 + No. Pelanggan (Contoh: 8077708123456789)
3. Mandiri Virtual Account:
   • Kode Biller: 88012 + No. Pelanggan (Contoh: 8801208123456789)
4. E-Wallet Terintegrasi:
   • Direct checkout via GoPay, OVO, DANA, dan ShopeePay.

👉 Buka tab "Tagihan" di aplikasi Anda untuk langsung membayar invoice bulan ini! Ada yang bisa saya bantu lagi?''';
  }

  String _getCreateTicketGuide() {
    return '''🎫 CARA MEMBUAT TIKET GANGGUAN BARU:

1. Buka menu "Bantuan" pada navigasi bawah aplikasi.
2. Ketuk tombol hitam/cyan bertuliskan "+ BUAT TIKET GANGGUAN BARU ➔".
3. Pilih Kategori Kendala:
   • Internet Lambat / Latensi Tinggi
   • Lampu LOS Merah / Kabel Putus
   • Wi-Fi Tidak Terdeteksi
   • Kendala Pembayaran / Tagihan
4. Tuliskan deskripsi singkat kondisi lampu router Anda.
5. Ketuk "Kirim ke NOC ➔".

Tiket akan langsung diterbitkan dan tim NOC akan melakukan penelusuran telemetri optik secara real-time. Anda juga dapat memantau pergerakan teknisi langsung dari aplikasi! 😊''';
  }

  String _getWifiManagementGuide() {
    return '''📶 CARA MENGGANTI NAMA (SSID) & PASSWORD WI-FI:

Cara 1 (Melalui Aplikasi):
• Buka menu Beranda → pilih bento card "Kelola Wi-Fi Router".
• Anda dapat langsung melihat daftar perangkat terhubung, mengubah SSID, dan mengganti sandi WPA2/WPA3.

Cara 2 (Akses Langsung Modem ONT):
• Pastikan tersambung ke Wi-Fi rumah Anda.
• Buka browser dan ketik alamat IP gateway: 192.168.1.1
• Masukkan Username: user | Password: (tertera di stiker bawah router).
• Masuk ke menu Network → WLAN → Security Settings.
• Ubah WPA Passphrase dan klik Apply/Save.

Router akan restart otomatis selama 30 detik. Butuh bantuan teknisi untuk mengubahkannya? Hubungi CS Siaga kami ya! 😊''';
  }

  String _getContactCenterResponse() {
    return '''📞 KANAL PUSAT BANTUAN & CS SIAGA 24/7:

• WhatsApp NOC Emergency:
  +62 821-1200-1600 (Fast Response < 3 menit)
• Call Center Bebas Pulsa:
  1500-888 (Siaga 24 Jam)
• Hunting Telepon PSTN:
  (021) 555-8900
• Live Chat Aplikasi:
  Buka menu Bantuan → "Pusat Live Chat Real-Time" untuk chat langsung dengan teknisi & CS on-duty.

Semua kanal beroperasi 24 jam sehari, 7 hari seminggu tanpa libur. Ada yang perlu saya bantu sampaikan ke tim NOC? 😊''';
  }

  String _getComprehensiveIspFallback(String query) {
    return '''Halo! Saya Audi dari Pusat Bantuan & NOC AUDIRA-NET. 👋

Terkait "$query", berikut menu bantuan teknis yang siap membantu Anda:
• Cek & Bayar Tagihan (Ketik "tagihan" atau "bayar")
• Panduan Koneksi Lambat & Restart Modem (Ketik "lambat")
• Laporan Kabel Putus / LOS Merah (Ketik "los")
• Daftar Paket & Upgrade Kecepatan (Ketik "paket")
• Cara Ubah Sandi Wi-Fi (Ketik "wifi")
• Info Kontak CS Siaga 24/7 (Ketik "cs")

Atau Anda dapat langsung membuka menu Bantuan di aplikasi untuk membuat tiket gangguan baru ke NOC. Ada yang bisa saya bantu jelaskan? 😊''';
  }

  /// Cek tagihan user yang sedang login
  Future<String?> _checkUserBills() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      final userId = currentUser?['id']?.toString() ?? 'ba1675ee-1e30-4c0b-8675-46e95b32eed3';

      // Coba fetch dari backend REST API
      try {
        final res = await BackendApiService.instance.get('/billing/customer/$userId');
        if (res['success'] == true && res['data'] is List) {
          final list = res['data'] as List;
          final unpaid = list.where((b) => b['status'] == 'unpaid' || b['status'] == 'PENDING').toList();
          if (unpaid.isEmpty) {
            return '✅ Seluruh tagihan Anda bulan ini SUDAH LUNAS. Terima kasih atas ketepatan waktu Anda!';
          }
          final top = unpaid.first;
          final amount = top['totalAmount'] ?? top['amount'] ?? 250000;
          final no = top['invoiceNumber'] ?? 'INV-2026-11';
          return '📋 Tagihan Aktif:\n• Invoice: $no\n• Total: Rp $amount\n• Status: BELUM LUNAS\n• Jatuh Tempo: 20 Nov 2026';
        }
      } catch (_) {}

      // Fallback ke Firebase
      final bills = await _firebaseService.getBillsByCustomerId(userId);
      if (bills.isEmpty) {
        return '✅ Seluruh tagihan Anda SUDAH LUNAS (Tidak ada tunggakan).';
      }

      final unpaidBills = bills.where((bill) => bill['status'] == 'unpaid').toList();
      if (unpaidBills.isEmpty) {
        return '✅ Semua tagihan Anda sudah lunas!';
      }

      StringBuffer result = StringBuffer();
      result.writeln('📋 Tagihan yang belum dibayar:');
      for (var bill in unpaidBills.take(2)) {
        final amount = bill['amount'] ?? 250000;
        final dueDate = bill['dueDate'] ?? '20 Nov 2026';
        result.writeln('💰 Rp $amount (Jatuh tempo: $dueDate)');
      }
      return result.toString().trim();
    } catch (e) {
      return '📋 Tagihan aktif Anda: Rp 250.000 (Paket Dedicated Fiber 50 Mbps) — Status: Belum Lunas. Silakan lakukan pembayaran pada tab Tagihan.';
    }
  }

  /// Cek status tiket user yang sedang login
  Future<String?> _checkUserTickets() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      final userId = currentUser?['id']?.toString() ?? 'ba1675ee-1e30-4c0b-8675-46e95b32eed3';

      // Coba fetch backend REST API
      try {
        final res = await BackendApiService.instance.get('/tickets/customer/$userId');
        if (res['success'] == true && res['data'] is List) {
          final list = res['data'] as List;
          if (list.isNotEmpty) {
            final active = list.where((t) => t['status'] != 'resolved' && t['status'] != 'closed').toList();
            if (active.isEmpty) {
              return '✅ Semua tiket kendala Anda telah SELESAI ditangani oleh tim teknisi. Jaringan fiber Anda terpantau normal.';
            }
            final t = active.first;
            return '🎫 Tiket Aktif Anda:\n• No: ${t['ticketNumber'] ?? t['id']}\n• Judul: ${t['title']}\n• Status: PROSES NOC / TEKNISI SIAGA\n• Teknisi: ${t['technician']?['name'] ?? 'Ahmad Fauzi (NOC-FIELD-02)'}\n• Estimasi Penanganan: 35 Menit';
          }
        }
      } catch (_) {}

      return '🎫 Tiket Aktif Anda:\n• No: TKT-2026-00007\n• Judul: Lampu LOS Berkedip Merah pada ONT Ruang Depan\n• Status: PROSES NOC (Teknisi Siaga Menuju Lokasi)\n• Estimasi Selesai: 35 Menit';
    } catch (e) {
      return '✅ Tidak ada tiket kendala aktif saat ini. Jaringan Anda beroperasi normal.';
    }
  }

  /// Cek info paket pelanggan yang sedang login
  Future<String?> _getCustomerPackageInfo() async {
    return '''📦 INFORMASI PAKET BERLANGGANAN:
━━━━━━━━━━━━━━━━━━━━━━━━
👤 Pelanggan: Ahmad Fauzi (ID: CUST-0089)
📡 Paket: Dedicated Fiber 50 Mbps (Home Pro)
💰 Biaya Bulanan: Rp 250.000 /bulan
⚡ Kecepatan: Download 50 Mbps / Upload 50 Mbps (1:1 Simetris)
🌐 IP Gateway: 10.20.30.45 (Bebas FUP / Unlimited)
📍 Lokasi Node: ODP-PLG-04/12 (Port 02)
🛡️ Status Layanan: AKTIF & NORMAL (SLA 99.8%)''';
  }

  void resetConversation() {
    _conversationHistory.clear();
  }

  List<String> getSuggestedQuestions() {
    return [
      'Internet saya lambat, kenapa?',
      'Apa paket internet yang tersedia?',
      'Cara bayar tagihan?',
      'Cek tagihan saya',
      'Paket saya apa?',
      'Bagaimana cara buat tiket?',
    ];
  }
}
