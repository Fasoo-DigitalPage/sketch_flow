import 'dart:ui';
import 'package:bson/bson.dart';
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
  BsonBinary toBson() {
    return BsonBinary.fromHexString('0500000000');
    // Hex string is same as '0x05 0x00 0x00 0x00 0x00'
  }

  @override
  String? toSvg() {
    return null;
  }
}
