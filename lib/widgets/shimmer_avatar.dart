import 'package:flutter/material.dart';

/// Shimmer avatar loader dengan fallback untuk profile pictures
class ShimmerAvatar extends StatefulWidget {
  final String? imageUrl;
  final double radius;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const ShimmerAvatar({
    super.key,
    this.imageUrl,
    this.radius = 40,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  State<ShimmerAvatar> createState() => _ShimmerAvatarState();
}

class _ShimmerAvatarState extends State<ShimmerAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return _buildPlaceholder(isDark);
    }

    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            widget.backgroundColor ??
            (isDark ? Colors.grey[800] : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          widget.imageUrl!,
          width: widget.radius * 2,
          height: widget.radius * 2,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildShimmer(isDark);
          },
          errorBuilder: (context, error, stackTrace) {
            return _buildError(isDark);
          },
        ),
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDark
                  ? [Colors.grey[800]!, Colors.grey[700]!, Colors.grey[800]!]
                  : [Colors.grey[300]!, Colors.grey[200]!, Colors.grey[300]!],
              stops: [
                (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                _shimmerController.value.clamp(0.0, 1.0),
                (_shimmerController.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            widget.backgroundColor ??
            (isDark ? Colors.grey[800] : Colors.white),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          widget.errorWidget ??
          Icon(
            Icons.person_rounded,
            size: widget.radius,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
    );
  }

  Widget _buildError(bool isDark) {
    return Container(
      width: widget.radius * 2,
      height: widget.radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            widget.backgroundColor ??
            (isDark ? Colors.grey[800] : Colors.grey[100]),
      ),
      child:
          widget.errorWidget ??
          Icon(
            Icons.person_rounded,
            size: widget.radius,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
    );
  }
}
