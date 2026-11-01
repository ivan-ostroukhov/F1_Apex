import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1_app/common/localization/generated/app_localizations.dart';

void main() {
  testWidgets('AppLocalizations provides correct RU and EN strings for Home screen', (tester) async {
    late AppLocalizations ruL10n;
    late AppLocalizations enL10n;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            ruL10n = AppLocalizations.of(context)!;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(ruL10n.driverPositionShort, 'поз');
    expect(ruL10n.winsLabel, 'Победы');
    expect(ruL10n.driverPointsShort, 'блв');
    expect(ruL10n.grandPrixCompleted, 'Гран-при завершено');
    expect(ruL10n.distanceCovered, 'Пройдено');
    expect(ruL10n.lapsCompleted, 'Пройдено кругов');
    expect(ruL10n.breakingNews, 'Срочные новости');
    expect(ruL10n.viewAllNews, 'Посмотреть все >');
    expect(ruL10n.mexicoGrandPrixTitle, 'R19 Гран-при Мехико');
    expect(ruL10n.lapsCount, 'Количество кругов');
    expect(ruL10n.maxSpeed, 'Максимальная скорость');
    expect(ruL10n.turnsCount, 'Количество поворотов');
    expect(ruL10n.elevationChange, 'Перепад высот');
    expect(ruL10n.mostSuccessfulConstructor, 'Самая успешная команда-конструктор');
    expect(ruL10n.recordWinsFormat('04'), '04 ПОБЕДЫ');
    expect(ruL10n.mostSuccessfulDrivers, 'Самые успешные пилоты');
    expect(ruL10n.raceLapRecord, 'Рекорд круга гонки');
    expect(ruL10n.fastestPitStop, 'Самый быстрый пит-стоп сезона');
    expect(ruL10n.fastestLapSeason, 'Самый быстрый круг сезона');

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            enL10n = AppLocalizations.of(context)!;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(enL10n.driverPositionShort, 'pos');
    expect(enL10n.winsLabel, 'Wins');
    expect(enL10n.driverPointsShort, 'pts');
    expect(enL10n.grandPrixCompleted, 'Grand Prix completed');
    expect(enL10n.distanceCovered, 'Distance covered');
    expect(enL10n.lapsCompleted, 'Laps completed');
    expect(enL10n.breakingNews, 'Breaking News');
    expect(enL10n.viewAllNews, 'View all >');
    expect(enL10n.mexicoGrandPrixTitle, 'R19 Mexico City Grand Prix');
    expect(enL10n.lapsCount, 'Number of laps');
    expect(enL10n.maxSpeed, 'Top speed');
    expect(enL10n.turnsCount, 'Number of turns');
    expect(enL10n.elevationChange, 'Elevation change');
    expect(enL10n.mostSuccessfulConstructor, 'Most successful constructor');
    expect(enL10n.recordWinsFormat('04'), '04 WINS');
    expect(enL10n.mostSuccessfulDrivers, 'Most successful drivers');
    expect(enL10n.raceLapRecord, 'Race lap record');
    expect(enL10n.fastestPitStop, 'Fastest pit stop of the season');
    expect(enL10n.fastestLapSeason, 'Fastest lap of the season');
  });
}
