import 'package:flutter/material.dart';

class ColorPickerSliderShape extends SliderTrackShape {
  final double trackHeight;
  final int colorStepCount;
  final List<Color> colors;

  ColorPickerSliderShape({
    this.trackHeight = 4.0,
    required this.colorStepCount,
    required this.colors,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final double height = trackHeight;
    final double trackLeft = offset.dx + 8;
    final double trackTop = offset.dy + (parentBox.size.height - height) / 2;
    final double trackWidth = parentBox.size.width - 16;

    final Canvas canvas = context.canvas;
    final double rectWidth = trackWidth / colorStepCount;

    final Rect trackRect = Rect.fromLTWH(
      trackLeft,
      trackTop,
      trackWidth,
      height,
    );
    final RRect roundedRect = RRect.fromRectAndRadius(
      trackRect,
      Radius.circular(height / 2),
    );

    canvas.save();
    canvas.clipRRect(roundedRect);

    for (int i = 0; i < colorStepCount; i++) {
      final Color color = colors[i];
      final Paint paint = Paint()..color = color;
      final double x = trackLeft + i * rectWidth;
      canvas.drawRect(Rect.fromLTWH(x, trackTop, rectWidth, height), paint);
    }

    canvas.restore();

    final Paint borderPaint = Paint()
      ..color = Colors.grey.withAlpha(80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    canvas.drawRRect(roundedRect, borderPaint);
  }

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackLeft = offset.dx + 8;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width - 16;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
