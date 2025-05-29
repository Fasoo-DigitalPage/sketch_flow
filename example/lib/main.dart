import 'dart:convert';
import 'dart:typed_data';
import 'package:example/test_data.dart';
import 'package:flutter/material.dart';
import 'package:jovial_svg/jovial_svg.dart';
import 'package:sketch_flow/sketch_controller.dart';
import 'package:sketch_flow/sketch_model.dart';
import 'package:sketch_flow/sketch_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: DemoPage());
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<StatefulWidget> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final SketchController _sketchController = SketchController(
    sketchConfig: SketchConfig(showEraserEffect: true),
  );
  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SketchTopBar(
        controller: _sketchController,
        showJsonDialogIcon: true,
        exportSVGIcon: Image.asset('assets/images/svg.png'),
        exportPNGIcon: Image.asset('assets/images/png.png'),
        exportJSONIcon: Image.asset('assets/images/json.png'),
        exportTestDataIcon: Image.asset('assets/images/import.png'),
        onClickToJsonButton: () {
          final json = _sketchController.toJson();
          _showJsonDialog(json: json);
        },
        showInputTestDataIcon: true,
        onClickInputTestButton: () {
          _sketchController.fromJson(json: testData);
        },
        onClickExtractPNG: () async {
          final image = await _sketchController.extractPNG(
            repaintKey: _repaintKey,
          );
          if (context.mounted && image != null) {
            _showPNGDialog(image: image);
          }
        },
        onClickExtractSVG: (offsets) {
          final width = MediaQuery.of(context).size.width;
          final height = MediaQuery.of(context).size.height;
          final svgCode = _sketchController.extractSVG(
            width: width,
            height: height,
          );
          final scalableImage = ScalableImage.fromSvgString(svgCode);

          _showSVGDialog(si: scalableImage);
        },
      ),
      body: Center(
        child: SketchBoard(
          controller: _sketchController,
          repaintKey: _repaintKey,
        ),
      ),
      bottomNavigationBar: SketchBottomBar(controller: _sketchController),
    );
  }

  void _showJsonDialog({required List<Map<String, dynamic>> json}) {
    final prettyJson = const JsonEncoder.withIndent('  ').convert(json);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  void _showPNGDialog({required Uint8List image}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Sketch PNG"),
            content: SingleChildScrollView(child: Image.memory(image)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }

  void _showSVGDialog({required ScalableImage si}) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Sketch SVG"),
            content: SingleChildScrollView(child: ScalableImageWidget(si: si)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close"),
              ),
            ],
          ),
    );
  }
}
