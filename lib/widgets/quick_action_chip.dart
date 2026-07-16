import 'package:flutter/material.dart';

class QuickActionChip extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<QuickActionChip> createState() => _QuickActionChipState();
}

class _QuickActionChipState extends State<QuickActionChip>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.color.withValues(alpha: _isPressed ? 0.6 : 0.3),
                width: _isPressed ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: widget.color, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
