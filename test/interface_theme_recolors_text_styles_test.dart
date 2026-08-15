import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('active light palette recolors base text styles', (tester) async {
    final preferences = BlenderInterfacePreferencesService();
    final themes = BlenderThemeService(selectedThemeId: 'blender-light');
    addTearDown(preferences.dispose);
    addTearDown(themes.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlenderInterfaceTheme(
          preferences: preferences,
          themeService: themes,
          child: Builder(
            builder: (context) => Column(
              children: <Widget>[
                Text('body', style: BlenderTheme.of(context).textTheme.body),
                Text(
                  'header',
                  style: BlenderTheme.of(context).textTheme.panelTitle,
                ),
                Text(
                  'caption',
                  style: BlenderTheme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('body')).style?.color,
      const BlenderColorScheme.light().foreground,
    );
    expect(
      tester.widget<Text>(find.text('header')).style?.color,
      const BlenderColorScheme.light().foreground,
    );
    expect(
      tester.widget<Text>(find.text('caption')).style?.color,
      const BlenderColorScheme.light().foregroundMuted,
    );
  });

  testWidgets('parent rebuild does not notify inherited theme during build', (
    tester,
  ) async {
    final preferences = BlenderInterfacePreferencesService();
    final rebuild = ValueNotifier<int>(0);
    addTearDown(preferences.dispose);
    addTearDown(rebuild.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder<int>(
          valueListenable: rebuild,
          builder: (context, value, child) => BlenderInterfaceTheme(
            preferences: preferences,
            child: Overlay(
              initialEntries: <OverlayEntry>[
                OverlayEntry(
                  builder: (context) => Text(
                    'frame-$value',
                    style: BlenderTheme.of(context).textTheme.body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    rebuild.value = 1;
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(Overlay), findsOneWidget);
  });

  testWidgets('button keeps its Actions registry stable across rebuilds', (
    tester,
  ) async {
    final rebuild = ValueNotifier<int>(0);
    var presses = 0;
    addTearDown(rebuild.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: ValueListenableBuilder<int>(
          valueListenable: rebuild,
          builder: (context, value, child) => Center(
            child: BlenderButton(
              key: const ValueKey<String>('stable-button'),
              label: 'Run $value',
              onPressed: () => presses++,
            ),
          ),
        ),
      ),
    );

    rebuild.value = 1;
    await tester.pump();

    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey<String>('stable-button')));
    expect(presses, 1);
  });
}
