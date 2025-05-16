import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_flow/sketch_controller.dart';
import 'package:sketch_flow/sketch_model.dart';

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
      controller.updateConfig(SketchConfig(toolType: SketchToolType.eraser));
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

      controller.updateConfig(SketchConfig(toolType: SketchToolType.eraser, eraserMode: EraserMode.area));

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

      controller.updateConfig(SketchConfig(toolType: SketchToolType.eraser, eraserMode: EraserMode.stroke));

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

      controller.updateConfig(SketchConfig(toolType: SketchToolType.eraser, eraserMode: EraserMode.area));

      // erasing
      controller.startNewLine(Offset(30, 30));
      controller.addPoint(Offset(40, 40));
      controller.addPoint(Offset(55, 55));
      controller.endLine();

      expect(controller.contents[1].offsets.length, 2);
    });
  });
}