import 'package:flutter/material.dart';
import '../services/backend_api_service.dart';
import '../services/hybrid_billing_service.dart';

/// Backend Integration Testing Screen
/// Helps verify the connection between Flutter app and NestJS backend
class BackendIntegrationTest extends StatefulWidget {
  const BackendIntegrationTest({super.key});

  @override
  State<BackendIntegrationTest> createState() => _BackendIntegrationTestState();
}

class _BackendIntegrationTestState extends State<BackendIntegrationTest> {
  final BackendApiService _backendApi = BackendApiService.instance;
  final HybridBillingService _hybridService = HybridBillingService.instance;

  bool _isLoading = false;
  final Map<String, dynamic> _testResults = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backend Integration Test'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_outlined,
                      size: 48,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Backend Integration Test',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Test connection with NestJS backend',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Test Buttons
            _buildTestButton(
              'Health Check',
              Icons.health_and_safety,
              Colors.green,
              _testHealthCheck,
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              'Dashboard Stats',
              Icons.dashboard,
              Colors.orange,
              _testDashboardStats,
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              'Get Customers',
              Icons.people,
              Colors.purple,
              _testGetCustomers,
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              'Get Invoices',
              Icons.receipt,
              Colors.blue,
              _testGetInvoices,
            ),
            const SizedBox(height: 12),
            _buildTestButton(
              'Hybrid Service Test',
              Icons.sync_alt,
              Colors.teal,
              _testHybridService,
            ),
            const SizedBox(height: 24),

            // Results
            if (_testResults.isNotEmpty) ...[
              const Text(
                'Test Results:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _testResults.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              entry.value['success'] == true
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: entry.value['success'] == true
                                  ? Colors.green
                                  : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    entry.value.toString(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],

            // Loading
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        minimumSize: const Size.fromHeight(50),
      ),
    );
  }

  Future<void> _testHealthCheck() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    try {
      final isHealthy = await _backendApi.checkHealth();

      setState(() {
        _testResults['Health Check'] = {
          'success': isHealthy,
          'message': isHealthy
              ? '✅ Backend is healthy and accessible'
              : '❌ Backend is not accessible',
        };
      });
    } catch (e) {
      setState(() {
        _testResults['Health Check'] = {
          'success': false,
          'error': e.toString(),
        };
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testDashboardStats() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    try {
      final response = await _backendApi.getDashboardStats();

      setState(() {
        _testResults['Dashboard Stats'] = response;
      });
    } catch (e) {
      setState(() {
        _testResults['Dashboard Stats'] = {
          'success': false,
          'error': e.toString(),
        };
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetCustomers() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    try {
      final response = await _backendApi.getCustomers(page: 1, limit: 5);

      setState(() {
        _testResults['Get Customers'] = response;
      });
    } catch (e) {
      setState(() {
        _testResults['Get Customers'] = {
          'success': false,
          'error': e.toString(),
        };
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testGetInvoices() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    try {
      final response = await _backendApi.getInvoices(page: 1, limit: 5);

      setState(() {
        _testResults['Get Invoices'] = response;
      });
    } catch (e) {
      setState(() {
        _testResults['Get Invoices'] = {
          'success': false,
          'error': e.toString(),
        };
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testHybridService() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    try {
      // Test hybrid service
      final customers = await _hybridService.getCustomers(page: 1, limit: 3);
      final stats = await _hybridService.getDashboardStats();

      setState(() {
        _testResults['Hybrid Service'] = {
          'success': true,
          'dataSource': _hybridService.dataSource,
          'customersCount': customers.length,
          'stats': stats,
        };
      });
    } catch (e) {
      setState(() {
        _testResults['Hybrid Service'] = {
          'success': false,
          'error': e.toString(),
        };
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
