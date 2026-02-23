import 'package:flutter/material.dart';

/// Full-screen flash effect using AnimationController at the specified Hz.
class FlashDisplay extends StatefulWidget {
  final Color flashColor;
  final double hz;

  const FlashDisplay({
    super.key,
    required this.flashColor,
    required this.hz,
  });

  @override
  State<FlashDisplay> createState() => _FlashDisplayState();
}

class _FlashDisplayState extends State<FlashDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (1000 / widget.hz).round()),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(FlashDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hz != widget.hz) {
      _controller.duration = Duration(milliseconds: (1000 / widget.hz).round());
      _controller.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final isOn = _controller.value > 0.5;
        return Container(
          color: isOn ? widget.flashColor : Colors.black,
          width: double.infinity,
          height: double.infinity,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
