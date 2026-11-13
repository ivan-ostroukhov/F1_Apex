import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:f1_app/common/localization/generated/app_localizations.dart';
import '../../../../common/utils/f1_colors.dart';
import '../../../../common/utils/f1_media.dart';
import '../../../../common/widgets/animated_digit_text.dart';
import '../../domain/constructor_detail_model.dart';
import '../../domain/constructor_repository.dart';

class ConstructorDetailScreen extends StatefulWidget {
  final String constructorId;

  const ConstructorDetailScreen({
    super.key,
    required this.constructorId,
  });

  @override
  State<ConstructorDetailScreen> createState() => _ConstructorDetailScreenState();
}

class _ConstructorDetailScreenState extends State<ConstructorDetailScreen> {
  final GlobalKey _seasonButtonKey = GlobalKey();
  String _selectedSeason = '2026';
  List<String> _seasons = [];
  late Future<ConstructorDetailModel> _detailFuture;

  @override
  void initState() {
    super.initState();
    _loadData(_selectedSeason);
    _fetchSeasons();
  }

  void _loadData(String season) {
    setState(() {
      _selectedSeason = season;
      _detailFuture = context
          .read<IConstructorRepository>()
          .getConstructorDetails(widget.constructorId, season: season);
    });
  }

  Future<void> _fetchSeasons() async {
    try {
      final seasons = await context
          .read<IConstructorRepository>()
          .getConstructorSeasons(widget.constructorId);
      if (mounted) {
        setState(() {
          _seasons = seasons;
          if (_seasons.isNotEmpty && !_seasons.contains(_selectedSeason)) {
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

    final availableSeasons = _seasons.isNotEmpty
        ? _seasons.take(4).toList()
        : ['2026', '2025', '2024', '2023'];

    double top = buttonOffset.dy - 10;
    double left = buttonOffset.dx - 12;

    final estimatedHeight = availableSeasons.length * 46.0 + 30.0;
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<ConstructorDetailModel>(
        future: _detailFuture,
        builder: (context, snapshot) {
          final detail = snapshot.data;
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          final teamName = detail?.name ?? widget.constructorId.toUpperCase();
          final teamColor = F1Colors.getTeamColor(teamName);
          final chassis = detail?.chassis ?? 'F1 2026';

          final posStr = isLoading
              ? '..'
              : (detail != null && detail.position != '0'
                  ? detail.position.padLeft(2, '0')
                  : '—');
          final ptsStr = isLoading ? '..' : (detail?.points ?? '0');
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

          final carAssetPath = detail?.carAssetPath.isNotEmpty == true
              ? detail!.carAssetPath
              : F1Media.getCarAssetPath(widget.constructorId);

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
                            center: const Alignment(0.7, -0.5),
                            radius: 1.3,
                            stops: const [0.0, 0.45, 0.85, 1.0],
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
                      right: -10,
                      top: 40,
                      bottom: 0,
                      width: 250,
                      child: Transform.scale(
                        scale: 0.85,
                        child: Image.asset(
                          carAssetPath,
                          fit: BoxFit.contain,
                          alignment: Alignment.topRight,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.sports_motorsports,
                            size: 140,
                            color: Colors.white12,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 240,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.0, 0.25, 0.60, 1.0],
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.60),
                                Colors.black.withValues(alpha: 0.95),
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
                              teamName,
                              style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              chassis,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: teamColor,
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
                                    l10n.seasonPrefix(_selectedSeason),
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

                            _buildBigStat(posStr, l10n.driverPositionShort),
                            const SizedBox(height: 10),
                            _buildBigStat(ptsStr, l10n.driverPointsShort),
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
                Divider(
                  color: Colors.white.withValues(alpha: 0.08),
                  height: 1,
                ),

                if (detail != null && detail.drivers.isNotEmpty) ...[
                  for (final d in detail.drivers) ...[
                    InkWell(
                      onTap: () => context.push('/drivers/${d.id}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Text(
                              d.permanentNumber != '0' ? d.permanentNumber : '—',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: teamColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.code,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  d.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.08),
                      height: 1,
                    ),
                  ],
                ],

                _buildDetailTile(
                  leading: Text(
                    chassis.length > 2 ? chassis.substring(0, 2) : chassis,
                    style: TextStyle(
                      color: teamColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  title: chassis,
                  subtitle: l10n.chassisLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white70,
                    size: 24,
                  ),
                  title: isLoading ? 'Загрузка...' : (detail?.engine ?? '—'),
                  subtitle: l10n.engineLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.person_outline,
                    color: Colors.white70,
                    size: 24,
                  ),
                  title: isLoading ? 'Загрузка...' : (detail?.teamPrincipal ?? '—'),
                  subtitle: l10n.teamPrincipalLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.flag_circle_outlined,
                    color: Colors.white70,
                    size: 24,
                  ),
                  title: isLoading ? 'Загрузка...' : (detail?.firstRace ?? '—'),
                  subtitle: l10n.firstRaceLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.emoji_events_outlined,
                    color: Colors.white70,
                    size: 24,
                  ),
                  title: isLoading
                      ? '..'
                      : '${detail?.constructorsTitles ?? 0}',
                  subtitle: l10n.constructorsChampionshipsLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.military_tech_outlined,
                    color: Colors.white70,
                    size: 24,
                  ),
                  title: isLoading ? '..' : '${detail?.driversTitles ?? 0}',
                  subtitle: l10n.driversChampionshipsLabel,
                ),

                _buildDetailTile(
                  leading: const Icon(
                    Icons.public,
                    color: Colors.white70,
                    size: 24,
                  ),
                  title: isLoading ? 'Загрузка...' : (detail?.baseLocation ?? '—'),
                  subtitle: l10n.baseLabel,
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
        AnimatedDigitText(
          text: value,
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
            AnimatedDigitText(
              text: value,
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