import 'package:flutter/material.dart';
import 'enhanced_ui_components.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedEmptyState(
      icon: icon,
      title: title,
      description: message,
      actionLabel: actionText,
      onAction: onAction,
    );
  }
}
