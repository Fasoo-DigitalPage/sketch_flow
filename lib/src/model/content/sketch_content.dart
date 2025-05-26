import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';
import 'package:sketch_flow/src/model/content/blank.dart';
import 'package:sketch_flow/src/model/content/shape/line.dart';
import 'package:sketch_flow/src/model/content/shape/rectangle.dart';

abstract class SketchContent {
  final List<Offset> offsets;
  final SketchConfig sketchConfig;

  SketchContent({required this.offsets, required this.sketchConfig});

  factory SketchContent.create({
    required List<Offset> offsets,
    required SketchConfig sketchConfig,
  }) {
    switch (sketchConfig.toolType) {
      case SketchToolType.pencil:
        return Pencil(offsets: List.from(offsets), sketchConfig: sketchConfig);
      case SketchToolType.brush:
        return Brush(offsets: List.from(offsets), sketchConfig: sketchConfig);
      case SketchToolType.highlighter:
        return Highlighter(offsets: List.from(offsets), sketchConfig: sketchConfig);
      case SketchToolType.eraser:
        return Eraser(offsets: List.from(offsets), sketchConfig: sketchConfig);
      case SketchToolType.line:
        return Line(offsets: List.from(offsets), sketchConfig: sketchConfig);
      case SketchToolType.rectangle:
        return Rectangle(offsets: List.from(offsets), sketchConfig: sketchConfig);
      default:
        return Blank(offsets: [], sketchConfig: sketchConfig);
    }
  }

  void draw(Canvas canvas);

  Map<String, dynamic> toJson();

  String? toSvg();
}