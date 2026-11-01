class ErgastStandingsResponseDto {
  final MrDataDto mrData;

  const ErgastStandingsResponseDto({required this.mrData});

  factory ErgastStandingsResponseDto.fromJson(Map<String, dynamic> json) {
    return ErgastStandingsResponseDto(
      mrData: MrDataDto.fromJson(json['MRData'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class MrDataDto {
  final StandingsTableDto standingsTable;

  const MrDataDto({required this.standingsTable});

  factory MrDataDto.fromJson(Map<String, dynamic> json) {
    return MrDataDto(
      standingsTable: StandingsTableDto.fromJson(
        json['StandingsTable'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

class StandingsTableDto {
  final List<StandingsListDto> standingsLists;

  const StandingsTableDto({required this.standingsLists});

  factory StandingsTableDto.fromJson(Map<String, dynamic> json) {
    final lists = json['StandingsLists'] as List<dynamic>? ?? [];
    return StandingsTableDto(
      standingsLists: lists
          .map((e) => StandingsListDto.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }
}

class StandingsListDto {
  final List<DriverStandingDto> driverStandings;

  const StandingsListDto({required this.driverStandings});

  factory StandingsListDto.fromJson(Map<String, dynamic> json) {
    final standings = json['DriverStandings'] as List<dynamic>? ?? [];
    return StandingsListDto(
      driverStandings: standings
          .map((e) => DriverStandingDto.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }
}

class DriverStandingDto {
  final String points;
  final String? position;
  final String? wins;
  final DriverInfoDto driver;
  final List<ConstructorDto> constructors;

  const DriverStandingDto({
    required this.points,
    this.position,
    this.wins,
    required this.driver,
    required this.constructors,
  });

  factory DriverStandingDto.fromJson(Map<String, dynamic> json) {
    final constructorsList = json['Constructors'] as List<dynamic>? ?? [];
    return DriverStandingDto(
      points: json['points'] as String? ?? '0',
      position: json['position'] as String?,
      wins: json['wins'] as String?,
      driver: DriverInfoDto.fromJson(json['Driver'] as Map<String, dynamic>? ?? {}),
      constructors: constructorsList
          .map((e) => ConstructorDto.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }
}

class DriverInfoDto {
  final String driverId;
  final String? permanentNumber;
  final String givenName;
  final String familyName;
  final String nationality;

  const DriverInfoDto({
    required this.driverId,
    this.permanentNumber,
    required this.givenName,
    required this.familyName,
    required this.nationality,
  });

  factory DriverInfoDto.fromJson(Map<String, dynamic> json) {
    return DriverInfoDto(
      driverId: json['driverId'] as String? ?? '',
      permanentNumber: json['permanentNumber'] as String?,
      givenName: json['givenName'] as String? ?? '',
      familyName: json['familyName'] as String? ?? '',
      nationality: json['nationality'] as String? ?? '',
    );
  }
}

class ConstructorDto {
  final String constructorId;
  final String name;

  const ConstructorDto({
    required this.constructorId,
    required this.name,
  });

  factory ConstructorDto.fromJson(Map<String, dynamic> json) {
    return ConstructorDto(
      constructorId: json['constructorId'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
