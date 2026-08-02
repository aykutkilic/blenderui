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
}
