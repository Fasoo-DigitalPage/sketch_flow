import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_contents.dart';
import 'package:sketch_flow/sketch_flow.dart';

class SketchTopBar extends StatelessWidget implements PreferredSizeWidget {
  /// Top bar widget
  ///
  /// [topBarHeight] The height of the top bar
  ///
  /// [topBarColor] The background color of the top bar
  ///
  /// [topBarBorderColor] The border color of the top bar
  ///
  /// [topBarBorderWidth] he border width of the top bar
  ///
  /// [backButtonIcon] The icon for the back button
  ///
  /// [onClickBackButton] Callback function invoked when the back button
  ///
  /// [activeUndoIcon] The icon displayed when the undo action is active.
  ///
  /// [inActiveUndoIcon] The icon displayed when the undo action is inactive.
  ///
  /// [activeRedoIcon] The icon displayed when the redo action is active.
  ///
  /// [inActiveRedoIcon] The icon displayed when the redo action is inactive.
  ///
  /// [showJsonDialogIcon] JSON dialog view settings (default false)
  ///
  /// [onClickToJsonButton] Callback function invoked when the json button
  ///
  /// [showInputTestDataIcon] Input Test Data view settings (default false)
  ///
  /// [onClickInputTestButton] Callback function invoked when test input button
  const SketchTopBar({
    super.key,
    required this.controller,
    this.topBarHeight,
    this.topBarColor,
    this.topBarBorderColor,
    this.topBarBorderWidth,
    this.backButtonIcon,
    this.onClickBackButton,
    this.activeUndoIcon,
    this.inActiveUndoIcon,
    this.activeRedoIcon,
    this.inActiveRedoIcon,
    this.showJsonDialogIcon,
    this.onClickToJsonButton,
    this.showInputTestDataIcon,
    this.onClickInputTestButton,
    this.onClickExtractPNG,
    this.onClickExtractSVG
  });
  final SketchController controller;

  final double? topBarHeight;
  final Color? topBarColor;
  final Color? topBarBorderColor;
  final double? topBarBorderWidth;

  final Widget? backButtonIcon;
  final Function()? onClickBackButton;

  final Widget? activeUndoIcon;
  final Widget? inActiveUndoIcon;

  final Widget? activeRedoIcon;
  final Widget? inActiveRedoIcon;

  final bool? showJsonDialogIcon;
  final Function(Map<String, dynamic>)? onClickToJsonButton;

  final bool? showInputTestDataIcon;
  final Function()? onClickInputTestButton;

  final Function()? onClickExtractPNG;

  final Function(List<Offset>)? onClickExtractSVG;

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
                ),
                Row(
                  children: [
                    /// Undo Icon button
                    ValueListenableBuilder<bool>(
                        valueListenable: controller.canUndoNotifier,
                        builder: (context, canUndo, _) {
                          return IconButton(
                              icon: canUndo
                                  ? (activeUndoIcon ?? Icon(Icons.undo_rounded))
                                  : (inActiveUndoIcon ?? Icon(Icons.undo_rounded)),
                              onPressed: canUndo ? () {
                                controller.undo();
                              } : null
                          );
                        }
                    ),

                    /// Redo Icon button
                    ValueListenableBuilder<bool>(
                        valueListenable: controller.canRedoNotifier,
                        builder: (context, canRedo, _) {
                          return IconButton(
                              icon: canRedo
                                  ? (activeRedoIcon ?? Icon(Icons.redo_rounded))
                                  : (inActiveRedoIcon ?? Icon(Icons.redo_rounded)),
                              onPressed: canRedo ? () {
                                controller.redo();
                              } : null
                          );
                        }
                    ),

                    IconButton(
                        onPressed: () {
                          if(onClickExtractSVG != null) {
                            List<Offset> offsets = [];

                            for (final content in controller.contents) {
                              offsets.addAll(content.points);
                            }

                            onClickExtractSVG!(offsets);
                          }
                        },
                        icon: Icon(Icons.file_open_outlined)
                    ),

                    IconButton(
                        onPressed: () {
                          if(onClickExtractPNG != null) {
                            onClickExtractPNG!();
                          }
                        },
                        icon: Icon(Icons.image)
                    ),

                    /// Button for JSON data debugging
                    if(showJsonDialogIcon ?? false)
                      IconButton(
                        icon: Icon(Icons.javascript),
                        onPressed: () {
                          if(onClickToJsonButton != null) {
                            onClickToJsonButton!(controller.toJson());
                          }
                        },
                      ),

                    if(showInputTestDataIcon ?? false)
                      IconButton(
                          icon: Icon(Icons.input),
                          onPressed: ()  {
                            if (onClickInputTestButton != null) {
                              onClickInputTestButton!();
                            }
                          },
                      ),
                  ],
                ),

              ],
            )
        )
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(topBarHeight ?? kToolbarHeight);
}