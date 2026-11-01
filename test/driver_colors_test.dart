import 'package:f1_app/common/utils/f1_colors.dart';
import 'package:f1_app/common/utils/team_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('verify F1Colors.getTeamColor for all 2026 constructors and drivers', () {
    // Red Bull (Blue)
    expect(F1Colors.getTeamColor('Red Bull Racing'), const Color(0xFF3671C6));
    expect(F1Colors.getTeamColor('red_bull'), const Color(0xFF3671C6));
    expect(F1Colors.getTeamColor('', 'max_verstappen'), const Color(0xFF3671C6));
    expect(F1Colors.getTeamColor('', 'verstappen'), const Color(0xFF3671C6));

    // Ferrari (Red)
    expect(F1Colors.getTeamColor('Ferrari'), const Color(0xFFE80020));
    expect(F1Colors.getTeamColor('ferrari'), const Color(0xFFE80020));
    expect(F1Colors.getTeamColor('', 'leclerc'), const Color(0xFFE80020));
    expect(F1Colors.getTeamColor('', 'hamilton'), const Color(0xFFE80020));

    // Mercedes (Cyan)
    expect(F1Colors.getTeamColor('Mercedes'), const Color(0xFF27F4D2));
    expect(F1Colors.getTeamColor('mercedes'), const Color(0xFF27F4D2));
    expect(F1Colors.getTeamColor('', 'russell'), const Color(0xFF27F4D2));
    expect(F1Colors.getTeamColor('', 'antonelli'), const Color(0xFF27F4D2));

    // McLaren (Papaya)
    expect(F1Colors.getTeamColor('McLaren'), const Color(0xFFFF8000));
    expect(F1Colors.getTeamColor('mclaren'), const Color(0xFFFF8000));
    expect(F1Colors.getTeamColor('', 'norris'), const Color(0xFFFF8000));
    expect(F1Colors.getTeamColor('', 'piastri'), const Color(0xFFFF8000));

    // Aston Martin (Green)
    expect(F1Colors.getTeamColor('Aston Martin'), const Color(0xFF229971));
    expect(F1Colors.getTeamColor('aston_martin'), const Color(0xFF229971));
    expect(F1Colors.getTeamColor('', 'alonso'), const Color(0xFF229971));

    // Alpine (Pink)
    expect(F1Colors.getTeamColor('Alpine'), const Color(0xFFFF87BC));
    expect(F1Colors.getTeamColor('alpine'), const Color(0xFFFF87BC));
    expect(F1Colors.getTeamColor('', 'gasly'), const Color(0xFFFF87BC));

    // Williams (Blue)
    expect(F1Colors.getTeamColor('Williams'), const Color(0xFF64C4FF));
    expect(F1Colors.getTeamColor('williams'), const Color(0xFF64C4FF));
    expect(F1Colors.getTeamColor('', 'albon'), const Color(0xFF64C4FF));
    expect(F1Colors.getTeamColor('', 'sainz'), const Color(0xFF64C4FF));

    // Racing Bulls (Blue)
    expect(F1Colors.getTeamColor('Racing Bulls'), const Color(0xFF6692FF));
    expect(F1Colors.getTeamColor('racing_bulls'), const Color(0xFF6692FF));
    expect(F1Colors.getTeamColor('rb'), const Color(0xFF6692FF));
    expect(F1Colors.getTeamColor('toro rosso'), const Color(0xFF6692FF));
    expect(F1Colors.getTeamColor('', 'tsunoda'), const Color(0xFF6692FF));

    // Haas (Gray)
    expect(F1Colors.getTeamColor('Haas'), const Color(0xFFB6BABD));
    expect(F1Colors.getTeamColor('haas'), const Color(0xFFB6BABD));
    expect(F1Colors.getTeamColor('', 'bearman'), const Color(0xFFB6BABD));

    // Audi (Red)
    expect(F1Colors.getTeamColor('Audi'), const Color(0xFFE20613));
    expect(F1Colors.getTeamColor('audi'), const Color(0xFFE20613));
    expect(F1Colors.getTeamColor('', 'hulkenberg'), const Color(0xFFE20613));

    // Cadillac (Gold)
    expect(F1Colors.getTeamColor('Cadillac'), const Color(0xFFE8A838));
    expect(F1Colors.getTeamColor('cadillac'), const Color(0xFFE8A838));
    expect(F1Colors.getTeamColor('', 'bottas'), const Color(0xFFE8A838));

    // Sauber (Green)
    expect(F1Colors.getTeamColor('Sauber'), const Color(0xFF52E252));
    expect(F1Colors.getTeamColor('kick_sauber'), const Color(0xFF52E252));
  });

  test('verify TeamUtils.getDefaultTeamForDriver', () {
    expect(TeamUtils.getDefaultTeamForDriver('max_verstappen'), 'Red Bull Racing');
    expect(TeamUtils.getDefaultTeamForDriver('verstappen'), 'Red Bull Racing');
    expect(TeamUtils.getDefaultTeamForDriver('leclerc'), 'Ferrari');
    expect(TeamUtils.getDefaultTeamForDriver('hamilton'), 'Ferrari');
    expect(TeamUtils.getDefaultTeamForDriver('sainz'), 'Williams');
    expect(TeamUtils.getDefaultTeamForDriver('hulkenberg'), 'Audi');
    expect(TeamUtils.getDefaultTeamForDriver('bottas'), 'Cadillac');
  });
}
