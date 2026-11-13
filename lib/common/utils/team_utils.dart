class DriverStatsData {
  final String pos;
  final String pts;
  final int wins;
  final int podiums;
  final int poles;
  final String permanentNumber;
  final int worldChampionships;

  const DriverStatsData({
    required this.pos,
    required this.pts,
    required this.wins,
    required this.podiums,
    required this.poles,
    required this.permanentNumber,
    required this.worldChampionships,
  });
}

class TeamUtils {
  static String cleanTeamName(String raw, [String? driverId]) {
    if (driverId != null && driverId.isNotEmpty) {
      final known = getRealDriverTeam(driverId);
      if (known.isNotEmpty) return known;
    }

    if (raw.isNotEmpty) {
      var name = raw;

      name = name.replaceAll(RegExp(r'\s+F1\s+Team.*', caseSensitive: false), '');
      name = name.replaceAll(RegExp(r'\s+Formula\s+One\s+Team.*', caseSensitive: false), '');
      name = name.replaceAll(RegExp(r'\s+Aramco.*', caseSensitive: false), '');
      name = name.replaceAll(RegExp(r'\s+Stake.*', caseSensitive: false), '');
      name = name.replaceAll(RegExp(r'\s+Racing$', caseSensitive: false), '');
      name = name.trim();

      final lower = name.toLowerCase();
      if (lower == 'rb') return 'Racing Bulls';
      if (lower.contains('cadillac')) return 'Cadillac';
      if (lower.contains('red bull')) return 'Red Bull';
      if (lower.contains('ferrari')) return 'Ferrari';
      if (lower.contains('mercedes')) return 'Mercedes';
      if (lower.contains('mclaren')) return 'McLaren';
      if (lower.contains('aston')) return 'Aston Martin';
      if (lower.contains('alpine')) return 'Alpine';
      if (lower.contains('williams')) return 'Williams';
      if (lower.contains('haas')) return 'Haas';
      if (lower.contains('sauber') || lower.contains('kick')) return 'Sauber';
      if (lower.contains('audi')) return 'Audi';
      return name;
    }

    return raw;
  }

  static String getRealDriverTeam(String driverId) {
    final lower = driverId.toLowerCase();
    if (lower.contains('verstappen') || lower.contains('hadjar') || lower.contains('lawson')) return 'Red Bull';
    if (lower.contains('leclerc') || lower.contains('hamilton')) return 'Ferrari';
    if (lower.contains('norris') || lower.contains('piastri')) return 'McLaren';
    if (lower.contains('russell') || lower.contains('antonelli')) return 'Mercedes';
    if (lower.contains('alonso') || lower.contains('stroll')) return 'Aston Martin';
    if (lower.contains('gasly') || lower.contains('colapinto') || lower.contains('doohan')) return 'Alpine';
    if (lower.contains('albon') || lower.contains('sainz')) return 'Williams';
    if (lower.contains('tsunoda') || lower.contains('lindblad')) return 'Racing Bulls';
    if (lower.contains('bearman') || lower.contains('ocon') || lower.contains('magnussen')) return 'Haas';
    if (lower.contains('hulkenberg') || lower.contains('bortoleto')) return 'Audi';
    if (lower.contains('bottas') || lower.contains('perez')) return 'Cadillac';
    return 'Red Bull';
  }

  static String getDefaultTeamForDriver(String driverId) {
    return getRealDriverTeam(driverId);
  }

  static DriverStatsData getDefaultDriverStats(String driverId) {
    final lower = driverId.toLowerCase();
    if (lower.contains('verstappen')) {
      return const DriverStatsData(pos: '01', pts: '437', wins: 9, podiums: 14, poles: 8, permanentNumber: '1', worldChampionships: 4);
    }
    if (lower.contains('norris')) {
      return const DriverStatsData(pos: '02', pts: '374', wins: 4, podiums: 12, poles: 8, permanentNumber: '4', worldChampionships: 0);
    }
    if (lower.contains('leclerc')) {
      return const DriverStatsData(pos: '03', pts: '356', wins: 3, podiums: 12, poles: 3, permanentNumber: '16', worldChampionships: 0);
    }
    if (lower.contains('piastri')) {
      return const DriverStatsData(pos: '04', pts: '292', wins: 2, podiums: 8, poles: 1, permanentNumber: '81', worldChampionships: 0);
    }
    if (lower.contains('sainz')) {
      return const DriverStatsData(pos: '05', pts: '290', wins: 2, podiums: 8, poles: 1, permanentNumber: '55', worldChampionships: 0);
    }
    if (lower.contains('russell')) {
      return const DriverStatsData(pos: '06', pts: '245', wins: 1, podiums: 4, poles: 2, permanentNumber: '63', worldChampionships: 0);
    }
    if (lower.contains('hamilton')) {
      return const DriverStatsData(pos: '07', pts: '223', wins: 2, podiums: 5, poles: 0, permanentNumber: '44', worldChampionships: 7);
    }
    if (lower.contains('perez')) {
      return const DriverStatsData(pos: '08', pts: '152', wins: 0, podiums: 4, poles: 0, permanentNumber: '11', worldChampionships: 0);
    }
    if (lower.contains('alonso')) {
      return const DriverStatsData(pos: '09', pts: '70', wins: 0, podiums: 0, poles: 0, permanentNumber: '14', worldChampionships: 2);
    }
    if (lower.contains('hulkenberg')) {
      return const DriverStatsData(pos: '10', pts: '41', wins: 0, podiums: 0, poles: 0, permanentNumber: '27', worldChampionships: 0);
    }
    if (lower.contains('tsunoda')) {
      return const DriverStatsData(pos: '11', pts: '30', wins: 0, podiums: 0, poles: 0, permanentNumber: '22', worldChampionships: 0);
    }
    if (lower.contains('stroll')) {
      return const DriverStatsData(pos: '12', pts: '24', wins: 0, podiums: 0, poles: 0, permanentNumber: '18', worldChampionships: 0);
    }
    if (lower.contains('bearman')) {
      return const DriverStatsData(pos: '13', pts: '7', wins: 0, podiums: 0, poles: 0, permanentNumber: '87', worldChampionships: 0);
    }
    if (lower.contains('colapinto')) {
      return const DriverStatsData(pos: '14', pts: '5', wins: 0, podiums: 0, poles: 0, permanentNumber: '43', worldChampionships: 0);
    }
    if (lower.contains('ocon')) {
      return const DriverStatsData(pos: '15', pts: '23', wins: 0, podiums: 1, poles: 0, permanentNumber: '31', worldChampionships: 0);
    }
    if (lower.contains('gasly')) {
      return const DriverStatsData(pos: '16', pts: '26', wins: 0, podiums: 1, poles: 0, permanentNumber: '10', worldChampionships: 0);
    }
    if (lower.contains('albon')) {
      return const DriverStatsData(pos: '17', pts: '12', wins: 0, podiums: 0, poles: 0, permanentNumber: '23', worldChampionships: 0);
    }
    if (lower.contains('lawson')) {
      return const DriverStatsData(pos: '18', pts: '12', wins: 0, podiums: 0, poles: 0, permanentNumber: '30', worldChampionships: 0);
    }
    if (lower.contains('antonelli')) {
      return const DriverStatsData(pos: '19', pts: '0', wins: 0, podiums: 0, poles: 0, permanentNumber: '12', worldChampionships: 0);
    }
    if (lower.contains('hadjar')) {
      return const DriverStatsData(pos: '20', pts: '0', wins: 0, podiums: 0, poles: 0, permanentNumber: '6', worldChampionships: 0);
    }
    if (lower.contains('bortoleto')) {
      return const DriverStatsData(pos: '21', pts: '0', wins: 0, podiums: 0, poles: 0, permanentNumber: '5', worldChampionships: 0);
    }
    if (lower.contains('lindblad')) {
      return const DriverStatsData(pos: '22', pts: '0', wins: 0, podiums: 0, poles: 0, permanentNumber: '7', worldChampionships: 0);
    }
    if (lower.contains('bottas')) {
      return const DriverStatsData(pos: '23', pts: '0', wins: 0, podiums: 0, poles: 0, permanentNumber: '77', worldChampionships: 0);
    }
    return const DriverStatsData(pos: '10', pts: '50', wins: 0, podiums: 0, poles: 0, permanentNumber: '99', worldChampionships: 0);
  }
}