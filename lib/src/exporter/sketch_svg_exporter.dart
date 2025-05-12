import 'package:sketch_flow/sketch_contents.dart';
import 'package:sketch_flow/sketch_flow.dart';

class SketchSvgExporter {
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
      } else {
        final pathData = StringBuffer();
        pathData.write('M ${content.offsets.first.dx} ${content.offsets.first.dy} ');
        for (var i = 1; i < content.offsets.length; i++) {
          final p = content.offsets[i];
          pathData.write('L ${p.dx} ${p.dy} ');
        }

        final color = '#${content.sketchConfig.color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
        final opacity = content.sketchConfig.opacity;
        final strokeWidth = content.sketchConfig.strokeThickness;

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