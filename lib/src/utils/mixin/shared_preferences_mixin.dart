import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ugz_app/src/constants/db_keys.dart';

mixin SharedPreferenceMixin<T extends Object> {
  late final String _key;
  late final SharedPreferences _client;
  late final T? _initial;
  set state(T? newState);
  T? get state;
  late final dynamic Function(T)? _toJson;
  late final T? Function(dynamic)? _fromJson;

  T? initialize(
    SharedPreferences prefs,
    DBKeys key, {
    T? initial,
    dynamic Function(T)? toJson,
    T? Function(dynamic)? fromJson,
  }) {
    _client = prefs;
    _key = key.name;
    _initial = initial ?? key.initial;
    _toJson = toJson;
    _fromJson = fromJson;
    return _get ?? _initial;
  }

  void update(T? value) => state = value;

  T? get _get {
    final value = _client.get(_key);
    if (_fromJson != null && value is String) {
      return _fromJson(jsonDecode(value));
    }
    if (value != null && value is List) {
      return value.map((e) => e.toString()).toList() as T?;
    }
    return value is T ? value : _initial;
  }

  Future<bool> persist(T? value) async {
    if (value == null) return _client.remove(_key);
    if (_toJson != null) {
      return _client.setString(_key, jsonEncode(_toJson(value)));
    }
    if (value is bool) return _client.setBool(_key, value);
    if (value is double) return _client.setDouble(_key, value);
    if (value is int) return _client.setInt(_key, value);
    if (value is String) return _client.setString(_key, value);
    if (value is List<String>) return _client.setStringList(_key, value);
    return false;
  }
}
