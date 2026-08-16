import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('object picker filters and assigns a typed reference', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 360,
            child: BlenderObjectPicker<String>(
              value: selected,
              options: const <BlenderObjectPickerOption<String>>[
                BlenderObjectPickerOption<String>(
                  value: 'camera',
                  label: 'Camera',
                  icon: BlenderGlyph.camera,
                ),
                BlenderObjectPickerOption<String>(
                  value: 'cube',
                  label: 'Cube',
                  icon: BlenderGlyph.cube,
                  searchTerms: <String>['mesh'],
                ),
                BlenderObjectPickerOption<String>(
                  value: 'light',
                  label: 'Light',
                  icon: BlenderGlyph.light,
                ),
              ],
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    final field = find.byKey(
      const ValueKey<String>('blender-object-picker-field'),
    );
    await tester.tapAt(tester.getTopLeft(field) + const Offset(40, 10));
    await tester.pump();
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Cube'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);

    final search = tester.widget<BlenderTextField>(
      find.byKey(const ValueKey<String>('blender-object-picker-search')),
    );
    search.controller.text = 'mesh';
    await tester.pump();
    expect(find.text('Camera'), findsNothing);
    expect(find.text('Cube'), findsOneWidget);

    await tester.tap(find.text('Cube'));
    await tester.pump();
    expect(selected, 'cube');
  });

  testWidgets('assigned and empty references expose Blender trailing actions', (
    tester,
  ) async {
    String? selected = 'missing-id';
    var picks = 0;

    Future<void> pump() => tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 360,
            child: BlenderObjectPicker<String>(
              value: selected,
              options: const <BlenderObjectPickerOption<String>>[
                BlenderObjectPickerOption<String>(
                  value: 'cube',
                  label: 'Cube',
                  icon: BlenderGlyph.cube,
                ),
              ],
              unresolvedLabelBuilder: (value) => 'Missing: $value',
              onChanged: (value) => selected = value,
              onPick: () => picks++,
            ),
          ),
        ),
      ),
    );

    await pump();
    expect(find.text('Missing: missing-id'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('blender-object-picker-clear')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('blender-object-picker-pick')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('blender-object-picker-clear')),
    );
    await tester.pump();
    expect(selected, isNull);

    await pump();
    await tester.tap(
      find.byKey(const ValueKey<String>('blender-object-picker-pick')),
    );
    await tester.pump();
    expect(picks, 1);
    expect(
      find.byKey(const ValueKey<String>('blender-object-picker-search')),
      findsNothing,
    );
  });

  testWidgets('empty object catalogs still open an explicit filtered result', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 360,
            child: BlenderObjectPicker<String>(
              value: null,
              options: const <BlenderObjectPickerOption<String>>[],
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final field = find.byKey(
      const ValueKey<String>('blender-object-picker-field'),
    );
    await tester.tapAt(tester.getTopLeft(field) + const Offset(40, 10));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('blender-object-picker-search')),
      findsOneWidget,
    );
    expect(find.text('No results found'), findsOneWidget);
  });
}
