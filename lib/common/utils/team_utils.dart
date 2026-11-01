class TeamUtils {
  static String cleanTeamName(String raw) {
    if (raw.isEmpty) return raw;
    var name = raw;

    name = name.replaceAll(RegExp(r'\s+F1\s+Team.*', caseSensitive: false), '');
    name = name.replaceAll(RegExp(r'\s+Formula\s+One\s+Team.*', caseSensitive: false), '');
    name = name.replaceAll(RegExp(r'\s+Aramco.*', caseSensitive: false), '');
    name = name.replaceAll(RegExp(r'\s+Stake.*', caseSensitive: false), '');
    name = name.replaceAll(RegExp(r'\s+Racing$', caseSensitive: false), '');
    name = name.replaceAll(RegExp(r'^Oracle\s+', caseSensitive: false), '');
    name = name.replaceAll(RegExp(r'^Scuderia\s+', caseSensitive: false), '');
    name = name.trim();

    final lower = name.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ');
    if (lower == 'rb' ||
        lower.contains('racing bulls') ||
        lower.contains('vcarb') ||
        lower.contains('alphatauri') ||
        lower.contains('toro rosso')) {
      return 'Racing Bulls';
    }
    if (lower.contains('red bull') || lower.contains('redbull')) return 'Red Bull';
    if (lower.contains('ferrari')) return 'Ferrari';
    if (lower.contains('mercedes')) return 'Mercedes';
    if (lower.contains('mclaren')) return 'McLaren';
    if (lower.contains('aston')) return 'Aston Martin';
    if (lower.contains('alpine')) return 'Alpine';
    if (lower.contains('williams')) return 'Williams';
    if (lower.contains('haas')) return 'Haas';
    if (lower.contains('audi')) return 'Audi';
    if (lower.contains('cadillac')) return 'Cadillac';
    if (lower.contains('sauber') || lower.contains('kick') || lower.contains('stake')) return 'Sauber';

    return name;
  }

  static String getDefaultTeamForDriver(String driverId) {
    final lower = driverId.toLowerCase().replaceAll('-', '_').trim();
    if (lower.contains('verstappen') || lower.contains('hadjar')) return 'Red Bull Racing';
    if (lower.contains('leclerc') || lower.contains('hamilton')) return 'Ferrari';
    if (lower.contains('norris') || lower.contains('piastri')) return 'McLaren';
    if (lower.contains('russell') || lower.contains('antonelli')) return 'Mercedes';
    if (lower.contains('alonso') || lower.contains('stroll')) return 'Aston Martin';
    if (lower.contains('gasly') || lower.contains('colapinto') || lower.contains('doohan')) return 'Alpine';
    if (lower.contains('albon') || lower.contains('sainz')) return 'Williams';
    if (lower.contains('tsunoda') || lower.contains('lawson') || lower.contains('lindblad')) return 'Racing Bulls';
    if (lower.contains('bearman') || lower.contains('ocon')) return 'Haas';
    if (lower.contains('hulkenberg') || lower.contains('bortoleto')) return 'Audi';
    if (lower.contains('bottas') || lower.contains('perez')) return 'Cadillac';
    return 'Red Bull Racing';
  }
}
