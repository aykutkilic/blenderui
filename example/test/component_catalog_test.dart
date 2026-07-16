import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_example/demo/component_catalog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('component catalog browses dedicated tutorial pages', (
    tester,
  ) async {
    await tester.pumpWidget(const BlenderApp(home: ComponentCatalogPage()));
    await tester.pumpAndSettle();

    expect(find.text('BlenderUI Components'), findsOneWidget);
    expect(find.text('Live example'), findsOneWidget);
    expect(find.text('Code example'), findsOneWidget);
    expect(find.text('Button'), findsWidgets);

    await tester.tap(find.text('Apply').first);
    await tester.pump();
    expect(find.text('Event: Apply pressed'), findsOneWidget);

    await tester.tap(find.text('Tree').first);
    await tester.pumpAndSettle();

    expect(find.text('Tree'), findsWidgets);
    expect(find.textContaining('Hierarchical rows'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('catalog-code-example')),
      findsOneWidget,
    );
  });

  testWidgets('multi-column dropdown opens and selects an item', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: ComponentCatalogPage(initialComponent: 'multi-column-menu'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Page Editor').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    final level = find.byKey(
      const ValueKey<String>('catalog-multicolumn-menu-item-level'),
    );
    expect(level, findsOneWidget);
    await tester.tap(level);
    await tester.pumpAndSettle();

    expect(find.text('Event: Editor: level'), findsOneWidget);
  });

  testWidgets('properties example demonstrates nested enabled range sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: ComponentCatalogPage(initialComponent: 'properties-editor'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sampling'), findsOneWidget);
    expect(find.text('Viewport'), findsOneWidget);
    expect(find.text('Render'), findsOneWidget);
    expect(find.text('Shadows'), findsOneWidget);
    expect(find.text('Volume Shadows'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('blender-number-field-surface')),
      findsWidgets,
    );

    final shadowsGroup = find.ancestor(
      of: find.text('Shadows'),
      matching: find.byType(BlenderPanel),
    );
    await tester.tap(
      find
          .descendant(of: shadowsGroup, matching: find.byType(BlenderCheckbox))
          .first,
    );
    await tester.pump();
    expect(find.text('Event: Shadows: disabled'), findsOneWidget);
  });
}
