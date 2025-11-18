import 'package:flutter/material.dart';

class GradientTrackShape extends SliderTrackShape {
  final LinearGradient gradient;
  final double trackHeight;

  GradientTrackShape({
    required this.gradient,
    this.trackHeight = 4.0,
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

    final Rect trackRect = Rect.fromLTWH(
      trackLeft,
      trackTop,
      trackWidth,
      height,
    );

    final double thumbRadius =
        sliderTheme.thumbShape!.getPreferredSize(isEnabled, isDiscrete).height / 2;

    final RRect trackRRect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(thumbRadius),
    );

    final Canvas canvas = context.canvas;

    canvas.save();
    canvas.clipRRect(trackRRect);

    _drawCheckerboard(canvas, trackRect);

    final Paint paint = Paint()
      ..shader = gradient.createShader(trackRect)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(trackRRect, paint);
    
    canvas.restore();
  }

  void _drawCheckerboard(Canvas canvas, Rect rect) {
    final Paint lightPaint = Paint()..color = Colors.white;
    final Paint darkPaint = Paint()..color = Colors.grey.shade300;

    final int verSquares = 2;

    final double newSquareSize = rect.height / verSquares;

    final int horSquares = (rect.width / newSquareSize).ceil();

    for (int y = 0; y < verSquares; y++) {
      for (int x = 0; x < horSquares; x++) {
        final paint = (x + y) % 2 == 0 ? lightPaint : darkPaint;
        final squareRect = Rect.fromLTWH(
          rect.left + x * newSquareSize,
          rect.top + y * newSquareSize,
          newSquareSize,
          newSquareSize,
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
