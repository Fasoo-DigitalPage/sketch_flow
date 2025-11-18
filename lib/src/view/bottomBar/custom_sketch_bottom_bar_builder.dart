import 'package:flutter/cupertino.dart';
import 'package:sketch_flow/sketch_flow.dart';

typedef CustomSketchBottomBarBuilder = Widget Function(
  BuildContext context,
  SketchBarActions onToolTap,
  SketchController controller,
  SketchToolType selectedToolType,
);

class SketchBarActions {
  final void Function({required SketchToolType toolType}) onToolTap;

  const SketchBarActions({
    required this.onToolTap,
  });
}
