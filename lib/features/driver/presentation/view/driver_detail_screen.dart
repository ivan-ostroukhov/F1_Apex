import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:f1_app/common/localization/generated/app_localizations.dart';
import '../../../../common/utils/f1_colors.dart';
import '../../domain/driver_detail_model.dart';
import '../../domain/i_driver_repository.dart';
import '../bloc/list/driver_list_cubit.dart';
import '../bloc/list/driver_list_state.dart';
import '../widgets/round_points_chart.dart';
import '../widgets/driver_hero_image.dart';

class DriverDetailScreen extends StatefulWidget {
  final String driverId;

  const DriverDetailScreen({
    super.key,
    required this.driverId,
  });

  @override
  State<DriverDetailScreen> createState() => _DriverDetailScreenState();
}

class _DriverDetailScreenState extends State<DriverDetailScreen> {
  final GlobalKey _seasonButtonKey = GlobalKey();
  String _selectedSeason = '2026';
  List<String> _seasons = [];
  late Future<DriverDetailModel> _detailFuture;

  @override
  void initState() {
    super.initState();
    _loadData(_selectedSeason);
    _fetchSeasons();
  }

  void _loadData(String season) {
    setState(() {
      _selectedSeason = season;
      _detailFuture = context.read<IDriverRepository>().getDriverDetails(
        widget.driverId,
        season: season,
      );
    });
  }

  Future<void> _fetchSeasons() async {
    try {
      final seasons = await context
          .read<IDriverRepository>()
          .getDriverSeasons(widget.driverId);
      if (mounted) {
        setState(() {
          _seasons = seasons;
          if (_seasons.isNotEmpty &&
              !_seasons.contains(_selectedSeason) &&
              _selectedSeason != 'career') {
            _selectedSeason = _seasons.first;
            _loadData(_selectedSeason);
          }
        });
      }
    } catch (_) {}
  }

  void _showSeasonPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final renderBox = _seasonButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonOffset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;

    String? debutYear;
    try {
      final detailData = await _detailFuture;
      if (detailData.firstRace != '—' && detailData.firstRace.isNotEmpty) {
        final match = RegExp(r'\d{4}').firstMatch(detailData.firstRace);
        if (match != null) {
          debutYear = match.group(0);
        }
      }
    } catch (_) {}

    final debutInt = int.tryParse(debutYear ?? '') ?? 1950;
    const currentYearInt = 2026;

    List<String> availableSeasons;
    if (_seasons.isNotEmpty) {
      availableSeasons = _seasons
          .where((s) => (int.tryParse(s) ?? 0) >= debutInt)
          .take(4)
          .toList();
    } else {
      final list = <String>[];
      for (int y = currentYearInt; y >= debutInt && list.length < 4; y--) {
        list.add(y.toString());
      }
      availableSeasons = list.isNotEmpty ? list : ['2026'];
    }

    final showSinceDebut = debutYear != null && debutInt < currentYearInt;

    double top = buttonOffset.dy - 10;
    double left = buttonOffset.dx - 12;

    final itemCount = availableSeasons.length + (showSinceDebut ? 1 : 0);
    final estimatedHeight = itemCount * 46.0 + 30.0;
    if (top + estimatedHeight > screenSize.height - 30) {
      top = screenSize.height - estimatedHeight - 30;
    }
    if (top < 40) top = 40;

    if (!mounted) return;

    final selected = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'SeasonPicker',
      barrierColor: Colors.black26,
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (ctx, anim1, anim2) {
        return Stack(
          children: [
            Positioned(
              top: top,
              left: left,
              child: Material(
                color: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      width: 215,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xCC181A22),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final season in availableSeasons) ...[
                            InkWell(
                              onTap: () => Navigator.of(ctx).pop(season),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        l10n.seasonPrefix(season),
                                        style: TextStyle(
                                          color: season == _selectedSeason
                                              ? Colors.white
                                              : Colors.white70,
                                          fontSize: 16,
                                          fontWeight: season == _selectedSeason
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (season == _selectedSeason)
                                      const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          if (showSinceDebut) ...[
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => Navigator.of(ctx).pop('career'),
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        l10n.sinceDebut(debutYear!),
                                        style: TextStyle(
                                          color: _selectedSeason == 'career'
                                              ? Colors.white
                                              : Colors.white70,
                                          fontSize: 15,
                                          fontWeight: _selectedSeason == 'career'
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (_selectedSeason == 'career')
                                      const Icon(
                                        Icons.check,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      transitionBuilder: (ctx, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutCubic,
            ),
            alignment: Alignment.topLeft,
            child: child,
          ),
        );
      },
    );

    if (selected != null && selected != _selectedSeason) {
      _loadData(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final listState = context.read<DriverListCubit>().state;
    dynamic currentDriver;

    if (listState is DriverListLoaded) {
      try {
        currentDriver = listState.drivers.firstWhere(
          (d) => d.id == widget.driverId,
        );
      } catch (_) {
        currentDriver = listState.drivers.first;
      }
    }

    final fullName = currentDriver?.name as String? ?? 'Driver Name';
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    final fallbackTeamName = currentDriver?.teamName as String? ?? 'Team';
    final fallbackPoints = currentDriver?.points?.toString() ?? '0';

    String fallbackPositionNumber = '01';
    if (listState is DriverListLoaded && currentDriver != null) {
      final index = listState.drivers.indexOf(currentDriver);
      if (index >= 0) {
        fallbackPositionNumber = (index + 1).toString().padLeft(2, '0');
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<DriverDetailModel>(
        future: _detailFuture,
        builder: (context, snapshot) {
          final detail = snapshot.data;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          final dynamicTeamName = (detail != null && detail.teamName.isNotEmpty)
              ? detail.teamName
              : fallbackTeamName;
          final displayTeamColor = F1Colors.getTeamColor(dynamicTeamName, widget.driverId);

          String displayPosition = fallbackPositionNumber;
          if (detail != null && detail.position != '0') {
            displayPosition = detail.position.padLeft(2, '0');
          }

          final displayPoints = (detail != null && detail.points != '0')
              ? detail.points
              : (isLoading ? '..' : fallbackPoints);

          final winsStr = isLoading
              ? '..'
              : (detail?.wins ?? 0).toString().padLeft(2, '0');
          final podiumsStr = isLoading
              ? '..'
              : (detail?.podiums ?? 0).toString().padLeft(2, '0');
          final polesStr = isLoading
              ? '..'
              : (detail?.poles ?? 0).toString().padLeft(2, '0');
          final dnfsStr = isLoading
              ? '..'
              : (detail?.dnfs ?? 0).toString().padLeft(2, '0');

          final chartPoints = (detail?.roundPoints != null && detail!.roundPoints.isNotEmpty)
              ? detail.roundPoints.map((p) => p ?? 0).toList()
              : <int>[];

          final driverCode = (detail != null && detail.code.isNotEmpty)
              ? detail.code
              : (widget.driverId.length >= 3
                  ? widget.driverId.substring(0, 3).toUpperCase()
                  : widget.driverId.toUpperCase());

          final firstRaceStr = isLoading ? 'Загрузка...' : (detail?.firstRace ?? '—');
          final firstWinStr = isLoading ? 'Загрузка...' : (detail?.firstWin ?? '—');
          final championshipsStr = isLoading ? '..' : '${detail?.worldChampionships ?? 0}';
          final dobStr = isLoading ? 'Загрузка...' : (detail?.dateOfBirth ?? '—');
          final countryStr = isLoading ? 'Загрузка...' : (detail?.nationality ?? '—');

          String debutYear = '';
          if (detail != null && detail.firstRace != '—' && detail.firstRace.isNotEmpty) {
            final match = RegExp(r'\d{4}').firstMatch(detail.firstRace);
            if (match != null) {
              debutYear = match.group(0) ?? '';
            }
          }

          final seasonText = _selectedSeason == 'career'
              ? l10n.sinceDebut(debutYear.isNotEmpty ? debutYear : 'Debut')
              : l10n.seasonPrefix(_selectedSeason);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      top: -400,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.65, -0.6),
                            radius: 1.25,
                            stops: const [0.0, 0.45, 0.8, 1.0],
                            colors: [
                              displayTeamColor.withValues(alpha: 0.55),
                              displayTeamColor.withValues(alpha: 0.28),
                              displayTeamColor.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 0,
                      top: 40,
                      bottom: 0,
                      width: 400,
                      child: DriverHeroImage(
                        driverId: widget.driverId,
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
                                Colors.black.withValues(alpha: 0.6),
                                Colors.black,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 26,
                              ),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(height: 16),

                            Text(
                              firstName,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Text(
                              lastName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: displayTeamColor,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),

                            GestureDetector(
                              key: _seasonButtonKey,
                              onTap: _showSeasonPicker,
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    seasonText,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.unfold_more,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),

                            _buildBigStat(displayPosition, l10n.driverPositionShort),
                            const SizedBox(height: 10),
                            _buildBigStat(displayPoints, l10n.driverPointsShort),
                            const SizedBox(height: 16),

                            _buildIconStat(
                              Icons.emoji_events_outlined,
                              winsStr,
                              l10n.winsLabel,
                            ),
                            const SizedBox(height: 12),
                            _buildIconStat(
                              Icons.bar_chart,
                              podiumsStr,
                              l10n.podiumsLabel,
                            ),
                            const SizedBox(height: 12),
                            _buildIconStat(
                              Icons.adjust_outlined,
                              polesStr,
                              l10n.polesLabel,
                            ),
                            const SizedBox(height: 12),
                            _buildIconStat(
                              Icons.block,
                              dnfsStr,
                              l10n.dnfsLabel,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                if (chartPoints.isNotEmpty)
                  RoundPointsChart(
                    roundPoints: chartPoints,
                    accentColor: displayTeamColor,
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      height: 50,
                      child: Center(
                        child: Text(
                          'Нет данных по очкам текущего сезона',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 20),
                Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 1,
                ),

                _buildDetailTile(
                  leading: Text(
                    driverCode.length > 2 ? driverCode.substring(0, 2) : driverCode,
                    style: TextStyle(
                      color: displayTeamColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: driverCode,
                  subtitle: l10n.driverCodeLabel,
                ),

                _buildDetailTile(
                  leading: Icon(
                    Icons.sports_motorsports_outlined,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 26,
                  ),
                  title: dynamicTeamName,
                  subtitle: l10n.teamLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.flag_circle_outlined,
                    color: Colors.white70,
                    size: 26,
                  ),
                  title: firstRaceStr,
                  subtitle: l10n.firstRaceLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.military_tech_outlined,
                    color: Colors.white70,
                    size: 26,
                  ),
                  title: firstWinStr,
                  subtitle: l10n.firstWinLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.white70,
                    size: 26,
                  ),
                  title: championshipsStr,
                  subtitle: l10n.worldChampionshipsLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.white70,
                    size: 24,
                  ),
                  title: dobStr,
                  subtitle: l10n.dateOfBirthLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.public,
                    color: Colors.white70,
                    size: 24,
                  ),
                  title: countryStr,
                  subtitle: l10n.countryLabel,
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _buildBigStat(String value, String unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget _buildIconStat(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _buildDetailTile({
    required Widget leading,
    required String title,
    required String subtitle,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(width: 44, child: leading),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
      ],
    );
  }
}