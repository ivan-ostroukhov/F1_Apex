import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _boxName = 'f1_app_box';
  static Box? _box;
  static Map<String, dynamic>? _bundledPodiums;
  static Map<String, dynamic>? _bundledMilestones;
  static Map<String, dynamic>? _bundledSeasons;
  static Map<String, dynamic>? _bundledDriverDetails;
  static Map<String, dynamic>? _bundledConstructorDetails;

  static Future<void> init() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox(_boxName);
      await _loadBundledJson();
      await _seedInitialData();
    } catch (_) {}
  }

  static Future<void> _loadBundledJson() async {
    try {
      final jsonStr = await rootBundle.loadString('assets/data/f1_history.json');
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      _bundledPodiums = data['podiums'] as Map<String, dynamic>? ?? {};
      _bundledMilestones = data['driver_milestones'] as Map<String, dynamic>? ?? {};
      _bundledSeasons = data['driver_seasons'] as Map<String, dynamic>? ?? {};
      _bundledDriverDetails = data['driver_details'] as Map<String, dynamic>? ?? {};
      _bundledConstructorDetails = data['constructor_details'] as Map<String, dynamic>? ?? {};
    } catch (_) {}
  }

  static Future<void> _seedInitialData() async {
    if (_box == null) return;
    if (_bundledPodiums != null) {
      for (final entry in _bundledPodiums!.entries) {
        final key = 'podium_${entry.key}';
        if (!_box!.containsKey(key)) {
          await _box!.put(key, jsonEncode(entry.value));
        }
      }
    }
    if (_bundledMilestones != null) {
      for (final entry in _bundledMilestones!.entries) {
        final key = 'driver_milestones_${entry.key}';
        if (!_box!.containsKey(key)) {
          await _box!.put(key, jsonEncode(entry.value));
        }
      }
    }
    if (_bundledSeasons != null) {
      for (final entry in _bundledSeasons!.entries) {
        final key = 'driver_seasons_${entry.key}';
        if (!_box!.containsKey(key)) {
          await _box!.put(key, jsonEncode(entry.value));
        }
      }
    }
    if (_bundledDriverDetails != null) {
      for (final entry in _bundledDriverDetails!.entries) {
        final key = 'driver_detail_${entry.key}';
        if (!_box!.containsKey(key)) {
          await _box!.put(key, jsonEncode(entry.value));
        }
      }
    }
    if (_bundledConstructorDetails != null) {
      for (final entry in _bundledConstructorDetails!.entries) {
        final key = 'constructor_detail_${entry.key}';
        if (!_box!.containsKey(key)) {
          await _box!.put(key, jsonEncode(entry.value));
        }
      }
    }
  }

  static String? getString(String key) {
    final value = _box?.get(key) as String?;
    if (value != null && value.isNotEmpty) {
      return value;
    }
    if (key.startsWith('podium_') && _bundledPodiums != null) {
      final roundNum = key.replaceAll('podium_', '');
      if (_bundledPodiums!.containsKey(roundNum)) {
        final encoded = jsonEncode(_bundledPodiums![roundNum]);
        _box?.put(key, encoded);
        return encoded;
      }
    }
    if (key.startsWith('driver_milestones_') && _bundledMilestones != null) {
      final driverId = key.replaceAll('driver_milestones_', '');
      final normalizedId = driverId == 'verstappen' ? 'max_verstappen' : driverId;
      if (_bundledMilestones!.containsKey(driverId)) {
        final encoded = jsonEncode(_bundledMilestones![driverId]);
        _box?.put(key, encoded);
        return encoded;
      } else if (_bundledMilestones!.containsKey(normalizedId)) {
        final encoded = jsonEncode(_bundledMilestones![normalizedId]);
        _box?.put(key, encoded);
        return encoded;
      }
    }
    if (key.startsWith('driver_seasons_') && _bundledSeasons != null) {
      final driverId = key.replaceAll('driver_seasons_', '');
      final normalizedId = driverId == 'verstappen' ? 'max_verstappen' : driverId;
      if (_bundledSeasons!.containsKey(driverId)) {
        final encoded = jsonEncode(_bundledSeasons![driverId]);
        _box?.put(key, encoded);
        return encoded;
      } else if (_bundledSeasons!.containsKey(normalizedId)) {
        final encoded = jsonEncode(_bundledSeasons![normalizedId]);
        _box?.put(key, encoded);
        return encoded;
      }
    }
    if (key.startsWith('driver_detail_') && _bundledDriverDetails != null) {
      final detailKey = key.replaceAll('driver_detail_', '');
      if (_bundledDriverDetails!.containsKey(detailKey)) {
        final encoded = jsonEncode(_bundledDriverDetails![detailKey]);
        _box?.put(key, encoded);
        return encoded;
      }
      final normalizedKey = detailKey.replaceAll('verstappen', 'max_verstappen');
      if (_bundledDriverDetails!.containsKey(normalizedKey)) {
        final encoded = jsonEncode(_bundledDriverDetails![normalizedKey]);
        _box?.put(key, encoded);
        return encoded;
      }
    }
    if (key.startsWith('constructor_detail_') && _bundledConstructorDetails != null) {
      final detailKey = key.replaceAll('constructor_detail_', '');
      if (_bundledConstructorDetails!.containsKey(detailKey)) {
        final encoded = jsonEncode(_bundledConstructorDetails![detailKey]);
        _box?.put(key, encoded);
        return encoded;
      }
    }
    return null;
  }

  static Future<void> setString(String key, String value) async {
    await _box?.put(key, value);
  }

  static Future<void> clearKey(String key) async {
    await _box?.delete(key);
  }
}
