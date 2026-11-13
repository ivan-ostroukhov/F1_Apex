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

    // 1. Новости запускаем в фоне (не блокируют splash screen)
    _loadNewsInBackground(homeRepo);

    // 2. Критичные данные экрана (пилоты, команда, расписание) ждём параллельно
    await Future.wait<void>([
      _loadDriversAndTeam(d1, d2, tm),
      _loadSchedule(scheduleRepo),
    ]);

    if (isClosed) return;
    // Как только критичные данные получены — экран загрузки может безопасно уходить
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _loadDriversAndTeam(String d1, String d2, String tm) async {
    try {
      final results = await Future.wait([
        _driverRepo.getDriverDetails(d1).catchError((_) => _emptyDriver(d1)),
        _driverRepo.getDriverDetails(d2).catchError((_) => _emptyDriver(d2)),
        _constructorRepo.getConstructorDetails(tm).catchError((_) => _emptyTeam(tm)),
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

  /// Called when user changes favorites in settings
  Future<void> refreshFavorites() async {
    final d1 = LocalStorageService.getString('fav_driver_1') ?? 'verstappen';
    final d2 = LocalStorageService.getString('fav_driver_2') ?? 'piastri';
    final tm = LocalStorageService.getString('fav_team') ?? 'red_bull';

    emit(state.copyWith(favDriver1: d1, favDriver2: d2, favTeam: tm));

    try {
      final results = await Future.wait([
        _driverRepo.getDriverDetails(d1).catchError((_) => _emptyDriver(d1)),
        _driverRepo.getDriverDetails(d2).catchError((_) => _emptyDriver(d2)),
        _constructorRepo.getConstructorDetails(tm).catchError((_) => _emptyTeam(tm)),
      ]);
      if (isClosed) return;
      emit(state.copyWith(
        driver1Detail: results[0] as DriverDetailModel,
        driver2Detail: results[1] as DriverDetailModel,
        teamDetail: results[2] as ConstructorDetailModel,
      ));
    } catch (_) {}
  }

  DriverDetailModel _emptyDriver(String id) {
    return DriverDetailModel(
      id: id,
      firstName: '',
      lastName: '',
      code: '',
      permanentNumber: '',
      teamName: '',
      position: '0',
      points: '0',
      wins: 0,
      podiums: 0,
      poles: 0,
      dnfs: 0,
      dateOfBirth: '',
      nationality: '',
      firstRace: '',
      firstWin: '',
      worldChampionships: 0,
      roundPoints: [],
      season: '2026',
    );
  }

  ConstructorDetailModel _emptyTeam(String id) {
    return ConstructorDetailModel(
      id: id,
      name: id,
      chassis: '',
      engine: '',
      teamPrincipal: '',
      firstRace: '',
      constructorsTitles: 0,
      driversTitles: 0,
      baseLocation: '',
      position: '0',
      points: '0',
      wins: 0,
      podiums: 0,
      poles: 0,
      dnfs: 0,
      season: '2026',
      carAssetPath: '',
      drivers: [],
    );
  }
}
