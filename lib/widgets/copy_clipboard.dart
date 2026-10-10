import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

/// Widget untuk copy text ke clipboard dengan feedback
class CopyableText extends StatelessWidget {
  final String text;
  final String? displayText;
  final TextStyle? style;
  final String? successMessage;
  final IconData icon;
  final bool showIcon;
  final Color? iconColor;

  const CopyableText({
    super.key,
    required this.text,
    this.displayText,
    this.style,
    this.successMessage,
    this.icon = Icons.copy,
    this.showIcon = true,
    this.iconColor,
  });

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  successMessage ?? 'Disalin ke clipboard',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _copyToClipboard(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayText ?? text,
              style:
                  style ??
                  TextStyle(
                    color: AppTheme.primaryCyan,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            if (showIcon) ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                size: 16,
                color: iconColor ?? theme.textTheme.bodySmall?.color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Button khusus untuk copy
class CopyButton extends StatefulWidget {
  final String text;
  final String? label;
  final String? successMessage;
  final IconData icon;
  final Color? color;
  final bool outlined;

  const CopyButton({
    super.key,
    required this.text,
    this.label,
    this.successMessage,
    this.icon = Icons.copy,
    this.color,
    this.outlined = false,
  });

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCopy(BuildContext context) async {
    await _controller.forward();
    await _controller.reverse();

    await Clipboard.setData(ClipboardData(text: widget.text));

    setState(() => _copied = true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.successMessage ?? 'Berhasil disalin',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.color ?? AppTheme.primaryCyan;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.outlined
          ? OutlinedButton.icon(
              onPressed: () => _handleCopy(context),
              icon: Icon(_copied ? Icons.check : widget.icon, size: 18),
              label: Text(widget.label ?? 'Salin'),
              style: OutlinedButton.styleFrom(
                foregroundColor: buttonColor,
                side: BorderSide(color: buttonColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: () => _handleCopy(context),
              icon: Icon(_copied ? Icons.check : widget.icon, size: 18),
              label: Text(widget.label ?? 'Salin'),
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
    );
  }
}

/// Icon button untuk copy
class CopyIconButton extends StatefulWidget {
  final String text;
  final String? tooltip;
  final String? successMessage;
  final Color? color;

  const CopyIconButton({
    super.key,
    required this.text,
    this.tooltip,
    this.successMessage,
    this.color,
  });

  @override
  State<CopyIconButton> createState() => _CopyIconButtonState();
}

class _CopyIconButtonState extends State<CopyIconButton> {
  bool _copied = false;

  Future<void> _handleCopy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: widget.text));

    setState(() => _copied = true);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.successMessage ?? 'Disalin ke clipboard',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _copied = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _copied ? Icons.check : Icons.copy,
        color: widget.color ?? AppTheme.primaryCyan,
      ),
      tooltip: widget.tooltip ?? 'Salin',
      onPressed: () => _handleCopy(context),
    );
  }
}

/// Card dengan copy button
class CopyableCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final String? successMessage;

  const CopyableCard({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.successMessage,
  });

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  successMessage ?? '$title disalin',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _copyToClipboard(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryCyan.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryCyan, size: 20),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.copy,
                size: 20,
                color: theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper untuk copy dengan feedback visual
class CopyHelper {
  static Future<void> copyWithFeedback({
    required BuildContext context,
    required String text,
    String? message,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message ?? 'Disalin ke clipboard',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
