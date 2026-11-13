import 'package:flutter/material.dart';

class RoundPointsChart extends StatelessWidget {
  final List<int?> roundPoints;
  final Color accentColor;

  const RoundPointsChart({
    super.key,
    required this.roundPoints,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    const maxScore = 26;
    const totalRounds = 24;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 22,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _axisLabel('25'),
                      _axisLabel('18'),
                      _axisLabel('15'),
                      _axisLabel('10'),
                      _axisLabel('1'),
                    ],
                  ),
                ),
                const SizedBox(width: 6),


                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(totalRounds, (index) {
                      final score = index < roundPoints.length ? roundPoints[index] : null;
                      final hasScore = score != null;
                      final isPointScoring = hasScore && score > 0;
                      final barHeight = isPointScoring
                          ? ((score / maxScore) * 78).clamp(6.0, 78.0)
                          : 3.0;

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: barHeight,
                                decoration: BoxDecoration(
                                  color: isPointScoring
                                      ? accentColor
                                      : (hasScore
                                          ? accentColor.withValues(alpha: 0.35)
                                          : Colors.white.withValues(alpha: 0.12)),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: isPointScoring
                                      ? [
                                          BoxShadow(
                                            color: accentColor.withValues(alpha: 0.4),
                                            blurRadius: 4,
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              const SizedBox(width: 28),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(totalRounds, (index) {
                    final roundNum = (index + 1).toString().padLeft(2, '0');
                    final isCompleted = index < roundPoints.length && roundPoints[index] != null;
                    return Text(
                      roundNum,
                      style: TextStyle(
                        color: isCompleted ? Colors.white70 : Colors.white24,
                        fontSize: 8.5,
                        fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _axisLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white30, fontSize: 8),
    );
  }
}