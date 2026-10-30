import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:http/http.dart' as http;
import '../../../config/api_config.dart';
import '../../../services/backend_api_service.dart';

class SpeedtestServerNode {
  final String id;
  final String name;
  final String sponsor;
  final String location;
  final String country;
  final String flag;
  final String ip;
  final String host;
  final int port;
  final String tier;
  final String tierLabel;
  final double distanceKm;
  final double basePingMs;
  final double baseJitterMs;
  final bool isRecommended;
  double? livePingMs;

  SpeedtestServerNode({
    required this.id,
    required this.name,
    required this.sponsor,
    required this.location,
    required this.country,
    required this.flag,
    required this.ip,
    required this.host,
    required this.port,
    required this.tier,
    required this.tierLabel,
    required this.distanceKm,
    required this.basePingMs,
    required this.baseJitterMs,
    required this.isRecommended,
    this.livePingMs,
  });

  factory SpeedtestServerNode.fromJson(Map<String, dynamic> json) {
    return SpeedtestServerNode(
      id: json['id']?.toString() ?? 'node-01',
      name: json['name']?.toString() ?? 'AUDIRA Edge',
      sponsor: json['sponsor']?.toString() ?? 'AUDIRA ISP',
      location: json['location']?.toString() ?? 'Indonesia',
      country: json['country']?.toString() ?? 'ID',
      flag: json['flag']?.toString() ?? '🇮🇩',
      ip: json['ip']?.toString() ?? '103.189.20.1',
      host: json['host']?.toString() ?? ApiConfig.baseUrl,
      port: (json['port'] as num?)?.toInt() ?? 3218,
      tier: json['tier']?.toString() ?? 'LOCAL_CORE',
      tierLabel: json['tierLabel']?.toString() ?? '10 Gbps',
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 1.0,
      basePingMs: (json['basePingMs'] as num?)?.toDouble() ?? 1.8,
      baseJitterMs: (json['baseJitterMs'] as num?)?.toDouble() ?? 0.3,
      isRecommended: json['isRecommended'] == true,
      livePingMs: (json['livePingMs'] as num?)?.toDouble(),
    );
  }

  static List<SpeedtestServerNode> getDefaultNodes() {
    return [
      SpeedtestServerNode(
        id: 'audira-core-01',
        name: 'AUDIRA Core Edge Node #01',
        sponsor: 'PT Audira Sukses Mandiri (AS141415)',
        location: 'Batam IDC Spine - Rack A04',
        country: 'ID',
        flag: '🇮🇩',
        ip: '103.189.20.1',
        host: ApiConfig.baseUrl,
        port: 3218,
        tier: 'LOCAL_CORE',
        tierLabel: 'Backbone 10 Gbps (Rekomendasi)',
        distanceKm: 1.2,
        basePingMs: 1.8,
        baseJitterMs: 0.3,
        isRecommended: true,
      ),
      SpeedtestServerNode(
        id: 'audira-cpe-gateway',
        name: 'AUDIRA Home Gateway (CPE ONT)',
        sponsor: 'Router Pelanggan (TR-069 First-Hop)',
        location: 'First-Hop CPE Fiber Gateway',
        country: 'ID',
        flag: '🏠',
        ip: '192.168.1.1',
        host: 'http://192.168.1.1',
        port: 80,
        tier: 'CPE_LOCAL',
        tierLabel: 'Wi-Fi / LAN Lokal (1 Gbps)',
        distanceKm: 0.05,
        basePingMs: 0.9,
        baseJitterMs: 0.2,
        isRecommended: false,
      ),
      SpeedtestServerNode(
        id: 'jkt-iix-01',
        name: 'Jakarta OpenIXP / IIX 100G',
        sponsor: 'APJII Cyber 1 Building',
        location: 'Kuningan Barat, Jakarta',
        country: 'ID',
        flag: '🇮🇩',
        ip: '218.100.27.1',
        host: 'https://iix.openixp.net',
        port: 443,
        tier: 'NATIONAL_EXCHANGE',
        tierLabel: 'Peering Nasional 100 Gbps',
        distanceKm: 28.5,
        basePingMs: 13.5,
        baseJitterMs: 1.1,
        isRecommended: false,
      ),
      SpeedtestServerNode(
        id: 'sg-equinix-sg1',
        name: 'Singapore Equinix SG1 / SingTel',
        sponsor: 'Equinix International Hub',
        location: 'Ayer Rajah Crescent, Singapore',
        country: 'SG',
        flag: '🇸🇬',
        ip: '202.73.16.1',
        host: 'https://sg-speed.equinix.com',
        port: 443,
        tier: 'GLOBAL_TRANSIT',
        tierLabel: 'Global Tier-1 Transit (40 Gbps)',
        distanceKm: 32.0,
        basePingMs: 21.8,
        baseJitterMs: 1.6,
        isRecommended: false,
      ),
      SpeedtestServerNode(
        id: 'cloudflare-edge',
        name: 'Cloudflare Anycast Edge CDN',
        sponsor: 'Cloudflare, Inc.',
        location: 'Jakarta POP (CGK Edge)',
        country: 'US',
        flag: '⚡',
        ip: '104.16.132.229',
        host: 'https://speed.cloudflare.com',
        port: 443,
        tier: 'GLOBAL_CDN',
        tierLabel: 'Global Anycast CDN 100 Gbps',
        distanceKm: 18.0,
        basePingMs: 8.4,
        baseJitterMs: 0.8,
        isRecommended: false,
      ),
    ];
  }
}

class SpeedtestServerPickerSheet extends StatefulWidget {
  final SpeedtestServerNode currentServer;
  final ValueChanged<SpeedtestServerNode> onSelectServer;

  const SpeedtestServerPickerSheet({
    super.key,
    required this.currentServer,
    required this.onSelectServer,
  });

  static Future<SpeedtestServerNode?> show(
    BuildContext context, {
    required SpeedtestServerNode currentServer,
  }) {
    return showModalBottomSheet<SpeedtestServerNode>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SpeedtestServerPickerSheet(
        currentServer: currentServer,
        onSelectServer: (server) => Navigator.pop(ctx, server),
      ),
    );
  }

  @override
  State<SpeedtestServerPickerSheet> createState() =>
      _SpeedtestServerPickerSheetState();
}

class _SpeedtestServerPickerSheetState
    extends State<SpeedtestServerPickerSheet> {
  List<SpeedtestServerNode> _servers = [];
  bool _isLoading = true;
  String _selectedCategory = 'ALL';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadServers();
  }

  Future<void> _loadServers() async {
    List<SpeedtestServerNode> loaded = SpeedtestServerNode.getDefaultNodes();

    try {
      final res = await BackendApiService.instance.get(
        ApiConfig.speedtestServers,
      );
      if (res['servers'] is List) {
        final list = (res['servers'] as List)
            .map(
              (item) =>
                  SpeedtestServerNode.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        if (list.isNotEmpty) {
          loaded = list;
        }
      }
    } catch (_) {
      // Use standard default nodes
    }

    if (mounted) {
      setState(() {
        _servers = loaded;
        _isLoading = false;
      });
      _measureLivePings();
    }
  }

  Future<void> _measureLivePings() async {
    // Ping all servers asynchronously over real socket to populate live latency
    final client = http.Client();
    try {
      for (int i = 0; i < _servers.length; i++) {
        final s = _servers[i];
        try {
          final stopwatch = Stopwatch()..start();
          final pingUri = Uri.parse(
            '${ApiConfig.baseUrl}${ApiConfig.speedtestPing}?node=${s.id}&_t=${DateTime.now().microsecondsSinceEpoch}',
          );
          final res = await client
              .get(pingUri)
              .timeout(const Duration(milliseconds: 2500));
          stopwatch.stop();

          if (res.statusCode == 200 && mounted) {
            final elapsed = stopwatch.elapsedMicroseconds / 1000.0;
            setState(() {
              s.livePingMs = double.parse(elapsed.toStringAsFixed(1));
            });
          }
        } catch (_) {
          if (mounted) {
            setState(() => s.livePingMs = s.basePingMs);
          }
        }
      }
    } finally {
      client.close();
    }
  }

  void _selectFastest() {
    if (_servers.isEmpty) return;
    SpeedtestServerNode fastest = _servers.first;
    double minPing = fastest.livePingMs ?? fastest.basePingMs;

    for (final s in _servers) {
      final ping = s.livePingMs ?? s.basePingMs;
      if (ping < minPing) {
        minPing = ping;
        fastest = s;
      }
    }

    widget.onSelectServer(fastest);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF070B14) : Colors.white;
    final textPrimary = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF0F172A);
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? const Color(0xFF00F0FF)
        : const Color(0xFF0F172A);

    final filtered = _servers.where((s) {
      if (_selectedCategory == 'LOCAL' &&
          s.tier != 'LOCAL_CORE' &&
          s.tier != 'CPE_LOCAL') {
        return false;
      }
      if (_selectedCategory == 'NATIONAL' && s.tier != 'NATIONAL_EXCHANGE') {
        return false;
      }
      if (_selectedCategory == 'GLOBAL' &&
          s.tier != 'GLOBAL_TRANSIT' &&
          s.tier != 'GLOBAL_CDN') {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return s.name.toLowerCase().contains(query) ||
            s.location.toLowerCase().contains(query) ||
            s.sponsor.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF00F0FF).withValues(alpha: 0.2)
                : const Color(0xFF0F172A).withValues(alpha: 0.15),
            offset: const Offset(0, -6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F0FF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
                  ),
                ),
                child: const Icon(
                  LucideIcons.server,
                  color: Color(0xFF00F0FF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TARGET SERVER SPEEDTEST',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF00F0FF),
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      'Pilih Node Tujuan Pengujian',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _selectFastest,
                icon: const Icon(
                  LucideIcons.zap,
                  size: 14,
                  color: Color(0xFFFFD700),
                ),
                label: Text(
                  'TERCEPAT',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFFFD700,
                  ).withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFFFD700), width: 1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Field
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: TextStyle(color: textPrimary, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Cari node server, kota, atau sponsor...',
              hintStyle: TextStyle(color: textSecondary, fontSize: 12),
              prefixIcon: Icon(
                LucideIcons.search,
                size: 18,
                color: textSecondary,
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF0E1626)
                  : const Color(0xFFF1F5F9),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF00F0FF),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('ALL', 'Semua Server (5)'),
                const SizedBox(width: 8),
                _buildCategoryChip('LOCAL', 'Lokal Core & ONT'),
                const SizedBox(width: 8),
                _buildCategoryChip('NATIONAL', 'Nasional IIX'),
                const SizedBox(width: 8),
                _buildCategoryChip('GLOBAL', 'Global Transit'),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Server Node List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF00F0FF)),
                  )
                : filtered.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada node server yang cocok.',
                      style: TextStyle(color: textSecondary, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final server = filtered[idx];
                      final isSelected = server.id == widget.currentServer.id;
                      return _buildServerCard(
                        server,
                        isSelected,
                        isDark,
                        textPrimary,
                        textSecondary,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String cat, String label) {
    final isSelected = _selectedCategory == cat;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                    : const Color(0xFF0284C7))
              : (isDark ? const Color(0xFF0D1424) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00F0FF)
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? (isDark ? const Color(0xFF00F0FF) : Colors.white)
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
          ),
        ),
      ),
    );
  }

  Widget _buildServerCard(
    SpeedtestServerNode server,
    bool isSelected,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    final pingStr = server.livePingMs != null
        ? '${server.livePingMs!.toStringAsFixed(1)} ms'
        : '${server.basePingMs.toStringAsFixed(1)} ms';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onSelectServer(server),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF0F1E33) : const Color(0xFFE0F2FE))
                : (isDark ? const Color(0xFF0B1322) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00F0FF)
                  : (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0)),
              width: isSelected ? 2 : 1.2,
            ),
          ),
          child: Row(
            children: [
              // Country Flag / Home Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF162238) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Center(
                  child: Text(
                    server.flag,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Server Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            server.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (server.isRecommended) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF00FF9D,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF00FF9D),
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              'CORE',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF00FF9D),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${server.location} • ${server.tierLabel}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        color: textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sponsor: ${server.sponsor}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: const Color(0xFF00F0FF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Ping Badge & Selected Icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: (server.basePingMs <= 5)
                          ? const Color(0xFF00FF9D).withValues(alpha: 0.15)
                          : (server.basePingMs <= 20)
                          ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                          : const Color(0xFFFFB800).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pingStr,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: (server.basePingMs <= 5)
                            ? const Color(0xFF00FF9D)
                            : (server.basePingMs <= 20)
                            ? const Color(0xFF00F0FF)
                            : const Color(0xFFFFB800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isSelected)
                    const Icon(
                      LucideIcons.checkCircle2,
                      color: Color(0xFF00F0FF),
                      size: 18,
                    )
                  else
                    Text(
                      '${server.distanceKm.toStringAsFixed(1)} km',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        color: textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
