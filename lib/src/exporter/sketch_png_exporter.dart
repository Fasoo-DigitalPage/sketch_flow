import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class SketchPngExporter {
  static Future<Uint8List?> extractPNG({
    required GlobalKey repaintKey,
    double? pixelRatio
  }) async {
    try {
      final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: pixelRatio ?? 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch(e) {
      print('Error capturing image: $e');
      return null;
    }
  }
}