import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_model.dart';
import 'package:sketch_flow/sketch_view_model.dart';
import 'package:sketch_flow/sketch_view.dart';

/// SketchBoard is the main widget that renders a drawable canvas.
///
/// It supports two modes:
/// - **Draw Mode**: where the user can draw handwriting directly on the canvas.
/// - **Move Mode**: where the canvas can be zoomed and panned.
///
/// Features:
/// - Renders handwriting using the [SketchViewModel].
/// - Supports zoom and pan using [InteractiveViewer].
/// - Accepts overlay widgets (e.g., images or decorations) via [overlayWidgets].
/// - Wraps everything in a [RepaintBoundary] to support images export.
///
/// [viewModel]: Required controller that holds the drawing state.
/// [repaintKey]: Key used to extract the widget as an images (PNG).
/// [overlayWidgets]: Visual widgets (images, decorations, etc.) to be rendered below the drawing.
/// [boardColor]: Background color of the drawing area.
/// [boardMinScale], [boardMaxScale]: Zoom scale limits when in move mode.
/// [backgroundColor]: Scaffold background (outside the canvas).
///
/// Note:
/// - All content, including overlay widgets and the canvas, will be captured when exporting as an images.
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
  ///
  /// [overlayWidgets] The visual widgets
  const SketchBoard({
    super.key,
    required this.viewModel,
    this.repaintKey,
    this.boardColor,
    this.boardMaxScale,
    this.boardMinScale,
    this.backgroundColor,
    this.overlayWidgets,
  });

  final SketchViewModel viewModel;
  final GlobalKey? repaintKey;
  final Color? boardColor;
  final double? boardMinScale;
  final double? boardMaxScale;
  final Color? backgroundColor;
  final List<Widget>? overlayWidgets;

  @override
  State<StatefulWidget> createState() => _SketchBoardState();
}

class _SketchBoardState extends State<SketchBoard> {
  @override
  Widget build(BuildContext context) {
    // Drawing mode widget
    Widget drawingModeWidget = Listener(
      onPointerDown:
          (event) => widget.viewModel.startNewLine(event.localPosition),
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
              child: Stack(
                children: [
                  if (widget.overlayWidgets != null) ...?widget.overlayWidgets,
                  CustomPaint(painter: SketchPainter(widget.viewModel)),
                ],
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
      child: AnimatedBuilder(
        animation: widget.viewModel,
        builder: (context, _) {
          return RepaintBoundary(
            key: widget.repaintKey,
            child: Stack(
              children: [
                if (widget.overlayWidgets != null) ...?widget.overlayWidgets,
                CustomPaint(painter: SketchPainter(widget.viewModel)),
              ],
            ),
          );
        },
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
      },
    );
  }
}
