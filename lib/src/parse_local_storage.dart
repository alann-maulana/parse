import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ParseLocalStorage parseLocalStorage = ParseLocalStorage._internal();

class ParseLocalStorage {
  final Map<String, LocalStorage> _cache;

  ParseLocalStorage._internal() : _cache = {};

  Future<LocalStorage?> get(String key) async {
    if (!_cache.containsKey(key)) {
      final instance = LocalStorage._internal(key);
      await instance._init();
      _cache[key] = instance;
    }

    return _cache[key];
  }

  @visibleForTesting
  Future<void> clear() async {
    _cache.forEach((key, cache) async {
      await cache.delete();
    });
    _cache.clear();
  }
}

class LocalStorage {
  final String _keyName;
  final Map<String, dynamic> _data = {};

  LocalStorage._internal(this._keyName);

  _init() async {
    final _db = await SharedPreferences.getInstance();
    final source = _db.getString(_keyName);
    try {
      final map = json.decode(source!);
      if (map is Map<String, dynamic>) {
        _data.addAll(map);
      }
    } catch (_) {}
    await _db.setString(_keyName, json.encode(_data));
  }

  Future<bool> setData(Map<String, dynamic> values) async {
    _data
      ..clear()
      ..addAll(values);

    return _flush();
  }

  Future<bool> setItem(String key, value) async {
    _data[key] = value;

    return _flush();
  }

  Future<bool> delete() async {
    _data.clear();

    return _flush();
  }

  Future<bool> deleteItem(String key) async {
    _data.remove(key);

    return _flush();
  }

  Map<String, dynamic> getData() {
    return _data;
  }

  getItem(String key) {
    return _data[key];
  }

  bool get isEmpty => _data.isEmpty;

  Future<bool> _flush() async {
    final _db = await SharedPreferences.getInstance();
    return await _db.setString(_keyName, json.encode(_data));
  }
}
