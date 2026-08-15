import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('application menu dismisses before opening a selected dialog', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlenderApp(
        home: Builder(
          builder: (context) => BlenderApplicationMenuBar<String>(
            menus: <BlenderApplicationMenu<String>>[
              BlenderApplicationMenu<String>(
                label: 'File',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'new', label: 'New Package'),
                ],
                onSelected: (_) {
                  showBlenderDialog<void>(
                    context: context,
                    builder: (_) =>
                        const BlenderDialog(title: 'New Package Dialog'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(
      find.ancestor(
        of: find.text('File'),
        matching: find.byType(BlenderMenuButton<String>),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('New Package'));
    await tester.pumpAndSettle();

    expect(find.text('New Package'), findsNothing);
    expect(find.text('New Package Dialog'), findsOneWidget);
  });
}
