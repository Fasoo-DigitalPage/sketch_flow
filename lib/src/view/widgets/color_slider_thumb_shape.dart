import 'package:flutter/material.dart';

class ColorSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;

  final double borderWidth;

  final Color borderColor;

  const ColorSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.borderWidth = 3.0,
    this.borderColor = Colors.white,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final Color innerColor = sliderTheme.thumbColor ?? Colors.black;

    final Paint outerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill;

    final Paint innerPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, enabledThumbRadius, outerPaint);

    final double innerRadius = enabledThumbRadius - borderWidth;
    if (innerRadius > 0) {
      canvas.drawCircle(center, innerRadius, innerPaint);
    }
  }
}