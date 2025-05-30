import 'package:flutter/material.dart';

class BaseThickness extends StatelessWidget {
  const BaseThickness({
    super.key,
    required this.radius,
    required this.index,
    required this.isSelected,
    required this.color,
    required this.onClickThickness,
    required this.selectColor,
  });

  final double radius;
  final int index;
  final bool isSelected;
  final Color color;
  final Color selectColor;
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
            index: index,
            isSelected: isSelected,
            color: color,
            selectColor: selectColor
          ),
        ),
      ),
      onPressed: onClickThickness,
    );
  }
}

class BaseThicknessPainter extends CustomPainter {
  BaseThicknessPainter({
    required this.index,
    required this.radius,
    required this.isSelected,
    required this.color,
    required this.selectColor,
  });

  final double radius;
  final bool isSelected;
  final Color color;
  final Color selectColor;
  final int index;

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
      ..color = isSelected ? selectColor : color
      ..strokeWidth = index * 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      center,
      radius,
      isSelected ? fillCirclePaint : strokePaint,
    );
    canvas.drawCircle(center, radius, strokePaint);

    final start = Offset(center.dx - radius + (radius * 0.4), center.dy);
    final end = Offset(center.dx + radius - (radius * 0.4), center.dy);
    canvas.drawLine(start, end, thicknessPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
