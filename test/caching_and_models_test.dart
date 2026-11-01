import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1_app/features/driver/domain/driver_detail_model.dart';
import 'package:f1_app/features/constructor/domain/constructor_detail_model.dart';

void main() {
  test('DriverDetailModel serialization roundtrip', () {
    const model = DriverDetailModel(
      id: 'max_verstappen',
      firstName: 'Max',
      lastName: 'Verstappen',
      code: 'VER',
      permanentNumber: '3',
      teamName: 'Red Bull Racing',
      position: '4',
      points: '236',
      wins: 2,
      podiums: 10,
      poles: 2,
      dnfs: 4,
      dateOfBirth: '30.09.1997 (28)',
      nationality: 'Dutch',
      firstRace: '2015 Australian Grand Prix',
      firstWin: '2016 Spanish Grand Prix',
      worldChampionships: 4,
      roundPoints: [8, 0, 4, 10, 15, 0, 12, 18, 0, 15, 18, 0, 15, 18, 18, 25, 25, 15],
      season: '2026',
    );

    final json = model.toJson();
    final deserialized = DriverDetailModel.fromJson(json);

    expect(deserialized.id, equals('max_verstappen'));
    expect(deserialized.points, equals('236'));
    expect(deserialized.wins, equals(2));
    expect(deserialized.roundPoints.length, equals(18));
    expect(deserialized.roundPoints.first, equals(8));
    expect(deserialized.roundPoints.last, equals(15));
  });

  test('ConstructorDetailModel serialization roundtrip', () {
    const model = ConstructorDetailModel(
      id: 'red_bull',
      name: 'Red Bull Racing',
      chassis: 'RB22',
      engine: 'Honda RBPT',
      teamPrincipal: 'Christian Horner',
      firstRace: '2005 Australian Grand Prix',
      constructorsTitles: 6,
      driversTitles: 7,
      baseLocation: 'Milton Keynes, United Kingdom',
      position: '3',
      points: '355',
      wins: 2,
      podiums: 10,
      poles: 2,
      dnfs: 4,
      season: '2026',
      carAssetPath: 'assets/images/red_bull.png',
      drivers: [
        ConstructorDriverModel(id: 'max_verstappen', permanentNumber: '3', code: 'VER', name: 'Max Verstappen'),
      ],
    );

    final json = model.toJson();
    final deserialized = ConstructorDetailModel.fromJson(json);

    expect(deserialized.id, equals('red_bull'));
    expect(deserialized.points, equals('355'));
    expect(deserialized.wins, equals(2));
    expect(deserialized.drivers.length, equals(1));
    expect(deserialized.drivers.first.name, equals('Max Verstappen'));
  });

  test('f1_history.json is valid and contains required sections', () {
    final file = File('assets/data/f1_history.json');
    expect(file.existsSync(), isTrue);

    final content = file.readAsStringSync();
    final data = jsonDecode(content) as Map<String, dynamic>;

    expect(data.containsKey('podiums'), isTrue);
    expect(data.containsKey('driver_milestones'), isTrue);
    expect(data.containsKey('driver_seasons'), isTrue);
    expect(data.containsKey('driver_details'), isTrue);
    expect(data.containsKey('constructor_details'), isTrue);

    final milestones = data['driver_milestones'] as Map<String, dynamic>;
    expect(milestones.containsKey('verstappen'), isTrue);
    expect(milestones.containsKey('max_verstappen'), isTrue);
    expect(milestones.containsKey('leclerc'), isTrue);
    expect(milestones.containsKey('piastri'), isTrue);

    final details = data['driver_details'] as Map<String, dynamic>;
    expect(details.containsKey('max_verstappen_2026'), isTrue);
    expect(details['max_verstappen_2026']['points'], equals('236'));
    expect(details['max_verstappen_2026']['position'], equals('4'));
  });
}
