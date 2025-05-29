import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_controller.dart';
import 'package:sketch_flow/sketch_view.dart';
import 'package:sketch_flow/sketch_model.dart';

/// Number of ColorPicker representation colors
const int _colorStepsCounts = 1792;

class SketchBottomBar extends StatefulWidget {
  /// A bottom bar that provides tools for handwriting or sketching.
  ///
  /// [controller] The sketch controller that manages drawing state.
  ///
  /// [bottomBarHeight] The height of the bottom bar.
  ///
  /// [bottomBarColor] The background color of the bottom bar.
  ///
  /// [moveIcon] Move icon (see [SketchToolIcon])
  ///
  /// [pencilIcon] Pencil icon (see [SketchToolIcon])
  ///
  /// [brushIcon] Brush Icon (see [SketchToolIcon])
  ///
  /// [highlighterIcon] Highlighter Icon (see [SketchToolIcon])
  ///
  /// [eraserIcon] Eraser Icon (see [SketchToolIcon])
  ///
  /// [lineIcon] Line Icon (see [SketchToolIcon])
  ///
  /// [rectangleIcon] Rectangle Icon (see [SketchToolIcon])
  ///
  /// [circleIcon] Circle Icon (see [SketchToolIcon])
  ///
  /// [clearIcon] Icon used for the "clear all" function.
  ///
  /// [paletteIcon] Icon for opening the color palette.
  ///
  /// [eraserRadioButtonColor] The color of the eraser type radio button
  ///
  /// [eraserThicknessTextStyle] The TextStyle that displays the current eraser thickness as text
  ///
  /// [eraserThicknessSliderThemeData] The theme data used to customize the appearance of the eraser thickness slider
  ///
  /// [penOpacitySliderThemeData] The theme data used to customize the appearance of the pen opacity slider
  ///
  /// [overlayBackgroundColor] The color of the overlay
  ///
  /// [showColorPickerSliderBar] ColorPicker Slider active or not (base true)
  const SketchBottomBar({
    super.key,
    required this.controller,
    this.bottomBarHeight,
    this.bottomBarColor = Colors.white,
    this.bottomBarBorderColor = Colors.grey,
    this.bottomBarBorderWidth,
    this.moveIcon,
    this.pencilIcon,
    this.eraserIcon,
    this.lineIcon,
    this.brushIcon,
    this.highlighterIcon,
    this.clearIcon,
    this.paletteIcon,
    this.rectangleIcon,
    this.circleIcon,
    this.eraserRadioButtonColor = Colors.black,
    this.eraserThicknessTextStyle,
    this.eraserThicknessSliderThemeData,
    this.penOpacitySliderThemeData,
    this.overlayBackgroundColor = Colors.white,
    this.showColorPickerSliderBar = true,
  });

  final SketchController controller;

  final double? bottomBarHeight;
  final Color bottomBarColor;
  final Color bottomBarBorderColor;
  final double? bottomBarBorderWidth;

  final SketchToolIcon? moveIcon;
  final SketchToolIcon? pencilIcon;
  final SketchToolIcon? brushIcon;
  final SketchToolIcon? highlighterIcon;
  final SketchToolIcon? eraserIcon;

  final SketchToolIcon? lineIcon;
  final SketchToolIcon? rectangleIcon;
  final SketchToolIcon? circleIcon;

  final Widget? paletteIcon;
  final Widget? clearIcon;

  final Color eraserRadioButtonColor;
  final TextStyle? eraserThicknessTextStyle;
  final SliderThemeData? eraserThicknessSliderThemeData;

  final SliderThemeData? penOpacitySliderThemeData;

  final Color overlayBackgroundColor;

  final bool showColorPickerSliderBar;

  @override
  State<StatefulWidget> createState() => _SketchBottomBarState();
}

class _SketchBottomBarState extends State<SketchBottomBar>
    with TickerProviderStateMixin {
  late final _controller = widget.controller;

  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;
  late double _safeAreaBottomPadding;

  /// The overlay entry for showing tool configuration options.
  OverlayEntry? _toolConfigOverlay;

  /// The currently selected drawing tool.
  SketchToolType _selectedToolType = SketchToolType.pencil;

  /// The currently selected eraser mode (stroke or area).
  EraserMode _selectedEraserType = EraserMode.area;

  /// ColorPicker color value list
  late List<Color> _rgbGradientColors;

  late int _selectedColorIndex;

  @override
  void initState() {
    super.initState();

    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.showColorPickerSliderBar) {
      _generateRGBGradientColors(colorStepCounts: _colorStepsCounts);

      _selectedColorIndex = _findClosestColorIndex(
        target: _controller.currentSketchConfig.lastUsedColor,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _fadeAnimationController.dispose();
  }

  /// Handles tool selection.
  /// Call _showToolConfig if the tabs currently pressed are the same
  void _onToolTap({required SketchToolType toolType}) {
    final updateConfig = _controller.currentSketchConfig.copyWith(
      toolType: toolType,
    );

    if (toolType == _selectedToolType || toolType == SketchToolType.palette) {
      _showToolConfig(toolType: toolType);
      _controller.disableDrawing();
    }

    if (toolType != SketchToolType.palette) {
      if (toolType != _controller.currentSketchConfig.toolType) {
        setState(() {
          _selectedColorIndex = _findClosestColorIndex(
            target: updateConfig.effectiveConfig.color,
          );
        });
      }

      setState(() {
        _selectedToolType = toolType;
      });
      _controller.updateConfig(toolType: toolType);
    }
  }

  /// Displays the configuration options for the selected tool
  /// such as thickness, color, or eraser type.
  void _showToolConfig({required SketchToolType toolType}) {
    if (toolType == SketchToolType.move) return;

    _toolConfigOverlay?.remove();
    _toolConfigOverlay = null;

    final colorList = _controller.currentSketchConfig.colorList;

    Widget applyWidget = SizedBox.shrink();

    if (toolType.isUsedConfig) {
      applyWidget = _drawingConfigWidget();
    } else {
      applyWidget = switch (toolType) {
        SketchToolType.eraser => _eraserConfigWidget(),
        SketchToolType.palette => _paletteConfigWidget(colorList: colorList),
        _ => SizedBox.shrink(),
      };
    }

    _toolConfigOverlay = OverlayEntry(
      builder: (context) => GestureDetector(
        // Close the overlay when touching the external area.
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _controller.enableDrawing();

          if (_toolConfigOverlay != null) {
            _toolConfigOverlay!.remove();
            _toolConfigOverlay = null;
          }
        },
        child: Stack(
          children: [
            Positioned(
              bottom: (widget.bottomBarHeight ?? 70) + (_safeAreaBottomPadding),
              left: 25,
              right: 25,
              child: GestureDetector(
                onTap: () {},
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.overlayBackgroundColor,
                      border: Border.all(color: Colors.grey, width: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 4,
                    ),
                    child: StatefulBuilder(
                      builder: (context, selModalState) {
                        return applyWidget;
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_toolConfigOverlay!);
    _fadeAnimationController.forward(from: 0.0);
  }

  /// Called when a stroke thickness is selected.
  /// Updates the stroke width, closes the overlay, and enables drawing.
  void _onThicknessSelected({required double strokeThickness}) {
    _fadeAnimationController.reverse().then((_) async {
      _controller.updateConfig(lastUsedStrokeThickness: strokeThickness);
      _controller.enableDrawing();

      await Future.delayed(Duration(milliseconds: 100));

      if (_toolConfigOverlay != null) {
        _toolConfigOverlay!.remove();
        _toolConfigOverlay = null;
      }
    });
  }

  /// Called when a color is selected from the palette.
  /// Updates the drawing color, closes the overlay, and enables drawing.
  void _onColorSelected({required Color color}) {
    _fadeAnimationController.reverse().then((_) async {
      _controller.updateConfig(lastUsedColor: color);
      _controller.enableDrawing();

      // Update ColorPicker thumbBar value
      if (widget.showColorPickerSliderBar) {
        setState(() {
          _selectedColorIndex = _findClosestColorIndex(target: color);
        });
      }

      await Future.delayed(Duration(milliseconds: 100));

      if (_toolConfigOverlay != null) {
        _toolConfigOverlay!.remove();
        _toolConfigOverlay = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    /// Bottom safe area padding for proper positioning of the overlay.
    _safeAreaBottomPadding = MediaQuery.of(context).padding.bottom;

    return SafeArea(
      child: Container(
        height: widget.bottomBarHeight ?? 60,
        decoration: BoxDecoration(
          color: widget.bottomBarColor,
          border: Border(
            top: BorderSide(
              color: widget.bottomBarBorderColor,
              width: widget.bottomBarBorderWidth ?? 0.5,
            ),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                /// Move tool
                _toolButtonWidget(
                  toolType: SketchToolType.move,
                  icon: SketchToolIcon(
                    enableIcon:
                        widget.moveIcon?.enableIcon ?? Icon(Icons.pinch),
                    disableIcon: widget.moveIcon?.disableIcon ??
                        Icon(Icons.pinch_outlined),
                  ),
                  onClickToolButton: () =>
                      _onToolTap(toolType: SketchToolType.move),
                ),

                /// Default pen tool
                _toolButtonWidget(
                  toolType: SketchToolType.pencil,
                  icon: SketchToolIcon(
                    enableIcon: widget.pencilIcon?.enableIcon ??
                        Icon(
                          Icons.mode_edit_outline,
                          color: _controller
                              .currentSketchConfig.pencilConfig.color,
                        ),
                    disableIcon: widget.pencilIcon?.disableIcon ??
                        Icon(
                          Icons.mode_edit_outline_outlined,
                          color: _controller
                              .currentSketchConfig.pencilConfig.color,
                        ),
                  ),
                  onClickToolButton: () =>
                      _onToolTap(toolType: SketchToolType.pencil),
                ),

                /// Brush tool
                _toolButtonWidget(
                  toolType: SketchToolType.brush,
                  icon: SketchToolIcon(
                    enableIcon: widget.brushIcon?.enableIcon ??
                        Icon(
                          Icons.brush_rounded,
                          color:
                              _controller.currentSketchConfig.brushConfig.color,
                        ),
                    disableIcon: widget.brushIcon?.disableIcon ??
                        Icon(
                          Icons.brush_outlined,
                          color:
                              _controller.currentSketchConfig.brushConfig.color,
                        ),
                  ),
                  onClickToolButton: () =>
                      _onToolTap(toolType: SketchToolType.brush),
                ),

                /// highlighter tool
                _toolButtonWidget(
                  toolType: SketchToolType.highlighter,
                  icon: SketchToolIcon(
                    enableIcon: widget.highlighterIcon?.enableIcon ??
                        Icon(
                          Icons.colorize_rounded,
                          color: _controller
                              .currentSketchConfig.highlighterConfig.color,
                        ),
                    disableIcon: widget.highlighterIcon?.disableIcon ??
                        Icon(
                          Icons.colorize_outlined,
                          color: _controller
                              .currentSketchConfig.highlighterConfig.color,
                        ),
                  ),
                  onClickToolButton: () =>
                      _onToolTap(toolType: SketchToolType.highlighter),
                ),

                /// Eraser tool
                _toolButtonWidget(
                  toolType: SketchToolType.eraser,
                  icon: SketchToolIcon(
                    enableIcon: widget.eraserIcon?.enableIcon ??
                        Icon(CupertinoIcons.bandage_fill),
                    disableIcon: widget.eraserIcon?.disableIcon ??
                        Icon(CupertinoIcons.bandage),
                  ),
                  onClickToolButton: () =>
                      _onToolTap(toolType: SketchToolType.eraser),
                ),

                /// Line tool
                _toolButtonWidget(
                  toolType: SketchToolType.line,
                  icon: SketchToolIcon(
                    enableIcon: widget.lineIcon?.enableIcon ??
                        Icon(
                          Icons.show_chart_rounded,
                          color:
                              _controller.currentSketchConfig.lineConfig.color,
                        ),
                    disableIcon: widget.lineIcon?.disableIcon ??
                        Icon(
                          Icons.show_chart_outlined,
                          color:
                              _controller.currentSketchConfig.lineConfig.color,
                        ),
                  ),
                  onClickToolButton: () =>
                      _onToolTap(toolType: SketchToolType.line),
                ),

                /// Rectangle tool
                _toolButtonWidget(
                  toolType: SketchToolType.rectangle,
                  icon: SketchToolIcon(
                    enableIcon: widget.rectangleIcon?.enableIcon ??
                        Icon(
                          Icons.rectangle,
                          color: _controller
                              .currentSketchConfig.rectangleConfig.color,
                        ),
                    disableIcon: widget.rectangleIcon?.disableIcon ??
                        Icon(
                          Icons.rectangle_outlined,
                          color: _controller
                              .currentSketchConfig.rectangleConfig.color,
                        ),
                  ),
                  onClickToolButton: () =>
                      _onToolTap(toolType: SketchToolType.rectangle),
                ),

                /// Circle tool
                _toolButtonWidget(
                  toolType: SketchToolType.circle,
                  icon: SketchToolIcon(
                    enableIcon: widget.circleIcon?.enableIcon ??
                        Icon(
                          Icons.circle_rounded,
                          color: _controller
                              .currentSketchConfig.circleConfig.color,
                        ),
                    disableIcon: widget.circleIcon?.disableIcon ??
                        Icon(
                          Icons.circle_outlined,
                          color: _controller
                              .currentSketchConfig.circleConfig.color,
                        ),
                  ),
                  onClickToolButton: () =>
                      _onToolTap(toolType: SketchToolType.circle),
                ),

                /// Color palette
                IconButton(
                  icon: widget.paletteIcon ?? Icon(Icons.palette_rounded),
                  onPressed: () => _onToolTap(toolType: SketchToolType.palette),
                  iconSize: 24,
                ),

                /// Clear all drawings
                IconButton(
                  icon:
                      widget.clearIcon ?? Icon(Icons.cleaning_services_rounded),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolButtonWidget({
    required SketchToolType toolType,
    required SketchToolIcon icon,
    required Function() onClickToolButton,
  }) {
    final bool isActive = toolType == _selectedToolType;
    final double targetSize = isActive ? icon.size * 1.5 : icon.size;

    final Widget selectedWidget = isActive ? icon.enableIcon : icon.disableIcon;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: IconButton(
        onPressed: onClickToolButton,
        icon: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: targetSize, end: targetSize),
          duration: Duration(milliseconds: 200),
          builder: (context, size, child) {
            return SizedBox(
              width: size,
              height: size,
              child: Center(
                child: FittedBox(fit: BoxFit.contain, child: child),
              ),
            );
          },
          child: selectedWidget,
        ),
        iconSize: 48,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }

  /// Build the stroke thickness selection widget for drawing tools.
  Widget _drawingConfigWidget() {
    final effectiveConfig = _controller.currentSketchConfig.effectiveConfig;

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              effectiveConfig.strokeThicknessList.length,
              (index) {
                return BaseThickness(
                  radius: 17.5,
                  index: index,
                  isSelected: effectiveConfig.strokeThickness ==
                      effectiveConfig.strokeThicknessList[index],
                  color: effectiveConfig.color,
                  onClickThickness: () => _onThicknessSelected(
                    strokeThickness: effectiveConfig.strokeThicknessList[index],
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 4.0),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final effectiveConfig =
                _controller.currentSketchConfig.effectiveConfig;

            return Material(
              color: widget.overlayBackgroundColor,
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: SliderTheme(
                  data: widget.penOpacitySliderThemeData ??
                      SliderTheme.of(context).copyWith(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        trackShape: GradientTrackShape(
                          trackHeight: 8.0,
                          gradient: LinearGradient(
                            colors: [
                              effectiveConfig.color.withValues(alpha: 0.0),
                              effectiveConfig.color.withValues(alpha: 1.0),
                            ],
                          ),
                        ),
                        inactiveTickMarkColor: effectiveConfig.color,
                        thumbColor: effectiveConfig.color,
                        overlayColor: effectiveConfig.color.withValues(
                          alpha: 0.05,
                        ),
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                  child: Slider(
                    value: effectiveConfig.opacity,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (opacity) {
                      _controller.updateConfig(lastUsedOpacity: opacity);
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Builds the color palette selection widget.
  Widget _paletteConfigWidget({required List<Color> colorList}) {
    return Center(
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(colorList.length, (index) {
                return BaseCircle(
                  radius: 17.5,
                  color: colorList[index],
                  onClickCircle: () =>
                      _onColorSelected(color: colorList[index]),
                );
              }),
            ),
          ),
          if (widget.showColorPickerSliderBar)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final effectiveConfig =
                    _controller.currentSketchConfig.effectiveConfig;

                return Material(
                  color: widget.overlayBackgroundColor,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        activeTrackColor: Colors.transparent,
                        inactiveTrackColor: Colors.transparent,
                        trackShape: ColorPickerSliderShape(
                          trackHeight: 10.0,
                          colorStepCount: _colorStepsCounts,
                          colors: _rgbGradientColors,
                        ),
                        inactiveTickMarkColor: effectiveConfig.color,
                        thumbColor: effectiveConfig.color,
                        overlayColor: effectiveConfig.color.withValues(
                          alpha: 0.05,
                        ),
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                      child: Slider(
                        value: _selectedColorIndex.toDouble(),
                        min: 0.0,
                        max: (_colorStepsCounts - 1).toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _selectedColorIndex = value.round();
                            _controller.updateConfig(
                                lastUsedColor:
                                    _rgbGradientColors[_selectedColorIndex]);
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  /// Build the eraser configuration widget.
  /// Allows users to choose between area erasing and stroke erasing.
  Widget _eraserConfigWidget({Text? areaEraserText, Text? strokeEraserText}) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final config = _controller.currentSketchConfig;

        return Material(
          color: widget.overlayBackgroundColor,
          child: Column(
            children: [
              RadioListTile<EraserMode>(
                title: areaEraserText ??
                    Text("Area eraser", style: TextStyle(fontSize: 14)),
                activeColor: widget.eraserRadioButtonColor,
                value: EraserMode.area,
                groupValue: _selectedEraserType,
                onChanged: (value) {
                  setState(() {
                    _selectedEraserType = value!;
                  });
                  _controller.updateConfig(eraserMode: value);
                },
              ),
              RadioListTile<EraserMode>(
                title: strokeEraserText ??
                    Text("Stroke eraser", style: TextStyle(fontSize: 14)),
                activeColor: widget.eraserRadioButtonColor,
                value: EraserMode.stroke,
                groupValue: _selectedEraserType,
                onChanged: (value) {
                  setState(() {
                    _selectedEraserType = value!;
                  });
                  _controller.updateConfig(eraserMode: value);
                },
              ),
              SizedBox(height: 12),
              Column(
                children: [
                  Text(
                    "${(config.eraserRadius % 1 >= 0.75) ? config.eraserRadius.ceil() : config.eraserRadius.floor()}",
                    style: widget.eraserThicknessTextStyle ??
                        TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SliderTheme(
                    data: widget.eraserThicknessSliderThemeData ??
                        SliderTheme.of(context).copyWith(
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 25,
                          ),
                          activeTrackColor: Colors.black,
                          inactiveTrackColor: Colors.black.withAlpha(15),
                          inactiveTickMarkColor: Colors.black,
                          thumbColor: Colors.black,
                          overlayColor: Colors.black.withValues(alpha: 0.05),
                          secondaryActiveTrackColor: Colors.black,
                          trackHeight: 4,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                          ),
                        ),
                    child: Slider(
                      value: config.eraserRadius,
                      min: config.eraserRadiusMin,
                      max: config.eraserRadiusMax,
                      divisions: 9,
                      onChanged: (eraserRadius) {
                        _controller.updateConfig(eraserRadius: eraserRadius);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Initialize gradient color list with RGB values.
  void _generateRGBGradientColors({required int colorStepCounts}) {
    List<List<int>> rgbStops = [
      [255, 255, 255], // white
      [255, 0, 0], // red
      [255, 255, 0], // yellow
      [0, 255, 0], // green
      [0, 255, 255], // cyan
      [0, 0, 255], // blue
      [255, 0, 255], // magenta
      [0, 0, 0], // black
    ];

    _rgbGradientColors = [];

    int segments = rgbStops.length - 1;
    int stepsPerSegment = (_colorStepsCounts / segments).floor();

    for (int i = 0; i < segments; i++) {
      List<int> start = rgbStops[i];
      List<int> end = rgbStops[i + 1];

      for (int j = 0; j < stepsPerSegment; j++) {
        double t = j / stepsPerSegment;
        int r = (start[0] + (end[0] - start[0]) * t).round();
        int g = (start[1] + (end[1] - start[1]) * t).round();
        int b = (start[2] + (end[2] - start[2]) * t).round();
        _rgbGradientColors.add(Color.fromARGB(255, r, g, b));
      }
    }

    // Add remaining colors
    while (_rgbGradientColors.length < _colorStepsCounts) {
      _rgbGradientColors.add(Color.fromARGB(255, 0, 0, 0));
    }
  }

  int _findClosestColorIndex({required Color target}) {
    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < _rgbGradientColors.length; i++) {
      final c = _rgbGradientColors[i];

      final dr = target.r * 255 - c.r * 255;
      final dg = target.g * 255 - c.g * 255;
      final db = target.b * 255 - c.b * 255;

      final distance = dr * dr + dg * dg + db * db;

      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }
}
