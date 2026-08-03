import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('toggle labels condense inside narrow editor regions', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlenderTheme(
          child: const SizedBox(
            width: 120,
            child: BlenderToggle(
              value: true,
              onChanged: null,
              label: 'A deliberately long contextual option',
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('A deliberately long contextual option'), findsOneWidget);
  });
}
