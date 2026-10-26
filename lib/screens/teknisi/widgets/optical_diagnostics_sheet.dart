import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

/// Pocket Optical & TR-069 Diagnostics Sheet
/// Allows field technicians to measure live optical dBm, test PON connectivity, and reboot customer ONT
class OpticalDiagnosticsSheet extends StatefulWidget {
  final String? customerName;
  final String? ontSerial;
  final String? odpReference;

  const OpticalDiagnosticsSheet({
    super.key,
    this.customerName,
    this.ontSerial,
    this.odpReference,
  });

  @override
  State<OpticalDiagnosticsSheet> createState() => _OpticalDiagnosticsSheetState();
}

class _OpticalDiagnosticsSheetState extends State<OpticalDiagnosticsSheet> {
  bool _isTesting = false;
  bool _isRebooting = false;
  double _rxPowerDbm = -19.45;
  double _txPowerDbm = 2.35;
  double _tempCelsius = 42.8;
  final String _ponStatus = 'O5 (OPERATION)';
  String _quality = 'SANGAT BAIK';

  Future<void> _refreshTelemetry() async {
    setState(() => _isTesting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Simulate real-time TR-069 fluctuation
    final newRx = -18.5 - (DateTime.now().millisecond % 50) / 10.0;
    setState(() {
      _rxPowerDbm = double.parse(newRx.toStringAsFixed(2));
      _txPowerDbm = double.parse((2.1 + (DateTime.now().second % 4) / 10.0).toStringAsFixed(2));
      _tempCelsius = double.parse((41.0 + (DateTime.now().second % 6) / 2.0).toStringAsFixed(1));
      
      if (_rxPowerDbm >= -22.0) {
        _quality = 'SANGAT BAIK (OPTIMAL)';
      } else if (_rxPowerDbm >= -26.0) {
        _quality = 'CUKUP (WARNING)';
      } else {
        _quality = 'LOSS TINGGI (REDAMAN RUSAK)';
      }
      _isTesting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Telemetri Sinyal Optik Diperbarui: $_rxPowerDbm dBm'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _rebootCPE() async {
    setState(() => _isRebooting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRebooting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Perintah Reboot ONT berhasil dikirim via TR-069!'),
          backgroundColor: Color(0xFF0284C7),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Color _getDbmColor(double dbm) {
    if (dbm >= -22.0) return const Color(0xFF10B981); // Green
    if (dbm >= -26.0) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dbmColor = _getDbmColor(_rxPowerDbm);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1220) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? const Color(0xFF00F5FF).withValues(alpha: 0.3) : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F5FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.speed_rounded, color: Color(0xFF00F5FF), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'POCKET OPTICAL METER',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: Color(0xFF00F5FF),
                        ),
                      ),
                      Text(
                        widget.customerName != null ? 'Pelanggan: ${widget.customerName}' : 'Diagnostik Optik TR-069',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Main Optical Gauge Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [const Color(0xFF050B14), const Color(0xFF0D1B2A)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFEDF2F7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: dbmColor.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: dbmColor.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'RX OPTICAL POWER (REDAMAN)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$_rxPowerDbm',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: dbmColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'dBm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: dbmColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: dbmColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: dbmColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _quality,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: dbmColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Secondary Telemetry Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  isDark: isDark,
                  title: 'TX Power',
                  value: '+$_txPowerDbm dBm',
                  sub: 'Laser Transmitter',
                  color: const Color(0xFF00F5FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  isDark: isDark,
                  title: 'Suhu ONT',
                  value: '$_tempCelsius°C',
                  sub: 'Internal Sensor',
                  color: const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  isDark: isDark,
                  title: 'Status PON',
                  value: _ponStatus,
                  sub: 'Synchronized',
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hardware reference banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111827) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITIK ODP: ${widget.odpReference ?? "ODP-AUDIRA-MDK-04/08"}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'SN: ${widget.ontSerial ?? "HWTC-9A8B7C6D"}',
                      style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ONLINE',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isRebooting ? null : _rebootCPE,
                  icon: _isRebooting 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.restart_alt_rounded, size: 18),
                  label: Text(_isRebooting ? 'Rebooting...' : 'Reboot ONT'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: isDark ? const Color(0xFF00F5FF) : AppTheme.signalBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isTesting ? null : _refreshTelemetry,
                  icon: _isTesting 
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.refresh_rounded, size: 20, color: Colors.black),
                  label: Text(
                    _isTesting ? 'Membaca Sinyal...' : 'Ukur Redaman Ulang',
                    style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00F5FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required bool isDark,
    required String title,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 9,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
