import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';
import 'package:sketch_flow/src/model/config/sketch_tool_config.dart';
import 'package:sketch_flow/src/model/content/highlighter.dart';

class SketchDataConverter {
  static List<Map<String, dynamic>> toJson(List<SketchContent> contents) {
    return contents.map((c) => c.toJson()).toList();
  }

  static List<SketchContent> fromJson(List<Map<String, dynamic>> contents) {
    final result = <SketchContent>[];

    for (final content in contents) {
      final type = content['type'];
      final offsets =
          (content['offsets'] as List)
              .map((e) {
                final dx = e['dx'];
                final dy = e['dy'];
                if (dx is num && dy is num) {
                  return Offset(dx.toDouble(), dy.toDouble());
                }
                return null;
              })
              .whereType<Offset>()
              .toList();

      final toolType = switch(type) {
        'pencil' => SketchToolType.pencil,
        'brush' => SketchToolType.brush,
        'eraser' => SketchToolType.eraser,
        'highlighter' => SketchToolType.highlighter,
        _ => SketchToolType.pencil
      };

      final pencilConfig = SketchToolConfig(
        opacity: content['pencilOpacity'] ?? 1.0,
        color: Color(content['pencilColor'] ?? 0xFF000000),
        strokeThickness: content['pencilStrokeThickness'] ?? 1.0,
      );

      final brushConfig = SketchToolConfig(
        opacity: content['brushOpacity'] ?? 1.0,
        color: Color(content['brushColor'] ?? 0xFF000000),
        strokeThickness: content['brushStrokeThickness'] ?? 1.0,
      );

      final highlighterConfig = SketchToolConfig(
        opacity: content['highlighterOpacity'] ?? 1.0,
        color: Color(content['highlighterColor'] ?? 0xFF000000),
        strokeThickness: content['highlighterStrokeThickness'] ?? 1.0,
      );

      final sketchConfig = SketchConfig(
        toolType: toolType,
        pencilConfig: pencilConfig,
        brushConfig: brushConfig,
        highlighterConfig: highlighterConfig,
        eraserRadius: content['eraserRadius'] ?? 1.0,
      );

      switch (type) {
        case 'pencil':
          result.add(Pencil(offsets: offsets, sketchConfig: sketchConfig));
          break;
        case 'brush':
          result.add(Brush(offsets: offsets, sketchConfig: sketchConfig));
          break;
        case 'eraser':
          result.add(Eraser(offsets: offsets, sketchConfig: sketchConfig));
          break;
        case 'highlighter':
          result.add(Highlighter(offsets: offsets, sketchConfig: sketchConfig));
      }
    }

    return result;
  }
}
