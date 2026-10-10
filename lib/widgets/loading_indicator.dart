import 'package:flutter/material.dart';
import 'enhanced_ui_components.dart';

class LoadingIndicator extends StatelessWidget {
  final String? message;
  final String? title;
  final bool showProgress;
  final double? progress;
  final LoadingType type;

  const LoadingIndicator({
    super.key,
    this.message,
    this.title,
    this.showProgress = false,
    this.progress,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedLoadingIndicator(
      title: title,
      message: message,
      showProgress: showProgress,
      progress: progress,
      type: type,
    );
  }
}
