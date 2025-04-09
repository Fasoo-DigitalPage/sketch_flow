import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_flow.dart';
import 'package:sketch_flow/src/bottomBar/sketch_tool_item.dart';
import 'package:sketch_flow/src/widgets/base_circle.dart';
import 'package:sketch_flow/src/widgets/base_thickness.dart';

/// 그리기 도구 모음 하단바
///
/// [controller] 스케치 컨트롤러
///
/// [thicknessList] 그리기 도구 두께 리스트
///
/// [bottomBarHeight] 하단바 높이
///
/// [bottomBarColor] 하단바 색상
///
/// [activePencilIcon] 연필 활성화 아이콘
///
/// [inActivePencilIcon] 연필 비활성화 아이콘
///
/// [activeEraserIcon] 지우개 활성화 아이콘
///
/// [inActiveEraserIcon] 지우개 비활성화 아이콘
///
/// [clearIcon] 전체 삭제 아이콘
///
/// [paletteIcon] 색상 선택 아이콘
class SketchBottomBar extends StatefulWidget {
  const SketchBottomBar({
    super.key,
    required this.controller,
    this.bottomBarHeight,
    this.bottomBarColor,
    this.bottomBarBorderColor,
    this.bottomBarBorderWidth,
    this.activePencilIcon,
    this.inActivePencilIcon,
    this.activeEraserIcon,
    this.inActiveEraserIcon,
    this.clearIcon,
    this.paletteIcon,
  });

  final SketchController controller;

  final double? bottomBarHeight;
  final Color? bottomBarColor;
  final Color? bottomBarBorderColor;
  final double? bottomBarBorderWidth;

  final Widget? activePencilIcon;
  final Widget? inActivePencilIcon;

  final Widget? activeEraserIcon;
  final Widget? inActiveEraserIcon;

  final Widget? paletteIcon;

  final Widget? clearIcon;

  @override
  State<StatefulWidget> createState() => _SketchBottomBarState();
}

class _SketchBottomBarState extends State<SketchBottomBar> with TickerProviderStateMixin {
  late final _controller = widget.controller;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late double _safeAreaBottomPadding;

  /// 옵션 설정 OverlayEntry
  OverlayEntry? _toolConfigOverlay;

  /// 선택한 그리기 도구
  SketchToolType _selectedToolType = SketchToolType.pencil;

  /// 마지막 탭 시간
  DateTime? _lastTapTimes;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 200)
    );
    _fadeAnimation = CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut
    );
  }

  @override
  void dispose() {
    super.dispose();
    _fadeController.dispose();
  }

  /// 그리기 도구 선택
  /// 연속 두번 탭하면 옵션 설정을 띄운다 (0.5초 간격)
  void _onToolTap({required SketchToolType toolType}) {
    final now = DateTime.now();
    final lastTap = _lastTapTimes;

    /// 서론 다른 탭을 0.5초 이내에 눌렀을 때 옵션창을 띄우는 것을 방지
    /// 색상은 제외 (그리기 기능에 영향을 주지 않기 때문)
    if((toolType == SketchToolType.palette || _selectedToolType == toolType) &&
        lastTap != null && now.difference(lastTap) < const Duration(milliseconds: 500)) {
      /// 그리기 비활성화
      _controller.disableDrawing();
      _showToolConfig(toolType: toolType);
    }

    if(toolType != SketchToolType.palette) {
      setState(() {
        _selectedToolType = toolType;
      });
      _controller.updateConfig(_controller.currentSketchConfig.copyWith(toolType: toolType));
    }

    _lastTapTimes = now;
  }

  /// 옵션 설정 창
  void _showToolConfig({required SketchToolType toolType}) {
    /// 기존 Overlay 제거
    _toolConfigOverlay?.remove();
    _toolConfigOverlay = null;

    /// 두께 리스트
    final thicknessList = _controller.currentSketchConfig.thicknessList;

    /// 색상 리스트
    final colorList = _controller.currentSketchConfig.colorList;

    /// 설정할 옵션 위젯
    final applyWidget = switch(toolType) {
      SketchToolType.pencil => _drawingConfigWidget(thicknessList: thicknessList),
      SketchToolType.eraser => _drawingConfigWidget(thicknessList: thicknessList),
      SketchToolType.palette => _paletteConfigWidget(colorList: colorList)
    };

    _toolConfigOverlay = OverlayEntry(
        builder: (context) => GestureDetector(
          // 외부 터치 감지
          behavior: HitTestBehavior.translucent,
          onTap: () => _onThicknessSelected(strokeWidth: _controller.currentSketchConfig.strokeWidth),
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
                          child: applyWidget,
                        ),
                    ),
                  )
              )
            ],
          ),
        )
    );

    Overlay.of(context).insert(_toolConfigOverlay!);
    _fadeController.forward(from: 0.0);
  }

  /// 펜 굵기 선택 함수
  /// 선택 시 띄워져있는 Overlay 삭제 및 애니메이션 효과를 준다.
  /// 그리기를 활성화 시킨다.
  void _onThicknessSelected({required double strokeWidth}) {
    _fadeController.reverse().then((_) async {
      _controller.updateConfig(_controller.currentSketchConfig.copyWith(strokeWidth: strokeWidth));

      // 그리기 활성화
      _controller.enableDrawing();

      await Future.delayed(Duration(milliseconds: 100));

      if(_toolConfigOverlay != null) {
        _toolConfigOverlay!.remove();
        _toolConfigOverlay = null;
      }
    });
  }

  void _onColorSelected({required Color color}) {
    _fadeController.reverse().then((_) async {
      _controller.updateConfig(_controller.currentSketchConfig.copyWith(color: color));

      // 그리기 활성화
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
    /// SafeArea 하단 여백 영역
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              /// 기본 펜
              _toolButtonWidget(
                  toolItem: SketchToolItem(
                    toolType: SketchToolType.pencil,
                    activeIcon: widget.activePencilIcon ?? Icon(Icons.mode_edit_outline),
                    inActiveIcon: widget.inActivePencilIcon ?? Icon(Icons.mode_edit_outline_outlined),
                  ),
                  selectedToolType: _selectedToolType,
                  onClickToolButton: () => _onToolTap(toolType: SketchToolType.pencil)
              ),

              /// 지우개
              _toolButtonWidget(
                  toolItem: SketchToolItem(
                      toolType: SketchToolType.eraser,
                      activeIcon: widget.activeEraserIcon ?? Icon(Icons.square_rounded),
                      inActiveIcon: widget.inActiveEraserIcon ?? Icon(Icons.square_outlined)
                  ),
                  selectedToolType: _selectedToolType,
                  onClickToolButton: () => _onToolTap(toolType: SketchToolType.eraser)
              ),

              /// 색상 선택
              IconButton(
                icon: widget.paletteIcon ?? Icon(Icons.palette_rounded),
                onPressed: () => _onToolTap(toolType: SketchToolType.palette),
              ),

              /// 전체 삭제
              IconButton(
                  icon: widget.clearIcon ?? Icon(Icons.cleaning_services_rounded),
                  onPressed: () {
                    _controller.clear();
                  }
              ),
            ],
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

    return IconButton(
        onPressed: onClickToolButton,
        icon: isActive ? toolItem.activeIcon : toolItem.inActiveIcon
    );
  }

  Widget _drawingConfigWidget({required List<double> thicknessList}) {
    return Column(
      children: [
        /// 그리기 도구 두께 리스트 스크롤뷰
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(thicknessList.length, (index) {
                return BaseThickness(
                  radius: 17.5,
                  thickness: thicknessList[index],
                  onClickThickness: () => _onThicknessSelected(strokeWidth: thicknessList[index]),
                );
              })
          ),
        )
      ],
    );
  }

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

}