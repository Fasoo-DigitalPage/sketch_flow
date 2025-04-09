import 'package:flutter/material.dart';

/// 도구 타입
///
/// [pencil] 연필 (기본 펜)
///
/// [eraser] 지우개
///
/// [palette] 색상 선택
enum SketchToolType {
  pencil, eraser, palette
}

/// [toolType] 펜 도구
///
/// [color] 펜 색상
///
/// [strokeWidth] 펜 굵기
///
/// [thicknessList] 펜 굵기 리스트
class SketchConfig {
  SketchConfig({
    required this.toolType,
    required this.color,
    required this.strokeWidth,
    required this.thicknessList,
    required this.colorList,
  });

  final SketchToolType toolType;
  final Color color;
  final double strokeWidth;
  final List<double> thicknessList;
  final List<Color> colorList;

  SketchConfig copyWith({
    SketchToolType? toolType,
    Color? color,
    double? strokeWidth,
    List<double>? thicknessList,
    List<Color>? colorList,
  }) {
    return SketchConfig(
        toolType: toolType ?? this.toolType,
        color: color ?? this.color,
        strokeWidth: strokeWidth ?? this.strokeWidth,
        thicknessList: thicknessList ?? this.thicknessList,
        colorList: colorList ?? this.colorList
    );
  }

  @override
  String toString() {
    return "toolType: ${toolType.name}, color: $color, strokeWidth: $strokeWidth, thicknessList: $thicknessList";
  }
}