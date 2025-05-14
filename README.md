# Sketch Flow

**A powerful and flexible Flutter sketching plugin**  
Easily build drawing applications with elegant UI and comprehensive export features.



## 🚀 Features

### Easy-to-use SketchController  
  - Integrate sketching functionality with just a few lines using `SketchController`. Manage tools, undo/redo, and export effortlessly.

### Export Support
- `PNG`: For high-resolution image rendering
- `SVG`: For scalable vector graphics
- `JSON`: For precise stroke data and replaying paths

### Built-in Stylish UI
- Comes with ready-made top/bottom bars that offer a **clean, user-friendly design**.
- Use directly without extra customization for quick prototyping.

## 🖼️ Preview  
Test it live!: [Try it](https://sketch-flow-ashy.vercel.app/)  
View example code: [main.dart](https://github.com/JunYeong0314/sketch_flow/blob/main/example/lib/main.dart)

<p align="center">
<img width = "24%" src='https://github.com/user-attachments/assets/d9dcbc12-3d7b-4b3d-a047-34608f89452a' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/9f5f8d92-d02e-4768-ae37-bba670bae995' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/1416e050-d1fe-4a60-a733-5c392ecf2581' border='0'>
<img width = "24%" src='https://github.com/user-attachments/assets/2eb33ff3-3fa4-4c9a-871a-c81320369860' border='0'>
</p>

## 📒 Core components at a glance
| Components                              | Description                                                        |
| ---------------------------------- | --------------------------------------------------------- |
| `SketchController`                 | **[Required]** Key controller that manages drawing status and can be extracted in various formats such as JSON/SVG/PNG |
| `SketchBoard`                      | **[Required]** Main canvas widget to handle user input (draw/er, etc.)                         |
| `SketchTopBar` / `SketchBottomBar` | **[Optional]** Preferred UI components                             |


## ✍️ How to Use `sketch_flow`
### Install the package
- Add this to your `pubspec.yaml`:
```dart
dependencies:
  sketch_flow: ^latest_version
```

### `SketchController` and `SketchBoard`
- SketchController is a key class that manages drawing data.  
By passing this controller to SketchBoard, you can process user input, extract or reload the information you need.
```dart
final SketchController _controller = SketchController();
```
- And if you want to extract images with PNG or save the screen, you need to set GlobalKey on SketchBoard.  
This key is internally connected to RepaintBoundary and is used to capture images.
