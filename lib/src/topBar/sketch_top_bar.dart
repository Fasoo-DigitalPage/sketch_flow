import 'package:flutter/material.dart';

/// 상단바
///
/// [topBarHeight] 상단바 높이
///
/// [topBarColor] 상단바 색상
///
/// [topBarBorderColor] 상단바 테두리 색상
///
/// [topBarBorderWidth] 상단바 테두리 두께
class SketchTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SketchTopBar({
    super.key,
    this.topBarHeight,
    this.topBarColor,
    this.topBarBorderColor,
    this.topBarBorderWidth
  });

  final double? topBarHeight;
  final Color? topBarColor;
  final Color? topBarBorderColor;
  final double? topBarBorderWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            decoration: BoxDecoration(
                color: topBarColor ?? Colors.white,
                border: Border(
                    bottom: BorderSide(
                        color: topBarBorderColor ?? Colors.grey,
                        width: topBarBorderWidth ?? 0.5
                    )
                )
            ),
            child: SizedBox(
              child: Text("test"),
            )
        )
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(topBarHeight ?? 30.0);
}