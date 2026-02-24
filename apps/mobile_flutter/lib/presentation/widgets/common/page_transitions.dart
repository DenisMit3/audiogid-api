import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';

/// Custom page transition builder for smooth page animations
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeSlideTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

/// Combined fade and slide transition
class FadeSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const FadeSlideTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: AppCurves.emphasized,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppCurves.emphasized,
    ));

    final secondaryFadeAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeInOut,
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: FadeTransition(
          opacity:
              Tween<double>(begin: 1, end: 0.9).animate(secondaryFadeAnimation),
          child: child,
        ),
      ),
    );
  }
}

/// Custom page transition for GoRouter
CustomTransitionPage<T> buildPageWithTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
  TransitionType type = TransitionType.fade,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppDurations.pageTransition,
    reverseTransitionDuration: AppDurations.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (type) {
        case TransitionType.fade:
          return _buildFadeTransition(animation, child);
        case TransitionType.slide:
          return _buildSlideTransition(animation, child);
        case TransitionType.scale:
          return _buildScaleTransition(animation, child);
        case TransitionType.fadeSlide:
          return _buildFadeSlideTransition(animation, child);
        case TransitionType.sharedAxis:
          return _buildSharedAxisTransition(
              animation, secondaryAnimation, child);
      }
    },
  );
}

enum TransitionType {
  fade,
  slide,
  scale,
  fadeSlide,
  sharedAxis,
}

Widget _buildFadeTransition(Animation<double> animation, Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: AppCurves.emphasized,
    ),
    child: child,
  );
}

Widget _buildSlideTransition(Animation<double> animation, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppCurves.emphasized,
    )),
    child: child,
  );
}

Widget _buildScaleTransition(Animation<double> animation, Widget child) {
  return ScaleTransition(
    scale: Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: animation,
        curve: AppCurves.emphasized,
      ),
    ),
    child: FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}

Widget _buildFadeSlideTransition(Animation<double> animation, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: AppCurves.emphasized,
    )),
    child: FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}

Widget _buildSharedAxisTransition(
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: AppCurves.emphasized,
      )),
      child: child,
    ),
  );
}

/// Hero animation helper for smooth image transitions
class HeroImage extends StatelessWidget {
  final String tag;
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const HeroImage({
    super.key,
    required this.tag,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // #region agent log
    print('[DEBUG f46abe] HeroImage.build: tag=$tag, imageUrl=$imageUrl');
    // #endregion

    Widget imageWidget;
    if (imageUrl == null || imageUrl!.isEmpty) {
      // #region agent log
      print('[DEBUG f46abe] HeroImage: URL is null/empty, showing placeholder');
      // #endregion
      imageWidget = placeholder ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.6),
                  colorScheme.secondary.withOpacity(0.6),
                ],
              ),
              borderRadius: borderRadius,
            ),
            child: Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.white.withOpacity(0.7),
            ),
          );
    } else {
      // #region agent log
      print('[DEBUG f46abe] HeroImage: Loading image from URL: $imageUrl');
      // #endregion

      // Check if it's a data URL (base64 encoded)
      if (imageUrl!.startsWith('data:')) {
        // #region agent log
        print(
            '[DEBUG f46abe] HeroImage: Detected data URL, using Image.memory');
        // #endregion
        try {
          // Extract base64 data from data URL
          final dataUri = Uri.parse(imageUrl!);
          final base64Data = imageUrl!.split(',').last;
          final bytes = base64Decode(base64Data);
          imageWidget = Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              // #region agent log
              print('[DEBUG f46abe] HeroImage data URL ERROR: $error');
              // #endregion
              return Container(
                width: width,
                height: height,
                color: colorScheme.errorContainer,
                child: Icon(Icons.broken_image,
                    color: colorScheme.onErrorContainer),
              );
            },
          );
        } catch (e) {
          // #region agent log
          print('[DEBUG f46abe] HeroImage data URL parse ERROR: $e');
          // #endregion
          imageWidget = Container(
            width: width,
            height: height,
            color: colorScheme.errorContainer,
            child:
                Icon(Icons.broken_image, color: colorScheme.onErrorContainer),
          );
        }
      } else {
        // Regular network URL
        imageWidget = CachedNetworkImage(
          imageUrl: imageUrl!,
          width: width,
          height: height,
          fit: fit,
          progressIndicatorBuilder: (context, url, progress) {
            // #region agent log
            print(
                '[DEBUG f46abe] HeroImage PROGRESS: url=$url, downloaded=${progress.downloaded}, total=${progress.totalSize}, percent=${progress.progress}');
            // #endregion
            return Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.6),
                    colorScheme.secondary.withOpacity(0.6),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      value: progress.progress,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      progress.progress != null
                          ? '${(progress.progress! * 100).toInt()}%'
                          : 'Загрузка...',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
          errorWidget: (context, url, error) {
            // #region agent log
            print('[DEBUG f46abe] HeroImage ERROR: url=$url, error=$error');
            // #endregion
            return Container(
              width: width,
              height: height,
              color: colorScheme.errorContainer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image,
                      color: colorScheme.onErrorContainer, size: 32),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'Ошибка: $error',
                      style: TextStyle(
                          color: colorScheme.onErrorContainer, fontSize: 10),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return Hero(
      tag: tag,
      flightShuttleBuilder:
          (flightContext, animation, direction, fromContext, toContext) {
        return Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: borderRadius ?? BorderRadius.zero,
                child: imageWidget,
              );
            },
          ),
        );
      },
      child: imageWidget,
    );
  }
}

/// Staggered animation list item
class StaggeredListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration staggerDuration;
  final Duration animationDuration;

  const StaggeredListItem({
    super.key,
    required this.child,
    required this.index,
    this.staggerDuration = const Duration(milliseconds: 50),
    this.animationDuration = AppDurations.normal,
  });

  @override
  State<StaggeredListItem> createState() => _StaggeredListItemState();
}

class _StaggeredListItemState extends State<StaggeredListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.emphasized,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppCurves.emphasized,
    ));

    Future.delayed(widget.staggerDuration * widget.index, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animated list builder with staggered entrance
class StaggeredListBuilder extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final EdgeInsets? padding;
  final ScrollController? controller;
  final Duration staggerDuration;

  const StaggeredListBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.controller,
    this.staggerDuration = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return StaggeredListItem(
          index: index,
          staggerDuration: staggerDuration,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}

/// Bouncing button animation
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double scaleFactor;
  final Duration duration;

  const BouncingButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.scaleFactor = 0.95,
    this.duration = AppDurations.instant,
  });

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    _controller.forward();
  }

  void _onTapUp(_) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Pulse animation for attention-grabbing elements
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 0.95,
    this.maxScale = 1.0,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Ripple/loading indicator animation
class RippleLoadingIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final int rippleCount;

  const RippleLoadingIndicator({
    super.key,
    this.size = 100,
    this.color,
    this.rippleCount = 3,
  });

  @override
  State<RippleLoadingIndicator> createState() => _RippleLoadingIndicatorState();
}

class _RippleLoadingIndicatorState extends State<RippleLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
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
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(widget.rippleCount, (index) {
          final delay = index / widget.rippleCount;
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final animValue = (_controller.value + delay) % 1.0;
              return Transform.scale(
                scale: animValue,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(1 - animValue),
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
