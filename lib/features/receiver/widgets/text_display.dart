import 'package:flutter/material.dart';

/// Renders text cue edge-to-edge using FittedBox auto-scaling.
class TextDisplay extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color bgColor;

  const TextDisplay({
    super.key,
    required this.text,
    required this.textColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgColor,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      child: FittedBox(
        fit: BoxFit.contain,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w900,
            height: 1.0,
            letterSpacing: -2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
