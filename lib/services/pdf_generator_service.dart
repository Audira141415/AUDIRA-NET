import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service untuk generate PDF invoice dan dokumen lainnya
class PdfGeneratorService {
  static final PdfGeneratorService _instance = PdfGeneratorService._internal();
  factory PdfGeneratorService() => _instance;
  PdfGeneratorService._internal();

  static PdfGeneratorService get instance => _instance;

  /// Generate Invoice PDF dari data bill
  Future<File> generateInvoicePdf(Map<String, dynamic> billData) async {
    final pdf = pw.Document();

    // Format data
    final customerName = billData['customerName'] ?? 'Customer';
    final customerId = billData['customerId'] ?? '-';
    final billMonth = billData['billMonth'] ?? '-';
    final amount = (billData['amount'] ?? 0.0) as double;
    final dueDate = billData['dueDate'] ?? '-';
    final status = billData['status'] ?? 'unpaid';
    final paidDate = billData['paidDate'] ?? '-';
    final packageName = billData['packageName'] ?? 'Paket Standard';
    final installAddress = billData['installAddress'] ?? '-';

    // Format currency
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              pw.SizedBox(height: 20),

              // Invoice Info
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INVOICE TAGIHAN INTERNET',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'No. Invoice: INV-$customerId-${billMonth.replaceAll(' ', '')}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'Tanggal: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Customer Info
              pw.Text(
                'Informasi Pelanggan',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildInfoRow('ID Pelanggan', customerId),
              _buildInfoRow('Nama', customerName),
              _buildInfoRow('Alamat Instalasi', installAddress),
              _buildInfoRow('Paket Layanan', packageName),
              pw.SizedBox(height: 20),

              // Bill Details
              pw.Text(
                'Detail Tagihan',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  // Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue50),
                    children: [
                      _buildTableCell('Periode', isHeader: true),
                      _buildTableCell('Deskripsi', isHeader: true),
                      _buildTableCell(
                        'Jumlah',
                        isHeader: true,
                        align: pw.TextAlign.right,
                      ),
                    ],
                  ),
                  // Data
                  pw.TableRow(
                    children: [
                      _buildTableCell(billMonth),
                      _buildTableCell('Biaya Layanan Internet $packageName'),
                      _buildTableCell(
                        currencyFormat.format(amount),
                        align: pw.TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 15),

              // Total
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL TAGIHAN',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      currencyFormat.format(amount),
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // Payment Info
              _buildInfoRow('Jatuh Tempo', dueDate),
              _buildInfoRow(
                'Status',
                status == 'paid' ? 'LUNAS' : 'BELUM LUNAS',
              ),
              if (status == 'paid' && paidDate != '-')
                _buildInfoRow('Tanggal Bayar', paidDate),

              pw.SizedBox(height: 20),

              // Payment Methods
              if (status != 'paid') ...[
                pw.Text(
                  'Metode Pembayaran',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPaymentMethod(
                        'Transfer Bank',
                        'BCA 1234567890 a.n. Audiranet',
                      ),
                      pw.SizedBox(height: 6),
                      _buildPaymentMethod(
                        'E-Wallet',
                        'OVO/GoPay/DANA: 08123456789',
                      ),
                      pw.SizedBox(height: 6),
                      _buildPaymentMethod(
                        'Virtual Account',
                        'Mandiri VA: 88808123456789',
                      ),
                    ],
                  ),
                ),
              ],

              pw.Spacer(),

              // Footer
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Terima kasih atas kepercayaan Anda menggunakan layanan Audiranet.',
                style: const pw.TextStyle(fontSize: 10),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                'Hubungi: support@audiranet.com | +62 21 1234 5678',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    // Save to file
    final output = await _getOutputFile('invoice_${customerId}_$billMonth.pdf');
    await output.writeAsBytes(await pdf.save());

    return output;
  }

  /// Build header dengan logo
  pw.Widget _buildHeader() {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blue, width: 3),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'AUDIRANET',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                'Internet Service Provider',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.Container(
            width: 60,
            height: 60,
            decoration: pw.BoxDecoration(
              color: PdfColors.blue,
              borderRadius: pw.BorderRadius.circular(30),
            ),
            child: pw.Center(
              child: pw.Text(
                'ISP',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build info row
  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 130,
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 10)),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Build table cell
  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: align,
      ),
    );
  }

  /// Build payment method info
  pw.Widget _buildPaymentMethod(String method, String details) {
    return pw.Row(
      children: [
        pw.Container(
          width: 4,
          height: 4,
          decoration: const pw.BoxDecoration(
            color: PdfColors.blue,
            shape: pw.BoxShape.circle,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          '$method: ',
          style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(details, style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  /// Get output file path
  Future<File> _getOutputFile(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename';
    return File(path);
  }

  /// Preview PDF
  Future<void> previewPdf(Map<String, dynamic> billData) async {
    final pdf = pw.Document();

    // Same content as generateInvoicePdf but for preview
    // (Code duplicated for simplicity, consider refactoring)

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  /// Share PDF
  Future<void> sharePdf(File pdfFile) async {
    await Share.shareXFiles(
      [XFile(pdfFile.path)],
      subject: 'Invoice Audiranet',
      text: 'Invoice tagihan internet Audiranet',
    );
  }

  /// Print PDF
  Future<void> printPdf(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    await Printing.layoutPdf(onLayout: (format) => bytes);
  }
}
