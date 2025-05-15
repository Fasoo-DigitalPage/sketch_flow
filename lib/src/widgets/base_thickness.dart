import 'package:flutter/material.dart';

class BaseThickness extends StatelessWidget {
  const BaseThickness({
    super.key,
    required this.radius,
    required this.thickness,
    required this.isSelected,
    required this.color,
    required this.onClickThickness
  });

  final double radius;
  final double thickness;
  final bool isSelected;
  final Color color;
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
                thickness: thickness,
                isSelected: isSelected,
                color: color
            ),
          ),
        ),
        onPressed: onClickThickness,
    );
  }

}

class BaseThicknessPainter extends CustomPainter {
  BaseThicknessPainter({required this.thickness, required this.radius, required this.isSelected, required this.color});

  final double radius;
  final double thickness;
  final bool isSelected;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final strokePaint = Paint()
      ..color = Color(0xCFCFCFCF)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final fillCirclePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final thicknessPaint = Paint()
      ..color = isSelected ? Colors.white : color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, isSelected ? fillCirclePaint : strokePaint);
    canvas.drawCircle(center, radius, strokePaint);

    final start = Offset(center.dx-radius+(radius * 0.4), center.dy);
    final end = Offset(center.dx+radius-(radius * 0.4), center.dy);
    canvas.drawLine(start, end, thicknessPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

}