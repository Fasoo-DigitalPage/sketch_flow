import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sketch_flow/src/content/sketch_content.dart';

class Eraser extends SketchContent {
  final Path path;
  final double eraseWidth;

  Eraser({required this.path, this.eraseWidth = 10.0});

  @override
  void draw(Canvas canvas) {
    final eraserPaint = Paint()
      ..color = Colors.transparent
      ..strokeWidth = eraseWidth
      ..style = PaintingStyle.stroke
      ..blendMode = BlendMode.clear;

    canvas.drawPath(path, eraserPaint);
  }

}