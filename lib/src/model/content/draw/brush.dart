import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';

class Brush extends SketchContent {
  Brush({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;

    for (int i = 0; i < offsets.length - 1; i++) {
      final p1 = offsets[i];
      final p2 = offsets[i + 1];

      // calculation of the distance between two offsets
      final distance = (p2 - p1).distance;
      final speed = distance;

      double minThickness = sketchConfig.brushConfig.strokeThickness * 0.45;
      double maxThickness = sketchConfig.brushConfig.strokeThickness;

      // If draw it quickly, it becomes thinner
      double thickness = maxThickness - (speed * 0.5);

      // Avoid being too thin or too thick
      thickness = thickness.clamp(minThickness, maxThickness);

      final paint =
          Paint()
            ..color = sketchConfig.brushConfig.color.withValues(
              alpha: sketchConfig.brushConfig.opacity,
            )
            ..strokeWidth = thickness
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'brush',
      'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'brushColor': sketchConfig.brushConfig.color.toARGB32(),
      'brushStrokeThickness': sketchConfig.brushConfig.strokeThickness,
      'brushOpacity': sketchConfig.brushConfig.opacity,
    };
  }

  @override
  String? toSvg() {
    final config = sketchConfig.brushConfig;

    final baseThickness = config.strokeThickness;
    final minThickness = baseThickness * 0.45;
    final maxThickness = baseThickness;
    final color =
        '#${config.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final opacity = config.opacity;

    final buffer = StringBuffer();
    for (int i = 0; i < offsets.length - 1; i++) {
      final p1 = offsets[i];
      final p2 = offsets[i + 1];
      final speed = (p2 - p1).distance;
      final thickness = (maxThickness - (speed * 0.5)).clamp(
        minThickness,
        maxThickness,
      );
      buffer.writeln(
        '<line x1="${p1.dx}" y1="${p1.dy}" x2="${p2.dx}" y2="${p2.dy}" '
        'stroke="$color" stroke-width="$thickness" stroke-linecap="round" stroke-opacity="$opacity"/>',
      );
    }
    return buffer.toString();
  }
}
