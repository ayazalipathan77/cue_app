import 'package:flutter/material.dart';

/// Nearby Connections service identifier — must match on both devices.
const String kServiceId = 'com.cueapp.cue';

/// App display name.
const String kAppName = 'CUE';

/// Role-select background colour.
const Color kBgColor = Color(0xFF0D0D1A);

/// Text/bg colour presets for the TEXT cue tab.
const List<Color> kTextColorPresets = [
  Colors.white,
  Color(0xFFFFE600), // yellow
  Color(0xFF00E676), // green
  Color(0xFFFF1744), // red
];

const List<Color> kBgColorPresets = [
  Colors.black,
  Color(0xFF0A1628), // dark blue
  Color(0xFF1A0A0A), // dark red
];

/// Flash colour presets.
const List<Color> kFlashColorPresets = [
  Color(0xFFFF1744), // red
  Colors.white,
  Color(0xFF2196F3), // blue
];
