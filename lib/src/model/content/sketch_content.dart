import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';

/// This class defines a common interface and structure for various types of
/// drawing tools and shapes (e.g., pencil, brush, eraser, line, rectangle, etc.).
/// It enforces the implementation of drawing, serialization to JSON, and SVG export.
abstract class SketchContent {
  /// A list of offset points that define the shape or path of the drawing.
  final List<Offset> offsets;

  /// The configuration for the sketch tool used (e.g., color, thickness, type).
  final SketchConfig sketchConfig;

  /// Constructs a SketchContent with the given offsets and configuration.
  SketchContent({required this.offsets, required this.sketchConfig});

  /// Factory constructor that creates an instance of a concrete [SketchContent]
  /// subclass based on the provided [SketchConfig]'s [toolType].
  ///
  /// Returns the appropriate tool instance or a [Blank] if the tool type is unknown.
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
        return Highlighter(
          offsets: List.from(offsets),
          sketchConfig: sketchConfig,
        );
      case SketchToolType.eraser:
        return Eraser(offsets: List.from(offsets), sketchConfig: sketchConfig);
      case SketchToolType.line:
        return Line(offsets: List.from(offsets), sketchConfig: sketchConfig);
      case SketchToolType.rectangle:
        return Rectangle(
          offsets: List.from(offsets),
          sketchConfig: sketchConfig,
        );
      case SketchToolType.circle:
        return Circle(offsets: List.from(offsets), sketchConfig: sketchConfig);
      default:
        return Blank(offsets: [], sketchConfig: sketchConfig);
    }
  }

  /// Draws the content on the provided [canvas].
  void draw(Canvas canvas);

  /// Serializes the content into a JSON-compatible map.
  Map<String, dynamic> toJson();

  /// Converts the content to an SVG string representation.
  ///
  /// Returns `null` if the shape does not support SVG export.
  String? toSvg();
}
