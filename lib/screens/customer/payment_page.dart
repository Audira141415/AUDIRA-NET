import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../services/firebase_service.dart';

class PaymentPage extends StatelessWidget {
  final String billId;
  final String billMonth;
  final double amount;

  const PaymentPage({
    super.key,
    required this.billId,
    required this.billMonth,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pilih Metode Pembayaran'),
        backgroundColor: AppTheme.primaryCyan,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bill Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade700, Colors.blue.shade900],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_formatNumber(amount)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tagihan $billMonth',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Methods
            Text(
              'Pilih Metode Pembayaran',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 16),

            // Virtual Account
            _PaymentMethodSection(
              title: 'Virtual Account',
              methods: [
                _PaymentMethod(
                  name: 'BCA Virtual Account',
                  icon: Icons.account_balance,
                  color: Colors.blue,
                  onTap: () =>
                      _showVirtualAccountDialog(context, 'BCA', '1234567890'),
                ),
                _PaymentMethod(
                  name: 'Mandiri Virtual Account',
                  icon: Icons.account_balance,
                  color: Colors.yellow.shade800,
                  onTap: () => _showVirtualAccountDialog(
                    context,
                    'Mandiri',
                    '9876543210',
                  ),
                ),
                _PaymentMethod(
                  name: 'BNI Virtual Account',
                  icon: Icons.account_balance,
                  color: Colors.orange,
                  onTap: () =>
                      _showVirtualAccountDialog(context, 'BNI', '5555666677'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // E-Wallet
            _PaymentMethodSection(
              title: 'E-Wallet',
              methods: [
                _PaymentMethod(
                  name: 'GoPay',
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                  onTap: () => _showEWalletDialog(context, 'GoPay'),
                ),
                _PaymentMethod(
                  name: 'OVO',
                  icon: Icons.account_balance_wallet,
                  color: Colors.purple,
                  onTap: () => _showEWalletDialog(context, 'OVO'),
                ),
                _PaymentMethod(
                  name: 'DANA',
                  icon: Icons.account_balance_wallet,
                  color: Colors.blue,
                  onTap: () => _showEWalletDialog(context, 'DANA'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // QRIS
            _PaymentMethodSection(
              title: 'QRIS',
              methods: [
                _PaymentMethod(
                  name: 'Bayar dengan QRIS',
                  icon: Icons.qr_code_scanner,
                  color: Colors.red,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$bank Virtual Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nomor Virtual Account:',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vaNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nomor VA disalin!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: Rp ${_formatNumber(amount)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Silakan transfer ke nomor VA di atas melalui mobile banking atau ATM $bank.',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Save payment to database
              try {
                await FirebaseService.instance.createPayment({
                  'billId': billId,
                  'customerId': 1, // Hardcoded for demo
                  'amount': amount.toInt(),
                  'paymentMethod': 'Virtual Account - $bank',
                  'paymentStatus': 'completed',
                  'transactionId':
                      'VA-$vaNumber-${DateTime.now().millisecondsSinceEpoch}',
                });

                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Back to bills with success
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pembayaran berhasil disimpan!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Konfirmasi Pembayaran'),
          ),
        ],
      ),
    );
  }

  void _showEWalletDialog(BuildContext context, String wallet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pembayaran $wallet'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet,
              size: 64,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              'Total Pembayaran',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            Text(
              'Rp ${_formatNumber(amount)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Anda akan diarahkan ke aplikasi $wallet untuk menyelesaikan pembayaran.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Membuka $wallet...')));
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  void _showQRISDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('QRIS Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: Column(
                children: [
                  Icon(Icons.qr_code_2, size: 150, color: Colors.grey[800]),
                  const SizedBox(height: 12),
                  Text(
                    'Scan QR Code',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rp ${_formatNumber(amount)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan dengan aplikasi mobile banking atau e-wallet Anda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menunggu pembayaran...')),
              );
            },
            child: const Text('Sudah Bayar'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
