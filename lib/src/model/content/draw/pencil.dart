import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';

/// Represents a pencil tool for freehand drawing.
///
/// The **Pencil** tool allows users to draw continuous free-form lines
/// by tracking finger or stylus movement.
class Pencil extends SketchContent {
  Pencil({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    for (int i = 0; i < offsets.length - 1; i++) {
      path.lineTo(offsets[i].dx, offsets[i].dy);
    }

    final paint = Paint()
      ..color = sketchConfig.pencilConfig.color.withValues(
        alpha: sketchConfig.pencilConfig.opacity,
      )
      ..strokeWidth = sketchConfig.pencilConfig.strokeThickness
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, paint);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'pencil',
      'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'pencilColor': sketchConfig.pencilConfig.color.toARGB32(),
      'pencilStrokeThickness': sketchConfig.pencilConfig.strokeThickness,
      'pencilOpacity': sketchConfig.pencilConfig.opacity,
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
        '#${sketchConfig.pencilConfig.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final opacity = sketchConfig.pencilConfig.opacity;
    final strokeWidth = sketchConfig.pencilConfig.strokeThickness;

    return '<path d="$pathData" stroke="$color" stroke-width="$strokeWidth" fill="none" stroke-opacity="$opacity"/>';
  }
}
