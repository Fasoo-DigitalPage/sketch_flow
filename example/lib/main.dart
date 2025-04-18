import 'package:flutter/material.dart';
import 'package:sketch_flow/sketch_flow.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DemoPage(),
    );
  }
}

class DemoPage extends StatelessWidget {
  DemoPage({super.key});

  final SketchController _sketchController = SketchController(sketchConfig: SketchConfig());

  @override
  Widget build(BuildContext context) {
    return SketchBoard(
        controller: _sketchController,
        showJsonDialogIcon: true,
    );
  }
}
