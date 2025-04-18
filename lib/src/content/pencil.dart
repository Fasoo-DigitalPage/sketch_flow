import 'dart:ui';
import 'package:sketch_flow/src/content/sketch_content.dart';

class Pencil extends SketchContent {
  Pencil({required super.points, required super.paint});

  @override
  void draw(Canvas canvas) {
    drawPointAsLine(canvas: canvas, customPaint: paint);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'pencil',
      'points': points.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'color': paint.color.toARGB32(),
      'strokeWidth': paint.strokeWidth,
    };
  }
}