import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../tokens/colors.dart';
import '../../tokens/radius.dart';
import '../../tokens/spacing.dart';
import '../../tokens/motion.dart';

/// Small pill-shaped button for tags and filters
class PillButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSelected;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? selectedBackgroundColor;

  const PillButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isSelected = false,
    this.icon,
    this.backgroundColor,
    this.selectedBackgroundColor,
  });

  @override
  State<PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<PillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: AppCurves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSelected
        ? (widget.selectedBackgroundColor ?? AppColors.accentPrimary)
        : (widget.backgroundColor ?? AppColors.bgSecondary);

    final textColor = widget.isSelected
        ? Colors.white
        : AppColors.textPrimary;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: widget.onPressed != null ? _handleTapDown : null,
            onTapUp: widget.onPressed != null ? _handleTapUp : null,
            onTapCancel: widget.onPressed != null ? _handleTapCancel : null,
            onTap: widget.onPressed != null
                ? () {
                    widget.onPressed?.call();
                    HapticFeedback.selectionClick();
                  }
                : null,
            child: AnimatedContainer(
              duration: AppDurations.standard,
              curve: AppCurves.easeOut,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: widget.isSelected
                      ? AppColors.accentPrimary
                      : AppColors.glassBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: 16,
                      color: textColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

