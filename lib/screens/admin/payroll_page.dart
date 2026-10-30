import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../utils/excel_exporter.dart';

/// Payroll System - Admin
/// Process employee salaries, deductions, allowances, and generate real payslips / reports
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

      final monthKey = DateFormat('yyyy-MM').format(_selectedMonth);
      final payrollSnapshot = await FirebaseFirestore.instance
          .collection('payroll')
          .where('month', isEqualTo: monthKey)
          .get();

      _payrollRecords = payrollSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      // Calculate summary
      _calculateSummary();

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      developer.log('Error loading payroll data: $e', name: 'PayrollPage');
      if (mounted) setState(() => _isLoading = false);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF05070D) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Payroll System (Penggajian)'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendar),
            tooltip: 'Pilih Periode',
            onPressed: _selectMonth,
          ),
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Muat Ulang',
            onPressed: _loadPayrollData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(LucideIcons.moreVertical),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'generate',
                child: Row(
                  children: [
                    Icon(LucideIcons.plusCircle, size: 18, color: Color(0xFF00F0FF)),
                    SizedBox(width: 8),
                    Text('Generate Payroll'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(LucideIcons.download, size: 18, color: Color(0xFF00FF9D)),
                    SizedBox(width: 8),
                    Text('Export Laporan'),
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0A0E1A), const Color(0xFF162032)]
                    : [const Color(0xFF0070F3), const Color(0xFF0051B3)],
              ),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : Colors.transparent,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PERIODE PENGGAJIAN',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMMM yyyy').format(_selectedMonth),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _selectMonth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white24),
                    ),
                  ),
                  icon: const Icon(LucideIcons.calendarDays, size: 16),
                  label: const Text('Ganti Bulan'),
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
                          LucideIcons.wallet,
                          const Color(0xFF00FF9D),
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Karyawan',
                          _payrollSummary['employeeCount'],
                          LucideIcons.users,
                          const Color(0xFF00F0FF),
                          isAmount: false,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Sudah Dibayar',
                          _payrollSummary['paidCount'],
                          LucideIcons.checkCircle2,
                          const Color(0xFF10B981),
                          isAmount: false,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryCard(
                          'Pending',
                          _payrollSummary['pendingCount'],
                          LucideIcons.clock,
                          const Color(0xFFFFB800),
                          isAmount: false,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
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
                          LucideIcons.receipt,
                          size: 64,
                          color: textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada data payroll untuk periode ini',
                          style: TextStyle(fontSize: 16, color: textMuted),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _generatePayroll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0070F3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(LucideIcons.plusCircle, size: 18),
                          label: const Text('Generate Payroll Bulan Ini'),
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
                        return _buildPayrollCard(
                          record,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          isDark: isDark,
                        );
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
    Color accentColor, {
    bool isAmount = true,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isAmount
                ? NumberFormat.currency(
                    locale: 'id_ID',
                    symbol: 'Rp ',
                    decimalDigits: 0,
                  ).format(value ?? 0)
                : (value ?? 0).toString(),
            style: TextStyle(
              fontSize: isAmount ? 16 : 22,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayrollCard(
    Map<String, dynamic> record, {
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textMuted,
    required bool isDark,
  }) {
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

    final isPaid = status == 'paid';
    final Color statusColor = isPaid
        ? const Color(0xFF10B981)
        : const Color(0xFFFFB800);
    final IconData statusIcon = isPaid
        ? LucideIcons.checkCircle
        : LucideIcons.clock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Text(
              employeeName.isNotEmpty ? employeeName[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          title: Text(
            employeeName,
            style: TextStyle(fontWeight: FontWeight.bold, color: textPrimary),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 3),
              Text(
                'ID: $employeeId',
                style: TextStyle(fontSize: 12, color: textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                'Net: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(netSalary)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF00FF9D) : const Color(0xFF059669),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RINCIAN KOMPONEN GAJI',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 0.8,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAmountRow(
                    'Gaji Pokok',
                    baseSalary,
                    isDark ? Colors.white : const Color(0xFF0F172A),
                    textColor: textPrimary,
                  ),

                  // Allowances
                  if (allowances.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Tunjangan (Allowances)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...allowances.entries.map(
                      (e) => _buildAmountRow(
                        '  + ${e.key}',
                        e.value,
                        const Color(0xFF10B981),
                        textColor: textMuted,
                      ),
                    ),
                    _buildAmountRow(
                      'Total Tunjangan',
                      totalAllowances,
                      const Color(0xFF10B981),
                      isBold: true,
                      textColor: textPrimary,
                    ),
                  ],

                  // Deductions
                  if (deductions.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Potongan (Deductions)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: const Color(0xFFFF2A5F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...deductions.entries.map(
                      (e) => _buildAmountRow(
                        '  - ${e.key}',
                        e.value,
                        const Color(0xFFFF2A5F),
                        textColor: textMuted,
                      ),
                    ),
                    _buildAmountRow(
                      'Total Potongan',
                      totalDeductions,
                      const Color(0xFFFF2A5F),
                      isBold: true,
                      textColor: textPrimary,
                    ),
                  ],

                  Divider(height: 24, color: borderColor),
                  _buildAmountRow(
                    'TOTAL GAJI BERSIH (NET)',
                    netSalary,
                    const Color(0xFF00F0FF),
                    isBold: true,
                    isLarge: true,
                    textColor: textPrimary,
                  ),
                  const SizedBox(height: 16),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (status != 'paid')
                        FilledButton.icon(
                          onPressed: () => _processPayment(record),
                          icon: const Icon(LucideIcons.creditCard, size: 16),
                          label: const Text('Bayar Gaji'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => _generatePayslip(record),
                        icon: const Icon(LucideIcons.fileText, size: 16),
                        label: const Text('Cetak Slip Gaji'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF0070F3),
                          side: const BorderSide(color: Color(0xFF0070F3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountRow(
    String label,
    dynamic amount,
    Color amountColor, {
    bool isBold = false,
    bool isLarge = false,
    required Color textColor,
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
              fontSize: isLarge ? 14 : 13,
              color: textColor,
            ),
          ),
          Text(
            NumberFormat.currency(
              locale: 'id_ID',
              symbol: 'Rp ',
              decimalDigits: 0,
            ).format(amount ?? 0),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isLarge ? 15 : 13,
              color: amountColor,
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Payroll'),
        content: Text(
          'Generate payroll untuk periode ${DateFormat('MMMM yyyy').format(_selectedMonth)}?\n\n'
          'Sistem akan memproses ${_employees.length} karyawan aktif secara otomatis dengan deduplikasi ID.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0070F3)),
            child: const Text('Generate Sekarang'),
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
        final empId = employee['employeeId']?.toString() ?? employee['id']?.toString() ?? 'EMP';
        final docId = '${empId}_$monthKey';

        // Calculate allowances (10% transport, 5% meal)
        final allowances = {
          'Transport': baseSalary * 0.10,
          'Meal': baseSalary * 0.05,
        };
        final totalAllowances = allowances.values.fold<double>(
          0,
          (total, val) => total + val,
        );

        // Calculate deductions (5% tax, 2% pension)
        final deductions = {
          'Tax (PPh 21)': baseSalary * 0.05,
          'BPJS / Pensiun': baseSalary * 0.02,
        };
        final totalDeductions = deductions.values.fold<double>(
          0,
          (total, val) => total + val,
        );

        final netSalary = baseSalary + totalAllowances - totalDeductions;

        final payrollDoc = FirebaseFirestore.instance
            .collection('payroll')
            .doc(docId);

        batch.set(payrollDoc, {
          'id': docId,
          'employeeId': empId,
          'employeeName': employee['name'] ?? 'Karyawan',
          'department': employee['department'] ?? 'General',
          'month': monthKey,
          'baseSalary': baseSalary,
          'allowances': allowances,
          'totalAllowances': totalAllowances,
          'deductions': deductions,
          'totalDeductions': totalDeductions,
          'netSalary': netSalary,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Berhasil membuat payroll untuk ${_employees.length} karyawan (${DateFormat('MMMM yyyy').format(_selectedMonth)})',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        _loadPayrollData();
      }
    } catch (e) {
      developer.log('Error generating payroll: $e', name: 'PayrollPage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal generate payroll: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _processPayment(Map<String, dynamic> record) async {
    final netSalary = (record['netSalary'] as num?)?.toDouble() ?? 0;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran'),
        content: Text(
          'Tandai gaji untuk ${record['employeeName']} sebagai SUDAH DIBAYAR?\n\n'
          'Nominal: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(netSalary)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text('Ya, Konfirmasi Bayar'),
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
            content: Text('✅ Pembayaran gaji berhasil dicatat.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        _loadPayrollData();
      }
    } catch (e) {
      developer.log('Error processing payment: $e', name: 'PayrollPage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Gagal memproses pembayaran'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Generate real official PDF payslip and open print/save dialog
  Future<void> _generatePayslip(Map<String, dynamic> record) async {
    try {
      final doc = pw.Document();

      final employeeName = record['employeeName']?.toString() ?? 'Karyawan';
      final employeeId = record['employeeId']?.toString() ?? '-';
      final department = record['department']?.toString() ?? 'Operasional';
      final month = record['month']?.toString() ?? DateFormat('yyyy-MM').format(_selectedMonth);
      final baseSalary = (record['baseSalary'] as num?)?.toDouble() ?? 0;
      final allowances = record['allowances'] as Map<String, dynamic>? ?? {};
      final deductions = record['deductions'] as Map<String, dynamic>? ?? {};
      final totalAllowances = (record['totalAllowances'] as num?)?.toDouble() ?? 0;
      final totalDeductions = (record['totalDeductions'] as num?)?.toDouble() ?? 0;
      final netSalary = (record['netSalary'] as num?)?.toDouble() ?? 0;
      final status = record['status']?.toString() ?? 'pending';

      final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'PT AUDIRA MULTIMEDIA DIGITAL',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue900,
                          ),
                        ),
                        pw.Text(
                          'AUDIRA DIGITAL NETWORK - ISP & TELECOMMUNICATIONS',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                        ),
                        pw.Text(
                          'Jl. Raya Internet No. 14, Indonesia | https://audira.my.id',
                          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: status == 'paid' ? PdfColors.green : PdfColors.orange,
                          width: 1.5,
                        ),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Text(
                        status == 'paid' ? 'LUNAS / PAID' : 'PENDING',
                        style: pw.TextStyle(
                          color: status == 'paid' ? PdfColors.green : PdfColors.orange,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.blue800),
                pw.SizedBox(height: 12),

                // Title
                pw.Center(
                  child: pw.Text(
                    'SLIP GAJI KARYAWAN (PAYSLIP)',
                    style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Periode: $month',
                    style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Employee Metadata Box
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(6),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Nama Karyawan : $employeeName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text('ID Karyawan      : $employeeId'),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Departemen   : $department'),
                          pw.SizedBox(height: 4),
                          pw.Text('Tanggal Cetak : ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}'),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),

                // Earnings & Deductions Tables
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Earnings
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('PENERIMAAN (EARNINGS)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                            pw.Divider(color: PdfColors.grey300),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Gaji Pokok'),
                                pw.Text(currency.format(baseSalary)),
                              ],
                            ),
                            ...allowances.entries.map((e) => pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 4),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(e.key),
                                  pw.Text(currency.format(e.value)),
                                ],
                              ),
                            )),
                            pw.Divider(color: PdfColors.grey300),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Total Penerimaan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                pw.Text(currency.format(baseSalary + totalAllowances), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 16),
                    // Deductions
                    pw.Expanded(
                      child: pw.Container(
                        padding: const pw.EdgeInsets.all(10),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('POTONGAN (DEDUCTIONS)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                            pw.Divider(color: PdfColors.grey300),
                            if (deductions.isEmpty)
                              pw.Text('Tidak ada potongan', style: const pw.TextStyle(color: PdfColors.grey600)),
                            ...deductions.entries.map((e) => pw.Padding(
                              padding: const pw.EdgeInsets.only(top: 4),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(e.key),
                                  pw.Text(currency.format(e.value)),
                                ],
                              ),
                            )),
                            pw.Divider(color: PdfColors.grey300),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text('Total Potongan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                pw.Text(currency.format(totalDeductions), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Net Salary Highlight Box
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue800, width: 1.5),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOTAL GAJI BERSIH (TAKE-HOME PAY)',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                      ),
                      pw.Text(
                        currency.format(netSalary),
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 36),

                // Signatures
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('Penerima,', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 50),
                        pw.Text('( $employeeName )', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Text('Finance & HRD AUDIRA,', style: const pw.TextStyle(fontSize: 10)),
                        pw.SizedBox(height: 12),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.blue700),
                            borderRadius: pw.BorderRadius.circular(3),
                          ),
                          child: pw.Text('VERIFIED DIGITAL', style: pw.TextStyle(fontSize: 8, color: PdfColors.blue800, fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.SizedBox(height: 24),
                        pw.Text('( Agus Dwi Rianto )', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                        pw.Text('Founder AUDIRA Digital', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Divider(color: PdfColors.grey400),
                pw.Center(
                  child: pw.Text(
                    'Slip gaji ini digenerate secara resmi dan terverifikasi oleh Sistem ERP AUDIRA-NET.',
                    style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                  ),
                ),
              ],
            );
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'Slip_Gaji_${employeeName.replaceAll(' ', '_')}_$month.pdf',
      );
    } catch (e) {
      developer.log('Error printing payslip: $e', name: 'PayrollPage');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Gagal membuat slip gaji: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Export payroll report dialog (Excel or PDF)
  Future<void> _exportPayrollReport() async {
    final periodTitle = DateFormat('MMMM yyyy').format(_selectedMonth);

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Export Laporan Payroll ($periodTitle)',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih format file untuk mengunduh atau membagikan rekap gaji karyawan:',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.sheet, color: Color(0xFF10B981)),
                  ),
                  title: const Text('Export ke Excel (.xlsx)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tabel komplit dengan rumus total, tunjangan, dan potongan'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    final path = await ExcelExporter.exportPayroll(_payrollRecords, periodTitle);
                    if (!mounted) return;
                    if (path != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Laporan Excel berhasil digenerate dan dishare.'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0070F3).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.fileText, color: Color(0xFF0070F3)),
                  ),
                  title: const Text('Cetak Rekap PDF', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Dokumen cetak A4 rekapitulasi gaji karyawan bulanan'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _printPayrollSummaryPdf(periodTitle);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _printPayrollSummaryPdf(String periodTitle) async {
    try {
      final doc = pw.Document();
      final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(28),
          header: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('PT AUDIRA MULTIMEDIA DIGITAL - REKAPITULASI PAYROLL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  pw.Text('Periode: $periodTitle', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.blue800),
              pw.SizedBox(height: 8),
            ],
          ),
          build: (pw.Context context) => [
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['No', 'ID', 'Nama Karyawan', 'Gaji Pokok', 'Tunjangan', 'Potongan', 'Gaji Bersih', 'Status'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 8),
              data: List<List<String>>.generate(
                _payrollRecords.length,
                (index) {
                  final r = _payrollRecords[index];
                  final base = (r['baseSalary'] as num?)?.toDouble() ?? 0;
                  final allow = (r['totalAllowances'] as num?)?.toDouble() ?? 0;
                  final deduct = (r['totalDeductions'] as num?)?.toDouble() ?? 0;
                  final net = (r['netSalary'] as num?)?.toDouble() ?? 0;
                  return [
                    '${index + 1}',
                    r['employeeId']?.toString() ?? '-',
                    r['employeeName']?.toString() ?? '-',
                    currency.format(base),
                    currency.format(allow),
                    currency.format(deduct),
                    currency.format(net),
                    (r['status']?.toString() ?? 'pending').toUpperCase(),
                  ];
                },
              ),
            ),
            pw.SizedBox(height: 14),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Text(
                    'TOTAL BERSIH KESELURUHAN: ${currency.format(_payrollSummary['totalNet'] ?? 0)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save(),
        name: 'Rekap_Payroll_${periodTitle.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      developer.log('Error printing payroll summary: $e', name: 'PayrollPage');
    }
  }
}
