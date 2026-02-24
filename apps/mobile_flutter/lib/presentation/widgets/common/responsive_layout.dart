import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';

/// Safe area wrapper that handles notch, system bars, and keyboard
class SafeAreaWrapper extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final EdgeInsets? minimum;
  final bool maintainBottomViewPadding;

  const SafeAreaWrapper({
    super.key,
    required this.child,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.minimum,
    this.maintainBottomViewPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      minimum: minimum ?? EdgeInsets.zero,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }
}

/// Responsive padding container
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? customPadding;
  final bool horizontal;
  final bool vertical;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.customPadding,
    this.horizontal = true,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveH = context.horizontalPadding;

    final padding = customPadding ??
        EdgeInsets.symmetric(
          horizontal: horizontal ? responsiveH : 0,
          vertical: vertical ? AppSpacing.md : 0,
        );

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive container that adapts width based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final Alignment alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.screenWidth;
    final defaultMaxWidth = context.responsive(
      phone: double.infinity,
      tablet: 720.0,
      largeTablet: 960.0,
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? defaultMaxWidth,
        ),
        child:
            padding != null ? Padding(padding: padding!, child: child) : child,
      ),
    );
  }
}

/// Responsive grid that adapts column count based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final EdgeInsets? padding;
  final int? minCrossAxisCount;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = AppSpacing.md,
    this.runSpacing = AppSpacing.md,
    this.padding,
    this.minCrossAxisCount,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.responsive(
      smallPhone: 1,
      phone: minCrossAxisCount ?? 2,
      tablet: 3,
      largeTablet: 4,
    );

    return GridView.builder(
      padding: padding ?? EdgeInsets.all(context.horizontalPadding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: runSpacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive sliver grid for CustomScrollView
class ResponsiveSliverGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  const ResponsiveSliverGrid({
    super.key,
    required this.children,
    this.spacing = AppSpacing.md,
    this.runSpacing = AppSpacing.md,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = context.responsive(
      smallPhone: 1,
      phone: 2,
      tablet: 3,
      largeTablet: 4,
    );

    return SliverGrid(
      delegate: SliverChildListDelegate(children),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: runSpacing,
        crossAxisSpacing: spacing,
        childAspectRatio: childAspectRatio,
      ),
    );
  }
}

/// Adaptive layout for landscape/portrait
class AdaptiveLayout extends StatelessWidget {
  final Widget portraitLayout;
  final Widget landscapeLayout;

  const AdaptiveLayout({
    super.key,
    required this.portraitLayout,
    required this.landscapeLayout,
  });

  @override
  Widget build(BuildContext context) {
    return context.isLandscape ? landscapeLayout : portraitLayout;
  }
}

/// Split view for tablets
class SplitView extends StatelessWidget {
  final Widget master;
  final Widget detail;
  final double masterWidth;
  final Color? dividerColor;

  const SplitView({
    super.key,
    required this.master,
    required this.detail,
    this.masterWidth = 320,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!context.isTablet) {
      // On phones, only show master
      return master;
    }

    return Row(
      children: [
        SizedBox(
          width: masterWidth,
          child: master,
        ),
        VerticalDivider(
          width: 1,
          color: dividerColor ?? Theme.of(context).dividerColor,
        ),
        Expanded(child: detail),
      ],
    );
  }
}

/// Bottom sheet safe padding for devices with gesture bars
class BottomSheetSafePadding extends StatelessWidget {
  final double extraPadding;

  const BottomSheetSafePadding({
    super.key,
    this.extraPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return SizedBox(height: bottomPadding + extraPadding);
  }
}

/// Keyboard-aware scaffold body
class KeyboardAwareBody extends StatelessWidget {
  final Widget child;
  final bool resizeToAvoidBottomInset;
  final ScrollController? scrollController;

  const KeyboardAwareBody({
    super.key,
    required this.child,
    this.resizeToAvoidBottomInset = true,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    if (!resizeToAvoidBottomInset) {
      return child;
    }

    final viewInsets = MediaQuery.of(context).viewInsets;

    return AnimatedPadding(
      duration: AppDurations.fast,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: child,
    );
  }
}

/// Responsive app bar with adaptive actions
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final double? elevation;
  final Color? backgroundColor;
  final bool centerTitle;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.elevation,
    this.backgroundColor,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final effectiveActions =
        context.isSmallPhone && actions != null && actions!.length > 2
            ? [
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => actions!
                      .asMap()
                      .entries
                      .map((e) => PopupMenuItem(
                            value: e.key,
                            child: e.value,
                          ))
                      .toList(),
                ),
              ]
            : actions;

    return AppBar(
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: effectiveActions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      elevation: elevation,
      backgroundColor: backgroundColor,
      centerTitle: centerTitle,
    );
  }
}

/// Floating action button with safe area awareness
class SafeFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final String? tooltip;
  final Color? backgroundColor;
  final bool mini;
  final bool extended;
  final String? label;
  final IconData? icon;

  const SafeFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tooltip,
    this.backgroundColor,
    this.mini = false,
    this.extended = false,
    this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    Widget fab;
    if (extended && label != null) {
      fab = FloatingActionButton.extended(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        icon: icon != null ? Icon(icon) : null,
        label: Text(label!),
      );
    } else {
      fab = FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: backgroundColor,
        mini: mini,
        child: child,
      );
    }

    // Add extra bottom padding if there's a safe area
    if (bottomPadding > 0) {
      return Padding(
        padding: EdgeInsets.only(bottom: bottomPadding / 2),
        child: fab,
      );
    }

    return fab;
  }
}
