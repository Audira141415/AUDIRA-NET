import 'package:intl/intl.dart';

class Formatters {
  // Format currency
  static String formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  // Format date
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  // Format date with time
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(date);
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  // Format data usage
  static String formatDataUsage(double gb) {
    if (gb < 1) {
      return '${(gb * 1024).toStringAsFixed(0)} MB';
    }
    return '${gb.toStringAsFixed(1)} GB';
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return '';

    // Remove all non-numeric characters
    final cleaned = phone.replaceAll(RegExp(r'\D'), '');

    // Format as: 0812-3456-7890
    if (cleaned.length >= 10) {
      return '${cleaned.substring(0, 4)}-${cleaned.substring(4, 8)}-${cleaned.substring(8)}';
    }
    return phone;
  }

  // Format speed
  static String formatSpeed(int mbps) {
    if (mbps < 1000) {
      return '$mbps Mbps';
    }
    return '${(mbps / 1000).toStringAsFixed(1)} Gbps';
  }
}
