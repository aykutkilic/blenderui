part of '../editors.dart';

/// Source-shaped menu taxonomy shared by all node editor hosts.
abstract final class BlenderNodeEditorMenuCatalog {
  static List<BlenderMenuItem<String>> contexts(BlenderEditorType type) =>
      switch (type) {
        BlenderEditorType.shaderEditor => const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Object', label: 'Object'),
          BlenderMenuItem<String>(value: 'World', label: 'World'),
          BlenderMenuItem<String>(value: 'Line Style', label: 'Line Style'),
        ],
        BlenderEditorType.geometryNodeEditor => const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Modifier', label: 'Modifier'),
          BlenderMenuItem<String>(value: 'Tool', label: 'Tool'),
        ],
        BlenderEditorType.compositor => const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
          BlenderMenuItem<String>(value: 'Sequencer', label: 'Sequencer'),
        ],
        BlenderEditorType.textureNodeEditor => const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Brush', label: 'Brush'),
          BlenderMenuItem<String>(value: 'Image', label: 'Image'),
        ],
        _ => const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Tree', label: 'Tree'),
        ],
      };

  static List<BlenderMenuItem<String>> view({bool compositor = false}) =>
      <BlenderMenuItem<String>>[
        const BlenderMenuItem<String>(value: 'view.toolbar', label: 'Toolbar'),
        const BlenderMenuItem<String>(value: 'view.sidebar', label: 'Sidebar'),
        if (compositor)
          const BlenderMenuItem<String>(
            value: 'view.asset-shelf',
            label: 'Asset Shelf',
          ),
        const BlenderMenuItem<String>(
          value: 'view.zoom-in',
          label: 'Zoom In',
          shortcut: 'Numpad +',
          separator: true,
        ),
        const BlenderMenuItem<String>(
          value: 'view.zoom-out',
          label: 'Zoom Out',
          shortcut: 'Numpad -',
        ),
        const BlenderMenuItem<String>(
          value: 'view.frame-selected',
          label: 'Frame Selected',
          shortcut: 'Numpad .',
          separator: true,
        ),
        const BlenderMenuItem<String>(
          value: 'view.frame-all',
          label: 'Frame All',
          shortcut: 'Home',
        ),
        if (compositor) ...const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'view.backdrop-move',
            label: 'Backdrop Move',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'view.backdrop-zoom-in',
            label: 'Backdrop Zoom In',
          ),
          BlenderMenuItem<String>(
            value: 'view.backdrop-zoom-out',
            label: 'Backdrop Zoom Out',
          ),
          BlenderMenuItem<String>(
            value: 'view.backdrop-fit',
            label: 'Fit Backdrop to Available Space',
          ),
        ],
        const BlenderMenuItem<String>(
          value: 'view.area',
          label: 'Area',
          separator: true,
        ),
      ];

  static List<BlenderMenuItem<String>> select() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(
          value: 'select.all',
          label: 'All',
          shortcut: 'A',
        ),
        BlenderMenuItem<String>(
          value: 'select.none',
          label: 'None',
          shortcut: 'Alt A',
        ),
        BlenderMenuItem<String>(
          value: 'select.invert',
          label: 'Invert',
          shortcut: 'Ctrl I',
        ),
        BlenderMenuItem<String>(
          value: 'select.box',
          label: 'Select Box',
          separator: true,
        ),
        BlenderMenuItem<String>(value: 'select.circle', label: 'Select Circle'),
        BlenderMenuItem<String>(value: 'select.lasso', label: 'Select Lasso'),
        BlenderMenuItem<String>(
          value: 'select.linked-from',
          label: 'Linked from',
          separator: true,
        ),
        BlenderMenuItem<String>(value: 'select.linked-to', label: 'Linked to'),
        BlenderMenuItem<String>(
          value: 'select.grouped',
          label: 'Select Grouped',
          separator: true,
        ),
        BlenderMenuItem<String>(
          value: 'select.previous-type',
          label: 'Activate Same Type Previous',
        ),
        BlenderMenuItem<String>(
          value: 'select.next-type',
          label: 'Activate Same Type Next',
        ),
        BlenderMenuItem<String>(
          value: 'select.find',
          label: 'Find Node...',
          shortcut: 'Ctrl F',
          separator: true,
        ),
      ];

  static List<BlenderMenuItem<String>> add(BlenderEditorType type) {
    if (type == BlenderEditorType.geometryNodeEditor) return geometryAdd();
    return <BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'add.search',
        label: 'Search...',
        shortcut: 'Shift A',
      ),
      for (final label in <String>[
        'Input',
        'Output',
        if (type == BlenderEditorType.compositor) 'Filter' else 'Shader',
        'Color',
        'Vector',
        'Converter',
        'Group',
        'Layout',
      ])
        BlenderMenuItem<String>(value: 'add.${_slug(label)}', label: label),
    ];
  }

  static List<BlenderMenuItem<String>>
  geometryAdd() => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(
      value: 'add.search',
      label: 'Search...',
      shortcut: 'Shift A',
    ),
    _category('Input', <String>['Constant', 'Group', 'Scene', 'Gizmo']),
    _category('Output', <String>['Group Output', 'Viewer']),
    _category('Attribute', <String>[
      'Attribute Statistic',
      'Domain Size',
      'Capture Attribute',
      'Store Named Attribute',
    ]),
    _nestedCategory('Geometry', <String, List<String>>{
      'Read': <String>['Bounding Box', 'Geometry Proximity'],
      'Sample': <String>['Raycast', 'Sample Index'],
      'Write': <String>['Set ID', 'Set Position'],
      'Material': <String>['Material Selection', 'Set Material'],
      'Operations': <String>['Geometry to Instance', 'Join Geometry'],
    }),
    _nestedCategory('Curve', <String, List<String>>{
      'Read': <String>[
        'Curve Handle Positions',
        'Curve Length',
        'Curve Tilt',
        'Endpoint Selection',
        'Handle Type Selection',
        'Is Spline Cyclic',
        'Spline Length',
        'Spline Parameter',
        'Spline Resolution',
      ],
      'Sample': <String>['Sample Curve'],
      'Write': <String>['Set Curve Radius', 'Set Curve Tilt'],
      'Operations': <String>['Curve to Mesh', 'Resample Curve', 'Trim Curve'],
      'Primitives': <String>[
        'Arc',
        'Bézier Segment',
        'Curve Circle',
        'Curve Line',
      ],
      'Topology': <String>['Curve of Point', 'Points of Curve'],
    }),
    _category('Grease Pencil', <String>['Read', 'Write', 'Operations']),
    _category('Instances', <String>[
      'Instance on Points',
      'Instances to Points',
      'Realize Instances',
      'Rotate Instances',
      'Scale Instances',
      'Translate Instances',
    ]),
    _nestedCategory('Mesh', <String, List<String>>{
      'Read': <String>['Edge Angle', 'Face Area', 'Mesh Island'],
      'Sample': <String>['Sample Nearest Surface', 'Sample UV Surface'],
      'Write': <String>['Set Shade Smooth'],
      'Operations': <String>['Boolean', 'Extrude Mesh', 'Mesh to Curve'],
      'Primitives': <String>[
        'Cube',
        'Cylinder',
        'Grid',
        'Icosphere',
        'UV Sphere',
      ],
      'Topology': <String>[
        'Corners of Edge',
        'Edges of Vertex',
        'Face of Corner',
      ],
    }),
    _category('Point', <String>[
      'Distribute Points in Grid',
      'Distribute Points on Faces',
      'Points',
      'Points to Vertices',
    ]),
    _category('Volume', <String>[
      'Read',
      'Write',
      'Sample',
      'Operations',
      'Primitives',
    ]),
    _category('Simulation', <String>['Simulation Input', 'Simulation Output']),
    _category('Color', <String>[
      'Color Ramp',
      'Combine Color',
      'Mix',
      'Separate Color',
    ]),
    _category('Texture', <String>[
      'Brick Texture',
      'Gradient Texture',
      'Noise Texture',
      'Voronoi Texture',
    ]),
    _category('Utilities', <String>[
      'Field',
      'Rotation',
      'Matrix',
      'Math',
      'Vector',
    ]),
    _category('Group', <String>['Group Input', 'Group Output']),
    _category('Layout', <String>['Frame', 'Reroute']),
  ];

  static List<BlenderMenuItem<String>> node({bool compositor = false}) =>
      <BlenderMenuItem<String>>[
        for (final label in <String>['Move', 'Rotate', 'Resize'])
          BlenderMenuItem<String>(value: 'node.${_slug(label)}', label: label),
        for (final label in <String>['Cut', 'Copy', 'Paste', 'Duplicate'])
          BlenderMenuItem<String>(
            value: 'node.${_slug(label)}',
            label: label,
            separator: label == 'Cut',
          ),
        for (final label in <String>[
          'Join in New Frame',
          'Remove from Frame',
          'Join Group Inputs',
          'Join Named',
        ])
          BlenderMenuItem<String>(
            value: 'node.${_slug(label)}',
            label: label,
            separator: label == 'Join in New Frame',
          ),
        const BlenderMenuItem<String>(
          value: 'node.rename',
          label: 'Rename...',
          separator: true,
        ),
        for (final label in <String>[
          'Make Links',
          'Make and Replace Links',
          'Links Cut',
          'Links Detach',
          'Links Mute',
        ])
          BlenderMenuItem<String>(
            value: 'node.${_slug(label)}',
            label: label,
            separator: label == 'Make Links',
          ),
        for (final label in <String>[
          'Group',
          'Insert Into Group',
          'Exit Group',
          'Ungroup',
        ])
          BlenderMenuItem<String>(
            value: 'node.${_slug(label)}',
            label: label,
            separator: label == 'Group',
          ),
        _category('Swap', <String>['Search...']),
        _category('Show/Hide', <String>['Toggle', 'Hide Unused Sockets']),
        if (compositor)
          const BlenderMenuItem<String>(
            value: 'node.read-view-layers',
            label: 'Read View Layers',
          ),
        const BlenderMenuItem<String>(
          value: 'node.delete-reconnect',
          label: 'Delete with Reconnect',
          separator: true,
        ),
        const BlenderMenuItem<String>(
          value: 'node.delete',
          label: 'Delete',
          shortcut: 'X',
        ),
      ];

  static BlenderMenuItem<String> _category(String label, List<String> items) =>
      BlenderMenuItem<String>(
        value: 'add.${_slug(label)}',
        label: label,
        submenu: <BlenderMenuItem<String>>[
          for (final item in items)
            BlenderMenuItem<String>(
              value: 'add.${_slug(label)}.${_slug(item)}',
              label: item,
            ),
        ],
      );

  static BlenderMenuItem<String> _nestedCategory(
    String label,
    Map<String, List<String>> groups,
  ) => BlenderMenuItem<String>(
    value: 'add.${_slug(label)}',
    label: label,
    submenu: <BlenderMenuItem<String>>[
      for (final entry in groups.entries)
        BlenderMenuItem<String>(
          value: 'add.${_slug(label)}.${_slug(entry.key)}',
          label: entry.key,
          submenu: <BlenderMenuItem<String>>[
            for (final item in entry.value)
              BlenderMenuItem<String>(
                value: 'add.${_slug(label)}.${_slug(entry.key)}.${_slug(item)}',
                label: item,
              ),
          ],
        ),
    ],
  );

  static String _slug(String value) => value
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

/// Reusable Node Editor header; values and operators remain caller-owned.
class BlenderNodeEditorHeader extends StatelessWidget {
  const BlenderNodeEditorHeader({
    super.key,
    required this.editorType,
    required this.treeContext,
    required this.dataBlock,
    this.groupNavigation,
    this.onGroupNavigationChanged,
    this.onEditorTypeChanged,
    this.onTreeContextChanged,
    this.onDataBlockChanged,
    this.onCommand,
    this.pinned = false,
    this.onPinnedChanged,
    this.snapping = false,
    this.onSnappingChanged,
    this.overlays = true,
    this.onOverlaysChanged,
    this.wireColors = true,
    this.onWireColorsChanged,
    this.showNamedAttributes = false,
    this.onShowNamedAttributesChanged,
    this.showTimings = false,
    this.onShowTimingsChanged,
    this.showBackdrop = false,
    this.onShowBackdropChanged,
    this.gizmos = true,
    this.onGizmosChanged,
  });

  final BlenderEditorType editorType;
  final String treeContext;
  final String dataBlock;
  final BlenderNodeGroupNavigation? groupNavigation;
  final ValueChanged<BlenderNodeGroupNavigation>? onGroupNavigationChanged;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<String>? onTreeContextChanged;
  final ValueChanged<String>? onDataBlockChanged;
  final ValueChanged<String>? onCommand;
  final bool pinned;
  final ValueChanged<bool>? onPinnedChanged;
  final bool snapping;
  final ValueChanged<bool>? onSnappingChanged;
  final bool overlays;
  final ValueChanged<bool>? onOverlaysChanged;
  final bool wireColors;
  final ValueChanged<bool>? onWireColorsChanged;
  final bool showNamedAttributes;
  final ValueChanged<bool>? onShowNamedAttributesChanged;
  final bool showTimings;
  final ValueChanged<bool>? onShowTimingsChanged;
  final bool showBackdrop;
  final ValueChanged<bool>? onShowBackdropChanged;
  final bool gizmos;
  final ValueChanged<bool>? onGizmosChanged;

  @override
  Widget build(BuildContext context) {
    final compositor = editorType == BlenderEditorType.compositor;
    final contexts = BlenderNodeEditorMenuCatalog.contexts(editorType);
    final effectiveContext = contexts.any((item) => item.value == treeContext)
        ? treeContext
        : contexts.first.value;
    final dataBlocks = _dataBlocks(editorType);
    final effectiveDataBlock = dataBlocks.any((item) => item.value == dataBlock)
        ? dataBlock
        : dataBlocks.first.value;
    return BlenderAreaHeader(
      height: 30,
      editorType: editorType,
      showEditorLabel: false,
      onEditorTypeChanged: onEditorTypeChanged,
      leading: <Widget>[
        SizedBox(
          width: 92,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('node-tree-context'),
            value: effectiveContext,
            items: contexts,
            onChanged: onTreeContextChanged,
          ),
        ),
        if (groupNavigation case final navigation?) ...<Widget>[
          const SizedBox(width: 4),
          SizedBox(
            width: 220,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: BlenderBreadcrumbs(
                items: <String>[
                  for (final entry in navigation.path) entry.label,
                ],
                onSelected: onGroupNavigationChanged == null
                    ? null
                    : (index) =>
                          onGroupNavigationChanged!(navigation.jumpTo(index)),
              ),
            ),
          ),
        ],
      ],
      menuDescriptors: <BlenderMenuDescriptorWidget>[
        BlenderMenuDescriptor<String>(
          label: 'View',
          items: BlenderNodeEditorMenuCatalog.view(compositor: compositor),
          onSelected: onCommand,
        ),
        BlenderMenuDescriptor<String>(
          label: 'Select',
          items: BlenderNodeEditorMenuCatalog.select(),
          onSelected: onCommand,
        ),
        BlenderMenuDescriptor<String>(
          label: 'Add',
          items: BlenderNodeEditorMenuCatalog.add(editorType),
          onSelected: onCommand,
        ),
        BlenderMenuDescriptor<String>(
          label: 'Node',
          items: BlenderNodeEditorMenuCatalog.node(compositor: compositor),
          onSelected: onCommand,
        ),
      ],
      actions: <Widget>[
        SizedBox(
          width: 132,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('node-tree-datablock'),
            value: effectiveDataBlock,
            compact: true,
            items: dataBlocks,
            onChanged: onDataBlockChanged,
          ),
        ),
        BlenderIconButton(
          key: const ValueKey<String>('node-pin-button'),
          glyph: BlenderGlyph.pin,
          selected: pinned,
          onPressed: onPinnedChanged == null
              ? null
              : () => onPinnedChanged!(!pinned),
          tooltip: 'Pin node tree',
        ),
        if (compositor) ...<Widget>[
          BlenderIconButton(
            key: const ValueKey<String>('node-backdrop-button'),
            glyph: BlenderGlyph.eye,
            selected: showBackdrop,
            onPressed: onShowBackdropChanged == null
                ? null
                : () => onShowBackdropChanged!(!showBackdrop),
            tooltip: 'Show backdrop',
          ),
          BlenderIconButton(
            key: const ValueKey<String>('node-gizmo-button'),
            glyph: BlenderGlyph.gizmo,
            selected: gizmos,
            onPressed: onGizmosChanged == null
                ? null
                : () => onGizmosChanged!(!gizmos),
            tooltip: 'Node gizmos',
          ),
        ],
        BlenderIconButton(
          key: const ValueKey<String>('node-snap-button'),
          glyph: BlenderGlyph.snap,
          selected: snapping,
          onPressed: onSnappingChanged == null
              ? null
              : () => onSnappingChanged!(!snapping),
          tooltip: 'Snap to grid',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('node-overlay-button'),
            glyph: BlenderGlyph.overlay,
            selected: overlays,
            tooltip: 'Node editor overlays',
          ),
          popover: (context, close) => _overlayPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  Widget _overlayPopover() => BlenderPopoverPanel.settings('Overlays', <Widget>[
    const Text('Node Editor Overlays'),
    BlenderCheckbox(
      value: overlays,
      label: 'Show Overlays',
      onChanged: onOverlaysChanged ?? (_) {},
    ),
    BlenderCheckbox(
      value: wireColors,
      label: 'Wire Colors',
      onChanged: onWireColorsChanged ?? (_) {},
    ),
    BlenderCheckbox(value: true, label: 'Context Path', onChanged: (_) {}),
    BlenderCheckbox(value: false, label: 'Annotations', onChanged: (_) {}),
    if (editorType == BlenderEditorType.shaderEditor)
      BlenderCheckbox(value: true, label: 'Previews', onChanged: (_) {}),
    if (editorType == BlenderEditorType.geometryNodeEditor)
      BlenderCheckbox(
        value: showNamedAttributes,
        label: 'Named Attributes',
        onChanged: onShowNamedAttributesChanged ?? (_) {},
      ),
    if (editorType == BlenderEditorType.geometryNodeEditor ||
        editorType == BlenderEditorType.compositor)
      BlenderCheckbox(
        value: showTimings,
        label: 'Timings',
        onChanged: onShowTimingsChanged ?? (_) {},
      ),
  ]);

  static List<BlenderMenuItem<String>> _dataBlocks(
    BlenderEditorType type,
  ) => switch (type) {
    BlenderEditorType.geometryNodeEditor => const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Modifier Group', label: 'Modifier Group'),
      BlenderMenuItem<String>(value: 'Tool Group', label: 'Tool Group'),
    ],
    BlenderEditorType.compositor => const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Scene Nodes', label: 'Scene Nodes'),
      BlenderMenuItem<String>(
        value: 'Compositor Strip',
        label: 'Compositor Strip',
      ),
    ],
    BlenderEditorType.textureNodeEditor => const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Texture Nodes', label: 'Texture Nodes'),
    ],
    _ => const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Material Nodes', label: 'Material Nodes'),
    ],
  };
}
