import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BrutalButton extends StatefulWidget {
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  const BrutalButton({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    required this.onTap,
  });

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(_pressed ? 5 : 0, _pressed ? 5 : 0, 0),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: widget.bg,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: _pressed
              ? []
              : const [BoxShadow(color: Colors.black, offset: Offset(5, 5), blurRadius: 0)],
        ),
        child: Text(
          widget.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: widget.fg,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}