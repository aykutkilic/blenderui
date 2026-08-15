import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('checkbox labels activate their controls', (tester) async {
    var checked = false;
    await tester.pumpWidget(
      MaterialApp(
        home: BlenderTheme(
          child: BlenderCheckbox(
            value: checked,
            onChanged: (value) => checked = value,
            label: 'Show Solution',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Solution'));
    expect(checked, isTrue);
  });

  testWidgets('radio labels activate their controls', (tester) async {
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: BlenderTheme(
          child: BlenderRadio<String>(
            value: 'object',
            groupValue: 'edit',
            onChanged: (value) => selected = value,
            label: 'Object mode',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Object mode'));
    expect(selected, 'object');
  });

  testWidgets('toggle labels condense inside narrow editor regions', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
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
