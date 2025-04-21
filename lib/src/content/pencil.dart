import 'dart:ui';
import 'package:sketch_flow/src/content/sketch_content.dart';

class Pencil extends SketchContent {
  Pencil({required super.points, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i=0; i<points.length-1; i++) {
      path.lineTo(points[i].dx, points[i].dy);
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
      'points': points.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'color': sketchConfig.color.toARGB32(),
      'strokeWidth': sketchConfig.strokeThickness,
    };
  }
}