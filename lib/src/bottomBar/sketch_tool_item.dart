import 'package:flutter/cupertino.dart';
import 'package:sketch_flow/sketch_flow.dart';

/// [toolType] The type of sketch tool represented.
///
/// [activeIcon] The icon displayed when this tool is selected (active).
///
/// [inActiveIcon] The icon displayed when this tool is  not selected (inactive).
class SketchToolItem {
  final SketchToolType toolType;
  final Widget activeIcon;
  final Widget inActiveIcon;

  SketchToolItem({required this.toolType, required this.activeIcon, required this.inActiveIcon});
}