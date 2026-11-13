import 'dart:convert';
import 'dart:io';
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
    } catch (_) {}

    try {
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box(_boxName);
      } else {
        _box = await Hive.openBox(_boxName);
      }
    } catch (_) {}

    try {
      await _loadBundledJson();
      await _seedInitialData();
    } catch (_) {}
  }

  static Future<void> _loadBundledJson() async {
    String? jsonStr;
    try {
      jsonStr = await rootBundle.loadString('assets/data/f1_history.json');
    } catch (_) {
      try {
        final file = File('assets/data/f1_history.json');
        if (file.existsSync()) {
          jsonStr = await file.readAsString();
        }
      } catch (_) {}
    }

    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        _bundledPodiums = data['podiums'] as Map<String, dynamic>? ?? {};
        _bundledMilestones = data['driver_milestones'] as Map<String, dynamic>? ?? {};
        _bundledSeasons = data['driver_seasons'] as Map<String, dynamic>? ?? {};
        _bundledDriverDetails = data['driver_details'] as Map<String, dynamic>? ?? {};
        _bundledConstructorDetails = data['constructor_details'] as Map<String, dynamic>? ?? {};
      } catch (_) {}
    }
  }

  static bool _isCorrupt(String key, String value) {
    if (key.startsWith('driver_detail_')) {
      try {
        final map = jsonDecode(value) as Map<String, dynamic>;
        final pts = map['points'] as String? ?? '0';
        final pos = map['position'] as String? ?? '0';
        final rounds = map['roundPoints'] as List<dynamic>? ?? [];
        if ((pts == '0' || pts.isEmpty) && (pos == '0' || pos == '—') && rounds.isEmpty) {
          return true;
        }
        final seasonMatch = RegExp(r'_(\d{4}|career)$').firstMatch(key);
        if (seasonMatch != null) {
          final expectedSeason = seasonMatch.group(1);
          final actualSeason = map['season'] as String?;
          if (actualSeason != null && actualSeason.isNotEmpty && actualSeason != expectedSeason) {
            return true;
          }
        }
      } catch (_) {
        return true;
      }
    } else if (key.startsWith('constructor_detail_')) {
      try {
        final map = jsonDecode(value) as Map<String, dynamic>;
        final pts = map['points'] as String? ?? '0';
        final pos = map['position'] as String? ?? '0';
        final wins = (map['wins'] as num?)?.toInt() ?? 0;
        if ((pts == '0' || pts.isEmpty) && (pos == '0' || pos == '—') && wins == 0) {
          return true;
        }
        final seasonMatch = RegExp(r'_(\d{4}|career)$').firstMatch(key);
        if (seasonMatch != null) {
          final expectedSeason = seasonMatch.group(1);
          final actualSeason = map['season'] as String?;
          if (actualSeason != null && actualSeason.isNotEmpty && actualSeason != expectedSeason) {
            return true;
          }
        }
      } catch (_) {
        return true;
      }
    }
    return false;
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
        final existing = _box!.get(key) as String?;
        if (existing == null || existing.isEmpty || _isCorrupt(key, existing)) {
          await _box!.put(key, jsonEncode(entry.value));
        }
      }
    }
    if (_bundledConstructorDetails != null) {
      for (final entry in _bundledConstructorDetails!.entries) {
        final key = 'constructor_detail_${entry.key}';
        final existing = _box!.get(key) as String?;
        if (existing == null || existing.isEmpty || _isCorrupt(key, existing)) {
          await _box!.put(key, jsonEncode(entry.value));
        }
      }
    }
  }

  static String? getString(String key) {
    final value = _box?.get(key) as String?;
    if (value != null && value.isNotEmpty) {
      if (!_isCorrupt(key, value)) {
        return value;
      }
      _box?.delete(key);
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
      final isOtherSeason = RegExp(r'_(?!2026)\d{4}$|_career$').hasMatch(detailKey);
      if (!isOtherSeason) {
        final with2026 = detailKey.endsWith('_2026') ? detailKey : '${detailKey}_2026';
        if (_bundledDriverDetails!.containsKey(detailKey)) {
          final encoded = jsonEncode(_bundledDriverDetails![detailKey]);
          _box?.put(key, encoded);
          return encoded;
        }
        if (_bundledDriverDetails!.containsKey(with2026)) {
          final encoded = jsonEncode(_bundledDriverDetails![with2026]);
          _box?.put(key, encoded);
          return encoded;
        }
        final normalizedKey = detailKey.contains('max_verstappen')
            ? detailKey.replaceAll('max_verstappen', 'verstappen')
            : detailKey.replaceAll('verstappen', 'max_verstappen');
        if (_bundledDriverDetails!.containsKey(normalizedKey)) {
          final encoded = jsonEncode(_bundledDriverDetails![normalizedKey]);
          _box?.put(key, encoded);
          return encoded;
        }
        final normalizedWith2026 = normalizedKey.endsWith('_2026') ? normalizedKey : '${normalizedKey}_2026';
        if (_bundledDriverDetails!.containsKey(normalizedWith2026)) {
          final encoded = jsonEncode(_bundledDriverDetails![normalizedWith2026]);
          _box?.put(key, encoded);
          return encoded;
        }
      }
    }
    if (key.startsWith('constructor_detail_') && _bundledConstructorDetails != null) {
      final detailKey = key.replaceAll('constructor_detail_', '');
      final isOtherSeason = RegExp(r'_(?!2026)\d{4}$|_career$').hasMatch(detailKey);
      if (!isOtherSeason) {
        final with2026 = detailKey.endsWith('_2026') ? detailKey : '${detailKey}_2026';
        if (_bundledConstructorDetails!.containsKey(detailKey)) {
          final encoded = jsonEncode(_bundledConstructorDetails![detailKey]);
          _box?.put(key, encoded);
          return encoded;
        }
        if (_bundledConstructorDetails!.containsKey(with2026)) {
          final encoded = jsonEncode(_bundledConstructorDetails![with2026]);
          _box?.put(key, encoded);
          return encoded;
        }
      }
    }
    return null;
  }

  static Future<void> setString(String key, String value) async {
    if (_isCorrupt(key, value)) return;
    await _box?.put(key, value);
  }

  static Future<void> clearKey(String key) async {
    await _box?.delete(key);
  }
}
