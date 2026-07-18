part of '../blender_ui_test.dart';

void registerOperatorRedoAndPropertyDialogPreservePopupTests() {
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
    final cancelButton = find.ancestor(
      of: find.text('Cancel'),
      matching: find.byType(BlenderButton),
    );
    final applyButton = find.ancestor(
      of: find.text('Apply'),
      matching: find.byType(BlenderButton),
    );
    expect(cancelButton, findsOneWidget);
    expect(applyButton, findsOneWidget);
    expect(
      tester.getRect(cancelButton).width,
      closeTo(tester.getRect(applyButton).width, 0.1),
    );
    expect(
      tester.getRect(cancelButton).left,
      lessThan(tester.getRect(applyButton).left),
    );
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

  testWidgets('cache file time rows preserve source conditional states', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 560,
          height: 520,
          child: BlenderCacheFilePanel(
            settings: const BlenderCacheFileSettings(
              path: '/cache/scene.abc',
              isSequence: true,
            ),
            onChanged: _ignoreCacheFileSettings,
          ),
        ),
      ),
    );

    expect(find.text('Filepath'), findsOneWidget);
    expect(find.text('Override Frame'), findsOneWidget);
    expect(find.text('Frame Offset'), findsOneWidget);
    final numberFields = tester
        .widgetList<BlenderNumberField>(find.byType(BlenderNumberField))
        .toList();
    expect(
      numberFields.any((field) => field.value == 1 && !field.enabled),
      isTrue,
    );
    expect(
      numberFields.any((field) => field.value == 0 && !field.enabled),
      isTrue,
    );
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
}
