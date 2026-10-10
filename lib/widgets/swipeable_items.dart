import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Swipeable list item dengan actions
class SwipeableListItem extends StatelessWidget {
  final Widget child;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final bool enableEdit;
  final bool enableDelete;
  final bool enableArchive;

  const SwipeableListItem({
    super.key,
    required this.child,
    this.onEdit,
    this.onDelete,
    this.onArchive,
    this.onTap,
    this.backgroundColor,
    this.enableEdit = true,
    this.enableDelete = true,
    this.enableArchive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      background: enableEdit && onEdit != null
          ? _buildSwipeBackground(
              context,
              alignment: Alignment.centerLeft,
              color: Colors.blue,
              icon: Icons.edit,
              label: 'Edit',
            )
          : null,
      secondaryBackground: enableDelete && onDelete != null
          ? _buildSwipeBackground(
              context,
              alignment: Alignment.centerRight,
              color: Colors.red,
              icon: Icons.delete,
              label: 'Hapus',
            )
          : null,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - Edit
          if (enableEdit && onEdit != null) {
            onEdit!();
            return false; // Don't dismiss
          }
        } else if (direction == DismissDirection.endToStart) {
          // Swipe left - Delete
          if (enableDelete && onDelete != null) {
            return await _showDeleteConfirmation(context);
          }
        }
        return false;
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          color: backgroundColor ?? Colors.transparent,
          child: child,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text('Apakah Anda yakin ingin menghapus item ini?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                  onDelete?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

/// Action chip untuk quick actions
class QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final bool isDestructive;

  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ??
        (isDestructive ? Colors.red : AppTheme.primaryCyan);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: chipColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: chipColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: chipColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Expandable list item dengan actions
class ExpandableListItem extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final List<Widget> actions;
  final Widget? leading;
  final EdgeInsets? padding;

  const ExpandableListItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.actions,
    this.leading,
    this.padding,
  });

  @override
  State<ExpandableListItem> createState() => _ExpandableListItemState();
}

class _ExpandableListItemState extends State<ExpandableListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _toggleExpanded,
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.all(16),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.title,
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        widget.subtitle!,
                      ],
                    ],
                  ),
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                  child: const Icon(Icons.keyboard_arrow_down),
                ),
              ],
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.actions,
            ),
          ),
        ),
      ],
    );
  }
}
