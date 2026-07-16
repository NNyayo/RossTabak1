import 'package:flutter/material.dart';

class CompletionRateCard extends StatefulWidget {
  final int percentage;

  const CompletionRateCard({super.key, required this.percentage});

  @override
  State<CompletionRateCard> createState() => _CompletionRateCardState();
}

class _CompletionRateCardState extends State<CompletionRateCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  late Animation<double> _scaleAnimation;
  int _currentPercentage = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0,
      end: widget.percentage / 100,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _animateCounter();
    });
  }

  Future<void> _animateCounter() async {
    for (int i = 0; i <= widget.percentage; i++) {
      await Future.delayed(const Duration(milliseconds: 15));
      if (mounted) setState(() => _currentPercentage = i);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRateColor() {
    if (widget.percentage >= 80) return Colors.green;
    if (widget.percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getRateLabel() {
    if (widget.percentage >= 80) return 'Отлично!';
    if (widget.percentage >= 50) return 'Хорошо';
    return 'Нужно работать';
  }

  @override
  Widget build(BuildContext context) {
    final rateColor = _getRateColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.speed, color: rateColor, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Выполнение задач',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: _progressAnimation.value,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation(rateColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_currentPercentage%',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: rateColor,
                            ),
                          ),
                          Text(
                            _getRateLabel(),
                            style: TextStyle(
                              fontSize: 12,
                              color: rateColor.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _progressAnimation.value,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(rateColor),
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
