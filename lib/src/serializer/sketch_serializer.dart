import 'dart:ui';
import '../../sketch_contents.dart';
import '../../sketch_flow.dart';

class SketchSerializer {
  static Map<String, dynamic> toJson(List<SketchContent> contents) {
    return {
      'sketchContents': contents.map((c) => c.toJson()).toList(),
    };
  }

  static List<SketchContent> fromJson(List<Map<String, dynamic>> contents) {
    final result = <SketchContent>[];

    for (final content in contents) {
      final type = content['type'];
      final offsets = (content['offsets'] as List)
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

      final color = Color(content['color'] ?? 0xFF000000);
      final strokeThickness = (content['strokeThickness'] as num?)?.toDouble() ?? 1.0;
      final opacity = (content['opacity'] as num?)?.toDouble() ?? 1.0;
      final eraserRadius = (content['eraserRadius'] as num?)?.toDouble() ?? 1.0;

      final sketchConfig = SketchConfig(
        color: color,
        strokeThickness: strokeThickness,
        opacity: opacity,
        eraserRadius: eraserRadius,
      );

      switch (type) {
        case 'pencil':
          result.add(Pencil(offsets: offsets, sketchConfig: sketchConfig));
          break;
        case 'eraser':
          result.add(Eraser(offsets: offsets, sketchConfig: sketchConfig));
          break;
      }
    }

    return result;
  }
}