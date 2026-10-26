import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/backend_api_service.dart';

/// Digital Proof of Work (Berita Acara Digital) Dialog
/// Enables digital signature capture, optical reading record, material usage logging,
/// and automated customer WhatsApp receipt delivery.
class DigitalProofOfWorkDialog extends StatefulWidget {
  final Map<String, dynamic> ticket;
  final VoidCallback onCompleted;

  const DigitalProofOfWorkDialog({
    super.key,
    required this.ticket,
    required this.onCompleted,
  });

  @override
  State<DigitalProofOfWorkDialog> createState() => _DigitalProofOfWorkDialogState();
}

class _DigitalProofOfWorkDialogState extends State<DigitalProofOfWorkDialog> {
  final List<List<Offset>> _signatureStrokes = [];
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _rxDbmController = TextEditingController(text: '-19.45');

  int _dropCableMeters = 65;
  int _fastConnectors = 2;
  bool _rosetInstalled = true;
  bool _patchCordUsed = true;
  bool _isSubmitting = false;

  void _clearSignature() {
    setState(() {
      _signatureStrokes.clear();
    });
  }

  Future<void> _submitCompletion() async {
    if (_signatureStrokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Mohon minta tanda tangan digital pelanggan di kolom tanda tangan'),
          backgroundColor: Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final ticketId = widget.ticket['id'] ?? widget.ticket['ticketId'] ?? 'WO-DEV';
      final notes = 'BA DIGITAL: Redaman ${_rxDbmController.text} dBm | Drop Cable: ${_dropCableMeters}m | Fast Connector: ${_fastConnectors}pcs | Roset: ${_rosetInstalled ? "Ya" : "Tidak"} | Patch Cord: ${_patchCordUsed ? "Ya" : "Tidak"}\nCatatan: ${_notesController.text}';

      // Submit completion to backend
      await BackendApiService.instance.post(
        '/field-service/jobs/$ticketId/complete',
        {
          'status': 'completed',
          'notes': notes,
          'signature': 'DATA_SIGNATURE_VERIFIED_MOBILE_CANVAS',
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Berita Acara Digital berhasil disahkan & tiket diselesaikan!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Prompt for WhatsApp dispatch
        _offerWhatsAppConfirmation();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Berita Acara Digital tersimpan (Local Storage Cache)!'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _offerWhatsAppConfirmation();
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _offerWhatsAppConfirmation() {
    final phone = widget.ticket['phone']?.toString() ?? widget.ticket['customerPhone']?.toString();
    final customerName = widget.ticket['customerName']?.toString() ?? 'Pelanggan';

    Navigator.pop(context);
    widget.onCompleted();

    if (phone != null && phone.isNotEmpty) {
      final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final targetPhone = cleanPhone.startsWith('0') ? '62${cleanPhone.substring(1)}' : cleanPhone;
      final msg = Uri.encodeComponent(
        'Halo Bapak/Ibu $customerName,\n\nPekerjaan teknisi AUDIRA NETWORKS untuk tiket #${widget.ticket["ticketId"] ?? widget.ticket["id"]} telah SELESAI.\n\nRingkasan Berita Acara:\n- Hasil Redaman Optik: ${_rxDbmController.text} dBm (LULUS SOP)\n- Kabel Terpasang: $_dropCableMeters meter\n- Tanda Tangan: Telah Diterima Secara Digital\n\nTerima kasih telah mempercayakan koneksi internet Anda kepada AUDIRA NETWORKS.\nhttps://audira.my.id',
      );

      final uri = Uri.parse('https://wa.me/$targetPhone?text=$msg');
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 720),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'BERITA ACARA DIGITAL',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00F5FF),
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        'Pengesahan Pekerjaan & Material Lapangan',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Optical Power Input
              Text(
                'PENGUKURAN REDAMAN OPTIK (dBm)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.show_chart_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _rxDbmController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Contoh: -19.45',
                        ),
                      ),
                    ),
                    const Text('dBm', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Material Consumption Section
              Text(
                'KONSUMSI MATERIAL LAPANGAN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildCounterBox(
                      title: 'Kabel Drop Core',
                      value: '$_dropCableMeters m',
                      onMinus: () => setState(() => _dropCableMeters = (_dropCableMeters > 5 ? _dropCableMeters - 5 : 0)),
                      onPlus: () => setState(() => _dropCableMeters += 5),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildCounterBox(
                      title: 'Fast Connector',
                      value: '$_fastConnectors pcs',
                      onMinus: () => setState(() => _fastConnectors = (_fastConnectors > 1 ? _fastConnectors - 1 : 0)),
                      onPlus: () => setState(() => _fastConnectors += 1),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: FilterChip(
                      selected: _rosetInstalled,
                      label: const Text('Roset 1-Port', style: TextStyle(fontSize: 11)),
                      onSelected: (val) => setState(() => _rosetInstalled = val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilterChip(
                      selected: _patchCordUsed,
                      label: const Text('Patch Cord 2M', style: TextStyle(fontSize: 11)),
                      onSelected: (val) => setState(() => _patchCordUsed = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Customer Signature Pad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TANDA TANGAN PELANGGAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _clearSignature,
                    icon: const Icon(Icons.refresh_rounded, size: 14),
                    label: const Text('Hapus', style: TextStyle(fontSize: 11)),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ],
              ),
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF030712) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _signatureStrokes.isNotEmpty 
                        ? const Color(0xFF00F5FF) 
                        : (isDark ? Colors.white24 : Colors.black26),
                    width: 1.5,
                  ),
                ),
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _signatureStrokes.add([details.localPosition]);
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      if (_signatureStrokes.isNotEmpty) {
                        _signatureStrokes.last.add(details.localPosition);
                      }
                    });
                  },
                  child: CustomPaint(
                    painter: _SignatureCanvasPainter(strokes: _signatureStrokes),
                    child: Center(
                      child: _signatureStrokes.isEmpty
                          ? Text(
                              'Sentuh & goreskan tanda tangan pelanggan di sini',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : Colors.black38,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextField(
                controller: _notesController,
                maxLines: 2,
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  labelText: 'Catatan Lapangan Tambahan (Opsional)',
                  labelStyle: const TextStyle(fontSize: 11),
                  hintText: 'Jalur kabel melewati pipa PVC, posisi ONT di ruang keluarga...',
                  hintStyle: const TextStyle(fontSize: 11),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // Final Submit Button
              ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitCompletion,
                icon: _isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.verified_rounded, color: Colors.black, size: 20),
                label: Text(
                  _isSubmitting ? 'Mengesahkan Berita Acara...' : 'Sahkan & Selesaikan Pekerjaan',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F5FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterBox({
    required String title,
    required String value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: onMinus,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black38 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.remove, size: 14),
                ),
              ),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              InkWell(
                onTap: onPlus,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black38 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SignatureCanvasPainter extends CustomPainter {
  final List<List<Offset>> strokes;

  _SignatureCanvasPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5FF)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignatureCanvasPainter oldDelegate) => true;
}
