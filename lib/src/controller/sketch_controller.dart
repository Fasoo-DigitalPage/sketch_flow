import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_contents.dart';
import 'package:sketch_flow/sketch_flow.dart';

/// A controller that manages the user's sketching state on the canvas.
class SketchController extends ChangeNotifier {
  SketchController({
    SketchConfig? sketchConfig
  }) : _sketchConfig = sketchConfig ?? SketchConfig();

  /// The list of all accumulated sketch contents.
  final List<SketchContent> _contents = [];
  List<SketchContent> get contents => List.unmodifiable(_contents);

  /// Notifier for the current tool type (e.g., pencil, eraser).
  final ValueNotifier<SketchToolType> toolTypeNotifier = ValueNotifier(SketchToolType.pencil);

  /// Notifier for the undo
  final ValueNotifier<bool> canUndoNotifier = ValueNotifier(false);

  /// Notifier for the redo
  final ValueNotifier<bool> canRedoNotifier = ValueNotifier(false);

  /// The current configuration of the sketch tool
  SketchConfig _sketchConfig;
  SketchConfig get currentSketchConfig => _sketchConfig;

  /// The offset currently being drawn
  List<Offset> _currentOffsets = [];

  /// Indicates whether sketching is enabled.
  bool _isEnabled = true;

  /// undo / redo stack
  final List<List<SketchContent>> _undoStack = [];
  final List<List<SketchContent>> _redoStack = [];

  Offset? _eraserCirclePosition;
  Offset? get eraserCirclePosition => _eraserCirclePosition;

  /// Creates a new sketch content based on the current configuration and path.
  SketchContent? createCurrentContent() {
    if(_isOffsetsEmpty(_currentOffsets)) return null;

    switch(_sketchConfig.toolType) {
      case SketchToolType.palette:
      case SketchToolType.move:
         return null;
      case SketchToolType.pencil:
        return Pencil(
            points: List.from(_currentOffsets),
            paint: Paint()
              ..color = _sketchConfig.color
              ..strokeWidth = _sketchConfig.strokeThickness
              ..style = PaintingStyle.stroke
        );
      case SketchToolType.eraser:
        return Eraser(
            points: List.from(_currentOffsets),
            paint: Paint()
              ..color = Colors.transparent
              ..blendMode = BlendMode.clear
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeJoin = StrokeJoin.round
              ..strokeWidth = _sketchConfig.eraserRadius
        );
    }
  }

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

  /// Updates the current sketch tool configuration
  void updateConfig(SketchConfig config) {
    _sketchConfig = config;
    toolTypeNotifier.value = config.toolType;
    notifyListeners();
  }

  /// Starts a new line when the user touches the screen
  void startNewLine(Offset offset) {
    if (!_isEnabled) return;

    _currentOffsets = [offset];
  }

  /// Adds a point to the current path as the user move their finger
  void addPoint(Offset offset) {
    if (!_isEnabled) return;

    if (_currentOffsets.isNotEmpty && _currentOffsets.last == offset) return;

    _currentOffsets.add(offset);

    if(_sketchConfig.toolType == SketchToolType.eraser) {
      _eraserCirclePosition = offset;
    }

    if (_sketchConfig.toolType == SketchToolType.eraser && _sketchConfig.eraserMode == EraserMode.stroke) {
      //_eraserStrokesIntersecting(eraserOffsets: _currentOffsets);
    }

    notifyListeners();
  }

  /// Ends the current line and saves the sketch content
  void endLine() {
    if (!_isEnabled) return;
    final content = createCurrentContent();

    if(content != null) {
      // For stroke eraser (EraserMode.stroke), the undo stack and content removal
      // are already handle inside _eraserStrokesIntersecting.
      // So we skip saving to undo stack to avoid duplication.
      final isEraserStroke = content is Eraser && _sketchConfig.eraserMode == EraserMode.stroke;

      if(!isEraserStroke) {
        _saveToUndoStack();
        _contents.add(content);
      }

      if(_sketchConfig.toolType == SketchToolType.eraser) {
        _eraserCirclePosition = null;
      }

      _currentOffsets.clear();
      notifyListeners();
    }
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
    if(_undoStack.isEmpty) return;

    _redoStack.add(List.from(_contents));
    _contents..clear()..addAll(_undoStack.removeLast());
    _updateUndoRedoStatus();

    notifyListeners();
  }

  /// Reapplies the most recently undone drawing state by popping from the redo stack.
  /// The current state is pushed back onto the undo stack.
  void redo() {
    if(_redoStack.isEmpty) return;

    _undoStack.add(List.from(_contents));
    _contents..clear()..addAll(_redoStack.removeLast());
    _updateUndoRedoStatus();

    notifyListeners();
  }

  /// Checks if a given is empty.
  bool _isOffsetsEmpty(List<Offset> offsets) => offsets.length < 2;

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
}