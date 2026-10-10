import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/app_theme.dart';

/// Widget untuk share dengan berbagai opsi
class ShareWidget extends StatelessWidget {
  final String text;
  final String? subject;
  final List<String>? files;
  final String? label;
  final IconData icon;
  final Color? color;
  final bool outlined;

  const ShareWidget({
    super.key,
    required this.text,
    this.subject,
    this.files,
    this.label,
    this.icon = Icons.share,
    this.color,
    this.outlined = false,
  });

  Future<void> _handleShare(BuildContext context) async {
    try {
      if (files != null && files!.isNotEmpty) {
        final xFiles = files!.map((path) => XFile(path)).toList();
        await Share.shareXFiles(
          xFiles,
          text: text,
          subject: subject,
        );
      } else {
        await Share.share(
          text,
          subject: subject,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Gagal membagikan: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppTheme.primaryCyan;

    if (outlined) {
      return OutlinedButton.icon(
        onPressed: () => _handleShare(context),
        icon: Icon(icon, size: 18),
        label: Text(label ?? 'Bagikan'),
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _handleShare(context),
      icon: Icon(icon, size: 18),
      label: Text(label ?? 'Bagikan'),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

/// Icon button untuk share
class ShareIconButton extends StatelessWidget {
  final String text;
  final String? subject;
  final List<String>? files;
  final String? tooltip;
  final Color? color;

  const ShareIconButton({
    super.key,
    required this.text,
    this.subject,
    this.files,
    this.tooltip,
    this.color,
  });

  Future<void> _handleShare(BuildContext context) async {
    try {
      if (files != null && files!.isNotEmpty) {
        final xFiles = files!.map((path) => XFile(path)).toList();
        await Share.shareXFiles(
          xFiles,
          text: text,
          subject: subject,
        );
      } else {
        await Share.share(
          text,
          subject: subject,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Gagal membagikan: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.share,
        color: color ?? AppTheme.primaryCyan,
      ),
      tooltip: tooltip ?? 'Bagikan',
      onPressed: () => _handleShare(context),
    );
  }
}

/// Bottom sheet dengan opsi share
class ShareBottomSheet extends StatelessWidget {
  final String title;
  final List<ShareOption> options;

  const ShareBottomSheet({
    super.key,
    required this.title,
    required this.options,
  });

  static void show({
    required BuildContext context,
    required String title,
    required List<ShareOption> options,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ShareBottomSheet(
        title: title,
        options: options,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return _ShareOptionTile(option: option);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ShareOptionTile extends StatelessWidget {
  final ShareOption option;

  const _ShareOptionTile({required this.option});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          option.onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: option.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                option.icon,
                color: option.color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 12,
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Model untuk share option
class ShareOption {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ShareOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// Helper class untuk share functionality
class ShareHelper {
  /// Share text sederhana
  static Future<void> shareText({
    required String text,
    String? subject,
  }) async {
    await Share.share(text, subject: subject);
  }

  /// Share file
  static Future<void> shareFile({
    required String filePath,
    String? text,
    String? subject,
  }) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: text,
      subject: subject,
    );
  }

  /// Share multiple files
  static Future<void> shareFiles({
    required List<String> filePaths,
    String? text,
    String? subject,
  }) async {
    final xFiles = filePaths.map((path) => XFile(path)).toList();
    await Share.shareXFiles(
      xFiles,
      text: text,
      subject: subject,
    );
  }

  /// Share billing report
  static Future<void> shareBillingReport({
    required String customerName,
    required String period,
    required String totalAmount,
    String? filePath,
  }) async {
    final text = '''
📄 Laporan Tagihan

Pelanggan: $customerName
Periode: $period
Total Tagihan: $totalAmount

Dikirim melalui AudiraNet
    ''';

    if (filePath != null) {
      await shareFile(
        filePath: filePath,
        text: text,
        subject: 'Laporan Tagihan - $customerName',
      );
    } else {
      await shareText(
        text: text,
        subject: 'Laporan Tagihan - $customerName',
      );
    }
  }

  /// Share customer data
  static Future<void> shareCustomerData({
    required String customerName,
    required String customerId,
    required String status,
    String? address,
  }) async {
    final text = '''
👤 Data Pelanggan

Nama: $customerName
ID: $customerId
Status: $status
${address != null ? 'Alamat: $address' : ''}

Dikirim melalui AudiraNet
    ''';

    await shareText(
      text: text,
      subject: 'Data Pelanggan - $customerName',
    );
  }

  /// Share app recommendation
  static Future<void> shareApp() async {
    const text = '''
🌐 AudiraNet - Sistem Manajemen Internet

Aplikasi untuk mengelola pelanggan internet, tagihan, dan pembayaran.

Download sekarang!
    ''';

    await shareText(
      text: text,
      subject: 'Rekomendasi Aplikasi AudiraNet',
    );
  }
}
