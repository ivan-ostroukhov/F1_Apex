import 'package:dio/dio.dart';
import '../../../../common/network/load_exception.dart';
import '../api/driver_api.dart';
import '../dto/driver_dto.dart';
import 'driver_data_source.dart';

class NetworkDriverDataSource implements IDriverDataSource {
  final DriverApi _api;

  const NetworkDriverDataSource(this._api);

  @override
  Future<List<DriverStandingDto>> getDriverStandings({
    String? season,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final response = await _api.getStandings(season: season, limit: limit, offset: offset);
      final lists = response.mrData.standingsTable.standingsLists;
      if (lists.isEmpty) return [];
      return lists.first.driverStandings;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<DriverStandingDto> getDriverById(String id, {String season = 'current'}) async {
    try {
      final response = await _api.getDriverStandingById(id, season: season);
      final lists = response.mrData.standingsTable.standingsLists;
      if (lists.isEmpty || lists.first.driverStandings.isEmpty) {
        throw const NotFoundLoadException();
      }
      return lists.first.driverStandings.first;
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDriverSeasonResults(
    String driverId, {
    String season = 'current',
  }) async {
    try {
      return await _api.getDriverSeasonResults(driverId, season: season);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<List<String>> getDriverSeasons(String driverId) async {
    try {
      return await _api.getDriverSeasons(driverId);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDriverCareerMilestones(String driverId) async {
    try {
      final results = await Future.wait([
        _api.getDriverFirstRace(driverId),
        _api.getDriverFirstWin(driverId),
        _api.getDriverChampionships(driverId),
      ]);

      return {
        'firstRace': results[0],
        'firstWin': results[1],
        'championships': results[2],
      };
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  LoadException _mapDioException(DioException e) {
    if (e.response?.statusCode == 404) {
      return const NotFoundLoadException();
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkLoadException();
    }
    return ServerLoadException(e.response?.statusCode);
  }
}