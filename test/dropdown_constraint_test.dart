import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/gestures.dart';
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

  testWidgets('compact dropdown retains selection, icon, and open state', (
    tester,
  ) async {
    var value = 'Layout';
    await tester.pumpWidget(
      BlenderApp(
        home: StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 140,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('mode-dropdown'),
              value: value,
              compact: true,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'Layout',
                  label: 'Layout',
                  icon: BlenderIcon(BlenderGlyph.grid, size: 16),
                ),
                BlenderMenuItem<String>(
                  value: 'Text Edit',
                  label: 'Text Edit',
                  icon: BlenderIcon(BlenderGlyph.text, size: 16),
                ),
              ],
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );

    final dropdown = find.byKey(const ValueKey<String>('mode-dropdown'));
    expect(
      find.descendant(of: dropdown, matching: find.text('Layout')),
      findsOneWidget,
    );
    var button = tester.widget<BlenderButton>(
      find.descendant(of: dropdown, matching: find.byType(BlenderButton)),
    );
    expect(button.variant, BlenderButtonVariant.toolbar);
    expect(button.selected, isFalse);
    expect(
      tester
          .widget<BlenderIcon>(
            find
                .descendant(of: dropdown, matching: find.byType(BlenderIcon))
                .first,
          )
          .glyph,
      BlenderGlyph.grid,
    );

    await tester.tap(
      find.descendant(of: dropdown, matching: find.byType(BlenderButton)),
    );
    await tester.pump();
    button = tester.widget<BlenderButton>(
      find.descendant(of: dropdown, matching: find.byType(BlenderButton)),
    );
    expect(button.selected, isTrue);

    await tester.tap(find.text('Text Edit').last);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: dropdown, matching: find.text('Text Edit')),
      findsOneWidget,
    );
    expect(
      tester
          .widget<BlenderIcon>(
            find
                .descendant(of: dropdown, matching: find.byType(BlenderIcon))
                .first,
          )
          .glyph,
      BlenderGlyph.text,
    );
  });

  testWidgets('icon-only dropdown hides the selected label explicitly', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: SizedBox(
          width: 42,
          child: BlenderDropdown<String>(
            value: 'Layout',
            compact: true,
            iconOnly: true,
            items: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Layout',
                label: 'Layout',
                icon: BlenderIcon(BlenderGlyph.grid, size: 16),
              ),
            ],
            onChanged: null,
          ),
        ),
      ),
    );

    expect(find.text('Layout'), findsNothing);
    expect(find.byType(BlenderIcon), findsNWidgets(2));
  });

  testWidgets('compact dropdown centers with neighboring header buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 360,
            child: BlenderToolbar(
              height: 40,
              scrollable: false,
              children: <Widget>[
                SizedBox(
                  width: 140,
                  child: BlenderDropdown<String>(
                    value: 'Layout',
                    compact: true,
                    items: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Layout', label: 'Layout'),
                    ],
                    onChanged: null,
                  ),
                ),
                BlenderButton(label: 'View', onPressed: null),
              ],
            ),
          ),
        ),
      ),
    );

    final buttons = find.byType(BlenderButton);
    expect(buttons, findsNWidgets(2));
    expect(
      tester.getCenter(buttons.first).dy,
      closeTo(tester.getCenter(buttons.last).dy, 0.01),
    );
  });

  testWidgets('toolbar pulldowns are flat and switch to hovered siblings', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            child: BlenderToolbar(
              scrollable: false,
              children: <Widget>[
                BlenderMenuButton<String>(
                  label: 'View',
                  variant: BlenderButtonVariant.menuTrigger,
                  items: <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'view-action',
                      label: 'View Action',
                    ),
                  ],
                ),
                BlenderMenuButton<String>(
                  label: 'Select',
                  variant: BlenderButtonVariant.menuTrigger,
                  items: <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'select-action',
                      label: 'Select Action',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final viewMenu = find.byType(BlenderMenuButton<String>).first;
    final selectMenu = find.byType(BlenderMenuButton<String>).last;
    var viewButton = tester.widget<BlenderButton>(
      find.descendant(of: viewMenu, matching: find.byType(BlenderButton)),
    );
    expect(viewButton.showBorder, isFalse);
    expect(viewButton.selected, isFalse);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: tester.getCenter(viewMenu));
    await tester.tap(viewMenu);
    await tester.pumpAndSettle();
    expect(find.text('View Action'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(BlenderMenu<String>)).dx,
      closeTo(tester.getTopLeft(viewMenu).dx, 0.01),
    );
    viewButton = tester.widget<BlenderButton>(
      find.descendant(of: viewMenu, matching: find.byType(BlenderButton)),
    );
    expect(viewButton.selected, isTrue);
    final activeSurface = tester.widget<AnimatedContainer>(
      find.descendant(of: viewMenu, matching: find.byType(AnimatedContainer)),
    );
    expect(
      (activeSurface.decoration! as BoxDecoration).color,
      BlenderTheme.of(tester.element(viewMenu)).colors.surfaceRaised,
    );

    await mouse.moveTo(tester.getCenter(selectMenu));
    await tester.pumpAndSettle();
    expect(find.text('View Action'), findsNothing);
    expect(find.text('Select Action'), findsOneWidget);
    expect(
      tester
          .widget<BlenderButton>(
            find.descendant(
              of: selectMenu,
              matching: find.byType(BlenderButton),
            ),
          )
          .selected,
      isTrue,
    );
  });
}
