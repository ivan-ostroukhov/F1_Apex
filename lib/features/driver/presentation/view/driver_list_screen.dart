import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:f1_app/common/localization/generated/app_localizations.dart';
import '../../../../common/utils/f1_colors.dart';
import '../bloc/list/driver_list_cubit.dart';
import '../bloc/list/driver_list_state.dart';
import '../widgets/driver_hero_image.dart';

class DriverListScreen extends StatefulWidget {
  const DriverListScreen({super.key});

  @override
  State<DriverListScreen> createState() => _DriverListScreenState();
}

class _DriverListScreenState extends State<DriverListScreen> {
  final GlobalKey _seasonButtonKey = GlobalKey();

  void _showSeasonPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final renderBox = _seasonButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonOffset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final cubit = context.read<DriverListCubit>();
    final currentSeason = cubit.currentSeason;

    final seasons = ['2026', '2025', '2024', '2023'];

    double top = buttonOffset.dy - 10;
    double left = buttonOffset.dx - 12;

    final estimatedHeight = seasons.length * 46.0 + 30.0;
    if (top + estimatedHeight > screenSize.height - 30) {
      top = screenSize.height - estimatedHeight - 30;
    }
    if (top < 40) top = 40;

    if (!mounted) return;

    final selected = await showGeneralDialog<String>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DriverSeasonPicker',
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
                          for (final season in seasons) ...[
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
                                          color: season == currentSeason
                                              ? Colors.white
                                              : Colors.white70,
                                          fontSize: 16,
                                          fontWeight: season == currentSeason
                                              ? FontWeight.bold
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (season == currentSeason)
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

    if (selected != null && selected != currentSeason) {
      cubit.loadDrivers(season: selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DriverListCubit, DriverListState>(
          builder: (context, state) {
            return switch (state) {
              DriverListLoading() => Center(
                child: CircularProgressIndicator(color: theme.colorScheme.onSurface),
              ),
              DriverListError() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 64, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      l10n.errorLoading,
                      style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                      onPressed: () =>
                          context.read<DriverListCubit>().loadDrivers(),
                    ),
                  ],
                ),
              ),
              DriverListNotFound(:final query) => Center(
                child: Text(
                  '"$query": ${l10n.notFoundSubtitle}',
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ),
              DriverListLoaded(:final drivers) => _DriversContent(
                drivers: drivers,
                seasonButtonKey: _seasonButtonKey,
                onShowSeasonPicker: () => _showSeasonPicker(context),
              ),
            };
          },
        ),
      ),
    );
  }
}

class _DriversContent extends StatelessWidget {
  final List<dynamic> drivers;
  final GlobalKey seasonButtonKey;
  final VoidCallback onShowSeasonPicker;

  const _DriversContent({
    required this.drivers,
    required this.seasonButtonKey,
    required this.onShowSeasonPicker,
  });

  @override
  Widget build(BuildContext context) {
    if (drivers.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final leader = drivers.first;
    final leaderTeamColor = F1Colors.getTeamColor(leader.teamName);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 320,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  top: -400,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.5, 0.91, 1],
                        colors: [
                          leaderTeamColor.withValues(alpha: 0.5),
                          leaderTeamColor.withValues(alpha: 0.28),
                          leaderTeamColor.withValues(alpha: 0.08),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 12,
                  top: 30,
                  bottom: 30,
                  width: 200,
                  child: DriverHeroImage(
                    driverId: leader.id,
                    alignment: Alignment.topRight,
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 90,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 1.0],
                          colors: [
                            Colors.transparent,
                            theme.scaffoldBackgroundColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        key: seasonButtonKey,
                        onTap: onShowSeasonPicker,
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.driversTable,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.unfold_more,
                              size: 22,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: InkWell(
                    onTap: () => context.push('/drivers/${leader.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 38,
                            child: Text(
                              '01',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leader.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  leader.teamName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: leaderTeamColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${leader.points}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                l10n.driverPointsShort,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final driver = drivers[index + 1];
              final positionNumber = (index + 2).toString().padLeft(2, '0');
              final teamColor = F1Colors.getTeamColor(driver.teamName);

              return InkWell(
                onTap: () => context.push('/drivers/${driver.id}'),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 38,
                            child: Text(
                              positionNumber,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  driver.teamName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: teamColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${driver.points}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.onSurface,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                l10n.driverPointsShort,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.chevron_right,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: theme.dividerColor,
                      height: 1,
                    ),
                  ],
                ),
              );
            },
            childCount: drivers.length - 1,
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 105),
        ),
      ],
    );
  }
}