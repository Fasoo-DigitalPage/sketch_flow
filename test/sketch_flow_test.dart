import 'package:flutter_test/flutter_test.dart';
import 'package:sketch_flow/sketch_view_model.dart';
import 'package:sketch_flow/sketch_model.dart';

void main() {
  group('SketchViewModel', () {
    late SketchViewModel viewModel;
    
    setUp(() {
      viewModel = SketchViewModel();
    });
    
    test('Initial status screen', () {
      expect(viewModel.contents, isEmpty);
      expect(viewModel.currentSketchConfig.toolType, SketchToolType.pencil);
      expect(viewModel.canUndoNotifier.value, isFalse);
      expect(viewModel.canRedoNotifier.value, isFalse);
    });
    
    test('startNewLine to start a new line', () {
      final offset = Offset(10, 10);
      viewModel.startNewLine(offset);
      viewModel.addPoint(Offset(11, 11));
      viewModel.endLine();

      expect(viewModel.contents.length, 1);
      expect(viewModel.contents.first.offsets.first, offset);
    });
    
    test('Delete all content with clear', () {
      viewModel.startNewLine(Offset(10, 10));
      viewModel.addPoint(Offset(20, 20));
      viewModel.endLine();

      viewModel.clear();

      expect(viewModel.contents, isEmpty);
      expect(viewModel.canUndoNotifier.value, isTrue);
    });
    
    test('Undo functional test', () {
      viewModel.startNewLine(Offset(10, 10));
      viewModel.addPoint(Offset(20, 20));
      viewModel.endLine();

      viewModel.undo();

      expect(viewModel.contents, isEmpty);
      expect(viewModel.canRedoNotifier.value, isTrue);
    });
    
    test('Redo functional test', () {
      viewModel.startNewLine(Offset(10, 10));
      viewModel.addPoint(Offset(20, 20));
      viewModel.endLine();
      
      viewModel.undo();
      viewModel.redo();
      
      expect(viewModel.contents.length, 1);
      expect(viewModel.canUndoNotifier.value, isTrue);
      expect(viewModel.canRedoNotifier.value, isFalse);
    });
    
    test('ValueNotifier is reflected when toolType is changed', () {
      viewModel.updateConfig(SketchConfig(toolType: SketchToolType.eraser));
      expect(viewModel.toolTypeNotifier.value, SketchToolType.eraser);
    });

    test('Verify deduplication on consecutive input of the same offset', () {
      final offset = Offset(10, 10);
      viewModel.startNewLine(offset);
      viewModel.addPoint(offset);
      viewModel.endLine();

      final content = viewModel.contents.first;
      expect(content.offsets.length, 1);
    });

    test('Check if there are any deleted content', () {
      // drawing
      viewModel.startNewLine(Offset(10, 10));
      viewModel.addPoint(Offset(20, 20));
      viewModel.addPoint(Offset(30, 30));
      viewModel.endLine();

      viewModel.updateConfig(SketchConfig(toolType: SketchToolType.eraser, eraserMode: EraserMode.area));

      // clear
      viewModel.startNewLine(Offset(15, 15));
      viewModel.addPoint(Offset(20, 20));
      viewModel.addPoint(Offset(25, 25));

      expect(viewModel.hasErasedContent, isTrue);
    });
    
    test('Verification of stroke erasing motion', () {
      // drawing
      viewModel.startNewLine(Offset(10, 10));
      viewModel.addPoint(Offset(20, 20));
      viewModel.addPoint(Offset(30, 30));
      viewModel.endLine();

      viewModel.updateConfig(SketchConfig(toolType: SketchToolType.eraser, eraserMode: EraserMode.stroke));

      // erasing
      viewModel.startNewLine(Offset(15, 15));
      viewModel.addPoint(Offset(20, 20));
      viewModel.addPoint(Offset(30, 30));
      viewModel.endLine();

      expect(viewModel.contents, isEmpty);
    });

    test('Verification of JSON converter', () {
      // drawing
      viewModel.startNewLine(Offset(10, 10));
      viewModel.addPoint(Offset(20, 20));
      viewModel.addPoint(Offset(30, 30));
      viewModel.endLine();

      // JSON serialization
      final List<Map<String, dynamic>> json = viewModel.toJson();

      // clear
      viewModel.clear();

      // Json deserialization
      viewModel.fromJson(json: json);

      expect(viewModel.contents, isNotEmpty);
    });

    test('Verifying that only erased coordinates remain', () {
      // drawing
      viewModel.startNewLine(Offset(10, 10));
      viewModel.addPoint(Offset(20, 20));
      viewModel.addPoint(Offset(30, 30));
      viewModel.addPoint(Offset(40, 40));
      viewModel.endLine();

      viewModel.updateConfig(SketchConfig(toolType: SketchToolType.eraser, eraserMode: EraserMode.area));

      // erasing
      viewModel.startNewLine(Offset(30, 30));
      viewModel.addPoint(Offset(40, 40));
      viewModel.addPoint(Offset(55, 55));
      viewModel.endLine();

      expect(viewModel.contents[1].offsets.length, 2);
    });
  });
}