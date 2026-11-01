import 'dart:convert';
import '../domain/constructor_model.dart';
import '../domain/constructor_detail_model.dart';
import '../domain/constructor_repository.dart';
import 'data_sources/constructor_data_source.dart';
import 'dto/constructor_dto.dart';
import 'mappers/constructor_mapper.dart';
import '../../../../common/network/local_storage_service.dart';

class TeamMetaData {
  final String chassis;
  final String engine;
  final String teamPrincipal;
  final String baseLocation;
  final int constructorsTitles;
  final int driversTitles;
  final String carAssetPath;

  const TeamMetaData({
    required this.chassis,
    required this.engine,
    required this.teamPrincipal,
    required this.baseLocation,
    required this.constructorsTitles,
    required this.driversTitles,
    required this.carAssetPath,
  });
}

TeamMetaData _getMeta(String id, String name) {
  final lower = '$id $name'.toLowerCase();
  if (lower.contains('ferrari')) {
    return const TeamMetaData(
      chassis: 'SF-26',
      engine: 'Ferrari',
      teamPrincipal: 'Frederic Vasseur',
      baseLocation: 'Maranello, Italy',
      constructorsTitles: 16,
      driversTitles: 15,
      carAssetPath: 'assets/images/ferrari.png',
    );
  }
  if (lower.contains('mercedes')) {
    return const TeamMetaData(
      chassis: 'F1 W17',
      engine: 'Mercedes',
      teamPrincipal: 'Toto Wolff',
      baseLocation: 'Brackley, United Kingdom',
      constructorsTitles: 8,
      driversTitles: 9,
      carAssetPath: 'assets/images/mercedes.png',
    );
  }
  if (lower.contains('red_bull') || lower.contains('red bull')) {
    return const TeamMetaData(
      chassis: 'RB22',
      engine: 'Honda RBPT',
      teamPrincipal: 'Christian Horner',
      baseLocation: 'Milton Keynes, United Kingdom',
      constructorsTitles: 6,
      driversTitles: 7,
      carAssetPath: 'assets/images/red_bull.png',
    );
  }
  if (lower.contains('mclaren')) {
    return const TeamMetaData(
      chassis: 'MCL40',
      engine: 'Mercedes',
      teamPrincipal: 'Andrea Stella',
      baseLocation: 'Woking, United Kingdom',
      constructorsTitles: 9,
      driversTitles: 12,
      carAssetPath: 'assets/images/mclaren.png',
    );
  }
  if (lower.contains('aston')) {
    return const TeamMetaData(
      chassis: 'AMR26',
      engine: 'Mercedes',
      teamPrincipal: 'Mike Krack',
      baseLocation: 'Silverstone, United Kingdom',
      constructorsTitles: 0,
      driversTitles: 0,
      carAssetPath: 'assets/images/aston_martin.png',
    );
  }
  if (lower.contains('alpine')) {
    return const TeamMetaData(
      chassis: 'A526',
      engine: 'Renault',
      teamPrincipal: 'Oliver Oakes',
      baseLocation: 'Enstone, United Kingdom',
      constructorsTitles: 2,
      driversTitles: 2,
      carAssetPath: 'assets/images/alpine.png',
    );
  }
  if (lower.contains('rb') || lower.contains('racing_bulls') || lower.contains('racing bulls')) {
    return const TeamMetaData(
      chassis: 'VCARB 03',
      engine: 'Honda RBPT',
      teamPrincipal: 'Laurent Mekies',
      baseLocation: 'Faenza, Italy',
      constructorsTitles: 0,
      driversTitles: 0,
      carAssetPath: 'assets/images/racing_bulls.png',
    );
  }
  if (lower.contains('haas')) {
    return const TeamMetaData(
      chassis: 'VF-26',
      engine: 'Ferrari',
      teamPrincipal: 'Ayao Komatsu',
      baseLocation: 'Kannapolis, United States',
      constructorsTitles: 0,
      driversTitles: 0,
      carAssetPath: 'assets/images/haas.png',
    );
  }
  if (lower.contains('williams')) {
    return const TeamMetaData(
      chassis: 'FW48',
      engine: 'Mercedes',
      teamPrincipal: 'James Vowles',
      baseLocation: 'Grove, United Kingdom',
      constructorsTitles: 9,
      driversTitles: 7,
      carAssetPath: 'assets/images/williams.png',
    );
  }
  if (lower.contains('sauber') || lower.contains('kick')) {
    return const TeamMetaData(
      chassis: 'C46',
      engine: 'Ferrari',
      teamPrincipal: 'Mattia Binotto',
      baseLocation: 'Hinwil, Switzerland',
      constructorsTitles: 0,
      driversTitles: 0,
      carAssetPath: 'assets/images/sauber.png',
    );
  }
  return TeamMetaData(
    chassis: 'F1 2026',
    engine: 'Formula 1',
    teamPrincipal: 'Team Principal',
    baseLocation: 'United Kingdom',
    constructorsTitles: 0,
    driversTitles: 0,
    carAssetPath: 'assets/images/${id}_car.png',
  );
}

class ConstructorRepository implements IConstructorRepository {
  final IConstructorDataSource _dataSource;

  const ConstructorRepository(this._dataSource);

  @override
  Future<List<ConstructorModel>> getConstructors({String? query, String? season}) async {
    final standings = await _dataSource.getConstructorStandings(season: season);
    final constructors = standings.toDomainList();

    if (query == null || query.trim().isEmpty) {
      return constructors;
    }

    final q = query.trim().toLowerCase();
    return constructors
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.nationality.toLowerCase().contains(q))
        .toList();
  }

  @override
  Future<ConstructorDetailModel> getConstructorDetails(
    String constructorId, {
    String? season,
  }) async {
    final querySeason = season ?? '2026';
    final isPastSeason = querySeason != '2026' && querySeason != 'current';
    final cacheKey = 'constructor_detail_${constructorId}_$querySeason';
    final tsKey = 'constructor_detail_ts_${constructorId}_$querySeason';

    // 1. Check local cache
    ConstructorDetailModel? cachedModel;
    final cachedStr = LocalStorageService.getString(cacheKey);
    if (cachedStr != null && cachedStr.isNotEmpty) {
      try {
        cachedModel = ConstructorDetailModel.fromJson(
          jsonDecode(cachedStr) as Map<String, dynamic>,
        );
      } catch (_) {}
    }

    if (isPastSeason && cachedModel != null) {
      return cachedModel;
    }

    if (cachedModel != null) {
      final tsStr = LocalStorageService.getString(tsKey);
      final ts = int.tryParse(tsStr ?? '') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - ts < const Duration(hours: 2).inMilliseconds) {
        return cachedModel;
      }
    }

    // 2. Fetch from network
    try {
      final seasonResultsFuture = _dataSource.getConstructorSeasonResults(
        constructorId,
        season: querySeason,
      );
      final careerDataFuture = _dataSource.getConstructorCareerMilestones(constructorId);
      final standingFuture = _dataSource.getConstructorStandingForSeason(
        constructorId,
        season: querySeason,
      );

      final results = await Future.wait([
        seasonResultsFuture,
        careerDataFuture,
        standingFuture,
      ]);

      final seasonData = results[0] as Map<String, dynamic>;
      final careerData = results[1] as Map<String, dynamic>;
      final standing = results[2] as ConstructorStandingDto?;

      final raceList =
          seasonData['MRData']?['RaceTable']?['Races'] as List<dynamic>? ?? [];

      int wins = 0;
      int podiums = 0;
      int poles = 0;
      int dnfs = 0;

      String name = standing?.constructor.name ?? '';
      final Map<String, ConstructorDriverModel> driversMap = {};

      for (final race in raceList) {
        final resList = race['Results'] as List<dynamic>? ?? [];
        for (final res in resList) {
          if (res is! Map<String, dynamic>) continue;

          final constrObj = res['Constructor'] as Map<String, dynamic>? ?? {};
          if (name.isEmpty) {
            name = constrObj['name'] as String? ?? name;
          }

          final driverObj = res['Driver'] as Map<String, dynamic>? ?? {};
          final driverId = driverObj['driverId'] as String? ?? '';
          if (driverId.isNotEmpty && !driversMap.containsKey(driverId)) {
            final permNum = driverObj['permanentNumber'] as String? ?? '0';
            final code = driverObj['code'] as String? ??
                (driverId.length >= 3 ? driverId.substring(0, 3).toUpperCase() : driverId.toUpperCase());
            final given = driverObj['givenName'] as String? ?? '';
            final family = driverObj['familyName'] as String? ?? '';

            driversMap[driverId] = ConstructorDriverModel(
              id: driverId,
              permanentNumber: permNum,
              code: code,
              name: '$given $family'.trim(),
            );
          }

          final pos = int.tryParse(res['position'] as String? ?? '') ?? 0;
          final grid = int.tryParse(res['grid'] as String? ?? '') ?? 0;
          final status = res['status'] as String? ?? '';

          if (pos == 1) wins++;
          if (pos >= 1 && pos <= 3) podiums++;
          if (grid == 1) poles++;
          if (!status.toLowerCase().contains('finished') && !status.startsWith('+')) {
            dnfs++;
          }
        }
      }

      final firstRaceList =
          careerData['firstRace']?['MRData']?['RaceTable']?['Races'] as List<dynamic>? ?? [];
      final firstRaceStr = firstRaceList.isNotEmpty
          ? '${firstRaceList.first['season']} ${firstRaceList.first['raceName']}'
          : '—';

      final apiTitles = int.tryParse(
        careerData['championships']?['MRData']?['total'] as String? ?? '0',
      ) ?? 0;

      final meta = _getMeta(constructorId, name);

      final model = ConstructorDetailModel(
        id: constructorId,
        name: name.isNotEmpty ? name : constructorId.toUpperCase(),
        chassis: meta.chassis,
        engine: meta.engine,
        teamPrincipal: meta.teamPrincipal,
        firstRace: firstRaceStr,
        constructorsTitles: apiTitles > 0 ? apiTitles : meta.constructorsTitles,
        driversTitles: meta.driversTitles,
        baseLocation: meta.baseLocation,
        position: standing?.position ?? '0',
        points: standing?.points ?? '0',
        wins: wins > 0 ? wins : (int.tryParse(standing?.wins ?? '0') ?? 0),
        podiums: podiums,
        poles: poles,
        dnfs: dnfs,
        season: querySeason,
        carAssetPath: meta.carAssetPath,
        drivers: driversMap.values.toList(),
      );

      LocalStorageService.setString(cacheKey, jsonEncode(model.toJson()));
      LocalStorageService.setString(tsKey, DateTime.now().millisecondsSinceEpoch.toString());

      return model;
    } catch (e) {
      if (cachedModel != null) {
        return cachedModel;
      }
      final meta = _getMeta(constructorId, constructorId);
      return ConstructorDetailModel(
        id: constructorId,
        name: constructorId.toUpperCase(),
        chassis: meta.chassis,
        engine: meta.engine,
        teamPrincipal: meta.teamPrincipal,
        firstRace: '—',
        constructorsTitles: meta.constructorsTitles,
        driversTitles: meta.driversTitles,
        baseLocation: meta.baseLocation,
        position: '0',
        points: '0',
        wins: 0,
        podiums: 0,
        poles: 0,
        dnfs: 0,
        season: querySeason,
        carAssetPath: meta.carAssetPath,
        drivers: const [],
      );
    }
  }

  @override
  Future<List<String>> getConstructorSeasons(String constructorId) async {
    final cacheKey = 'constructor_seasons_$constructorId';
    final cached = LocalStorageService.getString(cacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final list = (jsonDecode(cached) as List<dynamic>).map((e) => e.toString()).toList();
        if (list.isNotEmpty) return list;
      } catch (_) {}
    }

    try {
      final seasons = await _dataSource.getConstructorSeasons(constructorId);
      if (seasons.isNotEmpty) {
        LocalStorageService.setString(cacheKey, jsonEncode(seasons));
        return seasons;
      }
    } catch (_) {}

    return ['2026', '2025', '2024', '2023'];
  }
}