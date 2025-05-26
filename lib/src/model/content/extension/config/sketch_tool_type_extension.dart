import 'package:sketch_flow/sketch_model.dart';

extension SketchToolTypeExtension on SketchToolType {
  /// Returns true if this tool type is a shape tool (e.g. rectangle).
  /// Useful for distinguishing shape tools from freehand drawing tools.
  bool get isShape {
    switch (this) {
      case SketchToolType.rectangle:
      case SketchToolType.line:
        return true;
      default:
        return false;
    }
  }

  bool get isUsedConfig {
    switch (this) {
      case SketchToolType.palette:
      case SketchToolType.eraser:
      case SketchToolType.move:
        return false;
      default:
        return true;
    }
  }
}