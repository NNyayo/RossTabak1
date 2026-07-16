import 'package:flutter/material.dart';

class AnimatedSlideItem extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedSlideItem({super.key, required this.child, this.index = 0});

  @override
  State<AnimatedSlideItem> createState() => _AnimatedSlideItemState();
}

class _AnimatedSlideItemState extends State<AnimatedSlideItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _isVisible = true);
        Future.delayed(Duration(milliseconds: widget.index * 80), () {
          if (mounted) _controller.forward();
        });
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
    if (!_isVisible) return const SizedBox.shrink();
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(opacity: _fadeAnimation, child: widget.child),
    );
  }
}

class AnimatedExpandableCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final VoidCallback? onExpand;

  const AnimatedExpandableCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.onExpand,
  });

  @override
  State<AnimatedExpandableCard> createState() => _AnimatedExpandableCardState();
}

class _AnimatedExpandableCardState extends State<AnimatedExpandableCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    if (_isExpanded) {
      _controller.forward();
      widget.onExpand?.call();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: widget.iconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ClipRect(
          child: SizeTransition(
            sizeFactor: _heightAnimation,
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(left: 44, right: 16, bottom: 16),
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }
}
