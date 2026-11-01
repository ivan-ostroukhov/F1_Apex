import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:f1_app/common/network/local_storage_service.dart';
import 'package:f1_app/features/driver/domain/driver_detail_model.dart';
import 'package:f1_app/features/constructor/domain/constructor_detail_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox('f1_app_box');
    await LocalStorageService.init();
  });

  test('LocalStorageService loads Verstappen 2026 correctly', () {
    final str = LocalStorageService.getString('driver_detail_verstappen_2026');
    expect(str, isNotNull);
    final model = DriverDetailModel.fromJson(jsonDecode(str!) as Map<String, dynamic>);
    expect(model.points, '236');
    expect(model.position, '4');
    expect(model.wins, 2);
    expect(model.roundPoints.length, 18);
  });

  test('LocalStorageService loads Piastri 2026 correctly', () {
    final str = LocalStorageService.getString('driver_detail_piastri_2026');
    expect(str, isNotNull);
    final model = DriverDetailModel.fromJson(jsonDecode(str!) as Map<String, dynamic>);
    expect(model.points, '144');
    expect(model.position, '7');
    expect(model.wins, 0);
    expect(model.roundPoints.length, 18);
  });

  test('LocalStorageService loads Red Bull 2026 correctly', () {
    final str = LocalStorageService.getString('constructor_detail_red_bull_2026');
    expect(str, isNotNull);
    final model = ConstructorDetailModel.fromJson(jsonDecode(str!) as Map<String, dynamic>);
    expect(model.points, '355');
    expect(model.position, '3');
    expect(model.wins, 2);
  });

  test('Corrupt zero-point data is rejected and falls back to bundled data', () async {
    final corruptDriver = jsonEncode({
      'id': 'max_verstappen',
      'points': '0',
      'position': '0',
      'wins': 0,
      'roundPoints': [],
    });

    await LocalStorageService.setString('driver_detail_max_verstappen_2026', corruptDriver);

    final str = LocalStorageService.getString('driver_detail_max_verstappen_2026');
    expect(str, isNotNull);
    final model = DriverDetailModel.fromJson(jsonDecode(str!) as Map<String, dynamic>);
    expect(model.points, '236');
    expect(model.position, '4');
  });
}
