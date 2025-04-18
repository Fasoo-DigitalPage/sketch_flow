import 'dart:ui';

abstract class SketchContent {
  final List<Offset> points;
  final Paint paint;

  SketchContent({required this.points, required this.paint});

  void draw(Canvas canvas);

  void drawPointAsLine({required Canvas canvas, required Paint customPaint}) {
    if (points.length < 2) return;
    Path path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i=0; i<points.length-1; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);
  }

  Map<String, dynamic> toJson();
}