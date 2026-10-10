import 'package:flutter/material.dart';

/// Shimmer image loader dengan fallback
class ShimmerImage extends StatefulWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ShimmerImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  State<ShimmerImage> createState() => _ShimmerImageState();
}

class _ShimmerImageState extends State<ShimmerImage>
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

    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      child: Image.network(
        widget.imageUrl!,
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildShimmer(isDark);
        },
        errorBuilder: (context, error, stackTrace) {
          return widget.errorWidget ?? _buildError(isDark);
        },
      ),
    );
  }

  Widget _buildShimmer(bool isDark) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDark
                  ? [
                      Colors.grey[800]!,
                      Colors.grey[700]!,
                      Colors.grey[800]!,
                    ]
                  : [
                      Colors.grey[300]!,
                      Colors.grey[200]!,
                      Colors.grey[300]!,
                    ],
              stops: [
                _shimmerController.value - 0.3,
                _shimmerController.value,
                _shimmerController.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    if (widget.placeholder != null) return widget.placeholder!;

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: widget.borderRadius,
      ),
      child: Icon(
        Icons.image,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        size: 48,
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: widget.borderRadius,
      ),
      child: Icon(
        Icons.broken_image,
        color: isDark ? Colors.grey[600] : Colors.grey[400],
        size: 48,
      ),
    );
  }
}

/// Circular shimmer image (untuk avatars)
class ShimmerAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData defaultIcon;

  const ShimmerAvatar({
    super.key,
    this.imageUrl,
    this.radius = 24,
    this.defaultIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerImage(
      imageUrl: imageUrl,
      width: radius * 2,
      height: radius * 2,
      borderRadius: BorderRadius.circular(radius),
      placeholder: CircleAvatar(
        radius: radius,
        child: Icon(defaultIcon, size: radius),
      ),
    );
  }
}
