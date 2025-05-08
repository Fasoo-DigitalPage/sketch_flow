import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:example/test_data.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
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

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<StatefulWidget> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final SketchController _sketchController = SketchController(sketchConfig: SketchConfig());
  final GlobalKey _repaintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: SketchTopBar(
        controller: _sketchController,
        showJsonDialogIcon: true,
        onClickToJsonButton: (json) => _showJsonDialog(json: json, context: context),
        showInputTestDataIcon: true,
        onClickInputTestButton: () => _sketchController.fromJson(contents: testData),
        onClickExtractPNG: () async {
          final image = await _sketchController.extractWithPNG(repaintKey: _repaintKey);
          if(context.mounted && image != null) {
            _showPNGDialog(image: image, context: context);
          }
        },
        onClickExtractSVG: (offsets) {
          final width = MediaQuery.of(context).size.width;
          final height = MediaQuery.of(context).size.height;
          final svgCode = _sketchController.extractWithSVG(width: width, height: height);

          _showSVGDialog(svgCode: svgCode, context: context);
        },
      ),
      body: SketchBoard(controller: _sketchController, repaintKey: _repaintKey),
      bottomNavigationBar: SketchBottomBar(controller: _sketchController),
    );
  }

  void _showJsonDialog({required Map<String, dynamic> json, required BuildContext context}) {
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

  void _showPNGDialog({required Uint8List image, required BuildContext context}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Sketch PNG"),
          content: SingleChildScrollView(
            child: Image.memory(image),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Close")
            )
          ],
        ),
    );
  }

  void _showSVGDialog({required String svgCode, required BuildContext context}) async {
    final directory = await getApplicationDocumentsDirectory();

    final file = File('${directory.path}/my_vector_file.svg');

    await file.writeAsString(svgCode);
    
    final params = ShareParams(
      text: 'Sketch SVG',
      files: [XFile(file.path)]
    );

    SharePlus.instance.share(params);
  }
}
