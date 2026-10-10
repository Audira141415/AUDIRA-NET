import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

/// Payroll System - Admin
/// Process employee salaries, deductions, allowances, and generate payslips
class PayrollPage extends StatefulWidget {
  const PayrollPage({super.key});

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _payrollRecords = [];
  Map<String, dynamic> _payrollSummary = {};

  @override
  void initState() {
    super.initState();
    _loadPayrollData();
  }

  Future<void> _loadPayrollData() async {
    setState(() => _isLoading = true);
    try {
      // Load active employees
      final employeesSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('status', isEqualTo: 'active')
          .get();

      _employees = employeesSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // Load payroll records for selected month
      final startOfMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month,
        1,
      );
      final endOfMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
        0,
      );

      final payrollSnapshot = await FirebaseFirestore.instance
          .collection('payroll')
          .where(
            'month',
            isEqualTo: DateFormat('yyyy-MM').format(_selectedMonth),
          )
          .get();

      _payrollRecords = payrollSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // Calculate summary
      _calculateSummary();

      setState(() => _isLoading = false);
    } catch (e) {
      developer.log('Error loading payroll data: $e', name: 'PayrollPage');
      setState(() => _isLoading = false);
    }
  }

  void _calculateSummary() {
    double totalGrossSalary = 0;
    double totalDeductions = 0;
    double totalAllowances = 0;
    double totalNetSalary = 0;

    for (var record in _payrollRecords) {
      totalGrossSalary += (record['baseSalary'] as num?)?.toDouble() ?? 0;
      totalDeductions += (record['totalDeductions'] as num?)?.toDouble() ?? 0;
      totalAllowances += (record['totalAllowances'] as num?)?.toDouble() ?? 0;
      totalNetSalary += (record['netSalary'] as num?)?.toDouble() ?? 0;
    }

    _payrollSummary = {
      'totalGross': totalGrossSalary,
      'totalDeductions': totalDeductions,
      'totalAllowances': totalAllowances,
      'totalNet': totalNetSalary,
      'employeeCount': _payrollRecords.length,
      'pendingCount': _payrollRecords
          .where((r) => r['status'] == 'pending')
          .length,
      'paidCount': _payrollRecords.where((r) => r['status'] == 'paid').length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll System'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectMonth,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPayrollData,
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate',
                child: Row(
                  children: [
                    Icon(Icons.add_circle),
                    SizedBox(width: 8),
                    Text('Generate Payroll'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export Report'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'generate') {
                _generatePayroll();
              } else if (value == 'export') {
                _exportPayrollReport();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payroll Period',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _selectMonth,
                  icon: const Icon(Icons.edit_calendar, color: Colors.white),
                ),
              ],
            ),
          ),

          // Summary Cards
          if (!_isLoading && _payrollRecords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Payroll',
                          _payrollSummary['totalNet'],
                          Icons.account_balance_wallet,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Employees',
                          _payrollSummary['employeeCount'],
                          Icons.people,
                          Colors.blue,
                          isAmount: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Paid',
                          _payrollSummary['paidCount'],
                          Icons.check_circle,
                          Colors.green,
                          isAmount: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Pending',
                          _payrollSummary['pendingCount'],
                          Icons.pending,
                          Colors.orange,
                          isAmount: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Payroll List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _payrollRecords.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No payroll records for this month',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _generatePayroll,
                          icon: const Icon(Icons.add_circle),
                          label: const Text('Generate Payroll'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadPayrollData,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _payrollRecords.length,
                      itemBuilder: (context, index) {
                        final record = _payrollRecords[index];
                        return _buildPayrollCard(record);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    dynamic value,
    IconData icon,
    Color color, {
    bool isAmount = true,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              isAmount
                  ? NumberFormat.currency(
                      locale: 'id_ID',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(value)
                  : value.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollCard(Map<String, dynamic> record) {
    final employeeName = record['employeeName'] as String? ?? 'Unknown';
    final employeeId = record['employeeId'] as String? ?? '-';
    final baseSalary = (record['baseSalary'] as num?)?.toDouble() ?? 0;
    final totalAllowances =
        (record['totalAllowances'] as num?)?.toDouble() ?? 0;
    final totalDeductions =
        (record['totalDeductions'] as num?)?.toDouble() ?? 0;
    final netSalary = (record['netSalary'] as num?)?.toDouble() ?? 0;
    final status = record['status'] as String? ?? 'pending';
    final allowances = record['allowances'] as Map<String, dynamic>? ?? {};
    final deductions = record['deductions'] as Map<String, dynamic>? ?? {};

    Color statusColor = status == 'paid' ? Colors.green : Colors.orange;
    IconData statusIcon = status == 'paid' ? Icons.check_circle : Icons.pending;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Text(
            employeeName.isNotEmpty ? employeeName[0].toUpperCase() : '?',
            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
          ),
        ),
        title: Text(
          employeeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('ID: $employeeId'),
            Text(
              'Net Salary: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(netSalary)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            status.toUpperCase(),
            style: TextStyle(fontSize: 10, color: statusColor),
          ),
          backgroundColor: statusColor.withOpacity(0.1),
          avatar: Icon(statusIcon, size: 16, color: statusColor),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salary Breakdown
                const Text(
                  'Salary Breakdown',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildAmountRow('Base Salary', baseSalary, Colors.blue),

                // Allowances
                if (allowances.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Allowances',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  ...allowances.entries.map(
                    (e) => _buildAmountRow('  ${e.key}', e.value, Colors.green),
                  ),
                  _buildAmountRow(
                    'Total Allowances',
                    totalAllowances,
                    Colors.green.shade700,
                    isBold: true,
                  ),
                ],

                // Deductions
                if (deductions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Deductions',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  ...deductions.entries.map(
                    (e) => _buildAmountRow('  ${e.key}', e.value, Colors.red),
                  ),
                  _buildAmountRow(
                    'Total Deductions',
                    totalDeductions,
                    Colors.red.shade700,
                    isBold: true,
                  ),
                ],

                const Divider(height: 24),
                _buildAmountRow(
                  'NET SALARY',
                  netSalary,
                  Colors.purple,
                  isBold: true,
                  isLarge: true,
                ),
                const SizedBox(height: 16),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (status != 'paid')
                      FilledButton.icon(
                        onPressed: () => _processPayment(record),
                        icon: const Icon(Icons.payment, size: 18),
                        label: const Text('Process Payment'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _generatePayslip(record),
                      icon: const Icon(Icons.receipt, size: 18),
                      label: const Text('Payslip'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    dynamic amount,
    Color color, {
    bool isBold = false,
    bool isLarge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isLarge ? 16 : 13,
              color: isBold ? color : Colors.black87,
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isLarge ? 16 : 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() => _selectedMonth = picked);
      _loadPayrollData();
    }
  }

  Future<void> _generatePayroll() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Payroll'),
        content: Text(
          'Generate payroll for ${DateFormat('MMMM yyyy').format(_selectedMonth)}?\n\n'
          'This will create payroll records for ${_employees.length} active employees.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Generate'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final monthKey = DateFormat('yyyy-MM').format(_selectedMonth);
      final batch = FirebaseFirestore.instance.batch();

      for (var employee in _employees) {
        final baseSalary = (employee['salary'] as num?)?.toDouble() ?? 0;

        // Calculate allowances (example: 10% transport, 5% meal)
        final allowances = {
          'Transport': baseSalary * 0.10,
          'Meal': baseSalary * 0.05,
        };
        final totalAllowances = allowances.values.fold<double>(
          0,
          (sum, val) => sum + val,
        );

        // Calculate deductions (example: 5% tax, 2% pension)
        final deductions = {
          'Tax': baseSalary * 0.05,
          'Pension': baseSalary * 0.02,
        };
        final totalDeductions = deductions.values.fold<double>(
          0,
          (sum, val) => sum + val,
        );

        final netSalary = baseSalary + totalAllowances - totalDeductions;

        final payrollDoc = FirebaseFirestore.instance
            .collection('payroll')
            .doc();
        batch.set(payrollDoc, {
          'employeeId': employee['employeeId'],
          'employeeName': employee['name'],
          'month': monthKey,
          'baseSalary': baseSalary,
          'allowances': allowances,
          'totalAllowances': totalAllowances,
          'deductions': deductions,
          'totalDeductions': totalDeductions,
          'netSalary': netSalary,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payroll generated for ${_employees.length} employees',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadPayrollData();
      }
    } catch (e) {
      developer.log('Error generating payroll: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error generating payroll'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPayment(Map<String, dynamic> record) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: Text(
          'Mark payment as processed for ${record['employeeName']}?\n\n'
          'Amount: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(record['netSalary'])}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('payroll')
          .doc(record['id'])
          .update({'status': 'paid', 'paidAt': FieldValue.serverTimestamp()});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPayrollData();
      }
    } catch (e) {
      developer.log('Error processing payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error processing payment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generatePayslip(Map<String, dynamic> record) async {
    // Mock PDF generation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Payslip'),
        content: const Text(
          'PDF payslip generation feature will be available soon.\n\n'
          'This will generate a detailed payslip PDF with all salary components.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportPayrollReport() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Report'),
        content: const Text(
          'Export payroll report feature will be available soon.\n\n'
          'You will be able to export in PDF, Excel, or CSV format.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
