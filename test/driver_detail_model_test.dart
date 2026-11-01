import 'package:flutter_test/flutter_test.dart';
import 'package:f1_app/features/driver/domain/driver_detail_model.dart';

void main() {
  test('DriverDetailModel serialization and deserialization', () {
    const model = DriverDetailModel(
      id: 'verstappen',
      firstName: 'Max',
      lastName: 'Verstappen',
      code: 'VER',
      permanentNumber: '3',
      teamName: 'Red Bull Racing',
      position: '4',
      points: '236',
      wins: 2,
      podiums: 12,
      poles: 5,
      dnfs: 1,
      dateOfBirth: '30.09.1997 (28)',
      nationality: 'Dutch',
      firstRace: '2015 Australian Grand Prix',
      firstWin: '2016 Spanish Grand Prix',
      worldChampionships: 4,
      roundPoints: [25, 18, 0, 15, null, 26],
      season: '2026',
    );

    final json = model.toJson();
    final restored = DriverDetailModel.fromJson(json);

    expect(restored.id, 'verstappen');
    expect(restored.firstName, 'Max');
    expect(restored.lastName, 'Verstappen');
    expect(restored.code, 'VER');
    expect(restored.points, '236');
    expect(restored.wins, 2);
    expect(restored.podiums, 12);
    expect(restored.poles, 5);
    expect(restored.dnfs, 1);
    expect(restored.worldChampionships, 4);
    expect(restored.roundPoints, [25, 18, 0, 15, null, 26]);
    expect(restored.season, '2026');
  });
}
