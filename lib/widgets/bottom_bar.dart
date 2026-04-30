import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TAYYIB BOTTOM BAR
// Liquid spring animation · icon fill transitions · haptic feedback
// ─────────────────────────────────────────────────────────────────────────────

class TayyibTabItem {
  final IconData icon;
  final IconData iconFilled;
  final String label;
  const TayyibTabItem({
    required this.icon,
    required this.iconFilled,
    required this.label,
  });
}

class TayyibBottomBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<TayyibTabItem> items;

  const TayyibBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<TayyibBottomBar> createState() => _TayyibBottomBarState();
}

class _TayyibBottomBarState extends State<TayyibBottomBar>
    with SingleTickerProviderStateMixin {
  // The "spring" curve — slight overshoot, feels liquid
  static const _springCurve = Cubic(0.34, 1.56, 0.64, 1.0);
  static const _duration     = Duration(milliseconds: 380);
  static const _barHeight    = 60.0;
  static const _pillV        = 6.0; // vertical pill padding
  static const _pillH        = 6.0; // horizontal pill padding per side

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgColor  = TayyibColors.cardBg(context);
    final tabCount = widget.items.length;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: TayyibShadow.bottomBar(context),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barHeight,
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final totalW   = constraints.maxWidth;
              final tabW     = totalW / tabCount;
              final pillW    = tabW - (_pillH * 2);
              final pillLeft = (widget.currentIndex * tabW) + _pillH;

              return Stack(
                children: [
                  // ── Sliding pill background ───────────────────────────────
                  AnimatedPositioned(
                    left: pillLeft,
                    top: _pillV,
                    duration: _duration,
                    curve: _springCurve,
                    child: Container(
                      width: pillW,
                      height: _barHeight - (_pillV * 2),
                      decoration: BoxDecoration(
                        color: TayyibColors.primary.withOpacity(
                          isDark ? 0.18 : 0.10,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // ── Tab items ─────────────────────────────────────────────
                  Row(
                    children: List.generate(tabCount, (i) {
                      return _TabButton(
                        item: widget.items[i],
                        selected: widget.currentIndex == i,
                        width: tabW,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          widget.onTap(i);
                        },
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual tab button with animated icon + label
// ─────────────────────────────────────────────────────────────────────────────

class _TabButton extends StatefulWidget {
  final TayyibTabItem item;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  const _TabButton({
    required this.item,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.86).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _ctrl.forward();
  void _onTapUp(TapUpDetails _) {
    _ctrl.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? TayyibColors.primary
        : TayyibColors.secondaryLabel;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.width,
        height: 60,
        child: ScaleTransition(
          scale: _scale,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Animated icon ─────────────────────────────────────────────
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => ScaleTransition(
                  scale: Tween<double>(begin: 0.70, end: 1.0).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOutBack),
                  ),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: Icon(
                  widget.selected ? widget.item.iconFilled : widget.item.icon,
                  key: ValueKey(widget.selected),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 3),

              // ── Label ─────────────────────────────────────────────────────
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TayyibText.caption1(color: color).copyWith(
                  fontWeight: widget.selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
                child: Text(widget.item.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}