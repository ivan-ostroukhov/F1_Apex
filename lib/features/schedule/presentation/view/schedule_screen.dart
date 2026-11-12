import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:f1_app/common/localization/generated/app_localizations.dart';
import '../../../../common/utils/f1_colors.dart';
import '../../../../common/utils/f1_media.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../domain/models/race_model.dart';
import '../cubit/schedule_cubit.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScheduleCubit(ScheduleRepository())..loadSchedule(),
      child: const _ScheduleView(),
    );
  }
}

class _ScheduleView extends StatefulWidget {
  const _ScheduleView();

  @override
  State<_ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<_ScheduleView> {
  final Key _currentRaceKey = const ValueKey('current_race_hero');
  late final ScrollController _scrollController;
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  bool _isPastRacesExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final isExpanded = _scrollController.offset < -60;
    if (_isPastRacesExpanded != isExpanded) {
      setState(() {
        _isPastRacesExpanded = isExpanded;
      });
    }
  }

  void _initCountdown(DateTime? raceDate) {
    _countdownTimer?.cancel();
    if (raceDate == null) return;

    void updateRemaining() {
      final diff = raceDate.difference(DateTime.now());
      if (mounted) {
        setState(() {
          _remainingTime = diff.isNegative ? Duration.zero : diff;
        });
      }
    }

    updateRemaining();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => updateRemaining());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToPastRaces() {
    if (!_scrollController.hasClients) return;

    final willExpand = !_isPastRacesExpanded;
    setState(() {
      _isPastRacesExpanded = willExpand;
    });

    final targetOffset = willExpand ? -450.0 : 0.0;

    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _openRaceDetail(BuildContext context, RaceModel race) {
    context.push('/schedule/detail', extra: race);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocConsumer<ScheduleCubit, ScheduleState>(
        listener: (context, state) {
          if (state is ScheduleLoaded && state.currentRace?.date != null) {
            _initCountdown(state.currentRace!.date);
          }
        },
        builder: (context, state) {
          if (state is ScheduleLoading) {
            return Center(
              child: CircularProgressIndicator(color: theme.colorScheme.onSurface),
            );
          }

          if (state is ScheduleError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<ScheduleCubit>().loadSchedule(),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (state is! ScheduleLoaded) return const SizedBox.shrink();

          final currentRace = state.currentRace;
          final pastRaces = state.pastRaces;
          final upcomingRaces = state.upcomingRaces;

          final currentCircuitColor = currentRace != null
              ? F1Colors.getCircuitColor(
            currentRace.circuitId.isNotEmpty ? currentRace.circuitId : currentRace.raceName,
          )
              : const Color(0xFF15448C);

          final days = _remainingTime.inDays.toString().padLeft(2, '0');
          final hours = (_remainingTime.inHours % 24).toString().padLeft(2, '0');
          final minutes = (_remainingTime.inMinutes % 60).toString().padLeft(2, '0');

          return CustomScrollView(
            controller: _scrollController,
            center: _currentRaceKey,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPastRaceTile(context, pastRaces[index]),
                  childCount: pastRaces.length,
                ),
              ),
              SliverToBoxAdapter(
                key: _currentRaceKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: _scrollToPastRaces,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.pastRaces,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedRotation(
                                turns: _isPastRacesExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutQuad,
                                child: Icon(
                                  Icons.keyboard_arrow_up,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (currentRace != null)
                      SizedBox(
                        height: 310,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Positioned.fill(
                              right: -100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(0.9, -0.5),
                                    radius: 0.75,
                                    stops: const [0.0, 0.45, 0.8, 0.8],
                                    colors: [
                                      currentCircuitColor.withValues(alpha: 0.65),
                                      currentCircuitColor.withValues(alpha: 0.30),
                                      currentCircuitColor.withValues(alpha: 0.08),
                                      theme.scaffoldBackgroundColor,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              right: 180,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: const Alignment(-0.9, 0.8),
                                    radius: 0.75,
                                    stops: const [0.0, 0.45, 0.8, 0.8],
                                    colors: [
                                      currentCircuitColor.withValues(alpha: 0.65),
                                      currentCircuitColor.withValues(alpha: 0.30),
                                      currentCircuitColor.withValues(alpha: 0.08),
                                      theme.scaffoldBackgroundColor,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 45,
                              width: 220,
                              height: 190,
                              child: Transform.scale(
                                scale: 1.10,
                                child: Image.asset(
                                  F1Media.getTrackAssetPath(currentRace.circuitId),
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerRight,
                                  errorBuilder: (_, __, ___) => Icon(
                                    Icons.polyline_rounded,
                                    size: 165,
                                    color: currentCircuitColor.withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              top: 16,
                              right: 180,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.roundFormat(currentRace.round),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentRace.raceName,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    currentRace.locality,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currentRace.dateRange,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 16,
                              bottom: 20,
                              right: 16,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.raceCountdownPrefix,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _buildCountdownItem(days, l10n.daysShort, theme),
                                          const SizedBox(width: 14),
                                          _buildCountdownItem(hours, l10n.hoursShort, theme),
                                          const SizedBox(width: 14),
                                          _buildCountdownItem(minutes, l10n.minutesShort, theme),
                                        ],
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.14),
                                      foregroundColor: theme.colorScheme.onSurface,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      elevation: 0,
                                    ),
                                    icon: const Icon(Icons.access_time, size: 16),
                                    label: Text(l10n.scheduleButton, style: const TextStyle(fontSize: 13)),
                                    onPressed: () => _openRaceDetail(context, currentRace),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: 24,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, theme.scaffoldBackgroundColor],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildUpcomingRaceTile(context, upcomingRaces[index]),
                  childCount: upcomingRaces.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 105)),
            ],
          );
        },
      ),
    );
  }

  static Widget _buildCountdownItem(String value, String label, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  static Widget _buildPastRaceTile(BuildContext context, RaceModel race) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Divider(color: theme.dividerColor, height: 1),
        InkWell(
          onTap: () {
            context.push('/schedule/detail', extra: race);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.grey,
                      BlendMode.srcIn,
                    ),
                    child: Image.asset(
                      F1Media.get2DTrackAssetPath(race.circuitId),
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.timeline,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        race.raceName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          text: 'R${race.round} • ',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          children: [
                            TextSpan(
                              text: race.locality,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (race.podium != null && race.podium!.isNotEmpty)
                        Row(
                          children: race.podium!.map((driver) {
                            final teamColor = F1Colors.getTeamColor(driver.teamName);
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: teamColor.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    driver.code,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildUpcomingRaceTile(BuildContext context, RaceModel race) {
    final theme = Theme.of(context);
    final circuitColor = F1Colors.getCircuitColor(
      race.circuitId.isNotEmpty ? race.circuitId : race.raceName,
    );

    return Column(
      children: [
        Divider(color: theme.dividerColor, height: 1),
        InkWell(
          onTap: () {
            context.push('/schedule/detail', extra: race);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        race.dateRange.isNotEmpty ? race.dateRange.split(' ').first : '--',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        race.dateRange.split(' ').length > 1 ? race.dateRange.split(' ').last : '',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        race.raceName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        text: TextSpan(
                          text: 'R${race.round} • ',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                          ),
                          children: [
                            TextSpan(
                              text: race.locality,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: circuitColor.withValues(alpha: 0.95),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  F1Media.get2DTrackAssetPath(race.circuitId),
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.timeline,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}