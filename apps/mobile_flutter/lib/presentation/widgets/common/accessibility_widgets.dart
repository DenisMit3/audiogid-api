import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Wrapper for adding accessibility features to any widget
class AccessibleWidget extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? hint;
  final bool excludeFromSemantics;
  final bool isButton;
  final bool isLink;
  final bool isHeader;
  final bool isImage;
  final VoidCallback? onTap;

  const AccessibleWidget({
    super.key,
    required this.child,
    this.semanticLabel,
    this.hint,
    this.excludeFromSemantics = false,
    this.isButton = false,
    this.isLink = false,
    this.isHeader = false,
    this.isImage = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (excludeFromSemantics) {
      return ExcludeSemantics(child: child);
    }

    return Semantics(
      label: semanticLabel,
      hint: hint,
      button: isButton,
      link: isLink,
      header: isHeader,
      image: isImage,
      onTap: onTap,
      child: child,
    );
  }
}

/// Accessible icon button with proper semantics
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color? color;
  final double? size;
  final bool isSelected;
  final EdgeInsetsGeometry? padding;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.size,
    this.isSelected = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      selected: isSelected,
      child: IconButton(
        icon: Icon(icon, color: color, size: size),
        tooltip: tooltip,
        onPressed: onPressed,
        padding: padding,
      ),
    );
  }
}

/// Card that announces its content for screen readers
class AccessibleCard extends StatelessWidget {
  final Widget child;
  final String? semanticLabel;
  final String? hint;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const AccessibleCard({
    super.key,
    required this.child,
    this.semanticLabel,
    this.hint,
    this.onTap,
    this.margin,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Card(
      margin: margin,
      color: backgroundColor,
      child: padding != null 
          ? Padding(padding: padding!, child: child) 
          : child,
    );

    if (onTap != null) {
      cardContent = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }

    return Semantics(
      label: semanticLabel,
      hint: hint ?? (onTap != null ? 'Нажмите для просмотра' : null),
      button: onTap != null,
      child: cardContent,
    );
  }
}

/// Image with proper accessibility and fallback
class AccessibleImage extends StatelessWidget {
  final String? imageUrl;
  final String semanticLabel;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const AccessibleImage({
    super.key,
    this.imageUrl,
    required this.semanticLabel,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget imageWidget;

    if (imageUrl == null || imageUrl!.isEmpty) {
      imageWidget = _buildPlaceholder(colorScheme);
    } else {
      imageWidget = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? _buildLoadingPlaceholder(colorScheme);
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? _buildErrorPlaceholder(colorScheme);
        },
      );
    }

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return Semantics(
      image: true,
      label: semanticLabel,
      child: imageWidget,
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.image_outlined,
        color: colorScheme.onSurfaceVariant,
        size: 48,
      ),
    );
  }

  Widget _buildLoadingPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: width,
      height: height,
      color: colorScheme.surfaceVariant,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorPlaceholder(ColorScheme colorScheme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.3),
        borderRadius: borderRadius,
      ),
      child: Icon(
        Icons.broken_image_outlined,
        color: colorScheme.error,
        size: 48,
      ),
    );
  }
}

/// List tile with proper accessibility
class AccessibleListTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final EdgeInsetsGeometry? contentPadding;
  final bool isThreeLine;

  const AccessibleListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.semanticLabel,
    this.contentPadding,
    this.isThreeLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      child: ListTile(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
        contentPadding: contentPadding,
        isThreeLine: isThreeLine,
      ),
    );
  }
}

/// Header widget for screen reader navigation
class AccessibleHeader extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int level;

  const AccessibleHeader({
    super.key,
    required this.text,
    this.style,
    this.level = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    
    final defaultStyle = switch (level) {
      1 => textTheme.headlineLarge,
      2 => textTheme.headlineMedium,
      3 => textTheme.headlineSmall,
      4 => textTheme.titleLarge,
      _ => textTheme.titleMedium,
    };

    return Semantics(
      header: true,
      child: Text(
        text,
        style: style ?? defaultStyle,
      ),
    );
  }
}

/// Skip to content link for keyboard navigation
class SkipToContentButton extends StatelessWidget {
  final FocusNode? focusNode;
  final VoidCallback onSkip;

  const SkipToContentButton({
    super.key,
    this.focusNode,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      link: true,
      label: 'Перейти к основному содержимому',
      child: Focus(
        focusNode: focusNode,
        child: Builder(
          builder: (context) {
            final hasFocus = Focus.of(context).hasFocus;
            if (!hasFocus) return const SizedBox.shrink();
            
            return Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Перейти к содержимому',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Announcer for dynamic content changes
class AccessibilityAnnouncer {
  static void announce(BuildContext context, String message, {bool isPolite = true}) {
    SemanticsService.announce(
      message,
      isPolite ? TextDirection.ltr : TextDirection.ltr,
    );
  }

  static void announceNavigation(BuildContext context, String routeName) {
    announce(context, 'Переход на экран: $routeName');
  }

  static void announceError(BuildContext context, String error) {
    SemanticsService.announce(
      'Ошибка: $error',
      TextDirection.ltr,
    );
  }

  static void announceSuccess(BuildContext context, String message) {
    announce(context, message);
  }
}

/// Focus traversal helper for proper keyboard navigation order
class FocusTraversalWidget extends StatelessWidget {
  final List<Widget> children;
  final Axis direction;

  const FocusTraversalWidget({
    super.key,
    required this.children,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: direction == Axis.vertical
          ? Column(children: children)
          : Row(children: children),
    );
  }
}

/// Minimum touch target size wrapper (48x48 dp for accessibility)
class MinTouchTarget extends StatelessWidget {
  final Widget child;
  final double minSize;

  const MinTouchTarget({
    super.key,
    required this.child,
    this.minSize = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: Center(child: child),
    );
  }
}
