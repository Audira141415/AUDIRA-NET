import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.audiranet.com/v1';
  static const Duration timeout = Duration(seconds: 30);

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  /// HTTP GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      developer.log('GET Request: $uri', name: 'ApiService');

      final response = await http
          .get(uri, headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      developer.log('GET Error: $e', name: 'ApiService');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to fetch data',
      };
    }
  }

  /// HTTP POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      developer.log('POST Request: $uri', name: 'ApiService');

      final response = await http
          .post(uri, headers: _getHeaders(), body: json.encode(data))
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      developer.log('POST Error: $e', name: 'ApiService');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to send data',
      };
    }
  }

  /// HTTP PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      developer.log('PUT Request: $uri', name: 'ApiService');

      final response = await http
          .put(uri, headers: _getHeaders(), body: json.encode(data))
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      developer.log('PUT Error: $e', name: 'ApiService');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to update data',
      };
    }
  }

  /// HTTP DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      developer.log('DELETE Request: $uri', name: 'ApiService');

      final response = await http
          .delete(uri, headers: _getHeaders())
          .timeout(timeout);

      return _handleResponse(response);
    } catch (e) {
      developer.log('DELETE Error: $e', name: 'ApiService');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to delete data',
      };
    }
  }

  /// Get common headers
  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    developer.log(
      'Response Status: ${response.statusCode}',
      name: 'ApiService',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
          'statusCode': response.statusCode,
        };
      } catch (e) {
        return {
          'success': true,
          'data': response.body,
          'statusCode': response.statusCode,
        };
      }
    } else {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Request failed with status ${response.statusCode}',
        'error': response.body,
      };
    }
  }
}
