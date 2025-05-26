import 'dart:ui';

import 'package:sketch_flow/sketch_model.dart';

class Line extends SketchContent {
  Line({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;

    final paint = Paint()
      ..color = sketchConfig.lineConfig.color.withValues(alpha: sketchConfig.lineConfig.opacity)
      ..strokeWidth = sketchConfig.lineConfig.strokeThickness
      ..style = PaintingStyle.stroke;

    canvas.drawLine(offsets.first, offsets.last, paint);
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'line',
    'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
    'lineColor': sketchConfig.lineConfig.color.toARGB32(),
    'lineStrokeThickness': sketchConfig.lineConfig.strokeThickness,
    'lineOpacity': sketchConfig.lineConfig.opacity,
  };

  @override
  String? toSvg() {
    final start = offsets.first;
    final end = offsets.last;
    final color = '#${sketchConfig.lineConfig.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final opacity = sketchConfig.lineConfig.opacity;
    final strokeWidth = sketchConfig.lineConfig.strokeThickness;

    return '<line x1="${start.dx}" y1="${start.dy}" x2="${end.dx}" y2="${end.dy}" stroke="$color" stroke-width="$strokeWidth" stroke-opacity="$opacity" />';
  }

  List<Offset> interpolateLine({required double spacing}) {
    if (offsets.length < 2) return List.from(offsets);

    final List<Offset> interpolated = [];
    final start = offsets.first;
    final end = offsets.last;

    final distance = (start - end).distance;
    final segments = (distance / spacing).ceil();

    for (int i = 0; i <= segments; i++) {
      double t = i / segments;
      double dx = start.dx + (end.dx - start.dx) * t;
      double dy = start.dy + (end.dy - start.dy) * t;
      interpolated.add(Offset(dx, dy));
    }

    return interpolated;
  }

}