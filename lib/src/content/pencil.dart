import 'dart:ui';

import 'package:sketch_flow/src/content/sketch_content.dart';

class Pencil extends SketchContent {
  final Path path;
  final Paint paint;

  Pencil({required this.path, required this.paint});

  @override
  void draw(Canvas canvas) {
    canvas.drawPath(path, paint);
  }
}