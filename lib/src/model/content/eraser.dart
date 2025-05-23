import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_model.dart';

class Eraser extends SketchContent {
  Eraser({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    for (int i=0; i<offsets.length-1; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
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
      'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'eraserRadius': sketchConfig.eraserRadius
    };
  }

  @override
  String? toSvg() {
    final radius = sketchConfig.eraserRadius;

    return offsets.map((point) {
      return '<circle cx="${point.dx}" cy="${point.dy}" r="$radius" fill="black"/>';
    }).join('\n');
  }
}