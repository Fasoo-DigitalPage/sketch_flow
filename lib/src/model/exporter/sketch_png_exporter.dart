import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

/// A utility class that exports a widget's visual content as a PNG image.
class SketchPngExporter {
  /// Captures the widget associated with [repaintKey] and returns it as PNG bytes.
  ///
  /// [repaintKey] must be a [GlobalKey] assigned to a [RepaintBoundary] widget.
  /// [pixelRatio] optionally defines the resolution of the output image. Defaults to 3.0.
  ///
  /// Returns a [Uint8List] representing the PNG bytes, or `null` if capture fails.
  ///
  /// Throws an error if the capture process encounters any issues.
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
      throw('Error capturing images: $e');
    }
  }
}