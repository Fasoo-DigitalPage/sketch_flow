import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_flow.dart';

/// SketchBoard is the main widget that renders a drawable canvas.
///
/// It supports two modes:
/// - **Draw Mode**: where the user can draw handwriting directly on the canvas.
/// - **Move Mode**: where the canvas can be zoomed and panned.
///
/// Features:
/// - Renders handwriting using the [Sketchcontroller].
/// - Supports zoom and pan using [InteractiveViewer].
/// - Accepts overlay widgets (e.g., images or decorations) via [overlayWidgets].
/// - Wraps everything in a [RepaintBoundary] to support images export.
///
/// [controller]: Required controller that holds the drawing state.
/// [repaintKey]: Key used to extract the widget as an images (PNG).
/// [overlayWidgets]: Visual widgets (images, decorations, etc.) to be rendered below the drawing.
/// [boardColor]: Background color of the drawing area.
/// [boardMinScale], [boardMaxScale]: Zoom scale limits when in move mode.
/// [backgroundColor]: Scaffold background (outside the canvas).
/// [isPadDevice]: Enable palm rejection by separating stylus and touch input.
///
/// Note:
/// - All content, including overlay widgets and the canvas, will be captured when exporting as an images.
class SketchBoard extends StatefulWidget {
  /// Main widget for the sketch board.
  ///
  /// [controller] The sketch controller used to manage drawing state.
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
  ///
  /// [boardWidthSize] Board width size
  ///
  /// [boardHeightSize] Board height size
  ///
  /// [isPadDevice] Enables palm rejection by differentiating between touch and stylus input.
  ///
  /// When `true` (typically for tablets):
  /// - Drawing is restricted to [PointerDeviceKind.stylus] (pen).
  /// - Panning and zooming are handled by [PointerDeviceKind.touch] (finger).
  ///
  /// When `false` (typically for phones):
  /// - Drawing is handled by [PointerDeviceKind.touch].
  /// - Panning and zooming are only active in [SketchToolType.move].
  ///
  /// Defaults to `false`.
  ///
  /// [multiTouchPanZoomEnabled] Enable pan and zoom via multi-touch (two or more fingers)
  /// even when the tool type is set to Draw or Erase
  ///
  /// when `true`:
  /// - Two or more finger gesture will activate panning and zooming.
  /// - A single-finger gesture will still perform drawing/erasing
  ///
  /// When `false`:
  /// - Panning and zooming are only possible when `controller.toolType` is `SketchToolType.move`.
  ///
  /// Default to `false`.
  const SketchBoard({
    super.key,
    required this.controller,
    this.repaintKey,
    this.boardColor,
    this.boardMaxScale,
    this.boardMinScale,
    this.backgroundColor,
    this.overlayWidget,
    this.boardWidthSize,
    this.boardHeightSize,
    this.isPadDevice = false,
    this.multiTouchPanZoomEnabled = false
  });

  final SketchController controller;
  final GlobalKey? repaintKey;
  final Color? boardColor;
  final double? boardMinScale;
  final double? boardMaxScale;
  final Color? backgroundColor;
  final Widget? overlayWidget;

  final double? boardWidthSize;
  final double? boardHeightSize;

  final bool isPadDevice;
  final bool multiTouchPanZoomEnabled;

  @override
  State<StatefulWidget> createState() => _SketchBoardState();
}

class _SketchBoardState extends State<SketchBoard> {
  bool _isDrawing = false;
  final Set<int> _activePointers = {};

  Size _currentBoardSize = Size.zero;

  // Handles pointer down events.
  // Only starts a new line if the pointer is inside the drawing area.
  void _handlePointerDown(PointerDownEvent event) {
    final int previousCount = _activePointers.length;
    _activePointers.add(event.pointer);

    if (_activePointers.length != previousCount) {
      setState(() {});
    }

    final bool multiTouchZoomActive = widget.multiTouchPanZoomEnabled && _activePointers.length > 1;

    if (multiTouchZoomActive) {
      if (_isDrawing) {
        widget.controller.endLine();
        if (mounted) setState(() => _isDrawing = false);
      }
      return;
    }

    if (_activePointers.length > 1) {
      if (_isDrawing) {
        widget.controller.endLine();
        if (mounted) setState(() => _isDrawing = false);
      }

      if (!widget.multiTouchPanZoomEnabled) return;
      return;
    }

    if (_activePointers.length == 1) {
      final bool isStylus = event.kind == PointerDeviceKind.stylus;
      if ((widget.isPadDevice && isStylus) || (!widget.isPadDevice)) {
        if (_isInDrawingArea(event.localPosition)) {
          widget.controller.startNewLine(event.localPosition);
          if (mounted) setState(() => _isDrawing = true);
        }
      }
    }
  }

  // Handles pointer move events.
  // Only adds points to the current line if the pointer is inside the drawing area.
  // If the pointer moves outside, the current line is ended.
  void _handlePointerMove(PointerMoveEvent event) {
    if (_activePointers.length > 1) {
      return;
    }

    if (_isDrawing) {
      final bool isStylus = event.kind == PointerDeviceKind.stylus;
      if ((widget.isPadDevice && isStylus) || (!widget.isPadDevice)) {
        if (_isInDrawingArea(event.localPosition)) {
          widget.controller.addPoint(event.localPosition);
        } else {
          widget.controller.endLine();
        }
      }
    }
  }

  // Handles pointer up events.
  // Ends the current line regardless of position.
  void _handlePointerUp(PointerUpEvent event) {
    final int previousCount = _activePointers.length;
    _activePointers.remove(event.pointer);
    if (_activePointers.length != previousCount) {
      setState(() {});
    }

    if (_isDrawing) {
      widget.controller.endLine();
      if (mounted) {
        setState(() {
          _isDrawing = false;
        });
      }
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    final int previousCount = _activePointers.length;
    _activePointers.remove(event.pointer);
    if (_activePointers.length != previousCount) {
      setState(() {});
    }

    if (_isDrawing) {
      widget.controller.endLine();
      if (mounted) {
        setState(() {
          _isDrawing = false;
        });
      }
    }
  }

  // Checks if a given position is within the drawing area bounds.
  // Returns true if the position is inside, false otherwise.
  bool _isInDrawingArea(Offset pos) {
    return pos.dx >= 0 &&
        pos.dx <= _currentBoardSize.width &&
        pos.dy >= 0 &&
        pos.dy <= _currentBoardSize.height;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = widget.boardWidthSize ??
            (constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.of(context).size.width);

        final double height = widget.boardHeightSize ??
            (constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : MediaQuery.of(context).size.height);

        _currentBoardSize = Size(width, height);

        Widget canvasWidget = Container(
          color: widget.boardColor ?? Colors.white,
          width: width,
          height: height,
          child: Stack(
            children: [
              if (widget.overlayWidget != null)
                Positioned.fill(child: widget.overlayWidget!),
              AnimatedBuilder(
                animation: widget.controller,
                builder: (context, _) {
                  return CustomPaint(painter: SketchPainter(widget.controller));
                },
              ),
            ],
          ),
        );

        Widget repaintWrapper = RepaintBoundary(
          key: widget.repaintKey,
          child: canvasWidget,
        );

        return ValueListenableBuilder<SketchToolType>(
          valueListenable: widget.controller.toolTypeNotifier,
          builder: (context, toolType, _) {
            bool isMoveArea = toolType == SketchToolType.move;

            if (isMoveArea) {
              return InteractiveViewer(
                panEnabled: true,
                scaleEnabled: true,
                maxScale: widget.boardMaxScale ?? 5.0,
                minScale: widget.boardMinScale ?? 0.5,
                child: repaintWrapper,
              );
            }
            final bool multiTouchZoomActive =
                widget.multiTouchPanZoomEnabled && _activePointers.length > 1;

            final bool padSingleTouchPanActive =
                widget.isPadDevice && !_isDrawing && _activePointers.length == 1;

            final bool panActive;
            final bool scaleActive;

            if (multiTouchZoomActive) {
              panActive = true;
              scaleActive = true;
            } else if (padSingleTouchPanActive) {
              panActive = true;
              scaleActive = false;
            } else {
              panActive = false;
              scaleActive = false;
            }

            final bool isPanZoomedEnabled = panActive || scaleActive;

            return InteractiveViewer(
              panEnabled: panActive,
              scaleEnabled: scaleActive,
              maxScale: isPanZoomedEnabled ? widget.boardMaxScale ?? 5.0 : 1.0,
              minScale: isPanZoomedEnabled ? widget.boardMinScale ?? 0.5 : 1.0,
              child: Listener(
                onPointerDown: (event) => _handlePointerDown(event),
                onPointerMove: (event) => _handlePointerMove(event),
                onPointerUp: (event) => _handlePointerUp(event),
                onPointerCancel: (event) => _handlePointerCancel(event),
                child: repaintWrapper,
              ),
            );
          },
        );
      },
    );
  }
}
