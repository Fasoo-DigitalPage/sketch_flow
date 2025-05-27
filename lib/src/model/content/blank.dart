import 'dart:ui';
import 'package:sketch_flow/sketch_model.dart';

class Blank extends SketchContent {
  Blank({required super.offsets, required super.sketchConfig});

  @override
  void draw(Canvas canvas) {}

  @override
  Map<String, dynamic> toJson() {
    return {};
  }

  @override
  String? toSvg() {
    return null;
  }
}
