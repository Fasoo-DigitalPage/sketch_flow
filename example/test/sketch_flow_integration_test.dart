import 'package:example/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SketchBottomBar interaction test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    final penTool = find.byIcon(Icons.mode_edit_outline);
    expect(penTool, findsOneWidget);

    await tester.tap(penTool);
    await tester.pumpAndSettle();
  });
}