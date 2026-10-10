import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Audira Digital Network';
  static const String appVersion = '1.0.0';
  static const String companyName = 'Audira Digital Network';

  // Contact Info
  static const String supportEmail = 'cs@audiranet.com';
  static const String supportPhone = '1500-888';
  static const String supportWhatsApp = '0812-3456-7890';
  static const String supportWhatsAppFull = '6281234567890';
  static const String techSupportPhone = '02112345678';
  static const String techSupportEmail = 'support@audiranet.com';

  // Customer Service
  static const String csEmail = 'cs@audiranet.com';
  static const String csCallCenter = '1500-888';
  static const String csWhatsApp = '0812-3456-7890';

  // Operating Hours
  static const String weekdayHours = 'Senin - Jumat: 08:00 - 20:00';
  static const String weekendHours = 'Sabtu - Minggu: 09:00 - 17:00';

  // Admin Credentials (for display only)
  static const String adminName = 'Admin Audira';
  static const String adminEmail = 'admin@audiranet.com';

  // Demo Data
  static const String demoCustomerName = 'Budi Santoso';
  static const String demoCustomerPackage = '50 Mbps Unlimited';
  static const int demoCustomerSpeed = 50;

  // API
  static const String apiBaseUrl = 'https://api.audiranet.com/v1';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Points & Rewards
  static const int dailyCheckInPoints = 10;
  static const int ticketCompletedPoints = 20;
  static const int installationCompletedPoints = 50;

  // Performance Metrics (Demo)
  static const int demoTicketsCompleted = 45;
  static const int demoInstallationsCompleted = 12;
  static const double demoRating = 4.8;
  static const String demoResponseTime = '15m';
}

class AppColors {
  static const Color primary = Color(0xFF3F51B5); // Indigo
  static const Color secondary = Color(0xFF448AFF);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}

class AppStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle body1 = TextStyle(fontSize: 16);

  static const TextStyle body2 = TextStyle(fontSize: 14);

  static const TextStyle caption = TextStyle(fontSize: 12, color: Colors.grey);
}
