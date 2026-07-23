import 'package:flutter/material.dart';

/// Virtualized list for better performance with large datasets
/// Only renders items visible in the viewport
class VirtualizedList extends StatefulWidget {
  final List items;
  final Widget Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
  final double itemHeight;
  final double? maxHeight;
  final EdgeInsetsGeometry? padding;

  const VirtualizedList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.emptyBuilder,
    required this.itemHeight,
    this.maxHeight,
    this.padding,
  });

  @override
  State<VirtualizedList> createState() => _VirtualizedListState();
}

class _VirtualizedListState extends State<VirtualizedList> {
  final ScrollController _scrollController = ScrollController();
  int _visibleStart = 0;
  int _visibleEnd = 0;
  final double _buffer = 5; // Extra items to render above/below viewport

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _updateVisibleRange();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    _updateVisibleRange();
  }

  void _updateVisibleRange() {
    if (!mounted) return;

    final viewportHeight = _scrollController.position.viewportDimension;
    final offset = _scrollController.offset;

    final start = ((offset / widget.itemHeight).floor() - _buffer.toInt())
        .clamp(0, widget.items.length - 1);
    final end =
        ((offset + viewportHeight) / widget.itemHeight).ceil() +
        _buffer.toInt();
    final clampedEnd = end.clamp(0, widget.items.length - 1);

    if (start != _visibleStart || clampedEnd != _visibleEnd) {
      setState(() {
        _visibleStart = start;
        _visibleEnd = clampedEnd;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyBuilder?.call(context) ??
          const Center(child: Text('Нет данных'));
    }

    final visibleItems = <Widget>[];

    // Spacer above
    if (_visibleStart > 0) {
      visibleItems.add(SizedBox(height: _visibleStart * widget.itemHeight));
    }

    // Visible items
    for (
      int i = _visibleStart;
      i <= _visibleEnd && i < widget.items.length;
      i++
    ) {
      visibleItems.add(
        SizedBox(
          height: widget.itemHeight,
          child: widget.itemBuilder(context, i),
        ),
      );
    }

    return Container(
      constraints: widget.maxHeight != null
          ? BoxConstraints(maxHeight: widget.maxHeight!)
          : null,
      padding: widget.padding,
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: visibleItems,
      ),
    );
  }
}
