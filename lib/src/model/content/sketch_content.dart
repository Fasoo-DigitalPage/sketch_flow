import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';

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
      default:
        throw UnimplementedError(
          'Unsupported toolType: ${sketchConfig.toolType}',
        );
    }
  }

  void draw(Canvas canvas);

  Map<String, dynamic> toJson();

  String? toSvg();
}