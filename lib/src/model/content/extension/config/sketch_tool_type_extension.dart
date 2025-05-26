import 'package:sketch_flow/sketch_model.dart';

extension SketchToolTypeExtension on SketchToolType {
  /// Returns true if this tool type is a shape tool (e.g. rectangle).
  /// Useful for distinguishing shape tools from freehand drawing tools.
  bool get isShape {
    switch (this) {
      case SketchToolType.rectangle:
        return true;
      default:
        return false;
    }
  }
}