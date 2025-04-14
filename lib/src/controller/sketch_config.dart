import 'package:flutter/material.dart';

/// Defines the type of sketch tool available.
///
/// [pencil] Pencil tool (default drawing tool)
///
/// [eraser] Eraser tool
///
/// [palette] Color palette for selecting drawing colors.
enum SketchToolType {
  pencil, eraser, palette, move
}

/// Represents the configuration for a sketching tool.
///
/// [toolType] The type of sketch tool (e.g., pencil, eraser)
///
/// [color] The color of the pen
///
/// [strokeThickness] The thickness of the stroke
///
/// [strokeThicknessList] A list of available stroke thickness option
///
/// [eraserThickness] The thickness of the eraser
///
/// [eraserThicknessMax] The maximum thickness the eraser can be set to
///
/// [eraserThicknessMin] The minimum thickness the eraser can be set to
///
/// [eraserThicknessDivisions] The number of discrete steps in the eraser thickness slider
class SketchConfig {
  SketchConfig({
    this.toolType = SketchToolType.pencil,
    this.color = Colors.black,
    this.eraserThickness = 1,
    this.eraserThicknessMax = 10,
    this.eraserThicknessMin = 1,
    this.eraserThicknessDivisions = 9,
    List<Color>? colorList,
    double? strokeThickness,
    List<double>? strokeThicknessList,
  }) :
        strokeThicknessList = strokeThicknessList ?? [...(strokeThicknessList ?? [1, 2, 3.5, 5, 7])]..sort(),
        strokeThickness = strokeThickness ?? ((strokeThicknessList ?? [1, 2, 3.5, 5, 7])..sort()).first,
        colorList = colorList ?? [Colors.black, Color(0xCFCFCFCF), Colors.red, Colors.blue, Colors.green];

  final SketchToolType toolType;

  final Color color;
  final List<Color> colorList;

  final double strokeThickness;
  final List<double> strokeThicknessList;

  final double eraserThickness;
  final double eraserThicknessMax;
  final double eraserThicknessMin;
  final int eraserThicknessDivisions;

  SketchConfig copyWith({
    SketchToolType? toolType,
    Color? color,
    List<Color>? colorList,
    double? strokeThickness,
    List<double>? strokeThicknessList,
    double? eraserThickness,
    double? eraserThicknessMax,
    double? eraserThicknessMin,
    int? eraserThicknessDivisions,
  }) {
    return SketchConfig(
        toolType: toolType ?? this.toolType,
        color: color ?? this.color,
        strokeThickness: strokeThickness ?? this.strokeThickness,
        strokeThicknessList: strokeThicknessList ?? this.strokeThicknessList,
        colorList: colorList ?? this.colorList,
        eraserThickness: eraserThickness ?? this.eraserThickness,
        eraserThicknessMax: eraserThicknessMax ?? this.eraserThicknessMax,
        eraserThicknessMin: eraserThicknessMin ?? this.eraserThicknessMin,
        eraserThicknessDivisions: eraserThicknessDivisions ?? this.eraserThicknessDivisions
    );
  }

  @override
  String toString() {
    return "toolType: ${toolType.name}, color: $color, strokeThickness: $strokeThickness, "
        "strokeThicknessList: $strokeThicknessList, eraserThickness: $eraserThickness, eraserThickness: $eraserThickness, "
        "eraserThicknessMax: $eraserThicknessMax, eraserThicknessMin: $eraserThicknessMin, eraserThicknessDivisions: $eraserThicknessDivisions";
  }
}