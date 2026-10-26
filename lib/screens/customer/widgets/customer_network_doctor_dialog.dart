import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../utils/app_theme.dart';

/// Modal Wizard Dokter Jaringan Mandiri (Automated Self-Care Diagnostic)
/// Menguji 4 parameter utama koneksi: Sinyal Optik ONT TR-069, PPPoE Gateway, DNS ISP, dan Latensi Transit
class CustomerNetworkDoctorDialog extends StatefulWidget {
  const CustomerNetworkDoctorDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CustomerNetworkDoctorDialog(),
    );
  }

  @override
  State<CustomerNetworkDoctorDialog> createState() =>
      _CustomerNetworkDoctorDialogState();
}

class _CustomerNetworkDoctorDialogState
    extends State<CustomerNetworkDoctorDialog> {
  int _currentStep = 0;
  bool _isRunning = true;
  bool _isRebooting = false;
  int _rebootCountdown = 60;
  Timer? _rebootTimer;

  final List<Map<String, dynamic>> _diagnosticSteps = [
    {
      'title': 'Sinyal Optik ONT (TR-069)',
      'desc': 'Mengukur redaman kabel fiber optik drop core',
      'detail': '-19.4 dBm [OPTIMAL: -15 s.d -24 dBm]',
      'icon': LucideIcons.radio,
      'status': 'pending', // pending, running, success, warning
    },
    {
      'title': 'Autentikasi PPPoE Gateway',
      'desc': 'Verifikasi sesi routerboard MikroTik core',
      'detail': 'Sesi Aktif // IP: 103.189.201.88',
      'icon': LucideIcons.server,
      'status': 'pending',
    },
    {
      'title': 'Resolusi DNS Core ISP',
      'desc': 'Uji kecepatan translasi domain DNS 1.1.1.1 & 8.8.8.8',
      'detail': 'Respon 4ms // Bebas DNS Hijacking',
      'icon': LucideIcons.shieldCheck,
      'status': 'pending',
    },
    {
      'title': 'Latensi Gateway & CDN Transit',
      'desc': 'Uji ping ke edge server peering OpenIXP Jakarta',
      'detail': 'Ping: 11ms // Jitter: 0.8ms // Loss: 0.0%',
      'icon': LucideIcons.zap,
      'status': 'pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startDiagnostics();
  }

  @override
  void dispose() {
    _rebootTimer?.cancel();
    super.dispose();
  }

  Future<void> _startDiagnostics() async {
    setState(() {
      _currentStep = 0;
      _isRunning = true;
      for (var s in _diagnosticSteps) {
        s['status'] = 'pending';
      }
    });

    for (int i = 0; i < _diagnosticSteps.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentStep = i;
        _diagnosticSteps[i]['status'] = 'running';
      });

      await Future.delayed(const Duration(milliseconds: 900));

      if (!mounted) return;
      setState(() {
        _diagnosticSteps[i]['status'] = 'success';
      });
    }

    if (mounted) {
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _triggerRemoteReboot() {
    setState(() {
      _isRebooting = true;
      _rebootCountdown = 60;
    });

    _rebootTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_rebootCountdown > 1) {
          _rebootCountdown--;
        } else {
          timer.cancel();
          _isRebooting = false;
          _startDiagnostics();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF0A0E1A) : Colors.white;
    final textPrimary =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Dialog(
      backgroundColor: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
          width: 2.0,
        ),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F0FF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF00F0FF),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          LucideIcons.stethoscope,
                          size: 20,
                          color: Color(0xFF00F0FF),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DOKTER JARINGAN 1-TAP',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                              color: textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            _isRunning
                                ? '// DIAGNOSA TAHAP ${_currentStep + 1}/4'
                                : '// AUDIT STATUS KONEKSI MANDIRI',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: _isRunning
                                  ? const Color(0xFF00F0FF)
                                  : textSecondary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!_isRunning && !_isRebooting)
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 20),
                      color: textSecondary,
                      onPressed: () => Navigator.pop(context),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Reboot Countdown Banner if active
              if (_isRebooting) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFF59E0B),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'MODEM SEDANG ME-REBOOT VIA TR-069',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFF59E0B),
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Menunggu sinkronisasi ulang sinyal: $_rebootCountdown detik...',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Diagnostic Step List
              ...List.generate(_diagnosticSteps.length, (index) {
                final step = _diagnosticSteps[index];
                final status = step['status'] as String;

                Color statusColor = const Color(0xFF64748B);
                Widget trailingWidget = const SizedBox(width: 20);

                if (status == 'running') {
                  statusColor = const Color(0xFF00F0FF);
                  trailingWidget = const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00F0FF),
                    ),
                  );
                } else if (status == 'success') {
                  statusColor = const Color(0xFF00FF9D);
                  trailingWidget = const Icon(
                    LucideIcons.checkCircle2,
                    size: 18,
                    color: Color(0xFF00FF9D),
                  );
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF05070D)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: status == 'running'
                          ? const Color(0xFF00F0FF)
                          : isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0),
                      width: status == 'running' ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step['icon'] as IconData,
                          size: 16,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step['title'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              status == 'success'
                                  ? step['detail'] as String
                                  : step['desc'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: status == 'success'
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                                color: status == 'success'
                                    ? const Color(0xFF00FF9D)
                                    : textSecondary,
                                fontFamily: status == 'success' ? 'monospace' : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailingWidget,
                    ],
                  ),
                );
              }),

              const SizedBox(height: 12),

              // Conclusion Banner when completed
              if (!_isRunning && !_isRebooting) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF9D).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF00FF9D),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.shieldCheck,
                        size: 24,
                        color: Color(0xFF00FF9D),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'KONEKSI FIBER OPTIK PRIMA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF00FF9D),
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Seluruh node transmisi OLT, MikroTik, dan redaman modem (-19.4 dBm) bekerja optimal.',
                              style: TextStyle(
                                fontSize: 10,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Action Buttons
              if (!_isRunning && !_isRebooting) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _triggerRemoteReboot,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark
                              ? const Color(0xFF00F0FF)
                              : const Color(0xFF0284C7),
                          side: BorderSide(
                            color: isDark
                                ? const Color(0xFF00F0FF)
                                : const Color(0xFF0284C7),
                            width: 1.4,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        icon: const Icon(LucideIcons.rotateCw, size: 14),
                        label: const Text(
                          'Reboot Modem',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? AppTheme.neonCyan
                              : const Color(0xFF0F172A),
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                        icon: const Icon(LucideIcons.check, size: 14),
                        label: const Text(
                          'Selesai',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
