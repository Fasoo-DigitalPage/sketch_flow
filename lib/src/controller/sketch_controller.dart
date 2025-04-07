import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sketch_flow/src/content/eraser.dart';
import 'package:sketch_flow/src/content/pencil.dart';
import 'package:sketch_flow/src/content/sketch_content.dart';
import 'package:sketch_flow/src/controller/sketch_config.dart';

class SketchController extends ChangeNotifier {
  /// 누적 그리기 데이터
  final List<SketchContent> _contents = [];

  /// 그리기 도구
  SketchConfig _sketchConfig = SketchConfig(
      toolType: SketchToolType.pencil,
      color: Colors.black,
      strokeWidth: 3.0,
  );

  List<SketchContent> get contents => List.unmodifiable(_contents);
  SketchConfig get currentSketchConfig => _sketchConfig;

  Path _currentPath = Path();

  SketchContent? createCurrentContent() {
    if(_currentPath == Path()) return null;

    switch(_sketchConfig.toolType) {
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

  void updateConfig(SketchConfig config) {
    _sketchConfig = config;
    notifyListeners();
  }

  /// 그리기 시작
  void startNewLine(Offset offset) {
    _currentPath = Path()..moveTo(offset.dx, offset.dy);
  }

  /// 그리기 작업
  void addPoint(Offset offset) {
    _currentPath.lineTo(offset.dx, offset.dy);
    notifyListeners();
  }

  /// 그리기 종료
  void endLine() {
    final content = createCurrentContent();

    if(content != null) {
      _contents.add(content);
      _currentPath = Path();
      notifyListeners();
    }
  }

  /// 전체 삭제
  void clear() {
    _contents.clear();
    notifyListeners();
  }
}