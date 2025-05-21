import 'dart:ui';

import 'package:sketch_flow/sketch_model.dart';

class Highlighter extends SketchContent {
  Highlighter({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    for (int i=0; i<offsets.length-1; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }

    final paint = Paint()
      ..color = sketchConfig.highlighterConfig.color.withValues(alpha: sketchConfig.highlighterConfig.opacity)
      ..strokeWidth = sketchConfig.highlighterConfig.strokeThickness
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'highlighter',
      'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'highlighterColor': sketchConfig.highlighterConfig.color.toARGB32(),
      'highlighterStrokeThickness': sketchConfig.highlighterConfig.strokeThickness,
      'highlighterOpacity': sketchConfig.highlighterConfig.opacity,
    };
  }

}