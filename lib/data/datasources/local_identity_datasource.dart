import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalIdentityDataSource {
  Future<Map<String, dynamic>?> loadIdentityJson(String roomCode);

  Future<void> saveIdentityJson(String roomCode, Map<String, dynamic> json);
}

class LocalIdentityDataSourceImpl implements LocalIdentityDataSource {
  LocalIdentityDataSourceImpl(this._prefs);

  static const _key = 'rumour_room_identities_v1';
  final SharedPreferences _prefs;

  Map<String, dynamic> _all() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) return Map<String, dynamic>.from(decoded);
    return {};
  }

  Future<void> _writeAll(Map<String, dynamic> all) async {
    await _prefs.setString(_key, jsonEncode(all));
  }

  @override
  Future<Map<String, dynamic>?> loadIdentityJson(String roomCode) async {
    final all = _all();
    final entry = all[roomCode];
    if (entry is Map<String, dynamic>) return Map<String, dynamic>.from(entry);
    return null;
  }

  @override
  Future<void> saveIdentityJson(String roomCode, Map<String, dynamic> json) async {
    final all = _all();
    all[roomCode] = json;
    await _writeAll(all);
  }
}
