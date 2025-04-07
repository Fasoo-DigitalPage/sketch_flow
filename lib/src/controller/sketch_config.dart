import 'package:flutter/material.dart';

enum SketchToolType {
  pencil, eraser
}

class SketchConfig {
  final SketchToolType toolType;
  final Color color;
  final double strokeWidth;

  SketchConfig({required this.toolType, this.color = Colors.black, required this.strokeWidth});

  SketchConfig copyWith({
    SketchToolType? toolType,
    Color? color,
    double? strokeWidth
  }) {
    return SketchConfig(
        toolType: toolType ?? this.toolType,
        color: color ?? this.color,
        strokeWidth: strokeWidth ?? this.strokeWidth
    );
  }
}