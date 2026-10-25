import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../widgets/cyber_widgets.dart';

class PaymentPage extends StatelessWidget {
  final String billId;
  final String billMonth;
  final double amount;

  PaymentPage({
    super.key,
    dynamic billId,
    dynamic billMonth,
    dynamic amount,
  })  : billId = (billId != null && billId.toString().isNotEmpty && billId.toString() != 'null')
            ? billId.toString()
            : 'INV-GENERAL',
        billMonth = (billMonth != null && billMonth.toString().isNotEmpty && billMonth.toString() != 'null')
            ? billMonth.toString()
            : 'Periode Berjalan',
        amount = amount is num
            ? amount.toDouble()
            : (double.tryParse(amount?.toString() ?? '0') ?? 0.0);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.cyberOledBg : const Color(0xFFF1F5F9),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            LucideIcons.arrowLeft,
            size: 18,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CHECKOUT // GATEWAY PEMBAYARAN',
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            letterSpacing: 1.8,
            color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
          ),
        ),
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: isDark
                ? AppTheme.neonCyan.withValues(alpha: 0.2)
                : const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Summary Cyber Card
            CyberCard(
              accentColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TOTAL INVOICE PEMBAYARAN',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                      CyberBadge(
                        label: 'INV: $billId',
                        color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Rp ${_formatNumber(amount)}',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      CyberBadge(
                        label: 'PERIODE: $billMonth',
                        color: isDark ? AppTheme.neonAmber : const Color(0xFFD97706),
                        icon: LucideIcons.calendar,
                      ),
                      const CyberBadge(
                        label: 'STATUS: MENUNGGU PEMBAYARAN',
                        color: AppTheme.neonCrimson,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section Header
            Row(
              children: [
                CyberPulseDot(
                  color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                  size: 8,
                ),
                const SizedBox(width: 8),
                Text(
                  'METODE PEMBAYARAN TERENKRIPSI',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Virtual Account
            _PaymentMethodSection(
              title: 'VIRTUAL ACCOUNT (INSTANT CONFIRMATION)',
              methods: [
                _PaymentMethod(
                  name: 'BCA Virtual Account',
                  icon: LucideIcons.landmark,
                  color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                  onTap: () =>
                      _showVirtualAccountDialog(context, 'BCA', '1234567890'),
                ),
                _PaymentMethod(
                  name: 'Mandiri Virtual Account',
                  icon: LucideIcons.landmark,
                  color: isDark ? AppTheme.neonAmber : const Color(0xFFD97706),
                  onTap: () =>
                      _showVirtualAccountDialog(context, 'Mandiri', '9876543210'),
                ),
                _PaymentMethod(
                  name: 'BNI Virtual Account',
                  icon: LucideIcons.landmark,
                  color: isDark ? AppTheme.neonPurple : const Color(0xFF7C3AED),
                  onTap: () =>
                      _showVirtualAccountDialog(context, 'BNI', '5555666677'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // E-Wallet
            _PaymentMethodSection(
              title: 'DOMPET DIGITAL // E-WALLET',
              methods: [
                _PaymentMethod(
                  name: 'GoPay Instant',
                  icon: LucideIcons.wallet,
                  color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
                  onTap: () => _showEWalletDialog(context, 'GoPay'),
                ),
                _PaymentMethod(
                  name: 'OVO Payment',
                  icon: LucideIcons.wallet,
                  color: isDark ? AppTheme.neonPurple : const Color(0xFF7C3AED),
                  onTap: () => _showEWalletDialog(context, 'OVO'),
                ),
                _PaymentMethod(
                  name: 'DANA Digital',
                  icon: LucideIcons.wallet,
                  color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                  onTap: () => _showEWalletDialog(context, 'DANA'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // QRIS
            _PaymentMethodSection(
              title: 'QR STANDAR INDONESIA (QRIS)',
              methods: [
                _PaymentMethod(
                  name: 'Bayar via QRIS Universal',
                  icon: LucideIcons.qrCode,
                  color: AppTheme.neonCrimson,
                  onTap: () => _showQRISDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(double value) {
    return value
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void _showVirtualAccountDialog(
    BuildContext context,
    String bank,
    String vaNumber,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Icon(
              LucideIcons.landmark,
              color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              '$bank VIRTUAL ACCOUNT',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NOMOR REKENING VA:',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cyberSurfaceCard : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? AppTheme.neonCyan.withValues(alpha: 0.4)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vaNumber,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      LucideIcons.copy,
                      size: 20,
                      color: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Nomor VA berhasil disalin!'),
                          backgroundColor: isDark
                              ? AppTheme.cyberObsidian
                              : const Color(0xFF1E293B),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'TOTAL: Rp ${_formatNumber(amount)}',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Transfer nominal tepat sesuai invoice ke nomor VA di atas via m-Banking atau ATM.',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'BATAL',
              style: TextStyle(
                color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                fontFamily: 'monospace',
              ),
            ),
          ),
          CyberActionButton(
            label: 'KONFIRMASI BAYAR',
            fullWidth: false,
            primaryColor: isDark ? AppTheme.neonCyan : AppTheme.signalBlue,
            onPressed: () async {
              try {
                await FirebaseService.instance.createPayment({
                  'billId': billId,
                  'customerId': 1,
                  'amount': amount.toInt(),
                  'paymentMethod': 'Virtual Account - $bank',
                  'paymentStatus': 'completed',
                  'transactionId':
                      'VA-$vaNumber-${DateTime.now().millisecondsSinceEpoch}',
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pembayaran berhasil dikonfirmasi!'),
                      backgroundColor: AppTheme.neonGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppTheme.neonCrimson,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showEWalletDialog(BuildContext context, String wallet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? AppTheme.neonPurple : const Color(0xFF7C3AED),
            width: 1.5,
          ),
        ),
        title: Text(
          'PEMBAYARAN $wallet',
          style: TextStyle(
            fontFamily: 'monospace',
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.wallet,
              size: 56,
              color: isDark ? AppTheme.neonPurple : const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 16),
            Text(
              'TOTAL INVOICE',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Rp ${_formatNumber(amount)}',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Sistem akan mengalihkan koneksi ke aplikasi $wallet untuk autorisasi pembayaran.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'BATAL',
              style: TextStyle(
                color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                fontFamily: 'monospace',
              ),
            ),
          ),
          CyberActionButton(
            label: 'LANJUTKAN KE $wallet',
            fullWidth: false,
            primaryColor: isDark ? AppTheme.neonPurple : const Color(0xFF7C3AED),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Membuka gateway $wallet...'),
                  backgroundColor: isDark
                      ? AppTheme.cyberObsidian
                      : const Color(0xFF1E293B),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showQRISDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.cyberObsidian : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.neonCrimson, width: 1.5),
        ),
        title: Text(
          'QRIS UNIVERSAL GATEWAY',
          style: TextStyle(
            fontFamily: 'monospace',
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonCrimson, width: 2),
              ),
              child: Column(
                children: const [
                  Icon(LucideIcons.qrCode, size: 160, color: Colors.black87),
                  SizedBox(height: 8),
                  Text(
                    'NMID: ID1020039281726 // AUDIRA',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rp ${_formatNumber(amount)}',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.neonGreen : const Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Scan dengan BCA Mobile, Livin, GoPay, OVO, ShopeePay, DANA, atau aplikasi QRIS lainnya',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'TUTUP',
              style: TextStyle(
                color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
                fontFamily: 'monospace',
              ),
            ),
          ),
          CyberActionButton(
            label: 'SAYA SUDAH BAYAR',
            fullWidth: false,
            primaryColor: AppTheme.neonCrimson,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Memverifikasi status transaksi...'),
                  backgroundColor: isDark
                      ? AppTheme.cyberObsidian
                      : const Color(0xFF1E293B),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodSection extends StatelessWidget {
  final String title;
  final List<_PaymentMethod> methods;

  const _PaymentMethodSection({required this.title, required this.methods});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isDark ? AppTheme.textMuted : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        ...methods,
      ],
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PaymentMethod({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor =
        !isDark && color == AppTheme.neonAmber ? const Color(0xFFD97706) : color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cyberObsidian : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activeColor.withValues(alpha: isDark ? 0.25 : 0.35),
          width: 1.2,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: isDark ? 0.12 : 0.10),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: activeColor.withValues(alpha: isDark ? 0.3 : 0.4),
                    ),
                  ),
                  child: Icon(icon, color: activeColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: 14,
                  color: activeColor.withValues(alpha: isDark ? 0.6 : 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
