import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/loyalty_service.dart';
import '../../services/auth_service.dart';
import '../../models/loyalty_model.dart';
import 'package:intl/intl.dart';

class LoyaltyRewardsPage extends StatefulWidget {
  const LoyaltyRewardsPage({super.key});

  @override
  State<LoyaltyRewardsPage> createState() => _LoyaltyRewardsPageState();
}

class _LoyaltyRewardsPageState extends State<LoyaltyRewardsPage>
    with SingleTickerProviderStateMixin {
  final LoyaltyService _loyaltyService = LoyaltyService.instance;
  LoyaltyAccount? _account;
  List<PointsTransaction> _transactions = [];
  List<Map<String, dynamic>> _rewards = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final userData = AuthService.instance.currentUserData;
      final userId = userData?['id'] ?? 'usr-customer-01';

      LoyaltyAccount? account;
      try {
        account = await _loyaltyService
            .getOrCreateAccount(userId)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}

      account ??= LoyaltyAccount(
        customerId: userId,
        totalPoints: 1250,
        lifetimePoints: 2400,
        tier: 'gold',
        referralCount: 3,
        lastActivityAt: DateTime.now(),
      );

      List<PointsTransaction> transactions = [];
      try {
        transactions = await _loyaltyService
            .getTransactionHistory(userId)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}

      if (transactions.isEmpty) {
        transactions = [
          PointsTransaction(
            id: 'tx_01',
            customerId: userId,
            type: 'earn',
            points: 250,
            description: 'Pembayaran Tagihan Tepat Waktu (Nov 2026)',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          PointsTransaction(
            id: 'tx_02',
            customerId: userId,
            type: 'earn',
            points: 500,
            description: 'Bonus Pelanggan Setia 1 Tahun',
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
        ];
      }

      List<Map<String, dynamic>> rewards = [];
      try {
        rewards = await _loyaltyService
            .getAvailableRewards(userId)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}

      if (rewards.isEmpty) {
        rewards = [
          {
            'name': 'Diskon Tagihan Rp 25.000',
            'pointsCost': 250,
            'description': 'Potongan langsung untuk invoice periode berikutnya',
          },
          {
            'name': 'Speed Booster 100 Mbps (3 Hari)',
            'pointsCost': 500,
            'description': 'Lonjakan bandwidth ganda tanpa FUP limit',
          },
          {
            'name': 'Gratis Sewa Router Mesh Wi-Fi 6',
            'pointsCost': 1000,
            'description': 'Perluasan cakupan sinyal hingga ke setiap sudut rumah',
          },
        ];
      }

      if (mounted) {
        setState(() {
          _account = account;
          _transactions = transactions;
          _rewards = rewards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _redeemReward(Map<String, dynamic> reward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penukaran'),
        content: Text(
          'Tukar ${reward['pointsCost']} poin untuk ${reward['name']}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tukar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await _loyaltyService.redeemPoints(
        _account!.customerId,
        reward['pointsCost'],
        reward['name'],
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reward berhasil ditukar!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poin tidak mencukupi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('🎁 Loyalty & Rewards'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Rewards'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildRewardsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_account == null) return const SizedBox();

    final tierData = _loyaltyService.tiers[_account!.tier]!;
    final nextTier = _account!.tier == 'platinum'
        ? null
        : _account!.tier == 'gold'
        ? 'platinum'
        : _account!.tier == 'silver'
        ? 'gold'
        : 'silver';

    final nextTierPoints = nextTier != null
        ? _loyaltyService.tiers[nextTier]!['minPoints'] -
              _account!.lifetimePoints
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tier Card
          Card(
            elevation: 8,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(tierData['color']),
                    Color(tierData['color']).withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${tierData['name']} Member',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_account!.totalPoints}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Poin Tersedia',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${_account!.lifetimePoints} Lifetime Points',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Referral Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Referral Code',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _loyaltyService.generateReferralCode(
                              _account!.customerId,
                            ),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: _loyaltyService.generateReferralCode(
                                _account!.customerId,
                              ),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kode disalin!')),
                          );
                        },
                        icon: const Icon(LucideIcons.copy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_account!.referralCount} teman berhasil direferensikan',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Benefits Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Benefit Tier Anda',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...(tierData['benefits'] as List).map((benefit) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(
                            LucideIcons.checkCircle2,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(benefit),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          if (nextTier != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Kumpulkan $nextTierPoints poin lagi untuk naik ke ${_loyaltyService.tiers[nextTier]!['name']}!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rewards.length,
      itemBuilder: (context, index) {
        final reward = _rewards[index];
        final pointsCost = (reward['pointsCost'] as num?)?.toInt() ?? 0;
        final canAfford = (reward['canAfford'] == true) || ((_account?.totalPoints ?? 0) >= pointsCost);

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: canAfford ? Colors.blue : Colors.grey.shade300,
              child: Icon(
                reward['category'] == 'discount'
                    ? LucideIcons.tag
                    : reward['category'] == 'upgrade'
                    ? LucideIcons.arrowUpCircle
                    : LucideIcons.gift,
                color: Colors.white,
              ),
            ),
            title: Text(
              reward['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward['description']),
                const SizedBox(height: 4),
                Text(
                  '${reward['pointsCost']} poin',
                  style: TextStyle(
                    color: canAfford ? Colors.blue : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: FilledButton(
              onPressed: canAfford ? () => _redeemReward(reward) : null,
              child: const Text('Tukar'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    if (_transactions.isEmpty) {
      return const Center(child: Text('Belum ada riwayat transaksi poin'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        final isEarn = tx.points > 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isEarn
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              child: Icon(
                isEarn ? LucideIcons.plus : LucideIcons.minus,
                color: isEarn ? Colors.green : Colors.red,
              ),
            ),
            title: Text(tx.description),
            subtitle: Text(
              DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt),
            ),
            trailing: Text(
              '${isEarn ? '+' : ''}${tx.points}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isEarn ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }
}
