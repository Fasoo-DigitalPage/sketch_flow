import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_flow.dart';
import 'package:sketch_flow/src/widgets/base_thickness.dart';

class SketchToolItem {
  final SketchToolType toolType;
  final Widget activeIcon;
  final Widget inActiveIcon;

  SketchToolItem({required this.toolType, required this.activeIcon, required this.inActiveIcon});
}

class SketchBottomBar extends StatefulWidget {
  const SketchBottomBar({
    super.key,
    required this.controller,
    this.height,
    this.activePencilIcon,
    this.inActivePencilIcon,
    this.activeEraserIcon,
    this.inActiveEraserIcon,
    this.paletteIcon,
    this.clearIcon,
    this.bottomBarColor,
    this.bottomBarBorderColor,
    this.bottomBarBorderWidth
  });

  final SketchController controller;
  final double? height;

  /// Bottom Bar
  final Color? bottomBarColor;
  final Color? bottomBarBorderColor;
  final double? bottomBarBorderWidth;

  /// Pencil Icons
  final Widget? activePencilIcon;
  final Widget? inActivePencilIcon;

  /// Eraser Icons
  final Widget? activeEraserIcon;
  final Widget? inActiveEraserIcon;

  /// Palette Icons
  final Widget? paletteIcon;

  /// Clear Icons
  final Widget? clearIcon;


  @override
  State<StatefulWidget> createState() => _SketchBottomBarState();
}

class _SketchBottomBarState extends State<SketchBottomBar> with TickerProviderStateMixin {
  late final _controller = widget.controller;
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  /// Key Value
  final GlobalKey _pencilKey = GlobalKey();
  final GlobalKey _eraserKey = GlobalKey();

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
  /// 연속 두번 탭하면 설정 창을 띄운다 (0.5초 간격)
  void _onToolTap({required SketchToolType toolType, required GlobalKey key}) {
    final now = DateTime.now();
    final lastTap = _lastTapTimes;

    setState(() {
      _selectedToolType = toolType;
    });
    _controller.updateConfig(_controller.currentSketchConfig.copyWith(toolType: toolType));

    if(lastTap != null && now.difference(lastTap) < const Duration(milliseconds: 500)) {
      /// 그리기 비활성화
      /// 펜 설정 Overlay를 띄운 뒤 외부영역을 터치 할 때
      /// 그리기 기능을 비활성화 한다.
      _controller.disableDrawing();
      _showToolConfig(toolType: toolType);
    }

    _lastTapTimes = now;
  }

  /// 그리기 옵션 설정 다이얼로그
  void _showToolConfig({required SketchToolType toolType}) {
    // 기존 Overlay 제거
    _toolConfigOverlay?.remove();
    _toolConfigOverlay = null;

    _toolConfigOverlay = OverlayEntry(
        builder: (context) => GestureDetector(
          // 외부 터치 감지
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _fadeController.reverse().then((_) {
              _toolConfigOverlay!.remove();
              _toolConfigOverlay = null;
            });
            // 그리기 활성화
            _controller.enableDrawing();
          },
          child: Stack(
            children: [
              Positioned(
                  bottom: 75,
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
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  BaseThickness(
                                    radius: 17.5,
                                    thickness: 1,
                                    onClickThickness: () => _onThicknessSelected(strokeWidth: 3.0),
                                  ),
                                  BaseThickness(
                                    radius: 17.5,
                                    thickness: 2,
                                    onClickThickness: () => _onThicknessSelected(strokeWidth: 4.5),
                                  ),
                                  BaseThickness(
                                    radius: 17.5,
                                    thickness: 3.5,
                                    onClickThickness: () => _onThicknessSelected(strokeWidth: 6),
                                  ),
                                  BaseThickness(
                                    radius: 17.5,
                                    thickness: 5,
                                    onClickThickness: () => _onThicknessSelected(strokeWidth: 8.5),
                                  ),
                                  BaseThickness(
                                    radius: 17.5,
                                    thickness: 7,
                                    onClickThickness: () => _onThicknessSelected(strokeWidth: 11.5),
                                  ),
                                ],
                              )
                            ],
                          ),
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
  void _onThicknessSelected({required double strokeWidth}) {
    _controller.updateConfig(_controller.currentSketchConfig.copyWith(strokeWidth: strokeWidth));
    _fadeController.reverse().then((_) async {
      await Future.delayed(Duration(milliseconds: 100));

      _toolConfigOverlay!.remove();
      _toolConfigOverlay = null;

      // 그리기 활성화
      _controller.enableDrawing();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 60,
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
          /// Pencil
          _toolButton(
              key: _pencilKey,
              toolItem: SketchToolItem(
                  toolType: SketchToolType.pencil,
                  activeIcon: widget.activePencilIcon ?? Icon(Icons.mode_edit_outline),
                  inActiveIcon: widget.inActivePencilIcon ?? Icon(Icons.mode_edit_outline_outlined),
              ),
              selectedToolType: _selectedToolType,
              onClickToolButton: () => _onToolTap(toolType: SketchToolType.pencil, key: _pencilKey)
          ),

          /// Eraser
          _toolButton(
              key: _eraserKey,
              toolItem: SketchToolItem(
                  toolType: SketchToolType.eraser,
                  activeIcon: widget.activeEraserIcon ?? Icon(Icons.square_rounded),
                  inActiveIcon: widget.inActiveEraserIcon ?? Icon(Icons.square_outlined)
              ),
              selectedToolType: _selectedToolType,
              onClickToolButton: () => _onToolTap(toolType: SketchToolType.eraser, key: _eraserKey)
          ),

          /// Trash
          IconButton(
              icon: widget.clearIcon ?? Icon(Icons.cleaning_services_rounded),
              onPressed: () {
                _controller.clear();
              }
          ),
        ],
      ),
    );
  }

  Widget _toolButton({
    required GlobalKey key,
    required SketchToolItem toolItem,
    required SketchToolType selectedToolType,
    required Function() onClickToolButton
  }) {
    final bool isActive = toolItem.toolType == selectedToolType;

    return IconButton(
        key: key,
        onPressed: onClickToolButton,
        icon: isActive ? toolItem.activeIcon : toolItem.inActiveIcon
    );
  }

}