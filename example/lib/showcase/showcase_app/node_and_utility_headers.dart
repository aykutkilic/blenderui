part of '../showcase_app.dart';

extension _ShowcaseNodeUtilityHeaders on _ShowcaseAppState {
  BlenderAreaHeader _buildNodeEditorHeader(BlenderEditorType type) {
    final shader = type == BlenderEditorType.shaderEditor;
    final geometry = type == BlenderEditorType.geometryNodeEditor;
    final compositor = type == BlenderEditorType.compositor;
    final texture = type == BlenderEditorType.textureNodeEditor;
    final contextItems = shader
        ? const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Object', label: 'Object'),
            BlenderMenuItem<String>(value: 'World', label: 'World'),
            BlenderMenuItem<String>(value: 'Line Style', label: 'Line Style'),
          ]
        : geometry
        ? const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Modifier', label: 'Modifier'),
            BlenderMenuItem<String>(value: 'Tool', label: 'Tool'),
          ]
        : compositor
        ? const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
            BlenderMenuItem<String>(value: 'Sequencer', label: 'Sequencer'),
          ]
        : texture
        ? const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Brush', label: 'Brush'),
            BlenderMenuItem<String>(value: 'Image', label: 'Image'),
          ]
        : const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Tree Type', label: 'Tree Type'),
          ];
    final contextValue =
        contextItems.any((item) => item.value == _nodeTreeContext)
        ? _nodeTreeContext
        : contextItems.first.value;
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: _mainEditorArea.select,
      leading: <Widget>[
        SizedBox(
          width: 92,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('node-tree-context'),
            value: contextValue,
            items: contextItems,
            onChanged: (value) => _update(() => _nodeTreeContext = value),
          ),
        ),
      ],
      menuDescriptors: _editorMenuDescriptors(
        const <String>['View', 'Select', 'Add', 'Node'],
        menuItems: <String, List<String>>{
          'View': _nodeViewMenuItems(
            compositor: compositor,
          ).map((item) => item.label).toList(),
          'Select': _nodeSelectMenuItems().map((item) => item.label).toList(),
          'Add': _nodeAddMenuItems(type).map((item) => item.label).toList(),
          'Node': _nodeNodeMenuItems(
            compositor: compositor,
          ).map((item) => item.label).toList(),
        },
        menuDescriptors: <String, List<BlenderMenuItem<String>>>{
          'View': _nodeViewMenuItems(compositor: compositor),
          'Select': _nodeSelectMenuItems(),
          'Add': _nodeAddMenuItems(type),
          'Node': _nodeNodeMenuItems(compositor: compositor),
        },
      ),
      actions: <Widget>[
        SizedBox(
          width: 112,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('node-tree-datablock'),
            value: geometry
                ? (_nodeTreeContext == 'Tool' ? 'Tool Group' : 'Modifier Group')
                : compositor
                ? (_nodeTreeContext == 'Sequencer'
                      ? 'Compositor Strip'
                      : 'Scene Nodes')
                : texture
                ? 'Texture Nodes'
                : 'Material Nodes',
            compact: true,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Material Nodes',
                label: 'Material Nodes',
              ),
              BlenderMenuItem<String>(
                value: 'Scene Nodes',
                label: 'Scene Nodes',
              ),
              BlenderMenuItem<String>(
                value: 'Modifier Group',
                label: 'Modifier Group',
              ),
              BlenderMenuItem<String>(value: 'Tool Group', label: 'Tool Group'),
              BlenderMenuItem<String>(
                value: 'Texture Nodes',
                label: 'Texture Nodes',
              ),
              BlenderMenuItem<String>(
                value: 'Compositor Strip',
                label: 'Compositor Strip',
              ),
            ],
            onChanged: (value) => _setStatus('Node tree: $value'),
          ),
        ),
        const BlenderIconButton(
          key: const ValueKey<String>('node-pin-button'),
          glyph: BlenderGlyph.pin,
          tooltip: 'Pin node tree',
        ),
        if (compositor) ...<Widget>[
          BlenderIconButton(
            key: const ValueKey<String>('node-backdrop-button'),
            glyph: BlenderGlyph.eye,
            selected: _nodeShowBackdrop,
            onPressed: () =>
                _update(() => _nodeShowBackdrop = !_nodeShowBackdrop),
            tooltip: 'Show backdrop',
          ),
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('node-gizmo-button'),
              glyph: BlenderGlyph.gizmo,
              selected: _nodeGizmos,
              tooltip: 'Node gizmos',
            ),
            popover: (context, close) => _buildNodeGizmoPopover(),
          ),
        ],
        BlenderIconButton(
          key: const ValueKey<String>('node-snap-button'),
          glyph: BlenderGlyph.snap,
          selected: _nodeSnap,
          onPressed: () => _update(() => _nodeSnap = !_nodeSnap),
          tooltip: 'Snap to grid',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('node-overlay-button'),
            glyph: BlenderGlyph.overlay,
            selected: _nodeOverlays,
            tooltip: 'Node editor overlays',
          ),
          popover: (context, close) => _buildNodeOverlayPopover(type: type),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  List<BlenderMenuItem<String>> _nodeViewMenuItems({
    required bool compositor,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(value: 'Toolbar', label: 'Toolbar'),
    const BlenderMenuItem<String>(value: 'Sidebar', label: 'Sidebar'),
    if (compositor)
      const BlenderMenuItem<String>(value: 'Asset Shelf', label: 'Asset Shelf'),
    const BlenderMenuItem<String>(value: 'Zoom In', label: 'Zoom In'),
    const BlenderMenuItem<String>(value: 'Zoom Out', label: 'Zoom Out'),
    const BlenderMenuItem<String>(
      value: 'Frame Selected',
      label: 'Frame Selected',
    ),
    const BlenderMenuItem<String>(value: 'Frame All', label: 'Frame All'),
    if (compositor) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Backdrop Move',
        label: 'Backdrop Move',
      ),
      const BlenderMenuItem<String>(
        value: 'Backdrop Zoom In',
        label: 'Backdrop Zoom In',
      ),
      const BlenderMenuItem<String>(
        value: 'Backdrop Zoom Out',
        label: 'Backdrop Zoom Out',
      ),
      const BlenderMenuItem<String>(
        value: 'Fit Backdrop to Available Space',
        label: 'Fit Backdrop to Available Space',
      ),
    ],
    const BlenderMenuItem<String>(value: 'Area', label: 'Area'),
  ];

  List<BlenderMenuItem<String>> _nodeSelectMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'All', label: 'All'),
        BlenderMenuItem<String>(value: 'None', label: 'None'),
        BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
        BlenderMenuItem<String>(value: 'Select Box', label: 'Select Box'),
        BlenderMenuItem<String>(value: 'Select Circle', label: 'Select Circle'),
        BlenderMenuItem<String>(value: 'Select Lasso', label: 'Select Lasso'),
        BlenderMenuItem<String>(value: 'Linked from', label: 'Linked from'),
        BlenderMenuItem<String>(value: 'Linked to', label: 'Linked to'),
        BlenderMenuItem<String>(
          value: 'Select Grouped',
          label: 'Select Grouped',
        ),
        BlenderMenuItem<String>(
          value: 'Activate Same Type Previous',
          label: 'Activate Same Type Previous',
        ),
        BlenderMenuItem<String>(
          value: 'Activate Same Type Next',
          label: 'Activate Same Type Next',
        ),
        BlenderMenuItem<String>(value: 'Find Node...', label: 'Find Node...'),
      ];

  List<BlenderMenuItem<String>> _nodeAddMenuItems(BlenderEditorType type) =>
      <BlenderMenuItem<String>>[
        const BlenderMenuItem<String>(value: 'Search...', label: 'Search...'),
        const BlenderMenuItem<String>(value: 'Input', label: 'Input'),
        const BlenderMenuItem<String>(value: 'Output', label: 'Output'),
        BlenderMenuItem<String>(
          value: type == BlenderEditorType.compositor ? 'Filter' : 'Shader',
          label: type == BlenderEditorType.compositor ? 'Filter' : 'Shader',
        ),
        const BlenderMenuItem<String>(value: 'Color', label: 'Color'),
        const BlenderMenuItem<String>(value: 'Vector', label: 'Vector'),
        const BlenderMenuItem<String>(value: 'Converter', label: 'Converter'),
        const BlenderMenuItem<String>(value: 'Group', label: 'Group'),
        const BlenderMenuItem<String>(value: 'Layout', label: 'Layout'),
      ];

  List<BlenderMenuItem<String>> _nodeNodeMenuItems({
    required bool compositor,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(value: 'Move', label: 'Move'),
    const BlenderMenuItem<String>(value: 'Rotate', label: 'Rotate'),
    const BlenderMenuItem<String>(value: 'Resize', label: 'Resize'),
    const BlenderMenuItem<String>(value: 'Cut', label: 'Cut'),
    const BlenderMenuItem<String>(value: 'Copy', label: 'Copy'),
    const BlenderMenuItem<String>(value: 'Paste', label: 'Paste'),
    const BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
    const BlenderMenuItem<String>(
      value: 'Join in New Frame',
      label: 'Join in New Frame',
    ),
    const BlenderMenuItem<String>(
      value: 'Remove from Frame',
      label: 'Remove from Frame',
    ),
    const BlenderMenuItem<String>(
      value: 'Join Group Inputs',
      label: 'Join Group Inputs',
    ),
    const BlenderMenuItem<String>(value: 'Join Named', label: 'Join Named'),
    const BlenderMenuItem<String>(value: 'Rename...', label: 'Rename...'),
    const BlenderMenuItem<String>(value: 'Make Links', label: 'Make Links'),
    const BlenderMenuItem<String>(
      value: 'Make and Replace Links',
      label: 'Make and Replace Links',
    ),
    const BlenderMenuItem<String>(value: 'Links Cut', label: 'Links Cut'),
    const BlenderMenuItem<String>(value: 'Links Detach', label: 'Links Detach'),
    const BlenderMenuItem<String>(value: 'Links Mute', label: 'Links Mute'),
    const BlenderMenuItem<String>(value: 'Group', label: 'Group'),
    const BlenderMenuItem<String>(
      value: 'Insert Into Group',
      label: 'Insert Into Group',
    ),
    const BlenderMenuItem<String>(value: 'Exit Group', label: 'Exit Group'),
    const BlenderMenuItem<String>(value: 'Ungroup', label: 'Ungroup'),
    if (compositor)
      const BlenderMenuItem<String>(
        value: 'Read View Layers',
        label: 'Read View Layers',
      ),
    const BlenderMenuItem<String>(value: 'Swap', label: 'Swap'),
    const BlenderMenuItem<String>(value: 'Show/Hide', label: 'Show/Hide'),
    const BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
  ];

  Widget _buildNodeGizmoPopover() =>
      _buildAnimationPopoverPanel('Gizmos', <Widget>[
        const Text('Viewport Gizmos'),
        BlenderCheckbox(
          value: _nodeGizmos,
          label: 'Active Node',
          onChanged: (value) => _update(() => _nodeGizmos = value),
        ),
      ]);

  Widget _buildNodeOverlayPopover({required BlenderEditorType type}) {
    final geometry = type == BlenderEditorType.geometryNodeEditor;
    final compositor = type == BlenderEditorType.compositor;
    final shader = type == BlenderEditorType.shaderEditor;
    return _buildAnimationPopoverPanel('Overlays', <Widget>[
      const Text('Node Editor Overlays'),
      BlenderCheckbox(
        value: _nodeOverlays,
        label: 'Show Overlays',
        onChanged: (value) => _update(() => _nodeOverlays = value),
      ),
      BlenderCheckbox(value: true, label: 'Wire Colors', onChanged: (_) {}),
      BlenderCheckbox(value: true, label: 'Context Path', onChanged: (_) {}),
      BlenderCheckbox(value: false, label: 'Annotations', onChanged: (_) {}),
      if (shader)
        BlenderCheckbox(value: true, label: 'Previews', onChanged: (_) {}),
      if (geometry)
        BlenderCheckbox(
          value: false,
          label: 'Named Attributes',
          onChanged: (_) {},
        ),
      if (geometry || compositor)
        BlenderCheckbox(value: false, label: 'Timings', onChanged: (_) {}),
      if (compositor)
        BlenderCheckbox(value: true, label: 'Render Region', onChanged: (_) {}),
    ]);
  }

  BlenderAreaHeader _buildUtilityEditorHeader(BlenderEditorType type) {
    final menus = switch (type) {
      BlenderEditorType.textEditor => <String>[
        'View',
        'Text',
        'Edit',
        'Select',
        'Format',
        'Templates',
      ],
      BlenderEditorType.pythonConsole => <String>['View', 'Console'],
      BlenderEditorType.infoEditor => <String>['View', 'Info'],
      // Blender's normal View Layer Outliner header exposes its display-mode,
      // filter, and search controls from BlenderOutliner itself. Its editor
      // menu row is only present for the DATA_API display mode.
      BlenderEditorType.outliner =>
        _outlinerDisplayMode == BlenderOutlinerDisplayMode.dataApi
            ? <String>['Edit']
            : <String>[],
      BlenderEditorType.fileBrowser ||
      BlenderEditorType.assetBrowser => <String>['View', 'Select'],
      BlenderEditorType.spreadsheet => <String>['View', 'Select'],
      BlenderEditorType.project => <String>['View', 'Project'],
      _ => <String>['View'],
    };
    final menuItems = <String, List<String>>{
      'View': switch (type) {
        BlenderEditorType.textEditor => <String>[
          'Navigation',
          'Zoom In',
          'Zoom Out',
          'Toggle Word Wrap',
          'Toggle Line Numbers',
          'Sidebar',
        ],
        BlenderEditorType.pythonConsole => <String>[
          'Zoom In',
          'Zoom Out',
          'Move to Previous Word',
          'Move to Next Word',
          'Move to Line Begin',
          'Move to Line End',
          'Languages',
          'Area',
        ],
        BlenderEditorType.infoEditor => <String>['Area'],
        BlenderEditorType.outliner => <String>[
          'Toggle Sidebar',
          'Show Region Channels',
          'Show Region HUD',
          'Area',
        ],
        BlenderEditorType.spreadsheet => <String>[
          'Toolbar',
          'Sidebar',
          'Internal Attributes',
          'Area',
        ],
        BlenderEditorType.project => <String>['Sidebar', 'Area'],
        _ => <String>['${type.label} View Options'],
      },
      'Text': <String>[
        'New',
        'Open',
        'Reload',
        'Save',
        'Save As',
        'Resolve Conflict',
      ],
      'Edit': type == BlenderEditorType.outliner
          ? <String>[
              'Add Selected to Keying Set',
              'Remove Selected from Keying Set',
              'Add Drivers to Selected',
              'Remove Drivers from Selected',
            ]
          : <String>['Undo', 'Redo', 'Cut', 'Copy', 'Paste', 'Find', 'Replace'],
      'Select': <String>['All', 'Line', 'Word', 'Pick Linked'],
      'Format': <String>['Indent', 'Unindent', 'Auto Indent', 'Toggle Comment'],
      'Templates': <String>['Python', 'Open Shading Language', 'Application'],
      'Console': <String>[
        'Clear',
        'Clear Line',
        'Delete Previous Word',
        'Delete Next Word',
        'Copy as Script',
        'Cut',
        'Copy',
        'Paste',
        'Indent',
        'Unindent',
        'Backward in History',
        'Forward in History',
        'Autocomplete',
      ],
      'Info': <String>[
        'Select All',
        'Deselect All',
        'Invert Selection',
        'Toggle Selection',
        'Select Box',
        'Delete',
        'Copy',
      ],
      'Collection': <String>[
        'New Collection',
        'Delete',
        'Instance to Scene',
        'Link to Scene',
      ],
      'Object': <String>['Select', 'Delete', 'Copy', 'Paste'],
      'Project': <String>['Auto-Save Project', 'Save Project'],
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: _mainEditorArea.select,
      menuDescriptors: type == BlenderEditorType.preferences
          ? _editorHeaderPresets[type]!.menuDescriptors(_application.commands)
          : _editorMenuDescriptors(menus, menuItems: menuItems),
      actions: const <Widget>[
        BlenderIconButton(glyph: BlenderGlyph.more, tooltip: 'Editor options'),
      ],
    );
  }

  List<BlenderMenuDescriptor<String>> _editorMenuDescriptors(
    List<String> labels, {
    Map<String, List<String>> menuItems = const <String, List<String>>{},
    Map<String, List<BlenderMenuItem<String>>> menuDescriptors =
        const <String, List<BlenderMenuItem<String>>>{},
  }) => <BlenderMenuDescriptor<String>>[
    for (final label in labels)
      BlenderMenuDescriptor<String>(
        label: label,
        items:
            menuDescriptors[label] ??
            <BlenderMenuItem<String>>[
              for (final item in menuItems[label] ?? <String>['$label Options'])
                BlenderMenuItem<String>(value: item, label: item),
            ],
        onSelected: _setStatus,
      ),
  ];
}
