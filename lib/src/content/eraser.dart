import 'package:flutter/material.dart';
import 'package:sketch_flow/src/content/sketch_content.dart';

class Eraser extends SketchContent {
  Eraser({required super.points, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i=0; i<points.length-1; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final paint = Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = sketchConfig.eraserRadius * 2;

    canvas.drawPath(path, paint);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'eraser',
      'points': points.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'strokeWidth': sketchConfig.strokeThickness
    };
  }
}