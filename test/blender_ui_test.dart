import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _harness(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: BlenderTheme(child: child),
  );
}

void main() {
  test('local Blender icon source resolves the sibling checkout', () {
    final path = BlenderIconSource.pathFor('plus.svg');

    expect(path, isNotNull);
    expect(
      path!.replaceAll('\\', '/'),
      endsWith('/release/datafiles/icons_svg/plus.svg'),
    );
  });

  testWidgets('icons fall back when the Blender source is unavailable', (
    tester,
  ) async {
    BlenderIconSource.setDirectory('/path/that/does/not/exist');
    addTearDown(() => BlenderIconSource.setDirectory(null));

    await tester.pumpWidget(_harness(const BlenderIcon(BlenderGlyph.plus)));

    expect(find.byType(CustomPaint), findsOneWidget);
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

  testWidgets('header scroll surfaces hide automatic desktop scrollbars', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            platform: TargetPlatform.macOS,
          ),
          child: const SizedBox(
            width: 120,
            height: 30,
            child: BlenderToolbar(
              scrollable: true,
              children: <Widget>[SizedBox(width: 100), SizedBox(width: 100)],
            ),
          ),
        ),
      ),
    );

    expect(find.byType(RawScrollbar), findsNothing);
  });

  testWidgets('segmented controls leave only the group gap between buttons', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 120,
          child: BlenderSegmentedControl<String>(
            value: 'Set',
            items: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Set', label: 'Set'),
              BlenderMenuItem<String>(value: 'Add', label: 'Add'),
            ],
            onChanged: _ignoreString,
          ),
        ),
      ),
    );

    final animatedButtons = find.descendant(
      of: find.byType(BlenderSegmentedControl<String>),
      matching: find.byType(AnimatedContainer),
    );
    expect(animatedButtons, findsNWidgets(2));
    for (final element in animatedButtons.evaluate()) {
      final decoration = (element.widget as AnimatedContainer).decoration;
      expect((decoration! as BoxDecoration).border, isNull);
    }
  });

  testWidgets('boolean properties keep checkbox and label in value column', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 180,
          child: BlenderPropertiesEditor(
            groups: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'format',
                title: 'Format',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<double>(
                    id: 'resolution',
                    label: 'Resolution X',
                    value: 1920,
                    editorBuilder: (context, value, onChanged) =>
                        const SizedBox(height: 20),
                  ),
                  BlenderPropertyDescriptor<bool>(
                    id: 'render-region',
                    label: 'Render Region',
                    value: false,
                    editorBuilder: (context, value, onChanged) =>
                        BlenderCheckbox(value: value, onChanged: onChanged),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final numericLabel = tester.getRect(find.text('Resolution X'));
    final booleanLabel = tester.getRect(find.text('Render Region'));
    final checkbox = tester.getRect(find.byType(BlenderCheckbox));

    expect(numericLabel.right, lessThan(checkbox.left));
    expect(booleanLabel.left, greaterThanOrEqualTo(checkbox.right));
    expect(tester.takeException(), isNull);
  });

  test('docking controller splits, collapses, and replaces area content', () {
    final controller = BlenderDockingController<String>(
      root: const BlenderDockAreaNode<String>(id: 'main', value: 'viewport'),
    );

    final newAreaId = controller.splitArea(
      areaId: 'main',
      direction: BlenderSplitDirection.horizontal,
      fraction: .4,
      newValue: 'viewport-copy',
      newAreaFirst: false,
    );
    expect(newAreaId, isNotNull);
    expect(controller.root, isA<BlenderDockSplitNode<String>>());

    expect(
      controller.dockArea(
        sourceAreaId: newAreaId!,
        targetAreaId: 'main',
        target: BlenderDockTarget.center,
      ),
      isTrue,
    );
    expect(controller.root, isA<BlenderDockAreaNode<String>>());
    expect(
      (controller.root as BlenderDockAreaNode<String>).value,
      'viewport-copy',
    );
    controller.dispose();
  });

  testWidgets('corner action zone creates a live editor split', (tester) async {
    final controller = BlenderDockingController<String>(
      root: const BlenderDockAreaNode<String>(id: 'main', value: 'viewport'),
    );
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 240,
          child: BlenderDockingWorkspace<String>(
            controller: controller,
            areaBuilder: (context, area) =>
                const ColoredBox(color: Color(0xFF303030)),
          ),
        ),
      ),
    );

    final handle = find.bySemanticsLabel(
      'Split or dock area from topLeft corner',
    );
    await tester.dragFrom(tester.getRect(handle).center, const Offset(120, 40));
    await tester.pump();

    expect(controller.root, isA<BlenderDockSplitNode<String>>());
    controller.dispose();
  });

  testWidgets('corner drag into another area commits a center dock', (
    tester,
  ) async {
    final controller = BlenderDockingController<String>(
      root: const BlenderDockSplitNode<String>(
        id: 'columns',
        direction: BlenderSplitDirection.horizontal,
        fraction: .5,
        first: BlenderDockAreaNode<String>(id: 'left', value: 'viewport'),
        second: BlenderDockAreaNode<String>(id: 'right', value: 'properties'),
      ),
    );
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 400,
          height: 240,
          child: BlenderDockingWorkspace<String>(
            controller: controller,
            areaBuilder: (context, area) =>
                const ColoredBox(color: Color(0xFF303030)),
          ),
        ),
      ),
    );

    final handles = find.bySemanticsLabel(
      'Split or dock area from topRight corner',
    );
    final firstHandle = handles.at(0);
    final secondHandle = handles.at(1);
    final sourceHandle =
        tester.getRect(firstHandle).left < tester.getRect(secondHandle).left
        ? firstHandle
        : secondHandle;
    final workspaceRect = tester.getRect(
      find.byType(BlenderDockingWorkspace<String>),
    );
    final gesture = await tester.startGesture(
      tester.getRect(sourceHandle).center,
    );
    await gesture.moveBy(const Offset(0, 30));
    await tester.pump();
    await gesture.moveTo(
      Offset(
        workspaceRect.left + workspaceRect.width * .75,
        workspaceRect.top + workspaceRect.height * .5,
      ),
    );
    await tester.pump();
    await gesture.up();
    await tester.pump();

    expect(controller.root, isA<BlenderDockAreaNode<String>>());
    expect((controller.root as BlenderDockAreaNode<String>).value, 'viewport');
    controller.dispose();
  });

  testWidgets('Blender control variants and non-3D editors render', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 640,
          height: 640,
          child: Column(
            children: <Widget>[
              BlenderSegmentedControl<String>(
                value: 'Solid',
                items: <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Solid', label: 'Solid'),
                  BlenderMenuItem<String>(value: 'Wire', label: 'Wire'),
                ],
                onChanged: _ignoreString,
              ),
              BlenderProgressBar(value: .5, label: '50%'),
              Expanded(
                child: BlenderSpreadsheetEditor(
                  columns: <BlenderSpreadsheetColumn>[
                    BlenderSpreadsheetColumn(id: 'name', label: 'Name'),
                    BlenderSpreadsheetColumn(id: 'value', label: 'Value'),
                  ],
                  rows: <BlenderSpreadsheetRow>[
                    BlenderSpreadsheetRow(
                      id: 'one',
                      values: <String>['One', '1'],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Solid'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget);
    expect(find.text('Spreadsheet'), findsOneWidget);
    expect(find.text('One'), findsOneWidget);
  });

  testWidgets('dropdown uses an anchored popover and reports selection', (
    tester,
  ) async {
    var value = 'Solid';
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) => SizedBox(
              width: 240,
              child: BlenderDropdown<String>(
                value: value,
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Solid',
                    label: 'Solid',
                    icon: BlenderIcon(BlenderGlyph.scene, size: 16),
                  ),
                  BlenderMenuItem<String>(value: 'Wire', label: 'Wire'),
                ],
                onChanged: (next) => setState(() => value = next),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Solid'));
    await tester.pump();
    expect(find.text('Wire'), findsOneWidget);
    await tester.tap(find.text('Wire'));
    await tester.pump();

    expect(value, 'Wire');
    expect(find.text('Wire'), findsOneWidget);
  });

  testWidgets('menu button opens a pulldown and reports selection', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 320,
            child: BlenderMenuButton<String>(
              label: 'File',
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'open',
                  label: 'Open File',
                  selected: true,
                ),
              ],
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('File'), warnIfMissed: false);
    await tester.pump();
    expect(find.text('Open File'), findsOneWidget);
    expect(find.byType(BlenderIcon), findsOneWidget);
    await tester.tap(find.text('Open File'));
    await tester.pump();
    expect(selected, 'open');
  });

  testWidgets('color picker emits a changed color', (tester) async {
    var color = const Color(0xFF4772B3);
    await tester.pumpWidget(
      _harness(
        StatefulBuilder(
          builder: (context, setState) => SizedBox(
            width: 320,
            child: BlenderColorPicker(
              color: color,
              onChanged: (value) => setState(() => color = value),
            ),
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    await tester.tapAt(const Offset(300, 40));
    await tester.pump();

    expect(color, isNot(const Color(0xFF4772B3)));
  });

  testWidgets('tree selection reports the selected descriptor', (tester) async {
    BlenderTreeNode<String>? selected;
    const roots = <BlenderTreeNode<String>>[
      BlenderTreeNode<String>(id: 'cube', label: 'Cube', value: 'cube'),
    ];
    await tester.pumpWidget(
      _harness(
        SizedBox(
          height: 100,
          child: BlenderTree<String>(
            roots: roots,
            onSelected: (node) => selected = node,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Cube'));
    await tester.pump();

    expect(selected?.id, 'cube');
  });

  testWidgets('timeline and node editor render with generic models', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 600,
          height: 400,
          child: Column(
            children: <Widget>[
              const Expanded(
                child: BlenderTimeline(
                  model: const BlenderTimelineModel(
                    start: 1,
                    end: 60,
                    currentFrame: 1,
                    tracks: <BlenderTimelineTrack>[
                      const BlenderTimelineTrack(
                        id: 'main',
                        label: 'Main',
                        keyframes: <BlenderTimelineKeyframe>[
                          const BlenderTimelineKeyframe(1),
                        ],
                      ),
                    ],
                  ),
                  onCurrentFrameChanged: _ignoreDouble,
                ),
              ),
              const Expanded(
                child: BlenderNodeEditor(
                  model: const BlenderNodeGraphModel(
                    nodes: <BlenderGraphNode>[
                      const BlenderGraphNode(
                        id: 'a',
                        title: 'Input',
                        position: Offset(20, 20),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Timeline'), findsOneWidget);
    expect(find.text('Node Editor'), findsOneWidget);
  });

  testWidgets('list view reports selection and activation', (tester) async {
    BlenderListItem<String>? selected;
    BlenderListItem<String>? activated;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 240,
          height: 100,
          child: BlenderListView<String>(
            items: const <BlenderListItem<String>>[
              BlenderListItem<String>(id: 'scene', label: 'scene.blend'),
            ],
            onSelected: (item) => selected = item,
            onActivated: (item) => activated = item,
          ),
        ),
      ),
    );

    await tester.tap(find.text('scene.blend'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(selected?.id, 'scene');

    final center = tester.getCenter(find.text('scene.blend'));
    final firstTap = await tester.startGesture(center);
    await firstTap.up();
    await tester.pump(const Duration(milliseconds: 50));
    final secondTap = await tester.startGesture(center);
    await secondTap.up();
    await tester.pump(const Duration(milliseconds: 400));
    expect(activated?.id, 'scene');
  });

  testWidgets('file browser filters and restores entries', (tester) async {
    final search = TextEditingController();
    addTearDown(search.dispose);
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 360,
          height: 240,
          child: BlenderFileBrowser(
            entries: const <BlenderFileEntry>[
              BlenderFileEntry(path: '/scene.blend', name: 'scene.blend'),
              BlenderFileEntry(path: '/notes.txt', name: 'notes.txt'),
            ],
            searchController: search,
          ),
        ),
      ),
    );

    expect(find.text('scene.blend'), findsOneWidget);
    expect(find.text('notes.txt'), findsOneWidget);
    search.text = 'scene';
    await tester.pump();
    expect(find.text('scene.blend'), findsOneWidget);
    expect(find.text('notes.txt'), findsNothing);
    search.clear();
    await tester.pump();
    expect(find.text('notes.txt'), findsOneWidget);
  });

  testWidgets('node sockets render as compact labeled ports', (tester) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 500,
          height: 300,
          child: const BlenderNodeEditor(
            model: const BlenderNodeGraphModel(
              nodes: <BlenderGraphNode>[
                BlenderGraphNode(
                  id: 'shader',
                  title: 'Shader',
                  position: Offset(20, 20),
                  size: Size(220, 120),
                  inputs: <BlenderNodeSocketDefinition>[
                    BlenderNodeSocketDefinition(id: 'color', label: 'Color'),
                  ],
                  outputs: <BlenderNodeSocketDefinition>[
                    BlenderNodeSocketDefinition(id: 'shader', label: 'BSDF'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Color'), findsOneWidget);
    expect(find.text('BSDF'), findsOneWidget);
  });

  testWidgets('template controls render and emit changes', (tester) async {
    var ramp = const <BlenderColorRampStop>[
      BlenderColorRampStop(position: 0, color: Color(0xFF000000)),
      BlenderColorRampStop(position: 1, color: Color(0xFFFFFFFF)),
    ];
    var curve = const <Offset>[Offset(0, 0), Offset(1, 1)];
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 360,
          height: 420,
          child: Column(
            children: <Widget>[
              BlenderVectorField(
                values: const <double>[0, 1, 2],
                onChanged: (_) {},
              ),
              const BlenderMatrixField(
                values: const <List<double>>[
                  <double>[1, 0],
                  <double>[0, 1],
                ],
                rowLabels: const <String>['X', 'Y'],
                columnLabels: const <String>['X', 'Y'],
                onChanged: _ignoreMatrix,
              ),
              BlenderColorRamp(stops: ramp, onChanged: (value) => ramp = value),
              Expanded(
                child: BlenderCurveMapping(
                  points: curve,
                  onChanged: (value) => curve = value,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('X'), findsWidgets);
    await tester.tapAt(const Offset(330, 120));
    await tester.pump();
    expect(ramp, isNotEmpty);
    final rampRect = tester.getRect(find.byType(BlenderColorRamp));
    await tester.dragFrom(
      Offset(rampRect.right - 2, rampRect.top + 10),
      const Offset(-90, 0),
    );
    await tester.pump();
    expect(ramp.any((stop) => stop.position < 1), isTrue);
    await tester.tapAt(const Offset(300, 350));
    await tester.pump();
    expect(curve, isNotEmpty);
  });

  testWidgets('search menu filters operator entries', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 320,
          height: 220,
          child: BlenderSearchMenu<String>(
            controller: controller,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'save', label: 'Save Mainfile'),
              BlenderMenuItem<String>(value: 'open', label: 'Open Mainfile'),
            ],
            onSelected: _ignoreMenuItem,
          ),
        ),
      ),
    );

    expect(find.text('Save Mainfile'), findsOneWidget);
    expect(find.text('Open Mainfile'), findsOneWidget);
    controller.text = 'open';
    await tester.pump();
    expect(find.text('Save Mainfile'), findsNothing);
    expect(find.text('Open Mainfile'), findsOneWidget);
  });

  testWidgets('search menu preview mode renders a thumbnail grid', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? selected;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 420,
          height: 260,
          child: BlenderSearchMenu<String>(
            controller: controller,
            previewRows: 2,
            previewColumns: 2,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'cube',
                label: 'Cube',
                icon: BlenderIcon(BlenderGlyph.cube, size: 30),
              ),
              BlenderMenuItem<String>(
                value: 'sphere',
                label: 'Sphere',
                icon: BlenderIcon(BlenderGlyph.object, size: 30),
              ),
            ],
            onSelected: (item) => selected = item.value,
          ),
        ),
      ),
    );

    expect(find.byType(BlenderPreviewTile), findsNWidgets(2));
    await tester.tap(find.text('Sphere'));
    await tester.pump();
    expect(selected, 'sphere');
  });

  testWidgets('scope templates render normalized waveform data', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 320,
          height: 190,
          child: BlenderScopeView(
            type: BlenderScopeType.waveform,
            series: <BlenderScopeSeries>[
              BlenderScopeSeries(
                color: Color(0xFF71A8FF),
                points: <Offset>[Offset(0, 0), Offset(1, 1)],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Scope'), findsOneWidget);
  });

  testWidgets('recent-file template reports selection', (tester) async {
    BlenderRecentFile? selected;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 360,
          height: 180,
          child: BlenderRecentFiles(
            files: const <BlenderRecentFile>[
              BlenderRecentFile(
                id: 'scene',
                name: 'showcase.blend',
                path: '/showcase/showcase.blend',
              ),
            ],
            onSelected: (file) => selected = file,
          ),
        ),
      ),
    );

    await tester.tap(find.text('showcase.blend'));
    await tester.pump();
    expect(selected?.id, 'scene');
  });

  testWidgets('job progress reports cancellation', (tester) async {
    var canceled = false;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 420,
          height: 60,
          child: BlenderJobProgress(
            name: 'Building preview',
            progress: .68,
            onCancel: () => canceled = true,
          ),
        ),
      ),
    );

    expect(find.text('Building preview'), findsOneWidget);
    expect(find.text('68%'), findsOneWidget);
    await tester.tap(find.byType(BlenderButton).last);
    await tester.pump();
    expect(canceled, isTrue);
  });

  testWidgets('attribute search opens and selects an attribute', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 360,
            child: BlenderAttributeSearch<String>(
              options: const <BlenderAttributeOption<String>>[
                BlenderAttributeOption<String>(
                  name: 'roughness',
                  value: 'roughness',
                  domain: 'Point',
                  dataType: 'Float',
                ),
                BlenderAttributeOption<String>(
                  name: 'uv_map',
                  value: 'uv_map',
                  domain: 'Corner',
                  dataType: 'Float2',
                ),
              ],
              value: selected,
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Attribute'), warnIfMissed: false);
    await tester.pump();
    expect(find.textContaining('roughness'), findsOneWidget);
    await tester.tap(find.textContaining('roughness'));
    await tester.pump();
    expect(selected, 'roughness');
  });

  testWidgets('property templates render and update', (tester) async {
    List<String> activeLayers = <String>['one'];
    var colorSettings = const BlenderColorManagementSettings();
    var profile = const <Offset>[Offset(0, 0), Offset(1, 1)];
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 520,
          height: 720,
          child: ListView(
            children: <Widget>[
              BlenderLayerSelector(
                layers: <BlenderLayerItem>[
                  BlenderLayerItem(
                    id: 'one',
                    label: '1',
                    active: activeLayers.contains('one'),
                  ),
                  BlenderLayerItem(
                    id: 'two',
                    label: '2',
                    active: activeLayers.contains('two'),
                    used: true,
                  ),
                ],
                onChanged: (value) => activeLayers = value,
              ),
              BlenderColorManagement(
                settings: colorSettings,
                onChanged: (value) => colorSettings = value,
              ),
              BlenderCurveProfile(
                points: profile,
                presets: const <BlenderCurveProfilePreset>[
                  BlenderCurveProfilePreset(
                    name: 'Default',
                    points: <Offset>[Offset(0, 0), Offset(1, 1)],
                  ),
                ],
                onChanged: (value) => profile = value,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Color Management'), findsOneWidget);
    expect(find.text('Curve Profile'), findsOneWidget);
    await tester.tap(find.text('2'));
    await tester.pump();
    expect(activeLayers, <String>['two']);
  });

  testWidgets('modifier and node-input templates render', (tester) async {
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 520,
          height: 360,
          child: ListView(
            children: <Widget>[
              const BlenderModifierStack(
                modifiers: <BlenderModifierDescriptor>[
                  BlenderModifierDescriptor(
                    id: 'bevel',
                    name: 'Bevel',
                    child: const BlenderButton(label: 'Amount'),
                  ),
                ],
              ),
              const BlenderNodeInputs(
                groups: <BlenderNodeInputGroup>[
                  BlenderNodeInputGroup(
                    id: 'surface',
                    title: 'Surface',
                    inputs: <BlenderNodeInputDescriptor>[
                      BlenderNodeInputDescriptor(
                        id: 'color',
                        label: 'Base Color',
                        editor: BlenderButton(label: 'Color'),
                      ),
                      BlenderNodeInputDescriptor(
                        id: 'normal',
                        label: 'Normal',
                        editor: SizedBox.shrink(),
                        linked: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Bevel'), findsOneWidget);
    expect(find.text('Surface'), findsOneWidget);
    expect(find.text('Linked'), findsOneWidget);
  });

  testWidgets('remaining Blender widget styles render', (tester) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 320,
          height: 180,
          child: Column(
            children: <Widget>[
              const BlenderIconLabel(
                label: 'Linked Object',
                icon: BlenderGlyph.object,
              ),
              const SizedBox(height: 4),
              const BlenderLinkLabel(label: 'Cube Data'),
              const SizedBox(height: 4),
              const BlenderOperatorButton(
                label: 'Apply',
                icon: BlenderGlyph.check,
              ),
              const SizedBox(height: 4),
              const BlenderNoticeBanner(
                message: 'Changes saved',
                level: BlenderNoticeLevel.success,
                onDismiss: _ignoreVoid,
              ),
              const SizedBox(height: 4),
              const BlenderUnitVector(
                value: Offset.zero,
                onChanged: _ignoreOffset,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Linked Object'), findsOneWidget);
    expect(find.text('Cube Data'), findsOneWidget);
    expect(find.text('Changes saved'), findsOneWidget);
  });

  testWidgets('popover opens an anchored interactive surface', (tester) async {
    var selected = false;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: BlenderTheme(
            child: SizedBox(
              width: 180,
              height: 40,
              child: BlenderPopover(
                child: const BlenderButton(label: 'Options'),
                popover: (context, close) => SizedBox(
                  width: 180,
                  height: 100,
                  child: BlenderPanel(
                    title: 'Popover',
                    child: BlenderButton(
                      label: 'Choose',
                      onPressed: () {
                        selected = true;
                        close();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Options'));
    await tester.pump();
    expect(find.text('Popover'), findsOneWidget);
    await tester.tap(find.text('Choose'));
    await tester.pump();
    expect(selected, isTrue);
    expect(find.text('Popover'), findsNothing);
  });

  testWidgets('pie menu exposes radial command entries', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _harness(
        BlenderPieMenu<String>(
          items: const <BlenderPieMenuItem<String>>[
            BlenderPieMenuItem<String>(value: 'move', label: 'Move'),
            BlenderPieMenuItem<String>(value: 'rotate', label: 'Rotate'),
          ],
          onSelected: (item) => selected = item.value,
        ),
      ),
    );

    expect(find.text('Move'), findsOneWidget);
    await tester.tap(find.text('Rotate'));
    await tester.pump();
    expect(selected, 'rotate');
  });

  testWidgets('non-3D editor surfaces render independently', (tester) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 600,
          height: 360,
          child: BlenderVideoSequencerEditor(
            strips: const <BlenderSequencerStrip>[
              BlenderSequencerStrip(
                id: 'clip',
                label: 'Clip',
                start: 1,
                end: 40,
              ),
            ],
            start: 1,
            end: 60,
          ),
        ),
      ),
    );
    expect(find.text('Video Sequencer'), findsOneWidget);

    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 600,
          height: 360,
          child: BlenderPreferencesEditor(
            categories: const <String>['Interface'],
            sections: const <BlenderPreferenceSection>[
              BlenderPreferenceSection(
                id: 'theme',
                category: 'Interface',
                title: 'Theme',
                child: const Text('Theme settings'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Theme'), findsWidgets);
  });

  testWidgets('info editor renders report severity and timestamp', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 420,
          height: 180,
          child: BlenderInfoEditor(
            reports: <BlenderInfoReport>[
              BlenderInfoReport(
                id: 'saved',
                message: 'Saved showcase.blend',
                level: BlenderNoticeLevel.success,
                timestamp: 'Now',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Saved showcase.blend'), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);
  });

  testWidgets('Properties visible-tabs menu opens and updates visibility', (
    tester,
  ) async {
    var visible = <String>{'tool', 'render'};
    const tabs = <BlenderPropertyTab>[
      BlenderPropertyTab(id: 'tool', label: 'Tool', glyph: BlenderGlyph.tool),
      BlenderPropertyTab(
        id: 'render',
        label: 'Render',
        glyph: BlenderGlyph.render,
      ),
    ];
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: BlenderTheme(
            child: SizedBox(
              width: 160,
              height: 40,
              child: StatefulBuilder(
                builder: (context, setState) => Align(
                  alignment: Alignment.centerLeft,
                  child: BlenderPropertyTabVisibilityMenu(
                    tabs: tabs,
                    visibleTabIds: visible,
                    onVisibilityChanged: (value) =>
                        setState(() => visible = value),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(BlenderPropertyTabVisibilityMenu));
    await tester.pump();
    expect(find.text('Visible Tabs'), findsOneWidget);
    expect(find.text('Tool'), findsOneWidget);

    await tester.tap(find.byType(BlenderCheckbox).last);
    await tester.pump();
    expect(visible, <String>{'tool'});
  });

  testWidgets('Properties context tiles fill their navigation rail', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 120,
          height: 180,
          child: BlenderPropertyTabs(
            tabs: <BlenderPropertyTab>[
              BlenderPropertyTab(
                id: 'tool',
                label: 'Tool',
                glyph: BlenderGlyph.tool,
              ),
              BlenderPropertyTab(
                id: 'output',
                label: 'Output',
                glyph: BlenderGlyph.output,
              ),
            ],
            selectedIndex: 0,
            onChanged: _ignoreInt,
          ),
        ),
      ),
    );

    final tabs = tester.widget<BlenderPropertyTabs>(
      find.byType(BlenderPropertyTabs),
    );
    expect(tabs.tileSize, tabs.width);
  });

  testWidgets('editor type selector uses Blender menu trigger states', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlenderApp(
        home: _harness(
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 40,
              child: BlenderEditorTypeSelector(
                value: BlenderEditorType.properties,
                compact: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      ),
    );

    final buttonFinder = find.descendant(
      of: find.byType(BlenderEditorTypeSelector),
      matching: find.byType(BlenderButton),
    );
    var button = tester.widget<BlenderButton>(buttonFinder);
    expect(button.variant, BlenderButtonVariant.menuTrigger);
    expect(button.selected, isFalse);
    expect(
      (button.trailing! as BlenderIcon).glyph,
      BlenderGlyph.panelDisclosureDown,
    );

    await tester.tapAt(tester.getCenter(buttonFinder));
    await tester.pump();

    button = tester.widget<BlenderButton>(buttonFinder);
    expect(button.selected, isTrue);
    expect(find.text('General'), findsOneWidget);
  });

  testWidgets('Outliner filter exposes restriction controls', (tester) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: BlenderTheme(
          child: SizedBox(
            width: 360,
            height: 300,
            child: BlenderOutliner<String>(
              roots: <BlenderTreeNode<String>>[
                BlenderTreeNode<String>(id: 'scene', label: 'Scene Collection'),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIconButton && widget.glyph == BlenderGlyph.filter,
      ),
    );
    await tester.pump();

    expect(find.text('Restriction Toggles'), findsOneWidget);
    expect(find.text('Sort Alphabetically'), findsOneWidget);
    expect(find.text('Object Contents'), findsOneWidget);
  });

  testWidgets('Outliner display-mode dropdown reports the selected view', (
    tester,
  ) async {
    var mode = BlenderOutlinerDisplayMode.viewLayer;
    await tester.pumpWidget(
      BlenderApp(
        home: BlenderTheme(
          child: SizedBox(
            width: 360,
            height: 300,
            child: StatefulBuilder(
              builder: (context, setState) => BlenderOutliner<String>(
                displayMode: mode,
                onDisplayModeChanged: (value) => setState(() => mode = value),
                roots: const <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'scene',
                    label: 'Scene Collection',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(BlenderDropdown<BlenderOutlinerDisplayMode>));
    await tester.pump();
    expect(find.text('Video Sequencer'), findsOneWidget);
    await tester.tap(find.text('Blender File'));
    await tester.pump();

    expect(mode, BlenderOutlinerDisplayMode.blenderFile);
  });

  testWidgets('splitter exposes a draggable directional divider', (
    tester,
  ) async {
    var fraction = .5;
    await tester.pumpWidget(
      BlenderApp(
        home: BlenderTheme(
          child: SizedBox(
            width: 400,
            height: 180,
            child: BlenderSplitter(
              initialFraction: fraction,
              onFractionChanged: (value) => fraction = value,
              first: const SizedBox.expand(),
              second: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );

    final rect = tester.getRect(find.bySemanticsLabel('Resize editor width'));
    final dragSurface = find.byKey(
      const ValueKey<String>('blender-splitter-drag-surface'),
    );
    expect(tester.widget<MouseRegion>(dragSurface).cursor, MouseCursor.defer);

    final gesture = await tester.startGesture(rect.center);
    await gesture.moveBy(const Offset(8, 0));
    await tester.pump();

    expect(
      tester.widget<MouseRegion>(dragSurface).cursor,
      SystemMouseCursors.resizeColumn,
    );

    // The divider has moved underneath the pointer, but the cursor remains
    // owned by the active splitter surface instead of flickering to default.
    await gesture.moveBy(const Offset(48, 0));
    await tester.pump();
    expect(
      tester.widget<MouseRegion>(dragSurface).cursor,
      SystemMouseCursors.resizeColumn,
    );
    await gesture.up();
    await tester.pump();

    expect(fraction, greaterThan(.5));
  });

  testWidgets('editor shell exposes a draggable right-area divider', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 400,
          height: 180,
          child: BlenderEditorShell(
            main: SizedBox.expand(),
            right: SizedBox.expand(key: Key('right-editor-area')),
            rightWidth: 100,
          ),
        ),
      ),
    );

    final divider = find.bySemanticsLabel('Resize editor width');
    final before = tester.getRect(find.byKey(const Key('right-editor-area')));
    await tester.dragFrom(tester.getRect(divider).center, const Offset(-40, 0));
    await tester.pump();
    final after = tester.getRect(find.byKey(const Key('right-editor-area')));

    expect(after.width, greaterThan(before.width));
  });

  testWidgets('number field drags with Blender-style sensitivity', (
    tester,
  ) async {
    var value = 1.0;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 180,
          child: StatefulBuilder(
            builder: (context, setState) => BlenderNumberField(
              value: value,
              min: 0,
              max: 100,
              decimalDigits: 2,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      ),
    );

    await tester.drag(find.byType(BlenderNumberField), const Offset(40, 0));
    await tester.pump();
    expect(value, greaterThan(1));
    await tester.pump(const Duration(milliseconds: 50));
  });

  testWidgets('number field supports precise text-edit transition', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 180,
          child: BlenderNumberField(
            value: 1,
            decimalDigits: 2,
            onChanged: _ignoreDouble,
          ),
        ),
      ),
    );
    final fieldGesture = find.byWidgetPredicate(
      (widget) =>
          widget is GestureDetector && widget.onHorizontalDragStart != null,
    );
    tester.widget<GestureDetector>(fieldGesture.first).onTap!();
    await tester.pumpAndSettle();
    expect(find.byType(EditableText), findsOneWidget);
  });

  testWidgets('alert dialog uses centered Blender modal anatomy', (
    tester,
  ) async {
    var confirmed = false;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: BlenderButton(
              label: 'Delete',
              onPressed: () => showBlenderAlertDialog(
                context: tester.element(find.text('Delete')),
                title: 'Delete Object',
                message: 'This action cannot be undone.\nContinue?',
                confirmLabel: 'Delete',
                onConfirm: () => confirmed = true,
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Delete Object'), findsOneWidget);
    expect(find.text('This action cannot be undone.'), findsOneWidget);
    expect(find.text('Continue?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
    expect(find.text('Delete Object'), findsNothing);
  });

  testWidgets('operator redo and property dialog preserve popup anatomy', (
    tester,
  ) async {
    var confirmed = false;
    final properties = <BlenderPropertyDescriptor<dynamic>>[
      BlenderPropertyDescriptor<double>(
        id: 'offset',
        label: 'Offset',
        value: .25,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: 0,
          max: 1,
          onChanged: onChanged,
        ),
      ),
      BlenderPropertyDescriptor<bool>(
        id: 'preview',
        label: 'Preview Range',
        value: true,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, label: '', onChanged: onChanged),
      ),
    ];

    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: <Widget>[
              BlenderOperatorRedoPopup(title: 'Move', properties: properties),
              BlenderButton(
                label: 'Open operator dialog',
                onPressed: () => showBlenderOperatorPropertiesDialog(
                  context: tester.element(find.text('Open operator dialog')),
                  title: 'Move',
                  message: 'Adjust the move operation.',
                  properties: properties,
                  confirmLabel: 'Apply',
                  onConfirm: () => confirmed = true,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Move'), findsOneWidget);
    expect(find.text('Offset'), findsOneWidget);
    expect(find.text('Preview Range'), findsOneWidget);
    await tester.tap(find.text('Open operator dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Adjust the move operation.'), findsOneWidget);
    expect(find.text('Apply'), findsOneWidget);
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();
    expect(confirmed, isTrue);
  });

  testWidgets('collection importer and exporter templates preserve controls', (
    tester,
  ) async {
    final importerPath = TextEditingController(text: '/import/source.fbx');
    final exporterPath = TextEditingController(text: '//scene.gltf');
    addTearDown(importerPath.dispose);
    addTearDown(exporterPath.dispose);
    BlenderCollectionExporter? selected;

    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 720,
          height: 760,
          child: BlenderScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                BlenderCollectionImporterPanel(
                  importer: BlenderCollectionImporter(
                    label: 'FBX Importer',
                    filepathController: importerPath,
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      BlenderPropertyDescriptor<bool>(
                        id: 'collections',
                        label: 'Keep Collections',
                        value: true,
                        editorBuilder: (context, value, onChanged) =>
                            BlenderCheckbox(
                              value: value,
                              label: '',
                              onChanged: onChanged,
                            ),
                      ),
                    ],
                  ),
                ),
                BlenderCollectionExportersPanel(
                  selectedId: 'gltf',
                  exporters: <BlenderCollectionExporter>[
                    BlenderCollectionExporter(
                      id: 'gltf',
                      label: 'glTF 2.0',
                      filepathController: exporterPath,
                    ),
                    const BlenderCollectionExporter(
                      id: 'usd',
                      label: 'USD',
                      valid: false,
                    ),
                  ],
                  onSelected: (value) => selected = value,
                  onAdd: () {},
                  onRemove: () {},
                  onMoveUp: () {},
                  onMoveDown: () {},
                  onExportAll: () {},
                  onExport: () {},
                  onPresets: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Collection Importer'), findsOneWidget);
    expect(find.text('FBX Importer'), findsOneWidget);
    expect(find.byType(BlenderPathField), findsNWidgets(2));
    expect(find.text('Collection Exporters'), findsOneWidget);
    expect(find.text('glTF 2.0'), findsNWidgets(2));
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('Export All'), findsOneWidget);
    await tester.tap(find.text('USD'));
    expect(selected?.id, 'usd');
  });

  testWidgets('color palette preserves management controls and swatches', (
    tester,
  ) async {
    var selected = -1;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 360,
          child: BlenderColorPalette(
            title: 'Palette',
            colors: const <Color>[Color(0xFFAA4433), Color(0xFF3366AA)],
            selectedIndex: 0,
            onSelected: (index) => selected = index,
            onAdd: () {},
            onRemove: () {},
            onMoveUp: () {},
            onMoveDown: () {},
          ),
        ),
      ),
    );

    expect(find.text('Palette'), findsOneWidget);
    expect(find.bySemanticsLabel('Palette color 1'), findsOneWidget);
    expect(find.bySemanticsLabel('Palette color 2'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Palette color 2'));
    expect(selected, 1);
  });

  testWidgets('action and cryptomatte templates preserve ID affordances', (
    tester,
  ) async {
    var picked = false;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 640,
          child: Column(
            children: <Widget>[
              BlenderActionSelector<String>(
                value: 'walk',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'walk', label: 'Walk Cycle'),
                ],
                onChanged: (_) {},
                onNew: () {},
                onUnlink: () {},
              ),
              BlenderCryptoPicker(
                label: 'Cryptomatte',
                onPressed: () => picked = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Action'), findsOneWidget);
    expect(find.text('Walk Cycle'), findsOneWidget);
    expect(find.bySemanticsLabel('Pick Cryptomatte color'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Pick Cryptomatte color'));
    expect(picked, isTrue);
  });

  testWidgets('specialized property stacks render Blender source anatomy', (
    tester,
  ) async {
    var cache = const BlenderCacheFileSettings(
      path: '/cache/scene.abc',
      velocityName: 'velocity',
    );
    var linkState = BlenderLightLinkingState.include;
    final search = TextEditingController();
    addTearDown(search.dispose);
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 720,
          height: 900,
          child: BlenderScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const BlenderConstraintStack(
                  constraints: <BlenderConstraintDescriptor>[
                    BlenderConstraintDescriptor(
                      id: 'limit',
                      name: 'Limit Location',
                      child: const Text('Constraint properties'),
                    ),
                  ],
                ),
                const BlenderShaderEffectStack(
                  effects: <BlenderShaderEffectDescriptor>[
                    BlenderShaderEffectDescriptor(
                      id: 'shadow',
                      name: 'Drop Shadow',
                      child: Text('Shader effect properties'),
                    ),
                  ],
                ),
                const BlenderNodeTreeInterface(
                  items: <BlenderNodeInterfaceItem>[
                    BlenderNodeInterfaceItem.socket(
                      BlenderNodeInterfaceSocket(id: 'value', label: 'Value'),
                    ),
                  ],
                ),
                BlenderCacheFilePanel(
                  settings: cache,
                  onChanged: (value) => cache = value,
                ),
                BlenderLightLinkingCollection(
                  items: <BlenderLightLinkingItem>[
                    BlenderLightLinkingItem(
                      id: 'key',
                      label: 'Key Light',
                      onStateChanged: (value) => linkState = value,
                    ),
                  ],
                ),
                BlenderGreasePencilLayerTree(
                  searchController: search,
                  layers: <BlenderGreasePencilLayer>[
                    const BlenderGreasePencilLayer(
                      id: 'group',
                      name: 'Group',
                      isGroup: true,
                      children: <BlenderGreasePencilLayer>[
                        const BlenderGreasePencilLayer(
                          id: 'outline',
                          name: 'Outline',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Limit Location'), findsOneWidget);
    expect(find.text('Drop Shadow'), findsOneWidget);
    expect(find.text('Node Tree Interface'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text('Cache File'), findsOneWidget);
    expect(find.text('Time Settings'), findsOneWidget);
    expect(find.text('Velocity'), findsOneWidget);
    expect(find.text('Light Linking'), findsOneWidget);
    expect(find.text('Key Light'), findsOneWidget);
    expect(find.text('Grease Pencil Layers'), findsOneWidget);
    expect(find.text('Outline'), findsOneWidget);

    final linkingCheckbox = find.byType(BlenderCheckbox).last;
    await tester.ensureVisible(linkingCheckbox);
    await tester.tap(linkingCheckbox);
    await tester.pump();
    expect(linkState, BlenderLightLinkingState.exclude);

    search.text = 'missing';
    await tester.pump();
    expect(find.text('No layers'), findsOneWidget);
    search.text = 'outline';
    await tester.pump();
    expect(find.text('Outline'), findsOneWidget);
  });

  testWidgets('data-block field exposes the full ID template anatomy', (
    tester,
  ) async {
    String? selected;
    var newCount = 0;
    var fakeUser = true;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 760,
            child: BlenderDataBlockField<String>(
              label: 'Material',
              value: 'Material',
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'Material',
                  label: 'Material',
                  icon: BlenderIcon(BlenderGlyph.material, size: 14),
                ),
                BlenderMenuItem<String>(
                  value: 'Mesh',
                  label: 'Mesh',
                  icon: BlenderIcon(BlenderGlyph.object, size: 14),
                ),
              ],
              onChanged: (value) => selected = value,
              onNew: () => newCount++,
              onOpen: () {},
              onMakeSingleUser: () {},
              onMakeLocal: () {},
              onToggleFakeUser: (value) => fakeUser = value,
              onUnlink: () {},
              fakeUser: fakeUser,
              userCount: 3,
              linked: true,
              libraryOverride: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Material'), findsWidgets);
    expect(find.text('3'), findsOneWidget);
    expect(find.bySemanticsLabel('Make local'), findsOneWidget);
    expect(find.bySemanticsLabel('Library override'), findsOneWidget);
    expect(find.bySemanticsLabel('Keep data-block'), findsOneWidget);
    expect(find.bySemanticsLabel('Unlink data-block'), findsOneWidget);

    await tester.tap(find.text('Material').last, warnIfMissed: false);
    await tester.pump();
    expect(find.byType(BlenderSearchField), findsOneWidget);
    expect(find.text('Mesh'), findsOneWidget);
    await tester.tap(find.text('Mesh'));
    await tester.pump();
    expect(selected, 'Mesh');
    expect(find.text('Search data-blocks'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Make new data-block'));
    await tester.pump();
    expect(newCount, 1);
    await tester.tap(find.bySemanticsLabel('Keep data-block'));
    await tester.pump();
    expect(fakeUser, isFalse);
  });

  testWidgets('keymap property boxes preserve set and unset variants', (
    tester,
  ) async {
    var unset = 0;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 640,
          height: 180,
          child: BlenderKeymapItemProperties(
            properties: <BlenderKeymapProperty>[
              BlenderKeymapProperty(
                id: 'repeat',
                label: 'Repeat',
                editor: const Text('Repeat'),
                onUnset: () => unset++,
              ),
              const BlenderKeymapProperty(
                id: 'threshold',
                label: 'Threshold',
                editor: Text('Inherited'),
                isSet: false,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Repeat'), findsOneWidget);
    expect(find.text('Inherited'), findsOneWidget);
    expect(find.byType(BlenderIconButton), findsOneWidget);
    await tester.tap(find.byType(BlenderIconButton));
    await tester.pump();
    expect(unset, 1);
  });

  testWidgets('icon view opens an eight-column enum preview popup', (
    tester,
  ) async {
    String selected = 'Object';
    await tester.pumpWidget(
      BlenderApp(
        home: _harness(
          SizedBox(
            width: 320,
            height: 240,
            child: BlenderIconView<String>(
              value: selected,
              items: const <BlenderIconViewItem<String>>[
                BlenderIconViewItem<String>(
                  value: 'Object',
                  label: 'Object',
                  icon: BlenderIcon(BlenderGlyph.object, size: 30),
                ),
                BlenderIconViewItem<String>(
                  value: 'Collection',
                  label: 'Collection',
                  icon: BlenderIcon(BlenderGlyph.collection, size: 30),
                ),
              ],
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Object'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Object'));
    await tester.pumpAndSettle();
    expect(find.text('Collection'), findsOneWidget);
    await tester.tap(find.text('Collection'));
    await tester.pumpAndSettle();
    expect(selected, 'Collection');
    expect(find.text('Collection'), findsNothing);
  });

  testWidgets('preview panel renders Blender preview controls', (tester) async {
    var mode = 'Material';
    var world = false;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 640,
          height: 360,
          child: BlenderPreviewPanel(
            preview: const ColoredBox(
              color: Color(0xFF202020),
              child: Center(child: BlenderIcon(BlenderGlyph.material)),
            ),
            previewModes: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Material', label: 'Material'),
              BlenderMenuItem<String>(value: 'World', label: 'World'),
            ],
            previewMode: mode,
            onPreviewModeChanged: (value) => mode = value,
            usePreviewWorld: world,
            onUsePreviewWorldChanged: (value) => world = value,
            textureModes: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Texture', label: 'Texture'),
              BlenderMenuItem<String>(value: 'Material', label: 'Material'),
              BlenderMenuItem<String>(value: 'Both', label: 'Both'),
            ],
            textureMode: 'Both',
            onTextureModeChanged: (_) {},
            onUsePreviewAlphaChanged: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Preview'), findsOneWidget);
    expect(find.text('Use Preview World'), findsOneWidget);
    expect(find.text('Use Preview Alpha'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.dragHandle,
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('World'));
    expect(mode, 'World');
    await tester.tap(find.text('Use Preview World'));
    expect(world, isTrue);
  });

  testWidgets('report banner preserves severity and Info activation', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 520,
          child: BlenderReportBanner(
            message: 'Preview finished',
            level: BlenderNoticeLevel.success,
            onPressed: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('Preview finished'), findsOneWidget);
    await tester.tap(find.text('Preview finished'));
    expect(opened, isTrue);
  });

  testWidgets('status info preserves version, extension, and warning states', (
    tester,
  ) async {
    var extensionsOpened = false;
    var warningOpened = false;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 760,
          child: BlenderStatusInfo(
            statusText: 'Scene 1',
            versionText: 'Blender 4.5.0',
            extensionStatus: BlenderExtensionStatus.updates,
            extensionCount: 3,
            onExtensionPressed: () => extensionsOpened = true,
            warningMessage: 'Color Management',
            onWarningPressed: () => warningOpened = true,
          ),
        ),
      ),
    );

    expect(find.text('Scene 1'), findsOneWidget);
    expect(find.text('Blender 4.5.0'), findsOneWidget);
    expect(find.text('Color Management'), findsOneWidget);
    expect(find.bySemanticsLabel('Extension updates'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Extension updates'));
    await tester.tap(find.text('Color Management'));
    expect(extensionsOpened, isTrue);
    expect(warningOpened, isTrue);
  });

  testWidgets(
    'file browser side panels preserve execution and catalog anatomy',
    (tester) async {
      final filename = TextEditingController(text: 'scene.blend');
      addTearDown(filename.dispose);
      var executed = false;
      BlenderTreeNode<String>? newCatalogParent;
      await tester.pumpWidget(
        _harness(
          SizedBox(
            width: 560,
            height: 520,
            child: Column(
              children: <Widget>[
                BlenderFileOperatorPanel(
                  operatorName: 'Open Blender File',
                  properties: <BlenderPropertyDescriptor<dynamic>>[
                    BlenderPropertyDescriptor<bool>(
                      id: 'relative',
                      label: 'Relative Path',
                      value: true,
                      editorBuilder: (context, value, onChanged) =>
                          BlenderCheckbox(
                            value: value,
                            label: '',
                            onChanged: onChanged,
                          ),
                    ),
                  ],
                ),
                BlenderFileExecutionPanel(
                  filenameController: filename,
                  overwriteAlert: true,
                  onExecute: () => executed = true,
                  onCancel: () {},
                  onIncrement: () {},
                ),
                Expanded(
                  child: BlenderFileAssetCatalogPanel(
                    libraryValue: 'Local',
                    libraryItems: const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Local', label: 'Local'),
                    ],
                    catalogRoots: const <BlenderTreeNode<String>>[
                      BlenderTreeNode<String>(
                        id: 'root',
                        label: 'Environment',
                        initiallyExpanded: true,
                        children: <BlenderTreeNode<String>>[
                          BlenderTreeNode<String>(
                            id: 'studio',
                            label: 'Studio Lighting',
                            value: 'studio',
                          ),
                        ],
                      ),
                    ],
                    onNewCatalog: (node) => newCatalogParent = node,
                    onCatalogContextMenuSelected: (node, action) {
                      if (action == 'rename') newCatalogParent = node;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('scene.blend'), findsOneWidget);
      expect(find.text('Open Blender File'), findsOneWidget);
      expect(find.text('Relative Path'), findsOneWidget);
      expect(find.text('Overwrite'), findsOneWidget);
      expect(find.text('Asset Catalogs'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Unassigned'), findsOneWidget);
      expect(find.text('Environment'), findsOneWidget);
      expect(find.text('Studio Lighting'), findsOneWidget);
      await tester.tap(find.text('Overwrite'));
      expect(executed, isTrue);
      expect(newCatalogParent, isNull);
    },
  );

  testWidgets('asset-library preferences preserve built-in and remote states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 720,
          height: 460,
          child: BlenderAssetLibrariesPreferencesPanel(
            selectedId: 'local',
            libraries: const <BlenderAssetLibraryPreference>[
              BlenderAssetLibraryPreference(
                id: 'all',
                name: 'All',
                builtIn: true,
              ),
              BlenderAssetLibraryPreference(
                id: 'essentials',
                name: 'Essentials',
                builtIn: true,
                isEssentials: true,
                includeOnlineEssentials: true,
              ),
              BlenderAssetLibraryPreference(
                id: 'local',
                name: 'Studio Assets',
                path: '/assets',
              ),
              BlenderAssetLibraryPreference(
                id: 'remote',
                name: 'Remote Repository',
                isRemote: true,
                remoteUrl: 'https://assets.example.test',
                invalid: true,
              ),
            ],
            onEnabledChanged: (_, __) {},
          ),
        ),
      ),
    );

    expect(find.text('Asset Libraries'), findsOneWidget);
    expect(find.text('Built-In'), findsNWidgets(2));
    expect(find.text('Studio Assets'), findsOneWidget);
    expect(find.text('Remote Repository'), findsOneWidget);
    expect(find.byType(BlenderCheckbox), findsNWidgets(3));
    expect(find.bySemanticsLabel('Path'), findsOneWidget);
    expect(find.text('Link'), findsOneWidget);
    expect(find.text('Default Import Method'), findsOneWidget);
    expect(find.text('Relative Path'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is BlenderIcon && widget.glyph == BlenderGlyph.error,
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'texture user selector preserves source and Properties jump states',
    (tester) async {
      BlenderTextureUser? selected;
      var shown = false;
      await tester.pumpWidget(
        _harness(
          SizedBox(
            width: 520,
            child: BlenderTextureUserSelector(
              selectedId: 'base',
              users: const <BlenderTextureUser>[
                BlenderTextureUser(
                  id: 'base',
                  name: 'Base Color',
                  textureName: 'Noise Texture',
                  category: 'Material',
                ),
                BlenderTextureUser(
                  id: 'roughness',
                  name: 'Roughness',
                  textureName: 'Musgrave',
                  category: 'Material',
                ),
              ],
              onChanged: (user) => selected = user,
              onShowTexture: () => shown = true,
            ),
          ),
        ),
      );

      expect(find.text('Base Color - Noise Texture'), findsOneWidget);
      final dropdown = tester.widget<BlenderDropdown<String>>(
        find.byType(BlenderDropdown<String>),
      );
      expect(dropdown.items.first.label, 'Material');
      expect(dropdown.items.first.enabled, isFalse);
      expect(
        find.bySemanticsLabel('Show texture in Texture tab'),
        findsOneWidget,
      );
      await tester.tap(find.bySemanticsLabel('Show texture in Texture tab'));
      expect(shown, isTrue);
      expect(selected, isNull);
    },
  );

  testWidgets('input status rows preserve event and warning variants', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 640,
          child: BlenderInputStatus(
            items: <BlenderInputStatusItem>[
              BlenderInputStatusItem(event: 'LMB drag', label: 'Split/Dock'),
              BlenderInputStatusItem(
                modifiers: <String>['Shift'],
                event: 'LMB drag',
                label: 'Duplicate into Window',
              ),
              BlenderInputStatusItem(
                events: <String>['X', 'Y', 'Z'],
                label: 'Axis',
              ),
              BlenderInputStatusItem(
                label: 'Active object has non-uniform scale',
                icon: BlenderGlyph.warning,
                warning: true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Split/Dock'), findsOneWidget);
    expect(find.text('Duplicate into Window'), findsOneWidget);
    expect(find.text('Axis'), findsOneWidget);
    expect(find.text('Active object has non-uniform scale'), findsOneWidget);
    expect(find.text('Shift'), findsOneWidget);
    expect(find.text('X'), findsOneWidget);
    expect(find.text('Y'), findsOneWidget);
    expect(find.text('Z'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.warning,
      ),
      findsOneWidget,
    );
  });

  testWidgets('status context preserves Blender runtime hint variants', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 720,
          child: Column(
            children: <Widget>[
              BlenderStatusContextBar(kind: BlenderStatusContextKind.splitDock),
              BlenderStatusContextBar(
                kind: BlenderStatusContextKind.resizeRegion,
                regionVisible: false,
              ),
              BlenderStatusContextBar(
                kind: BlenderStatusContextKind.editorBorder,
              ),
              BlenderStatusContextBar(
                kind: BlenderStatusContextKind.viewportWarning,
                warningText: 'Active object has non-uniform scale',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Split/Dock'), findsOneWidget);
    expect(find.text('Duplicate into Window'), findsOneWidget);
    expect(find.text('Swap Areas'), findsOneWidget);
    expect(find.text('Show Hidden Region'), findsOneWidget);
    expect(find.text('Resize'), findsOneWidget);
    expect(find.text('Options'), findsOneWidget);
    expect(find.text('Active object has non-uniform scale'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.mouseLeftDrag,
      ),
      findsWidgets,
    );
  });

  testWidgets('bone, component, and compact-list templates preserve variants', (
    tester,
  ) async {
    var component = 'XYZ';
    var index = 0;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 640,
          height: 420,
          child: Column(
            children: <Widget>[
              const BlenderBoneCollectionTree(
                collections: const <BlenderBoneCollection>[
                  BlenderBoneCollection(
                    id: 'rig',
                    name: 'Rig',
                    active: true,
                    children: <BlenderBoneCollection>[
                      BlenderBoneCollection(
                        id: 'deform',
                        name: 'Deform',
                        hasSelectedBones: true,
                      ),
                    ],
                  ),
                ],
              ),
              BlenderComponentMenu<String>(
                value: component,
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'XYZ', label: 'XYZ'),
                  BlenderMenuItem<String>(value: 'UV', label: 'UV'),
                ],
                onChanged: (value) => component = value,
              ),
              BlenderCompactList<String>(
                selectedIndex: index,
                onChanged: (value) => index = value,
                items: const <BlenderListItem<String>>[
                  BlenderListItem<String>(id: 'a', label: 'First'),
                  BlenderListItem<String>(id: 'b', label: 'Second'),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Rig'), findsOneWidget);
    expect(find.text('Deform'), findsOneWidget);
    await tester.tap(find.text('UV'));
    expect(component, 'UV');
    await tester.tap(find.bySemanticsLabel('Next list item'));
    expect(index, 1);
  });

  testWidgets('asset shelf popover opens as a Blender scaled shelf', (
    tester,
  ) async {
    BlenderAssetShelfPopoverItem? selected;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 420,
            height: 300,
            child: BlenderAssetShelfPopover(
              label: 'Asset Shelf',
              big: true,
              assets: const <BlenderAssetShelfPopoverItem>[
                BlenderAssetShelfPopoverItem(id: 'cube', label: 'Cube'),
              ],
              onSelected: (asset) => selected = asset,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Asset Shelf'), warnIfMissed: false);
    await tester.pump();
    expect(find.text('Cube'), findsOneWidget);
    await tester.tap(find.text('Cube'));
    await tester.pumpAndSettle();
    expect(selected?.id, 'cube');
  });
}

void _ignoreDouble(double value) {}

void _ignoreString(String value) {}

void _ignoreBool(bool value) {}

void _ignoreInt(int value) {}

void _ignoreMenuItem(BlenderMenuItem<String> item) {}

void _ignoreVoid() {}

void _ignoreOffset(Offset value) {}

void _ignoreMatrix(List<List<double>> value) {}
