import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_flow/sketch_flow.dart';

Future<void> pumpSketchBoard(
    WidgetTester tester, {
      required SketchController controller,
      bool isPadDevice = false,
      bool multiTouchPanZoomEnabled = true,
      SketchToolType toolType = SketchToolType.pencil,
    }) async {
  controller.updateConfig(toolType: toolType);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SketchBoard(
          controller: controller,
          boardWidthSize: 800,
          boardHeightSize: 600,
          isPadDevice: isPadDevice,
          multiTouchPanZoomEnabled: multiTouchPanZoomEnabled,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

InteractiveViewer findActiveViewer(WidgetTester tester) {
  return tester.widget<InteractiveViewer>(find.byType(InteractiveViewer));
}

void main() {
  group('SketchController', () {
    late SketchController controller;

    setUp(() {
      controller = SketchController();
    });

    test('Initial status screen', () {
      expect(controller.contents, isEmpty);
      expect(controller.currentSketchConfig.toolType, SketchToolType.pencil);
      expect(controller.canUndoNotifier.value, isFalse);
      expect(controller.canRedoNotifier.value, isFalse);
    });

    test('startNewLine to start a new line', () {
      final offset = Offset(10, 10);
      controller.startNewLine(offset);
      controller.addPoint(Offset(11, 11));
      controller.endLine();

      expect(controller.contents.length, 1);
      expect(controller.contents.first.offsets.first, offset);
    });

    test('Delete all content with clear', () {
      controller.startNewLine(Offset(10, 10));
      controller.addPoint(Offset(20, 20));
      controller.endLine();

      controller.clear();

      expect(controller.contents, isEmpty);
      expect(controller.canUndoNotifier.value, isTrue);
    });

    test('Undo functional test', () {
      controller.startNewLine(Offset(10, 10));
      controller.addPoint(Offset(20, 20));
      controller.endLine();

      controller.undo();

      expect(controller.contents, isEmpty);
      expect(controller.canRedoNotifier.value, isTrue);
    });

    test('Redo functional test', () {
      controller.startNewLine(Offset(10, 10));
      controller.addPoint(Offset(20, 20));
      controller.endLine();

      controller.undo();
      controller.redo();

      expect(controller.contents.length, 1);
      expect(controller.canUndoNotifier.value, isTrue);
      expect(controller.canRedoNotifier.value, isFalse);
    });

    test('ValueNotifier is reflected when toolType is changed', () {
      controller.updateConfig(toolType: SketchToolType.eraser);
      expect(controller.toolTypeNotifier.value, SketchToolType.eraser);
    });

    test('Verify deduplication on consecutive input of the same offset', () {
      final offset = Offset(10, 10);
      controller.startNewLine(offset);
      controller.addPoint(offset);
      controller.endLine();

      final content = controller.contents.first;
      expect(content.offsets.length, 1);
    });

    test('Check if there are any deleted content', () {
      // drawing
      controller.startNewLine(Offset(10, 10));
      controller.addPoint(Offset(20, 20));
      controller.addPoint(Offset(30, 30));
      controller.endLine();

      controller.updateConfig(
        toolType: SketchToolType.eraser,
        eraserMode: EraserMode.area,
      );

      // clear
      controller.startNewLine(Offset(15, 15));
      controller.addPoint(Offset(20, 20));
      controller.addPoint(Offset(25, 25));

      expect(controller.hasErasedContent, isTrue);
    });

    test('Verification of stroke erasing motion', () {
      // drawing
      controller.startNewLine(Offset(10, 10));
      controller.addPoint(Offset(20, 20));
      controller.addPoint(Offset(30, 30));
      controller.endLine();

      controller.updateConfig(
        toolType: SketchToolType.eraser,
        eraserMode: EraserMode.stroke,
      );

      // erasing
      controller.startNewLine(Offset(15, 15));
      controller.addPoint(Offset(20, 20));
      controller.addPoint(Offset(30, 30));
      controller.endLine();

      expect(controller.contents, isEmpty);
    });

    test('Verification of JSON converter', () {
      // drawing
      controller.startNewLine(Offset(10, 10));
      controller.addPoint(Offset(20, 20));
      controller.addPoint(Offset(30, 30));
      controller.endLine();

      // JSON serialization
      final List<Map<String, dynamic>> json = controller.toJson();

      // clear
      controller.clear();

      // Json deserialization
      controller.fromJson(json: json);

      expect(controller.contents, isNotEmpty);
    });

    test('Verifying that only erased coordinates remain', () {
      // drawing
      controller.startNewLine(Offset(10, 10));
      controller.addPoint(Offset(20, 20));
      controller.addPoint(Offset(30, 30));
      controller.addPoint(Offset(40, 40));
      controller.endLine();

      controller.updateConfig(
        toolType: SketchToolType.eraser,
        eraserMode: EraserMode.area,
      );

      // erasing
      controller.startNewLine(Offset(30, 30));
      controller.addPoint(Offset(40, 40));
      controller.addPoint(Offset(55, 55));
      controller.endLine();

      expect(controller.contents[1].offsets.length, 2);
    });
  });

  group('SketchBoard Interaction', () {
    late SketchController controller;

    setUp(() {
      controller = SketchController();
    });

    testWidgets('Pad Mode (isPadDevice: true): Stylus draws, single-touch pans', (tester) async {
          await pumpSketchBoard(tester, controller: controller, isPadDevice: true);

          TestGesture stylusGesture = await tester.startGesture(
            Offset(100, 100),
            kind: PointerDeviceKind.stylus,
          );
          await stylusGesture.moveTo(Offset(150, 150));
          await stylusGesture.up();
          await tester.pumpAndSettle();

          expect(controller.contents.length, 1);

          controller.clear();
          expect(controller.contents.isEmpty, isTrue);

          TestGesture touchGesture = await tester.startGesture(
            Offset(100, 100),
            kind: PointerDeviceKind.touch,
          );
          await tester.pumpAndSettle();

          var viewer = findActiveViewer(tester);
          expect(viewer.panEnabled, isTrue);
          expect(viewer.scaleEnabled, isFalse);

          await touchGesture.moveTo(Offset(150, 150));
          await touchGesture.up();
          await tester.pumpAndSettle();

          expect(controller.contents.isEmpty, isTrue);
        });

    testWidgets('Phone Mode (isPadDevice: false): Single-touch draws',
            (tester) async {
          await pumpSketchBoard(tester, controller: controller, isPadDevice: false);

          TestGesture touchGesture = await tester.startGesture(
            Offset(100, 100),
            kind: PointerDeviceKind.touch,
          );
          await tester.pump();

          var viewer = findActiveViewer(tester);
          expect(viewer.panEnabled, isFalse);
          expect(viewer.scaleEnabled, isFalse);

          await touchGesture.moveTo(Offset(150, 150));
          await touchGesture.up();
          await tester.pumpAndSettle();

          expect(controller.contents.length, 1);
        });

    testWidgets('Move Mode (isMoveArea: true): Single-touch pans, no drawing',
            (tester) async {
          await pumpSketchBoard(
            tester,
            controller: controller,
            isPadDevice: false,
            toolType: SketchToolType.move,
          );

          var viewer = findActiveViewer(tester);
          expect(viewer.panEnabled, isTrue);
          expect(viewer.scaleEnabled, isTrue);

          TestGesture touchGesture = await tester.startGesture(Offset(100, 100));
          await touchGesture.moveTo(Offset(150, 150));
          await touchGesture.up();
          await tester.pumpAndSettle();

          expect(controller.contents.isEmpty, isTrue);
        });
  });
}
