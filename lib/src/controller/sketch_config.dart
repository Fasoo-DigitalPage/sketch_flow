import 'package:flutter/material.dart';

/// Defines the type of sketch tool available.
///
/// [pencil] Pencil tool (default drawing tool)
///
/// [eraser] Eraser tool
///
/// [palette] Color palette for selecting drawing colors
///
/// [move] Screen move tool
///
///
enum SketchToolType {
  pencil, eraser, palette, move
}


enum EraserMode {
  area, stroke
}

/// Represents the configuration for a sketching tool.
///
/// [toolType] The type of sketch tool (e.g., pencil, eraser)
///
/// [color] The color of the pen
///
/// [opacity] The opacity of the pen
///
/// [strokeThickness] The thickness of the stroke
///
/// [strokeThicknessList] A list of available stroke thickness option
///
/// [eraserRadius] The radius of the eraser
///
/// [eraserRadiusMax] The maximum thickness the eraser can be set to
///
/// [eraserRadiusMin] The minimum thickness the eraser can be set to
///
/// [eraserRadiusDivisions] The number of discrete steps in the eraser thickness slider
class SketchConfig {
  SketchConfig({
    this.toolType = SketchToolType.pencil,
    this.color = Colors.black,
    this.opacity = 1.0,
    this.eraserRadius = 10,
    this.eraserRadiusMax = 100,
    this.eraserRadiusMin = 10,
    this.eraserRadiusDivisions = 9,
    this.eraserMode = EraserMode.area,
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

  final double opacity;
  final double strokeThickness;
  final List<double> strokeThicknessList;

  final double eraserRadius;
  final double eraserRadiusMax;
  final double eraserRadiusMin;
  final int eraserRadiusDivisions;

  final EraserMode eraserMode;

  SketchConfig copyWith({
    SketchToolType? toolType,
    Color? color,
    double? opacity,
    List<Color>? colorList,
    double? strokeThickness,
    List<double>? strokeThicknessList,
    double? eraserRadius,
    double? eraserRadiusMax,
    double? eraserRadiusMin,
    int? eraserRadiusDivisions,
    EraserMode? eraserMode,
  }) {
    return SketchConfig(
        toolType: toolType ?? this.toolType,
        color: color ?? this.color,
        opacity: opacity ?? this.opacity,
        strokeThickness: strokeThickness ?? this.strokeThickness,
        strokeThicknessList: strokeThicknessList ?? this.strokeThicknessList,
        colorList: colorList ?? this.colorList,
        eraserRadius: eraserRadius ?? this.eraserRadius,
        eraserRadiusMax: eraserRadiusMax ?? this.eraserRadiusMax,
        eraserRadiusMin: eraserRadiusMin ?? this.eraserRadiusMin,
        eraserRadiusDivisions: eraserRadiusDivisions ?? this.eraserRadiusDivisions,
        eraserMode: eraserMode ?? this.eraserMode
    );
  }

  @override
  String toString() {
    return "toolType: ${toolType.name}, color: $color, strokeThickness: $strokeThickness, "
        "strokeThicknessList: $strokeThicknessList, eraserRadius: $eraserRadius, eraserRadius: $eraserRadius, "
        "eraserRadiusMax: $eraserRadiusMax, eraserRadiusMin: $eraserRadiusMin, eraserRadiusDivisions: $eraserRadiusDivisions"
        "eraserMode: $eraserMode, opacity: $opacity";
  }
}