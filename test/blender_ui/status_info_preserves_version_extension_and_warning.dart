part of '../blender_ui_test.dart';

void registerStatusInfoPreservesVersionExtensionAndWarningTests() {
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
            extensionStatus: BlenderExtensionStatus.blocked,
            extensionCount: 3,
            onExtensionPressed: () => extensionsOpened = true,
            newerBlenderVersion: 'Blender 4.6.0',
            assetEditFile: true,
            missingColorManagement: true,
            onWarningPressed: () => warningOpened = true,
          ),
        ),
      ),
    );

    expect(find.text('Scene 1'), findsOneWidget);
    expect(find.text('Blender 4.5.0'), findsNothing);
    expect(find.bySemanticsLabel('Extensions blocked'), findsOneWidget);
    expect(find.text('Blender 4.6.0 Color Management'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderTooltip && widget.message.contains('asset system'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.bySemanticsLabel('Extensions blocked'));
    await tester.tap(find.text('Blender 4.6.0 Color Management'));
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

  testWidgets('file browser hints preserve asset availability cards', (
    tester,
  ) async {
    var allowed = false;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 520,
          height: 280,
          child: BlenderFileBrowserHint(
            title: 'Internet Access Required',
            icon: BlenderGlyph.internetOffline,
            message: 'Allow Online Access to browse online assets.',
            actions: <BlenderFileBrowserHintAction>[
              const BlenderFileBrowserHintAction(
                label: 'Continue Offline',
                icon: BlenderGlyph.close,
              ),
              BlenderFileBrowserHintAction(
                label: 'Allow Online Access',
                icon: BlenderGlyph.check,
                onPressed: () => allowed = true,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Internet Access Required'), findsOneWidget);
    expect(find.text('Continue Offline'), findsOneWidget);
    await tester.tap(find.text('Allow Online Access'));
    expect(allowed, isTrue);
  });

  testWidgets('invalid asset library path hint preserves Preferences action', (
    tester,
  ) async {
    var opened = false;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 520,
          height: 280,
          child: BlenderFileBrowserLibraryPathHint(
            title: 'Path to asset library does not exist:',
            path: '/assets/missing',
            message: 'Manage Asset Libraries from Preferences.',
            onOpenPreferences: () => opened = true,
          ),
        ),
      ),
    );

    expect(find.text('/assets/missing'), findsOneWidget);
    expect(
      find.text('Manage Asset Libraries from Preferences.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Open Preferences'));
    expect(opened, isTrue);
  });

  testWidgets('unreadable library hint preserves path and report severity', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 520,
          height: 220,
          child: BlenderFileBrowserUnreadableLibraryHint(
            path: '/assets/library.blend',
            reports: const <BlenderFileBrowserReport>[
              BlenderFileBrowserReport(
                message: 'The library could not be read.',
                level: BlenderNoticeLevel.error,
              ),
              BlenderFileBrowserReport(message: 'Try another file.'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Unreadable Blender library file:'), findsOneWidget);
    expect(find.text('/assets/library.blend'), findsOneWidget);
    expect(find.text('The library could not be read.'), findsOneWidget);
    expect(find.text('Try another file.'), findsOneWidget);
  });

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
    expect(find.text('Import Method'), findsOneWidget);
    expect(find.text('Use Relative Path'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.errorFilled,
      ),
      findsOneWidget,
    );

    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 720,
          height: 460,
          child: BlenderAssetLibrariesPreferencesPanel(
            selectedId: 'remote',
            libraries: const <BlenderAssetLibraryPreference>[
              BlenderAssetLibraryPreference(
                id: 'remote',
                name: 'Remote Repository',
                isRemote: true,
                remoteUrl: 'https://assets.example.test',
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.bySemanticsLabel('Repository URL'), findsOneWidget);
    expect(find.text('Use Relative Path'), findsNothing);
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

      expect(find.text('Base Color'), findsOneWidget);
      final dropdown = tester.widget<BlenderDropdown<String>>(
        find.byType(BlenderDropdown<String>),
      );
      expect(dropdown.items.first.label, 'Material');
      expect(dropdown.items.first.enabled, isFalse);
      expect(dropdown.items[1].label, 'Base Color - Noise Texture');
      expect(
        find.bySemanticsLabel('Show texture in Texture tab'),
        findsOneWidget,
      );
      await tester.tap(find.bySemanticsLabel('Show texture in Texture tab'));
      expect(shown, isTrue);
      expect(selected, isNull);

      await tester.pumpWidget(
        _harness(
          SizedBox(
            width: 520,
            child: BlenderTextureUserSelector(
              users: const <BlenderTextureUser>[
                BlenderTextureUser(id: 'base', name: 'Base Color'),
              ],
              hasTexture: false,
              onShowTexture: () {},
            ),
          ),
        ),
      );
      expect(find.byType(BlenderIconButton), findsNothing);

      await tester.pumpWidget(
        _harness(
          SizedBox(
            width: 520,
            child: BlenderTextureUserSelector(
              users: const <BlenderTextureUser>[
                BlenderTextureUser(id: 'base', name: 'Base Color'),
              ],
              showTextureEnabled: false,
              showTextureDisabledTooltip: 'No texture user found',
              onShowTexture: () {},
            ),
          ),
        ),
      );
      expect(find.bySemanticsLabel('No texture user found'), findsOneWidget);
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
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.keyShift,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.keyControl,
      ),
      findsOneWidget,
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
