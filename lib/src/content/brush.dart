import 'dart:ui';

import 'package:sketch_flow/sketch_contents.dart';

class Brush extends SketchContent {
  Brush({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;

    for (int i=0; i<offsets.length-1; i++) {
      final p1 = offsets[i];
      final p2 = offsets[i+1];

      // calculation of the distance between two offsets
      final distance = (p2 - p1).distance;
      final speed = distance;

      double minThickness = sketchConfig.strokeThickness * 0.45;
      double maxThickness = sketchConfig.strokeThickness;

      // If draw it quickly, it becomes thinner
      double thickness = maxThickness - (speed * 0.5);

      // Avoid being too thin or too thick
      thickness = thickness.clamp(minThickness, maxThickness);

      final paint = Paint()
        ..color = sketchConfig.color.withValues(alpha: sketchConfig.opacity)
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
      'color': sketchConfig.color.toARGB32(),
      'strokeThickness': sketchConfig.strokeThickness
    };
  }

}