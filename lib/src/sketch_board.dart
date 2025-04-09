import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_flow.dart';
import 'package:sketch_flow/src/bottomBar/sketch_bottom_bar.dart';

/// 그리기 메인 위젯
///
/// [controller] 스케치 컨트롤러 (SketchController)
///
/// [boardColor] 바탕 색상
class SketchBoard extends StatefulWidget {
  const SketchBoard({
    super.key,
    this.controller,
    this.boardColor
  });

  final SketchController? controller;
  final Color? boardColor;

  @override
  State<StatefulWidget> createState() => _SketchBoardState();
}

class _SketchBoardState extends State<SketchBoard> {
  late final _controller = widget.controller ?? SketchController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.boardColor ?? Colors.white,
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
                builder: (BuildContext buildContext, BoxConstraints boxConstraints) {
                  return Listener(
                    // 화면을 터치할 때 호출
                      onPointerDown: (PointerDownEvent event) {
                        _controller.startNewLine(event.localPosition);
                      },
                      // 손을 화면에서 뗄 때 호출
                      onPointerUp: (PointerUpEvent event) {
                        _controller.endLine();
                      },
                      // 시스템이 터치를 취소할 때 호출
                      onPointerCancel: (PointerCancelEvent event) {

                      },
                      // 터치한 상태에서 손을 움직일 때 호출
                      onPointerMove: (PointerMoveEvent event) {
                        _controller.addPoint(event.localPosition);
                      },

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
                            }
                        ),
                      )
                  );
                }
            ),
          ),
        ],
      ),
      bottomNavigationBar: SketchBottomBar(controller: _controller),
    );
  }

}