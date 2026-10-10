import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../services/firebase_service.dart';
import '../../utils/app_theme.dart';

class CheckInHistoryPage extends StatefulWidget {
  const CheckInHistoryPage({super.key});

  @override
  State<CheckInHistoryPage> createState() => _CheckInHistoryPageState();
}

class _CheckInHistoryPageState extends State<CheckInHistoryPage> {
  List<Map<String, dynamic>> _history = [];
  Map<String, dynamic>? _rewardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      // Get first teknisi user from Firestore
      final userSnapshot = await FirebaseService.instance.usersCollection
          .where('role', isEqualTo: 'teknisi')
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        final teknisiId = userSnapshot.docs.first.id;

        // Get check-in history
        final historySnapshot = await FirebaseService.instance.firestore
            .collection('checkins')
            .where('teknisiId', isEqualTo: teknisiId)
            .orderBy('checkInTime', descending: true)
            .limit(90)
            .get();

        final history = historySnapshot.docs.map((doc) {
          final data = doc.data();
          return {'id': doc.id, ...data};
        }).toList();

        final rewards = await FirebaseService.instance.getRewardsByTeknisiId(
          teknisiId,
        );

        setState(() {
          _history = history;
          _rewardData = rewards.isNotEmpty ? rewards.first : null;
          _isLoading = false;
        });
      }
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
        title: const Text('📸 Riwayat Check-in'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryCyan,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryCyan),
            )
          : Column(
              children: [
                // Summary Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.brightCyan, AppTheme.deepCyan],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryStat(
                            icon: Icons.calendar_month,
                            label: 'Total Check-in',
                            value: '${_rewardData?['totalCheckins'] ?? 0}',
                          ),
                          Container(
                            height: 50,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          _buildSummaryStat(
                            icon: Icons.local_fire_department,
                            label: 'Streak Saat Ini',
                            value: '${_rewardData?['currentStreak'] ?? 0} hari',
                          ),
                          Container(
                            height: 50,
                            width: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          _buildSummaryStat(
                            icon: Icons.military_tech,
                            label: 'Terlama',
                            value: '${_rewardData?['longestStreak'] ?? 0} hari',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // History List
                Expanded(
                  child: _history.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada riwayat check-in',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadHistory,
                          color: Colors.orange,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _history.length,
                            itemBuilder: (context, index) {
                              final item = _history[index];
                              final date = DateTime.parse(item['checkInDate']);
                              final time = item['checkInTime'];
                              final points = item['points'] ?? 10;
                              final photoPath = item['photoPath'];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    if (photoPath != null &&
                                        photoPath.isNotEmpty) {
                                      _showPhotoDialog(photoPath, date, time);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Photo Thumbnail
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child:
                                              photoPath != null &&
                                                  photoPath.isNotEmpty &&
                                                  File(photoPath).existsSync()
                                              ? Image.file(
                                                  File(photoPath),
                                                  width: 60,
                                                  height: 60,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey.shade200,
                                                  child: Icon(
                                                    Icons.photo_camera,
                                                    color: Colors.grey.shade400,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 16),

                                        // Date & Time
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                DateFormat(
                                                  'EEEE, d MMMM yyyy',
                                                  'id_ID',
                                                ).format(date),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    time,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Points Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.shade50,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            border: Border.all(
                                              color: Colors.orange.shade200,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.orange,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '+$points',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.orange,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  void _showPhotoDialog(String photoPath, DateTime date, String time) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.photo, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, d MMM yyyy', 'id_ID').format(date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Photo
            if (File(photoPath).existsSync())
              Image.file(File(photoPath), fit: BoxFit.contain)
            else
              Container(
                height: 300,
                color: Colors.grey.shade200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Foto tidak ditemukan',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
