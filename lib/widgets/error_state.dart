import 'package:flutter/material.dart';
import 'enhanced_ui_components.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final String? errorDetails;
  final String? retryLabel;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorState({
    super.key,
    required this.title,
    this.description,
    this.errorDetails,
    this.retryLabel,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedErrorState(
      title: title,
      description: description,
      errorDetails: errorDetails,
      retryLabel: retryLabel,
      onRetry: onRetry,
      icon: icon,
      showErrorDetails: errorDetails != null,
    );
  }
}
