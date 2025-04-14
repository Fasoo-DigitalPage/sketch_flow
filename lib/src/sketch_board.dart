import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_flow.dart';

/// Main widget for the sketch board.
///
/// [controller] The sketch controller used to manage drawing state.
///
/// [boardColor] Background color of the sketch board.
///
/// [boardMaxScale] The maximum zoom level allowed when in move mode. (default is 5.0)
///
/// [boardMinScale] The minimum zoom level allowed when in move mode. (default is 1.0)
///
/// [backgroundColor] The background color of the Scaffold, which surrounds the canvas area (default is white)
class SketchBoard extends StatefulWidget {
  const SketchBoard({
    super.key,
    this.controller,
    this.boardColor,
    this.boardMaxScale,
    this.boardMinScale,
    this.backgroundColor
  });

  final SketchController? controller;
  final Color? boardColor;
  final double? boardMinScale;
  final double? boardMaxScale;
  final Color? backgroundColor;

  @override
  State<StatefulWidget> createState() => _SketchBoardState();
}

class _SketchBoardState extends State<SketchBoard> {
  late final _controller = widget.controller ?? SketchController();

  @override
  Widget build(BuildContext context) {
    // Drawing mode widget
    Widget drawingArea = Listener(
      onPointerDown: (event) => _controller.startNewLine(event.localPosition),
      onPointerMove: (event) => _controller.addPoint(event.localPosition),
      onPointerUp: (_) => _controller.endLine(),
      child: Container(
        color: widget.boardColor ?? Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return RepaintBoundary(
              child: CustomPaint(
                painter: SketchPainter(_controller),
              ),
            );
          },
        ),
      ),
    );

    // Move mode widget with zoom and pan support
    Widget moveArea = Container(
      color: widget.boardColor ?? Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: CustomPaint(
        painter: SketchPainter(_controller),
      ),
    );

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? Colors.white,
      appBar: SketchTopBar(
        controller: _controller,
      ),
      body: ValueListenableBuilder<SketchToolType>(
          valueListenable: _controller.toolTypeNotifier,
          builder: (context, toolType, _) {
            bool isMoveArea = toolType == SketchToolType.move;

            return InteractiveViewer(
                constrained: false,
                panEnabled: isMoveArea,
                maxScale: isMoveArea ? widget.boardMaxScale ?? 5.0 : 1.0,
                minScale: isMoveArea ? widget.boardMinScale ?? 0.5 : 1.0,
                child: isMoveArea ? moveArea : drawingArea,
            );
          }
      ),
      bottomNavigationBar: SketchBottomBar(controller: _controller),
    );
  }
}
