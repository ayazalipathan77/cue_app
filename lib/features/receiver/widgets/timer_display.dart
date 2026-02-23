import 'package:flutter/material.dart';

/// Displays a countdown/count-up timer with FittedBox auto-scaling.
/// Text turns red when < 10 seconds remain (countdown only).
class TimerDisplay extends StatelessWidget {
  final int seconds;
  final bool countingDown;

  const TimerDisplay({
    super.key,
    required this.seconds,
    required this.countingDown,
  });

  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final isLow = countingDown && seconds < 10;
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(12),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: Text(
          _format(seconds),
          style: TextStyle(
            color: isLow ? const Color(0xFFFF1744) : Colors.white,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
