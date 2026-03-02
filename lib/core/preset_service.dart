import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists up to 20 saved text cue presets, most-recent first.
class PresetService {
  static const _key = 'text_cue_presets';
  static const _maxPresets = 20;

  static Future<List<String>> load() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_key);
    if (raw == null) return [];
    try {
      return List<String>.from(jsonDecode(raw) as List);
    } catch (_) {
      return [];
    }
  }

  /// Saves [text] as a preset (deduped, most-recent at index 0).
  static Future<void> save(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    final list = await load();
    list.remove(t);
    list.insert(0, t);
    if (list.length > _maxPresets) list.removeLast();
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(list));
  }

  static Future<void> delete(String text) async {
    final list = await load();
    list.remove(text);
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(list));
  }
}
