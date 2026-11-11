import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;

    final items = [
      _NavBarItemData(
        builder: (color, isSelected) => HomeStadiumIcon(
          size: 24,
          color: color,
          isFilled: isSelected,
        ),
      ),
      _NavBarItemData(
        builder: (color, isSelected) => Icon(
          isSelected
              ? Icons.sports_motorsports_rounded
              : Icons.sports_motorsports_outlined,
          color: color,
          size: isSelected ? 25 : 23,
        ),
      ),
      _NavBarItemData(
        builder: (color, isSelected) => TrophyCupIcon(
          size: 24,
          color: color,
          isFilled: isSelected,
        ),
      ),
      _NavBarItemData(
        builder: (color, isSelected) => CalendarDotsIcon(
          size: 24,
          color: color,
          isFilled: isSelected,
        ),
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(40, 0, 40, 16),
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xDC1C1C22),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / items.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.fastOutSlowIn,
                    left: currentIndex * itemWidth + 3,
                    top: 3,
                    width: itemWidth - 6,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF101014),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),

                  Row(
                    children: List.generate(items.length, (index) {
                      final isSelected = index == currentIndex;
                      final item = items[index];
                      final color = isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55);

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => _onDestinationSelected(index),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: item.builder(color, isSelected),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavBarItemData {
  final Widget Function(Color color, bool isSelected) builder;

  const _NavBarItemData({
    required this.builder,
  });
}

class HomeStadiumIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isFilled;

  const HomeStadiumIcon({
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.85),
      painter: _HomeStadiumIconPainter(color: color, isFilled: isFilled),
    );
  }
}

class _HomeStadiumIconPainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _HomeStadiumIconPainter({required this.color, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = (w * 0.09).clamp(1.8, 2.5);

    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bar1Rect = RRect.fromLTRBR(
      w * 0.22, 0, w * 0.78, h * 0.16,
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(bar1Rect, paint);

    final bar2Rect = RRect.fromLTRBR(
      w * 0.12, h * 0.26, w * 0.88, h * 0.42,
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(bar2Rect, paint);

    final path = Path();
    path.moveTo(w * 0.08, h * 0.52);
    path.lineTo(w * 0.92, h * 0.52);
    path.lineTo(w * 0.82, h * 0.82);
    path.arcToPoint(
      Offset(w * 0.18, h * 0.82),
      radius: Radius.circular(w * 0.32),
      clockwise: true,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HomeStadiumIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}

class TrophyCupIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isFilled;

  const TrophyCupIcon({
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TrophyCupIconPainter(color: color, isFilled: isFilled),
    );
  }
}

class _TrophyCupIconPainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _TrophyCupIconPainter({required this.color, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = (w * 0.09).clamp(1.8, 2.5);

    final paint = Paint()
      ..color = color
      ..style = isFilled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final strokeOnlyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final baseRRect = RRect.fromLTRBR(
      w * 0.28, h * 0.72, w * 0.72, h * 0.88,
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(baseRRect, paint);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.62),
      Offset(w * 0.50, h * 0.72),
      strokeOnlyPaint,
    );

    final bowlPath = Path();
    bowlPath.moveTo(w * 0.24, h * 0.18);
    bowlPath.lineTo(w * 0.76, h * 0.18);
    bowlPath.cubicTo(
      w * 0.76, h * 0.48,
      w * 0.62, h * 0.62,
      w * 0.50, h * 0.62,
    );
    bowlPath.cubicTo(
      w * 0.38, h * 0.62,
      w * 0.24, h * 0.48,
      w * 0.24, h * 0.18,
    );
    bowlPath.close();

    canvas.drawPath(bowlPath, paint);

    final leftHandle = Path();
    leftHandle.moveTo(w * 0.24, h * 0.24);
    leftHandle.cubicTo(
      w * 0.08, h * 0.24,
      w * 0.08, h * 0.44,
      w * 0.24, h * 0.44,
    );
    canvas.drawPath(leftHandle, strokeOnlyPaint);

    final rightHandle = Path();
    rightHandle.moveTo(w * 0.76, h * 0.24);
    rightHandle.cubicTo(
      w * 0.92, h * 0.24,
      w * 0.92, h * 0.44,
      w * 0.76, h * 0.44,
    );
    canvas.drawPath(rightHandle, strokeOnlyPaint);
  }

  @override
  bool shouldRepaint(covariant _TrophyCupIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}

class CalendarDotsIcon extends StatelessWidget {
  final double size;
  final Color color;
  final bool isFilled;

  const CalendarDotsIcon({
    super.key,
    this.size = 24,
    this.color = Colors.white,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CalendarDotsIconPainter(color: color, isFilled: isFilled),
    );
  }
}

class _CalendarDotsIconPainter extends CustomPainter {
  final Color color;
  final bool isFilled;

  _CalendarDotsIconPainter({required this.color, required this.isFilled});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = (w * 0.09).clamp(1.8, 2.5);
    final dotRadius = w * 0.055;

    final boxRRect = RRect.fromLTRBR(
      w * 0.12, h * 0.12, w * 0.88, h * 0.88,
      Radius.circular(w * 0.20),
    );

    if (isFilled) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawRRect(boxRRect, fillPaint);

      final cutoutPaint = Paint()
        ..color = const Color(0xFF101014)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(w * 0.22, h * 0.28),
        Offset(w * 0.78, h * 0.28),
        cutoutPaint,
      );

      final dotCutoutPaint = Paint()
        ..color = const Color(0xFF101014)
        ..style = PaintingStyle.fill;

      final dots = [
        Offset(w * 0.32, h * 0.48),
        Offset(w * 0.50, h * 0.48),
        Offset(w * 0.68, h * 0.48),
        Offset(w * 0.32, h * 0.68),
        Offset(w * 0.50, h * 0.68),
      ];

      for (final dot in dots) {
        canvas.drawCircle(dot, dotRadius, dotCutoutPaint);
      }
    } else {
      final strokePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;
      canvas.drawRRect(boxRRect, strokePaint);

      canvas.drawLine(
        Offset(w * 0.14, h * 0.28),
        Offset(w * 0.86, h * 0.28),
        strokePaint,
      );

      final dotFillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final dots = [
        Offset(w * 0.32, h * 0.48),
        Offset(w * 0.50, h * 0.48),
        Offset(w * 0.68, h * 0.48),
        Offset(w * 0.32, h * 0.68),
        Offset(w * 0.50, h * 0.68),
      ];

      for (final dot in dots) {
        canvas.drawCircle(dot, dotRadius, dotFillPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CalendarDotsIconPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.isFilled != isFilled;
}