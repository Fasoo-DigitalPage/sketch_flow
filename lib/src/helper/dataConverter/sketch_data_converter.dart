import 'dart:ui';
import 'package:fixnum/fixnum.dart';
import 'package:bson/bson.dart';
import 'package:sketch_flow/sketch_model.dart';

/// A utility class responsible for converting sketch data to and from JSON format.
class SketchDataConverter {
  /// Converts a list of [SketchContent] objects into a list of JSON maps.
  static List<Map<String, dynamic>> toJson(List<SketchContent> contents) {
    return contents.map((c) => c.toJson()).toList();
  }

  /// Converts a list of JSON maps into a list of [SketchContent] objects.
  ///
  /// Each JSON entry should specify a `type`, list of `offsets`, and tool-specific
  /// configuration data. If a tool type is unrecognized, it defaults to pencil.
  static List<SketchContent> fromJson(List<Map<String, dynamic>> contents) {
    final result = <SketchContent>[];

    for (final content in contents) {
      final type = content['type'];

      // Convert raw offset data to List<Offset>
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

      // Determine the tool type
      final toolType = switch (type) {
        'pencil' => SketchToolType.pencil,
        'brush' => SketchToolType.brush,
        'eraser' => SketchToolType.eraser,
        'highlighter' => SketchToolType.highlighter,
        'line' => SketchToolType.line,
        'rectangle' => SketchToolType.rectangle,
        _ => SketchToolType.pencil,
      };

      final pencilConfig = SketchToolConfig(
        opacity: content['pencilOpacity']?.toDouble() ?? 1.0,
        color: Color(content['pencilColor'] ?? 0xFF000000),
        strokeThickness: content['pencilStrokeThickness']?.toDouble() ?? 1.0,
      );

      final brushConfig = SketchToolConfig(
        opacity: content['brushOpacity']?.toDouble() ?? 1.0,
        color: Color(content['brushColor'] ?? 0xFF000000),
        strokeThickness: content['brushStrokeThickness']?.toDouble() ?? 1.0,
      );

      final highlighterConfig = SketchToolConfig(
        opacity: content['highlighterOpacity']?.toDouble() ?? 1.0,
        color: Color(content['highlighterColor'] ?? 0xFF000000),
        strokeThickness:
            content['highlighterStrokeThickness']?.toDouble() ?? 1.0,
      );

      final lineConfig = SketchToolConfig(
        opacity: content['lineOpacity']?.toDouble() ?? 1.0,
        color: Color(content['lineColor'] ?? 0xFF000000),
        strokeThickness: content['lineStrokeThickness']?.toDouble() ?? 1.0,
      );

      final rectangleConfig = SketchToolConfig(
        opacity: content['rectangleOpacity']?.toDouble() ?? 1.0,
        color: Color(content['rectangleColor'] ?? 0xFF000000),
        strokeThickness: content['rectangleThickness']?.toDouble() ?? 1.0,
      );

      final circleConfig = SketchToolConfig(
        opacity: content['circleOpacity']?.toDouble() ?? 1.0,
        color: Color(content['circleColor'] ?? 0xFF000000),
        strokeThickness: content['circleStrokeThickness']?.toDouble() ?? 1.0,
      );

      // Combine tool configs into a full sketch configuration
      final sketchConfig = SketchConfig(
        toolType: toolType,
        pencilConfig: pencilConfig,
        brushConfig: brushConfig,
        highlighterConfig: highlighterConfig,
        lineConfig: lineConfig,
        rectangleConfig: rectangleConfig,
        circleConfig: circleConfig,
        eraserRadius: content['eraserRadius']?.toDouble() ?? 1.0,
      );

      // Reconstruct the proper content object
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
          break;
        case 'line':
          result.add(Line(offsets: offsets, sketchConfig: sketchConfig));
          break;
        case 'rectangle':
          result.add(Rectangle(offsets: offsets, sketchConfig: sketchConfig));
          break;
        case 'circle':
          result.add(Circle(offsets: offsets, sketchConfig: sketchConfig));
          break;
      }
    }

    return result;
  }

  /// Converts a list of [SketchContent] objects into BSON bytes.
  ///
  /// Wrapper for [toJson]
  static BsonBinary toBson(List<SketchContent> contents) {
    final jsonList = toJson(contents);
    print(
        'Decode: ${BsonCodec.deserialize(BsonBinary.fromHexString('0500000000'))}');
    print('Encode: ${BsonCodec.serialize([{}])}');
    return BsonCodec.serialize(jsonList);
  }

  /// Converts BSON bytes into a list of [SketchContent] objects.
  static List<SketchContent> fromBson(BsonBinary bytes) {
    final content = BsonCodec.deserialize(bytes);

    return fromJson(content.entries
        .map((e) => _normalizeForJson(e.value) as Map<String, dynamic>)
        .toList());
  }

  /// Converts BSON bytes into a list of JSON maps.
  static List<Map<String, dynamic>> fromBsonToJson(BsonBinary bson) {
    final output = BsonCodec.deserialize(bson);
    return output.entries
        .map((e) => _normalizeForJson(e.value) as Map<String, dynamic>)
        .toList();
  }

  /// Converts a list of JSON maps into BSON bytes.
  static BsonBinary fromJsonToBson(List<Map<String, dynamic>> content) {
    return BsonCodec.serialize(content);
  }

  /// Recursively normalizes a BSON-decoded object into pure JSON-safe values.
  static dynamic _normalizeForJson(dynamic value) {
    if (value is Int64) {
      return value.toInt();
    } else if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), _normalizeForJson(v)));
    } else if (value is List) {
      return value.map(_normalizeForJson).toList();
    }
    return value;
  }
}
