class ConstructorDriverModel {
  final String id;
  final String permanentNumber;
  final String code;
  final String name;

  const ConstructorDriverModel({
    required this.id,
    required this.permanentNumber,
    required this.code,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'permanentNumber': permanentNumber,
      'code': code,
      'name': name,
    };
  }

  factory ConstructorDriverModel.fromJson(Map<String, dynamic> json) {
    return ConstructorDriverModel(
      id: json['id'] as String? ?? '',
      permanentNumber: json['permanentNumber'] as String? ?? '0',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

class ConstructorDetailModel {
  final String id;
  final String name;
  final String chassis;
  final String engine;
  final String teamPrincipal;
  final String firstRace;
  final int constructorsTitles;
  final int driversTitles;
  final String baseLocation;
  final String position;
  final String points;
  final int wins;
  final int podiums;
  final int poles;
  final int dnfs;
  final String season;
  final String carAssetPath;
  final List<ConstructorDriverModel> drivers;

  const ConstructorDetailModel({
    required this.id,
    required this.name,
    required this.chassis,
    required this.engine,
    required this.teamPrincipal,
    required this.firstRace,
    required this.constructorsTitles,
    required this.driversTitles,
    required this.baseLocation,
    required this.position,
    required this.points,
    required this.wins,
    required this.podiums,
    required this.poles,
    required this.dnfs,
    required this.season,
    required this.carAssetPath,
    required this.drivers,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'chassis': chassis,
      'engine': engine,
      'teamPrincipal': teamPrincipal,
      'firstRace': firstRace,
      'constructorsTitles': constructorsTitles,
      'driversTitles': driversTitles,
      'baseLocation': baseLocation,
      'position': position,
      'points': points,
      'wins': wins,
      'podiums': podiums,
      'poles': poles,
      'dnfs': dnfs,
      'season': season,
      'carAssetPath': carAssetPath,
      'drivers': drivers.map((d) => d.toJson()).toList(),
    };
  }

  factory ConstructorDetailModel.fromJson(Map<String, dynamic> json) {
    return ConstructorDetailModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      chassis: json['chassis'] as String? ?? '',
      engine: json['engine'] as String? ?? '',
      teamPrincipal: json['teamPrincipal'] as String? ?? '',
      firstRace: json['firstRace'] as String? ?? '—',
      constructorsTitles: (json['constructorsTitles'] as num?)?.toInt() ?? 0,
      driversTitles: (json['driversTitles'] as num?)?.toInt() ?? 0,
      baseLocation: json['baseLocation'] as String? ?? '',
      position: json['position'] as String? ?? '0',
      points: json['points'] as String? ?? '0',
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      podiums: (json['podiums'] as num?)?.toInt() ?? 0,
      poles: (json['poles'] as num?)?.toInt() ?? 0,
      dnfs: (json['dnfs'] as num?)?.toInt() ?? 0,
      season: json['season'] as String? ?? '2026',
      carAssetPath: json['carAssetPath'] as String? ?? '',
      drivers: (json['drivers'] as List<dynamic>?)
              ?.map((d) => ConstructorDriverModel.fromJson(d as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
