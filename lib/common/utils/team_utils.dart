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
}