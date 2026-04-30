import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TAYYIB CARD
// ─────────────────────────────────────────────────────────────────────────────

class TayyibCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Color? color;

  const TayyibCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.boxShadow,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? TayyibColors.cardBg(context),
        borderRadius: borderRadius ?? BorderRadius.circular(14),
        boxShadow: boxShadow ?? TayyibShadow.small(),
      ),
      clipBehavior: Clip.antiAlias,
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAYYIB BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class TayyibButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final bool loading;
  final double height;

  const TayyibButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.loading = false,
    this.height = 52,
  });

  @override
  State<TayyibButton> createState() => _TayyibButtonState();
}

class _TayyibButtonState extends State<TayyibButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? TayyibColors.primary;
    final fg = widget.foregroundColor ?? Colors.white;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) {
          if (widget.onTap != null) _ctrl.forward();
        },
        onTapUp: (_) {
          _ctrl.reverse();
          if (widget.onTap != null) {
            HapticFeedback.lightImpact();
            widget.onTap!();
          }
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          width: double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.onTap == null ? bg.withOpacity(0.5) : bg,
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.onTap != null ? TayyibShadow.glow(bg) : null,
          ),
          child: Center(
            child: widget.loading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(fg),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: fg, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(widget.label, style: TayyibText.buttonLarge(color: fg)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAYYIB TEXT FIELD
// Grouped iOS-style rows with dividers
// ─────────────────────────────────────────────────────────────────────────────

class TayyibTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final bool obscure;
  final bool isFirst;
  final bool isLast;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final Widget? suffix;
  final int? maxLines;
  final int? minLines;

  const TayyibTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.isFirst = false,
    this.isLast = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final radius = BorderRadius.vertical(
      top:    isFirst ? const Radius.circular(14) : Radius.zero,
      bottom: isLast  ? const Radius.circular(14) : Radius.zero,
    );

    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      minLines: minLines,
      style: TayyibText.body(
        color: isDark ? TayyibColors.labelDark : TayyibColors.label,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TayyibText.body(color: TayyibColors.tertiaryLabel),
        prefixIcon: icon != null
            ? Icon(icon, color: TayyibColors.secondaryLabel, size: 20)
            : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: TayyibColors.cardBg(context),
        border: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius,
          borderSide: const BorderSide(
            color: TayyibColors.primary,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADER
// ─────────────────────────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String text;
  final String? trailing;

  const SectionHeader(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, right: 4),
      child: Row(
        children: [
          Text(
            text.toUpperCase(),
            style: TayyibText.sectionHeader(),
          ),
          if (trailing != null) ...[
            const Spacer(),
            Text(trailing!, style: TayyibText.caption1(color: TayyibColors.secondaryLabel)),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MADHAB PICKER
// ─────────────────────────────────────────────────────────────────────────────

class MadhabPicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final bool compact;

  const MadhabPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.compact = false,
  });

  static const _madhabs = ['hanafi', 'maliki', 'shafii', 'hanbali'];
  static const _labels  = ['Hanafi', 'Maliki', "Shafi'i", 'Hanbali'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? TayyibColors.groupedFillDark : TayyibColors.groupedFill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(_madhabs.length, (i) {
          final isSelected = _madhabs[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(_madhabs[i]);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? TayyibColors.cardDark : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected ? TayyibShadow.small() : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  _labels[i],
                  style: TayyibText.caption1(
                    color: isSelected
                        ? TayyibColors.primary
                        : TayyibColors.secondaryLabel,
                    weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}