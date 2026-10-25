import 'package:flutter/material.dart';
import '../screens/auth/role_selection_page.dart';
import '../screens/auth/login_page.dart';
import '../screens/auth/unified_login_page.dart';
import '../screens/customer/customer_home.dart';
import '../screens/admin/admin_home.dart';
import '../screens/customer/payment_page.dart';
import '../screens/teknisi/barcode_scanner_page.dart';
import '../screens/teknisi/checkin_history_page.dart';
import '../screens/admin/admin_teknisi_page.dart';
import '../screens/admin/admin_tiket_page_new.dart';
import '../screens/customer/loyalty_rewards_page.dart';
import '../screens/teknisi/jadwal_teknisi_page.dart';
import '../screens/teknisi/inventory_management_page.dart';
import '../screens/teknisi/teknisi_home.dart';
import '../screens/backend_integration_test.dart';

/// Arguments class for Payment page
class PaymentArguments {
  final String billId;
  final String billMonth;
  final double amount;

  PaymentArguments({
    required this.billId,
    required this.billMonth,
    required this.amount,
  });
}

/// Route names constants
class Routes {
  // Auth routes
  static const String unifiedLogin = '/'; // New default: Single login
  static const String roleSelection = '/role-selection'; // Keep for fallback
  static const String loginCustomer = '/login-customer';
  static const String loginAdmin = '/login-admin';
  static const String loginTeknisi = '/login-teknisi';

  // Customer routes
  static const String customerHome = '/customer';
  static const String speedTest = '/customer/speed-test';
  static const String payment = '/customer/payment';
  static const String loyaltyRewards = '/customer/loyalty-rewards';

  // Admin routes
  static const String adminHome = '/admin';
  static const String adminTeknisi = '/admin/teknisi';
  static const String adminTiket = '/admin/tiket';

  // Teknisi routes
  static const String teknisiHome = '/teknisi';
  static const String barcodeScanner = '/teknisi/barcode-scanner';
  static const String checkinHistory = '/teknisi/checkin-history';
  static const String jadwalTeknisi = '/teknisi/jadwal';
  static const String inventoryManagement = '/teknisi/inventory';

  // Integration & Testing
  static const String backendTest = '/backend-integration-test';
}

/// Route generator for handling named routes
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Extract arguments if any
    final args = settings.arguments;

    switch (settings.name) {
      // Auth routes - NEW: Unified Login (Default)
      case Routes.unifiedLogin:
        return MaterialPageRoute(builder: (_) => const UnifiedLoginPage());

      // Old: Role selection (Keep for fallback/testing)
      case Routes.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionPage());

      case Routes.loginCustomer:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(isAdmin: false, isTeknisi: false),
        );

      case Routes.loginAdmin:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(isAdmin: true, isTeknisi: false),
        );

      case Routes.loginTeknisi:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(isAdmin: false, isTeknisi: true),
        );

      // Customer routes
      case Routes.customerHome:
        return MaterialPageRoute(builder: (_) => const CustomerHomePage());

      case Routes.speedTest:
      case Routes.payment:
        if (args is PaymentArguments) {
          return MaterialPageRoute(
            builder: (_) => PaymentPage(
              billId: args.billId,
              billMonth: args.billMonth,
              amount: args.amount,
            ),
          );
        }
        return _errorRoute('Payment arguments required');

      case Routes.loyaltyRewards:
        return MaterialPageRoute(builder: (_) => const LoyaltyRewardsPage());

      // Admin routesRoute('Payment arguments required');

      // Admin routes
      case Routes.adminHome:
        return MaterialPageRoute(builder: (_) => const AdminHomePage());

      case Routes.adminTeknisi:
        return MaterialPageRoute(builder: (_) => const AdminTeknisiPage());

      case Routes.adminTiket:
        return MaterialPageRoute(builder: (_) => const AdminTiketPageNew());

      // Teknisi routes
      case Routes.teknisiHome:
        return MaterialPageRoute(builder: (_) => const TeknisiHomePage());

      case Routes.checkinHistory:
        return MaterialPageRoute(builder: (_) => const CheckInHistoryPage());

      case Routes.jadwalTeknisi:
        return MaterialPageRoute(builder: (_) => const JadwalTeknisiPage());

      case Routes.inventoryManagement:
        return MaterialPageRoute(
          builder: (_) => const InventoryManagementPage(),
        );

      case Routes.barcodeScanner:
        return MaterialPageRoute(builder: (_) => const BarcodeScannerPage());

      case Routes.backendTest:
        return MaterialPageRoute(
          builder: (_) => const BackendIntegrationTest(),
        );

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
