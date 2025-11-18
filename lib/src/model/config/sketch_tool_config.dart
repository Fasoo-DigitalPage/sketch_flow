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
  ///
  /// [enableIconStrokeThicknessList] A list of custom widgets for the "enabled" (selected) state
  /// of each corresponding thickness in [strokeThicknessList].
  ///
  /// [disableIconStrokeThicknessList] A list of custom widgets for the "disabled" (inactive) state
  /// of each corresponding thickness in [strokeThicknessList].
  const SketchToolConfig(
      {this.opacity = 1.0,
      this.opacityMin = 0.0,
      this.opacityMax = 1.0,
      this.color = Colors.black,
      this.strokeThickness = 1.0,
      this.strokeThicknessList = const [1, 2, 3.5, 5, 7],
      this.enableIconStrokeThicknessList,
      this.disableIconStrokeThicknessList})
      : assert(
          enableIconStrokeThicknessList == null || enableIconStrokeThicknessList.length == strokeThicknessList.length,
          'The length of enableIconStrokeThicknessList must match the length of strokeThicknessList.',
        ),
        assert(
          disableIconStrokeThicknessList == null || disableIconStrokeThicknessList.length == strokeThicknessList.length,
          'The length of disableIconStrokeThicknessList must match the length of strokeThicknessList.',
        );

  final double opacity;
  final double opacityMin;
  final double opacityMax;

  final Color color;

  final double strokeThickness;
  final List<double> strokeThicknessList;

  final List<Widget>? enableIconStrokeThicknessList;
  final List<Widget>? disableIconStrokeThicknessList;

  SketchToolConfig copyWith({
    double? opacity,
    double? opacityMin,
    double? opacityMax,
    Color? color,
    double? strokeThickness,
    List<double>? strokeThicknessList,
    List<Widget>? enableIconStrokeThicknessList,
    List<Widget>? disableIconStrokeThicknessList,
  }) {
    final finalStrokeThicknessList = strokeThicknessList ?? this.strokeThicknessList;
    final finalEnableIconList = enableIconStrokeThicknessList ?? this.enableIconStrokeThicknessList;
    final finalDisableIconList = disableIconStrokeThicknessList ?? this.disableIconStrokeThicknessList;

    assert(
      finalEnableIconList == null || finalEnableIconList.length == finalStrokeThicknessList.length,
      'The length of enableIconStrokeThicknessList must match the length of strokeThicknessList.',
    );
    assert(
      finalDisableIconList == null || finalDisableIconList.length == finalStrokeThicknessList.length,
      'The length of disableIconStrokeThicknessList must match the length of strokeThicknessList.',
    );

    return SketchToolConfig(
      opacity: opacity ?? this.opacity,
      opacityMin: opacityMin ?? this.opacityMin,
      opacityMax: opacityMax ?? this.opacityMax,
      color: color ?? this.color,
      strokeThickness: strokeThickness ?? this.strokeThickness,
      strokeThicknessList: finalStrokeThicknessList,
      enableIconStrokeThicknessList: finalEnableIconList,
      disableIconStrokeThicknessList: finalDisableIconList,
    );
  }
}
