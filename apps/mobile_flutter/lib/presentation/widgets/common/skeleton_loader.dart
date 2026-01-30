import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';

/// A shimmer loading effect for skeleton loaders
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  
  const ShimmerEffect({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
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
    if (!widget.isLoading) return widget.child;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark 
        ? Colors.grey[800]! 
        : Colors.grey[300]!;
    final highlightColor = isDark 
        ? Colors.grey[700]! 
        : Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Base skeleton container with rounded corners
class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonContainer({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}

/// Skeleton loader for text lines
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const SkeletonText({
    super.key,
    this.width = double.infinity,
    this.height = 14,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonContainer(
      width: width,
      height: height,
      margin: margin,
      borderRadius: BorderRadius.circular(4),
    );
  }
}

/// Skeleton loader for circular avatars
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({
    super.key,
    this.size = 48,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Skeleton loader for tour/POI cards
class SkeletonTourCard extends StatelessWidget {
  const SkeletonTourCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image placeholder
            SkeletonContainer(
              height: 160,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Row(
                    children: [
                      const Expanded(
                        child: SkeletonText(height: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      SkeletonContainer(
                        width: 60,
                        height: 24,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Description
                  const SkeletonText(width: double.infinity),
                  const SizedBox(height: AppSpacing.xs),
                  const SkeletonText(width: 200),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for list items
class SkeletonListTile extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;

  const SkeletonListTile({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            if (hasLeading) ...[
              const SkeletonCircle(size: 48),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonText(width: 180, height: 16),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonText(width: 120, height: 12),
                ],
              ),
            ),
            if (hasTrailing)
              SkeletonContainer(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(8),
              ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for POI detail screen
class SkeletonPoiDetail extends StatelessWidget {
  const SkeletonPoiDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero image
            const SkeletonContainer(
              height: 280,
              borderRadius: BorderRadius.zero,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const SkeletonText(width: double.infinity, height: 28),
                  const SizedBox(height: AppSpacing.sm),
                  // Category badge
                  SkeletonContainer(
                    width: 100,
                    height: 24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: SkeletonContainer(
                          height: 48,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: SkeletonContainer(
                          height: 48,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Description
                  const SkeletonText(width: double.infinity),
                  const SizedBox(height: AppSpacing.xs),
                  const SkeletonText(width: double.infinity),
                  const SizedBox(height: AppSpacing.xs),
                  const SkeletonText(width: 250),
                  const SizedBox(height: AppSpacing.lg),
                  // More content
                  const SkeletonText(width: double.infinity),
                  const SizedBox(height: AppSpacing.xs),
                  const SkeletonText(width: double.infinity),
                  const SizedBox(height: AppSpacing.xs),
                  const SkeletonText(width: 180),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for tour detail screen
class SkeletonTourDetail extends StatelessWidget {
  const SkeletonTourDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero image
            const SkeletonContainer(
              height: 240,
              borderRadius: BorderRadius.zero,
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const SkeletonText(width: double.infinity, height: 28),
                  const SizedBox(height: AppSpacing.md),
                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      3,
                      (_) => Column(
                        children: const [
                          SkeletonText(width: 60, height: 20),
                          SizedBox(height: AppSpacing.xs),
                          SkeletonText(width: 40, height: 12),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Map placeholder
                  SkeletonContainer(
                    height: 200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Section title
                  const SkeletonText(width: 150, height: 20),
                  const SizedBox(height: AppSpacing.md),
                  // Tour stops
                  ...List.generate(
                    3,
                    (_) => const Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: SkeletonListTile(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton loader for nearby map screen
class SkeletonNearbyScreen extends StatelessWidget {
  const SkeletonNearbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        children: [
          // Map area
          const Expanded(
            flex: 2,
            child: SkeletonContainer(
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
          ),
          // Bottom panel
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                // Handle
                SkeletonContainer(
                  width: 40,
                  height: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
                const SizedBox(height: AppSpacing.md),
                // List items
                ...List.generate(
                  3,
                  (_) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.sm),
                    child: SkeletonListTile(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
