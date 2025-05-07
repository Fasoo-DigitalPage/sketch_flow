import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_flow.dart';
import 'package:sketch_flow/sketch_widgets.dart';

class SketchBottomBar extends StatefulWidget {
  /// A bottom bar that provides tools for handwriting or sketching.
  ///
  /// [controller] The sketch controller that manages drawing state.
  ///
  /// [bottomBarHeight] The height of the bottom bar.
  ///
  /// [bottomBarColor] The background color of the bottom bar.
  ///
  /// [pencil] Pencil widget (see SketchToolItem)
  /// 
  /// [brush] Brush Widget (see SketchToolItem)
  /// 
  /// [eraser] Eraser Widget (see SketchToolItem)
  ///
  /// [clearIcon] Icon used for the "clear all" function.
  ///
  /// [paletteIcon] Icon for opening the color palette.
  ///
  /// [eraserRadioButtonColor] The color of the eraser type radio button
  ///
  /// [eraserThicknessSliderColor] The color of the slider used to control the eraser thickness
  ///
  /// [eraserThicknessTextStyle] The TextStyle that displays the current eraser thickness as text
  ///
  /// [eraserThicknessSliderThemeData] The theme data used to customize the appearance of the eraser thickness slider
  const SketchBottomBar({
    super.key,
    required this.controller,
    this.bottomBarHeight,
    this.bottomBarColor,
    this.bottomBarBorderColor,
    this.bottomBarBorderWidth,
    this.pencil,
    this.eraser,
    this.brush,
    this.clearIcon,
    this.paletteIcon,
    this.eraserRadioButtonColor,
    this.eraserThicknessSliderColor,
    this.eraserThicknessTextStyle,
    this.eraserThicknessSliderThemeData,
    this.penOpacitySliderThemeData,
  });

  final SketchController controller;

  final double? bottomBarHeight;
  final Color? bottomBarColor;
  final Color? bottomBarBorderColor;
  final double? bottomBarBorderWidth;

  final SketchToolItem? pencil;
  final SketchToolItem? brush;
  final SketchToolItem? eraser;
  final Widget? paletteIcon;
  final Widget? clearIcon;

  final Color? eraserRadioButtonColor;
  final Color? eraserThicknessSliderColor;
  final TextStyle? eraserThicknessTextStyle;
  final SliderThemeData? eraserThicknessSliderThemeData;

  final SliderThemeData? penOpacitySliderThemeData;

  @override
  State<StatefulWidget> createState() => _SketchBottomBarState();
}

class _SketchBottomBarState extends State<SketchBottomBar> with TickerProviderStateMixin {
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

  late double _eraserRadius = widget.controller.currentSketchConfig.eraserRadius;
  late double _penOpacity = widget.controller.currentSketchConfig.opacity;
  
  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200)
    );
    _fadeAnimation = CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut
    );
  }

  @override
  void dispose() {
    super.dispose();
    _fadeAnimationController.dispose();
  }

  /// Handles tool selection.
  /// Call _showToolConfig if the tabs currently pressed are the same
  void _onToolTap({required SketchToolType toolType}) {
    if(toolType == _selectedToolType || toolType == SketchToolType.palette) {
      _showToolConfig(toolType: toolType);
    }

    if(toolType != SketchToolType.palette) {
      setState(() {
        _selectedToolType = toolType;
      });
      _controller.updateConfig(_controller.currentSketchConfig.copyWith(toolType: toolType));
    }
    _controller.disableDrawing();
  }

  /// Displays the configuration options for the selected tool
  /// such as thickness, color, or eraser type.
  void _showToolConfig({required SketchToolType toolType}) {
    if(toolType == SketchToolType.move) return;

    _toolConfigOverlay?.remove();
    _toolConfigOverlay = null;

    final strokeThicknessList = _controller.currentSketchConfig.strokeThicknessList;
    final colorList = _controller.currentSketchConfig.colorList;

    final applyWidget = switch(toolType) {
      SketchToolType.pencil => _drawingConfigWidget(strokeThicknessList: strokeThicknessList),
      SketchToolType.brush => _drawingConfigWidget(strokeThicknessList: strokeThicknessList),
      SketchToolType.eraser => _eraserConfigWidget(),
      SketchToolType.palette => _paletteConfigWidget(colorList: colorList),
      SketchToolType.move => SizedBox.shrink(),
    };

    _toolConfigOverlay = OverlayEntry(
        builder: (context) => GestureDetector(
          // Close the overlay when touching the external area.
          behavior: HitTestBehavior.translucent,
          onTap: () => _onThicknessSelected(strokeThickness: _controller.currentSketchConfig.strokeThickness),
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
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.grey,
                                  width: 0.2
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 2,
                                  offset: Offset(0, 2)
                                )
                              ]
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          child: StatefulBuilder(builder: (context, selModalState) {
                            return applyWidget;
                          }),
                        ),
                    ),
                  )
              )
            ],
          ),
        )
    );

    Overlay.of(context).insert(_toolConfigOverlay!);
    _fadeAnimationController.forward(from: 0.0);
  }

  /// Called when a stroke thickness is selected.
  /// Updates the stroke width, closes the overlay, and enables drawing.
  void _onThicknessSelected({required double strokeThickness}) {
    _fadeAnimationController.reverse().then((_) async {
      _controller.updateConfig(_controller.currentSketchConfig.copyWith(strokeThickness: strokeThickness));
      _controller.enableDrawing();

      await Future.delayed(Duration(milliseconds: 100));

      if(_toolConfigOverlay != null) {
        _toolConfigOverlay!.remove();
        _toolConfigOverlay = null;
      }
    });
  }

  /// Called when a color is selected from the palette.
  /// Updates the drawing color, closes the overlay, and enables drawing.
  void _onColorSelected({required Color color}) {
    _fadeAnimationController.reverse().then((_) async {
      _controller.updateConfig(_controller.currentSketchConfig.copyWith(color: color));
      _controller.enableDrawing();

      await Future.delayed(Duration(milliseconds: 100));

      if(_toolConfigOverlay != null) {
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
              color: widget.bottomBarColor ?? Colors.white,
              border: Border(
                  top: BorderSide(
                      color: widget.bottomBarBorderColor ?? Colors.grey,
                      width: widget.bottomBarBorderWidth ?? 0.5
                  )
              )
          ),
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  /// Move tool
                  _toolButtonWidget(
                      toolItem: SketchToolItem(
                          toolType: SketchToolType.move,
                          activeIcon: Icon(Icons.mouse),
                          inActiveIcon: Icon(Icons.mouse_outlined)
                      ),
                      selectedToolType: _selectedToolType,
                      onClickToolButton: () => _onToolTap(toolType: SketchToolType.move)
                  ),

                  /// Default pen tool
                  _toolButtonWidget(
                      toolItem: SketchToolItem(
                        toolType: SketchToolType.pencil,
                        activeIcon: widget.pencil?.activeIcon ?? Icon(Icons.mode_edit_outline),
                        inActiveIcon: widget.pencil?.inActiveIcon ?? Icon(Icons.mode_edit_outline_outlined),
                      ),
                      selectedToolType: _selectedToolType,
                      onClickToolButton: () => _onToolTap(toolType: SketchToolType.pencil)
                  ),

                  /// Brush tool
                  _toolButtonWidget(
                      toolItem: SketchToolItem(
                          toolType: SketchToolType.brush,
                          activeIcon: widget.brush?.activeIcon ?? Icon(Icons.brush_rounded),
                          inActiveIcon: widget.brush?.inActiveIcon ?? Icon(Icons.brush_outlined)
                      ),
                      selectedToolType: _selectedToolType,
                      onClickToolButton: () => _onToolTap(toolType: SketchToolType.brush)
                  ),

                  /// Eraser tool
                  _toolButtonWidget(
                      toolItem: SketchToolItem(
                          toolType: SketchToolType.eraser,
                          activeIcon: widget.eraser?.activeIcon ?? Icon(Icons.square_rounded),
                          inActiveIcon: widget.eraser?.inActiveIcon ?? Icon(Icons.square_outlined)
                      ),
                      selectedToolType: _selectedToolType,
                      onClickToolButton: () => _onToolTap(toolType: SketchToolType.eraser)
                  ),

                  /// Color palette
                  IconButton(
                    icon: widget.paletteIcon ?? Icon(Icons.palette_rounded),
                    onPressed: () => _onToolTap(toolType: SketchToolType.palette),
                  ),

                  /// Clear all drawings
                  IconButton(
                      icon: widget.clearIcon ?? Icon(Icons.cleaning_services_rounded),
                      onPressed: () {
                        _controller.clear();
                      }
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

  Widget _toolButtonWidget({
    required SketchToolItem toolItem,
    required SketchToolType selectedToolType,
    required Function() onClickToolButton
  }) {
    final bool isActive = toolItem.toolType == selectedToolType;
    final double targetSize = isActive ? 36.0 : 24.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0), // 일정한 간격 유지
      child: IconButton(
        onPressed: onClickToolButton,
        icon: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: targetSize, end: targetSize),
          duration: Duration(milliseconds: 200),
          builder: (context, size, child) {
            return IconTheme(
              data: IconThemeData(size: size),
              child: child!,
            );
          },
          child: isActive ? toolItem.activeIcon : toolItem.inActiveIcon,
        ),
        iconSize: 48,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: 48, minHeight: 48),
      ),
    );
  }

  /// Build the stroke thickness selection widget for drawing tools.
  Widget _drawingConfigWidget({required List<double> strokeThicknessList}) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(strokeThicknessList.length, (index) {
                return BaseThickness(
                  radius: 17.5,
                  thickness: strokeThicknessList[index],
                  isSelected: _controller.currentSketchConfig.strokeThickness == strokeThicknessList[index],
                  color: _controller.currentSketchConfig.color,
                  onClickThickness: () => _onThicknessSelected(strokeThickness: strokeThicknessList[index]),
                );
              })
          ),
        ),
        SizedBox(height: 4.0,),
        StatefulBuilder(
            builder: (context, setModalState) {
              return Material(
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: SliderTheme(
                    data: widget.penOpacitySliderThemeData ?? SliderTheme.of(context).copyWith(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      trackShape: GradientTrackShape(
                          trackHeight: 8.0,
                          gradient: LinearGradient(
                              colors: [
                                _controller.currentSketchConfig.color.withValues(alpha: 0.0),
                                _controller.currentSketchConfig.color.withValues(alpha: 1.0),
                              ]
                          )
                      ),
                      inactiveTickMarkColor: _controller.currentSketchConfig.color,
                      thumbColor: _controller.currentSketchConfig.color,
                      overlayColor: _controller.currentSketchConfig.color.withValues(alpha: 0.05),
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                        value: _penOpacity,
                        min: 0.0,
                        max: 1.0,
                        onChanged: (opacity) {
                          _controller.updateConfig(_controller.currentSketchConfig.copyWith(opacity: opacity));
                          setState(() { _penOpacity = opacity; });

                          // Call to show UI immediately reflect slider value in overlay inner widget.
                          setModalState((){});
                        }
                    ),
                  ),
                ),
              );
            }
        )
      ],
    );
  }

  /// Builds the color palette selection widget.
  Widget _paletteConfigWidget({required List<Color> colorList}) {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(colorList.length, (index) {
            return BaseCircle(
                radius: 17.5,
                color: colorList[index],
                onClickCircle: () => _onColorSelected(color: colorList[index])
            );
          }),
        ),
      ),
    );
  }

  /// Build the eraser configuration widget.
  /// Allows users to choose between area erasing and stroke erasing.
  Widget _eraserConfigWidget({Text? areaEraserText, Text? strokeEraserText}) {
    return StatefulBuilder(
        builder: (context, setModalState) {
          final config = _controller.currentSketchConfig;
          return Material(
            color: Colors.white,
            child: Column(
              children: [
                RadioListTile<EraserMode>(
                    title: areaEraserText ?? Text("Area eraser", style: TextStyle(fontSize: 14),),
                    activeColor: widget.eraserRadioButtonColor ?? Colors.black,
                    value: EraserMode.area,
                    groupValue: _selectedEraserType,
                    onChanged: (value) {
                      setState(() { _selectedEraserType = value!; });
                      _controller.updateConfig(_controller.currentSketchConfig.copyWith(eraserMode: value));

                      // Used to induce rebuild in the Stateful Builder inside the overlay.
                      // Invoking only the outer setState does not update the overlay widget itself
                      // The setModalState must also be invoked to immediately reflect changes in the internal widget.
                      setModalState((){});
                    }
                ),
                RadioListTile<EraserMode>(
                    title: strokeEraserText ?? Text("Stroke eraser", style: TextStyle(fontSize: 14),),
                    activeColor: widget.eraserRadioButtonColor ?? Colors.black,
                    value: EraserMode.stroke,
                    groupValue: _selectedEraserType,
                    onChanged: (value) {
                      setState(() { _selectedEraserType = value!; });
                      _controller.updateConfig(_controller.currentSketchConfig.copyWith(eraserMode: value));

                      // Call to show UI immediately reflect radio button value in overlay inner widget.
                      setModalState((){});
                    }
                ),
                SizedBox(height: 12,),
                Column(
                  children: [
                    Text(
                      "${(_eraserRadius%1 >= 0.75) ? _eraserRadius.ceil() : _eraserRadius.floor()}",
                      style: widget.eraserThicknessTextStyle ?? TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SliderTheme(
                        data: widget.eraserThicknessSliderThemeData ?? SliderTheme.of(context).copyWith(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 25),
                          activeTrackColor: Colors.black,
                          inactiveTrackColor: Colors.black.withAlpha(15),
                          inactiveTickMarkColor: Colors.black,
                          thumbColor: Colors.black,
                          overlayColor: Colors.black.withValues(alpha: 0.05),
                          secondaryActiveTrackColor: Colors.black,
                          trackHeight: 4,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
                        ),
                        child: Slider(
                            value: _eraserRadius,
                            min: config.eraserRadiusMin,
                            max: config.eraserRadiusMax,
                            divisions: config.eraserRadiusDivisions,
                            onChanged: (eraserRadius) {
                              _controller.updateConfig(_controller.currentSketchConfig.copyWith(eraserRadius: eraserRadius));
                              setState(() { _eraserRadius = eraserRadius; });

                              // Call to show UI immediately reflect slider value in overlay inner widget.
                              setModalState((){});
                            }
                        )
                    )
                  ],
                )
              ],
            ),
          );
        }
    );
  }

}