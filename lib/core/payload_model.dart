import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart' show Color;

/// All payload types exchanged between Sender and Receiver.
enum PayloadType { text, timer, counter, flash, hello, clear }

/// Serialisable cue payload sent as UTF-8 JSON bytes over Nearby Connections.
class CuePayload {
  final PayloadType type;
  final Map<String, dynamic> _data;

  const CuePayload._(this.type, this._data);

  // ── Named constructors ────────────────────────────────────────────────────

  /// Send a text cue with optional colour overrides (hex strings, e.g. "#FFFFFF").
  factory CuePayload.text(String value, {String color = '#FFFFFF', String bg = '#000000'}) =>
      CuePayload._(PayloadType.text, {'value': value, 'color': color, 'bg': bg});

  /// Timer commands: action = 'start' | 'pause' | 'resume' | 'reset'
  factory CuePayload.timer(String action, {String direction = 'down', int seconds = 0}) =>
      CuePayload._(PayloadType.timer, {
        'action': action,
        if (action == 'start') 'direction': direction,
        if (action == 'start') 'seconds': seconds,
      });

  /// Counter commands: action = 'set' | 'increment' | 'decrement' | 'reset'
  factory CuePayload.counter(String action, {int value = 0, int step = 1}) =>
      CuePayload._(PayloadType.counter, {
        'action': action,
        if (action == 'set') 'value': value,
        if (action == 'increment' || action == 'decrement') 'step': step,
      });

  /// Flash commands: action = 'start' | 'stop'
  factory CuePayload.flash(String action, {double hz = 2.0, String color = '#FF0000'}) =>
      CuePayload._(PayloadType.flash, {
        'action': action,
        if (action == 'start') 'hz': hz,
        if (action == 'start') 'color': color,
      });

  /// Handshake — sent by Sender after connection established.
  factory CuePayload.hello(String deviceName) =>
      CuePayload._(PayloadType.hello, {'role': 'sender', 'name': deviceName});

  /// Clear the receiver display.
  factory CuePayload.clear() => CuePayload._(PayloadType.clear, {});

  // ── Serialisation ─────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {'type': type.name, ..._data};

  Uint8List toBytes() => Uint8List.fromList(utf8.encode(jsonEncode(toJson())));

  factory CuePayload.fromJson(Map<String, dynamic> json) {
    final type = PayloadType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => PayloadType.clear,
    );
    final data = Map<String, dynamic>.from(json)..remove('type');
    return CuePayload._(type, data);
  }

  factory CuePayload.fromBytes(Uint8List bytes) {
    final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    return CuePayload.fromJson(json);
  }

  // ── Convenience accessors ─────────────────────────────────────────────────

  String get action => (_data['action'] as String?) ?? '';
  String get value => (_data['value'] as String?) ?? '';
  String get textColor => (_data['color'] as String?) ?? '#FFFFFF';
  String get bgColor => (_data['bg'] as String?) ?? '#000000';
  String get direction => (_data['direction'] as String?) ?? 'down';
  int get seconds => (_data['seconds'] as int?) ?? 0;
  int get counterValue => (_data['value'] as int?) ?? 0;
  int get step => (_data['step'] as int?) ?? 1;
  double get hz => ((_data['hz'] as num?) ?? 2.0).toDouble();
  String get flashColor => (_data['color'] as String?) ?? '#FF0000';
  String get senderName => (_data['name'] as String?) ?? 'Sender';

  @override
  String toString() => 'CuePayload(${type.name}, $_data)';
}

/// Converts a hex colour string like "#FFFFFF" to a Flutter Color.
Color hexToColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}
