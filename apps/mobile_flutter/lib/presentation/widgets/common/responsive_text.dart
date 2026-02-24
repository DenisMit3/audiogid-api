import 'package:flutter/material.dart';
import 'package:mobile_flutter/core/theme/app_theme.dart';

/// Responsive text that handles overflow gracefully
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;
  final bool softWrap;
  final String? semanticLabel;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign,
    this.softWrap = true,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? text,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        softWrap: softWrap,
      ),
    );
  }
}

/// Title text with proper overflow handling and accessibility
class TitleText extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final TextAlign? textAlign;

  const TitleText(
    this.text, {
    super.key,
    this.maxLines = 2,
    this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.titleLarge;

    return Semantics(
      header: true,
      child: Text(
        text,
        style: baseStyle?.copyWith(fontWeight: FontWeight.w600),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      ),
    );
  }
}

/// Subtitle/description text with overflow handling
class BodyText extends StatelessWidget {
  final String text;
  final int maxLines;
  final TextStyle? style;
  final TextAlign? textAlign;
  final Color? color;

  const BodyText(
    this.text, {
    super.key,
    this.maxLines = 3,
    this.style,
    this.textAlign,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;

    return Text(
      text,
      style: baseStyle?.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}

/// Label text for small annotations
class LabelText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;

  const LabelText(
    this.text, {
    super.key,
    this.style,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? Theme.of(context).textTheme.labelMedium;

    return Text(
      text,
      style: baseStyle?.copyWith(
        color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Expandable text with "Show more" functionality
class ExpandableText extends StatefulWidget {
  final String text;
  final int collapsedMaxLines;
  final TextStyle? style;
  final String expandText;
  final String collapseText;

  const ExpandableText(
    this.text, {
    super.key,
    this.collapsedMaxLines = 3,
    this.style,
    this.expandText = 'Показать больше',
    this.collapseText = 'Свернуть',
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;
  bool _hasTextOverflow = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = widget.style ?? textTheme.bodyMedium;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Check if text overflows
        final textSpan = TextSpan(text: widget.text, style: baseStyle);
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.collapsedMaxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        _hasTextOverflow = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCrossFade(
              firstChild: Text(
                widget.text,
                style: baseStyle,
                maxLines: widget.collapsedMaxLines,
                overflow: TextOverflow.ellipsis,
              ),
              secondChild: Text(
                widget.text,
                style: baseStyle,
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: AppDurations.fast,
            ),
            if (_hasTextOverflow)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Semantics(
                    button: true,
                    label:
                        _isExpanded ? widget.collapseText : widget.expandText,
                    child: Text(
                      _isExpanded ? widget.collapseText : widget.expandText,
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Text with highlighted search terms
class HighlightedText extends StatelessWidget {
  final String text;
  final String? highlight;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int maxLines;

  const HighlightedText(
    this.text, {
    super.key,
    this.highlight,
    this.style,
    this.highlightStyle,
    this.maxLines = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight == null || highlight!.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    final colorScheme = Theme.of(context).colorScheme;
    final baseStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final defaultHighlightStyle = highlightStyle ??
        baseStyle?.copyWith(
          backgroundColor: colorScheme.primaryContainer,
          fontWeight: FontWeight.w600,
        );

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight!.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerHighlight, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (index > start) {
        spans.add(
            TextSpan(text: text.substring(start, index), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + highlight!.length),
        style: defaultHighlightStyle,
      ));
      start = index + highlight!.length;
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Badge with text (for counts, status, etc.)
class TextBadge extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final IconData? icon;

  const TextBadge(
    this.text, {
    super.key,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.fontSize,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colorScheme.secondaryContainer;
    final fgColor = textColor ?? colorScheme.onSecondaryContainer;

    return Container(
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fgColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
              color: fgColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Factory for duration badges
  factory TextBadge.duration(int minutes) {
    final text =
        minutes >= 60 ? '${minutes ~/ 60}ч ${minutes % 60}мин' : '$minutes мин';
    return TextBadge(text, icon: Icons.schedule);
  }

  /// Factory for distance badges
  factory TextBadge.distance(double km) {
    final text =
        km >= 1 ? '${km.toStringAsFixed(1)} км' : '${(km * 1000).toInt()} м';
    return TextBadge(text, icon: Icons.straighten);
  }

  /// Factory for POI count badges
  factory TextBadge.poiCount(int count) {
    final word = _pluralize(count, 'место', 'места', 'мест');
    return TextBadge('$count $word', icon: Icons.place);
  }

  static String _pluralize(int n, String one, String few, String many) {
    if (n % 10 == 1 && n % 100 != 11) return one;
    if (n % 10 >= 2 && n % 10 <= 4 && (n % 100 < 10 || n % 100 >= 20))
      return few;
    return many;
  }
}

/// Price tag widget
class PriceText extends StatelessWidget {
  final int? priceRub;
  final bool isFree;
  final TextStyle? style;
  final bool showCurrency;

  const PriceText({
    super.key,
    this.priceRub,
    this.isFree = false,
    this.style,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (isFree || priceRub == null || priceRub == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Бесплатно',
          style: (style ?? textTheme.labelMedium)?.copyWith(
            color: AppColors.success,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Text(
      showCurrency ? '$priceRub ₽' : '$priceRub',
      style: (style ?? textTheme.titleMedium)?.copyWith(
        fontWeight: FontWeight.w700,
        color: colorScheme.primary,
      ),
    );
  }
}
