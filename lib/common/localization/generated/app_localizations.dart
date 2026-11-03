import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Apex'**
  String get appTitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search driver or team...'**
  String get searchPlaceholder;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'PTS'**
  String get points;

  /// No description provided for @teammate.
  ///
  /// In en, this message translates to:
  /// **'Teammate'**
  String get teammate;

  /// No description provided for @viewTeammate.
  ///
  /// In en, this message translates to:
  /// **'View teammate profile'**
  String get viewTeammate;

  /// No description provided for @notFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'No drivers found'**
  String get notFoundTitle;

  /// No description provided for @notFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try another query'**
  String get notFoundSubtitle;

  /// No description provided for @errorLoading.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data from network'**
  String get errorLoading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @driversTab.
  ///
  /// In en, this message translates to:
  /// **'Drivers'**
  String get driversTab;

  /// No description provided for @homeTab.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get homeTab;

  /// No description provided for @constructorsTab.
  ///
  /// In en, this message translates to:
  /// **'Constructors'**
  String get constructorsTab;

  /// No description provided for @constructorsTable.
  ///
  /// In en, this message translates to:
  /// **'Constructors Standings'**
  String get constructorsTable;

  /// No description provided for @driversTable.
  ///
  /// In en, this message translates to:
  /// **'Drivers Standings'**
  String get driversTable;

  /// No description provided for @constructorsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Constructors championship coming soon'**
  String get constructorsComingSoon;

  /// No description provided for @scheduleTab.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleTab;

  /// No description provided for @roundPrefix.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get roundPrefix;

  /// No description provided for @raceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get raceCompleted;

  /// No description provided for @raceUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get raceUpcoming;

  /// No description provided for @driverPositionShort.
  ///
  /// In en, this message translates to:
  /// **'pos'**
  String get driverPositionShort;

  /// No description provided for @driverPointsShort.
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get driverPointsShort;

  /// No description provided for @winsLabel.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get winsLabel;

  /// No description provided for @podiumsLabel.
  ///
  /// In en, this message translates to:
  /// **'Podiums'**
  String get podiumsLabel;

  /// No description provided for @polesLabel.
  ///
  /// In en, this message translates to:
  /// **'Poles'**
  String get polesLabel;

  /// No description provided for @dnfsLabel.
  ///
  /// In en, this message translates to:
  /// **'DNFs'**
  String get dnfsLabel;

  /// No description provided for @seasonPrefix.
  ///
  /// In en, this message translates to:
  /// **'Season {year}'**
  String seasonPrefix(String year);

  /// No description provided for @selectSeason.
  ///
  /// In en, this message translates to:
  /// **'Select Season'**
  String get selectSeason;

  /// No description provided for @sinceDebut.
  ///
  /// In en, this message translates to:
  /// **'Since Debut ({year})'**
  String sinceDebut(String year);

  /// No description provided for @driverCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Driver Code'**
  String get driverCodeLabel;

  /// No description provided for @teamLabel.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get teamLabel;

  /// No description provided for @firstRaceLabel.
  ///
  /// In en, this message translates to:
  /// **'First Entry'**
  String get firstRaceLabel;

  /// No description provided for @firstWinLabel.
  ///
  /// In en, this message translates to:
  /// **'First Win'**
  String get firstWinLabel;

  /// No description provided for @worldChampionshipsLabel.
  ///
  /// In en, this message translates to:
  /// **'World Championships'**
  String get worldChampionshipsLabel;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// No description provided for @countryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// No description provided for @chassisLabel.
  ///
  /// In en, this message translates to:
  /// **'Chassis'**
  String get chassisLabel;

  /// No description provided for @engineLabel.
  ///
  /// In en, this message translates to:
  /// **'Engine'**
  String get engineLabel;

  /// No description provided for @teamPrincipalLabel.
  ///
  /// In en, this message translates to:
  /// **'Team Principal'**
  String get teamPrincipalLabel;

  /// No description provided for @constructorsChampionshipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Constructors Championships'**
  String get constructorsChampionshipsLabel;

  /// No description provided for @driversChampionshipsLabel.
  ///
  /// In en, this message translates to:
  /// **'Drivers Championships'**
  String get driversChampionshipsLabel;

  /// No description provided for @baseLabel.
  ///
  /// In en, this message translates to:
  /// **'Base'**
  String get baseLabel;

  /// No description provided for @headToHeadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select a driver to compare season or career stats for a more interesting comparison.'**
  String get headToHeadSubtitle;

  /// No description provided for @pastRaces.
  ///
  /// In en, this message translates to:
  /// **'Past Races'**
  String get pastRaces;

  /// No description provided for @upcomingRaces.
  ///
  /// In en, this message translates to:
  /// **'Upcoming Races'**
  String get upcomingRaces;

  /// No description provided for @raceCountdownPrefix.
  ///
  /// In en, this message translates to:
  /// **'Race starts in'**
  String get raceCountdownPrefix;

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get daysShort;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hoursShort;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'Mins'**
  String get minutesShort;

  /// No description provided for @scheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleButton;

  /// No description provided for @resultsButton.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsButton;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @generalSection.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSection;

  /// No description provided for @favoritesSection.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesSection;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @unitSystem.
  ///
  /// In en, this message translates to:
  /// **'Unit System'**
  String get unitSystem;

  /// No description provided for @timeFormat24.
  ///
  /// In en, this message translates to:
  /// **'24-Hour Time'**
  String get timeFormat24;

  /// No description provided for @detailedResults.
  ///
  /// In en, this message translates to:
  /// **'Detailed Results'**
  String get detailedResults;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectDriver.
  ///
  /// In en, this message translates to:
  /// **'Select Driver'**
  String get selectDriver;

  /// No description provided for @selectTeam.
  ///
  /// In en, this message translates to:
  /// **'Select Team'**
  String get selectTeam;

  /// No description provided for @searchDriver.
  ///
  /// In en, this message translates to:
  /// **'Search driver'**
  String get searchDriver;

  /// No description provided for @searchTeam.
  ///
  /// In en, this message translates to:
  /// **'Search group'**
  String get searchTeam;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @metricUnits.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metricUnits;

  /// No description provided for @grandPrixCompleted.
  ///
  /// In en, this message translates to:
  /// **'Grand Prix completed'**
  String get grandPrixCompleted;

  /// No description provided for @distanceCovered.
  ///
  /// In en, this message translates to:
  /// **'Distance covered'**
  String get distanceCovered;

  /// No description provided for @lapsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Laps completed'**
  String get lapsCompleted;

  /// No description provided for @breakingNews.
  ///
  /// In en, this message translates to:
  /// **'Breaking News'**
  String get breakingNews;

  /// No description provided for @viewAllNews.
  ///
  /// In en, this message translates to:
  /// **'View all >'**
  String get viewAllNews;

  /// No description provided for @mexicoGrandPrixTitle.
  ///
  /// In en, this message translates to:
  /// **'R19 Mexico City Grand Prix'**
  String get mexicoGrandPrixTitle;

  /// No description provided for @lapsCount.
  ///
  /// In en, this message translates to:
  /// **'Number of laps'**
  String get lapsCount;

  /// No description provided for @maxSpeed.
  ///
  /// In en, this message translates to:
  /// **'Top speed'**
  String get maxSpeed;

  /// No description provided for @turnsCount.
  ///
  /// In en, this message translates to:
  /// **'Number of turns'**
  String get turnsCount;

  /// No description provided for @elevationChange.
  ///
  /// In en, this message translates to:
  /// **'Elevation change'**
  String get elevationChange;

  /// No description provided for @mostSuccessfulConstructor.
  ///
  /// In en, this message translates to:
  /// **'Most successful constructor'**
  String get mostSuccessfulConstructor;

  /// No description provided for @recordWinsFormat.
  ///
  /// In en, this message translates to:
  /// **'{count} WINS'**
  String recordWinsFormat(String count);

  /// No description provided for @mostSuccessfulDrivers.
  ///
  /// In en, this message translates to:
  /// **'Most successful drivers'**
  String get mostSuccessfulDrivers;

  /// No description provided for @raceLapRecord.
  ///
  /// In en, this message translates to:
  /// **'Race lap record'**
  String get raceLapRecord;

  /// No description provided for @fastestPitStop.
  ///
  /// In en, this message translates to:
  /// **'Fastest pit stop of the season'**
  String get fastestPitStop;

  /// No description provided for @fastestLapSeason.
  ///
  /// In en, this message translates to:
  /// **'Fastest lap of the season'**
  String get fastestLapSeason;

  /// No description provided for @mexicoDateRange.
  ///
  /// In en, this message translates to:
  /// **'Oct 31 - Nov 02'**
  String get mexicoDateRange;

  /// No description provided for @mexicoSessionDate.
  ///
  /// In en, this message translates to:
  /// **'31 SAT'**
  String get mexicoSessionDate;

  /// No description provided for @mexicoSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Practice 1'**
  String get mexicoSessionTitle;

  /// No description provided for @noPointsData.
  ///
  /// In en, this message translates to:
  /// **'No points data for the current season'**
  String get noPointsData;

  /// No description provided for @roundFormat.
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String roundFormat(String number);

  /// No description provided for @kmUnit.
  ///
  /// In en, this message translates to:
  /// **'KM'**
  String get kmUnit;

  /// No description provided for @kmhUnit.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get kmhUnit;

  /// No description provided for @mUnit.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get mUnit;

  /// No description provided for @topSpeed.
  ///
  /// In en, this message translates to:
  /// **'Top speed'**
  String get topSpeed;

  /// No description provided for @turns.
  ///
  /// In en, this message translates to:
  /// **'Turns'**
  String get turns;

  /// No description provided for @elevationChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Elevation change'**
  String get elevationChangeLabel;

  /// No description provided for @lapsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'Number of laps'**
  String get lapsCountLabel;

  /// No description provided for @weekendSessions.
  ///
  /// In en, this message translates to:
  /// **'Weekend Sessions'**
  String get weekendSessions;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
