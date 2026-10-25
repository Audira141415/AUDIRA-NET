import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/firebase_service.dart';
import '../../../services/auth_service.dart';
import '../../../utils/app_theme.dart';
import '../checkin_history_page.dart';

/// Card status kehadiran dan check-in teknisi bergaya Utilitas Modern (Clean Minimalist)
class TeknisiDutyCard extends StatelessWidget {
  final bool hasCheckedIn;
  final Map<String, dynamic>? rewardData;
  final VoidCallback onCheckInSuccess;

  const TeknisiDutyCard({
    super.key,
    required this.hasCheckedIn,
    this.rewardData,
    required this.onCheckInSuccess,
  });

  Future<void> _performCheckIn(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.front,
      );

      if (photo == null) return;

      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(color: AppTheme.signalBlue),
        ),
      );

      final userId = AuthService.instance.currentUser?.id;
      if (userId == null) {
        if (context.mounted) Navigator.pop(context);
        throw Exception('Teknisi tidak ditemukan');
      }

      final result = await FirebaseService.instance.createCheckIn({
        'technicianId': userId,
        'checkinTime': FieldValue.serverTimestamp(),
        'location': 'Lapangan',
        'photo': photo.path,
      });

      if (!context.mounted) return;
      Navigator.pop(context); // Tutup loading

      onCheckInSuccess();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-in berhasil! +${result['points'] ?? 10} Poin | Streak: ${result['currentStreak'] ?? 1} hari',
          ),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal check-in: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);
    final titleColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final subColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Status Indicator Dot
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasCheckedIn
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  boxShadow: [
                    BoxShadow(
                      color: (hasCheckedIn
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B))
                          .withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                hasCheckedIn ? 'STATUS: AKTIF BERTUGAS' : 'STATUS: BELUM ABSEN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: hasCheckedIn
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                ),
              ),
              const Spacer(),
              // Riwayat Link
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckInHistoryPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 16,
                        color: subColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: subColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasCheckedIn
                          ? 'Siap Melayani Pelanggan'
                          : 'Mulai Shift Hari Ini',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasCheckedIn
                          ? (rewardData != null
                              ? 'Streak: ${rewardData!['currentStreak'] ?? 0} hari • ${rewardData!['totalPoints'] ?? 0} poin performa'
                              : 'Presensi harian telah terverifikasi.')
                          : 'Ambil foto selfie kehadiran untuk memulai dinas.',
                      style: TextStyle(
                        fontSize: 13,
                        color: subColor,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (!hasCheckedIn) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _performCheckIn(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.signalBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt_outlined, size: 18),
                  label: const Text(
                    'Absen',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
