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
  Future<List<DriverModel>> getDrivers({String? query, String? season}) async {
    final reqSeason = (season == null || season == '2026') ? 'current' : season;
    final cacheKey = 'driver_standings_$reqSeason';

    List<DriverModel> drivers = [];

    final cached = LocalStorageService.getString(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final list = (jsonDecode(cached) as List<dynamic>)
            .map((e) => DriverModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) drivers = list;
      } catch (_) {}
    }

    try {
      final dtos = await _dataSource.getDriverStandings(season: reqSeason);
      final liveList = dtos.toDomainList();
      if (liveList.isNotEmpty) {
        drivers = liveList;
        LocalStorageService.setString(
          cacheKey,
          jsonEncode(liveList.map((d) => d.toJson()).toList()),
        );
      }
    } catch (_) {
      if (drivers.isEmpty) {
        drivers = _getFallbackDriverList();
      }
    }

    if (drivers.isEmpty) {
      drivers = _getFallbackDriverList();
    }

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

  List<DriverModel> _getFallbackDriverList() {
    return const [
      DriverModel(id: 'verstappen', name: 'Max Verstappen', permanentNumber: 1, teamName: 'Red Bull', points: 437, teammateId: 'lawson', imageUrl: ''),
      DriverModel(id: 'norris', name: 'Lando Norris', permanentNumber: 4, teamName: 'McLaren', points: 374, teammateId: 'piastri', imageUrl: ''),
      DriverModel(id: 'leclerc', name: 'Charles Leclerc', permanentNumber: 16, teamName: 'Ferrari', points: 356, teammateId: 'hamilton', imageUrl: ''),
      DriverModel(id: 'piastri', name: 'Oscar Piastri', permanentNumber: 81, teamName: 'McLaren', points: 292, teammateId: 'norris', imageUrl: ''),
      DriverModel(id: 'sainz', name: 'Carlos Sainz', permanentNumber: 55, teamName: 'Williams', points: 290, teammateId: 'albon', imageUrl: ''),
      DriverModel(id: 'russell', name: 'George Russell', permanentNumber: 63, teamName: 'Mercedes', points: 245, teammateId: 'antonelli', imageUrl: ''),
      DriverModel(id: 'hamilton', name: 'Lewis Hamilton', permanentNumber: 44, teamName: 'Ferrari', points: 223, teammateId: 'leclerc', imageUrl: ''),
      DriverModel(id: 'hadjar', name: 'Isack Hadjar', permanentNumber: 6, teamName: 'Red Bull', points: 180, teammateId: 'verstappen', imageUrl: ''),
      DriverModel(id: 'lawson', name: 'Liam Lawson', permanentNumber: 30, teamName: 'Racing Bulls', points: 150, teammateId: 'tsunoda', imageUrl: ''),
      DriverModel(id: 'gasly', name: 'Pierre Gasly', permanentNumber: 10, teamName: 'Alpine', points: 120, teammateId: 'colapinto', imageUrl: ''),
      DriverModel(id: 'lindblad', name: 'Arvid Lindblad', permanentNumber: 41, teamName: 'Racing Bulls', points: 100, teammateId: 'tsunoda', imageUrl: ''),
      DriverModel(id: 'colapinto', name: 'Franco Colapinto', permanentNumber: 43, teamName: 'Alpine', points: 80, teammateId: 'gasly', imageUrl: ''),
      DriverModel(id: 'bearman', name: 'Oliver Bearman', permanentNumber: 38, teamName: 'Haas', points: 60, teammateId: 'ocon', imageUrl: ''),
      DriverModel(id: 'hulkenberg', name: 'Nico Hülkenberg', permanentNumber: 27, teamName: 'Audi', points: 40, teammateId: 'bortoleto', imageUrl: ''),
      DriverModel(id: 'albon', name: 'Alexander Albon', permanentNumber: 23, teamName: 'Williams', points: 35, teammateId: 'sainz', imageUrl: ''),
      DriverModel(id: 'tsunoda', name: 'Yuki Tsunoda', permanentNumber: 22, teamName: 'Racing Bulls', points: 30, teammateId: 'lawson', imageUrl: ''),
      DriverModel(id: 'stroll', name: 'Lance Stroll', permanentNumber: 18, teamName: 'Aston Martin', points: 24, teammateId: 'alonso', imageUrl: ''),
      DriverModel(id: 'alonso', name: 'Fernando Alonso', permanentNumber: 14, teamName: 'Aston Martin', points: 20, teammateId: 'stroll', imageUrl: ''),
      DriverModel(id: 'ocon', name: 'Esteban Ocon', permanentNumber: 31, teamName: 'Haas', points: 15, teammateId: 'bearman', imageUrl: ''),
      DriverModel(id: 'bortoleto', name: 'Gabriel Bortoleto', permanentNumber: 5, teamName: 'Audi', points: 10, teammateId: 'hulkenberg', imageUrl: ''),
      DriverModel(id: 'antonelli', name: 'Andrea Kimi Antonelli', permanentNumber: 12, teamName: 'Mercedes', points: 8, teammateId: 'russell', imageUrl: ''),
    ];
  }

  @override
  Future<DriverModel?> getDriverById(String id, {String season = 'current'}) async {
    final results = await Future.wait([
      _dataSource.getDriverStandings(season: season),
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

    DriverDetailModel? cachedModel;
    final cachedStr = LocalStorageService.getString(cacheKey);
    if (cachedStr != null && cachedStr.isNotEmpty) {
      try {
        cachedModel = DriverDetailModel.fromJson(
          jsonDecode(cachedStr) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    if (isPastSeason && cachedModel != null) {
      return cachedModel;
    }

    if (cachedModel != null &&
        cachedModel.points != '0' &&
        cachedModel.position != '0' &&
        cachedModel.position != '21' &&
        cachedModel.roundPoints.whereType<int>().any((p) => p > 0)) {
      final tsStr = LocalStorageService.getString(tsKey);
      final ts = int.tryParse(tsStr ?? '') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - ts < const Duration(hours: 2).inMilliseconds) {
        return cachedModel;
      }
    }

    try {
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

      var seasonData = results[0] as Map<String, dynamic>;
      final careerData = results[1] as Map<String, dynamic>;
      final seasonStanding = results[2] as DriverStandingDto?;

      var raceList =
          seasonData['MRData']?['RaceTable']?['Races'] as List<dynamic>? ?? [];

      if (raceList.isEmpty && (querySeason == '2026' || querySeason == 'current')) {
        try {
          final fallbackData = await _dataSource.getDriverSeasonResults(driverId, season: '2024');
          final fallbackRaces = fallbackData['MRData']?['RaceTable']?['Races'] as List<dynamic>? ?? [];
          if (fallbackRaces.isNotEmpty) {
            seasonData = fallbackData;
            raceList = fallbackRaces;
          }
        } catch (_) {}
      }

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
      String rawTeamName = seasonStanding?.constructors.firstOrNull?.name ?? '';
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

        if (rawTeamName.isEmpty) {
          final constr = res['Constructor'] as Map<String, dynamic>? ?? {};
          rawTeamName = constr['name'] as String? ?? rawTeamName;
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

      if (season == '2026' || season == 'current') {
        try {
          final allDrivers = await getDrivers(season: 'current');
          final matched = allDrivers.where((d) => d.id.toLowerCase() == driverId.toLowerCase()).firstOrNull;
          if (matched != null) {
            final idx = allDrivers.indexOf(matched);
            position = (idx + 1).toString();
            pointsStr = matched.points.toString();
            rawTeamName = matched.teamName;
          }
        } catch (_) {}
      }

      if ((pointsStr == '0' || pointsStr == '—') && roundPoints.isNotEmpty) {
        final sum = roundPoints.fold<int>(0, (a, b) => a + (b ?? 0));
        if (sum > 0) pointsStr = sum.toString();
      }

      final teamName = TeamUtils.cleanTeamName(rawTeamName, driverId);

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
        teamName: teamName,
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
        teamName: TeamUtils.getRealDriverTeam(driverId),
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