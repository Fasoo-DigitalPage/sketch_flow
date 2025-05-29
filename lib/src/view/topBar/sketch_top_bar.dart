import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_controller.dart';
import 'package:sketch_flow/sketch_view.dart';

class SketchTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Top bar widget
  ///
  /// [controller] The sketch controller used to manage drawing state
  ///
  /// [topBarHeight] The height of the top bar
  ///
  /// [topBarColor] The background color of the top bar
  ///
  /// [topBarBorderColor] The border color of the top bar
  ///
  /// [topBarBorderWidth] The border width of the top bar
  ///
  /// [backButtonIcon] The icon for the back button
  ///
  /// [onClickBackButton] Callback function invoked when the back button is pressed
  ///
  /// [undoIcon] The icon for the undo action (see [SketchToolIcon])
  ///
  /// [redoIcon] The icon for the redo action (see [SketchToolIcon])
  ///
  /// [exportSVGIcon] Export SVG Icon
  ///
  /// [onClickExtractSVG] Callback function invoked when SVG extract button is pressed
  ///
  /// [showExtractSVGIcon] Whether to show the SVG extract icon (default: false)
  ///
  /// [exportPNGIcon] Export PNG Icon
  ///
  /// [onClickExtractPNG] Callback function invoked when PNG extract button is pressed
  ///
  /// [showExtractPNGIcon] Whether to show the PNG extract icon (default: false)
  ///
  /// [exportJSONIcon] Export JSON Icon
  ///
  /// [onClickToJsonButton] Callback function invoked when the JSON button is pressed
  ///
  /// [showJsonDialogIcon] Whether to show the JSON dialog icon (default: false)
  ///
  /// [exportTestDataIcon] Export test data icon
  ///
  /// [showInputTestDataIcon] Whether to show the input test data icon (default: false)
  ///
  /// [onClickInputTestButton] Callback function invoked when the test input button is pressed
  ///
  const SketchTopBar({
    super.key,
    required this.controller,
    this.topBarHeight,
    this.topBarColor = Colors.white,
    this.topBarBorderColor = Colors.grey,
    this.topBarBorderWidth,
    this.backButtonIcon,
    this.onClickBackButton,
    this.undoIcon,
    this.redoIcon,
    this.exportSVGIcon,
    this.onClickExtractSVG,
    this.showExtractSVGIcon,
    this.exportPNGIcon,
    this.onClickExtractPNG,
    this.showExtractPNGIcon,
    this.exportJSONIcon,
    this.onClickToJsonButton,
    this.showJsonDialogIcon,
    this.exportTestDataIcon,
    this.showInputTestDataIcon,
    this.onClickInputTestButton,
  });

  final SketchController controller;

  final double? topBarHeight;
  final Color topBarColor;
  final Color topBarBorderColor;
  final double? topBarBorderWidth;

  final Widget? backButtonIcon;
  final Function()? onClickBackButton;

  final SketchToolIcon? undoIcon;
  final SketchToolIcon? redoIcon;

  final Widget? exportSVGIcon;
  final Function(List<Offset>)? onClickExtractSVG;
  final bool? showExtractSVGIcon;

  final Widget? exportPNGIcon;
  final Function()? onClickExtractPNG;
  final bool? showExtractPNGIcon;

  final Widget? exportJSONIcon;
  final Function()? onClickToJsonButton;
  final bool? showJsonDialogIcon;

  final Widget? exportTestDataIcon;
  final bool? showInputTestDataIcon;
  final Function()? onClickInputTestButton;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: topBarColor,
          border: Border(
            bottom: BorderSide(
              color: topBarBorderColor,
              width: topBarBorderWidth ?? 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: backButtonIcon ??
                  Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () {
                if (onClickBackButton != null) {
                  onClickBackButton!();
                }
              },
            ),
            Row(
              children: [
                /// Undo Icon button
                ValueListenableBuilder<bool>(
                  valueListenable: controller.canUndoNotifier,
                  builder: (context, canUndo, _) {
                    return IconButton(
                      icon: canUndo
                          ? (undoIcon?.enableIcon ?? Icon(Icons.undo_rounded))
                          : (undoIcon?.disableIcon ?? Icon(Icons.undo_rounded)),
                      onPressed: canUndo
                          ? () {
                              controller.undo();
                            }
                          : null,
                    );
                  },
                ),

                /// Redo Icon button
                ValueListenableBuilder<bool>(
                  valueListenable: controller.canRedoNotifier,
                  builder: (context, canRedo, _) {
                    return IconButton(
                      icon: canRedo
                          ? (redoIcon?.enableIcon ?? Icon(Icons.redo_rounded))
                          : (redoIcon?.disableIcon ?? Icon(Icons.redo_rounded)),
                      onPressed: canRedo
                          ? () {
                              controller.redo();
                            }
                          : null,
                    );
                  },
                ),

                if (showExtractSVGIcon ?? false)
                  IconButton(
                    onPressed: () {
                      if (onClickExtractSVG != null) {
                        List<Offset> offsets = [];

                        for (final content in controller.contents) {
                          offsets.addAll(content.offsets);
                        }

                        onClickExtractSVG!(offsets);
                      }
                    },
                    icon: exportSVGIcon ?? Icon(Icons.file_open_outlined),
                  ),

                if (showExtractPNGIcon ?? false)
                  IconButton(
                    onPressed: () {
                      if (onClickExtractPNG != null) {
                        onClickExtractPNG!();
                      }
                    },
                    icon: exportPNGIcon ?? Icon(Icons.image),
                  ),

                /// Button for JSON data debugging
                if (showJsonDialogIcon ?? false)
                  IconButton(
                    icon: exportJSONIcon ?? Icon(Icons.javascript),
                    onPressed: () {
                      if (onClickToJsonButton != null) {
                        onClickToJsonButton!();
                      }
                    },
                  ),

                if (showInputTestDataIcon ?? false)
                  IconButton(
                    icon: exportTestDataIcon ?? Icon(Icons.input),
                    onPressed: () {
                      if (onClickInputTestButton != null) {
                        onClickInputTestButton!();
                      }
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(topBarHeight ?? kToolbarHeight);
}
