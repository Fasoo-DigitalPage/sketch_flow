import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_model.dart';
import 'package:sketch_flow/sketch_helper.dart';

class SketchController extends ChangeNotifier {
  /// A controller that manages the user's sketching state on the canvas.
  SketchController({SketchConfig? sketchConfig})
      : _sketchConfig = sketchConfig ?? SketchConfig();

  /// The list of all accumulated sketch contents.
  final List<SketchContent> _contents = [];
  List<SketchContent> get contents => List.unmodifiable(_contents);

  /// Notifier for the current tool type (e.g., pencil, eraser).
  final ValueNotifier<SketchToolType> toolTypeNotifier = ValueNotifier(
    SketchToolType.pencil,
  );

  /// Notifier for the undo
  final ValueNotifier<bool> canUndoNotifier = ValueNotifier(false);

  /// Notifier for the redo
  final ValueNotifier<bool> canRedoNotifier = ValueNotifier(false);

  /// The current configuration of the sketch tool
  SketchConfig _sketchConfig;
  SketchConfig get currentSketchConfig => _sketchConfig;

  /// The offset currently being drawn
  List<Offset> _currentOffsets = [];
  List<Offset> get currentOffsets => _currentOffsets;

  /// Indicates whether sketching is enabled.
  bool _isEnabled = true;

  bool _hasErasedContent = false;
  bool get hasErasedContent => _hasErasedContent;

  /// undo / redo stack
  final List<List<SketchContent>> _undoStack = [];
  final List<List<SketchContent>> _redoStack = [];

  Offset? _eraserCirclePosition;
  Offset? get eraserCirclePosition => _eraserCirclePosition;

  /// Disables sketching functionality
  void disableDrawing() {
    _isEnabled = false;
    notifyListeners();
  }

  /// Enables sketching functionality
  void enableDrawing() {
    _isEnabled = true;
    notifyListeners();
  }

  /// Updates the current sketch tool configuration.
  ///
  /// This method allows updating global tool settings such as color, thickness, opacity, and eraser options.
  ///
  /// The parameters prefixed with `lastUsed` (e.g., [lastUsedColor], [lastUsedStrokeThickness], [lastUsedOpacity])
  /// represent the most recently used values for those options, **regardless of which tool is currently active**.
  ///
  /// This design means you don't need to manage or remember tool-specific settings yourself.
  /// For example, if you change the color while using the pencil, [lastUsedColor] is updated,
  /// and the next time you switch to another drawing tool, that color is automatically applied.
  ///
  /// **Note:** The "lastUsed" naming can be confusing at first glance, but it ensures a consistent
  /// and user-friendly experience by always applying the most recent settings, no matter which tool is selected.
  ///
  /// Example usage:
  /// ```
  /// controller.updateConfig(lastUsedColor: Colors.red);
  /// ```
  /// This will set the color for the current tool and remember it for future
  void updateConfig({
    SketchToolType? toolType,
    Color? lastUsedColor,
    double? lastUsedStrokeThickness,
    double? lastUsedOpacity,
    double? eraserRadius,
    EraserMode? eraserMode,
  }) {
    _sketchConfig = _sketchConfig.copyWith(
      toolType: toolType,
      lastUsedColor: lastUsedColor,
      lastUsedStrokeThickness: lastUsedStrokeThickness,
      lastUsedOpacity: lastUsedOpacity,
      eraserRadius: eraserRadius,
      eraserMode: eraserMode,
    );
    toolTypeNotifier.value = _sketchConfig.toolType;
    notifyListeners();
  }

  /// Starts a new line when the user touches the screen
  void startNewLine(Offset offset) {
    if (!_isEnabled) return;

    _currentOffsets = [offset];
  }

  /// Adds a point to the current path as the user move their finger
  void addPoint(Offset offset) {
    if (!_isEnabled || _isRedundantOffset(offset: offset)) return;

    if (_sketchConfig.toolType == SketchToolType.eraser) {
      _handleEraser(offset: offset);
    } else {
      _currentOffsets.add(offset);
    }

    notifyListeners();
  }

  /// Ends the current line and saves the sketch content
  void endLine() {
    if (!_isEnabled || _currentOffsets.isEmpty) return;

    final content = SketchContent.create(
      offsets: _currentOffsets,
      sketchConfig: _sketchConfig,
    );

    if (_sketchConfig.toolType == SketchToolType.eraser) {
      _eraserCirclePosition = null;
    }

    final isEraser = _sketchConfig.toolType == SketchToolType.eraser;
    final isAreaEraseWithEffect = isEraser &&
        _sketchConfig.eraserMode == EraserMode.area &&
        _hasErasedContent;

    // Save only when something is erased
    if (!isEraser || isAreaEraseWithEffect) {
      _saveToUndoStack();
      _contents.add(content);
    }

    _hasErasedContent = false;
    _currentOffsets.clear();
    notifyListeners();
  }

  /// Clears all sketch contents from the canvas
  void clear() {
    _saveToUndoStack();
    _contents.clear();
    notifyListeners();
  }

  /// Reverts the canvas to the previous drawing state by popping from the undo stack.
  /// The current state is pushed onto the redo stack for possible reapplication.
  void undo() {
    if (_undoStack.isEmpty) return;

    _redoStack.add(List.from(_contents));
    _contents
      ..clear()
      ..addAll(_undoStack.removeLast());
    _updateUndoRedoStatus();

    notifyListeners();
  }

  /// Reapplies the most recently undone drawing state by popping from the redo stack.
  /// The current state is pushed back onto the undo stack.
  void redo() {
    if (_redoStack.isEmpty) return;

    _undoStack.add(List.from(_contents));
    _contents
      ..clear()
      ..addAll(_redoStack.removeLast());
    _updateUndoRedoStatus();

    notifyListeners();
  }

  List<Map<String, dynamic>> toJson() {
    return SketchDataConverter.toJson(_contents);
  }

  void fromJson({required List<Map<String, dynamic>> json}) {
    final data = SketchDataConverter.fromJson(json);

    _contents
      ..clear()
      ..addAll(data);
    notifyListeners();
  }

  Future<Uint8List?> extractPNG({
    required GlobalKey repaintKey,
    double? pixelRatio,
  }) async {
    final image = await SketchPngExporter.extractPNG(
      repaintKey: repaintKey,
      pixelRatio: pixelRatio,
    );

    return image;
  }

  String extractSVG({required double width, required double height}) {
    return SketchSvgExporter.extractSVG(
      contents: _contents,
      width: width,
      height: height,
    );
  }

  void _saveToUndoStack() {
    _undoStack.add(List.from(_contents));
    _redoStack.clear();
    _updateUndoRedoStatus();
  }

  /// Update notifier values based on current undo/redo stack status
  void _updateUndoRedoStatus() {
    canUndoNotifier.value = _undoStack.isNotEmpty;
    canRedoNotifier.value = _redoStack.isNotEmpty;
  }

  /// Stroke eraser
  void _eraserStroke({required Offset center}) {
    List<SketchContent> removedContents = [];

    // If any point of a stroke lies within the eraser circle, remove that stroke
    // and add it to the removedPoint list for undo tracking.
    _contents.removeWhere((content) {
      if (content is! Eraser) {
        for (final offset in content.offsets) {
          if (content.sketchConfig.isShapeTool) {
            if (_checkShapeErased(
              toolType: content.sketchConfig.toolType,
              content: content,
              eraserCenter: center,
            )) {
              removedContents.add(content);
              return true;
            }
          } else {
            if (_isOffsetInsideCircle(offset: offset, center: center)) {
              removedContents.add(content);
              return true;
            }
          }
        }
      }
      return false;
    });

    // If any strokes were removed, save the previous state to the undo stack
    // and clear the redo stack
    if (removedContents.isNotEmpty) {
      _undoStack.add(_contents + removedContents);
      _redoStack.clear();
      _updateUndoRedoStatus();
    }

    notifyListeners();
  }

  /// Determining if there is anything erased
  bool _checkErasedContent({required Offset center}) {
    bool result = false;

    for (final content in _contents) {
      if (content.sketchConfig.toolType == SketchToolType.eraser) {
        continue;
      }
      for (final point in content.offsets) {
        if (content.sketchConfig.isShapeTool) {
          if (!result) {
            result = _checkShapeErased(
              toolType: content.sketchConfig.toolType,
              content: content,
              eraserCenter: center,
            );
          }
        } else {
          if (_isOffsetInsideCircle(offset: point, center: center)) {
            return true;
          }
        }
      }
    }
    return result;
  }

  /// Verify sure it's inside the eraser area
  bool _isOffsetInsideCircle({required Offset offset, required Offset center}) {
    final radius = _sketchConfig.eraserRadius;
    final dx = offset.dx - center.dx;
    final dy = offset.dy - center.dy;

    return dx * dx + dy * dy <= radius * radius;
  }

  /// Verify that it is a duplicate offset
  bool _isRedundantOffset({required Offset offset}) {
    return _currentOffsets.isNotEmpty && _currentOffsets.last == offset;
  }

  /// Eraser tool handling
  void _handleEraser({required Offset offset}) {
    _eraserCirclePosition = offset;

    if (_sketchConfig.eraserMode == EraserMode.stroke) {
      _eraserStroke(center: offset);
      return;
    }

    if (_checkErasedContent(center: offset)) {
      if (!_hasErasedContent) _hasErasedContent = true;
      _currentOffsets.add(offset);
    }
  }

  /// Determines whether a given shape has been actually erased by the eraser tool.
  ///
  /// This function checks if the eraser area (defined by [eraserCenter] and the current eraser radius)
  /// overlaps or intersects with the shape represented by [content], depending on the [toolType].
  /// Returns `true` if the shape is considered erased, otherwise `false`.
  bool _checkShapeErased({
    required SketchToolType toolType,
    required SketchContent content,
    required Offset eraserCenter,
  }) {
    final result = switch (toolType) {
      SketchToolType.rectangle => content.isErasedRectangleByEraser(
          offsets: content.offsets,
          eraserCenter: eraserCenter,
          eraserRadius: _sketchConfig.eraserRadius,
        ),
      SketchToolType.line => content.isErasedLineByEraser(
          offsets: content.offsets,
          eraserCenter: eraserCenter,
          eraserRadius: _sketchConfig.eraserRadius,
        ),
      SketchToolType.circle => content.isErasedCircleByEraser(
          offsets: content.offsets,
          eraserCenter: eraserCenter,
          eraserRadius: _sketchConfig.eraserRadius,
        ),
      _ => false,
    };

    return result;
  }
}
