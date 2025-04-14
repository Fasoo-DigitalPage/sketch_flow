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
/// [strokeWidth] The thickness of the pen stroke
///
/// [thicknessList] A list of available stroke thickness option
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