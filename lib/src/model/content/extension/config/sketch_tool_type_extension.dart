import 'package:sketch_flow/sketch_model.dart';

extension SketchToolTypeExtension on SketchToolType {
  /// Returns true if this tool type is a shape tool (e.g. rectangle).
  /// Useful for distinguishing shape tools from freehand drawing tools.
  bool get isShape {
    switch (this) {
      case SketchToolType.rectangle:
      case SketchToolType.line:
      case SketchToolType.circle:
        return true;
      default:
        return false;
    }
  }

  /// Returns true if this tool type uses [SketchConfig] settings (e.g. color, stroke width).
  ///
  /// This is useful for filtering out tool types that do not rely on configurable
  /// properties like color or thickness (e.g. [palette], [eraser], [move]).
  ///
  /// Example:
  /// - `pen`, `highlighter`, `shape tools` → true
  /// - `palette`, `eraser`, `move` → false
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
