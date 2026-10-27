import 'package:flutter/material.dart';

/// Smooth pulsing/blinking cursor displayed during live AI token streaming.
class AiStreamingCursor extends StatefulWidget {
  const AiStreamingCursor({
    super.key,
    this.color = const Color(0xFF10A37F),
    this.width = 7.0,
    this.height = 16.0,
    this.borderRadius = 2.0,
  });

  final Color color;
  final double width;
  final double height;
  final double borderRadius;

  @override
  State<AiStreamingCursor> createState() => _AiStreamingCursorState();
}

class _AiStreamingCursorState extends State<AiStreamingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        margin: const EdgeInsets.only(left: 3.0),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
