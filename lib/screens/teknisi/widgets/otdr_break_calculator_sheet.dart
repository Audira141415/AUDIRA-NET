import 'package:flutter/material.dart';

/// SOP & Arsitektur Jaringan ISP AUDIRA:
/// 1. TIA-598-D 12-Color Core Code Matrix
/// 2. OTDR Break Distance & Optical Power Budget Calculator
class OtdrBreakCalculatorSheet extends StatefulWidget {
  const OtdrBreakCalculatorSheet({super.key});

  @override
  State<OtdrBreakCalculatorSheet> createState() =>
      _OtdrBreakCalculatorSheetState();
}

class _OtdrBreakCalculatorSheetState extends State<OtdrBreakCalculatorSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tab 1: Break Distance State
  final TextEditingController _measuredLossController = TextEditingController(
    text: '4.20',
  );
  final TextEditingController _routeLengthController = TextEditingController(
    text: '12.0',
  );
  String _wavelength =
      '1310 nm'; // 1310 nm (~0.35 dB/km) or 1550 nm (~0.20 dB/km)
  double _calculatedDistanceKm = 0.0;
  final int _estimatedSplices = 3;
  final double _spliceLossDb = 0.02; // Standard fusion splice

  // Tab 2: Core Matrix State
  final TextEditingController _coreNumberController = TextEditingController(
    text: '42',
  );
  int _calculatedTubeNumber = 4;
  String _calculatedTubeColor = 'Cokelat (Brown)';
  Color _calculatedTubeHex = const Color(0xFF854D0E);
  int _calculatedCoreInTube = 6;
  String _calculatedCoreColor = 'Putih (White)';
  Color _calculatedCoreHex = const Color(0xFFF8FAFC);

  // Tab 3: Power Budget State
  final double _oltTxPower = 3.0; // dBm
  String _splitterRatio = '1:8 (10.5 dB)';
  double _cableLengthKm = 6.5;
  final double _connectorLoss = 0.6; // 2 connectors x 0.3 dB
  double _estimatedOntRxPower = -19.45;

  static const List<Map<String, dynamic>> _tia598Colors = [
    {
      'no': 1,
      'name': 'Biru (Blue)',
      'color': Color(0xFF2563EB),
      'darkText': false,
    },
    {
      'no': 2,
      'name': 'Oranye (Orange)',
      'color': Color(0xFFF97316),
      'darkText': false,
    },
    {
      'no': 3,
      'name': 'Hijau (Green)',
      'color': Color(0xFF16A34A),
      'darkText': false,
    },
    {
      'no': 4,
      'name': 'Cokelat (Brown)',
      'color': Color(0xFF854D0E),
      'darkText': false,
    },
    {
      'no': 5,
      'name': 'Abu-abu (Slate)',
      'color': Color(0xFF64748B),
      'darkText': false,
    },
    {
      'no': 6,
      'name': 'Putih (White)',
      'color': Color(0xFFF8FAFC),
      'darkText': true,
    },
    {
      'no': 7,
      'name': 'Merah (Red)',
      'color': Color(0xFFDC2626),
      'darkText': false,
    },
    {
      'no': 8,
      'name': 'Hitam (Black)',
      'color': Color(0xFF1E293B),
      'darkText': false,
    },
    {
      'no': 9,
      'name': 'Kuning (Yellow)',
      'color': Color(0xFFEAB308),
      'darkText': true,
    },
    {
      'no': 10,
      'name': 'Ungu (Violet)',
      'color': Color(0xFF9333EA),
      'darkText': false,
    },
    {
      'no': 11,
      'name': 'Merah Muda (Rose)',
      'color': Color(0xFFEC4899),
      'darkText': false,
    },
    {
      'no': 12,
      'name': 'Toska (Aqua)',
      'color': Color(0xFF06B6D4),
      'darkText': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateBreakDistance();
    _calculateCoreLookup(42);
    _calculatePowerBudget();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _measuredLossController.dispose();
    _routeLengthController.dispose();
    _coreNumberController.dispose();
    super.dispose();
  }

  void _calculateBreakDistance() {
    final loss = double.tryParse(_measuredLossController.text) ?? 4.20;
    final lossPerKm = _wavelength == '1310 nm' ? 0.35 : 0.20;
    final netLoss = (loss - (_estimatedSplices * _spliceLossDb)).clamp(
      0.05,
      100.0,
    );
    final dist = netLoss / lossPerKm;

    setState(() {
      _calculatedDistanceKm = double.parse(dist.toStringAsFixed(2));
    });
  }

  void _calculateCoreLookup(int coreNum) {
    if (coreNum <= 0) return;
    final tubeIndex = ((coreNum - 1) ~/ 12) % 12;
    final coreIndex = (coreNum - 1) % 12;

    setState(() {
      _calculatedTubeNumber = ((coreNum - 1) ~/ 12) + 1;
      _calculatedTubeColor = _tia598Colors[tubeIndex]['name'];
      _calculatedTubeHex = _tia598Colors[tubeIndex]['color'];

      _calculatedCoreInTube = coreIndex + 1;
      _calculatedCoreColor = _tia598Colors[coreIndex]['name'];
      _calculatedCoreHex = _tia598Colors[coreIndex]['color'];
    });
  }

  void _calculatePowerBudget() {
    final lossPerKm = _wavelength == '1310 nm' ? 0.35 : 0.20;
    double splitterLoss = 10.5;
    if (_splitterRatio.startsWith('1:2')) splitterLoss = 3.5;
    if (_splitterRatio.startsWith('1:4')) splitterLoss = 7.2;
    if (_splitterRatio.startsWith('1:8')) splitterLoss = 10.5;
    if (_splitterRatio.startsWith('1:16')) splitterLoss = 14.0;
    if (_splitterRatio.startsWith('1:32')) splitterLoss = 17.5;

    final totalCableLoss = _cableLengthKm * lossPerKm;
    final rx = _oltTxPower - splitterLoss - totalCableLoss - _connectorLoss;

    setState(() {
      _estimatedOntRxPower = double.parse(rx.toStringAsFixed(2));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF070B14) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark
              ? const Color(0xFF00FF9D).withValues(alpha: 0.35)
              : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 48,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.architecture_rounded,
                    color: Color(0xFF38BDF8),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KALKULATOR OTDR & FIBER SPLICING',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Standar Operasional ISP AUDIRA • TIA-598-D & ITU-T G.652.D',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Segmented Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D1527) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: const Color(0xFF0284C7),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark
                  ? Colors.white60
                  : const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              tabs: const [
                Tab(text: 'Titik Putus OTDR'),
                Tab(text: 'Kode Core TIA-598'),
                Tab(text: 'Power Budget'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBreakDistanceTab(isDark),
                _buildCoreMatrixTab(isDark),
                _buildPowerBudgetTab(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB 1: BREAK DISTANCE ──────────────────────────────────────────────
  Widget _buildBreakDistanceTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Result Hero Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0C1F38), const Color(0xFF061426)]
                  : [const Color(0xFFE0F2FE), const Color(0xFFF0F9FF)],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF0284C7).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ESTIMASI JARAK PUTUS KABEL (BREAK POINT)',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: isDark
                          ? const Color(0xFF38BDF8)
                          : const Color(0xFF0369A1),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Text(
                      'TOLERANSI ±15M',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$_calculatedDistanceKm',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kilometer (${(_calculatedDistanceKm * 1000).toStringAsFixed(0)} Meter)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white60,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Rekomendasi NOC: Inspeksi Joint Closure terdekat di segmen tiang ODC ${_calculatedDistanceKm > 5 ? "Ring Backbone" : "Distribusi ODP"}.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Input Loss Terukur
        Text(
          'Total Redaman Terukur di OTDR (dB)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _measuredLossController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => _calculateBreakDistance(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
          ),
          decoration: InputDecoration(
            hintText: 'Contoh: 4.20 dB',
            suffixText: 'dB',
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0D1527)
                : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),

        // Panjang Jalur Total & Wavelength
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panjang Kabel Total (km)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _routeLengthController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _calculateBreakDistance(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontFamily: 'monospace',
                    ),
                    decoration: InputDecoration(
                      hintText: '12.0',
                      suffixText: 'km',
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF0D1527)
                          : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panjang Gelombang',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0D1527)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                    ),
                    child: DropdownButton<String>(
                      value: _wavelength,
                      isExpanded: true,
                      underline: const SizedBox(),
                      dropdownColor: isDark
                          ? const Color(0xFF0F172A)
                          : Colors.white,
                      items: const [
                        DropdownMenuItem(
                          value: '1310 nm',
                          child: Text('1310 nm (0.35 dB/km)'),
                        ),
                        DropdownMenuItem(
                          value: '1550 nm',
                          child: Text('1550 nm (0.20 dB/km)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _wavelength = val);
                          _calculateBreakDistance();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // SOP Fusion Splicing Tip
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white10 : const Color(0xFFCBD5E1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    size: 16,
                    color: Color(0xFFF59E0B),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'SOP PENANGANAN FIBER CUT NOC AUDIRA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '1. Pastikan VFL (Visual Fault Locator) 30mW diaktifkan dari ODF untuk konfirmasi visual break.\n2. Bersihkan core dengan Isopropyl Alcohol 99% sebelum cleaving.\n3. Nilai splice loss fusion wajib di bawah 0.03 dB per core.',
                style: TextStyle(
                  fontSize: 10.5,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── TAB 2: CORE MATRIX TIA-598 ─────────────────────────────────────────
  Widget _buildCoreMatrixTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Quick Search Core Number
        Text(
          'Cari Posisi Core (1 s/d 144 Core)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _coreNumberController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            fontSize: 16,
          ),
          onChanged: (val) {
            final n = int.tryParse(val);
            if (n != null && n > 0) _calculateCoreLookup(n);
          },
          decoration: InputDecoration(
            hintText: 'Masukkan nomor core...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: isDark
                ? const Color(0xFF0D1527)
                : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),

        // Result Card: Tube & Core Visual Identification
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C1322) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF00FF9D).withValues(alpha: 0.3)
                  : const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HASIL IDENTIFIKASI CORE ${_coreNumberController.text}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark
                      ? const Color(0xFF00FF9D)
                      : const Color(0xFF059669),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  // Tube Color
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131D31) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WARNA TUBE (BUFFER)',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _calculatedTubeHex,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black26),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Tube #$_calculatedTubeNumber\n$_calculatedTubeColor',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Core Color
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131D31) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'WARNA CORE SERAT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: _calculatedCoreHex,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black26),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Core #$_calculatedCoreInTube\n$_calculatedCoreColor',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Grid 12 Standard Colors
        Text(
          'Standar 12 Warna TIA-598-D (1 s/d 12 Core per Tube)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: _tia598Colors.length,
          itemBuilder: (context, index) {
            final item = _tia598Colors[index];
            final color = item['color'] as Color;
            final isLight = item['darkText'] as bool;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isLight ? Colors.black12 : Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item['no']}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isLight ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${item['name']}'.split(' ')[0],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isLight ? Colors.black87 : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // ─── TAB 3: POWER BUDGET ────────────────────────────────────────────────
  Widget _buildPowerBudgetTab(bool isDark) {
    final isGood =
        _estimatedOntRxPower >= -24.0 && _estimatedOntRxPower <= -14.0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        // Result Power Budget Hero
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF071424) : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isGood ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ESTIMASI RX POWER DI MODEM ONT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isGood
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isGood ? 'OPTIMAL (O5)' : 'WARNING / LOSS',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$_estimatedOntRxPower',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      color: isGood
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'dBm (Rentang Ideal: -14.0 s/d -24.0 dBm)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Splitter Ratio Selection
        Text(
          'Rasio Splitter Pasif (ODP / ODC)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1527) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.4)),
          ),
          child: DropdownButton<String>(
            value: _splitterRatio,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            items: const [
              DropdownMenuItem(
                value: '1:2 (3.5 dB)',
                child: Text('Splitter 1:2 (Loss ~3.5 dB)'),
              ),
              DropdownMenuItem(
                value: '1:4 (7.2 dB)',
                child: Text('Splitter 1:4 (Loss ~7.2 dB)'),
              ),
              DropdownMenuItem(
                value: '1:8 (10.5 dB)',
                child: Text('Splitter 1:8 (Loss ~10.5 dB) - Standar ODP'),
              ),
              DropdownMenuItem(
                value: '1:16 (14.0 dB)',
                child: Text('Splitter 1:16 (Loss ~14.0 dB) - High Density'),
              ),
              DropdownMenuItem(
                value: '1:32 (17.5 dB)',
                child: Text('Splitter 1:32 (Loss ~17.5 dB) - GPON Spine'),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _splitterRatio = val);
                _calculatePowerBudget();
              }
            },
          ),
        ),
        const SizedBox(height: 14),

        // Jarak Kabel ke ONT Slider
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Jarak Kabel Dropcore / Distribusi:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              '${_cableLengthKm.toStringAsFixed(1)} km',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        Slider(
          value: _cableLengthKm,
          min: 0.2,
          max: 20.0,
          divisions: 99,
          activeColor: const Color(0xFF0284C7),
          onChanged: (val) {
            setState(() => _cableLengthKm = val);
            _calculatePowerBudget();
          },
        ),
      ],
    );
  }
}
