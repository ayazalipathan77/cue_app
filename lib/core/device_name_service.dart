import 'package:shared_preferences/shared_preferences.dart';

/// Persists custom device names across app launches.
class DeviceNameService {
  static const _senderKey = 'sender_device_name';
  static const _receiverKey = 'receiver_device_name';

  static Future<String> senderName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_senderKey) ?? 'CUE-Sender';
  }

  static Future<String> receiverName() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_receiverKey) ?? 'CUE-Receiver';
  }

  static Future<void> saveSenderName(String name) async {
    final p = await SharedPreferences.getInstance();
    final v = name.trim();
    await p.setString(_senderKey, v.isEmpty ? 'CUE-Sender' : v);
  }

  static Future<void> saveReceiverName(String name) async {
    final p = await SharedPreferences.getInstance();
    final v = name.trim();
    await p.setString(_receiverKey, v.isEmpty ? 'CUE-Receiver' : v);
  }
}
