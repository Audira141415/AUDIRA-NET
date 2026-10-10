import 'package:flutter/material.dart';
import '../widgets/quick_stats.dart';
import '../widgets/shimmer_image.dart';
import '../widgets/swipeable_items.dart';
import '../widgets/date_range_picker.dart';
import '../widgets/batch_operations.dart';
import '../widgets/copy_clipboard.dart';
import '../widgets/share_widget.dart';
import '../utils/app_theme.dart';

/// Example page demonstrating Quick Wins features integration
class QuickWinsDemoPage extends StatefulWidget {
  const QuickWinsDemoPage({super.key});

  @override
  State<QuickWinsDemoPage> createState() => _QuickWinsDemoPageState();
}

class _QuickWinsDemoPageState extends State<QuickWinsDemoPage> {
  DateTime? startDate;
  DateTime? endDate;
  List<String> selectedItems = [];
  final List<String> demoItems = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Quick Wins Demo'),
        actions: [
          ShareIconButton(
            text: 'Check out Quick Wins features!',
            subject: 'AudiraNet Quick Wins',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Quick Stats Section
          _buildStatsSection(),
          const SizedBox(height: 24),

          // 2. Date Range Picker Section
          _buildDateRangeSection(),
          const SizedBox(height: 24),

          // 3. Shimmer Image Section
          _buildShimmerImageSection(),
          const SizedBox(height: 24),

          // 4. Copy to Clipboard Section
          _buildCopySection(),
          const SizedBox(height: 24),

          // 5. Batch Operations Section
          _buildBatchSection(),
          const SizedBox(height: 24),

          // 6. Swipeable Items Section
          _buildSwipeableSection(),
        ],
      ),
      floatingActionButton: selectedItems.isNotEmpty
          ? BatchModeButton(
              selectedCount: selectedItems.length,
              onPressed: _showBatchOperations,
              onCancel: () => setState(() => selectedItems.clear()),
            )
          : null,
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📈 Quick Stats',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        StatsGrid(
          stats: [
            QuickStatCard(
              title: 'Total Users',
              value: '1,245',
              icon: Icons.people,
              color: AppTheme.primaryCyan,
              trend: '+12%',
              isIncrease: true,
              subtitle: 'Active this month',
            ),
            QuickStatCard(
              title: 'Revenue',
              value: '\$45.2K',
              icon: Icons.attach_money,
              color: Colors.green,
              trend: '+8%',
              isIncrease: true,
            ),
            QuickStatCard(
              title: 'Pending',
              value: '\$2.1K',
              icon: Icons.pending,
              color: Colors.orange,
              trend: '-5%',
              isIncrease: false,
            ),
            QuickStatCard(
              title: 'Completed',
              value: '892',
              icon: Icons.check_circle,
              color: Colors.blue,
              trend: '+15%',
              isIncrease: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📅 Date Range Picker',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        DateRangePicker(
          startDate: startDate,
          endDate: endDate,
          onDateRangeSelected: (range) {
            setState(() {
              startDate = range?.start;
              endDate = range?.end;
            });
          },
        ),
        const SizedBox(height: 12),
        QuickDateRangeSelector(
          onRangeSelected: (range) {
            setState(() {
              startDate = range.start;
              endDate = range.end;
            });
          },
        ),
      ],
    );
  }

  Widget _buildShimmerImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🖼️ Shimmer Image Loading',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ShimmerAvatar(
              imageUrl: 'https://via.placeholder.com/150',
              radius: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ShimmerImage(
                imageUrl: 'https://via.placeholder.com/300x200',
                height: 120,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCopySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📋 Copy to Clipboard',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CopyableCard(
          title: 'Customer ID',
          value: 'CUST-12345-ABC',
          icon: Icons.badge,
          successMessage: 'Customer ID copied!',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CopyButton(
                text: 'account@example.com',
                label: 'Copy Email',
                outlined: true,
              ),
            ),
            const SizedBox(width: 12),
            CopyIconButton(text: '+1234567890', tooltip: 'Copy Phone'),
          ],
        ),
      ],
    );
  }

  Widget _buildBatchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '✅ Batch Selection',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        BatchSelectionHeader(
          selectedCount: selectedItems.length,
          totalCount: demoItems.length,
          onSelectAll: () => setState(() {
            selectedItems = List.from(demoItems);
          }),
          onClearSelection: () => setState(() {
            selectedItems.clear();
          }),
        ),
      ],
    );
  }

  Widget _buildSwipeableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '👆 Swipeable Items',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...demoItems.map((item) {
          final isSelected = selectedItems.contains(item);
          return SwipeableListItem(
            key: ValueKey(item),
            onDelete: () async {
              setState(() => demoItems.remove(item));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$item deleted')));
            },
            onEdit: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Edit $item')));
            },
            child: ListTile(
              leading: BatchSelectCheckbox(
                selected: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedItems.add(item);
                    } else {
                      selectedItems.remove(item);
                    }
                  });
                },
              ),
              title: Text(item),
              subtitle: Text('Swipe left to edit, right to delete'),
              trailing: Icon(Icons.drag_handle),
            ),
          );
        }),
        const SizedBox(height: 16),
        ExpandableListItem(
          title: const Text('More Information'),
          actions: [
            QuickActionChip(
              label: 'Details',
              icon: Icons.info_outline,
              onTap: () {},
            ),
          ],
          leading: const Icon(Icons.info_outline),
          subtitle: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Swipe gestures:'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.arrow_back, size: 16),
                    const SizedBox(width: 8),
                    const Text('Swipe left to edit'),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.arrow_forward, size: 16),
                    const SizedBox(width: 8),
                    const Text('Swipe right to delete'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showBatchOperations() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BatchOperationsSheet(
        selectedCount: selectedItems.length,
        actions: [
          BatchAction(
            title: 'Delete Selected',
            description: 'Remove all selected items',
            icon: Icons.delete,
            color: Colors.red,
            onTap: () async {
              final confirm = await showBatchConfirmDialog(
                context: context,
                title: 'Delete Items',
                message: 'Are you sure you want to delete the selected items?',
                itemCount: selectedItems.length,
                confirmColor: Colors.red,
              );
              if (confirm == true && mounted) {
                setState(() {
                  demoItems.removeWhere((item) => selectedItems.contains(item));
                  selectedItems.clear();
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Items deleted')),
                  );
                }
              }
            },
          ),
          BatchAction(
            title: 'Share Selected',
            description: 'Share selected items',
            icon: Icons.share,
            color: AppTheme.primaryCyan,
            onTap: () {
              if (mounted) Navigator.pop(context);
              ShareHelper.shareText(
                text: 'Selected items: ${selectedItems.join(", ")}',
                subject: 'Shared Items',
              );
            },
          ),
        ],
        onCancel: () => Navigator.pop(context),
      ),
    );
  }
}
