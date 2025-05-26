import 'dart:ui';

import 'package:sketch_flow/sketch_model.dart';

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
      ..color = sketchConfig.rectangleConfig.color.withValues(alpha: sketchConfig.rectangleConfig.opacity)
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

    final color = '#${sketchConfig.rectangleConfig.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final opacity = sketchConfig.rectangleConfig.opacity;
    final strokeWidth = sketchConfig.rectangleConfig.strokeThickness;

    return '<rect x="$left" y="$top" width="$width" height="$height" stroke="$color" stroke-width="$strokeWidth" fill="none" stroke-opacity="$opacity" />';
  }

  List<Offset> interpolateRectangle({double spacing = 1.0}) {
    if (offsets.length < 2) return List.from(offsets);

    final start = offsets.first;
    final end = offsets.last;

    final topLeft = Offset(
      start.dx < end.dx ? start.dx : end.dx,
      start.dy < end.dy ? start.dy : end.dy,
    );
    final topRight = Offset(
      start.dx > end.dx ? start.dx : end.dx,
      start.dy < end.dy ? start.dy : end.dy,
    );
    final bottomRight = Offset(
      start.dx > end.dx ? start.dx : end.dx,
      start.dy > end.dy ? start.dy : end.dy,
    );
    final bottomLeft = Offset(
      start.dx < end.dx ? start.dx : end.dx,
      start.dy > end.dy ? start.dy : end.dy,
    );

    List<Offset> interpolateEdge(Offset a, Offset b) {
      final distance = (a - b).distance;
      final segments = (distance / spacing).ceil();
      return List.generate(segments + 1, (i) {
        final t = i / segments;
        return Offset(
          a.dx + (b.dx - a.dx) * t,
          a.dy + (b.dy - a.dy) * t,
        );
      });
    }

    final top = interpolateEdge(topLeft, topRight);
    final right = interpolateEdge(topRight, bottomRight);
    final bottom = interpolateEdge(bottomRight, bottomLeft);
    final left = interpolateEdge(bottomLeft, topLeft);

    return [
      ...top.sublist(0, top.length - 1),
      ...right.sublist(0, right.length - 1),
      ...bottom.sublist(0, bottom.length - 1),
      ...left
    ];
  }

}