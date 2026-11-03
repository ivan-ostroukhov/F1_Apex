import 'package:dio/dio.dart';
import '../dto/driver_dto.dart';

class DriverApi {
  final Dio _dio;

  const DriverApi(this._dio);

  Future<ErgastStandingsResponseDto> getStandings({
    String? season,
    int limit = 30,
    int offset = 0,
  }) async {
    final querySeason = (season == '2026' || season == null || season == 'current') ? 'current' : season;
    final response = await _dio.get<Map<String, dynamic>>(
      '/$querySeason/driverStandings.json',
      queryParameters: {'limit': limit, 'offset': offset},
    );
    return ErgastStandingsResponseDto.fromJson(response.data!);
  }

  Future<ErgastStandingsResponseDto> getDriverStandingById(
    String driverId, {
    String season = 'current',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/$season/drivers/$driverId/driverStandings.json',
    );
    return ErgastStandingsResponseDto.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> getDriverSeasonResults(
    String driverId, {
    String season = 'current',
  }) async {
    try {
      final path = season == 'career'
          ? '/drivers/$driverId/results.json'
          : '/$season/drivers/$driverId/results.json';
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: {'limit': 30},
      );
      return response.data ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<List<String>> getDriverSeasons(String driverId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/drivers/$driverId/seasons.json',
        queryParameters: {'limit': 100},
      );
      final seasonTable = response.data?['MRData']?['SeasonTable'];
      final seasonsList = seasonTable?['Seasons'] as List<dynamic>? ?? [];
      final seasons = seasonsList
          .map((s) => s['season'] as String? ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      seasons.sort((a, b) => b.compareTo(a));
      return seasons;
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getDriverFirstRace(String driverId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/drivers/$driverId/results.json',
        queryParameters: {'limit': 1},
      );
      return response.data ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> getDriverFirstWin(String driverId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/drivers/$driverId/results/1.json',
        queryParameters: {'limit': 1},
      );
      return response.data ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Future<Map<String, dynamic>> getDriverChampionships(String driverId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/drivers/$driverId/driverStandings/1.json',
      );
      return response.data ?? <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}