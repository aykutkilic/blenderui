import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dropdown fills bounded rows and sizes in scrolling headers', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: Column(
          children: <Widget>[
            SizedBox(
              width: 240,
              child: BlenderDropdown<String>(
                value: 'a',
                items: <BlenderMenuItem<String>>[
                  BlenderMenuItem(value: 'a', label: 'Bounded'),
                ],
                onChanged: null,
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  BlenderDropdown<String>(
                    value: 'a',
                    items: <BlenderMenuItem<String>>[
                      BlenderMenuItem(value: 'a', label: 'Header Snap'),
                    ],
                    onChanged: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Bounded'), findsOneWidget);
    expect(find.text('Header Snap'), findsOneWidget);
  });
}
