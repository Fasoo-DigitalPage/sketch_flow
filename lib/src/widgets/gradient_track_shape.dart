import 'package:flutter/material.dart';

class GradientTrackShape extends SliderTrackShape {
  final LinearGradient gradient;
  final double trackHeight;
  final double squareSize;

  GradientTrackShape({
    required this.gradient,
    this.trackHeight = 4.0,
    this.squareSize = 4.0,
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

    final Canvas canvas = context.canvas;

    _drawCheckerboard(canvas, trackRect);

    final Paint paint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, Radius.circular(height / 2)),
      paint,
    );
  }

  void _drawCheckerboard(Canvas canvas, Rect rect) {
    final Paint lightPaint = Paint()..color = Colors.white;
    final Paint darkPaint = Paint()..color = Colors.grey.shade300;

    final int horSquares = (rect.width / squareSize).ceil();
    final int verSquares = (rect.height / squareSize).ceil();

    for (int y = 0; y < verSquares; y++) {
      for (int x = 0; x < horSquares; x++) {
        final paint = (x + y) % 2 == 0 ? lightPaint : darkPaint;
        final squareRect = Rect.fromLTWH(
          rect.left + x * squareSize,
          rect.top + y * squareSize,
          squareSize,
          squareSize,
        );
        canvas.drawRect(squareRect, paint);
      }
    }
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
