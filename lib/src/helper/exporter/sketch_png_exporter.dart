import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
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
    double? pixelRatio,
  }) async {
    try {
      final boundary = repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: pixelRatio ?? 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      throw ('Error capturing images: $e');
    }
  }

  static Future<Uint8List?> extractCroppedPNG({
    required GlobalKey repaintKey,
    required Rect cropBounds,
    double? pixelRatio
  }) async {
    try {
      final boundary = repaintKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      final defaultPixelRatio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
      final effectivePixelRatio = pixelRatio ?? defaultPixelRatio;

      final ui.Image fullImage = await boundary.toImage(pixelRatio: effectivePixelRatio);

      final Rect physicalBounds = Rect.fromLTRB(
        cropBounds.left * effectivePixelRatio,
        cropBounds.top * effectivePixelRatio,
        cropBounds.right * effectivePixelRatio,
        cropBounds.bottom * effectivePixelRatio,
      );

      final Rect clampedBounds = Rect.fromLTRB(
        max(0, physicalBounds.left),
        max(0, physicalBounds.top),
        min(fullImage.width.toDouble(), physicalBounds.right),
        min(fullImage.height.toDouble(), physicalBounds.bottom),
      );

      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(
        recorder,
        // 새 캔버스의 크기는 잘라낼 영역의 크기와 같습니다.
        Rect.fromLTWH(0, 0, clampedBounds.width, clampedBounds.height),
      );

      final Rect src = clampedBounds;
      final Rect dst = Rect.fromLTWH(0, 0, clampedBounds.width, clampedBounds.height);
      final Paint paint = Paint();

      canvas.drawImageRect(fullImage, src, dst, paint);

      final ui.Picture picture = recorder.endRecording();

      final ui.Image croppedUiImage = await picture.toImage(
        clampedBounds.width.toInt(),
        clampedBounds.height.toInt(),
      );

      final ByteData? byteData = await croppedUiImage.toByteData(format: ui.ImageByteFormat.png);

      return byteData?.buffer.asUint8List();

    } catch (e) {
      debugPrint('Error capturing or cropping images: $e');
      return null;
    }
  }
}
