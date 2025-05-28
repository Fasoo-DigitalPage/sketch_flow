import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';

/// Represents a rectangular shape drawing tool.
///
/// The **Rectangle** tool allows users to draw a rectangular outline
/// defined by two diagonal corner points: [offsets.first] and [offsets.last].
class Rectangle extends SketchContent {
  Rectangle({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;

    final start = offsets.first;
    final end = offsets.last;

    if (start.dx.isNaN || start.dy.isNaN || end.dx.isNaN || end.dy.isNaN) {
      return;
    }

    final paint = Paint()
      ..color = sketchConfig.rectangleConfig.color.withValues(
        alpha: sketchConfig.rectangleConfig.opacity,
      )
      ..strokeWidth = sketchConfig.rectangleConfig.strokeThickness
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromPoints(start, end);

    canvas.drawRect(rect, paint);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'rectangle',
        'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
        'lineColor': sketchConfig.rectangleConfig.color.toARGB32(),
        'lineStrokeThickness': sketchConfig.rectangleConfig.strokeThickness,
        'lineOpacity': sketchConfig.rectangleConfig.opacity,
      };

  @override
  String? toSvg() {
    final start = offsets.first;
    final end = offsets.last;

    final left = start.dx < end.dx ? start.dx : end.dx;
    final top = start.dy < end.dy ? start.dy : end.dy;
    final width = (start.dx - end.dx).abs();
    final height = (start.dy - end.dy).abs();

    final color =
        '#${sketchConfig.rectangleConfig.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final opacity = sketchConfig.rectangleConfig.opacity;
    final strokeWidth = sketchConfig.rectangleConfig.strokeThickness;

    return '<rect x="$left" y="$top" width="$width" height="$height" stroke="$color" stroke-width="$strokeWidth" fill="none" stroke-opacity="$opacity" />';
  }
}
