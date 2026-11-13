import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:f1_app/common/network/local_storage_service.dart';
import 'package:f1_app/common/utils/f1_colors.dart';
import 'package:f1_app/features/driver/data/api/driver_api.dart';
import 'package:f1_app/features/driver/data/data_sources/network_driver_data_source.dart';
import 'package:f1_app/features/driver/data/driver_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = null;

  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync('hive_season_test');
    Hive.init(tempDir.path);
    await Hive.openBox('f1_app_box');
    await LocalStorageService.init();
  });

  test('LocalStorageService does not return 2026 data for 2024 keys', () {
    final lawson2024 = LocalStorageService.getString('driver_detail_lawson_2024');
    expect(lawson2024, isNull);

    final ham2024 = LocalStorageService.getString('driver_detail_hamilton_2024');
    expect(ham2024, isNull);

    final constr2024 = LocalStorageService.getString('constructor_detail_ferrari_2024');
    expect(constr2024, isNull);
  });

  test('DriverRepository fetches accurate 2024 stats for Lawson', () async {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.jolpi.ca/ergast/f1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    final api = DriverApi(dio);
    final dataSource = NetworkDriverDataSource(api);
    final repository = DriverRepository(dataSource);

    final detail = await repository.getDriverDetails('lawson', season: '2024');

    expect(detail.id, equals('lawson'));
    expect(detail.season, equals('2024'));
    expect(detail.points, equals('4'));
    expect(detail.position, equals('21'));
    expect(detail.roundPoints.length, equals(24));
    // Lawson did not race rounds 1-18 in 2024
    for (int i = 0; i < 18; i++) {
      expect(detail.roundPoints[i], isNull, reason: 'Round ${i + 1} should be null');
    }
    // Round 19 was US GP (pos 9, 2 pts)
    expect(detail.roundPoints[18], equals(2));
    // Round 21 was Brazil GP (pos 9, 2 pts)
    expect(detail.roundPoints[20], equals(2));
  });

  test('DriverRepository fetches accurate 2024 stats for Hamilton', () async {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://api.jolpi.ca/ergast/f1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
    final api = DriverApi(dio);
    final dataSource = NetworkDriverDataSource(api);
    final repository = DriverRepository(dataSource);

    final detail = await repository.getDriverDetails('hamilton', season: '2024');

    expect(detail.id, equals('hamilton'));
    expect(detail.season, equals('2024'));
    expect(detail.points, equals('223'));
    expect(detail.position, equals('7'));
    expect(detail.teamName.toLowerCase(), contains('mercedes'));

    final teamColor = F1Colors.getTeamColor(detail.teamName);
    // Mercedes color is cyan/teal (0xFF27F4D2)
    expect(teamColor.toARGB32(), equals(0xFF27F4D2));
  });
}
