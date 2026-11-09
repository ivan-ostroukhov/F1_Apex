import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/localization/generated/app_localizations.dart';
import '../../../../common/utils/f1_colors.dart';
import '../../../../common/utils/f1_media.dart';
import '../../../../common/widgets/turns_icon.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../domain/models/circuit_stats.dart';
import '../../domain/models/race_model.dart';

class RaceDetailScreen extends StatefulWidget {
  final RaceModel race;

  const RaceDetailScreen({
    super.key,
    required this.race,
  });

  @override
  State<RaceDetailScreen> createState() => _RaceDetailScreenState();
}

class _RaceDetailScreenState extends State<RaceDetailScreen> {
  List<PodiumDriver>? _podium;

  @override
  void initState() {
    super.initState();
    _podium = widget.race.podium;
    if ((_podium == null || _podium!.isEmpty) && widget.race.isCompleted) {
      _fetchPodium();
    }
  }

  Future<void> _fetchPodium() async {
    try {
      final repository = ScheduleRepository();
      final podium = await repository.getPodiumForRound(widget.race.round);
      if (mounted && podium.isNotEmpty) {
        setState(() {
          _podium = podium;
        });
      }
    } catch (_) {}
  }

  String _getDriverIdFromCode(String code) {
    final c = code.toUpperCase();
    switch (c) {
      case 'VER': return 'verstappen';
      case 'LEC': return 'leclerc';
      case 'HAM': return 'hamilton';
      case 'ANT': return 'antonelli';
      case 'NOR': return 'norris';
      case 'PIA': return 'piastri';
      case 'SAI': return 'sainz';
      case 'ALO': return 'alonso';
      case 'RUS': return 'russell';
      case 'LAW': return 'lawson';
      case 'STR': return 'stroll';
      case 'TSU': return 'tsunoda';
      case 'GAS': return 'gasly';
      case 'OCO': return 'ocon';
      case 'ALB': return 'albon';
      case 'HUL': return 'hulkenberg';
      case 'MAG': return 'magnussen';
      case 'BEA': return 'bearman';
      case 'BOR': return 'bortoleto';
      case 'DOO': return 'doohan';
      case 'HAD': return 'hadjar';
      default: return code.toLowerCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topPadding = MediaQuery.paddingOf(context).top;
    final circuitColor = F1Colors.getCircuitColor(
      widget.race.circuitId.isNotEmpty ? widget.race.circuitId : widget.race.raceName,
    );

    final stats = CircuitStats.getFor(widget.race.circuitId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -400,
                  left: -100,
                  right: -100,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.85, -0.1),
                        radius: 1.15,
                        colors: [
                          circuitColor.withValues(alpha: 0.70),
                          circuitColor.withValues(alpha: 0.32),
                          circuitColor.withValues(alpha: 0.08),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.45, 0.8, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 60,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.race.raceName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.race.circuitName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: circuitColor.withValues(alpha: 0.95),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.race.dateRange,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      stats.lengthKm,
                                      style: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -1,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.kmUnit,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white54,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _StatRow(
                                  icon: Icons.repeat_rounded,
                                  value: '${stats.laps}',
                                  label: l10n.lapsCountLabel,
                                ),
                                const SizedBox(height: 14),
                                _StatRow(
                                  customIcon: const TurnsIcon(size: 36, color: Colors.white70),
                                  value: '${stats.corners}',
                                  label: l10n.turns,
                                ),
                                const SizedBox(height: 14),
                                _StatRow(
                                  icon: Icons.speed_rounded,
                                  value: '${stats.maxSpeed} ${l10n.kmhUnit}',
                                  label: l10n.topSpeed,
                                ),
                                const SizedBox(height: 14),
                                _StatRow(
                                  icon: Icons.height_rounded,
                                  value: '${stats.elevation} ${l10n.mUnit}',
                                  label: l10n.elevationChangeLabel,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 6,
                            child: SizedBox(
                              height: 270,
                              child: Transform.translate(
                                offset: const Offset(-10, 0),
                                child: Transform.scale(
                                  scale: 1.15,
                                  child: Image.asset(
                                    F1Media.getTrackAssetPath(widget.race.circuitId),
                                    fit: BoxFit.contain,
                                    alignment: Alignment.centerLeft,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.polyline_rounded,
                                      size: 240,
                                      color: circuitColor.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_podium != null && _podium!.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _podium!.map((driver) {
                            final teamColor = F1Colors.getTeamColor(driver.teamName);
                            final driverId = _getDriverIdFromCode(driver.code);

                            return GestureDetector(
                              onTap: () => context.push('/drivers/$driverId'),
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _SlantedStripes(color: teamColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    driver.code,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.weekendSessions,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final session = widget.race.sessions[index];
                return _SessionTile(session: session);
              },
              childCount: widget.race.sessions.length,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 40),
          ),
        ],
      ),
    );
  }
}

class _SlantedStripes extends StatelessWidget {
  final Color color;

  const _SlantedStripes({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(26, 14),
      painter: _SlantedStripesPainter(color: color),
    );
  }
}

class _SlantedStripesPainter extends CustomPainter {
  final Color color;

  _SlantedStripesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const double stripeWidth = 5.5;
    const double gap = 3.0;
    const double slant = 6.0;

    for (int i = 0; i < 3; i++) {
      final startX = i * (stripeWidth + gap);
      final path = Path()
        ..moveTo(startX + slant, 0)
        ..lineTo(startX + slant + stripeWidth, 0)
        ..lineTo(startX + stripeWidth, size.height)
        ..lineTo(startX, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SlantedStripesPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _StatRow extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String value;
  final String label;

  const _StatRow({
    this.icon,
    this.customIcon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: customIcon ?? Icon(icon, size: 40, color: Colors.white70),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final RaceSession session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(
          color: Colors.white.withValues(alpha: 0.08),
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.day,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      session.dayOfWeek,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      session.timeRange,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}