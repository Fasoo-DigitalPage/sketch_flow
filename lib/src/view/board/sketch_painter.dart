import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_model.dart';
import 'package:sketch_flow/sketch_view_model.dart';

class SketchPainter extends CustomPainter {
  final SketchViewModel viewModel;

  SketchPainter(this.viewModel);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(null, Paint());

    for (final content in viewModel.contents) {
      content.draw(canvas);
    }

    final currentContent = viewModel.createCurrentContent();
    currentContent?.draw(canvas);

    if (viewModel.toolTypeNotifier.value == SketchToolType.eraser && viewModel.eraserCirclePosition != null
        && viewModel.currentSketchConfig.showEraserEffect) {
      final eraserPaint = Paint()
        ..color = Colors.grey
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(viewModel.eraserCirclePosition!, (viewModel.currentSketchConfig.eraserRadius), eraserPaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(SketchPainter oldDelegate) {
    return viewModel.contents != oldDelegate.viewModel.contents;
  }

}