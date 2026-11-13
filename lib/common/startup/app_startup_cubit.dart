import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/driver/domain/i_driver_repository.dart';
import '../../features/driver/domain/driver_detail_model.dart';
import '../../features/constructor/domain/constructor_repository.dart';
import '../../features/constructor/domain/constructor_detail_model.dart';
import '../../features/schedule/data/repositories/schedule_repository.dart'
    as schedule_impl;
import '../../features/schedule/domain/models/race_model.dart';
import '../../features/home/data/home_repository.dart';
import '../../features/home/domain/home_news_model.dart';
import '../network/local_storage_service.dart';
import '../utils/team_utils.dart';

class AppStartupState {
  final bool isLoading;
  final DriverDetailModel? driver1Detail;
  final DriverDetailModel? driver2Detail;
  final ConstructorDetailModel? teamDetail;
  final List<RaceModel> seasonSchedule;
  final RaceModel? nextRace;
  final List<HomeNewsModel> newsRu;
  final List<HomeNewsModel> newsEn;
  final String favDriver1;
  final String favDriver2;
  final String favTeam;

  const AppStartupState({
    this.isLoading = true,
    this.driver1Detail,
    this.driver2Detail,
    this.teamDetail,
    this.seasonSchedule = const [],
    this.nextRace,
    this.newsRu = const [],
    this.newsEn = const [],
    this.favDriver1 = 'verstappen',
    this.favDriver2 = 'piastri',
    this.favTeam = 'red_bull',
  });

  bool get isDone => !isLoading;

  AppStartupState copyWith({
    bool? isLoading,
    DriverDetailModel? driver1Detail,
    DriverDetailModel? driver2Detail,
    ConstructorDetailModel? teamDetail,
    List<RaceModel>? seasonSchedule,
    RaceModel? nextRace,
    List<HomeNewsModel>? newsRu,
    List<HomeNewsModel>? newsEn,
    String? favDriver1,
    String? favDriver2,
    String? favTeam,
  }) {
    return AppStartupState(
      isLoading: isLoading ?? this.isLoading,
      driver1Detail: driver1Detail ?? this.driver1Detail,
      driver2Detail: driver2Detail ?? this.driver2Detail,
      teamDetail: teamDetail ?? this.teamDetail,
      seasonSchedule: seasonSchedule ?? this.seasonSchedule,
      nextRace: nextRace ?? this.nextRace,
      newsRu: newsRu ?? this.newsRu,
      newsEn: newsEn ?? this.newsEn,
      favDriver1: favDriver1 ?? this.favDriver1,
      favDriver2: favDriver2 ?? this.favDriver2,
      favTeam: favTeam ?? this.favTeam,
    );
  }
}

class AppStartupCubit extends Cubit<AppStartupState> {
  final IDriverRepository _driverRepo;
  final IConstructorRepository _constructorRepo;

  AppStartupCubit({
    required IDriverRepository driverRepo,
    required IConstructorRepository constructorRepo,
  })  : _driverRepo = driverRepo,
        _constructorRepo = constructorRepo,
        super(const AppStartupState());

  Future<void> initialize() async {
    final d1 = LocalStorageService.getString('fav_driver_1') ?? 'verstappen';
    final d2 = LocalStorageService.getString('fav_driver_2') ?? 'piastri';
    final tm = LocalStorageService.getString('fav_team') ?? 'red_bull';

    emit(state.copyWith(
      favDriver1: d1,
      favDriver2: d2,
      favTeam: tm,
    ));

    final homeRepo = HomeRepository();
    final scheduleRepo = schedule_impl.ScheduleRepository();

    _loadNewsInBackground(homeRepo);

    await Future.wait<void>([
      _loadDriversAndTeam(d1, d2, tm),
      _loadSchedule(scheduleRepo),
    ]);

    if (isClosed) return;
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _loadDriversAndTeam(String d1, String d2, String tm) async {
    try {
      final results = await Future.wait([
        _driverRepo
            .getDriverDetails(d1)
            .then((res) => _validateDriver(res, d1))
            .catchError((_) => _fallbackDriverDetail(d1)),
        _driverRepo
            .getDriverDetails(d2)
            .then((res) => _validateDriver(res, d2))
            .catchError((_) => _fallbackDriverDetail(d2)),
        _constructorRepo
            .getConstructorDetails(tm)
            .then((res) => _validateTeam(res, tm))
            .catchError((_) => _fallbackTeamDetail(tm)),
      ]);
      if (isClosed) return;
      emit(state.copyWith(
        driver1Detail: results[0] as DriverDetailModel,
        driver2Detail: results[1] as DriverDetailModel,
        teamDetail: results[2] as ConstructorDetailModel,
      ));
    } catch (_) {}
  }

  Future<void> _loadSchedule(schedule_impl.ScheduleRepository repo) async {
    try {
      final schedule = await repo.getSeasonSchedule();
      if (isClosed) return;
      RaceModel? nextRace;
      if (schedule.isNotEmpty) {
        nextRace = schedule.where((r) => !r.isCompleted).firstOrNull ?? schedule.last;
      }
      emit(state.copyWith(
        seasonSchedule: schedule,
        nextRace: nextRace,
      ));
    } catch (_) {}
  }

  Future<void> _loadNewsInBackground(HomeRepository repo) async {
    try {
      final results = await Future.wait([
        repo.getLatestNews(isEnglish: false).catchError((_) => <HomeNewsModel>[]),
        repo.getLatestNews(isEnglish: true).catchError((_) => <HomeNewsModel>[]),
      ]);
      if (isClosed) return;
      emit(state.copyWith(
        newsRu: results[0],
        newsEn: results[1],
      ));
    } catch (_) {}
  }

  Future<void> refreshFavorites() async {
    final d1 = LocalStorageService.getString('fav_driver_1') ?? 'verstappen';
    final d2 = LocalStorageService.getString('fav_driver_2') ?? 'piastri';
    final tm = LocalStorageService.getString('fav_team') ?? 'red_bull';

    emit(state.copyWith(favDriver1: d1, favDriver2: d2, favTeam: tm));

    try {
      final results = await Future.wait([
        _driverRepo
            .getDriverDetails(d1)
            .then((res) => _validateDriver(res, d1))
            .catchError((_) => _fallbackDriverDetail(d1)),
        _driverRepo
            .getDriverDetails(d2)
            .then((res) => _validateDriver(res, d2))
            .catchError((_) => _fallbackDriverDetail(d2)),
        _constructorRepo
            .getConstructorDetails(tm)
            .then((res) => _validateTeam(res, tm))
            .catchError((_) => _fallbackTeamDetail(tm)),
      ]);
      if (isClosed) return;
      emit(state.copyWith(
        driver1Detail: results[0] as DriverDetailModel,
        driver2Detail: results[1] as DriverDetailModel,
        teamDetail: results[2] as ConstructorDetailModel,
      ));
    } catch (_) {}
  }

  DriverDetailModel _validateDriver(DriverDetailModel model, String id) {
    if (model.points != '0' || model.roundPoints.isNotEmpty) {
      return model;
    }
    return _fallbackDriverDetail(id);
  }

  ConstructorDetailModel _validateTeam(ConstructorDetailModel model, String id) {
    if (model.points != '0' || model.position != '0' || model.wins > 0) {
      return model;
    }
    return _fallbackTeamDetail(id);
  }

  (String, String) _getDefaultDriverName(String driverId) {
    final lower = driverId.toLowerCase().replaceAll('-', '_').trim();
    if (lower.contains('verstappen')) return ('Max', 'Verstappen');
    if (lower.contains('leclerc')) return ('Charles', 'Leclerc');
    if (lower.contains('hamilton')) return ('Lewis', 'Hamilton');
    if (lower.contains('norris')) return ('Lando', 'Norris');
    if (lower.contains('piastri')) return ('Oscar', 'Piastri');
    if (lower.contains('russell')) return ('George', 'Russell');
    if (lower.contains('antonelli')) return ('Kimi', 'Antonelli');
    if (lower.contains('alonso')) return ('Fernando', 'Alonso');
    if (lower.contains('stroll')) return ('Lance', 'Stroll');
    if (lower.contains('gasly')) return ('Pierre', 'Gasly');
    if (lower.contains('colapinto')) return ('Franco', 'Colapinto');
    if (lower.contains('albon')) return ('Alexander', 'Albon');
    if (lower.contains('sainz')) return ('Carlos', 'Sainz');
    if (lower.contains('tsunoda')) return ('Yuki', 'Tsunoda');
    if (lower.contains('lawson')) return ('Liam', 'Lawson');
    if (lower.contains('lindblad')) return ('Arvid', 'Lindblad');
    if (lower.contains('bearman')) return ('Oliver', 'Bearman');
    if (lower.contains('ocon')) return ('Esteban', 'Ocon');
    if (lower.contains('hulkenberg')) return ('Nico', 'Hulkenberg');
    if (lower.contains('bortoleto')) return ('Gabriel', 'Bortoleto');
    if (lower.contains('hadjar')) return ('Isack', 'Hadjar');
    if (lower.contains('bottas')) return ('Valtteri', 'Bottas');
    if (lower.contains('perez')) return ('Sergio', 'Perez');
    return (driverId.toUpperCase(), '');
  }

  DriverDetailModel _fallbackDriverDetail(String id) {
    final normId = id == 'verstappen' ? 'max_verstappen' : id;
    var cached = LocalStorageService.getString('driver_detail_${id}_2026');
    cached ??= LocalStorageService.getString('driver_detail_${normId}_2026');
    cached ??= LocalStorageService.getString('driver_detail_$id');
    cached ??= LocalStorageService.getString('driver_detail_$normId');

    if (cached != null && cached.isNotEmpty) {
      try {
        final model = DriverDetailModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        if (model.points != '0' || model.roundPoints.isNotEmpty) {
          return model;
        }
      } catch (_) {}
    }

    final name = _getDefaultDriverName(id);
    final stats = TeamUtils.getDefaultDriverStats(id);

    return DriverDetailModel(
      id: id,
      firstName: name.$1,
      lastName: name.$2,
      code: id.length >= 3 ? id.substring(0, 3).toUpperCase() : id.toUpperCase(),
      permanentNumber: stats.permanentNumber,
      teamName: TeamUtils.getDefaultTeamForDriver(id),
      position: stats.pos,
      points: stats.pts,
      wins: stats.wins,
      podiums: stats.podiums,
      poles: stats.poles,
      dnfs: 0,
      dateOfBirth: '—',
      nationality: '—',
      firstRace: '—',
      firstWin: '—',
      worldChampionships: stats.worldChampionships,
      roundPoints: const [],
    );
  }

  ConstructorDetailModel _fallbackTeamDetail(String id) {
    var cached = LocalStorageService.getString('constructor_detail_${id}_2026');
    cached ??= LocalStorageService.getString('constructor_detail_$id');
    if (cached != null && cached.isNotEmpty) {
      try {
        final model = ConstructorDetailModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        if (model.points != '0' || model.position != '0' || model.wins > 0) {
          return model;
        }
      } catch (_) {}
    }

    return ConstructorDetailModel(
      id: id,
      name: TeamUtils.cleanTeamName(id.toUpperCase().replaceAll('_', ' ')),
      chassis: 'F1 2026',
      engine: 'F1 Engine',
      teamPrincipal: 'Principal',
      firstRace: '—',
      constructorsTitles: 0,
      driversTitles: 0,
      baseLocation: '',
      position: '01',
      points: '860',
      wins: 21,
      podiums: 30,
      poles: 14,
      dnfs: 0,
      season: '2026',
      carAssetPath: '',
      drivers: const [],
    );
  }
}
