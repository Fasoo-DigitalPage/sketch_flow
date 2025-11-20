import 'package:flutter/cupertino.dart';

import '../../../sketch_flow.dart';

class CustomEraserConfig {
  final EraserMode currentMode;
  final double currentRadius;
  final double minRadius;
  final double maxRadius;
  final ValueChanged<EraserMode?> onModeChanged;
  final ValueChanged<double> onRadiusChanged;
  final Function() closeEraserConfigOverlay;

  const CustomEraserConfig({
    required this.currentMode,
    required this.currentRadius,
    required this.minRadius,
    required this.maxRadius,
    required this.onModeChanged,
    required this.onRadiusChanged,
    required this.closeEraserConfigOverlay,
  });
}

typedef EraserConfigBuilder = Widget Function(
  BuildContext context,
  CustomEraserConfig data,
);
