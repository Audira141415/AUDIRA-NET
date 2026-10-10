import 'package:flutter/material.dart';

/// Enhanced Loading Indicator with contextual messages and animations
class EnhancedLoadingIndicator extends StatelessWidget {
  final String? title;
  final String? message;
  final bool showProgress;
  final double? progress;
  final Color? color;
  final LoadingType type;

  const EnhancedLoadingIndicator({
    super.key,
    this.title,
    this.message,
    this.showProgress = false,
    this.progress,
    this.color,
    this.type = LoadingType.circular,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.primaryColor;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Loading Animation
            _buildLoadingAnimation(primaryColor),

            if (title != null) ...[
              const SizedBox(height: 24),
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (showProgress && progress != null) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progress! * 100).toInt()}%',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingAnimation(Color primaryColor) {
    switch (type) {
      case LoadingType.circular:
        return CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        );
      case LoadingType.linear:
        return SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            backgroundColor: primaryColor.withOpacity(0.2),
          ),
        );
      case LoadingType.dots:
        return _DotsLoadingAnimation(color: primaryColor);
      case LoadingType.pulse:
        return _PulseLoadingAnimation(color: primaryColor);
    }
  }
}

class _DotsLoadingAnimation extends StatefulWidget {
  final Color color;

  const _DotsLoadingAnimation({required this.color});

  @override
  State<_DotsLoadingAnimation> createState() => _DotsLoadingAnimationState();
}

class _DotsLoadingAnimationState extends State<_DotsLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final scale = Tween(
              begin: 0.5,
              end: 1.0,
            ).transform(Curves.elasticOut.transform(value));

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _PulseLoadingAnimation extends StatefulWidget {
  final Color color;

  const _PulseLoadingAnimation({required this.color});

  @override
  State<_PulseLoadingAnimation> createState() => _PulseLoadingAnimationState();
}

class _PulseLoadingAnimationState extends State<_PulseLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

enum LoadingType { circular, linear, dots, pulse }

/// Enhanced Empty State with better UX
class EnhancedEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? illustration;
  final EdgeInsets padding;

  const EnhancedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.illustration,
    this.padding = const EdgeInsets.all(32),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration or Icon
            if (illustration != null)
              illustration!
            else
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 64, color: colorScheme.primary),
              ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            // Description
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Enhanced Error State Widget
class EnhancedErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final String? errorDetails;
  final String? retryLabel;
  final String? supportLabel;
  final VoidCallback? onRetry;
  final VoidCallback? onSupport;
  final IconData icon;
  final bool showErrorDetails;

  const EnhancedErrorState({
    super.key,
    required this.title,
    this.description,
    this.errorDetails,
    this.retryLabel,
    this.supportLabel,
    this.onRetry,
    this.onSupport,
    this.icon = Icons.error_outline,
    this.showErrorDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: colorScheme.error),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),

            // Description
            if (description != null) ...[
              const SizedBox(height: 12),
              Text(
                description!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // Error Details (Expandable)
            if (showErrorDetails && errorDetails != null) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Error Details'),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      errorDetails!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Action Buttons
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: Text(retryLabel ?? 'Coba Lagi'),
                  ),
                if (onSupport != null)
                  OutlinedButton.icon(
                    onPressed: onSupport,
                    icon: const Icon(Icons.support_agent),
                    label: Text(supportLabel ?? 'Bantuan'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
