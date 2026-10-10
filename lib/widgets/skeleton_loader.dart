import 'package:flutter/material.dart';

/// Skeleton loader with shimmer animation effect
class SkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16.0,
    this.borderRadius,
    this.margin,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: isDark
                  ? [Colors.grey[800]!, Colors.grey[700]!, Colors.grey[800]!]
                  : [Colors.grey[300]!, Colors.grey[200]!, Colors.grey[300]!],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Card skeleton for list items
class SkeletonCard extends StatelessWidget {
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const SkeletonCard({super.key, this.padding, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 16,
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      width: MediaQuery.of(context).size.width * 0.25,
                      height: 14,
                    ),
                  ],
                ),
              ),
              const SkeletonLoader(
                width: 60,
                height: 24,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonLoader(height: 12),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: MediaQuery.of(context).size.width * 0.7,
            height: 12,
          ),
        ],
      ),
    );
  }
}

/// List of skeleton cards
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final EdgeInsets? padding;

  const SkeletonList({super.key, this.itemCount = 5, this.padding});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }
}

/// Circle skeleton for avatars
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsets? margin;

  const SkeletonCircle({super.key, this.size = 48.0, this.margin});

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      margin: margin,
    );
  }
}

/// Rectangle skeleton for images
class SkeletonRectangle extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsets? margin;

  const SkeletonRectangle({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      width: width,
      height: height,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      margin: margin,
    );
  }
}

/// Dashboard card skeleton
class SkeletonDashboardCard extends StatelessWidget {
  const SkeletonDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonCircle(size: 40),
              const Spacer(),
              SkeletonLoader(
                width: 60,
                height: 24,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonLoader(width: 80, height: 32),
          const SizedBox(height: 8),
          SkeletonLoader(
            width: MediaQuery.of(context).size.width * 0.3,
            height: 14,
          ),
        ],
      ),
    );
  }
}

/// Table row skeleton
class SkeletonTableRow extends StatelessWidget {
  final int columns;

  const SkeletonTableRow({super.key, this.columns = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(
          columns,
          (index) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SkeletonLoader(height: 16, width: double.infinity),
            ),
          ),
        ),
      ),
    );
  }
}

/// Skeleton list with table rows
class SkeletonTable extends StatelessWidget {
  final int rowCount;
  final int columns;

  const SkeletonTable({super.key, this.rowCount = 5, this.columns = 4});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        rowCount,
        (index) => SkeletonTableRow(columns: columns),
      ),
    );
  }
}
