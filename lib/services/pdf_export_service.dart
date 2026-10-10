import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

/// Service untuk generate PDF reports
class PdfExportService {
  /// Generate billing report PDF
  static Future<Uint8List> generateBillingReport({
    required String customerName,
    required String period,
    required List<Map<String, dynamic>> bills,
    required double totalAmount,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AUDIRANET',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.cyan700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Laporan Tagihan Internet',
                  style: const pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Divider(thickness: 2, color: PdfColors.cyan700),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Customer Info
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'Nama Pelanggan',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          customerName,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Periode',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          period,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Tanggal Cetak: ${dateFormat.format(DateTime.now())}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 24),

          // Bills Table
          pw.Text(
            'Rincian Tagihan',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.cyan50),
                children: [
                  _buildTableCell('No', isHeader: true),
                  _buildTableCell('Bulan', isHeader: true),
                  _buildTableCell('Jumlah', isHeader: true),
                  _buildTableCell('Jatuh Tempo', isHeader: true),
                  _buildTableCell('Status', isHeader: true),
                ],
              ),
              // Data
              ...List.generate(bills.length, (index) {
                final bill = bills[index];
                return pw.TableRow(
                  children: [
                    _buildTableCell((index + 1).toString()),
                    _buildTableCell(bill['billMonth'] ?? '-'),
                    _buildTableCell(currencyFormat.format(bill['amount'] ?? 0)),
                    _buildTableCell(bill['dueDate'] ?? '-'),
                    _buildTableCell(
                      bill['status'] == 'paid' ? 'Lunas' : 'Belum Bayar',
                    ),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.cyan50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Tagihan',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  currencyFormat.format(totalAmount),
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.cyan700,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 40),

          // Footer
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Terima kasih telah menggunakan layanan AUDIRANET',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Generate customer report PDF
  static Future<Uint8List> generateCustomerReport({
    required List<Map<String, dynamic>> customers,
    required String reportTitle,
    required String period,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'AUDIRANET',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.cyan700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  reportTitle,
                  style: const pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Periode: $period',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Divider(thickness: 2, color: PdfColors.cyan700),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Customers Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // Header
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.cyan50),
                children: [
                  _buildTableCell('No', isHeader: true),
                  _buildTableCell('Nama', isHeader: true),
                  _buildTableCell('Alamat', isHeader: true),
                  _buildTableCell('Paket', isHeader: true),
                  _buildTableCell('Status', isHeader: true),
                ],
              ),
              // Data
              ...List.generate(customers.length, (index) {
                final customer = customers[index];
                return pw.TableRow(
                  children: [
                    _buildTableCell((index + 1).toString()),
                    _buildTableCell(customer['name'] ?? '-'),
                    _buildTableCell(customer['address'] ?? '-'),
                    _buildTableCell(customer['package'] ?? '-'),
                    _buildTableCell(customer['status'] ?? '-'),
                  ],
                );
              }),
            ],
          ),

          pw.SizedBox(height: 20),

          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.cyan50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Text(
              'Total Pelanggan: ${customers.length}',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Helper method to build table cell
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.grey800 : PdfColors.grey700,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  /// Show print dialog
  static Future<void> printPdf(Uint8List pdfData, String filename) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdfData,
      name: filename,
    );
  }

  /// Share PDF
  static Future<void> sharePdf(Uint8List pdfData, String filename) async {
    await Printing.sharePdf(bytes: pdfData, filename: filename);
  }
}
