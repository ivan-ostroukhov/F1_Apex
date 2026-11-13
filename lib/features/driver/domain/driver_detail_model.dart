class DriverDetailModel {
  final String id;
  final String firstName;
  final String lastName;
  final String code;
  final String permanentNumber;
  final String teamName;
  final String position;
  final String points;
  final int wins;
  final int podiums;
  final int poles;
  final int dnfs;
  final String dateOfBirth;
  final String nationality;
  final String firstRace;
  final String firstWin;
  final int worldChampionships;
  final List<int?> roundPoints;
  final String season;

  const DriverDetailModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.code,
    required this.permanentNumber,
    required this.teamName,
    required this.position,
    required this.points,
    required this.wins,
    required this.podiums,
    required this.poles,
    required this.dnfs,
    required this.dateOfBirth,
    required this.nationality,
    required this.firstRace,
    required this.firstWin,
    required this.worldChampionships,
    required this.roundPoints,
    this.season = '2026',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'code': code,
      'permanentNumber': permanentNumber,
      'teamName': teamName,
      'position': position,
      'points': points,
      'wins': wins,
      'podiums': podiums,
      'poles': poles,
      'dnfs': dnfs,
      'dateOfBirth': dateOfBirth,
      'nationality': nationality,
      'firstRace': firstRace,
      'firstWin': firstWin,
      'worldChampionships': worldChampionships,
      'roundPoints': roundPoints,
      'season': season,
    };
  }

  factory DriverDetailModel.fromJson(Map<String, dynamic> json) {
    return DriverDetailModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      code: json['code'] as String? ?? '',
      permanentNumber: json['permanentNumber'] as String? ?? '',
      teamName: json['teamName'] as String? ?? '',
      position: json['position'] as String? ?? '0',
      points: json['points'] as String? ?? '0',
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      podiums: (json['podiums'] as num?)?.toInt() ?? 0,
      poles: (json['poles'] as num?)?.toInt() ?? 0,
      dnfs: (json['dnfs'] as num?)?.toInt() ?? 0,
      dateOfBirth: json['dateOfBirth'] as String? ?? '—',
      nationality: json['nationality'] as String? ?? '—',
      firstRace: json['firstRace'] as String? ?? '—',
      firstWin: json['firstWin'] as String? ?? '—',
      worldChampionships: (json['worldChampionships'] as num?)?.toInt() ?? 0,
      roundPoints: (json['roundPoints'] as List<dynamic>?)
              ?.map((e) => e == null ? null : (e as num).toInt())
              .toList() ??
          const [],
      season: json['season'] as String? ?? '2026',
    );
  }
}
