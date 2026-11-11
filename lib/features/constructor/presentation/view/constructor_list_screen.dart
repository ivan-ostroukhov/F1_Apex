import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:f1_app/common/localization/generated/app_localizations.dart';
import '../../../../common/utils/f1_colors.dart';
import '../../../../common/utils/f1_media.dart';
import '../../domain/constructor_model.dart';
import '../../domain/constructor_repository.dart';
import '../bloc/constructor_list_cubit.dart';
import '../bloc/constructor_list_state.dart';

class ConstructorListScreen extends StatefulWidget {
  const ConstructorListScreen({super.key});

  @override
  State<ConstructorListScreen> createState() => _ConstructorListScreenState();
}

class _ConstructorListScreenState extends State<ConstructorListScreen> {
  final GlobalKey _seasonButtonKey = GlobalKey();

  String _getCarModel(String teamName) {
    final lower = teamName.toLowerCase();
    if (lower.contains('mercedes')) return 'F1 W17';
    if (lower.contains('ferrari')) return 'SF-26';
    if (lower.contains('red bull')) return 'RB22';
    if (lower.contains('mclaren')) return 'MCL40';
    if (lower.contains('aston')) return 'AMR26';
    if (lower.contains('alpine')) return 'A526';
    if (lower.contains('williams')) return 'FW48';
    if (lower.contains('haas')) return 'VF-26';
    if (lower.contains('rb') || lower.contains('racing bulls') || lower.contains('alphatauri')) return 'VCARB 03';
    if (lower.contains('sauber') || lower.contains('kick')) return 'C46';
    return 'F1 2026';
  }

  String _getTeamImageId(String teamName) {
    final lower = teamName.toLowerCase();
    if (lower.contains('mercedes')) return 'mercedes';
    if (lower.contains('ferrari')) return 'ferrari';
    if (lower.contains('red bull')) return 'red_bull';
    if (lower.contains('mclaren')) return 'mclaren';
    if (lower.contains('aston')) return 'aston_martin';
    if (lower.contains('alpine')) return 'alpine';
    if (lower.contains('williams')) return 'williams';
    if (lower.contains('haas')) return 'haas';
    if (lower.contains('rb') || lower.contains('racing bulls')) return 'rb';
    if (lower.contains('sauber') || lower.contains('kick')) return 'sauber';
    return 'f1';
  }

  void _showSeasonPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final renderBox = _seasonButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonOffset = renderBox.localToGlobal(Offset.zero);
    final screenSize = MediaQuery.of(context).size;
    final cubit = context.read<ConstructorListCubit>();
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
      barrierLabel: 'ConstructorSeasonPicker',
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
      cubit.loadConstructors(season: selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (context) =>
          ConstructorListCubit(context.read<IConstructorRepository>())
            ..loadConstructors(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<ConstructorListCubit, ConstructorListState>(
            builder: (context, state) {
              final l10n = AppLocalizations.of(context)!;

              return switch (state) {
                ConstructorListLoading() => Center(
                    child: CircularProgressIndicator(color: theme.colorScheme.onSurface),
                  ),
                ConstructorListError() => Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.errorLoading,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                          onPressed: () => context
                              .read<ConstructorListCubit>()
                              .loadConstructors(),
                        ),
                      ],
                    ),
                  ),
                ConstructorListNotFound(:final query) => Center(
                    child: Text(
                      '"$query": ${l10n.notFoundSubtitle}',
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    ),
                  ),
                ConstructorListLoaded(:final constructors) =>
                  _ConstructorsContent(
                    constructors: constructors,
                    seasonButtonKey: _seasonButtonKey,
                    getCarModel: _getCarModel,
                    getTeamImageId: _getTeamImageId,
                    onShowSeasonPicker: () => _showSeasonPicker(context),
                  ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _ConstructorsContent extends StatelessWidget {
  final List<ConstructorModel> constructors;
  final GlobalKey seasonButtonKey;
  final String Function(String) getCarModel;
  final String Function(String) getTeamImageId;
  final VoidCallback onShowSeasonPicker;

  const _ConstructorsContent({
    required this.constructors,
    required this.seasonButtonKey,
    required this.getCarModel,
    required this.getTeamImageId,
    required this.onShowSeasonPicker,
  });

  @override
  Widget build(BuildContext context) {
    if (constructors.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final leader = constructors.first;
    final leaderColor = F1Colors.getTeamColor(leader.name);
    final leaderCarAsset = F1Media.getCarAssetPath(leader.id.isNotEmpty ? leader.id : leader.name);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  top: -400,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.7, -0.5),
                        radius: 1.3,
                        stops: const [0.0, 0.45, 0.85, 1.0],
                        colors: [
                          leaderColor.withValues(alpha: 0.55),
                          leaderColor.withValues(alpha: 0.28),
                          leaderColor.withValues(alpha: 0.08),
                          theme.scaffoldBackgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  right: 35,
                  top: 20,
                  width: 280,
                  height: 240,
                  child: Transform.scale(
                    scale: 1.1,
                    child: Image.asset(
                      leaderCarAsset,
                      fit: BoxFit.contain,
                      alignment: Alignment.topRight,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.sports_motorsports,
                        size: 120,
                        color: Colors.white12,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 120,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: const [0.0, 0.35, 0.70, 1.0],
                          colors: [
                            Colors.transparent,
                            theme.scaffoldBackgroundColor.withValues(alpha: 0.50),
                            theme.scaffoldBackgroundColor.withValues(alpha: 0.88),
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
                              l10n.constructorsTable,
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
              ],
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = constructors[index];
              final teamColor = F1Colors.getTeamColor(item.name);
              final carModel = getCarModel(item.name);
              final posStr = item.position.toString().padLeft(2, '0');

              return InkWell(
                onTap: () => context.push('/constructors/${item.id}'),
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
                              posStr,
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
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  carModel,
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
                                '${item.points}',
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
            childCount: constructors.length,
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 40),
        ),
      ],
    );
  }
}