part of '../blender_ui_test.dart';

void registerColorPickerEmitsAChangedColorTests() {
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

  testWidgets('tree activates a row on a second click', (tester) async {
    BlenderTreeNode<String>? activated;
    const roots = <BlenderTreeNode<String>>[
      BlenderTreeNode<String>(id: 'cube', label: 'Cube', value: 'cube'),
    ];
    await tester.pumpWidget(
      _harness(
        SizedBox(
          height: 100,
          child: BlenderTree<String>(
            roots: roots,
            onActivated: (node) => activated = node,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Cube'));
    await tester.tap(find.text('Cube'));
    await tester.pump();

    expect(activated?.id, 'cube');
  });

  testWidgets('tree labels and disclosures share the optical row center', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          height: 80,
          child: BlenderTree<String>(
            roots: <BlenderTreeNode<String>>[
              BlenderTreeNode<String>(
                id: 'collection',
                label: 'Collection',
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(id: 'child', label: 'Child'),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final row = tester.getCenter(
      find.byKey(const ValueKey<String>('tree-row-collection')),
    );
    final label = tester.getCenter(
      find.byKey(const ValueKey<String>('tree-label-collection')),
    );
    final disclosure = tester.getCenter(
      find.byKey(const ValueKey<String>('tree-disclosure-collection')),
    );
    expect(label.dy, closeTo(row.dy + 1, 0.1));
    expect(disclosure.dy, closeTo(row.dy + 1, 0.1));
  });

  testWidgets('tree disclosures use Blender thin arrow glyphs', (tester) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          height: 100,
          child: BlenderTree<String>(
            roots: <BlenderTreeNode<String>>[
              BlenderTreeNode<String>(
                id: 'collection',
                label: 'Collection',
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(id: 'cube', label: 'Cube'),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final disclosure = tester.widget<BlenderIcon>(
      find.byKey(const ValueKey<String>('tree-disclosure-collection')),
    );
    expect(disclosure.glyph, BlenderGlyph.panelDisclosureDown);
    expect(disclosure.size, 9);
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

    expect(find.text('Summary'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('timeline-window-region')),
      findsOneWidget,
    );
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

  testWidgets('template list preserves filter disclosure and sort controls', (
    tester,
  ) async {
    final filter = TextEditingController();
    addTearDown(filter.dispose);
    var inverted = false;
    var sorted = false;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 420,
          height: 260,
          child: BlenderTemplateList<String>(
            items: const <BlenderListItem<String>>[
              BlenderListItem<String>(id: 'one', label: 'First Item'),
              BlenderListItem<String>(id: 'two', label: 'Second Item'),
            ],
            filterController: filter,
            initiallyFilterExpanded: true,
            onInvertFilter: () => inverted = true,
            onSortAlphabetically: () => sorted = true,
          ),
        ),
      ),
    );

    expect(find.text('First Item'), findsOneWidget);
    expect(find.bySemanticsLabel('Invert Filter'), findsOneWidget);
    expect(find.bySemanticsLabel('Sort Alphabetically'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Invert Filter'));
    await tester.tap(find.bySemanticsLabel('Sort Alphabetically'));
    expect(inverted, isTrue);
    expect(sorted, isTrue);
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

  testWidgets('matrix transform panel preserves decomposition rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 360,
          height: 500,
          child: BlenderMatrixTransformPanel(
            values: const BlenderMatrixTransformValues(
              location: <double>[1, 2, 3],
              rotation: <double>[0, 45, 90],
              scale: <double>[1, 1, 1],
              hasShear: true,
            ),
            onRotationModeChanged: _ignoreString,
          ),
        ),
      ),
    );

    expect(find.text('Matrix has a shear'), findsOneWidget);
    expect(find.text('Location X'), findsOneWidget);
    expect(find.text('Rotation X'), findsOneWidget);
    expect(find.text('Scale X'), findsOneWidget);
    expect(find.text('XYZ Euler'), findsOneWidget);
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
              BlenderRecentFile(
                id: 'backup',
                name: 'showcase.blend1',
                path: '/showcase/showcase.blend1',
                isBackup: true,
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
    expect(find.text('/showcase/showcase.blend'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.fileBlend,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.fileBackup,
      ),
      findsOneWidget,
    );
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
}
