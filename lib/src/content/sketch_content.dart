import 'dart:ui';
import 'package:sketch_flow/sketch_flow.dart';

abstract class SketchContent {
  final List<Offset> offsets;
  final SketchConfig sketchConfig;

  SketchContent({required this.offsets, required this.sketchConfig});

  void draw(Canvas canvas);

  Map<String, dynamic> toJson();
}