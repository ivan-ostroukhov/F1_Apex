import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../common/utils/f1_colors.dart';
import '../../../../common/utils/f1_media.dart';
import '../../../../common/utils/team_utils.dart';
import '../../../../common/network/local_storage_service.dart';
import 'package:f1_app/common/localization/generated/app_localizations.dart';
import '../../../driver/domain/i_driver_repository.dart';
import '../../../driver/domain/driver_detail_model.dart';
import '../../../constructor/domain/constructor_repository.dart';
import '../../../constructor/domain/constructor_detail_model.dart';
import '../../../schedule/data/repositories/schedule_repository.dart';
import '../../../schedule/domain/models/race_model.dart';
import '../../../driver/presentation/widgets/driver_hero_image.dart';
import '../../data/home_repository.dart';
import '../../domain/home_news_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _activePage = 0;
  Timer? _carouselTimer;

  List<HomeNewsModel> _news = [];
  String _favDriver1 = 'verstappen';
  String _favDriver2 = 'piastri';
  String _favTeam = 'red_bull';

  DriverDetailModel? _driver1Detail;
  DriverDetailModel? _driver2Detail;
  ConstructorDetailModel? _teamDetail;
  RaceModel? _nextRace;
  bool? _lastIsEn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadNews();
        _loadFavoritesAndData();
      }
    });
    _startAutoScroll();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    if (_lastIsEn != isEn) {
      _lastIsEn = isEn;
      _loadNews();
    }
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _activePage = (_activePage + 1) % 4;
        });
      }
    });
  }

  void _nextSlide() {
    setState(() {
      _activePage = (_activePage + 1) % 4;
    });
    _startAutoScroll();
  }

  void _previousSlide() {
    setState(() {
      _activePage = (_activePage - 1 + 4) % 4;
    });
    _startAutoScroll();
  }

  Future<void> _loadNews() async {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final repo = HomeRepository();
    final newsList = await repo.getLatestNews(isEnglish: isEn);
    if (mounted) {
      setState(() {
        _news = newsList;
      });
    }
  }

  Future<void> _loadFavoritesAndData() async {
    final d1 = LocalStorageService.getString('fav_driver_1') ?? 'verstappen';
    final d2 = LocalStorageService.getString('fav_driver_2') ?? 'piastri';
    final tm = LocalStorageService.getString('fav_team') ?? 'red_bull';

    setState(() {
      _favDriver1 = d1;
      _favDriver2 = d2;
      _favTeam = tm;
    });

    try {
      final driverRepo = context.read<IDriverRepository>();
      final teamRepo = context.read<IConstructorRepository>();
      final scheduleRepo = ScheduleRepository();

      final results = await Future.wait([
        driverRepo.getDriverDetails(d1).catchError((_) => _fallbackDriverDetail(d1)),
        driverRepo.getDriverDetails(d2).catchError((_) => _fallbackDriverDetail(d2)),
        teamRepo.getConstructorDetails(tm).catchError((_) => _fallbackTeamDetail(tm)),
      ]);

      List<RaceModel> schedule = [];
      try {
        schedule = await scheduleRepo.getSeasonSchedule();
      } catch (_) {}

      if (mounted) {
        setState(() {
          final res1 = results[0] as DriverDetailModel;
          if (res1.points != '0' || res1.roundPoints.isNotEmpty) {
            _driver1Detail = res1;
          }
          final res2 = results[1] as DriverDetailModel;
          if (res2.points != '0' || res2.roundPoints.isNotEmpty) {
            _driver2Detail = res2;
          }
          final resTeam = results[2] as ConstructorDetailModel;
          if (resTeam.points != '0' || resTeam.position != '0' || resTeam.wins > 0) {
            _teamDetail = resTeam;
          }
          if (schedule.isNotEmpty) {
            _nextRace = schedule.where((r) => !r.isCompleted).firstOrNull ?? schedule.last;
          }
        });
      }
    } catch (_) {}
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
    return DriverDetailModel(
      id: id,
      firstName: name.$1,
      lastName: name.$2,
      code: id.length >= 3 ? id.substring(0, 3).toUpperCase() : id.toUpperCase(),
      permanentNumber: '1',
      teamName: TeamUtils.getDefaultTeamForDriver(id),
      position: '01',
      points: '100',
      wins: 1,
      podiums: 3,
      poles: 1,
      dnfs: 0,
      dateOfBirth: '—',
      nationality: '—',
      firstRace: '—',
      firstWin: '—',
      worldChampionships: 0,
      roundPoints: _getValidChartPoints(null, id),
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
      baseLocation: 'Base',
      position: '01',
      points: '200',
      wins: 2,
      podiums: 5,
      poles: 2,
      dnfs: 0,
      season: '2026',
      carAssetPath: 'assets/images/$id.png',
      drivers: const [],
    );
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    super.dispose();
  }

  Future<void> _openNewsUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  List<int> _getValidChartPoints(DriverDetailModel? detail, String driverId) {
    if (detail != null && detail.roundPoints.whereType<int>().any((p) => p > 0)) {
      return detail.roundPoints.map((p) => p ?? 0).toList();
    }
    final lower = driverId.toLowerCase();
    if (lower.contains('verstappen')) return const [25, 25, 0, 25, 25, 18, 25, 25, 12, 18, 10, 25, 12, 25, 18, 25, 18, 25];
    if (lower.contains('norris')) return const [15, 18, 15, 10, 18, 25, 18, 18, 15, 18, 15, 25, 12, 18, 25, 18, 25, 18];
    if (lower.contains('leclerc')) return const [12, 15, 18, 12, 15, 25, 15, 25, 0, 10, 15, 12, 18, 25, 15, 25, 18, 15];
    if (lower.contains('piastri')) return const [5, 12, 15, 4, 3, 13, 12, 18, 10, 18, 18, 15, 25, 15, 7, 12, 25, 10];
    if (lower.contains('hamilton')) return const [6, 2, 0, 2, 2, 8, 8, 6, 12, 15, 12, 25, 15, 25, 4, 10, 8, 12];
    if (lower.contains('russell') || lower.contains('antonelli')) return const [10, 8, 0, 6, 4, 4, 6, 10, 18, 12, 25, 12, 0, 6, 6, 6, 12, 10];
    if (lower.contains('sainz') || lower.contains('albon')) return const [15, 0, 25, 15, 10, 15, 10, 15, 0, 8, 15, 10, 8, 6, 10, 12, 0, 8];
    return const [8, 12, 4, 10, 15, 18, 6, 12, 10, 15, 8, 12, 15, 6, 10, 15, 8, 12];
  }

  Widget _getSlideWidget(int index) {
    final l10n = AppLocalizations.of(context)!;
    final d1 = _driver1Detail;
    final d2 = _driver2Detail;
    final tm = _teamDetail;

    switch (index) {
      case 0:
        final defaultTeam1 = TeamUtils.getDefaultTeamForDriver(_favDriver1);
        final defaultName1 = _getDefaultDriverName(_favDriver1);
        return _buildDriverSlide(
          l10n: l10n,
          driverId: _favDriver1,
          bgText: d1?.firstName.isNotEmpty == true ? d1!.firstName.toLowerCase() : defaultName1.$1.toLowerCase(),
          firstName: d1?.firstName.isNotEmpty == true ? d1!.firstName : defaultName1.$1,
          lastName: d1?.lastName.isNotEmpty == true ? d1!.lastName : defaultName1.$2,
          teamName: d1?.teamName.isNotEmpty == true ? d1!.teamName : defaultTeam1,
          pos: d1?.position != null && d1!.position != '0' ? d1.position.padLeft(2, '0') : '—',
          wins: d1?.wins != null ? d1!.wins.toString().padLeft(2, '0') : '00',
          pts: d1?.points != null && d1!.points != '0' ? d1.points : '0',
          chartPoints: _getValidChartPoints(d1, _favDriver1),
        );
      case 1:
        final defaultTeam2 = TeamUtils.getDefaultTeamForDriver(_favDriver2);
        final defaultName2 = _getDefaultDriverName(_favDriver2);
        return _buildDriverSlide(
          l10n: l10n,
          driverId: _favDriver2,
          bgText: d2?.firstName.isNotEmpty == true ? d2!.firstName.toLowerCase() : defaultName2.$1.toLowerCase(),
          firstName: d2?.firstName.isNotEmpty == true ? d2!.firstName : defaultName2.$1,
          lastName: d2?.lastName.isNotEmpty == true ? d2!.lastName : defaultName2.$2,
          teamName: d2?.teamName.isNotEmpty == true ? d2!.teamName : defaultTeam2,
          pos: d2?.position != null && d2!.position != '0' ? d2.position.padLeft(2, '0') : '—',
          wins: d2?.wins != null ? d2!.wins.toString().padLeft(2, '0') : '00',
          pts: d2?.points != null && d2!.points != '0' ? d2.points : '0',
          chartPoints: _getValidChartPoints(d2, _favDriver2),
        );
      case 2:
        final defaultTeam = TeamUtils.cleanTeamName(_favTeam);
        return _buildTeamSlide(
          l10n: l10n,
          teamName: tm?.name.isNotEmpty == true ? tm!.name : defaultTeam,
          bgText: tm?.name.isNotEmpty == true ? tm!.name.toLowerCase() : _favTeam,
          pos: tm?.position != null && tm!.position != '0' ? tm.position.padLeft(2, '0') : '01',
          wins: tm?.wins != null ? tm!.wins.toString().padLeft(2, '0') : '00',
          pts: tm?.points ?? '0',
          carAssetPath: tm?.carAssetPath ?? 'assets/images/$_favTeam.png',
        );
      case 3:
      default:
        final race = _nextRace;
        if (race != null) {
          final now = DateTime.now();
          final session = race.sessions.where((s) => s.endTime.isAfter(now)).firstOrNull ??
              race.sessions.firstOrNull;

          final sessionTitle = session != null ? session.title : 'Race';
          final sessionDate = session != null
              ? '${session.day} ${session.dayOfWeek}'
              : (race.date != null ? DateFormat('dd MMM', 'ru').format(race.date!) : '');
          final sessionTime = session != null ? session.timeRange : '';

          return _buildRaceSlide(
            circuitId: race.circuitId,
            bgText: race.circuitId.toLowerCase().replaceAll('-', '_'),
            locality: race.locality.isNotEmpty ? race.locality : race.raceName,
            dateRange: race.dateRange,
            sessionTitle: sessionTitle,
            sessionDate: sessionDate,
            sessionTime: sessionTime,
          );
        }

        return _buildRaceSlide(
          circuitId: 'rodriguez',
          bgText: 'mexico',
          locality: 'Mexico City',
          dateRange: l10n.mexicoDateRange,
          sessionTitle: l10n.mexicoSessionTitle,
          sessionDate: l10n.mexicoSessionDate,
          sessionTime: '00:30 - 01:30',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadNews(),
            _loadFavoritesAndData(),
          ]);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
        slivers: [
          SliverToBoxAdapter(
            child: SizedBox(
              height: 360,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity != null) {
                          if (details.primaryVelocity! < -100) {
                            _nextSlide();
                          } else if (details.primaryVelocity! > 100) {
                            _previousSlide();
                          }
                        }
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 700),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey<int>(_activePage),
                          child: _getSlideWidget(_activePage),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    right: 16,
                    child: GestureDetector(
                      onTap: () async {
                        await context.push('/settings');
                        _loadFavoritesAndData();
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.cardColor.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.dividerColor,
                          ),
                        ),
                        child: Icon(
                          Icons.tune_outlined,
                          color: theme.colorScheme.onSurface,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        final isActive = i == _activePage;
                        return GestureDetector(
                          onTap: () {
                            setState(() => _activePage = i);
                            _startAutoScroll();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 24 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isActive ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 135,
                        height: 135,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(135, 135),
                              painter: _GaugePainter(percent: 0.78, isLight: theme.brightness == Brightness.light),
                            ),
                            const Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '78',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProgressStat(context, '18/23', l10n.grandPrixCompleted),
                            Divider(color: theme.dividerColor, height: 16),
                            _buildProgressStat(context, isEn ? '5483.0 KM' : '5483.0 КМ', l10n.distanceCovered),
                            Divider(color: theme.dividerColor, height: 16),
                            _buildProgressStat(context, '1 082', l10n.lapsCompleted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.bolt, color: theme.colorScheme.onSurface, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            l10n.breakingNews,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => _openNewsUrl('https://www.formula1.com/en/latest/all.html'),
                        child: Text(
                          l10n.viewAllNews,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  height: 210,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _news.length,
                    itemBuilder: (context, index) {
                      final news = _news[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: GestureDetector(
                          onTap: () => _openNewsUrl(news.url),
                          child: Container(
                            width: 280,
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: theme.dividerColor,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: news.imageUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: theme.cardColor,
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      decoration: BoxDecoration(
                                        color: theme.cardColor,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.newspaper_rounded,
                                          size: 48,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.25),
                                          Colors.black.withValues(alpha: 0.88),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          news.title,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.link,
                                                  size: 14,
                                                  color: Colors.white70,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  news.source,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white70,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              isEn && news.timeAgoEn != null ? news.timeAgoEn! : news.timeAgo,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.white38,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.mexicoGrandPrixTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildWhiteStagePill(context, '71', l10n.lapsCount, const Color(0xFFFFD600), Icons.repeat_rounded),
                      const SizedBox(height: 10),
                      _buildWhiteStagePill(context, isEn ? '356.9 km/h' : '356.9 км/ч', l10n.maxSpeed, const Color(0xFF00E676), Icons.speed_rounded),
                      const SizedBox(height: 10),
                      _buildWhiteStagePill(context, '17', l10n.turnsCount, const Color(0xFF2979FF), Icons.alt_route_rounded),
                      const SizedBox(height: 10),
                      _buildWhiteStagePill(context, isEn ? '2.67 m' : '2.67 м', l10n.elevationChange, const Color(0xFFFF3D00), Icons.height_rounded),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecordTile(
                        context,
                        l10n.mostSuccessfulConstructor,
                        l10n.recordWinsFormat('04'),
                        'Red Bull',
                      ),
                      Divider(color: theme.dividerColor, height: 28),
                      _buildRecordTile(
                        context,
                        l10n.mostSuccessfulDrivers,
                        l10n.recordWinsFormat('04'),
                        'Max Verstappen',
                      ),
                      Divider(color: theme.dividerColor, height: 28),
                      _buildRecordTile(
                        context,
                        l10n.raceLapRecord,
                        '1:14.774',
                        'Valtteri Bottas',
                      ),
                      Divider(color: theme.dividerColor, height: 28),
                      _buildRecordTile(
                        context,
                        l10n.fastestPitStop,
                        isEn ? '1.80 s' : '1.80 с',
                        'McLaren (2023 Qatar GP)',
                      ),
                      Divider(color: theme.dividerColor, height: 28),
                      _buildRecordTile(
                        context,
                        l10n.fastestLapSeason,
                        '1:11.890',
                        'Lando Norris',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildDriverSlide({
    required AppLocalizations l10n,
    required String driverId,
    required String bgText,
    required String firstName,
    required String lastName,
    required String teamName,
    required String pos,
    required String wins,
    required String pts,
    required List<int> chartPoints,
  }) {
    final teamColor = F1Colors.getTeamColor(teamName, driverId);
    final theme = Theme.of(context);

    final formattedPos = pos.padLeft(2, '0');
    final formattedWins = (int.tryParse(wins) ?? 0).toString().padLeft(2, '0');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -400,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.65, -0.6),
                radius: 1.25,
                colors: [
                  teamColor.withValues(alpha: 0.55),
                  teamColor.withValues(alpha: 0.28),
                  teamColor.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          left: -10,
          top: 10,
          child: Text(
            bgText,
            style: GoogleFonts.titilliumWeb(
              fontSize: 110,
              fontWeight: FontWeight.w900,
              color: teamColor.withValues(alpha: 0.15),
              height: 0.9,
            ),
          ),
        ),

        Positioned(
          right: -10,
          top: 10,
          bottom: 0,
          width: 230,
          child: DriverHeroImage(
            driverId: driverId,
            alignment: Alignment.topRight,
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 100,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                width: 180,
                height: 32,
                child: _MiniPointsChart(
                  roundPoints: chartPoints,
                  accentColor: teamColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.bar_chart, size: 15, color: teamColor),
                  const SizedBox(width: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formattedPos,
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: ' ${l10n.driverPositionShort}',
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.stars, size: 15, color: teamColor),
                  const SizedBox(width: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formattedWins,
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: ' ${l10n.winsLabel}',
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    pts,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 54,
                      fontWeight: FontWeight.w300,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.driverPointsShort,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamSlide({
    required AppLocalizations l10n,
    required String teamName,
    required String bgText,
    required String pos,
    required String wins,
    required String pts,
    required String carAssetPath,
  }) {
    final teamColor = F1Colors.getTeamColor(teamName);
    final theme = Theme.of(context);
    final formattedPos = pos.padLeft(2, '0');
    final formattedWins = (int.tryParse(wins) ?? 0).toString().padLeft(2, '0');

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -400,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.65, -0.6),
                radius: 1.25,
                colors: [
                  teamColor.withValues(alpha: 0.55),
                  teamColor.withValues(alpha: 0.28),
                  teamColor.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          left: -10,
          top: 10,
          child: Text(
            bgText,
            style: GoogleFonts.titilliumWeb(
              fontSize: 100,
              fontWeight: FontWeight.w900,
              color: teamColor.withValues(alpha: 0.15),
              height: 0.9,
            ),
          ),
        ),

        Positioned(
          right: -10,
          top: 20,
          bottom: 0,
          width: 230,
          child: Image.asset(
            carAssetPath,
            fit: BoxFit.contain,
            alignment: Alignment.topRight,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.sports_motorsports,
              size: 130,
              color: Colors.white12,
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 100,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.bar_chart, size: 15, color: teamColor),
                  const SizedBox(width: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formattedPos,
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: ' ${l10n.driverPositionShort}',
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Icon(Icons.stars, size: 15, color: teamColor),
                  const SizedBox(width: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: formattedWins,
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        TextSpan(
                          text: ' ${l10n.winsLabel}',
                          style: GoogleFonts.titilliumWeb(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    pts,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 54,
                      fontWeight: FontWeight.w300,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.driverPointsShort,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 16,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRaceSlide({
    required String circuitId,
    required String bgText,
    required String locality,
    required String dateRange,
    required String sessionTitle,
    required String sessionDate,
    required String sessionTime,
  }) {
    final circuitColor = F1Colors.getCircuitColor(circuitId);
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -400,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.65, -0.6),
                radius: 1.25,
                colors: [
                  circuitColor.withValues(alpha: 0.55),
                  circuitColor.withValues(alpha: 0.28),
                  circuitColor.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          left: -10,
          top: 10,
          child: Text(
            bgText,
            style: GoogleFonts.titilliumWeb(
              fontSize: 100,
              fontWeight: FontWeight.w900,
              color: circuitColor.withValues(alpha: 0.2),
              height: 0.9,
            ),
          ),
        ),

        Positioned(
          right: -10,
          top: 20,
          width: 200,
          height: 180,
          child: Image.asset(
            F1Media.getTrackAssetPath(circuitId),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Icon(
              Icons.polyline_rounded,
              size: 160,
              color: circuitColor.withValues(alpha: 0.9),
            ),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 100,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    Colors.transparent,
                    theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                locality,
                style: GoogleFonts.titilliumWeb(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: circuitColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateRange,
                style: GoogleFonts.titilliumWeb(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    sessionTitle,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    sessionDate,
                    style: GoogleFonts.titilliumWeb(
                      fontSize: 54,
                      fontWeight: FontWeight.w300,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -1.0,
                    ),
                  ),
                ],
              ),
              Text(
                sessionTime,
                style: GoogleFonts.titilliumWeb(
                  fontSize: 13,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildProgressStat(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget _buildWhiteStagePill(
    BuildContext context,
    String value,
    String label,
    Color btnColor,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildRecordTile(BuildContext context, String category, String recordValue, String holder) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyle(
            fontSize: 13,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          recordValue,
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          holder,
          style: TextStyle(
            fontSize: 15,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MiniPointsChart extends StatelessWidget {
  final List<int> roundPoints;
  final Color accentColor;

  const _MiniPointsChart({
    required this.roundPoints,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    const maxScore = 25;
    const totalRounds = 18;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(totalRounds, (index) {
        final hasScore = index < roundPoints.length;
        final score = hasScore ? roundPoints[index] : 0;
        final barHeight = hasScore && score > 0
            ? ((score / maxScore) * 32).clamp(4.0, 32.0)
            : 3.0;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.0),
            height: barHeight,
            decoration: BoxDecoration(
              color: hasScore && score > 0
                  ? accentColor
                  : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percent;
  final bool isLight;

  _GaugePainter({required this.percent, this.isLight = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 2;

    // 1. Outer Ticks
    final tickPaint = Paint()
      ..color = isLight ? Colors.black.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    const totalTicks = 72;
    for (int i = 0; i < totalTicks; i++) {
      final angle = i * (2 * math.pi / totalTicks);
      final pOuter = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      final pInner = Offset(
        center.dx + (outerRadius - 6) * math.cos(angle),
        center.dy + (outerRadius - 6) * math.sin(angle),
      );
      canvas.drawLine(pInner, pOuter, tickPaint);
    }

    final arcRadius = outerRadius - 16;
    const strokeWidth = 14.0;
    const startAngle = math.pi * 0.72;
    const totalSweep = math.pi * 1.56;

    // 2. Inner Blue Disk (as shown in the screenshot)
    final innerRadius = arcRadius - (strokeWidth / 2) - 3;
    final innerRect = Rect.fromCircle(center: center, radius: innerRadius);
    final innerPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.2),
        radius: 0.85,
        colors: [
          Color(0xFF0075FF),
          Color(0xFF004BD6),
          Color(0xFF0036A8),
        ],
        stops: [0.0, 0.7, 1.0],
      ).createShader(innerRect);

    canvas.drawCircle(center, innerRadius, innerPaint);

    final innerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.white.withValues(alpha: 0.25);
    canvas.drawCircle(center, innerRadius, innerBorderPaint);

    // 3. Unfilled Slats Background
    final slatPaint = Paint()
      ..color = isLight ? const Color(0xFFE0E0E5) : const Color(0xFF262830)
      ..strokeWidth = 1.8;

    const slatCount = 48;
    for (int i = 0; i < slatCount; i++) {
      final slatProgress = i / slatCount;
      if (slatProgress > percent) {
        final angle = startAngle + (totalSweep * slatProgress);
        final innerR = arcRadius - (strokeWidth / 2) + 2;
        final outerR = arcRadius + (strokeWidth / 2) - 2;
        final p1 = Offset(
          center.dx + innerR * math.cos(angle),
          center.dy + innerR * math.sin(angle),
        );
        final p2 = Offset(
          center.dx + outerR * math.cos(angle),
          center.dy + outerR * math.sin(angle),
        );
        canvas.drawLine(p1, p2, slatPaint);
      }
    }

    // 4. Active Progress Arc with Gradient & Round Caps
    final progressSweep = totalSweep * percent;
    final arcRect = Rect.fromCircle(center: center, radius: arcRadius);
    final activeGradient = SweepGradient(
      center: Alignment.center,
      startAngle: startAngle,
      endAngle: startAngle + totalSweep,
      colors: const [
        Color(0xFF0038FF),
        Color(0xFF0075FF),
        Color(0xFF00E676),
        Color(0xFFAEEA00),
        Color(0xFFFFD600),
        Color(0xFFFFEA00),
      ],
      stops: const [0.0, 0.20, 0.42, 0.60, 0.76, 1.0],
    );

    final activePaint = Paint()
      ..shader = activeGradient.createShader(arcRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      arcRect,
      startAngle,
      progressSweep,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.isLight != isLight;
}