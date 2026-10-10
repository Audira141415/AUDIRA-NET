import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'logger_service.dart';

/// Backend API Service for communicating with NestJS backend
/// Provides HTTP methods with automatic authentication and error handling
class BackendApiService {
  static final BackendApiService instance = BackendApiService._init();
  BackendApiService._init();

  String? _authToken;

  // Set authentication token
  void setAuthToken(String? token) {
    _authToken = token;
  }

  // Get headers with authentication
  Map<String, String> _getHeaders({Map<String, String>? additionalHeaders}) {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Check if backend is healthy and accessible
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.getUrl(ApiConfig.health)),
            headers: _getHeaders(),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        LoggerService.info('✅ Backend health check: OK');
        return true;
      } else {
        LoggerService.warning(
          '⚠️ Backend health check failed: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      LoggerService.error('❌ Backend health check error: $e');
      return false;
    }
  }

  /// GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      var uri = Uri.parse(ApiConfig.getUrl(endpoint));

      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      LoggerService.info('🔍 GET: $uri');

      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      LoggerService.error('❌ GET Error ($endpoint): $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(endpoint));

      LoggerService.info('📤 POST: $uri');
      LoggerService.info('   Body: ${json.encode(data)}');

      final response = await http
          .post(uri, headers: _getHeaders(), body: json.encode(data))
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      LoggerService.error('❌ POST Error ($endpoint): $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(endpoint));

      LoggerService.info('✏️ PUT: $uri');
      LoggerService.info('   Body: ${json.encode(data)}');

      final response = await http
          .put(uri, headers: _getHeaders(), body: json.encode(data))
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      LoggerService.error('❌ PUT Error ($endpoint): $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse(ApiConfig.getUrl(endpoint));

      LoggerService.info('🗑️ DELETE: $uri');

      final response = await http
          .delete(uri, headers: _getHeaders())
          .timeout(ApiConfig.receiveTimeout);

      return _handleResponse(response);
    } catch (e) {
      LoggerService.error('❌ DELETE Error ($endpoint): $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    LoggerService.info('📥 Response: ${response.statusCode}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true, 'data': null};
      }

      try {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } catch (e) {
        return {'success': true, 'data': response.body};
      }
    } else {
      String errorMessage =
          'Request failed with status: ${response.statusCode}';

      try {
        final errorData = json.decode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (e) {
        // Use default error message
      }

      LoggerService.error('❌ Error: $errorMessage');
      return {
        'success': false,
        'error': errorMessage,
        'statusCode': response.statusCode,
      };
    }
  }

  // ============== Specific API Methods ==============

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    return await get(ApiConfig.dashboard);
  }

  /// Get customers list
  Future<Map<String, dynamic>> getCustomers({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    return await get('/pelanggan', queryParams: queryParams);
  }

  /// Get customer by ID
  Future<Map<String, dynamic>> getCustomerById(String id) async {
    return await get('/pelanggan/$id');
  }

  /// Get invoices list
  Future<Map<String, dynamic>> getInvoices({
    int page = 1,
    int limit = 10,
    String? status,
    String? customerId,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    if (customerId != null && customerId.isNotEmpty) {
      queryParams['customerId'] = customerId;
    }

    return await get(ApiConfig.invoices, queryParams: queryParams);
  }

  /// Create payment
  Future<Map<String, dynamic>> createPayment({
    required String invoiceId,
    required double amount,
    String? paymentMethod,
  }) async {
    return await post(ApiConfig.payments, {
      'invoiceId': invoiceId,
      'amount': amount,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
    });
  }

  /// Get payment status
  Future<Map<String, dynamic>> getPaymentStatus(String orderId) async {
    return await get('${ApiConfig.payments}/$orderId/status');
  }

  /// Get analytics revenue
  Future<Map<String, dynamic>> getRevenueAnalytics({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};

    if (startDate != null) queryParams['start'] = startDate;
    if (endDate != null) queryParams['end'] = endDate;

    return await get(ApiConfig.revenue, queryParams: queryParams);
  }
}
