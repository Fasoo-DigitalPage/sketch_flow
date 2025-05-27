import 'package:flutter/material.dart';

/// Drawing Tool Settings
class SketchToolConfig {
  /// [color] Drawing tool color
  ///
  /// [strokeThickness] Drawing tool stroke thickness
  ///
  /// [opacity] Drawing tool opacity
  ///
  /// [opacityMin] Minimum value for opacity adjustment
  ///
  /// [opacityMax] Maximum value for opacity adjustment
  ///
  /// [strokeThicknessList] A list of available stroke thickness option
  const SketchToolConfig({
    this.opacity = 1.0,
    this.opacityMin = 0.0,
    this.opacityMax = 1.0,
    this.color = Colors.black,
    this.strokeThickness = 1.0,
    this.strokeThicknessList = const [1, 2, 3.5, 5, 7],
  });

  final double opacity;
  final double opacityMin;
  final double opacityMax;

  final Color color;

  final double strokeThickness;
  final List<double> strokeThicknessList;

  SketchToolConfig copyWith({
    double? opacity,
    double? opacityMin,
    double? opacityMax,
    Color? color,
    double? strokeThickness,
    List<double>? strokeThicknessList,
  }) {
    return SketchToolConfig(
      opacity: opacity ?? this.opacity,
      opacityMin: opacityMin ?? this.opacityMin,
      opacityMax: opacityMax ?? this.opacityMax,
      color: color ?? this.color,
      strokeThickness: strokeThickness ?? this.strokeThickness,
      strokeThicknessList: strokeThicknessList ?? this.strokeThicknessList,
    );
  }
}
