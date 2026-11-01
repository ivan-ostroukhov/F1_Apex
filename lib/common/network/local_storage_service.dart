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
  }

  static String? getString(String key) {
    final value = _box?.get(key) as String?;
    if (value != null && value.isNotEmpty) {
      return value;
    }
    if (key.startsWith('podium_') && _bundledPodiums != null) {
      final roundNum = key.replaceAll('podium_', '');
      if (_bundledPodiums!.containsKey(roundNum)) {
        final podiumList = _bundledPodiums![roundNum];
        final encoded = jsonEncode(podiumList);
        _box?.put(key, encoded);
        return encoded;
      }
    }
    if (key.startsWith('driver_milestones_') && _bundledMilestones != null) {
      final driverId = key.replaceAll('driver_milestones_', '');
      if (_bundledMilestones!.containsKey(driverId)) {
        final data = _bundledMilestones![driverId];
        final encoded = jsonEncode(data);
        _box?.put(key, encoded);
        return encoded;
      }
    }
    if (key.startsWith('driver_seasons_') && _bundledSeasons != null) {
      final driverId = key.replaceAll('driver_seasons_', '');
      if (_bundledSeasons!.containsKey(driverId)) {
        final data = _bundledSeasons![driverId];
        final encoded = jsonEncode(data);
        _box?.put(key, encoded);
        return encoded;
      }
    }
    if (key.startsWith('driver_detail_') && _bundledDriverDetails != null) {
      final detailKey = key.replaceAll('driver_detail_', '');
      if (_bundledDriverDetails!.containsKey(detailKey)) {
        final data = _bundledDriverDetails![detailKey];
        final encoded = jsonEncode(data);
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
