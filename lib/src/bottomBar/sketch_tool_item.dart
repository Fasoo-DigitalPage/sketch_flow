import 'package:flutter/cupertino.dart';
import '../../sketch_flow.dart';

/// [toolType] 도구 종류
///
/// [activeIcon] 활성 아이콘
///
/// [inActiveIcon] 비활성 아이콘
class SketchToolItem {
  final SketchToolType toolType;
  final Widget activeIcon;
  final Widget inActiveIcon;

  SketchToolItem({required this.toolType, required this.activeIcon, required this.inActiveIcon});
}