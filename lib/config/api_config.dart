/// API Configuration for Backend Integration
/// Supports both development and production environments
class ApiConfig {
  // Base URLs
  static const String devBaseUrl = 'http://localhost:3218';
  static const String prodBaseUrl = 'https://api.audiranet.com';

  // Environment selection
  static const bool isDevelopment = true; // Change to false for production

  static String get baseUrl => isDevelopment ? devBaseUrl : prodBaseUrl;

  // API Endpoints
  static const String health = '/health';
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';

  // Billing endpoints
  static const String billing = '/billing';
  static const String invoices = '/invoices';
  static const String payments = '/payments';
  static const String customers = '/customers';

  // Analytics endpoints
  static const String analytics = '/analytics';
  static const String dashboard = '/analytics/dashboard';
  static const String revenue = '/analytics/revenue';

  // Settings
  static const String settings = '/settings';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Get full endpoint URL
  static String getUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
