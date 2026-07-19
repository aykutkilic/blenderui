part of '../blender_ui_test.dart';

void registerDialogRoutesRetainALiveBlenderThemeTests() {
  testWidgets('dialog routes retain a live Blender theme source', (
    tester,
  ) async {
    final selectedTheme = ValueNotifier<BlenderThemeData>(
      BlenderThemeData.dark,
    );
    final themeController = BlenderThemeController(
      source: selectedTheme,
      resolve: () => selectedTheme.value,
    );
    addTearDown(() {
      themeController.dispose();
      selectedTheme.dispose();
    });

    await tester.pumpWidget(
      BlenderApp(
        home: BlenderThemeScope(
          controller: themeController,
          child: Builder(
            builder: (context) => BlenderButton(
              label: 'Open',
              onPressed: () => showBlenderDialog<void>(
                context: context,
                builder: (_) => Builder(
                  builder: (context) => DecoratedBox(
                    key: const ValueKey<String>('live-theme-dialog'),
                    decoration: BoxDecoration(
                      color: BlenderTheme.of(context).colors.canvas,
                    ),
                    child: const SizedBox(width: 120, height: 80),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    final dialog = find.byKey(const ValueKey<String>('live-theme-dialog'));
    expect(
      (tester.widget<DecoratedBox>(dialog).decoration as BoxDecoration).color,
      const BlenderColorScheme.dark().canvas,
    );

    selectedTheme.value = BlenderThemeData.light;
    await tester.pump();
    expect(
      (tester.widget<DecoratedBox>(dialog).decoration as BoxDecoration).color,
      const BlenderColorScheme.light().canvas,
    );
  });

  testWidgets('transform property fields keep caller-owned callbacks', (
    tester,
  ) async {
    var value = 1.0;
    var locked = false;
    await tester.pumpWidget(
      _harness(
        StatefulBuilder(
          builder: (context, setState) => BlenderTransformAxisField(
            value: value,
            decimalDigits: 2,
            locked: locked,
            onChanged: (next) => setState(() => value = next),
            onLockChanged: () => setState(() => locked = !locked),
            onKeyframe: () {},
            lockButtonKey: const ValueKey<String>('transform-lock'),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey<String>('transform-lock')));
    await tester.pump();

    expect(locked, isTrue);
  });

  testWidgets('application menu bar presents descriptor-backed menus', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      BlenderApp(
        home: BlenderApplicationMenuBar<String>(
          leading: const <Widget>[Text('Brand')],
          trailing: const <Widget>[Text('Document')],
          menus: <BlenderApplicationMenu<String>>[
            BlenderApplicationMenu<String>(
              label: 'File',
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'save', label: 'Save'),
              ],
              onSelected: (value) => selected = value,
            ),
          ],
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
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(selected, 'save');
    expect(find.text('Brand'), findsOneWidget);
    expect(find.text('Document'), findsOneWidget);
  });

  test('property values return immutable vector updates', () {
    final values = <double>[1, 2, 3];
    final locks = <bool>[false, true];

    expect(BlenderPropertyValues.replaceAt(values, 1, 8), <double>[1, 8, 3]);
    expect(values, <double>[1, 2, 3]);
    expect(BlenderPropertyValues.toggleAt(locks, 1), <bool>[false, false]);
    expect(locks, <bool>[false, true]);
  });

  testWidgets('icons always use BlenderUI built-in vector painters', (
    tester,
  ) async {
    await tester.pumpWidget(_harness(const BlenderIcon(BlenderGlyph.plus)));

    expect(find.byType(CustomPaint), findsOneWidget);
  });

  testWidgets('disclosure arrows use normalized built-in geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const Row(
          children: <Widget>[
            BlenderIcon(BlenderGlyph.panelDisclosureDown, size: 9),
            BlenderIcon(BlenderGlyph.panelDisclosureRight, size: 9),
          ],
        ),
      ),
    );

    expect(find.byType(CustomPaint), findsNWidgets(2));
  });

  testWidgets('single-line search text fits its compact field', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 220,
          child: BlenderSearchField(
            controller: controller,
            placeholder: 'Search data-blocks',
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(EditableText)).height,
      greaterThanOrEqualTo(15),
    );
  });

  testWidgets('text fields support masked preference values', (tester) async {
    final controller = TextEditingController(text: 'secret-token');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 220,
          child: BlenderTextField(controller: controller, obscureText: true),
        ),
      ),
    );

    final editable = tester.widget<EditableText>(find.byType(EditableText));
    expect(editable.obscureText, isTrue);
    expect(editable.obscuringCharacter, '•');
  });

  testWidgets('status notification badge stays inside its topmost button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const BlenderStatusInfo(
          extensionStatus: BlenderExtensionStatus.updates,
          extensionCount: 2,
        ),
      ),
    );

    final statusInfo = tester.getRect(find.byType(BlenderStatusInfo));
    final badge = tester.getRect(find.text('2'));
    expect(badge.left, greaterThanOrEqualTo(statusInfo.left));
    expect(badge.right, lessThanOrEqualTo(statusInfo.right));
    expect(badge.top, greaterThanOrEqualTo(statusInfo.top));
  });

  testWidgets('button invokes its callback on pointer activation', (
    tester,
  ) async {
    var presses = 0;
    await tester.pumpWidget(
      _harness(BlenderButton(label: 'Apply', onPressed: () => presses++)),
    );

    await tester.tap(find.text('Apply'));
    await tester.pump();

    expect(presses, 1);
  });

  testWidgets('checkbox exposes and changes its checked state', (tester) async {
    var checked = false;
    await tester.pumpWidget(
      _harness(
        StatefulBuilder(
          builder: (context, setState) => BlenderCheckbox(
            value: checked,
            onChanged: (value) => setState(() => checked = value),
            label: 'Smooth Shading',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Smooth Shading'));
    await tester.pump();

    expect(checked, isTrue);
    expect(
      tester.getSemantics(find.byType(BlenderCheckbox)),
      matchesSemantics(
        isChecked: true,
        hasCheckedState: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
      ),
    );
  });

  testWidgets('menu items support independent persistent check states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        BlenderMenu<String>(
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: 'lock-object-modes',
              label: 'Lock Object Modes',
              checked: true,
            ),
            BlenderMenuItem<String>(
              value: 'redo',
              label: 'Redo',
              enabled: false,
            ),
          ],
          onSelected: (_) {},
        ),
      ),
    );

    expect(find.text('Lock Object Modes'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('menu-row-Lock Object Modes')),
        matching: find.byType(BlenderIcon),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<BlenderIcon>(
            find.descendant(
              of: find.byKey(
                const ValueKey<String>('menu-row-Lock Object Modes'),
              ),
              matching: find.byType(BlenderIcon),
            ),
          )
          .glyph,
      BlenderGlyph.check,
    );
  });

  testWidgets('preferences window owns category navigation and filtering', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 900,
          height: 620,
          child: const BlenderPreferencesWindow(
            categories: <String>['Interface', 'Animation'],
            categoryGroups: <BlenderPreferenceCategoryGroup>[
              BlenderPreferenceCategoryGroup(
                id: 'workspace',
                label: 'Workspace',
                categories: <String>['Interface'],
              ),
              BlenderPreferenceCategoryGroup(
                id: 'motion',
                label: 'Motion',
                categories: <String>['Animation'],
              ),
            ],
            initialCategory: 'Animation',
            sections: <BlenderPreferenceSection>[
              BlenderPreferenceSection(
                id: 'timeline',
                category: 'Animation',
                title: 'Timeline',
                searchTerms: <String>['Minimum Grid Spacing'],
                child: const Text('Minimum Grid Spacing'),
              ),
              BlenderPreferenceSection(
                id: 'display',
                category: 'Interface',
                title: 'Display',
                child: const Text('Resolution Scale'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Workspace'), findsOneWidget);
    expect(find.text('Motion'), findsOneWidget);
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Minimum Grid Spacing'), findsOneWidget);

    await tester.tap(find.text('Interface'));
    await tester.pump();
    expect(find.text('Display'), findsOneWidget);
    expect(find.text('Resolution Scale'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(BlenderSearchField),
        matching: find.byType(EditableText),
      ),
      'display',
    );
    await tester.pump();
    expect(find.text('Display'), findsOneWidget);

    await tester.enterText(
      find.descendant(
        of: find.byType(BlenderSearchField),
        matching: find.byType(EditableText),
      ),
      'minimum grid',
    );
    await tester.pump();
    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Minimum Grid Spacing'), findsOneWidget);
  });

  test('property factory preserves caller-owned update callbacks', () {
    var value = false;
    final descriptor = BlenderPropertyFactory.boolean(
      'enabled',
      'Enabled',
      value,
      onChanged: (next) => value = next,
    );

    descriptor.onChanged!(true);
    expect(value, isTrue);
    expect(descriptor.id, 'enabled');
  });

  test('tree state shares expansion and flattening across nested models', () {
    const roots = <_TreeFixture>[
      _TreeFixture('root', true, <_TreeFixture>[_TreeFixture('child', false)]),
    ];
    final expanded = BlenderTreeState.initialExpanded<_TreeFixture>(
      roots,
      idOf: (item) => item.id,
      childrenOf: (item) => item.children,
      initiallyExpanded: (item) => item.initiallyExpanded,
    );
    final entries = BlenderTreeState.flatten<_TreeFixture>(
      roots,
      idOf: (item) => item.id,
      childrenOf: (item) => item.children,
      expanded: expanded,
    );

    expect(expanded, <String>{'root'});
    expect(entries.map((entry) => entry.value.id), <String>['root', 'child']);
    expect(entries.map((entry) => entry.depth), <int>[0, 1]);
  });

  testWidgets('tab bars report the selected tab index', (tester) async {
    int? selected;
    await tester.pumpWidget(
      _harness(
        BlenderTabBar(
          tabs: const <String>['Layout', 'Modeling', 'Components'],
          selectedIndex: 0,
          onChanged: (value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.text('Components'));
    await tester.pump();
    expect(selected, 2);
  });

  testWidgets('tab bars use Blender workspace tab colors and geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const BlenderTabBar(
          tabs: <String>['Layout', 'Modeling'],
          selectedIndex: 0,
          onChanged: _ignoreInt,
        ),
      ),
    );

    final selected = find.widgetWithText(BlenderButton, 'Layout');
    final inactive = find.widgetWithText(BlenderButton, 'Modeling');
    final selectedContainer = tester.widget<AnimatedContainer>(
      find.descendant(of: selected, matching: find.byType(AnimatedContainer)),
    );
    final inactiveContainer = tester.widget<AnimatedContainer>(
      find.descendant(of: inactive, matching: find.byType(AnimatedContainer)),
    );
    final selectedText = tester.widget<DefaultTextStyle>(
      find.descendant(of: selected, matching: find.byType(DefaultTextStyle)),
    );
    final inactiveText = tester.widget<DefaultTextStyle>(
      find.descendant(of: inactive, matching: find.byType(DefaultTextStyle)),
    );

    expect(
      (selectedContainer.decoration! as BoxDecoration).color,
      const Color(0xFF303030),
    );
    expect(
      (inactiveContainer.decoration! as BoxDecoration).color,
      const Color(0xFF1D1D1D),
    );
    expect(selectedText.style.color, const Color(0xFFFFFFFF));
    expect(inactiveText.style.color, const Color(0xFF989898));
    expect(tester.getSize(selected).height, 22);
    expect(tester.getSize(inactive).height, 22);
  });

  testWidgets('tooltips wait before showing and hide when the pointer leaves', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        Overlay(
          initialEntries: <OverlayEntry>[
            OverlayEntry(
              builder: (context) => const BlenderTooltip(
                message: 'Delayed help',
                child: SizedBox(width: 80, height: 24, child: Text('Hover me')),
              ),
            ),
          ],
        ),
      ),
    );

    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    await pointer.moveTo(tester.getCenter(find.text('Hover me')));
    await tester.pump(const Duration(milliseconds: 499));
    expect(find.text('Delayed help'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Delayed help'), findsOneWidget);
    final tooltip = tester.getRect(find.text('Delayed help'));
    final target = tester.getRect(find.text('Hover me'));
    expect(tooltip.top, greaterThanOrEqualTo(target.bottom + 10));

    await pointer.removePointer();
    await tester.pump(const Duration(milliseconds: 1));
    expect(find.text('Delayed help'), findsNothing);
  });

  testWidgets('labeled selection controls remain within compact columns', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 120,
          child: Column(
            children: <Widget>[
              BlenderCheckbox(
                value: false,
                onChanged: _ignoreBool,
                label: 'A deliberately long checkbox label',
              ),
              BlenderRadio<String>(
                value: 'one',
                groupValue: 'one',
                onChanged: _ignoreString,
                label: 'A deliberately long radio label',
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('theme values are available to descendants', (tester) async {
    const custom = BlenderThemeData(
      colors: BlenderColorScheme.dark(),
      density: BlenderDensity(rowHeight: 30),
    );
    late BlenderThemeData observed;
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BlenderTheme(
          data: custom,
          child: Builder(
            builder: (context) {
              observed = BlenderTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(observed.density.rowHeight, 30);
    expect(observed.colors.propertiesBackground, const Color(0xFF303030));
    expect(observed.colors.panelSubSurface, const Color(0x1F000000));
    expect(observed.colors.panelOutline, const Color(0x11FFFFFF));
  });
}
