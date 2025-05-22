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
    required double height
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
        final radius = content.sketchConfig.eraserRadius;
        for (final point in content.offsets) {
          eraserBuffer.writeln(
            '<circle cx="${point.dx}" cy="${point.dy}" r="$radius" fill="black"/>',
          );
        }
      }
      else if (content is Brush) {
        for (int i=0; i<content.offsets.length-1; i++) {
          final p1 = content.offsets[i];
          final p2 = content.offsets[i + 1];

          final config = content.sketchConfig.brushConfig;

          final baseThickness = config.strokeThickness;
          if (baseThickness <= 0) continue;

          final minThickness = baseThickness * 0.45;
          final maxThickness = baseThickness;

          final distance = (p2 - p1).distance;
          final speed = distance;

          double rawThickness = maxThickness - (speed * 0.5);
          double thickness = rawThickness.clamp(minThickness, maxThickness);

          final color = '#${config.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
          final opacity = config.opacity;

          pathBuffer.writeln(
            '<line x1="${p1.dx}" y1="${p1.dy}" x2="${p2.dx}" y2="${p2.dy}" '
                'stroke="$color" stroke-width="$thickness" stroke-linecap="round" stroke-opacity="$opacity"/>',
          );
        }
      }
      else {
        final pathData = StringBuffer();
        pathData.write('M ${content.offsets.first.dx} ${content.offsets.first.dy} ');
        for (var i = 1; i < content.offsets.length; i++) {
          final p = content.offsets[i];
          pathData.write('L ${p.dx} ${p.dy} ');
        }
        
        final effectiveConfig = content.sketchConfig.effectiveConfig;

        final color = '#${effectiveConfig.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
        final opacity = effectiveConfig.opacity;
        final strokeWidth = effectiveConfig.strokeThickness;

        pathBuffer.writeln(
          '<path d="$pathData" stroke="$color" stroke-width="$strokeWidth" '
              'fill="none" stroke-opacity="$opacity"/>',
        );
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