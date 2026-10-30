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
  static const String customerTelemetry = '/customer/telemetry';
  static String invoiceBreakdown(String id) => '/billing/invoices/$id/breakdown';
  static String payInvoice(String id) => '/billing/invoices/$id/pay';
  static String receiptPdf(String id) => '/billing/receipt/$id/pdf';


  // Analytics endpoints
  static const String analytics = '/analytics';
  static const String dashboard = '/analytics/dashboard';
  static const String revenue = '/analytics/revenue';

  // Settings
  static const String settings = '/settings';

  // Telegram Operations Hub
  static const String telegramStatus = '/telegram/status';
  static const String telegramTopics = '/telegram/topics';
  static const String telegramBroadcast = '/telegram/broadcast';

  // Speedtest & SLA Benchmarking
  static const String speedtestServers = '/speedtest/servers';
  static const String speedtestPing = '/speedtest/ping';
  static const String speedtestDownload = '/speedtest/download';
  static const String speedtestUpload = '/speedtest/upload';
  static const String speedtestRun = '/speedtest/run';
  static const String speedtestHistory = '/speedtest/history';

  // Timeouts (Optimized for responsive mobile UX)
  static const Duration connectionTimeout = Duration(seconds: 6);
  static const Duration receiveTimeout = Duration(seconds: 6);


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
