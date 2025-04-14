import 'package:flutter/material.dart';
import 'package:sketch_flow/src/content/sketch_content.dart';

class Eraser extends SketchContent {
  final Path path;
  final double eraserThickness;

  Eraser({required this.path, required this.eraserThickness});

  @override
  void draw(Canvas canvas) {
    final eraserPaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = eraserThickness
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.clear;

    canvas.drawPath(path, eraserPaint);
  }

}