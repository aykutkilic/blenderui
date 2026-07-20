import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const nodeModel = BlenderNodeGraphModel(
    nodes: <BlenderGraphNode>[
      BlenderGraphNode(
        id: 'input',
        title: 'Group Input',
        position: Offset(110, 130),
        outputs: <BlenderNodeSocketDefinition>[
          BlenderNodeSocketDefinition(
            id: 'geometry',
            label: 'Geometry',
            dataType: BlenderNodeSocketDataType.geometry,
          ),
        ],
      ),
      BlenderGraphNode(
        id: 'output',
        title: 'Group Output',
        position: Offset(440, 220),
        inputs: <BlenderNodeSocketDefinition>[
          BlenderNodeSocketDefinition(
            id: 'geometry',
            label: 'Geometry',
            dataType: BlenderNodeSocketDataType.geometry,
          ),
        ],
      ),
    ],
    links: <BlenderGraphLink>[
      BlenderGraphLink(
        from: 'input',
        to: 'output',
        fromSocket: 'geometry',
        toSocket: 'geometry',
      ),
    ],
  );
  const fileEntries = <BlenderFileEntry>[
    BlenderFileEntry(path: '/scenes', name: 'scenes', isDirectory: true),
    BlenderFileEntry(
      path: '/cube.blend',
      name: 'cube.blend',
      modifiedLabel: '20 Jul 2026',
      sizeLabel: '1.2 MB',
      sizeBytes: 1200000,
      typeLabel: 'Blender',
    ),
    BlenderFileEntry(
      path: '/reference.png',
      name: 'reference.png',
      modifiedLabel: '19 Jul 2026',
      sizeLabel: '840 KB',
      sizeBytes: 840000,
      typeLabel: 'Image',
    ),
  ];

  Future<void> reference(
    WidgetTester tester,
    String name,
    Widget header,
    Widget body,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final key = ValueKey<String>('reference-$name');
    await tester.pumpWidget(
      BlenderApp(
        home: RepaintBoundary(
          key: key,
          child: Column(
            children: <Widget>[
              header,
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byKey(key),
      matchesGoldenFile('goldens/${name}_editor_reference.png'),
    );
  }

  Widget nodeHeader(BlenderEditorType type) => BlenderNodeEditorHeader(
    editorType: type,
    treeContext: 'Object',
    dataBlock: 'NodeTree',
  );

  Widget nodeBody({bool geometry = false, bool compositor = false}) =>
      BlenderNodeEditor(
        title: null,
        model: nodeModel,
        sidebar: BlenderNodeEditorSidebar(
          geometryNodeEditor: geometry,
          compositor: compositor,
          activeNode: nodeModel.nodes.first,
        ),
      );

  for (final entry in <(String, BlenderEditorType, bool, bool)>[
    ('shader', BlenderEditorType.shaderEditor, false, false),
    ('geometry_nodes', BlenderEditorType.geometryNodeEditor, true, false),
    ('compositor', BlenderEditorType.compositor, false, true),
    ('texture_nodes', BlenderEditorType.textureNodeEditor, false, false),
  ]) {
    testWidgets('${entry.$1} rendered reference', (tester) async {
      await reference(
        tester,
        entry.$1,
        nodeHeader(entry.$2),
        nodeBody(geometry: entry.$3, compositor: entry.$4),
      );
    });
  }

  testWidgets('3D Viewport rendered reference', (tester) async {
    final controller = BlenderViewportController();
    addTearDown(controller.dispose);
    await reference(
      tester,
      'view3d',
      const BlenderView3dEditorHeader(),
      BlenderViewportShell(
        controller: controller,
        sceneBuilder: (context, state) => const ColoredBox(
          color: Color(0xFF383838),
          child: Center(child: BlenderIcon(BlenderGlyph.cube, size: 96)),
        ),
        gizmoBuilder: (context, state) =>
            BlenderViewportOrientationGizmo(yaw: state.yaw, pitch: state.pitch),
        sidebar: const BlenderViewportSidebar(),
      ),
    );
  });

  testWidgets('Text Editor rendered reference', (tester) async {
    await reference(
      tester,
      'text',
      const BlenderUtilityEditorHeader(
        editorType: BlenderEditorType.textEditor,
      ),
      const BlenderTextEditor(
        title: null,
        text: 'import bpy\n\nprint(bpy.context.scene.name)',
        sidebar: BlenderTextEditorSidebar(),
        footer: BlenderTextEditorFooter(line: 3, column: 30),
      ),
    );
  });

  testWidgets('Python Console rendered reference', (tester) async {
    await reference(
      tester,
      'console',
      const BlenderUtilityEditorHeader(
        editorType: BlenderEditorType.pythonConsole,
      ),
      const BlenderConsoleEditor(
        title: null,
        lines: <BlenderConsoleLine>[
          BlenderConsoleLine(
            'PYTHON INTERACTIVE CONSOLE',
            kind: BlenderConsoleLineKind.info,
          ),
          BlenderConsoleLine(
            '>>> bpy.context.scene',
            kind: BlenderConsoleLineKind.input,
          ),
          BlenderConsoleLine('<bpy_struct, Scene("Scene")>'),
        ],
      ),
    );
  });

  testWidgets('Info Editor rendered reference', (tester) async {
    await reference(
      tester,
      'info',
      const BlenderUtilityEditorHeader(
        editorType: BlenderEditorType.infoEditor,
      ),
      const BlenderInfoEditor(
        title: null,
        selectedIds: <String>{'saved'},
        reports: <BlenderInfoReport>[
          BlenderInfoReport(
            id: 'saved',
            message: 'Saved "scene.blend"',
            timestamp: '12:42',
          ),
          BlenderInfoReport(
            id: 'warning',
            message: 'Missing texture',
            level: BlenderNoticeLevel.warning,
          ),
        ],
      ),
    );
  });

  testWidgets('Outliner rendered reference', (tester) async {
    await reference(
      tester,
      'outliner',
      const SizedBox.shrink(),
      const BlenderOutliner<String>(
        selectedIds: <String>{'cube'},
        showVisibility: true,
        showLock: true,
        roots: <BlenderTreeNode<String>>[
          BlenderTreeNode<String>(
            id: 'scene',
            label: 'Scene Collection',
            initiallyExpanded: true,
            children: <BlenderTreeNode<String>>[
              BlenderTreeNode<String>(id: 'cube', label: 'Cube'),
              BlenderTreeNode<String>(id: 'camera', label: 'Camera'),
              BlenderTreeNode<String>(id: 'light', label: 'Light'),
            ],
          ),
        ],
      ),
    );
  });

  testWidgets('Properties Editor rendered reference', (tester) async {
    await reference(
      tester,
      'properties',
      const BlenderUtilityEditorHeader(
        editorType: BlenderEditorType.properties,
      ),
      const BlenderPropertiesEditor(
        groups: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'transform',
            title: 'Transform',
            properties: <BlenderPropertyDescriptor<dynamic>>[],
            content: Column(
              children: <Widget>[
                BlenderNumberField(
                  value: 0,
                  label: 'Location X',
                  onChanged: _noopDouble,
                ),
                BlenderNumberField(
                  value: 0,
                  label: 'Location Y',
                  onChanged: _noopDouble,
                ),
                BlenderNumberField(
                  value: 1,
                  label: 'Scale',
                  onChanged: _noopDouble,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  });

  testWidgets('File Browser rendered reference', (tester) async {
    await reference(
      tester,
      'file_browser',
      const BlenderUtilityEditorHeader(
        editorType: BlenderEditorType.fileBrowser,
      ),
      const BlenderFileBrowser(
        title: null,
        entries: fileEntries,
        pathSegments: <String>['/', 'projects'],
        sidebar: BlenderFileBrowserSidebar(),
      ),
    );
  });

  testWidgets('Asset Browser rendered reference', (tester) async {
    await reference(
      tester,
      'asset_browser',
      const BlenderUtilityEditorHeader(
        editorType: BlenderEditorType.assetBrowser,
      ),
      BlenderFileBrowser(
        title: null,
        entries: fileEntries,
        gridView: true,
        assetBrowser: true,
        pathSegments: const <String>['/', 'assets'],
        sidebar: const BlenderFileBrowserSidebar(assetBrowser: true),
        previewBuilder: (context, entry) => ColoredBox(
          color: const Color(0xFF4A4A4A),
          child: Center(child: Text(entry.typeLabel ?? 'Folder')),
        ),
      ),
    );
  });

  testWidgets('Spreadsheet rendered reference', (tester) async {
    await reference(
      tester,
      'spreadsheet',
      const BlenderSpreadsheetEditorHeader(),
      const BlenderSpreadsheetEditor(
        title: null,
        columns: <BlenderSpreadsheetColumn>[
          BlenderSpreadsheetColumn(
            id: 'position',
            label: 'Position',
            width: 260,
          ),
          BlenderSpreadsheetColumn(
            id: 'radius',
            label: 'Radius',
            numeric: true,
          ),
          BlenderSpreadsheetColumn(id: 'id', label: 'ID', numeric: true),
        ],
        rows: <BlenderSpreadsheetRow>[
          BlenderSpreadsheetRow(
            id: '0',
            values: <String>['(0.0, 0.0, 0.0)', '1.0', '0'],
            selected: true,
          ),
          BlenderSpreadsheetRow(
            id: '1',
            values: <String>['(1.0, 0.0, 0.0)', '1.0', '1'],
          ),
          BlenderSpreadsheetRow(
            id: '2',
            values: <String>['(1.0, 1.0, 0.0)', '1.0', '2'],
          ),
        ],
      ),
    );
  });

  testWidgets('Preferences rendered reference', (tester) async {
    await reference(
      tester,
      'preferences',
      const BlenderUtilityEditorHeader(
        editorType: BlenderEditorType.preferences,
      ),
      const BlenderPreferencesEditor(
        categories: <String>['Interface', 'Themes', 'Input', 'Add-ons'],
        selectedCategory: 'Interface',
        sections: <BlenderPreferenceSection>[
          BlenderPreferenceSection(
            id: 'display',
            category: 'Interface',
            title: 'Display',
            child: Column(
              children: <Widget>[
                BlenderCheckbox(
                  value: true,
                  label: 'Tooltips',
                  onChanged: _noopBool,
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Developer Extras',
                  onChanged: _noopBool,
                ),
              ],
            ),
          ),
          BlenderPreferenceSection(
            id: 'editors',
            category: 'Interface',
            title: 'Editors',
            child: Text('Region overlap and navigation controls'),
          ),
        ],
      ),
    );
  });
}

void _noopDouble(double _) {}
void _noopBool(bool _) {}
