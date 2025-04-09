import 'package:flutter/material.dart';
import 'package:sketch_flow/src/content/eraser.dart';
import 'package:sketch_flow/src/content/pencil.dart';
import 'package:sketch_flow/src/content/sketch_content.dart';
import 'package:sketch_flow/src/controller/sketch_config.dart';

/// 스케치 화면에서 사용자의 드로잉 상태를 관리하는 컨트롤러
///
/// [thicknessList] 그리기 도구 두께 리스트
class SketchController extends ChangeNotifier {
  SketchController({Color? baseColor, List<Color>? colorList, List<double>? thicknessList})
    : _sketchConfig = SketchConfig(
      toolType: SketchToolType.pencil,
      color: baseColor ?? Colors.black,
      strokeWidth: thicknessList != null ? thicknessList.reduce((a, b) => a < b ? a : b) : 1,
      thicknessList: [...(thicknessList ?? [1, 2, 3.5, 5, 7])]..sort(),
      colorList: colorList ?? [Colors.black, Colors.white, Colors.red, Colors.blue, Colors.green]
  );

  /// 누적된 그리기 콘텐츠 목록
  final List<SketchContent> _contents = [];
  List<SketchContent> get contents => List.unmodifiable(_contents);

  /// 현재 사용 중인 그리기 도구 설정
  SketchConfig _sketchConfig;
  SketchConfig get currentSketchConfig => _sketchConfig;

  /// 현재 그리고 있는 선의 경로
  Path _currentPath = Path();

  /// 그리기 가능 여부 상태
  bool _isEnabled = true;

  /// 현재 설정에 따른 콘텐츠 생성
  SketchContent? createCurrentContent() {
    if(_isPathEmpty(_currentPath)) return null;

    switch(_sketchConfig.toolType) {
      case SketchToolType.palette:
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

  /// 그리기 비활성화
  void disableDrawing() {
    _isEnabled = false;
    notifyListeners();
  }

  /// 그리기 활성화
  void enableDrawing() {
    _isEnabled = true;
    notifyListeners();
  }

  /// 그리기 도구 설정 업데이트
  void updateConfig(SketchConfig config) {
    _sketchConfig = config;
    notifyListeners();
  }

  /// 새로운 선 시작 (터치 시작 시)
  void startNewLine(Offset offset) {
    if (!_isEnabled) return;
    _currentPath = Path()..moveTo(offset.dx, offset.dy);
  }

  /// 선에 점 추가 (터치 이동 시)
  void addPoint(Offset offset) {
    if (!_isEnabled) return;
    _currentPath.lineTo(offset.dx, offset.dy);
    notifyListeners();
  }

  /// 선 그리기 종료 및 콘텐츠 저장 (터치 종료 시)
  void endLine() {
    if (!_isEnabled) return;
    final content = createCurrentContent();

    if(content != null) {
      _contents.add(content);
      _currentPath = Path();
      notifyListeners();
    }
  }

  /// 모든 콘텐츠 삭제
  void clear() {
    _contents.clear();
    notifyListeners();
  }

  /// Path 빈 객체 유무
  bool _isPathEmpty(Path path) {
    final metrics = path.computeMetrics();
    return metrics.isEmpty;
  }
}