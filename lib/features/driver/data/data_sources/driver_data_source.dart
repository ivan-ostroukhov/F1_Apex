import '../dto/driver_dto.dart';

abstract interface class IDriverDataSource {
  Future<List<DriverStandingDto>> getDriverStandings({String? season, int limit = 30, int offset = 0});
  Future<DriverStandingDto> getDriverById(String id, {String season = 'current'});
  Future<Map<String, dynamic>> getDriverSeasonResults(String driverId, {String season = 'current'});
  Future<Map<String, dynamic>> getDriverCareerMilestones(String driverId);
  Future<List<String>> getDriverSeasons(String driverId);
}