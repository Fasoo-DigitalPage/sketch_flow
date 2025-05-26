import 'package:flutter/material.dart';
import 'package:sketch_flow/src/model/config/sketch_tool_config.dart';
import 'package:sketch_flow/src/model/content/extension/config/sketch_tool_type_extension.dart';

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
/// [highlighter] Highlighter tool
///
/// [line] Line tool
enum SketchToolType {
  pencil,
  eraser,
  palette,
  move,
  brush,
  highlighter,
  line,
  rectangle
}

enum EraserMode { area, stroke }

/// Drawing tool preferences.
class SketchConfig {
  /// Represents the configuration for a sketching tool.
  ///
  /// [toolType] The type of sketch tool (e.g., pencil, eraser)
  ///
  /// [lastUsedColor] Recently selected color
  ///
  /// [lastUsedStrokeThickness] Recently selected stroke thickness
  ///
  /// [lastUsedOpacity] Recently selected opacity
  ///
  /// [colorList] List of color
  ///
  /// [pencilConfig] The tool config of pencil (see [SketchToolConfig])
  ///
  /// [brushConfig] The tool config of brush (see [SketchToolConfig])
  ///
  /// [highlighterConfig] The tool config of highlighter (see [SketchToolConfig])
  ///
  /// [lineConfig] The tool config of line (see [SketchToolConfig])
  ///
  /// [rectangleConfig] The tool config of rectangle (see [SketchToolConfig])
  ///
  /// [eraserRadius] The radius of the eraser
  ///
  /// [eraserRadiusMax] The maximum thickness the eraser can be set to
  ///
  /// [eraserRadiusMin] The minimum thickness the eraser can be set to
  ///
  /// [eraserMode] Eraser mode (area, stroke)
  ///
  /// [showEraserEffect] Eraser motion effect (true is the default)
  const SketchConfig({
    this.toolType = SketchToolType.pencil,
    this.lastUsedColor = Colors.black,
    this.lastUsedStrokeThickness = 1.0,
    this.lastUsedOpacity = 1.0,
    this.colorList = const [
      Colors.black,
      Color(0xCFCFCFCF),
      Colors.red,
      Colors.blue,
      Colors.green,
    ],
    this.pencilConfig = const SketchToolConfig(),
    this.brushConfig = const SketchToolConfig(
        strokeThickness: 5.0,
        strokeThicknessList: [5.0, 7.5, 10.0, 12.5, 15.0],
    ),
    this.highlighterConfig = const SketchToolConfig(
      color: Colors.deepPurpleAccent,
      strokeThickness: 8.0,
      strokeThicknessList: [8.0, 11.5, 15.5, 19.0, 22.5],
      opacity: 0.6,
      opacityMin: 0.0,
      opacityMax: 0.8
    ),
    this.lineConfig = const SketchToolConfig(),
    this.rectangleConfig = const SketchToolConfig(),
    this.eraserRadius = 10,
    this.eraserRadiusMax = 100,
    this.eraserRadiusMin = 10,
    this.eraserMode = EraserMode.area,
    this.showEraserEffect = true,
  });

  final SketchToolType toolType;

  final Color lastUsedColor;
  final double lastUsedStrokeThickness;
  final double lastUsedOpacity;

  final List<Color> colorList;

  final SketchToolConfig pencilConfig;
  final SketchToolConfig brushConfig;
  final SketchToolConfig highlighterConfig;
  final SketchToolConfig lineConfig;
  final SketchToolConfig rectangleConfig;

  final double eraserRadius;
  final double eraserRadiusMax;
  final double eraserRadiusMin;

  final EraserMode eraserMode;

  final bool showEraserEffect;

  bool get isShapeTool => toolType.isShape;

  SketchToolConfig get effectiveConfig {
    switch (toolType) {
      case SketchToolType.pencil:
        return pencilConfig;
      case SketchToolType.brush:
        return brushConfig;
      case SketchToolType.highlighter:
        return highlighterConfig;
      case SketchToolType.line:
        return lineConfig;
      case SketchToolType.rectangle:
        return rectangleConfig;
      case SketchToolType.move:
      case SketchToolType.palette:
      case SketchToolType.eraser:
        return SketchToolConfig();
    }
  }

  /// Returns a new [SketchConfig] with updated values.
  ///
  /// This method intelligently applies the latest common options
  /// (such as [lastUsedColor], [lastUsedStrokeThickness], and [lastUsedOpacity])
  /// to the currently selected drawing tool (pencil, brush, etc),
  /// so developers don't need to manually update tool-specific configurations.
  ///
  /// For example:
  /// If [toolType] is [SketchToolType.pencil] and [lastUsedColor] is changed,
  /// the returned config will automatically apply the new color
  /// to [pencilConfig].
  ///
  /// This behavior reduces boilerplate and ensures consistency across the tool configuration logic.
  SketchConfig copyWith({
    SketchToolType? toolType,
    Color? lastUsedColor,
    double? lastUsedStrokeThickness,
    double? lastUsedOpacity,
    SketchToolConfig? pencilConfig,
    SketchToolConfig? brushConfig,
    SketchToolConfig? highlighterConfig,
    SketchToolConfig? lineConfig,
    SketchToolConfig? rectangleConfig,
    List<Color>? colorList,
    double? eraserRadius,
    double? eraserRadiusMax,
    double? eraserRadiusMin,
    EraserMode? eraserMode,
    bool? showEraserEffect,
  }) {
    final newToolType = toolType ?? this.toolType;

    // Automatically applies latest common options to the selected tool's config.
    SketchToolConfig updatedToolConfig(SketchToolConfig current) {
      return current.copyWith(
        color: lastUsedColor ?? current.color,
        strokeThickness: lastUsedStrokeThickness ?? current.strokeThickness,
        opacity: lastUsedOpacity ?? current.opacity,
      );
    }

    return SketchConfig(
      toolType: toolType ?? this.toolType,
      lastUsedColor: lastUsedColor ?? this.lastUsedColor,
      lastUsedStrokeThickness:
          lastUsedStrokeThickness ?? this.lastUsedStrokeThickness,
      pencilConfig:
          newToolType == SketchToolType.pencil
              ? updatedToolConfig(pencilConfig ?? this.pencilConfig)
              : pencilConfig ?? this.pencilConfig,
      brushConfig:
          newToolType == SketchToolType.brush
              ? updatedToolConfig(brushConfig ?? this.brushConfig)
              : brushConfig ?? this.brushConfig,
      highlighterConfig:
          newToolType == SketchToolType.highlighter
              ? updatedToolConfig(highlighterConfig ?? this.highlighterConfig)
              : highlighterConfig ?? this.highlighterConfig,
      lineConfig:
          newToolType == SketchToolType.line
              ? updatedToolConfig(lineConfig ?? this.lineConfig)
              : lineConfig ?? this.lineConfig,
      rectangleConfig:
          newToolType == SketchToolType.rectangle
              ? updatedToolConfig(rectangleConfig ?? this.rectangleConfig)
              : rectangleConfig ?? this.rectangleConfig,
      colorList: colorList ?? this.colorList,
      eraserRadius: eraserRadius ?? this.eraserRadius,
      eraserRadiusMax: eraserRadiusMax ?? this.eraserRadiusMax,
      eraserRadiusMin: eraserRadiusMin ?? this.eraserRadiusMin,
      eraserMode: eraserMode ?? this.eraserMode,
      showEraserEffect: showEraserEffect ?? this.showEraserEffect,
    );
  }

  @override
  String toString() {
    return 'SketchConfig('
        'toolType: ${toolType.name}, '
        'lastUsedColor: $lastUsedColor, '
        'lastUsedStrokeThickness: $lastUsedStrokeThickness, '
        'pencil: ${pencilConfig.toString()}, '
        'brush: ${brushConfig.toString()}, '
        'colorList: $colorList, '
        ')';
  }
}
