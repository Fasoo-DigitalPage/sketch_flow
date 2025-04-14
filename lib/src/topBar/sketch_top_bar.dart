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
///
/// [backButtonIcon] 이전 버튼 아이콘
///
/// [onClickBackButton] 이전 버튼 클릭 콜백 함수
class SketchTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SketchTopBar({
    super.key,
    this.topBarHeight,
    this.topBarColor,
    this.topBarBorderColor,
    this.topBarBorderWidth,
    this.backButtonIcon,
    this.onClickBackButton
  });

  final double? topBarHeight;
  final Color? topBarColor;
  final Color? topBarBorderColor;
  final double? topBarBorderWidth;

  final Widget? backButtonIcon;
  final Function()? onClickBackButton;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
                color: topBarColor ?? Colors.white,
                border: Border(
                    bottom: BorderSide(
                        color: topBarBorderColor ?? Colors.grey,
                        width: topBarBorderWidth ?? 0.5
                    )
                )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                    icon: backButtonIcon ?? Icon(Icons.arrow_back_ios, color: Colors.black,),
                    onPressed: onClickBackButton,
                )
              ],
            )
        )
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(topBarHeight ?? kToolbarHeight);
}