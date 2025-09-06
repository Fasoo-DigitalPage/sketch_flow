import 'dart:ui';
import 'package:bson/bson.dart';
import 'package:sketch_flow/sketch_model.dart';

/// Represents a circle drawing tool.
///
/// The **Circle** tool allows users to draw circular outlines by specifying two points:
/// the starting point and the ending point. These two points define the diameter
/// of the circle (drawn horizontally).
///
/// ### Key Features:
/// - Draws a stroked circle (no fill)
/// - Circle is centered between the first and last offset points
/// - Radius is calculated as half the horizontal distance between two points
class Circle extends SketchContent {
  Circle({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;

    final start = offsets.first;
    final end = offsets.last;

    if (start.dx.isNaN || start.dy.isNaN || end.dx.isNaN || end.dy.isNaN) {
      return;
    }

    final paint = Paint()
      ..color = sketchConfig.circleConfig.color.withValues(
        alpha: sketchConfig.circleConfig.opacity,
      )
      ..strokeWidth = sketchConfig.circleConfig.strokeThickness
      ..style = PaintingStyle.stroke;

    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);

    final radius =
        ((end.dx - start.dx).abs() / 2).clamp(0, double.infinity).toDouble();

    canvas.drawCircle(center, radius, paint);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'circle',
        'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
        'circleColor': sketchConfig.circleConfig.color.toARGB32(),
        'circleStrokeThickness': sketchConfig.circleConfig.strokeThickness,
        'circleOpacity': sketchConfig.circleConfig.opacity,
      };

  @override
  BsonBinary toBson() => BsonCodec.serialize(toJson());

  @override
  String? toSvg() {
    final start = offsets.first;
    final end = offsets.last;

    final cx = (start.dx + end.dx) / 2;
    final cy = (start.dy + end.dy) / 2;
    final r = ((end.dx - start.dx).abs() / 2).toDouble();

    final color =
        '#${sketchConfig.circleConfig.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final opacity = sketchConfig.circleConfig.opacity;
    final strokeWidth = sketchConfig.circleConfig.strokeThickness;

    return '<circle cx="$cx" cy="$cy" r="$r" stroke="$color" stroke-width="$strokeWidth" fill="none" stroke-opacity="$opacity" />';
  }
}
