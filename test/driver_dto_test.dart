import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:f1_app/features/driver/data/dto/driver_dto.dart';

void main() {
  test('parsing standings response with missing optional driver fields like nationality', () {
    const rawJson = '''
{
  "MRData": {
    "StandingsTable": {
      "StandingsLists": [
        {
          "DriverStandings": [
            {
              "position": "24",
              "points": "0",
              "wins": "0",
              "Driver": {
                "driverId": "ryo_hirakawa",
                "givenName": "Ryo",
                "familyName": "Hirakawa"
              },
              "Constructors": [
                {
                  "constructorId": "haas",
                  "name": "Haas F1 Team"
                }
              ]
            }
          ]
        }
      ]
    }
  }
}
''';

    final jsonMap = jsonDecode(rawJson) as Map<String, dynamic>;
    final result = ErgastStandingsResponseDto.fromJson(jsonMap);
    final standings = result.mrData.standingsTable.standingsLists.first.driverStandings;

    expect(standings.length, 1);
    expect(standings.first.driver.driverId, 'ryo_hirakawa');
    expect(standings.first.driver.nationality, '');
    expect(standings.first.constructors.first.name, 'Haas F1 Team');
  });
}
