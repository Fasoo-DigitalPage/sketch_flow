import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';

class Pencil extends SketchContent {
  Pencil({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    for (int i=0; i<offsets.length-1; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }

    final paint = Paint()
      ..color = sketchConfig.color.withValues(alpha: sketchConfig.opacity)
      ..strokeWidth = sketchConfig.strokeThickness
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'pencil',
      'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'color': sketchConfig.color.toARGB32(),
      'strokeThickness': sketchConfig.strokeThickness,
    };
  }
}