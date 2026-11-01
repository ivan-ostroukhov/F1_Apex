// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Apex';

  @override
  String get searchPlaceholder => 'Search driver or team...';

  @override
  String get points => 'PTS';

  @override
  String get teammate => 'Teammate';

  @override
  String get viewTeammate => 'View teammate profile';

  @override
  String get notFoundTitle => 'No drivers found';

  @override
  String get notFoundSubtitle => 'Try another query';

  @override
  String get errorLoading => 'Failed to load data from network';

  @override
  String get retry => 'Retry';

  @override
  String get driversTab => 'Drivers';

  @override
  String get homeTab => 'Main';

  @override
  String get constructorsTab => 'Constructors';

  @override
  String get constructorsTable => 'Constructors Standings';

  @override
  String get constructorsComingSoon => 'Constructors championship coming soon';

  @override
  String get scheduleTab => 'Schedule';

  @override
  String get roundPrefix => 'Round';

  @override
  String get raceCompleted => 'Finished';

  @override
  String get raceUpcoming => 'Upcoming';

  @override
  String get driverPositionShort => 'pos';

  @override
  String get driverPointsShort => 'pts';

  @override
  String get winsLabel => 'Wins';

  @override
  String get podiumsLabel => 'Podiums';

  @override
  String get polesLabel => 'Poles';

  @override
  String get dnfsLabel => 'DNFs';

  @override
  String seasonPrefix(String year) {
    return 'Season $year';
  }

  @override
  String get selectSeason => 'Select Season';

  @override
  String sinceDebut(String year) {
    return 'Since Debut ($year)';
  }

  @override
  String get driverCodeLabel => 'Driver Code';

  @override
  String get teamLabel => 'Team';

  @override
  String get firstRaceLabel => 'First Entry';

  @override
  String get firstWinLabel => 'First Win';

  @override
  String get worldChampionshipsLabel => 'World Championships';

  @override
  String get dateOfBirthLabel => 'Date of Birth';

  @override
  String get countryLabel => 'Country';

  @override
  String get chassisLabel => 'Chassis';

  @override
  String get engineLabel => 'Engine';

  @override
  String get teamPrincipalLabel => 'Team Principal';

  @override
  String get constructorsChampionshipsLabel => 'Constructors Championships';

  @override
  String get driversChampionshipsLabel => 'Drivers Championships';

  @override
  String get baseLabel => 'Base';

  @override
  String get headToHeadSubtitle =>
      'Select a driver to compare season or career stats for a more interesting comparison.';

  @override
  String get pastRaces => 'Past Races';

  @override
  String get upcomingRaces => 'Upcoming Races';

  @override
  String get raceCountdownPrefix => 'Race starts in';

  @override
  String get daysShort => 'Days';

  @override
  String get hoursShort => 'Hours';

  @override
  String get minutesShort => 'Mins';

  @override
  String get scheduleButton => 'Schedule';

  @override
  String get resultsButton => 'Results';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get generalSection => 'General';

  @override
  String get favoritesSection => 'Favorites';

  @override
  String get notifications => 'Notifications';

  @override
  String get appTheme => 'App Theme';

  @override
  String get unitSystem => 'Unit System';

  @override
  String get timeFormat24 => '24-Hour Time';

  @override
  String get detailedResults => 'Detailed Results';

  @override
  String get language => 'Language';

  @override
  String get selectDriver => 'Select Driver';

  @override
  String get selectTeam => 'Select Team';

  @override
  String get searchDriver => 'Search driver';

  @override
  String get searchTeam => 'Search group';

  @override
  String get cancel => 'Cancel';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get metricUnits => 'Metric';

  @override
  String get grandPrixCompleted => 'Grand Prix completed';

  @override
  String get distanceCovered => 'Distance covered';

  @override
  String get lapsCompleted => 'Laps completed';

  @override
  String get breakingNews => 'Breaking News';

  @override
  String get viewAllNews => 'View all >';

  @override
  String get mexicoGrandPrixTitle => 'R19 Mexico City Grand Prix';

  @override
  String get lapsCount => 'Number of laps';

  @override
  String get maxSpeed => 'Top speed';

  @override
  String get turnsCount => 'Number of turns';

  @override
  String get elevationChange => 'Elevation change';

  @override
  String get mostSuccessfulConstructor => 'Most successful constructor';

  @override
  String recordWinsFormat(String count) {
    return '$count WINS';
  }

  @override
  String get mostSuccessfulDrivers => 'Most successful drivers';

  @override
  String get raceLapRecord => 'Race lap record';

  @override
  String get fastestPitStop => 'Fastest pit stop of the season';

  @override
  String get fastestLapSeason => 'Fastest lap of the season';

  @override
  String get mexicoDateRange => 'Oct 31 - Nov 02';

  @override
  String get mexicoSessionDate => '31 SAT';

  @override
  String get mexicoSessionTitle => 'Practice 1';
}
