import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_flow.dart';

class SketchPainter extends CustomPainter {
  final SketchController controller;

  SketchPainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(null, Paint());

    for (final content in controller.contents) {
      content.draw(canvas);
    }

    final currentContent = controller.createCurrentContent();
    currentContent?.draw(canvas);

    if (controller.toolTypeNotifier.value == SketchToolType.eraser && controller.eraserCirclePosition != null) {
      final eraserPaint = Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(controller.eraserCirclePosition!, (controller.currentSketchConfig.eraserRadius), eraserPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(SketchPainter oldDelegate) {
    return controller.contents != oldDelegate.controller.contents;
  }

}