import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';

class Brush extends SketchContent {
  Brush({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {
    if (offsets.length < 2) return;
    final config = sketchConfig.brushConfig;
    double strokeWidth = config.strokeThickness;

    for (final segment in _createSmoothPathSegments()) {
      strokeWidth = _smoothedStrokeWidth(
        previous: strokeWidth,
        speed: segment.speed,
      );

      _drawBrushSegment(
        canvas: canvas,
        path: segment.path,
        strokeWidth: strokeWidth,
        config: config,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'brush',
      'offsets': offsets.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'brushColor': sketchConfig.brushConfig.color.toARGB32(),
      'brushStrokeThickness': sketchConfig.brushConfig.strokeThickness,
      'brushOpacity': sketchConfig.brushConfig.opacity,
    };
  }

  @override
  String? toSvg() {
    final config = sketchConfig.brushConfig;
    final color =
        '#${config.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    final opacity = config.opacity;
    final edgeOpacity = opacity * 0.2;
    double strokeWidth = config.strokeThickness;
    final buffer = StringBuffer();

    for (final segment in _createSmoothSvgPathSegments()) {
      strokeWidth = _smoothedStrokeWidth(
        previous: strokeWidth,
        speed: segment.speed,
      );
      final edgeStrokeWidth = strokeWidth * 1.35;

      buffer.write(
        '<path d="${segment.pathData}" stroke="$color" stroke-width="$edgeStrokeWidth" fill="none" stroke-opacity="$edgeOpacity" stroke-linecap="round" stroke-linejoin="round"/>',
      );
      buffer.write(
        '<path d="${segment.pathData}" stroke="$color" stroke-width="$strokeWidth" fill="none" stroke-opacity="$opacity" stroke-linecap="round" stroke-linejoin="round"/>',
      );
    }

    return buffer.toString();
  }

  List<({Path path, double speed})> _createSmoothPathSegments() {
    if (offsets.length == 2) {
      final path = Path()
        ..moveTo(offsets.first.dx, offsets.first.dy)
        ..lineTo(offsets.last.dx, offsets.last.dy);

      return [(path: path, speed: (offsets.last - offsets.first).distance)];
    }

    final segments = <({Path path, double speed})>[];
    Offset start = offsets.first;

    for (int i = 1; i < offsets.length - 2; i++) {
      final current = offsets[i];
      final next = offsets[i + 1];
      final midPoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(
          current.dx,
          current.dy,
          midPoint.dx,
          midPoint.dy,
        );

      segments.add(
        (path: path, speed: (current - offsets[i - 1]).distance),
      );
      start = midPoint;
    }

    final secondLast = offsets[offsets.length - 2];
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        secondLast.dx,
        secondLast.dy,
        offsets.last.dx,
        offsets.last.dy,
      );
    segments.add(
      (path: path, speed: (offsets.last - secondLast).distance),
    );

    return segments;
  }

  List<({String pathData, double speed})> _createSmoothSvgPathSegments() {
    if (offsets.length == 2) {
      return [
        (
          pathData:
              'M ${offsets.first.dx} ${offsets.first.dy} L ${offsets.last.dx} ${offsets.last.dy} ',
          speed: (offsets.last - offsets.first).distance,
        )
      ];
    }

    final segments = <({String pathData, double speed})>[];
    Offset start = offsets.first;

    for (int i = 1; i < offsets.length - 2; i++) {
      final current = offsets[i];
      final next = offsets[i + 1];
      final midPoint = Offset(
        (current.dx + next.dx) / 2,
        (current.dy + next.dy) / 2,
      );

      segments.add(
        (
          pathData:
              'M ${start.dx} ${start.dy} Q ${current.dx} ${current.dy} ${midPoint.dx} ${midPoint.dy} ',
          speed: (current - offsets[i - 1]).distance,
        ),
      );
      start = midPoint;
    }

    final secondLast = offsets[offsets.length - 2];
    segments.add(
      (
        pathData:
            'M ${start.dx} ${start.dy} Q ${secondLast.dx} ${secondLast.dy} ${offsets.last.dx} ${offsets.last.dy} ',
        speed: (offsets.last - secondLast).distance,
      ),
    );

    return segments;
  }

  void _drawBrushSegment({
    required Canvas canvas,
    required Path path,
    required double strokeWidth,
    required SketchToolConfig config,
  }) {
    final edgePaint = Paint()
      ..isAntiAlias = true
      ..color = config.color.withValues(alpha: config.opacity * 0.2)
      ..strokeWidth = strokeWidth * 1.35
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final bodyPaint = Paint()
      ..isAntiAlias = true
      ..color = config.color.withValues(alpha: config.opacity)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, edgePaint);
    canvas.drawPath(path, bodyPaint);
  }

  double _smoothedStrokeWidth({
    required double previous,
    required double speed,
  }) {
    final baseThickness = sketchConfig.brushConfig.strokeThickness;
    final minThickness = baseThickness * 0.45;
    final maxThickness = baseThickness;
    final target = (maxThickness - speed * 0.5).clamp(
      minThickness,
      maxThickness,
    );

    return previous + (target - previous) * 0.35;
  }
}
