import 'dart:convert';

import 'package:example/test_data.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SketchTopBar(
          controller: _sketchController,
          showJsonDialogIcon: true,
          onClickToJsonButton: (json) => _showDialog(json: json, context: context),
          showInputTestDataIcon: true,
          onClickInputTestButton: () => _sketchController.fromJson(contents: testData),
      ),
      body: SketchBoard(controller: _sketchController,),
      bottomNavigationBar: SketchBottomBar(controller: _sketchController),
    );
  }

  void _showDialog({required Map<String, dynamic> json, required BuildContext context}) {
    final prettyJson = const JsonEncoder.withIndent('  ').convert(_sketchController.toJson());

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Sketch JSON"),
          content: SingleChildScrollView(
            child: SelectableText(
              prettyJson,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close")
            )
          ],
        )
    );
  }
}
