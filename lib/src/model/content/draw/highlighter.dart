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
    final path = _createSmoothPath();

    final paint = Paint()
      ..isAntiAlias = true
      ..color = sketchConfig.highlighterConfig.color.withValues(
        alpha: sketchConfig.highlighterConfig.opacity,
      )
      ..strokeWidth = sketchConfig.highlighterConfig.strokeThickness
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
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
    final pathData = _createSmoothSvgPathData();
    final color =
        '#${sketchConfig.highlighterConfig.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final opacity = sketchConfig.highlighterConfig.opacity;
    final strokeWidth = sketchConfig.highlighterConfig.strokeThickness;

    return '<path d="$pathData" stroke="$color" stroke-width="$strokeWidth" fill="none" stroke-opacity="$opacity" stroke-linecap="round" stroke-linejoin="round"/>';
  }

  Path _createSmoothPath() {
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);

    if (offsets.length == 2) {
      path.lineTo(offsets.last.dx, offsets.last.dy);
      return path;
    }

    for (int i = 1; i < offsets.length - 2; i++) {
      final current = offsets[i];
      final next = offsets[i + 1];
      final midPoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );

      path.quadraticBezierTo(
        current.dx,
        current.dy,
        midPoint.dx,
        midPoint.dy,
      );
    }

    final secondLast = offsets[offsets.length - 2];
    path.quadraticBezierTo(
      secondLast.dx,
      secondLast.dy,
      offsets.last.dx,
      offsets.last.dy,
    );
    return path;
  }

  String _createSmoothSvgPathData() {
    final pathData = StringBuffer();
    pathData.write('M ${offsets.first.dx} ${offsets.first.dy} ');

    if (offsets.length < 2) {
      return pathData.toString();
    }

    if (offsets.length == 2) {
      pathData.write('L ${offsets.last.dx} ${offsets.last.dy} ');
      return pathData.toString();
    }

    for (int i = 1; i < offsets.length - 2; i++) {
      final current = offsets[i];
      final next = offsets[i + 1];
      final midPoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );

      pathData.write(
        'Q ${current.dx} ${current.dy} ${midPoint.dx} ${midPoint.dy} ',
      );
    }

    final secondLast = offsets[offsets.length - 2];
    pathData.write(
      'Q ${secondLast.dx} ${secondLast.dy} ${offsets.last.dx} ${offsets.last.dy} ',
    );
    return pathData.toString();
  }
}
