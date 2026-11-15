import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../common/utils/f1_media.dart';
import '../../../schedule/domain/models/race_model.dart';

class RaceScheduleGlassWidget extends StatelessWidget {
  final RaceModel? race;
  final bool is24Hour;
  final double width;
  final double? height;

  const RaceScheduleGlassWidget({
    super.key,
    this.race,
    this.is24Hour = true,
    this.width = 540,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRace = race ?? _createFallbackRace();
    final sessions = _extractDisplaySessions(effectiveRace);
    final countryCode = _resolveCountryCode(effectiveRace);
    final trackAsset = F1Media.getTrackAssetPath(effectiveRace.circuitId);
    final nextSession = _findNextSession(effectiveRace);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFFE10600).withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: CustomPaint(
            painter: _GlassStripesPainter(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF231F20).withValues(alpha: 0.88),
                    const Color(0xFF141315).withValues(alpha: 0.92),
                    const Color(0xFF0D0D0E).withValues(alpha: 0.96),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSessionsRow(sessions),
                  const SizedBox(height: 18),
                  _buildRaceInfoSection(
                    race: effectiveRace,
                    countryCode: countryCode,
                    trackAsset: trackAsset,
                    nextSession: nextSession,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsRow(List<_SessionDisplayItem> sessions) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: sessions.map((item) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 2.5,
                    height: 38,
                    margin: const EdgeInsets.only(top: 2, right: 6),
                    decoration: BoxDecoration(
                      color: item.isNext
                          ? const Color(0xFF00D2BE)
                          : (item.isCompleted ? Colors.white24 : const Color(0xFF2BE080)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.shortTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: item.isNext ? Colors.white : Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.dateStr,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          item.timeStr,
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRaceInfoSection({
    required RaceModel race,
    required String countryCode,
    required String trackAsset,
    required RaceSession? nextSession,
  }) {
    final roundNumber = race.round.padLeft(2, '0');
    final sessionName = nextSession?.title ?? 'Race';
    final targetDate = nextSession?.startTime ?? race.date;
    final dateFormatted = targetDate != null
        ? DateFormat(is24Hour ? 'dd MMM | HH:mm' : 'dd MMM | hh:mm a').format(targetDate).toUpperCase()
        : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                race.country.isNotEmpty ? race.country : 'United States',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                race.locality.isNotEmpty ? race.locality : 'Las Vegas',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF00D2BE),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$roundNumber/',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.18),
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sessionName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateFormatted,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 84,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Positioned(
                  right: 4,
                  child: Text(
                    countryCode,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.07),
                      fontSize: 68,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      trackAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        return Image.asset(
                          'assets/images/tracks/las_vegas.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_SessionDisplayItem> _extractDisplaySessions(RaceModel race) {
    final now = DateTime.now();
    final items = <_SessionDisplayItem>[];

    if (race.sessions.isEmpty) {
      final baseDate = race.date ?? DateTime(2026, 11, 21, 22, 0);
      final fp1 = baseDate.subtract(const Duration(days: 2, hours: 8));
      final fp2 = baseDate.subtract(const Duration(days: 2, hours: 4));
      final fp3 = baseDate.subtract(const Duration(days: 1, hours: 8));
      final quali = baseDate.subtract(const Duration(days: 1, hours: 4));

      return [
        _SessionDisplayItem('FP1', fp1, is24Hour, now),
        _SessionDisplayItem('FP2', fp2, is24Hour, now),
        _SessionDisplayItem('FP3', fp3, is24Hour, now),
        _SessionDisplayItem('Quali', quali, is24Hour, now),
        _SessionDisplayItem('Race', baseDate, is24Hour, now),
      ];
    }

    for (final s in race.sessions) {
      String short = s.title;
      final lower = short.toLowerCase();
      if (lower.contains('practice 1')) {
        short = 'FP1';
      } else if (lower.contains('practice 2')) {
        short = 'FP2';
      } else if (lower.contains('practice 3')) {
        short = 'FP3';
      } else if (lower.contains('sprint qualifying')) {
        short = 'Sprint SQ';
      } else if (lower.contains('sprint')) {
        short = 'Sprint';
      } else if (lower.contains('qualifying')) {
        short = 'Quali';
      } else if (lower.contains('race')) {
        short = 'Race';
      }

      items.add(_SessionDisplayItem(short, s.startTime, is24Hour, now));
    }

    return items.take(5).toList();
  }

  RaceSession? _findNextSession(RaceModel race) {
    final now = DateTime.now();
    for (final s in race.sessions) {
      if (s.startTime.isAfter(now)) {
        return s;
      }
    }
    return race.sessions.isNotEmpty ? race.sessions.last : null;
  }

  String _resolveCountryCode(RaceModel race) {
    final c = race.country.toLowerCase();
    if (c.contains('saudi')) return 'SAU';
    if (c.contains('united states') || c.contains('usa')) return 'USA';
    if (c.contains('vegas')) return 'LVS';
    if (c.contains('bahrain')) return 'BHR';
    if (c.contains('australia')) return 'AUS';
    if (c.contains('japan')) return 'JPN';
    if (c.contains('china')) return 'CHN';
    if (c.contains('miami')) return 'MIA';
    if (c.contains('italy') || c.contains('imola') || c.contains('monza')) return 'ITA';
    if (c.contains('monaco')) return 'MON';
    if (c.contains('canada')) return 'CAN';
    if (c.contains('spain')) return 'ESP';
    if (c.contains('austria')) return 'AUT';
    if (c.contains('britain') || c.contains('united kingdom')) return 'GBR';
    if (c.contains('hungary')) return 'HUN';
    if (c.contains('belgium')) return 'BEL';
    if (c.contains('netherlands')) return 'NLD';
    if (c.contains('azerbaijan')) return 'AZE';
    if (c.contains('singapore')) return 'SGP';
    if (c.contains('mexico')) return 'MEX';
    if (c.contains('brazil')) return 'BRA';
    if (c.contains('qatar')) return 'QAT';
    if (c.contains('abu dhabi') || c.contains('uae')) return 'UAE';
    return race.country.length >= 3 ? race.country.substring(0, 3).toUpperCase() : 'F1';
  }

  RaceModel _createFallbackRace() {
    return RaceModel(
      round: '21',
      raceName: 'Las Vegas Grand Prix',
      circuitId: 'las_vegas',
      circuitName: 'Las Vegas Strip Circuit',
      locality: 'Las Vegas',
      country: 'United States',
      date: DateTime(2026, 11, 22, 06, 0),
      dateRange: '19 - 22 Nov',
      isCompleted: false,
    );
  }
}

class _SessionDisplayItem {
  final String shortTitle;
  final DateTime time;
  final bool is24Hour;
  final DateTime now;

  _SessionDisplayItem(this.shortTitle, this.time, this.is24Hour, this.now);

  String get dateStr => DateFormat('MMM dd').format(time);

  String get timeStr {
    return is24Hour
        ? DateFormat('HH:mm').format(time)
        : DateFormat('hh:mm a').format(time);
  }

  bool get isCompleted => time.isBefore(now);
  bool get isNext => !isCompleted && time.difference(now).inHours <= 36;
}

class _GlassStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.02)
      ..strokeWidth = 1.0;

    const spacing = 10.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, size.height),
        Offset(i + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
