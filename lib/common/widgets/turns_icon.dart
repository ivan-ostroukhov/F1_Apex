import 'package:flutter/material.dart';

class TurnsIcon extends StatelessWidget {
  final double size;
  final Color color;

  const TurnsIcon({
    super.key,
    this.size = 22,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _TurnsIconPainter(color: color),
    );
  }
}

class _TurnsIconPainter extends CustomPainter {
  final Color color;

  _TurnsIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeWidth = (w * 0.14).clamp(2.0, 4.0);
    final dotRadius = (w * 0.14).clamp(2.0, 4.0);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final topCenter = Offset(w * 0.45, h * 0.22);
    final bottomCenter = Offset(w * 0.45, h * 0.78);

    canvas.drawCircle(topCenter, dotRadius, fillPaint);
    canvas.drawCircle(bottomCenter, dotRadius, fillPaint);

    final path = Path();
    path.moveTo(topCenter.dx, topCenter.dy);
    path.cubicTo(
      w * 0.88, h * 0.22,
      w * 0.88, h * 0.50,
      w * 0.50, h * 0.50,
    );
    path.cubicTo(
      w * 0.12, h * 0.50,
      w * 0.12, h * 0.78,
      bottomCenter.dx, bottomCenter.dy,
    );

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _TurnsIconPainter oldDelegate) =>
      oldDelegate.color != color;
}