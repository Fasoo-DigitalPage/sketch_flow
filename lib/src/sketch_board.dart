import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_flow.dart';

/// Main widget for the sketch board.
///
/// [controller] The sketch controller used to manage drawing state.
///
/// [boardColor] Background color of the sketch board.
class SketchBoard extends StatefulWidget {
  const SketchBoard({super.key, this.controller, this.boardColor});

  final SketchController? controller;
  final Color? boardColor;

  @override
  State<StatefulWidget> createState() => _SketchBoardState();
}

class _SketchBoardState extends State<SketchBoard> {
  late final _controller = widget.controller ?? SketchController();

  @override
  Widget build(BuildContext context) {
    // Drawing mode widget
    Widget drawingArea = Container(
      color: widget.boardColor ?? Colors.white,
      child: Listener(
        onPointerDown: (event) => _controller.startNewLine(event.localPosition),
        onPointerMove: (event) => _controller.addPoint(event.localPosition),
        onPointerUp: (_) => _controller.endLine(),
        child: Container(
          color: widget.boardColor ?? Colors.white,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              // 그리는 영역만 UI 갱신
              return RepaintBoundary(
                child: SizedBox.expand(
                  child: Container(
                    color: Colors.transparent,
                    child: CustomPaint(
                      painter: SketchPainter(_controller),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Move mode widget with zoom and pan support
    Widget moveArea = InteractiveViewer(
      constrained: false,
      maxScale: 5.0,
      minScale: 0.5,
      child: Container(
        color: Colors.transparent,
        width: MediaQuery.of(context).size.width,
        height: 3000,
        child: CustomPaint(
          painter: SketchPainter(_controller),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: widget.boardColor ?? Colors.white,
      appBar: SketchTopBar(),
      body: ValueListenableBuilder<SketchToolType>(
          valueListenable: _controller.toolTypeNotifier,
          builder: (context, toolType, _) {
            return toolType == SketchToolType.move ? moveArea : drawingArea;
          }
      ),
      bottomNavigationBar: SketchBottomBar(controller: _controller),
    );
  }
}
