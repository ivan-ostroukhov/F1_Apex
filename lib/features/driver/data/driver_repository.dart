import 'dart:convert';
import '../domain/driver_model.dart';
import '../domain/i_driver_repository.dart';
import '../domain/driver_detail_model.dart';
import 'dto/driver_dto.dart';
import 'data_sources/driver_data_source.dart';
import 'mappers/driver_mapper.dart';
import '../../../../common/network/load_exception.dart';
import '../../../../common/network/local_storage_service.dart';
import '../../../../common/utils/team_utils.dart';

class DriverRepository implements IDriverRepository {
  final IDriverDataSource _dataSource;

  const DriverRepository(this._dataSource);

  @override
  Future<List<DriverModel>> getDrivers({String? query}) async {
    final dtos = await _dataSource.getDriverStandings();
    final drivers = dtos.toDomainList();

    if (query == null || query.trim().isEmpty) {
      return drivers;
    }
    final q = query.trim().toLowerCase();
    return drivers
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.teamName.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<DriverModel?> getDriverById(String id, {String season = 'current'}) async {
    final results = await Future.wait([
      _dataSource.getDriverStandings(),
      _dataSource
          .getDriverById(id, season: season)
          .then<DriverStandingDto?>((val) => val)
          .catchError((_) => null),
    ]);

    final standings = results[0] as List<DriverStandingDto>;
    final specificDto = results[1] as DriverStandingDto?;

    final domainList = standings.toDomainList();
    final fromList = domainList.where((d) => d.id == id).firstOrNull;

    if (fromList != null) {
      return fromList;
    }

    if (specificDto != null) {
      return specificDto.toDomain(teammateId: id);
    }

    throw const NotFoundLoadException();
  }

  @override
  Future<List<String>> getDriverSeasons(String driverId) async {
    final cacheKey = 'driver_seasons_$driverId';
    final cached = LocalStorageService.getString(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final list = (jsonDecode(cached) as List<dynamic>).map((e) => e.toString()).toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }

    try {
      final seasons = await _dataSource.getDriverSeasons(driverId);
      if (seasons.isNotEmpty) {
        LocalStorageService.setString(cacheKey, jsonEncode(seasons));
        return seasons;
      }
    } catch (_) {}

    return ['2026', '2025', '2024'];
  }

  @override
  Future<DriverDetailModel> getDriverDetails(
    String driverId, {
    String season = '2026',
  }) async {
    final isCareer = season == 'career';
    final querySeason = isCareer ? 'current' : season;
    final isPastSeason = season != '2026' && season != 'current' && !isCareer;
    final cacheKey = 'driver_detail_${driverId}_$season';
    final tsKey = 'driver_detail_ts_${driverId}_$season';

    // 1. Check local cache
    DriverDetailModel? cachedModel;
    final cachedStr = LocalStorageService.getString(cacheKey);
    if (cachedStr != null && cachedStr.isNotEmpty) {
      try {
        cachedModel = DriverDetailModel.fromJson(
          jsonDecode(cachedStr) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    // Past seasons never change. Return immediately if cached!
    if (isPastSeason && cachedModel != null) {
      return cachedModel;
    }

    // For current season / career, if cache is fresh (< 2 hours), return immediately!
    if (cachedModel != null) {
      final tsStr = LocalStorageService.getString(tsKey);
      final ts = int.tryParse(tsStr ?? '') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - ts < const Duration(hours: 2).inMilliseconds) {
        return cachedModel;
      }
    }

    // 2. Fetch from network, falling back to cachedModel on failure
    try {
      // Check if career milestones are already cached for this driver
      final milestoneKey = 'driver_milestones_$driverId';
      final cachedMilestonesStr = LocalStorageService.getString(milestoneKey);
      Map<String, dynamic>? milestones;
      if (cachedMilestonesStr != null && cachedMilestonesStr.isNotEmpty) {
        try {
          milestones = jsonDecode(cachedMilestonesStr) as Map<String, dynamic>;
        } catch (_) {}
      }

      final seasonDataFuture = _dataSource.getDriverSeasonResults(driverId, season: querySeason);
      final careerDataFuture = (milestones != null)
          ? Future.value(<String, dynamic>{})
          : _dataSource.getDriverCareerMilestones(driverId);
      final standingFuture = isCareer
          ? Future.value(null)
          : _dataSource
              .getDriverById(driverId, season: querySeason)
              .then<DriverStandingDto?>((val) => val)
              .catchError((_) => null);

      final results = await Future.wait([
        seasonDataFuture,
        careerDataFuture,
        standingFuture,
      ]);

      final seasonData = results[0] as Map<String, dynamic>;
      final careerData = results[1] as Map<String, dynamic>;
      final seasonStanding = results[2] as DriverStandingDto?;

      final raceList =
          seasonData['MRData']?['RaceTable']?['Races'] as List<dynamic>? ?? [];

      int wins = 0;
      int podiums = 0;
      int poles = 0;
      int dnfs = 0;
      final List<int?> roundPoints = [];

      String code = milestones?['code'] as String? ?? '';
      String permanentNumber = milestones?['permanentNumber'] as String? ?? '';
      String dateOfBirth = milestones?['dateOfBirth'] as String? ?? '';
      String nationality = milestones?['nationality'] as String? ?? '';
      String givenName = milestones?['givenName'] as String? ?? '';
      String familyName = milestones?['familyName'] as String? ?? '';
      String teamName = seasonStanding?.constructors.firstOrNull?.name ?? '';
      String position = seasonStanding?.position ?? (isCareer ? '—' : '0');
      String pointsStr = seasonStanding?.points ?? (isCareer ? '—' : '0');

      for (final race in raceList) {
        final resultsList = race['Results'] as List<dynamic>? ?? [];
        if (resultsList.isEmpty) continue;
        final res = resultsList.first as Map<String, dynamic>;

        final driverObj = res['Driver'] as Map<String, dynamic>? ?? {};
        code = driverObj['code'] as String? ?? code;
        permanentNumber =
            driverObj['permanentNumber'] as String? ?? permanentNumber;
        dateOfBirth = driverObj['dateOfBirth'] as String? ?? dateOfBirth;
        nationality = driverObj['nationality'] as String? ?? nationality;
        givenName = driverObj['givenName'] as String? ?? givenName;
        familyName = driverObj['familyName'] as String? ?? familyName;

        if (teamName.isEmpty) {
          final constr = res['Constructor'] as Map<String, dynamic>? ?? {};
          teamName = constr['name'] as String? ?? teamName;
        }

        final pos = int.tryParse(res['position'] as String? ?? '') ?? 0;
        final grid = int.tryParse(res['grid'] as String? ?? '') ?? 0;
        final pts = (double.tryParse(res['points'] as String? ?? '') ?? 0).round();
        final status = res['status'] as String? ?? '';

        roundPoints.add(pts);

        if (pos == 1) wins++;
        if (pos >= 1 && pos <= 3) podiums++;
        if (grid == 1) poles++;
        if (!status.toLowerCase().contains('finished') && !status.startsWith('+')) {
          dnfs++;
        }
      }

      if (pointsStr == '0' && roundPoints.isNotEmpty) {
        final sum = roundPoints.fold<int>(0, (a, b) => a + (b ?? 0));
        if (sum > 0) pointsStr = sum.toString();
      }

      String firstRaceStr = milestones?['firstRace'] as String? ?? '';
      String firstWinStr = milestones?['firstWin'] as String? ?? '';
      int championships = milestones?['worldChampionships'] as int? ?? (milestones?['championships'] as int? ?? 0);

      if (milestones == null) {
        final firstRaceList =
            careerData['firstRace']?['MRData']?['RaceTable']?['Races'] as List<dynamic>? ?? [];
        firstRaceStr = firstRaceList.isNotEmpty
            ? '${firstRaceList.first['season']} ${firstRaceList.first['raceName']}'
            : '—';

        final firstWinList =
            careerData['firstWin']?['MRData']?['RaceTable']?['Races'] as List<dynamic>? ?? [];
        firstWinStr = firstWinList.isNotEmpty
            ? '${firstWinList.first['season']} ${firstWinList.first['raceName']}'
            : '—';

        championships = int.tryParse(
          careerData['championships']?['MRData']?['total'] as String? ?? '0',
        ) ?? 0;

        LocalStorageService.setString(
          milestoneKey,
          jsonEncode({
            'firstRace': firstRaceStr,
            'firstWin': firstWinStr,
            'worldChampionships': championships,
            'nationality': nationality,
            'dateOfBirth': dateOfBirth,
            'code': code,
            'permanentNumber': permanentNumber,
            'givenName': givenName,
            'familyName': familyName,
          }),
        );
      }

      String formattedDob = dateOfBirth;
      if (dateOfBirth.contains('-')) {
        final parts = dateOfBirth.split('-');
        if (parts.length == 3) {
          final year = int.tryParse(parts[0]) ?? 2000;
          final age = DateTime.now().year - year;
          formattedDob = '${parts[2]}.${parts[1]}.${parts[0]} ($age)';
        }
      }

      final model = DriverDetailModel(
        id: driverId,
        firstName: givenName,
        lastName: familyName,
        code: code.isNotEmpty
            ? code
            : (driverId.length >= 3 ? driverId.substring(0, 3).toUpperCase() : driverId.toUpperCase()),
        permanentNumber: permanentNumber,
        teamName: TeamUtils.cleanTeamName(teamName),
        position: position,
        points: pointsStr,
        wins: wins,
        podiums: podiums,
        poles: poles,
        dnfs: dnfs,
        dateOfBirth: formattedDob.isNotEmpty ? formattedDob : '—',
        nationality: nationality.isNotEmpty ? nationality : '—',
        firstRace: firstRaceStr.isNotEmpty ? firstRaceStr : '—',
        firstWin: firstWinStr.isNotEmpty ? firstWinStr : '—',
        worldChampionships: championships,
        roundPoints: roundPoints,
        season: season,
      );

      // Save to cache
      LocalStorageService.setString(cacheKey, jsonEncode(model.toJson()));
      LocalStorageService.setString(tsKey, DateTime.now().millisecondsSinceEpoch.toString());

      return model;
    } catch (e) {
      if (cachedModel != null) {
        return cachedModel;
      }
      return DriverDetailModel(
        id: driverId,
        firstName: '',
        lastName: '',
        code: driverId.length >= 3 ? driverId.substring(0, 3).toUpperCase() : driverId.toUpperCase(),
        permanentNumber: '',
        teamName: '',
        position: '0',
        points: '0',
        wins: 0,
        podiums: 0,
        poles: 0,
        dnfs: 0,
        dateOfBirth: '—',
        nationality: '—',
        firstRace: '—',
        firstWin: '—',
        worldChampionships: 0,
        roundPoints: const [],
        season: season,
      );
    }
  }
}
