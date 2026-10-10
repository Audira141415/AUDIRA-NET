import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Bottom sheet untuk batch operations
class BatchOperationsSheet extends StatefulWidget {
  final int selectedCount;
  final List<BatchAction> actions;
  final VoidCallback onCancel;

  const BatchOperationsSheet({
    super.key,
    required this.selectedCount,
    required this.actions,
    required this.onCancel,
  });

  @override
  State<BatchOperationsSheet> createState() => _BatchOperationsSheetState();
}

class _BatchOperationsSheetState extends State<BatchOperationsSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Operasi Batch',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: widget.onCancel,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.selectedCount} item dipilih',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.primaryCyan,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.actions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final action = widget.actions[index];
              return _BatchActionTile(action: action);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: theme.dividerColor),
              ),
              child: const Text('Batalkan'),
            ),
          ),
        ],
      ),
    );
  }
}

class _BatchActionTile extends StatelessWidget {
  final BatchAction action;

  const _BatchActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: action.color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (action.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        action.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Model untuk batch action
class BatchAction {
  final String title;
  final String? description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const BatchAction({
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// Floating action button untuk batch mode
class BatchModeButton extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onPressed;
  final VoidCallback? onCancel;

  const BatchModeButton({
    super.key,
    required this.selectedCount,
    required this.onPressed,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryCyan,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryCyan.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$selectedCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Operasi Batch',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (onCancel != null) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: onCancel,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Checkbox untuk batch selection
class BatchSelectCheckbox extends StatelessWidget {
  final bool selected;
  final ValueChanged<bool?> onChanged;

  const BatchSelectCheckbox({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.1,
      child: Checkbox(
        value: selected,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        activeColor: AppTheme.primaryCyan,
      ),
    );
  }
}

/// Header untuk batch selection mode
class BatchSelectionHeader extends StatelessWidget {
  final int selectedCount;
  final int totalCount;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;

  const BatchSelectionHeader({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    required this.onSelectAll,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    final allSelected = selectedCount == totalCount && totalCount > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryCyan.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryCyan.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          BatchSelectCheckbox(
            selected: allSelected,
            onChanged: (value) {
              if (value == true) {
                onSelectAll();
              } else {
                onClearSelection();
              }
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selectedCount > 0
                  ? '$selectedCount dari $totalCount dipilih'
                  : 'Pilih semua ($totalCount)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryCyan,
              ),
            ),
          ),
          if (selectedCount > 0)
            TextButton(
              onPressed: onClearSelection,
              child: const Text('Batal'),
            ),
        ],
      ),
    );
  }
}

/// Confirmation dialog untuk batch operations
Future<bool?> showBatchConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required int itemCount,
  String confirmText = 'Ya, Lanjutkan',
  String cancelText = 'Batal',
  Color? confirmColor,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (confirmColor ?? AppTheme.primaryCyan)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: confirmColor ?? AppTheme.primaryCyan,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$itemCount item akan diproses',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: confirmColor ?? AppTheme.primaryCyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmColor ?? AppTheme.primaryCyan,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}
