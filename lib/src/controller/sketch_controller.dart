import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_contents.dart';
import 'package:sketch_flow/sketch_flow.dart';

/// A controller that manages the user's sketching state on the canvas.
///
/// [thicknessList] List of available pen thickness options.
///
/// [colorList] List of available pen color options.
class SketchController extends ChangeNotifier {
  SketchController({Color? baseColor, List<Color>? colorList, List<double>? thicknessList})
    : _sketchConfig = SketchConfig(
      toolType: SketchToolType.pencil,
      color: baseColor ?? Colors.black,
      strokeWidth: thicknessList != null ? thicknessList.reduce((a, b) => a < b ? a : b) : 1,
      thicknessList: [...(thicknessList ?? [1, 2, 3.5, 5, 7])]..sort(),
      colorList: colorList ?? [Colors.black, Color(0xCFCFCFCF), Colors.red, Colors.blue, Colors.green]
  );

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

  /// The path currently being drawn
  Path _currentPath = Path();

  /// Indicates whether sketching is enabled.
  bool _isEnabled = true;

  /// undo / redo stack
  final List<List<SketchContent>> _undoStack = [];
  final List<List<SketchContent>> _redoStack = [];

  /// Creates a new sketch content based on the current configuration and path.
  SketchContent? createCurrentContent() {
    if(_isPathEmpty(_currentPath)) return null;

    switch(_sketchConfig.toolType) {
      case SketchToolType.palette:
      case SketchToolType.move:
         return null;
      case SketchToolType.pencil:
        return Pencil(
            path: _currentPath,
            paint: Paint()
              ..color = _sketchConfig.color
              ..strokeWidth = _sketchConfig.strokeWidth
              ..style = PaintingStyle.stroke
        );
      case SketchToolType.eraser:
        return Eraser(
            path: _currentPath,
            eraseWidth: _sketchConfig.strokeWidth
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
    _currentPath = Path()..moveTo(offset.dx, offset.dy);
  }

  /// Adds a point to the current path as the user move their finger
  void addPoint(Offset offset) {
    if (!_isEnabled) return;
    _currentPath.lineTo(offset.dx, offset.dy);
    notifyListeners();
  }

  /// Ends the current line and saves the sketch content
  void endLine() {
    if (!_isEnabled) return;
    final content = createCurrentContent();

    if(content != null) {
      _saveToUndoStack();
      _contents.add(content);
      _currentPath = Path();
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

  /// Checks if a given is empty (i.e., has no drawing metrics).
  bool _isPathEmpty(Path path) {
    final metrics = path.computeMetrics();
    return metrics.isEmpty;
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
}