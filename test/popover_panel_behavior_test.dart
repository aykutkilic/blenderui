import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('popover defaults align the panel center with its trigger', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        Center(
          child: BlenderPopover(
            child: const BlenderButton(
              key: ValueKey<String>('popover-trigger'),
              label: 'Open',
            ),
            popover: (context, close) =>
                BlenderPopoverPanel.settings('Panel', const <Widget>[
                  Text('Setting'),
                ]),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('popover-trigger')));
    await tester.pumpAndSettle();

    expect(
      tester
          .getCenter(
            find.byKey(const ValueKey<String>('blender-popover-panel-surface')),
          )
          .dx,
      closeTo(
        tester
            .getCenter(find.byKey(const ValueKey<String>('popover-trigger')))
            .dx,
        0.01,
      ),
    );
  });

  testWidgets('settings panels fit short content instead of their maximum', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        BlenderPopoverPanel.settings('Display', <Widget>[
          const Text('Short setting'),
        ], maxHeight: 400),
      ),
    );

    expect(
      tester
          .getSize(
            find.byKey(const ValueKey<String>('blender-popover-panel-surface')),
          )
          .height,
      lessThan(100),
    );
    final surface = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey<String>('blender-popover-panel-surface')),
    );
    expect((surface.decoration as BoxDecoration).border, isNull);
  });

  testWidgets('an open popover refreshes controls from its listenable state', (
    tester,
  ) async {
    final enabled = ValueNotifier<bool>(false);
    addTearDown(enabled.dispose);
    await tester.pumpWidget(
      _harness(
        BlenderPopover(
          refreshListenable: enabled,
          child: const BlenderButton(label: 'Options'),
          popover: (context, close) =>
              BlenderPopoverPanel.settings('Options', <Widget>[
                BlenderCheckbox(
                  value: enabled.value,
                  label: 'Enabled',
                  onChanged: (value) => enabled.value = value,
                ),
              ]),
        ),
      ),
    );

    await tester.tap(find.text('Options'));
    await tester.pumpAndSettle();
    enabled.value = true;
    await tester.pumpAndSettle();

    expect(enabled.value, isTrue);

    final checkbox = tester.widget<BlenderCheckbox>(
      find.ancestor(
        of: find.text('Enabled'),
        matching: find.byType(BlenderCheckbox),
      ),
    );
    expect(checkbox.value, isTrue);
  });

  testWidgets('long settings panels expose a downward overflow cue', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        BlenderPopoverPanel.settings(
          'Snapping',
          List<Widget>.generate(12, (index) => Text('Setting $index')),
          maxHeight: 120,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.chevronDown,
      ),
      findsOneWidget,
    );
  });
}

Widget _harness(Widget child) => BlenderApp(
  home: Directionality(
    textDirection: TextDirection.ltr,
    child: BlenderTheme(child: child),
  ),
);
