import 'package:flutter/material.dart';

class GradientTrackShape extends SliderTrackShape {
  final LinearGradient gradient;
  final double trackHeight;

  GradientTrackShape({
    required this.gradient,
    this.trackHeight = 4.0
  });

  @override
  void paint(
      PaintingContext context,
      Offset offset, {
        required Animation<double> enableAnimation,
        required RenderBox parentBox,
        Offset? secondaryOffset,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required Offset thumbCenter,
        bool isEnabled = false,
        bool isDiscrete = false,
      }) {
    final double height = trackHeight;
    final double trackLeft = offset.dx + 8;
    final double trackTop = offset.dy + (parentBox.size.height - height) / 2;
    final double trackWidth = parentBox.size.width - 16;

    final Rect trackRect = Rect.fromLTWH(trackLeft, trackTop, trackWidth, height);

    final Paint paint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..style = PaintingStyle.fill;

    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(height / 2)),
      paint,
    );
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double height = trackHeight;
    final double trackLeft = offset.dx + 8;
    final double trackTop = offset.dy + (parentBox.size.height - height) / 2;
    final double trackWidth = parentBox.size.width - 16;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, height);
  }
}
