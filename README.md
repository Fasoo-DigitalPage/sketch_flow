# Sketch Flow
[English](https://github.com/JunYeong0314/sketch_flow/edit/main/README.md) / [한국어](https://github.com/JunYeong0314/sketch_flow/blob/main/README-KO.md)  
**A powerful and flexible Flutter sketching plugin**  
Easily build drawing applications with elegant UI and comprehensive export features.



## Features

#### Easy-to-use SketchController  
  - Integrate sketching functionality with just a few lines using `SketchController`. Manage tools, undo/redo, and export effortlessly.

#### Export Support
- `PNG`: For high-resolution image rendering
- `SVG`: For scalable vector graphics
- `JSON`: For precise stroke data and replaying paths

#### Built-in Stylish UI
- Comes with ready-made top/bottom bars that offer a **clean, user-friendly design**.
- Use directly without extra customization for quick prototyping.

## Preview  
Test it live!: [Try it](https://fasoo-digitalpage.github.io/sketch_flow/)  
View example code: [main.dart](https://github.com/fasoo-digitalpage/sketch_flow/blob/main/example/lib/main.dart)

<p align="center">

<img width = "24%" src='https://github.com/user-attachments/assets/92eff9fe-c1f0-435a-970a-b0bf78f24b34' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/22cbdbbd-86e8-47a7-9880-2d48bbdb0e0f' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/d455aa41-d42c-456f-9011-fdc03e279aa7' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/81e68979-80dc-4b7e-88b2-12fe60c66435' border='0'>
</p>

## Core components at a glance
| Components                              | Description                                                        |
| ---------------------------------- | --------------------------------------------------------- |
| `SketchController`                 | **(Required)** Key controller that manages drawing status and can be extracted in various formats such as JSON/SVG/PNG |
| `SketchBoard`                      | **(Required)** Main canvas widget to handle user input (draw/er, etc.)                         |
| `SketchTopBar` / `SketchBottomBar` | **(Optional)** Preferred UI components                             |

## Architecture

<p align="center">
<img width = "70%" src='https://github.com/user-attachments/assets/248da299-3e7b-4585-b7f0-f534daa731e4' border='0'>
</p>

## How to Use `sketch_flow`
#### Install the package

- Add this to your `pubspec.yaml`: [Check latest version](https://pub.dev/packages/sketch_flow/versions)
```dart
dependencies:
  sketch_flow: ^latest_version
```

#### `SketchController` and `SketchBoard`
- SketchController is a key class that manages drawing data.  
By passing this controller to SketchBoard, you can process user input, extract or reload the information you need.
```dart
final SketchController _controller = SketchController();
```

- And if you want to extract images with PNG or save the screen, you need to set GlobalKey on SketchBoard.  
This key is internally connected to RepaintBoundary and is used to capture images.
```dart
final GlobalKey _repaintKey = GlobalKey();
```

- After this definition, pass it along to `SketchBoard`:
```dart
SketchBoard(
  controller: _controller,
  repaintKey: _repaintKey,
)
```
#### (Optional) Use `SketchTopBar` and `SketchBottomBar`  
- It's easy to use, and you can customize it in your own style through a variety of parameters.
```dart
Scaffold(
  appBar: SketchTopBar(controller: _controller),
  body: SketchBoard(controller: _controller),
  bottomNavigationBar: SketchBottomBar(controller: _sketchController),
)
```
> 💡 Of course, you can freely configure the UI.  
> If you connect the Sketch Controller properly, you can design the UI any way you want without the top and bottom bars.

## Export & Import Drawings
#### JSON (Serialization / Deserialization)
- You can easily **serialize (export)** your sketch data to JSON and **deserialize (import)** it back using the controller:
```dart
final json = _controller.toJson(); // Serialization

_controller.fromJson(json: json); // Deserialization
```
#### PNG
- You can easily export your drawing as a PNG using `SketchController`.  
Customize the image resolution with the `pixelRatio` parameter:
```dart
final Uint8List? image = await _controller.extractPNG(
  repaintKey: _repaintKey,
  pixelRatio: 2.0, // Customize resolution
);
```
#### SVG
- Easily export your drawing as an SVG with `SketchController`.  
You can define the canvas width and height to match your needs.
```dart
final String svgCode = await _controller.extractSVG(
  width: 300.0, // Define canvas width
  height: 400.0, // Define canvas height
);
```

## Tools Overview
| Tool Type   | Description                                                                                      |
| ----------- | ------------------------------------------------------------------------------------------------ |
| **Move**    | Enables panning and zooming of the canvas without affecting the drawings.                        |
| **Pencil**  | Draws a continuous line based on user input. Configurable stroke thickness, color, and opacity.  |
| **Brush**   | Simulates a brush-like stroke with smooth edges. Supports color and thickness customization.     |
| **Highlighter**  | 	Draws semi-transparent strokes resembling a highlighter. Comes with predefined low opacity and medium thickness to simulate real highlighter effects.  |
| **Palette** | Allows users to select colors for drawing tools. |
| **Eraser**  | Erases drawings either by stroke or by area.    |
| **Line**  |   Draws a straight line between the first and last touch point. Line color and thickness are customizable.  |
| **Rectangle**  |  Draws a rectangle defined by the first and last touch points.   |
| **Circle**  | 	Draws a circle or ellipse bounded by the first and last touch points. |




