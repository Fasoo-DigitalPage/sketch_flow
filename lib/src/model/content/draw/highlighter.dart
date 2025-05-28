import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';

/// Represents a highlighter tool for drawing semi-transparent strokes.
///
/// The **Highlighter** simulates the behavior of a real-world marker by:
/// - Using a **low opacity** for see-through strokes.
/// - Applying a **thicker stroke width** to resemble the broad tip of a highlighter.
class Highlighter extends SketchContent {
  Highlighter({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }

    final paint = Paint()
      ..color = sketchConfig.highlighterConfig.color.withValues(
        alpha: sketchConfig.highlighterConfig.opacity,
      )
      ..strokeWidth = sketchConfig.highlighterConfig.strokeThickness
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'highlighter',
      'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'highlighterColor': sketchConfig.highlighterConfig.color.toARGB32(),
      'highlighterStrokeThickness':
          sketchConfig.highlighterConfig.strokeThickness,
      'highlighterOpacity': sketchConfig.highlighterConfig.opacity,
    };
  }

  @override
  String? toSvg() {
    final pathData = StringBuffer();

    pathData.write('M ${offsets.first.dx} ${offsets.first.dy} ');
    for (int i = 1; i < offsets.length; i++) {
      final p = offsets[i];
      pathData.write('L ${p.dx} ${p.dy} ');
    }

    final color =
        '#${sketchConfig.highlighterConfig.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final opacity = sketchConfig.highlighterConfig.opacity;
    final strokeWidth = sketchConfig.highlighterConfig.strokeThickness;

    return '<path d="$pathData" stroke="$color" stroke-width="$strokeWidth" fill="none" stroke-opacity="$opacity"/>';
  }
}
