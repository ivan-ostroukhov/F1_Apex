import 'package:flutter/material.dart';
import 'team_utils.dart';

class F1Colors {
  static const List<Color> circuitPalette = [
    Color(0xFF0F5A28),
    Color(0xFF15448C),
    Color(0xFF7A1828),
    Color(0xFF0E7A6B),
    Color(0xFFB55A12),
    Color(0xFF5B2382),
    Color(0xFF1E3D59),
    Color(0xFF8B263E),
  ];

  static Color getCircuitColor(String key) {
    if (key.isEmpty) return circuitPalette.first;
    final lower = key.toLowerCase();

    if (lower.contains('sao_paulo') || lower.contains('brazil') || lower.contains('interlagos') || lower.contains('albert') || lower.contains('australia') || lower.contains('imola') || lower.contains('emilia') || lower.contains('spa') || lower.contains('belgium') || lower.contains('mexico') || lower.contains('rodriguez')) {
      return const Color(0xFF0F5A28);
    }
    if (lower.contains('vegas') || lower.contains('las_vegas') || lower.contains('miami') || lower.contains('austin') || lower.contains('cota') || lower.contains('americas') || lower.contains('usa') || lower.contains('austria') || lower.contains('red_bull_ring')) {
      return const Color(0xFF15448C);
    }
    if (lower.contains('qatar') || lower.contains('losail') || lower.contains('bahrain') || lower.contains('sakhir') || lower.contains('monza') || lower.contains('italy')) {
      return const Color(0xFF7A1828);
    }
    if (lower.contains('abu_dhabi') || lower.contains('yas_marina') || lower.contains('jeddah') || lower.contains('saudi') || lower.contains('baku') || lower.contains('azerbaijan')) {
      return const Color(0xFF0E7A6B);
    }
    if (lower.contains('suzuka') || lower.contains('japan') || lower.contains('canada') || lower.contains('montreal') || lower.contains('spain') || lower.contains('catalunya') || lower.contains('zandvoort') || lower.contains('dutch')) {
      return const Color(0xFFB55A12);
    }
    if (lower.contains('singapore') || lower.contains('marina_bay') || lower.contains('hungary') || lower.contains('hungaroring') || lower.contains('budapest')) {
      return const Color(0xFF5B2382);
    }
    if (lower.contains('silverstone') || lower.contains('britain') || lower.contains('british') || lower.contains('uk')) {
      return const Color(0xFF1E3D59);
    }
    if (lower.contains('shanghai') || lower.contains('china') || lower.contains('chinese') || lower.contains('monaco') || lower.contains('monte_carlo')) {
      return const Color(0xFF8B263E);
    }

    final hash = key.codeUnits.fold<int>(0, (acc, val) => acc + val);
    return circuitPalette[hash % circuitPalette.length];
  }

  static Color getTeamColor(String teamName, [String? fallbackDriverId]) {
    final cleaned = TeamUtils.cleanTeamName(teamName);
    var lower = cleaned.toLowerCase().replaceAll('_', ' ').replaceAll('-', ' ').trim();

    if (lower.contains('red bull') || lower.contains('redbull')) return const Color(0xFF3671C6);
    if (lower.contains('ferrari')) return const Color(0xFFE80020);
    if (lower.contains('mercedes')) return const Color(0xFF27F4D2);
    if (lower.contains('mclaren')) return const Color(0xFFFF8000);
    if (lower.contains('aston')) return const Color(0xFF229971);
    if (lower.contains('alpine')) return const Color(0xFFFF87BC);
    if (lower.contains('williams')) return const Color(0xFF64C4FF);
    if (lower.contains('haas')) return const Color(0xFFFF2A2A);
    if (lower.contains('audi')) return const Color(0xFFE20613);
    if (lower.contains('cadillac')) return const Color(0xFFE8A838);
    if (lower.contains('rb') ||
        lower.contains('racing bulls') ||
        lower.contains('vcarb') ||
        lower.contains('alphatauri') ||
        lower.contains('toro rosso')) {
      return const Color(0xFF6692FF);
    }
    if (lower.contains('sauber') || lower.contains('kick') || lower.contains('stake')) {
      return const Color(0xFF52E252);
    }

    final driverId = fallbackDriverId ?? (teamName.contains('_') ? teamName : null);
    if (driverId != null && driverId.isNotEmpty) {
      final defaultTeam = TeamUtils.getDefaultTeamForDriver(driverId);
      final defaultLower = defaultTeam.toLowerCase();
      if (defaultLower.contains('red bull')) return const Color(0xFF3671C6);
      if (defaultLower.contains('ferrari')) return const Color(0xFFE80020);
      if (defaultLower.contains('mercedes')) return const Color(0xFF27F4D2);
      if (defaultLower.contains('mclaren')) return const Color(0xFFFF8000);
      if (defaultLower.contains('aston')) return const Color(0xFF229971);
      if (defaultLower.contains('alpine')) return const Color(0xFFFF87BC);
      if (defaultLower.contains('williams')) return const Color(0xFF64C4FF);
      if (defaultLower.contains('haas')) return const Color(0xFFFF2B2B);
      if (defaultLower.contains('audi')) return const Color(0xFFE20613);
      if (defaultLower.contains('cadillac')) return const Color(0xFFE8A838);
      if (defaultLower.contains('racing bulls')) return const Color(0xFF6692FF);
      if (defaultLower.contains('sauber')) return const Color(0xFF52E252);
    }

    return Colors.white54;
  }
}