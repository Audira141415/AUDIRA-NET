import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final data = await FirebaseService.instance.getLeaderboard(limit: 20);
      setState(() {
        _leaderboard = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('🏆 Leaderboard'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryCyan),
            )
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              color: AppTheme.primaryCyan,
              child: _leaderboard.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada data leaderboard',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _leaderboard.length,
                      itemBuilder: (context, index) {
                        final item = _leaderboard[index];
                        final rank = index + 1;
                        final isTop3 = rank <= 3;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            gradient: isTop3
                                ? LinearGradient(
                                    colors: rank == 1
                                        ? [
                                            Colors.amber.shade400,
                                            Colors.amber.shade700,
                                          ]
                                        : rank == 2
                                        ? [
                                            Colors.grey.shade300,
                                            Colors.grey.shade500,
                                          ]
                                        : [
                                            AppTheme.brightCyan,
                                            AppTheme.deepCyan,
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isTop3 ? null : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isTop3
                                  ? Colors.transparent
                                  : Colors.grey.shade200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isTop3
                                    ? (rank == 1
                                          ? Colors.amber.withValues(alpha: 0.3)
                                          : rank == 2
                                          ? Colors.grey.withValues(alpha: 0.3)
                                          : AppTheme.primaryCyan.withValues(alpha: 
                                              0.3,
                                            ))
                                    : Colors.grey.withValues(alpha: 0.1),
                                blurRadius: isTop3 ? 8 : 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            leading: _buildRankBadge(rank, isTop3),
                            title: Text(
                              item['name'] ?? 'Unknown',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isTop3 ? Colors.white : Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: [
                                  _buildStatChip(
                                    icon: Icons.stars,
                                    label: '${item['totalPoints']} poin',
                                    isTop3: isTop3,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatChip(
                                    icon: Icons.local_fire_department,
                                    label: '${item['currentStreak']} hari',
                                    isTop3: isTop3,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatChip(
                                    icon: Icons.emoji_events,
                                    label: 'Lvl ${item['level']}',
                                    isTop3: isTop3,
                                  ),
                                ],
                              ),
                            ),
                            trailing: isTop3
                                ? Icon(
                                    rank == 1
                                        ? Icons.emoji_events
                                        : Icons.emoji_events_outlined,
                                    color: Colors.white,
                                    size: 28,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildRankBadge(int rank, bool isTop3) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isTop3
            ? Colors.white.withValues(alpha: 0.3)
            : AppTheme.primaryCyan.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: isTop3 ? Colors.white : AppTheme.primaryCyan,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          '#$rank',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isTop3 ? Colors.white : AppTheme.primaryCyan,
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required bool isTop3,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTop3 ? Colors.white.withValues(alpha: 0.25) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isTop3 ? Colors.white : Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isTop3 ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
