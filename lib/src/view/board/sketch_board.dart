import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_model.dart';
import 'package:sketch_flow/sketch_view_model.dart';
import 'package:sketch_flow/sketch_view.dart';

class SketchBoard extends StatefulWidget {
  /// Main widget for the sketch board.
  ///
  /// [viewModel] The sketch viewModel used to manage drawing state.
  ///
  /// [repaintKey] RepaintBoundary key value (required for PNG extraction)
  ///
  /// [boardColor] Background color of the sketch board.
  ///
  /// [boardMaxScale] The maximum zoom level allowed when in move mode. (default is 5.0)
  ///
  /// [boardMinScale] The minimum zoom level allowed when in move mode. (default is 1.0)
  ///
  /// [backgroundColor] The background color of the Scaffold, which surrounds the canvas area (default is white)
  ///
  /// [isReadOnly] The Read-only mode (By default, the top and bottom bars are null)
  const SketchBoard({
    super.key,
    required this.viewModel,
    this.repaintKey,
    this.boardColor,
    this.boardMaxScale,
    this.boardMinScale,
    this.backgroundColor,
  });

  final SketchViewModel viewModel;
  final GlobalKey? repaintKey;
  final Color? boardColor;
  final double? boardMinScale;
  final double? boardMaxScale;
  final Color? backgroundColor;

  @override
  State<StatefulWidget> createState() => _SketchBoardState();
}

class _SketchBoardState extends State<SketchBoard> {
  @override
  Widget build(BuildContext context) {
    // Drawing mode widget
    Widget drawingModeWidget = Listener(
      onPointerDown: (event) => widget.viewModel.startNewLine(event.localPosition),
      onPointerMove: (event) => widget.viewModel.addPoint(event.localPosition),
      onPointerUp: (_) => widget.viewModel.endLine(),
      child: Container(
        color: widget.boardColor ?? Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: widget.viewModel,
          builder: (context, _) {
            return RepaintBoundary(
              key: widget.repaintKey,
              child: CustomPaint(
                painter: SketchPainter(widget.viewModel),
              ),
            );
          },
        ),
      ),
    );

    // Move mode widget with zoom and pan support
    Widget viewerModeWidget = Container(
      color: widget.boardColor ?? Colors.white,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: CustomPaint(
        painter: SketchPainter(widget.viewModel),
      ),
    );

    return ValueListenableBuilder<SketchToolType>(
        valueListenable: widget.viewModel.toolTypeNotifier,
        builder: (context, toolType, _) {
          bool isMoveArea = toolType == SketchToolType.move;

          return InteractiveViewer(
            constrained: false,
            panEnabled: isMoveArea,
            maxScale: isMoveArea ? widget.boardMaxScale ?? 5.0 : 1.0,
            minScale: isMoveArea ? widget.boardMinScale ?? 0.5 : 1.0,
            child: isMoveArea ? viewerModeWidget : drawingModeWidget,
          );
        }
    );
  }

}
