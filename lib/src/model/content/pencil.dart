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
      ..color = sketchConfig.pencilConfig.color.withValues(alpha: sketchConfig.pencilConfig.opacity)
      ..strokeWidth = sketchConfig.pencilConfig.strokeThickness
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'pencil',
      'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'pencilColor': sketchConfig.pencilConfig.color.toARGB32(),
      'pencilStrokeThickness': sketchConfig.pencilConfig.strokeThickness,
      'pencilOpacity': sketchConfig.pencilConfig.opacity,
    };
  }
}