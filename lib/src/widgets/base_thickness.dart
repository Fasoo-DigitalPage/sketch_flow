import 'package:flutter/material.dart';

/// [radius] 아이콘 원 반지름
///
/// [thickness] 굵기
///
/// [onClickThickness] 선택 콜백 함수
class BaseThickness extends StatelessWidget {
  const BaseThickness({
    super.key,
    required this.radius,
    required this.thickness,
    required this.onClickThickness
  });

  final double radius;
  final double thickness;
  final Function() onClickThickness;

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: SizedBox(
          width: radius,
          height: radius,
          child: CustomPaint(
            painter: BaseThicknessPainter(
                radius: radius,
                thickness: thickness
            ),
          ),
        ),
        onPressed: onClickThickness,
    );
  }
}

class BaseThicknessPainter extends CustomPainter {
  BaseThicknessPainter({required this.thickness, required this.radius});

  final double radius;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final circlePaint = Paint()
      ..color = Color.fromARGB(255, 175, 175, 175)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final thicknessPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, circlePaint);

    final start = Offset(center.dx-radius+(radius * 0.4), center.dy);
    final end = Offset(center.dx+radius-(radius * 0.4), center.dy);
    canvas.drawLine(start, end, thicknessPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}