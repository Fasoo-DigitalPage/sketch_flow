import 'package:sketch_flow/sketch_model.dart';

class SketchSvgExporter {
  /// [extractSVG] generates an SVG string based on the given list of [SketchContent].
  ///
  /// **Note**:
  /// - This function only supports contents that are based on path or offset data.
  /// - Contents attached as PNG images do **not** contain vector data (e.g., Offset),
  ///   so they **cannot be exported** to SVG format.
  /// - PNG attachments are for display purposes within the SketchBoard only
  ///   and are **ignored** during SVG export.
  ///
  /// [contents]: The list of drawing contents to be exported
  /// [width], [height]: Dimensions for the SVG viewBox and size
  static String extractSVG({
    required List<SketchContent> contents,
    required double width,
    required double height,
  }) {
    final buffer = StringBuffer();
    final eraserBuffer = StringBuffer();
    final pathBuffer = StringBuffer();

    buffer.writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" width="$width" height="$height" viewBox="0 0 $width $height">',
    );

    for (final content in contents) {
      if (content.offsets.isEmpty) continue;

      if (content.sketchConfig.toolType == SketchToolType.eraser) {
        eraserBuffer.write(content.toSvg());
      } else {
        pathBuffer.write(content.toSvg());
      }
    }

    if (eraserBuffer.isNotEmpty) {
      buffer.writeln('<defs>');
      buffer.writeln('<mask id="eraser-mask">');
      buffer.writeln('<rect width="100%" height="100%" fill="white"/>');
      buffer.write(eraserBuffer.toString());
      buffer.writeln('</mask>');
      buffer.writeln('</defs>');

      buffer.writeln('<g mask="url(#eraser-mask)">');
      buffer.write(pathBuffer.toString());
      buffer.writeln('</g>');
    } else {
      buffer.write(pathBuffer.toString());
    }

    buffer.writeln('</svg>');

    return buffer.toString();
  }
}
