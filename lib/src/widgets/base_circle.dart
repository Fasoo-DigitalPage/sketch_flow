import 'package:flutter/material.dart';

class BaseCircle extends StatelessWidget {
  const BaseCircle({
    super.key,
    required this.color,
    required this.radius,
    required this.onClickCircle,
  });

  final double radius;
  final Color color;
  final Function() onClickCircle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: SizedBox(
        width: radius,
        height: radius,
        child: CustomPaint(
          painter: BaseCirclePainter(radius: radius, color: color),
        ),
      ),
      onPressed: onClickCircle,
    );
  }
}

class BaseCirclePainter extends CustomPainter {
  BaseCirclePainter({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final fillPaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final strokePaint =
        Paint()
          ..color = Color(0xCFCFCFCF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
