// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErgastStandingsResponseDto _$ErgastStandingsResponseDtoFromJson(
        Map<String, dynamic> json) =>
    ErgastStandingsResponseDto(
      mrData: MrDataDto.fromJson(json['MRData'] as Map<String, dynamic>),
    );

MrDataDto _$MrDataDtoFromJson(Map<String, dynamic> json) => MrDataDto(
      standingsTable: StandingsTableDto.fromJson(
          json['StandingsTable'] as Map<String, dynamic>),
    );

StandingsTableDto _$StandingsTableDtoFromJson(Map<String, dynamic> json) =>
    StandingsTableDto(
      standingsLists: (json['StandingsLists'] as List<dynamic>)
          .map((e) => StandingsListDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

StandingsListDto _$StandingsListDtoFromJson(Map<String, dynamic> json) =>
    StandingsListDto(
      driverStandings: (json['DriverStandings'] as List<dynamic>)
          .map((e) => DriverStandingDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

DriverStandingDto _$DriverStandingDtoFromJson(Map<String, dynamic> json) =>
    DriverStandingDto(
      points: json['points'] as String,
      position: json['position'] as String?,
      wins: json['wins'] as String?,
      driver: DriverInfoDto.fromJson(json['Driver'] as Map<String, dynamic>),
      constructors: (json['Constructors'] as List<dynamic>)
          .map((e) => ConstructorDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

DriverInfoDto _$DriverInfoDtoFromJson(Map<String, dynamic> json) =>
    DriverInfoDto(
      driverId: json['driverId'] as String,
      permanentNumber: json['permanentNumber'] as String?,
      givenName: json['givenName'] as String,
      familyName: json['familyName'] as String,
      nationality: json['nationality'] as String?,
    );

ConstructorDto _$ConstructorDtoFromJson(Map<String, dynamic> json) =>
    ConstructorDto(
      constructorId: json['constructorId'] as String,
      name: json['name'] as String,
    );
