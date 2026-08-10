import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors the localStorage helpers (`getLocalData` / `setLocalData`)
/// from `src/data.ts`, backed by `shared_preferences` on-device.
class StorageService {
  static final StorageService instance = StorageService._();

  StorageService._();

  /// Synchronously cached preferences handle (loaded at app startup).
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences? get _p => _prefs;

  String getString(String key, String defaultValue) {
    if (_p == null) return defaultValue;
    final stored = _p!.getString(key);
    if (stored == null) {
      _p!.setString(key, defaultValue);
      return defaultValue;
    }
    return stored;
  }

  bool getBool(String key, bool defaultValue) {
    if (_p == null) return defaultValue;
    final stored = _p!.getBool(key);
    if (stored == null) {
      _p!.setBool(key, defaultValue);
      return defaultValue;
    }
    return stored;
  }

  /// Stores an object list as a JSON string (mirrors `JSON.stringify`).
  void setList(String key, List<Map<String, dynamic>> data) {
    if (_p == null) return;
    _p!.setString(key, jsonEncode(data));
  }

  List<Map<String, dynamic>> getList(
      String key, List<Map<String, dynamic>> defaultValue) {
    if (_p == null) return defaultValue;
    final stored = _p!.getString(key);
    if (stored == null) {
      _p!.setString(key, jsonEncode(defaultValue));
      return defaultValue;
    }
    try {
      final decoded = jsonDecode(stored) as List;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (_) {
      return defaultValue;
    }
  }

  void setStringValue(String key, String value) {
    if (_p == null) return;
    _p!.setString(key, value);
  }

  void setBoolValue(String key, bool value) {
    if (_p == null) return;
    _p!.setBool(key, value);
  }

  Future<void> clearAll() async {
    await _p?.clear();
  }
}
