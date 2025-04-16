import 'package:flutter/material.dart';
import 'package:sketch_flow/src/content/sketch_content.dart';

class Eraser extends SketchContent {
  Eraser({required super.points, required super.paint});

  @override
  void draw(Canvas canvas) {
    drawPointAsLine(canvas: canvas, customPaint: paint);
  }

}