import 'package:flutter/cupertino.dart';
import 'package:sketch_flow/src/controller/sketch_controller.dart';

class SketchPainter extends CustomPainter {
  final SketchController controller;

  SketchPainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(null, Paint());

    /// 완료된 content 그리기
    for (final content in controller.contents) {
      content.draw(canvas);
    }

    final currentContent = controller.createCurrentContent();
    currentContent?.draw(canvas);

    canvas.restore();
  }

  @override
  bool shouldRepaint(SketchPainter oldDelegate) {
    return controller.contents != oldDelegate.controller.contents;
  }

}