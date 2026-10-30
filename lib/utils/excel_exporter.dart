import 'dart:io';
import 'dart:developer' as developer;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class ExcelExporter {
  /// Export customers to Excel
  static Future<String?> exportCustomers(
    List<Map<String, dynamic>> customers,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Customers'];

      // Header row
      sheet.appendRow([
        TextCellValue('Customer ID'),
        TextCellValue('Name'),
        TextCellValue('Email'),
        TextCellValue('Phone'),
        TextCellValue('Address'),
        TextCellValue('Package'),
        TextCellValue('Status'),
        TextCellValue('Activation Date'),
      ]);

      // Style header
      for (int i = 0; i < 8; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }

      // Data rows
      for (var customer in customers) {
        sheet.appendRow([
          TextCellValue(customer['customerId']?.toString() ?? '-'),
          TextCellValue(customer['name']?.toString() ?? '-'),
          TextCellValue(customer['email']?.toString() ?? '-'),
          TextCellValue(customer['phone']?.toString() ?? '-'),
          TextCellValue(customer['address']?.toString() ?? '-'),
          TextCellValue(customer['package']?['name']?.toString() ?? '-'),
          TextCellValue(customer['status']?.toString() ?? '-'),
          TextCellValue(
            customer['activationDate'] != null
                ? DateFormat('dd/MM/yyyy').format(
                    DateTime.parse(customer['activationDate'].toString()),
                  )
                : '-',
          ),
        ]);
      }

      // Auto-fit columns
      for (int i = 0; i < 8; i++) {
        sheet.setColumnWidth(i, 20);
      }

      return await _saveAndShare(excel, 'Customers_Report');
    } catch (e) {
      developer.log('Error exporting customers: $e', name: 'ExcelExporter');
      return null;
    }
  }

  /// Export tickets to Excel
  static Future<String?> exportTickets(
    List<Map<String, dynamic>> tickets,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Tickets'];

      // Header row
      sheet.appendRow([
        TextCellValue('Ticket ID'),
        TextCellValue('Customer'),
        TextCellValue('Subject'),
        TextCellValue('Priority'),
        TextCellValue('Status'),
        TextCellValue('Zone'),
        TextCellValue('Created At'),
        TextCellValue('Resolved At'),
      ]);

      // Style header
      for (int i = 0; i < 8; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.green,
          fontColorHex: ExcelColor.white,
        );
      }

      // Data rows
      for (var ticket in tickets) {
        sheet.appendRow([
          TextCellValue(ticket['ticketId']?.toString() ?? '-'),
          TextCellValue(ticket['customerName']?.toString() ?? '-'),
          TextCellValue(ticket['subject']?.toString() ?? '-'),
          TextCellValue(ticket['priority']?.toString() ?? '-'),
          TextCellValue(ticket['status']?.toString() ?? '-'),
          TextCellValue(ticket['zone']?.toString() ?? '-'),
          TextCellValue(
            ticket['createdAt'] != null
                ? DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(DateTime.parse(ticket['createdAt'].toString()))
                : '-',
          ),
          TextCellValue(
            ticket['resolvedAt'] != null
                ? DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(DateTime.parse(ticket['resolvedAt'].toString()))
                : '-',
          ),
        ]);
      }

      // Auto-fit columns
      for (int i = 0; i < 8; i++) {
        sheet.setColumnWidth(i, 20);
      }

      return await _saveAndShare(excel, 'Tickets_Report');
    } catch (e) {
      developer.log('Error exporting tickets: $e');
      return null;
    }
  }

  /// Export payments to Excel
  static Future<String?> exportPayments(
    List<Map<String, dynamic>> payments,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Payments'];

      // Header row
      sheet.appendRow([
        TextCellValue('Payment ID'),
        TextCellValue('Customer'),
        TextCellValue('Amount'),
        TextCellValue('Method'),
        TextCellValue('Status'),
        TextCellValue('Payment Date'),
        TextCellValue('Notes'),
      ]);

      // Style header
      for (int i = 0; i < 7; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.orange,
          fontColorHex: ExcelColor.white,
        );
      }

      // Data rows
      for (var payment in payments) {
        sheet.appendRow([
          TextCellValue(payment['paymentId']?.toString() ?? '-'),
          TextCellValue(payment['customerName']?.toString() ?? '-'),
          TextCellValue('Rp ${_formatCurrency(payment['amount'])}'),
          TextCellValue(payment['method']?.toString() ?? '-'),
          TextCellValue(payment['status']?.toString() ?? '-'),
          TextCellValue(
            payment['paymentDate'] != null
                ? DateFormat(
                    'dd/MM/yyyy',
                  ).format(DateTime.parse(payment['paymentDate'].toString()))
                : '-',
          ),
          TextCellValue(payment['notes']?.toString() ?? '-'),
        ]);
      }

      // Auto-fit columns
      for (int i = 0; i < 7; i++) {
        sheet.setColumnWidth(i, 20);
      }

      return await _saveAndShare(excel, 'Payments_Report');
    } catch (e) {
      developer.log('Error exporting payments: $e', name: 'ExcelExporter');
      return null;
    }
  }

  /// Export payroll records to Excel
  static Future<String?> exportPayroll(
    List<Map<String, dynamic>> records,
    String periodTitle,
  ) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Payroll'];

      // Header row
      sheet.appendRow([
        TextCellValue('ID Karyawan'),
        TextCellValue('Nama Karyawan'),
        TextCellValue('Periode'),
        TextCellValue('Gaji Pokok'),
        TextCellValue('Total Tunjangan'),
        TextCellValue('Total Potongan'),
        TextCellValue('Gaji Bersih (Net)'),
        TextCellValue('Status'),
      ]);

      // Style header
      for (int i = 0; i < 8; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.blue,
          fontColorHex: ExcelColor.white,
        );
      }

      double totalGross = 0;
      double totalAllow = 0;
      double totalDeduct = 0;
      double totalNet = 0;

      // Data rows
      for (var record in records) {
        final base = (record['baseSalary'] as num?)?.toDouble() ?? 0;
        final allow = (record['totalAllowances'] as num?)?.toDouble() ?? 0;
        final deduct = (record['totalDeductions'] as num?)?.toDouble() ?? 0;
        final net = (record['netSalary'] as num?)?.toDouble() ?? 0;

        totalGross += base;
        totalAllow += allow;
        totalDeduct += deduct;
        totalNet += net;

        sheet.appendRow([
          TextCellValue(record['employeeId']?.toString() ?? '-'),
          TextCellValue(record['employeeName']?.toString() ?? '-'),
          TextCellValue(record['month']?.toString() ?? periodTitle),
          TextCellValue('Rp ${_formatCurrency(base)}'),
          TextCellValue('Rp ${_formatCurrency(allow)}'),
          TextCellValue('Rp ${_formatCurrency(deduct)}'),
          TextCellValue('Rp ${_formatCurrency(net)}'),
          TextCellValue((record['status']?.toString() ?? 'pending').toUpperCase()),
        ]);
      }

      // Summary row
      sheet.appendRow([
        TextCellValue('TOTAL'),
        TextCellValue('${records.length} Karyawan'),
        TextCellValue(''),
        TextCellValue('Rp ${_formatCurrency(totalGross)}'),
        TextCellValue('Rp ${_formatCurrency(totalAllow)}'),
        TextCellValue('Rp ${_formatCurrency(totalDeduct)}'),
        TextCellValue('Rp ${_formatCurrency(totalNet)}'),
        TextCellValue(''),
      ]);

      // Set column width
      for (int i = 0; i < 8; i++) {
        sheet.setColumnWidth(i, 20);
      }

      final safePeriod = periodTitle.replaceAll(' ', '_');
      return await _saveAndShare(excel, 'Payroll_$safePeriod');
    } catch (e) {
      developer.log('Error exporting payroll: $e', name: 'ExcelExporter');
      return null;
    }
  }

  /// Save Excel file and share
  static Future<String?> _saveAndShare(Excel excel, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filePath = '${directory.path}/${fileName}_$timestamp.xlsx';

      final file = File(filePath);
      final bytes = excel.encode();
      if (bytes != null) {
        await file.writeAsBytes(bytes);

        // Share file
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: fileName,
          text: 'Export dari Audira Digital Network',
        );

        return filePath;
      }
      return null;
    } catch (e) {
      developer.log('Error saving Excel: $e');
      return null;
    }
  }

  /// Format currency
  static String _formatCurrency(dynamic amount) {
    if (amount == null) return '0';
    final formatter = NumberFormat('#,###', 'id_ID');
    return formatter.format(amount is String ? int.parse(amount) : amount);
  }
}
