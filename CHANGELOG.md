[1.2.1]
* Added `exportCroppedPNG` method to `SketchController`. This allows exporting a high-resolution PNG image that is automatically cropped to fit the bounds of both the drawn sketches and the optional `overlayWidget`.
* Added an `toolConfigOffset` parameter to `SketchBottomBar`. This provides a new way to adjust the tool's position, allowing for more precise control and custom UI interactions (e.g., displaying the tool config menu at a specific location).

[1.2.0]
This release introduces comprehensive UI customization options for `SketchBottomBar` and improves responsive layouts for tablet devices.

### Added

* **Full Bottom Bar Customization**: Added an optional `customBuilder` parameter to `SketchBottomBar`. Developers can now provide a `SketchBarBuilder` function to build a completely custom list of tool icons, while still accessing internal state (`controller`, `selectedToolType`) and actions (`onToolTap`).
* **Custom Eraser Config UI**: Added an optional `customEraserConfig` parameter. This allows providing an `EraserConfigBuilder` function to build a custom UI for the eraser settings overlay (e.g., using `ToggleButtons` instead of `RadioListTile`).
* **Custom Thickness Icon UI**: Added `enableIconStrokeThicknessList` and `disableIconStrokeThicknessList` to `SketchToolConfig`. Developers can now pass a `List<Widget>` to override the default thickness icons for any specific drawing tool.
* Added `assert`s to `SketchToolConfig` to throw an error if the length of custom icon lists does not match the `strokeThicknessList`.

### Changed

* **Responsive Overlays (Tablet Support)**: The default tool configuration overlays (for thickness/opacity and color palette) now use `LayoutBuilder`. They will automatically display as a `Row` on wide screens (like tablets) and a `Column` on narrow screens (like phones).
* **Refined Slider UI**: The default opacity and color picker sliders have been redesigned with a custom `GradientTrackShape` (featuring a 2-row checkerboard background and rounded ends) and a custom `ColorSliderThumbShape` (white border with selected color interior).

[1.1.0]
* **FEAT**: Add `isPadDevice` option to separate stylus and touch inputs.
* **FEAT**: Add `multiTouchPanZoomEnabled` to allow zooming/panning while drawing.

[1.0.0+2]
* license update

[1.0.0+1]
* docs update

[1.0.0]
* re-export core APIs to simplify imports

[0.1.6+3]
* Add Area/Stroke Eraser design settings
* Add selected strokeThickness icon color settings.

[0.1.6+2]
* Add SketchTopBar theme settings

[0.1.6+1]
* Apply to set png, svg icon options

[0.1.6]
* Refactor SketchController of updateConfig

[0.1.5]
* Fix SketchBoard overlayWidget bug

[0.1.4]
* Add SketchBoard width/height size settings

[0.1.3]
* Fix SketchTopBar back button bug 
* Update README

[0.1.2]
* Structural Change
* Repackaging

[0.1.1]
* Modify annotations, optimize import statements

[0.1.0]
* Initial version