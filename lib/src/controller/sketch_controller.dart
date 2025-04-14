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

  /// The current configuration of the sketch tool
  SketchConfig _sketchConfig;
  SketchConfig get currentSketchConfig => _sketchConfig;

  /// The path currently being drawn
  Path _currentPath = Path();

  /// Indicates whether sketching is enabled.
  bool _isEnabled = true;

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
      _contents.add(content);
      _currentPath = Path();
      notifyListeners();
    }
  }

  /// Clears all sketch contents from the canvas
  void clear() {
    _contents.clear();
    notifyListeners();
  }

  /// Checks if a given is empty (i.e., has no drawing metrics).
  bool _isPathEmpty(Path path) {
    final metrics = path.computeMetrics();
    return metrics.isEmpty;
  }
}