import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  final String? ticketId;
  final String? customerName;

  const BarcodeScannerPage({
    super.key,
    this.ticketId,
    this.customerName,
  });

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  // Mock data modem berdasarkan serial number
  Map<String, dynamic>? _getModemData(String serialNumber) {
    // Database mock modem
    final modems = {
      'HG8245H-12345678': {
        'model': 'Huawei HG8245H',
        'serialNumber': 'HG8245H-12345678',
        'macAddress': 'A4:C3:F0:12:34:56',
        'firmwareVersion': 'V3R017C10S115',
        'manufacturer': 'Huawei Technologies',
        'portCount': '4 GE + 2 POTS + 1 USB',
        'wifiStandard': 'WiFi 5 (802.11ac)',
        'maxSpeed': '1200 Mbps',
        'status': 'Active',
        'installDate': '2024-05-15',
        'lastMaintenance': '2025-10-20',
      },
      'ZTE-F660-87654321': {
        'model': 'ZTE F660',
        'serialNumber': 'ZTE-F660-87654321',
        'macAddress': '08:00:27:AB:CD:EF',
        'firmwareVersion': 'V8.0.10P7N1',
        'manufacturer': 'ZTE Corporation',
        'portCount': '4 GE + 2 POTS',
        'wifiStandard': 'WiFi 5 (802.11ac)',
        'maxSpeed': '1000 Mbps',
        'status': 'Active',
        'installDate': '2024-08-10',
        'lastMaintenance': '2025-09-15',
      },
      'TP-LINK-11223344': {
        'model': 'TP-Link Archer C6',
        'serialNumber': 'TP-LINK-11223344',
        'macAddress': '50:C7:BF:11:22:33',
        'firmwareVersion': '1.3.6 Build 20200902',
        'manufacturer': 'TP-Link Technologies',
        'portCount': '4 GE LAN + 1 WAN',
        'wifiStandard': 'WiFi 5 (802.11ac)',
        'maxSpeed': '1200 Mbps',
        'status': 'Active',
        'installDate': '2024-12-01',
        'lastMaintenance': '2025-11-05',
      },
    };

    return modems[serialNumber];
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    setState(() => _isProcessing = true);

    final String? code = barcodes.first.rawValue;
    if (code != null) {
      cameraController.stop();

      final modemData = _getModemData(code);

      if (modemData != null) {
        _showModemInfo(modemData);
      } else {
        _showUnknownDevice(code);
      }
    }
  }

  void _showModemInfo(Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade700, Colors.orange.shade500],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.router, size: 60, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    data['model'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: data['status'] == 'Active'
                          ? Colors.green.shade400
                          : Colors.red.shade400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      data['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildInfoSection('Informasi Perangkat', Icons.info_outline, [
                    _buildInfoRow('Model', data['model']),
                    _buildInfoRow('Serial Number', data['serialNumber']),
                    _buildInfoRow('MAC Address', data['macAddress']),
                    _buildInfoRow('Manufacturer', data['manufacturer']),
                    _buildInfoRow('Firmware Version', data['firmwareVersion']),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Spesifikasi Teknis', Icons.settings, [
                    _buildInfoRow('Port Count', data['portCount']),
                    _buildInfoRow('WiFi Standard', data['wifiStandard']),
                    _buildInfoRow('Max Speed', data['maxSpeed']),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Riwayat Maintenance', Icons.history, [
                    _buildInfoRow('Install Date', data['installDate']),
                    _buildInfoRow('Last Maintenance', data['lastMaintenance']),
                  ]),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() => _isProcessing = false);
                            cameraController.start();
                          },
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan Lagi'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: widget.ticketId != null ? 2 : 1,
                        child: FilledButton.icon(
                          onPressed: () => Navigator.pop(context, data),
                          icon: const Icon(Icons.link_rounded),
                          label: Text(
                            widget.ticketId != null 
                                ? 'Ikat ke #${widget.ticketId}' 
                                : 'Gunakan Perangkat',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF00F5FF),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.all(16),
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
    ).then((result) {
      if (mounted) {
        if (result == null) {
          setState(() => _isProcessing = false);
          cameraController.start();
        } else {
          Navigator.pop(context, result);
        }
      }
    });
  }

  void _showUnknownDevice(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perangkat Tidak Dikenali'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Serial number tidak ditemukan dalam database:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Silakan hubungi admin untuk mendaftarkan perangkat ini.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isProcessing = false);
              cameraController.start();
            },
            child: const Text('Scan Lagi'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Barcode Modem'),
        backgroundColor: Colors.orange.shade700,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              cameraController.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(controller: cameraController, onDetect: _onDetect),

          // Overlay
          CustomPaint(painter: ScannerOverlay(), child: Container()),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 40,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Arahkan kamera ke barcode pada modem',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

// Custom painter for scanner overlay
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.width * 0.7,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(scanArea, const Radius.circular(20)),
        ),
      ),
      paint,
    );

    // Corner brackets
    final cornerPaint = Paint()
      ..color = Colors.orange.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final cornerLength = 40.0;

    // Top-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top + cornerLength),
      Offset(scanArea.left, scanArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left + cornerLength, scanArea.top),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(scanArea.right - cornerLength, scanArea.top),
      Offset(scanArea.right, scanArea.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right, scanArea.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom - cornerLength),
      Offset(scanArea.left, scanArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left + cornerLength, scanArea.bottom),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(scanArea.right - cornerLength, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom - cornerLength),
      Offset(scanArea.right, scanArea.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
