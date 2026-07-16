import 'package:flutter/material.dart';

class AnimatedStatCard extends StatefulWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String? subtitle;

  const AnimatedStatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
    this.subtitle,
  });

  @override
  State<AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedScale(
          scale: _isHovering ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.color.withValues(
                  alpha: _isHovering ? 0.5 : 0.2,
                ),
                width: _isHovering ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(
                    alpha: _isHovering ? 0.2 : 0.1,
                  ),
                  blurRadius: _isHovering ? 16 : 8,
                  offset: Offset(0, _isHovering ? 4 : 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(widget.icon, color: widget.color, size: 28),
                    ),
                    if (widget.onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: widget.color.withValues(alpha: 0.5),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.count.toString(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: widget.color,
                  ),
                ),
                if (widget.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
