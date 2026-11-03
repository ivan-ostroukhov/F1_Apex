import 'driver_model.dart';
import 'driver_detail_model.dart';

abstract interface class IDriverRepository {
  Future<List<DriverModel>> getDrivers({String? query, String? season});
  Future<DriverModel?> getDriverById(String id, {String season = 'current'});
  Future<DriverDetailModel> getDriverDetails(String driverId, {String season = '2026'});
  Future<List<String>> getDriverSeasons(String driverId);
}