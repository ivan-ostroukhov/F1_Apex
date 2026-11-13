import 'package:json_annotation/json_annotation.dart';

part 'driver_dto.g.dart';

@JsonSerializable(createToJson: false)
class ErgastStandingsResponseDto {
  @JsonKey(name: 'MRData')
  final MrDataDto mrData;

  const ErgastStandingsResponseDto({required this.mrData});

  factory ErgastStandingsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ErgastStandingsResponseDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MrDataDto {
  @JsonKey(name: 'StandingsTable')
  final StandingsTableDto standingsTable;

  const MrDataDto({required this.standingsTable});

  factory MrDataDto.fromJson(Map<String, dynamic> json) =>
      _$MrDataDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class StandingsTableDto {
  @JsonKey(name: 'StandingsLists')
  final List<StandingsListDto> standingsLists;

  const StandingsTableDto({required this.standingsLists});

  factory StandingsTableDto.fromJson(Map<String, dynamic> json) =>
      _$StandingsTableDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class StandingsListDto {
  @JsonKey(name: 'DriverStandings')
  final List<DriverStandingDto> driverStandings;

  const StandingsListDto({required this.driverStandings});

  factory StandingsListDto.fromJson(Map<String, dynamic> json) =>
      _$StandingsListDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class DriverStandingDto {
  final String points;
  final String? position;
  final String? wins;
  @JsonKey(name: 'Driver')
  final DriverInfoDto driver;
  @JsonKey(name: 'Constructors')
  final List<ConstructorDto> constructors;

  const DriverStandingDto({
    required this.points,
    this.position,
    this.wins,
    required this.driver,
    required this.constructors,
  });

  factory DriverStandingDto.fromJson(Map<String, dynamic> json) =>
      _$DriverStandingDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class DriverInfoDto {
  final String driverId;
  final String? permanentNumber;
  final String givenName;
  final String familyName;
  final String? nationality;

  const DriverInfoDto({
    required this.driverId,
    this.permanentNumber,
    required this.givenName,
    required this.familyName,
    this.nationality,
  });

  factory DriverInfoDto.fromJson(Map<String, dynamic> json) =>
      _$DriverInfoDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class ConstructorDto {
  final String constructorId;
  final String name;

  const ConstructorDto({
    required this.constructorId,
    required this.name,
  });

  factory ConstructorDto.fromJson(Map<String, dynamic> json) =>
      _$ConstructorDtoFromJson(json);
}