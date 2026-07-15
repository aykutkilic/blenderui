import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import 'showcase_viewport.dart';

void main() {
  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  final BlenderDockingController<String> _dockController =
      BlenderDockingController<String>(
        root: const BlenderDockSplitNode<String>(
          id: 'workspace-columns',
          direction: BlenderSplitDirection.horizontal,
          fraction: .80,
          first: BlenderDockSplitNode<String>(
            id: 'main-stack',
            direction: BlenderSplitDirection.vertical,
            fraction: .84,
            first: BlenderDockAreaNode<String>(id: 'main-area', value: 'main'),
            second: BlenderDockAreaNode<String>(
              id: 'bottom-area',
              value: 'bottom',
            ),
          ),
          second: BlenderDockSplitNode<String>(
            id: 'right-stack',
            direction: BlenderSplitDirection.vertical,
            fraction: .27,
            first: BlenderDockAreaNode<String>(
              id: 'outliner-area',
              value: 'right-top',
            ),
            second: BlenderDockAreaNode<String>(
              id: 'properties-area',
              value: 'right-bottom',
            ),
          ),
        ),
      );
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fileSearchController = TextEditingController();
  final TextEditingController _keymapSearchController = TextEditingController();
  final TextEditingController _outlinerSearchController =
      TextEditingController();
  final TextEditingController _propertiesSearchController =
      TextEditingController();
  final TextEditingController _operatorSearchController =
      TextEditingController();
  final TextEditingController _layerSearchController = TextEditingController();
  final TextEditingController _galleryPathController = TextEditingController(
    text: '/showcase/scene.blend',
  );
  final TextEditingController _importerPathController = TextEditingController(
    text: '/showcase/import/source.fbx',
  );
  final TextEditingController _exporterPathController = TextEditingController(
    text: '//collection.gltf',
  );
  String _selectedExporterId = 'gltf';
  final List<BlenderGraphNode> _nodes = <BlenderGraphNode>[
    const BlenderGraphNode(
      id: 'texture',
      title: 'Texture',
      position: Offset(80, 150),
      size: Size(170, 96),
      outputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'color',
          label: 'Color',
          color: Color(0xFF8BC34A),
        ),
      ],
    ),
    const BlenderGraphNode(
      id: 'shader',
      title: 'Principled BSDF',
      position: Offset(360, 110),
      size: Size(220, 150),
      inputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'base-color',
          label: 'Base Color',
          color: Color(0xFF8BC34A),
        ),
        BlenderNodeSocketDefinition(
          id: 'roughness',
          label: 'Roughness',
          color: Color(0xFF4FC3F7),
        ),
      ],
      outputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'shader',
          label: 'BSDF',
          color: Color(0xFFFFB74D),
        ),
      ],
    ),
    const BlenderGraphNode(
      id: 'output',
      title: 'Material Output',
      position: Offset(680, 150),
      size: Size(180, 96),
      inputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'surface',
          label: 'Surface',
          color: Color(0xFFFFB74D),
        ),
      ],
    ),
  ];

  double _frame = 24;
  double _resolutionX = 1920;
  double _resolutionY = 1080;
  double _resolutionPercentage = 76;
  double _aspectX = 1;
  double _aspectY = 1;
  double _frameStart = 1;
  double _frameEnd = 250;
  double _frameStep = 1;
  double _locationX = 0;
  double _locationY = 0;
  List<double> _objectLocation = <double>[-1.1446, -4.4965, -1.5457];
  List<double> _objectRotation = <double>[0, 0, 0];
  List<double> _objectScale = <double>[1, 1, 1];
  List<bool> _objectLocationLocks = <bool>[false, false, false];
  List<bool> _objectRotationLocks = <bool>[false, false, false];
  List<bool> _objectScaleLocks = <bool>[false, false, false];
  String _objectRotationMode = 'XYZ Euler';
  Color _accentColor = const Color(0xFF4772B3);
  bool _useSmoothShading = true;
  bool _renderRegion = false;
  bool _cropToRenderRegion = false;
  bool _fileExtensions = true;
  bool _cacheResult = false;
  bool _propertiesSelectable = true;
  bool _showGrid = true;
  bool _wireframe = false;
  int _workspaceIndex = 0;
  int _toolIndex = 0;
  int _propertyTab = 0;
  BlenderOutlinerDisplayMode _outlinerDisplayMode =
      BlenderOutlinerDisplayMode.viewLayer;
  Set<String> _visiblePropertyTabIds = <String>{
    'tool',
    'render',
    'output',
    'scene',
    'world',
    'object',
    'modifier',
    'material',
  };
  int _bottomTab = 0;
  String _activeAction = 'CubeAction';
  String _preferenceCategory = 'Interface';
  bool _playing = false;
  bool _fileGrid = false;
  bool _galleryToggle = true;
  String _galleryMode = 'Regular';
  int _galleryListIndex = 0;
  String _frameRate = '24 fps';
  String _mediaType = 'Image';
  String _fileFormat = 'PNG (.png)';
  String _colorMode = 'RGBA';
  String _selectionMode = 'Set';
  String _syncWithOutliner = 'Auto';
  bool _propertiesContextMenuOpen = false;
  bool _toolOptionsExpanded = true;
  bool _toolTransformExpanded = true;
  bool _toolWorkspaceExpanded = false;
  bool _toolAffectOrigins = false;
  bool _toolAffectLocations = false;
  bool _toolAffectParents = false;
  bool _stereoscopy = false;
  String _formatPreset = 'Custom';

  static const List<BlenderPropertyTab> _propertyTabs = <BlenderPropertyTab>[
    BlenderPropertyTab(
      id: 'tool',
      label: 'Tool',
      glyph: BlenderGlyph.tool,
      group: 0,
    ),
    BlenderPropertyTab(
      id: 'render',
      label: 'Render',
      glyph: BlenderGlyph.render,
      group: 1,
    ),
    BlenderPropertyTab(
      id: 'output',
      label: 'Output',
      glyph: BlenderGlyph.output,
      group: 1,
    ),
    BlenderPropertyTab(
      id: 'scene',
      label: 'Scene',
      glyph: BlenderGlyph.scene,
      group: 2,
    ),
    BlenderPropertyTab(
      id: 'world',
      label: 'World',
      glyph: BlenderGlyph.world,
      group: 2,
    ),
    BlenderPropertyTab(
      id: 'object',
      label: 'Object',
      glyph: BlenderGlyph.object,
      group: 3,
    ),
    BlenderPropertyTab(
      id: 'modifier',
      label: 'Modifiers',
      glyph: BlenderGlyph.modifier,
      group: 3,
    ),
    BlenderPropertyTab(
      id: 'material',
      label: 'Material',
      glyph: BlenderGlyph.material,
      group: 4,
    ),
  ];
  double _gallerySlider = .42;
  Offset _galleryVector = const Offset(.35, .55);
  List<BlenderColorRampStop> _galleryRamp = const <BlenderColorRampStop>[
    BlenderColorRampStop(position: 0, color: Color(0xFF1D1D1D)),
    BlenderColorRampStop(position: 1, color: Color(0xFF4772B3)),
  ];
  List<Offset> _galleryCurve = const <Offset>[
    Offset(0, 0),
    Offset(.35, .72),
    Offset(1, 1),
  ];
  List<List<double>> _galleryMatrix = const <List<double>>[
    <double>[1, 0, 0],
    <double>[0, 1, 0],
    <double>[0, 0, 1],
  ];
  String? _galleryAttribute;
  Set<String> _galleryLayers = <String>{'1'};
  BlenderColorManagementSettings _galleryColorManagement =
      const BlenderColorManagementSettings();
  BlenderCacheFileSettings _galleryCacheFile = const BlenderCacheFileSettings(
    path: '/showcase/cache.abc',
    velocityName: 'point_velocity',
  );
  List<Offset> _galleryProfile = const <Offset>[
    Offset(0, 0),
    Offset(.35, .72),
    Offset(1, 1),
  ];
  BlenderEditorType _mainEditorType = BlenderEditorType.view3d;
  BlenderEditorType _rightTopEditorType = BlenderEditorType.outliner;
  BlenderEditorType _rightBottomEditorType = BlenderEditorType.properties;
  String _selectedObject = 'Cube';
  String? _selectedFile;
  String? _selectedShortcut;
  String _status = 'Ready';

  final List<BlenderConsoleLine> _consoleLines = const <BlenderConsoleLine>[
    BlenderConsoleLine(
      'Blender UI console showcase',
      kind: BlenderConsoleLineKind.info,
    ),
    BlenderConsoleLine('Type a command and press Enter.'),
  ];

  final List<BlenderSpreadsheetColumn> _spreadsheetColumns =
      const <BlenderSpreadsheetColumn>[
        BlenderSpreadsheetColumn(id: 'name', label: 'Name', width: 150),
        BlenderSpreadsheetColumn(id: 'type', label: 'Type', width: 100),
        BlenderSpreadsheetColumn(id: 'value', label: 'Value', width: 120),
        BlenderSpreadsheetColumn(id: 'state', label: 'State', width: 100),
      ];

  final List<BlenderSpreadsheetRow> _spreadsheetRows =
      const <BlenderSpreadsheetRow>[
        BlenderSpreadsheetRow(
          id: 'cube',
          values: <String>['Cube', 'Object', 'Active', 'Selected'],
        ),
        BlenderSpreadsheetRow(
          id: 'camera',
          values: <String>['Camera', 'Object', 'Ready', 'Linked'],
        ),
        BlenderSpreadsheetRow(
          id: 'light',
          values: <String>['Light', 'Object', 'Warm', 'Visible'],
        ),
      ];

  @override
  void dispose() {
    _dockController.dispose();
    _searchController.dispose();
    _fileSearchController.dispose();
    _keymapSearchController.dispose();
    _outlinerSearchController.dispose();
    _propertiesSearchController.dispose();
    _operatorSearchController.dispose();
    _layerSearchController.dispose();
    _galleryPathController.dispose();
    _importerPathController.dispose();
    _exporterPathController.dispose();
    super.dispose();
  }

  List<BlenderTreeNode<String>> get _tree {
    final colors = BlenderTheme.of(context).colors;
    return <BlenderTreeNode<String>>[
      BlenderTreeNode<String>(
        id: 'scene-collection',
        label: 'Scene Collection',
        icon: BlenderGlyph.collection,
        iconColor: colors.iconCollection,
        initiallyExpanded: true,
        children: <BlenderTreeNode<String>>[
          BlenderTreeNode<String>(
            id: 'collection',
            label: 'Collection',
            icon: BlenderGlyph.collection,
            iconColor: colors.iconCollection,
            initiallyExpanded: true,
            children: <BlenderTreeNode<String>>[
              BlenderTreeNode<String>(
                id: 'camera',
                label: 'Camera',
                value: 'Camera',
                icon: BlenderGlyph.camera,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'camera-data',
                    label: 'Camera',
                    icon: BlenderGlyph.camera,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'cube',
                label: 'Cube',
                value: 'Cube',
                icon: BlenderGlyph.cube,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'cube-data',
                    label: 'Cube',
                    icon: BlenderGlyph.wireframe,
                    iconColor: colors.iconObjectData,
                  ),
                  BlenderTreeNode<String>(
                    id: 'cube-material',
                    label: 'Material',
                    icon: BlenderGlyph.material,
                    iconColor: colors.iconShading,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'light',
                label: 'Light',
                value: 'Light',
                icon: BlenderGlyph.light,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'light-data',
                    label: 'Light',
                    icon: BlenderGlyph.light,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
            ],
          ),
          BlenderTreeNode<String>(
            id: 'world',
            label: 'World',
            icon: BlenderGlyph.world,
            iconColor: colors.iconScene,
          ),
        ],
      ),
    ];
  }

  List<BlenderTreeNode<String>> get _outlinerRoots {
    final colors = BlenderTheme.of(context).colors;
    return switch (_outlinerDisplayMode) {
      BlenderOutlinerDisplayMode.viewLayer => _tree,
      BlenderOutlinerDisplayMode.scenes => <BlenderTreeNode<String>>[
        BlenderTreeNode<String>(
          id: 'scene',
          label: 'Scene',
          icon: BlenderGlyph.scene,
          iconColor: colors.iconScene,
          initiallyExpanded: true,
          children: _tree,
        ),
      ],
      BlenderOutlinerDisplayMode.videoSequencer => <BlenderTreeNode<String>>[
        BlenderTreeNode<String>(
          id: 'sequence-editor',
          label: 'Sequence Editor',
          icon: BlenderGlyph.sequence,
          iconColor: colors.iconObject,
          initiallyExpanded: true,
          children: const <BlenderTreeNode<String>>[
            BlenderTreeNode<String>(id: 'strip-intro', label: 'Intro'),
            BlenderTreeNode<String>(id: 'strip-title', label: 'Title Card'),
            BlenderTreeNode<String>(id: 'strip-outro', label: 'Outro'),
          ],
        ),
      ],
      BlenderOutlinerDisplayMode.blenderFile => <BlenderTreeNode<String>>[
        BlenderTreeNode<String>(
          id: 'blend-file',
          label: 'Untitled',
          icon: BlenderGlyph.file,
          iconColor: colors.foregroundMuted,
          initiallyExpanded: true,
          children: const <BlenderTreeNode<String>>[
            BlenderTreeNode(id: 'objects', label: 'Objects'),
            BlenderTreeNode(id: 'collections', label: 'Collections'),
            BlenderTreeNode(id: 'materials', label: 'Materials'),
          ],
        ),
      ],
      BlenderOutlinerDisplayMode.dataApi => const <BlenderTreeNode<String>>[
        BlenderTreeNode(id: 'bpy-data', label: 'bpy.data'),
      ],
      BlenderOutlinerDisplayMode.libraryOverrides =>
        const <BlenderTreeNode<String>>[
          BlenderTreeNode(id: 'overrides', label: 'Library Overrides'),
        ],
      BlenderOutlinerDisplayMode.unusedData => const <BlenderTreeNode<String>>[
        BlenderTreeNode(id: 'orphan-data', label: 'Unused Data'),
      ],
    };
  }

  BlenderNodeGraphModel get _nodeGraph {
    return BlenderNodeGraphModel(
      nodes: List<BlenderGraphNode>.unmodifiable(_nodes),
      links: const <BlenderGraphLink>[
        BlenderGraphLink(from: 'texture', to: 'shader'),
        BlenderGraphLink(from: 'shader', to: 'output'),
      ],
    );
  }

  BlenderTimelineModel get _timelineModel {
    return BlenderTimelineModel(
      start: 1,
      end: 120,
      currentFrame: _frame,
      tracks: const <BlenderTimelineTrack>[
        BlenderTimelineTrack(
          id: 'cube',
          label: 'Cube',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(24),
            BlenderTimelineKeyframe(60),
          ],
        ),
        BlenderTimelineTrack(
          id: 'camera',
          label: 'Camera',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(80),
          ],
        ),
        BlenderTimelineTrack(
          id: 'light',
          label: 'Light',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(48),
            BlenderTimelineKeyframe(96),
          ],
        ),
      ],
    );
  }

  BlenderTimelineModel get _actionModel {
    return BlenderTimelineModel(
      start: 1,
      end: 120,
      currentFrame: _frame,
      tracks: const <BlenderTimelineTrack>[
        BlenderTimelineTrack(
          id: 'summary',
          label: 'CubeAction Summary',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(24),
            BlenderTimelineKeyframe(60),
          ],
        ),
        BlenderTimelineTrack(
          id: 'location-x',
          label: 'X Location',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(24),
            BlenderTimelineKeyframe(60),
          ],
        ),
        BlenderTimelineTrack(
          id: 'location-y',
          label: 'Y Location',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(60),
          ],
        ),
        BlenderTimelineTrack(
          id: 'rotation-z',
          label: 'Z Euler Rotation',
          keyframes: <BlenderTimelineKeyframe>[
            BlenderTimelineKeyframe(1),
            BlenderTimelineKeyframe(24),
            BlenderTimelineKeyframe(60),
          ],
        ),
      ],
    );
  }

  List<BlenderSequencerStrip> get _sequenceStrips {
    return const <BlenderSequencerStrip>[
      BlenderSequencerStrip(
        id: 'intro',
        label: 'Intro',
        start: 1,
        end: 28,
        channel: 0,
        color: Color(0xFF4772B3),
      ),
      BlenderSequencerStrip(
        id: 'title',
        label: 'Title Card',
        start: 18,
        end: 48,
        channel: 1,
        color: Color(0xFFAC8737),
      ),
      BlenderSequencerStrip(
        id: 'outro',
        label: 'Outro',
        start: 52,
        end: 96,
        channel: 0,
        color: Color(0xFF188625),
      ),
    ];
  }

  List<BlenderPropertyGroup> get _propertyGroups {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'format',
        title: 'Format',
        headerActions: <Widget>[_buildFormatPresetButton()],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'resolution-x',
            label: 'Resolution X',
            value: _resolutionX,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 1,
              max: 16384,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => setState(() => _resolutionX = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'resolution-y',
            label: 'Y',
            value: _resolutionY,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 1,
              max: 16384,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => setState(() => _resolutionY = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'resolution-percentage',
            label: '%',
            value: _resolutionPercentage,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 100,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => setState(() => _resolutionPercentage = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'aspect-x',
            label: 'Aspect X',
            value: _aspectX,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              step: .001,
              decimalDigits: 3,
              onChanged: onChanged,
            ),
            onChanged: (value) => setState(() => _aspectX = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'aspect-y',
            label: 'Y',
            value: _aspectY,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              step: .001,
              decimalDigits: 3,
              onChanged: onChanged,
            ),
            onChanged: (value) => setState(() => _aspectY = value),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'render-region',
            label: 'Render Region',
            value: _renderRegion,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (value) => setState(() => _renderRegion = value),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'crop-render-region',
            label: 'Crop to Render Region',
            value: _cropToRenderRegion,
            enabled: _renderRegion,
            editorBuilder: (context, value, onChanged) => BlenderCheckbox(
              value: value,
              enabled: _renderRegion,
              onChanged: onChanged,
            ),
            onChanged: (value) => setState(() => _cropToRenderRegion = value),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'frame-rate',
            label: 'Frame Rate',
            value: _frameRate,
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: '24 fps', label: '24 fps'),
                    BlenderMenuItem<String>(value: '30 fps', label: '30 fps'),
                    BlenderMenuItem<String>(value: '60 fps', label: '60 fps'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (value) => setState(() => _frameRate = value),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'frame-range',
        title: 'Frame Range',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'frame-start',
            label: 'Frame Start',
            value: _frameStart,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 100000,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => setState(() => _frameStart = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'frame-end',
            label: 'End',
            value: _frameEnd,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 100000,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => setState(() => _frameEnd = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'frame-step',
            label: 'Step',
            value: _frameStep,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 1,
              max: 1000,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => setState(() => _frameStep = value),
          ),
        ],
      ),
      const BlenderPropertyGroup(
        id: 'time-stretching',
        title: 'Time Stretching',
        properties: <BlenderPropertyDescriptor<dynamic>>[],
        initiallyExpanded: false,
      ),
      BlenderPropertyGroup(
        id: 'stereoscopy',
        title: 'Stereoscopy',
        properties: <BlenderPropertyDescriptor<dynamic>>[],
        initiallyExpanded: false,
        headerLeading: BlenderCheckbox(
          key: const ValueKey<String>('stereoscopy-header-checkbox'),
          value: _stereoscopy,
          onChanged: _setStereoscopy,
        ),
      ),
      BlenderPropertyGroup(
        id: 'output',
        title: 'Output',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'output-path',
            label: 'Output',
            value: _galleryPathController.text,
            editorBuilder: (context, value, onChanged) => BlenderPathField(
              controller: _galleryPathController,
              onBrowse: () => _setStatus('Browse output path'),
              placeholder: '/tmp/',
            ),
            onChanged: (value) {},
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'file-extensions',
            label: 'File Extensions',
            value: _fileExtensions,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (value) => setState(() => _fileExtensions = value),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'cache-result',
            label: 'Cache Result',
            value: _cacheResult,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (value) => setState(() => _cacheResult = value),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'media-type',
            label: 'Media Type',
            value: _mediaType,
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'Image', label: 'Image'),
                    BlenderMenuItem<String>(value: 'Movie', label: 'Movie'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (value) => setState(() => _mediaType = value),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'file-format',
            label: 'File Format',
            value: _fileFormat,
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'PNG (.png)',
                      label: 'PNG (.png)',
                    ),
                    BlenderMenuItem<String>(value: 'JPEG', label: 'JPEG'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (value) => setState(() => _fileFormat = value),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'color-mode',
            label: 'Color',
            value: _colorMode,
            editorBuilder: (context, value, onChanged) =>
                BlenderSegmentedControl<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'BW', label: 'BW'),
                    BlenderMenuItem<String>(value: 'RGB', label: 'RGB'),
                    BlenderMenuItem<String>(value: 'RGBA', label: 'RGBA'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (value) => setState(() => _colorMode = value),
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _toolPropertyGroups {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'tool-options',
        title: 'Options',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<bool>(
            id: 'select-through',
            label: 'Select Through',
            value: _renderRegion,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (value) => setState(() => _renderRegion = value),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'select-overlap',
            label: 'Select Overlap',
            value: !_cropToRenderRegion,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (value) => setState(() => _cropToRenderRegion = !value),
          ),
        ],
      ),
    ];
  }

  void _setObjectVectorValue(
    List<double> values,
    int index,
    double value,
    void Function(List<double>) assign,
  ) {
    final updated = List<double>.of(values)..[index] = value;
    setState(() => assign(updated));
  }

  void _toggleObjectVectorLock(
    List<bool> locks,
    int index,
    void Function(List<bool>) assign,
  ) {
    final updated = List<bool>.of(locks)..[index] = !locks[index];
    setState(() => assign(updated));
  }

  List<BlenderPropertyGroup> get _objectPropertyGroups {
    const axes = <String>['X', 'Y', 'Z'];
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'object-transform',
        title: 'Transform',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          for (var index = 0; index < 3; index++)
            BlenderPropertyDescriptor<double>(
              id: 'object-location-${axes[index].toLowerCase()}',
              label: index == 0 ? 'Location X' : axes[index],
              value: _objectLocation[index],
              editorBuilder: (context, value, onChanged) =>
                  _ObjectTransformValueEditor(
                    value: value,
                    suffix: ' m',
                    decimalDigits: 4,
                    locked: _objectLocationLocks[index],
                    onChanged: onChanged,
                    onLockChanged: () => _toggleObjectVectorLock(
                      _objectLocationLocks,
                      index,
                      (locks) => _objectLocationLocks = locks,
                    ),
                    onKeyframe: () =>
                        _setStatus('Keyframe Location ${axes[index]}'),
                  ),
              onChanged: (value) => _setObjectVectorValue(
                _objectLocation,
                index,
                value,
                (values) => _objectLocation = values,
              ),
            ),
          for (var index = 0; index < 3; index++)
            BlenderPropertyDescriptor<double>(
              id: 'object-rotation-${axes[index].toLowerCase()}',
              label: index == 0 ? 'Rotation X' : axes[index],
              value: _objectRotation[index],
              editorBuilder: (context, value, onChanged) =>
                  _ObjectTransformValueEditor(
                    value: value,
                    suffix: '°',
                    decimalDigits: 0,
                    locked: _objectRotationLocks[index],
                    onChanged: onChanged,
                    onLockChanged: () => _toggleObjectVectorLock(
                      _objectRotationLocks,
                      index,
                      (locks) => _objectRotationLocks = locks,
                    ),
                    onKeyframe: () =>
                        _setStatus('Keyframe Rotation ${axes[index]}'),
                  ),
              onChanged: (value) => _setObjectVectorValue(
                _objectRotation,
                index,
                value,
                (values) => _objectRotation = values,
              ),
            ),
          BlenderPropertyDescriptor<String>(
            id: 'object-rotation-mode',
            label: 'Mode',
            value: _objectRotationMode,
            editorBuilder: (context, value, onChanged) =>
                _ObjectRotationModeEditor(
                  value: value,
                  onChanged: onChanged,
                  onKeyframe: () => _setStatus('Keyframe Rotation Mode'),
                ),
            onChanged: (value) => setState(() => _objectRotationMode = value),
          ),
          for (var index = 0; index < 3; index++)
            BlenderPropertyDescriptor<double>(
              id: 'object-scale-${axes[index].toLowerCase()}',
              label: index == 0 ? 'Scale X' : axes[index],
              value: _objectScale[index],
              editorBuilder: (context, value, onChanged) =>
                  _ObjectTransformValueEditor(
                    value: value,
                    decimalDigits: 3,
                    locked: _objectScaleLocks[index],
                    onChanged: onChanged,
                    onLockChanged: () => _toggleObjectVectorLock(
                      _objectScaleLocks,
                      index,
                      (locks) => _objectScaleLocks = locks,
                    ),
                    onKeyframe: () =>
                        _setStatus('Keyframe Scale ${axes[index]}'),
                  ),
              onChanged: (value) => _setObjectVectorValue(
                _objectScale,
                index,
                value,
                (values) => _objectScale = values,
              ),
            ),
        ],
        children: const <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'object-delta-transform',
            title: 'Delta Transform',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
        ],
      ),
      for (final section in const <(String, String)>[
        ('object-relations', 'Relations'),
        ('object-collections', 'Collections'),
        ('object-viewport-display', 'Viewport Display'),
        ('object-instancing', 'Instancing'),
        ('object-motion-paths', 'Motion Paths'),
        ('object-visibility', 'Visibility'),
        ('object-animation', 'Animation'),
        ('object-custom-properties', 'Custom Properties'),
      ])
        BlenderPropertyGroup(
          id: section.$1,
          title: section.$2,
          initiallyExpanded: false,
          properties: const <BlenderPropertyDescriptor<dynamic>>[],
        ),
    ];
  }

  String get _propertiesContextTitle => switch (_propertyTab) {
    0 => 'Select Box',
    1 => 'Render',
    2 => 'Output',
    3 => 'Scene',
    4 => 'World',
    5 => _selectedObject,
    6 => 'Modifiers',
    _ => 'Material',
  };

  BlenderGlyph get _propertiesContextGlyph => switch (_propertyTab) {
    0 => BlenderGlyph.selectBox,
    1 => BlenderGlyph.render,
    2 => BlenderGlyph.output,
    3 => BlenderGlyph.scene,
    4 => BlenderGlyph.world,
    5 => BlenderGlyph.object,
    6 => BlenderGlyph.modifier,
    _ => BlenderGlyph.material,
  };

  List<BlenderPropertyGroup> get _visiblePropertyGroups =>
      switch (_propertyTab) {
        0 => _toolPropertyGroups,
        2 => _propertyGroups,
        1 => const <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'render-context',
            title: 'Render',
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
        ],
        3 => const <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'scene-context',
            title: 'Scene',
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
        ],
        4 => const <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'world-context',
            title: 'World',
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
        ],
        5 => _objectPropertyGroups,
        6 => const <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'modifier-context',
            title: 'Modifiers',
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
        ],
        _ => const <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'material-context',
            title: 'Material',
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
        ],
      };

  Widget? get _propertyTopContent {
    if (_propertyTab == 5) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-object-field'),
        value: _selectedObject,
        icon: BlenderGlyph.object,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Camera',
            label: 'Camera',
            icon: BlenderIcon(BlenderGlyph.camera, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Cube',
            label: 'Cube',
            icon: BlenderIcon(BlenderGlyph.object, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Light',
            label: 'Light',
            icon: BlenderIcon(BlenderGlyph.light, size: 14),
          ),
        ],
        onChanged: (value) => setState(() => _selectedObject = value),
      );
    }
    if (_propertyTab != 0) return null;
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 190),
        child: SizedBox(
          key: const ValueKey<String>('tool-selection-operation-group'),
          width: double.infinity,
          child: BlenderSegmentedControl<String>(
            value: _selectionMode,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Set',
                label: '',
                icon: BlenderIcon(BlenderGlyph.selectBox, size: 16),
              ),
              BlenderMenuItem<String>(
                value: 'Extend',
                label: '',
                icon: BlenderIcon(BlenderGlyph.selectExtend, size: 16),
              ),
              BlenderMenuItem<String>(
                value: 'Subtract',
                label: '',
                icon: BlenderIcon(BlenderGlyph.selectSubtract, size: 16),
              ),
              BlenderMenuItem<String>(
                value: 'Difference',
                label: '',
                icon: BlenderIcon(BlenderGlyph.selectDifference, size: 16),
              ),
              BlenderMenuItem<String>(
                value: 'Intersect',
                label: '',
                icon: BlenderIcon(BlenderGlyph.selectIntersect, size: 16),
              ),
            ],
            onChanged: (value) => setState(() => _selectionMode = value),
          ),
        ),
      ),
    );
  }

  Widget _buildFormatPresetButton() {
    const presets = <String>[
      '4K DCI 2160p',
      '4K UHDTV 2160p',
      '4K UW 1600p',
      'DVCPRO HD 720p',
      'DVCPRO HD 1080p',
      'HDTV 720p',
      'HDTV 1080p',
      'HDV 1080p',
      'HDV NTSC 1080p',
      'HDV PAL 1080p',
      'TV NTSC 4:3',
      'TV NTSC 16:9',
      'TV PAL 4:3',
      'TV PAL 16:9',
    ];
    return BlenderPopover(
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      child: const BlenderIconButton(
        glyph: BlenderGlyph.preset,
        size: 22,
        tooltip: 'Format presets',
      ),
      popover: (context, close) => BlenderMenu<String>(
        items: <BlenderMenuItem<String>>[
          for (final preset in presets)
            BlenderMenuItem<String>(
              value: preset,
              label: preset,
              selected: preset == _formatPreset,
            ),
          const BlenderMenuItem<String>(
            value: 'separator',
            label: '',
            separator: true,
          ),
          const BlenderMenuItem<String>(
            value: 'new-preset',
            label: 'New Preset',
            icon: BlenderIcon(BlenderGlyph.plus, size: 13),
          ),
        ],
        onSelected: (item) {
          if (item.value != 'separator') {
            setState(() => _formatPreset = item.value);
            close();
          }
        },
      ),
    );
  }

  void _setStereoscopy(bool value) {
    setState(() => _stereoscopy = value);
  }

  Widget _buildToolSettingsBody() {
    final theme = BlenderTheme.of(context);
    return BlenderScrollView(
      child: Padding(
        // Blender's panel layout applies UI_PANEL_MARGIN_X before drawing
        // panel cards. The specialized Tool body bypasses the generic
        // Properties list, so keep the equivalent horizontal inset here.
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _propertyTopContent!,
            const SizedBox(height: 10),
            _buildToolSettingsPanel(
              title: 'Options',
              expanded: _toolOptionsExpanded,
              onToggle: () =>
                  setState(() => _toolOptionsExpanded = !_toolOptionsExpanded),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildNestedToolHeader(
                    title: 'Transform',
                    expanded: _toolTransformExpanded,
                    onToggle: () => setState(
                      () => _toolTransformExpanded = !_toolTransformExpanded,
                    ),
                  ),
                  if (_toolTransformExpanded)
                    Container(
                      color: theme.colors.panelSubSurface,
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                'Affect Only',
                                textAlign: TextAlign.right,
                                style: theme.textTheme.body.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                _buildToolCheckbox(
                                  value: _toolAffectOrigins,
                                  label: 'Origins',
                                  onChanged: (value) => setState(
                                    () => _toolAffectOrigins = value,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                _buildToolCheckbox(
                                  value: _toolAffectLocations,
                                  label: 'Locations',
                                  onChanged: (value) => setState(
                                    () => _toolAffectLocations = value,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                _buildToolCheckbox(
                                  value: _toolAffectParents,
                                  label: 'Parents',
                                  onChanged: (value) => setState(
                                    () => _toolAffectParents = value,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            _buildToolSettingsPanel(
              title: 'Workspace',
              expanded: _toolWorkspaceExpanded,
              onToggle: () => setState(
                () => _toolWorkspaceExpanded = !_toolWorkspaceExpanded,
              ),
              child: const SizedBox(height: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolSettingsPanel({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.panelBackground,
        border: Border.all(color: theme.colors.panelOutline),
        borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: SizedBox(
              height: theme.density.headerHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: <Widget>[
                    BlenderIcon(
                      key: ValueKey<String>(
                        'tool-settings-panel-disclosure-$title',
                      ),
                      expanded
                          ? BlenderGlyph.panelDisclosureDown
                          : BlenderGlyph.panelDisclosureRight,
                      size: 9,
                      color: theme.colors.foregroundMuted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.body,
                      ),
                    ),
                    BlenderIcon(
                      key: ValueKey<String>('tool-settings-drag-handle-$title'),
                      BlenderGlyph.dragHandle,
                      size: 9,
                      color: theme.colors.foregroundMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded) child,
        ],
      ),
    );
  }

  Widget _buildToolCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = BlenderTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(!value),
      child: Row(
        children: <Widget>[
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: value ? theme.colors.buttonSelected : theme.colors.button,
              border: Border.all(
                color: value
                    ? theme.colors.buttonSelected
                    : theme.colors.borderSubtle,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: value
                ? const BlenderIcon(BlenderGlyph.check, size: 13)
                : null,
          ),
          const SizedBox(width: 5),
          Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildNestedToolHeader({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    final theme = BlenderTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Container(
        height: theme.density.headerHeight,
        color: theme.colors.panelBackground,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: <Widget>[
            BlenderIcon(
              key: ValueKey<String>('tool-settings-nested-disclosure-$title'),
              expanded
                  ? BlenderGlyph.panelDisclosureDown
                  : BlenderGlyph.panelDisclosureRight,
              size: 9,
              color: theme.colors.foregroundMuted,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setStatus(String message) {
    setState(() => _status = message);
  }

  void _moveNode(BlenderGraphNode node, Offset position) {
    setState(() {
      final index = _nodes.indexWhere((candidate) => candidate.id == node.id);
      if (index == -1) return;
      _nodes[index] = BlenderGraphNode(
        id: node.id,
        title: node.title,
        position: position,
        size: node.size,
        inputs: node.inputs,
        outputs: node.outputs,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlenderApp(
      title: 'Blender UI — workspace showcase',
      home: BlenderEditorShell(
        topBar: _buildMainToolbar(),
        left: null,
        main: BlenderDockingWorkspace<String>(
          controller: _dockController,
          cloneValue: (value) {
            _setStatus('Area split: $value');
            return value;
          },
          areaBuilder: _buildDockedArea,
        ),
        statusBar: BlenderStatusBar(
          left: <Widget>[Text('Blender UI showcase  •  $_status')],
          right: const <Widget>[
            Text('Global Search'),
            SizedBox(width: 5),
            BlenderKeycap('F3'),
          ],
        ),
      ),
    );
  }

  Widget _buildDockedArea(
    BuildContext context,
    BlenderDockAreaNode<String> area,
  ) {
    return switch (area.value) {
      'main' => _buildMainEditor(),
      'bottom' => _buildBottomEditor(),
      'right-top' => _buildRightTopArea(),
      'right-bottom' => _buildRightBottomArea(),
      _ => _buildMainEditor(),
    };
  }

  Widget _buildMainToolbar() {
    Widget menu(String label, List<BlenderMenuItem<String>> items) {
      return BlenderMenuButton<String>(
        label: label,
        items: items,
        variant: BlenderButtonVariant.topBar,
        onSelected: _setStatus,
      );
    }

    final theme = BlenderTheme.of(context);
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: theme.colors.canvas,
        border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: BlenderToolbar(
              height: 30,
              scrollable: true,
              background: theme.colors.canvas,
              children: <Widget>[
                const SizedBox(
                  width: 34,
                  child: Center(
                    child: BlenderIcon(BlenderGlyph.cube, size: 20),
                  ),
                ),
                menu('File', const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'New',
                    label: 'New',
                    shortcut: '⌘ N',
                    icon: BlenderIcon(BlenderGlyph.file, size: 18),
                  ),
                  BlenderMenuItem<String>(
                    value: 'Open',
                    label: 'Open...',
                    shortcut: '⌘ O',
                    icon: BlenderIcon(BlenderGlyph.folder, size: 18),
                  ),
                  BlenderMenuItem<String>(
                    value: 'Open Recent',
                    label: 'Open Recent',
                    shortcut: '⇧ ⌘ O',
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Recent Scene',
                        label: 'showcase.blend',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Recent Materials',
                        label: 'materials.blend',
                      ),
                    ],
                  ),
                  BlenderMenuItem<String>(
                    value: 'Revert',
                    label: 'Revert',
                    enabled: false,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Recover',
                    label: 'Recover',
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Recover Last Session',
                        label: 'Last Session',
                      ),
                    ],
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-open',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Save',
                    label: 'Save',
                    shortcut: '⌘ S',
                    icon: BlenderIcon(BlenderGlyph.save, size: 18),
                  ),
                  BlenderMenuItem<String>(
                    value: 'Save As',
                    label: 'Save As...',
                    shortcut: '⇧ ⌘ S',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Save Copy',
                    label: 'Save Copy...',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Save Incremental',
                    label: 'Save Incremental',
                    enabled: false,
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-save',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Link',
                    label: 'Link...',
                    icon: BlenderIcon(BlenderGlyph.link, size: 18),
                  ),
                  BlenderMenuItem<String>(
                    value: 'Append',
                    label: 'Append...',
                    icon: BlenderIcon(BlenderGlyph.link, size: 18),
                  ),
                  BlenderMenuItem<String>(
                    value: 'Data Previews',
                    label: 'Data Previews',
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Update Data Previews',
                        label: 'Update Data Previews',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Remove Data Previews',
                        label: 'Remove Data Previews',
                      ),
                    ],
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-data',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Import',
                    label: 'Import',
                    icon: BlenderIcon(BlenderGlyph.open, size: 18),
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Import Alembic',
                        label: 'Alembic (.abc)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Import USD',
                        label: 'Universal Scene Description (.usd*)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Import SVG',
                        label: 'SVG as Grease Pencil',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Import OBJ',
                        label: 'Wavefront (.obj)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Import PLY',
                        label: 'Stanford PLY (.ply)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Import STL',
                        label: 'STL (.stl)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Import FBX',
                        label: 'FBX (.fbx)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Import BVH',
                        label: 'Motion Capture (.bvh)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Import SVG2',
                        label: 'Scalable Vector Graphics (.svg)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Import FBX Legacy',
                        label: 'FBX (.fbx) (Legacy)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Import glTF',
                        label: 'glTF 2.0 (.glb/.gltf)',
                      ),
                    ],
                  ),
                  BlenderMenuItem<String>(
                    value: 'Export',
                    label: 'Export',
                    icon: BlenderIcon(BlenderGlyph.save, size: 18),
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Export OBJ',
                        label: 'Wavefront (.obj)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Export FBX',
                        label: 'FBX (.fbx)',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Export glTF',
                        label: 'glTF 2.0 (.glb/.gltf)',
                      ),
                    ],
                  ),
                  BlenderMenuItem<String>(
                    value: 'Export All Collections',
                    label: 'Export All Collections',
                    enabled: false,
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-export',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'External Data',
                    label: 'External Data',
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Pack Resources',
                        label: 'Pack Resources',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Unpack Resources',
                        label: 'Unpack Resources',
                      ),
                    ],
                  ),
                  BlenderMenuItem<String>(
                    value: 'Clean Up',
                    label: 'Clean Up',
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Unused Data',
                        label: 'Unused Data-Blocks',
                      ),
                    ],
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-cleanup',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Defaults',
                    label: 'Defaults',
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Save Startup File',
                        label: 'Save Startup File',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Load Factory Settings',
                        label: 'Load Factory Settings',
                      ),
                    ],
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-quit',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Quit',
                    label: 'Quit',
                    shortcut: '⌘ Q',
                    icon: BlenderIcon(BlenderGlyph.close, size: 18),
                  ),
                ]),
                menu('Edit', const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Undo',
                    label: 'Undo',
                    shortcut: 'Ctrl+Z',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Redo',
                    label: 'Redo',
                    shortcut: 'Ctrl+Shift+Z',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Preferences',
                    label: 'Preferences',
                  ),
                ]),
                menu('Render', const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Render Image',
                    label: 'Render Image',
                    shortcut: 'F12',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Render Animation',
                    label: 'Render Animation',
                  ),
                ]),
                menu('Window', const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'New Window',
                    label: 'New Window',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Toggle Fullscreen',
                    label: 'Toggle Fullscreen',
                  ),
                ]),
                menu('Help', const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Manual',
                    label: 'Blender Manual',
                  ),
                  BlenderMenuItem<String>(
                    value: 'About',
                    label: 'About Blender UI',
                  ),
                ]),
                const SizedBox(width: 8),
                SizedBox(
                  width: 1,
                  height: 24,
                  child: ColoredBox(color: theme.colors.editorOutline),
                ),
                const SizedBox(width: 6),
                BlenderTabBar(
                  scrollable: false,
                  variant: BlenderButtonVariant.topBar,
                  tabs: const <String>[
                    'Layout',
                    'Modeling',
                    'Sculpting',
                    'UV Editing',
                    'Texture Paint',
                    'Shading',
                    'Animation',
                    'Rendering',
                    'Compositing',
                    'Geometry Nodes',
                  ],
                  selectedIndex: _workspaceIndex,
                  onChanged: (value) {
                    setState(() => _workspaceIndex = value);
                    _setStatus('Workspace changed');
                  },
                ),
                BlenderPopover(
                  child: BlenderIconButton(
                    glyph: BlenderGlyph.plus,
                    onPressed: () {},
                    tooltip: 'Add Workspace',
                    size: 26,
                  ),
                  popover: (context, close) => SizedBox(
                    width: 260,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: theme.colors.menuBackground,
                        border: Border.all(color: theme.colors.borderSubtle),
                        borderRadius: BorderRadius.circular(
                          theme.shapes.menuRadius,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text('Add Workspace', style: theme.textTheme.body),
                            const SizedBox(height: 6),
                            for (final workspace in <String>[
                              'General',
                              '2D Animation',
                              'Sculpting',
                              'Video Editing',
                            ])
                              BlenderButton(
                                label: workspace,
                                variant: BlenderButtonVariant.menu,
                                onPressed: () {
                                  _setStatus('Workspace added: $workspace');
                                  close();
                                },
                              ),
                            const BlenderSeparator(),
                            BlenderButton(
                              label: 'Duplicate Current',
                              onPressed: () {
                                _setStatus('Workspace duplicated');
                                close();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          BlenderDataBlockGroup<String>(
            value: 'Scene',
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Scene',
                label: 'Scene',
                icon: BlenderIcon(BlenderGlyph.scene, size: 16),
              ),
              BlenderMenuItem<String>(value: 'Preview', label: 'Preview'),
            ],
            tooltip: 'Scene',
            onChanged: (value) => _setStatus('Scene: $value'),
            onNamePressed: () => _setStatus('Rename scene'),
            onPin: () => _setStatus('Pinned scene'),
            onDuplicate: () => _setStatus('Scene copied'),
            onClose: () => _setStatus('Scene view closed'),
          ),
          SizedBox(
            width: 1,
            height: 24,
            child: ColoredBox(color: theme.colors.editorOutline),
          ),
          BlenderDataBlockGroup<String>(
            value: 'ViewLayer',
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'ViewLayer',
                label: 'ViewLayer',
                icon: BlenderIcon(BlenderGlyph.image, size: 16),
              ),
              BlenderMenuItem<String>(
                value: 'Preview Layer',
                label: 'Preview Layer',
              ),
            ],
            tooltip: 'View Layer',
            onChanged: (value) => _setStatus('View layer: $value'),
            onNamePressed: () => _setStatus('Rename view layer'),
            onDuplicate: () => _setStatus('View layer copied'),
            onClose: () => _setStatus('View layer closed'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return BlenderToolShelf(
      width: 48,
      tools: const <BlenderToolDefinition>[
        BlenderToolDefinition(
          glyph: BlenderGlyph.pointer,
          tooltip: 'Select tool',
          options: <BlenderToolOption>[
            BlenderToolOption(
              label: 'Tweak',
              glyph: BlenderGlyph.pointer,
              shortcut: 'Space Bar',
              description: 'Select and transform elements directly.',
            ),
            BlenderToolOption(
              label: 'Select Box',
              glyph: BlenderGlyph.selectBox,
              shortcut: 'W',
              description: 'Select elements inside a rectangular region.',
            ),
            BlenderToolOption(
              label: 'Select Circle',
              glyph: BlenderGlyph.radio,
              shortcut: 'C',
              description: 'Select elements inside a circular region.',
            ),
            BlenderToolOption(
              label: 'Select Lasso',
              glyph: BlenderGlyph.pointer,
              shortcut: 'Ctrl Space',
              description: 'Select elements inside a freeform region.',
            ),
          ],
        ),
        BlenderToolDefinition(glyph: BlenderGlyph.plus, tooltip: 'Add tool'),
        BlenderToolDefinition(
          glyph: BlenderGlyph.transform,
          tooltip: 'Move tool',
        ),
        BlenderToolDefinition(
          glyph: BlenderGlyph.rotate,
          tooltip: 'Rotate tool',
        ),
        BlenderToolDefinition(glyph: BlenderGlyph.scale, tooltip: 'Scale tool'),
        BlenderToolDefinition(glyph: BlenderGlyph.pan, tooltip: 'Pan tool'),
        BlenderToolDefinition(glyph: BlenderGlyph.zoom, tooltip: 'Zoom tool'),
        BlenderToolDefinition(
          glyph: BlenderGlyph.tool,
          tooltip: 'Tool settings',
        ),
      ],
      selectedIndex: _toolIndex,
      onChanged: (value) {
        setState(() => _toolIndex = value);
        _setStatus('Tool changed');
      },
      onOptionSelected: (option) => _setStatus('Tool: ${option.label}'),
    );
  }

  Widget _buildMainEditor() {
    return Column(
      children: <Widget>[
        _buildMainEditorHeader(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildLeftSidebar(),
              Expanded(child: _buildMainEditorSurface()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainEditorHeader() {
    return switch (_mainEditorType) {
      BlenderEditorType.view3d => _buildView3dHeader(),
      BlenderEditorType.imageEditor ||
      BlenderEditorType.uvEditor => _buildImageEditorHeader(_mainEditorType),
      BlenderEditorType.timeline ||
      BlenderEditorType.dopeSheet ||
      BlenderEditorType.graphEditor ||
      BlenderEditorType.nlaEditor ||
      BlenderEditorType.drivers ||
      BlenderEditorType.sequencer ||
      BlenderEditorType.videoEditing => _buildAnimationEditorHeader(
        _mainEditorType,
      ),
      BlenderEditorType.shaderEditor ||
      BlenderEditorType.geometryNodeEditor ||
      BlenderEditorType.compositor ||
      BlenderEditorType.textureNodeEditor => _buildNodeEditorHeader(
        _mainEditorType,
      ),
      _ => _buildUtilityEditorHeader(_mainEditorType),
    };
  }

  Widget _buildView3dHeader() {
    return BlenderAreaHeader(
      height: 30,
      editorType: _mainEditorType,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      leading: <Widget>[
        SizedBox(
          width: 118,
          child: BlenderDropdown<String>(
            value: 'Object Mode',
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Object Mode',
                label: 'Object Mode',
              ),
              BlenderMenuItem<String>(value: 'Edit Mode', label: 'Edit Mode'),
              BlenderMenuItem<String>(
                value: 'Sculpt Mode',
                label: 'Sculpt Mode',
              ),
            ],
            onChanged: (value) => _setStatus('$value selected'),
          ),
        ),
      ],
      menus: <Widget>[
        BlenderMenuButton<String>(
          label: 'View',
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: 'Frame',
              label: 'Frame Selected',
              shortcut: 'Numpad .',
            ),
            BlenderMenuItem<String>(value: 'Zoom', label: 'Zoom Selected'),
          ],
          variant: BlenderButtonVariant.topBar,
          onSelected: _setStatus,
        ),
        BlenderMenuButton<String>(
          label: 'Select',
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: 'All',
              label: 'Select All',
              shortcut: 'A',
            ),
            BlenderMenuItem<String>(
              value: 'None',
              label: 'Select None',
              shortcut: 'Alt+A',
            ),
          ],
          variant: BlenderButtonVariant.topBar,
          onSelected: _setStatus,
        ),
        BlenderMenuButton<String>(
          label: 'Add',
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: 'Collection',
              label: 'Add Collection',
            ),
            BlenderMenuItem<String>(value: 'Node', label: 'Add Node'),
          ],
          variant: BlenderButtonVariant.topBar,
          onSelected: _setStatus,
        ),
      ],
      actions: <Widget>[
        BlenderIconButton(
          glyph: BlenderGlyph.grid,
          selected: _showGrid,
          onPressed: () => setState(() => _showGrid = !_showGrid),
          tooltip: 'Toggle grid',
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.wireframe,
          selected: _wireframe,
          onPressed: () => setState(() => _wireframe = !_wireframe),
          tooltip: 'Toggle wireframe',
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Area options',
        ),
      ],
    );
  }

  BlenderAreaHeader _buildImageEditorHeader(BlenderEditorType type) {
    final imageLabel = type == BlenderEditorType.uvEditor ? 'UV Map' : 'Image';
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      leading: <Widget>[
        SizedBox(
          width: 112,
          child: BlenderDropdown<String>(
            value: imageLabel,
            items: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: imageLabel, label: imageLabel),
            ],
            onChanged: _setStatus,
          ),
        ),
      ],
      menus: _editorMenus(<String>['View', 'Select', 'Image']),
      actions: <Widget>[
        const BlenderIconButton(
          glyph: BlenderGlyph.grid,
          tooltip: 'Display grid',
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  BlenderAreaHeader _buildAnimationEditorHeader(BlenderEditorType type) {
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      menus: _editorMenus(<String>['View', 'Marker', 'Playback']),
      actions: <Widget>[
        const BlenderIconButton(
          glyph: BlenderGlyph.play,
          tooltip: 'Play animation',
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  BlenderAreaHeader _buildNodeEditorHeader(BlenderEditorType type) {
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      leading: <Widget>[
        SizedBox(
          width: 86,
          child: BlenderDropdown<String>(
            value: type == BlenderEditorType.shaderEditor
                ? 'Object'
                : 'Tree Type',
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Object', label: 'Object'),
              BlenderMenuItem<String>(value: 'Tree Type', label: 'Tree Type'),
            ],
            onChanged: _setStatus,
          ),
        ),
      ],
      menus: _editorMenus(<String>['View', 'Select', 'Add', 'Node']),
      actions: const <Widget>[
        BlenderIconButton(glyph: BlenderGlyph.grid, tooltip: 'Toggle grid'),
        BlenderIconButton(glyph: BlenderGlyph.more, tooltip: 'Editor options'),
      ],
    );
  }

  BlenderAreaHeader _buildUtilityEditorHeader(BlenderEditorType type) {
    final menus = switch (type) {
      BlenderEditorType.textEditor => <String>['View', 'Text', 'Edit'],
      BlenderEditorType.pythonConsole => <String>['View', 'Console'],
      BlenderEditorType.fileBrowser ||
      BlenderEditorType.assetBrowser => <String>['View', 'Select'],
      BlenderEditorType.spreadsheet => <String>['View', 'Select'],
      _ => <String>['View'],
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      menus: _editorMenus(menus),
      actions: const <Widget>[
        BlenderIconButton(glyph: BlenderGlyph.more, tooltip: 'Editor options'),
      ],
    );
  }

  List<Widget> _editorMenus(List<String> labels) => <Widget>[
    for (final label in labels)
      BlenderMenuButton<String>(
        label: label,
        items: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: label, label: '$label Options'),
        ],
        variant: BlenderButtonVariant.topBar,
        onSelected: _setStatus,
      ),
  ];

  Widget _buildMainEditorSurface() {
    final surface = switch (_mainEditorType) {
      BlenderEditorType.view3d => BlenderRegion(
        title: null,
        child: ShowcaseViewport(
          selectedObject: _selectedObject,
          showGrid: _showGrid,
          wireframe: _wireframe,
        ),
      ),
      BlenderEditorType.imageEditor => const BlenderImageEditor(
        label: 'Image Editor placeholder',
      ),
      BlenderEditorType.uvEditor => const BlenderUVEditor(
        points: <BlenderUVPoint>[
          BlenderUVPoint(id: 'a', position: Offset(.18, .2)),
          BlenderUVPoint(id: 'b', position: Offset(.78, .2)),
          BlenderUVPoint(id: 'c', position: Offset(.78, .78)),
          BlenderUVPoint(id: 'd', position: Offset(.18, .78)),
        ],
        edges: <BlenderUVEdge>[
          BlenderUVEdge(from: 0, to: 1),
          BlenderUVEdge(from: 1, to: 2),
          BlenderUVEdge(from: 2, to: 3),
          BlenderUVEdge(from: 3, to: 0),
        ],
      ),
      BlenderEditorType.timeline => BlenderTimeline(
        model: _timelineModel,
        onCurrentFrameChanged: (value) => setState(() => _frame = value),
      ),
      BlenderEditorType.dopeSheet => BlenderDopeSheetEditor(
        model: _timelineModel,
        onCurrentFrameChanged: (value) => setState(() => _frame = value),
      ),
      BlenderEditorType.graphEditor => const BlenderCurveEditor(
        channels: <BlenderCurveChannel>[
          BlenderCurveChannel(
            id: 'location-x',
            label: 'Cube / Location X',
            points: <Offset>[
              Offset(0, .2),
              Offset(.35, .7),
              Offset(.7, .35),
              Offset(1, .8),
            ],
            color: Color(0xFFFF3352),
          ),
          BlenderCurveChannel(
            id: 'location-y',
            label: 'Cube / Location Y',
            points: <Offset>[
              Offset(0, .6),
              Offset(.35, .2),
              Offset(.7, .75),
              Offset(1, .4),
            ],
            color: Color(0xFF8BDC00),
          ),
        ],
      ),
      BlenderEditorType.nlaEditor => BlenderNLAEditor(
        strips: _sequenceStrips,
        start: 1,
        end: 120,
        currentFrame: _frame,
        onCurrentFrameChanged: (value) => setState(() => _frame = value),
      ),
      BlenderEditorType.drivers => const BlenderCurveEditor(
        channels: <BlenderCurveChannel>[
          BlenderCurveChannel(
            id: 'driver',
            label: 'Driver / Value',
            points: <Offset>[Offset(0, .25), Offset(.45, .6), Offset(1, .4)],
            color: Color(0xFFFFB74D),
          ),
        ],
      ),
      BlenderEditorType.sequencer ||
      BlenderEditorType.videoEditing => BlenderVideoSequencerEditor(
        strips: _sequenceStrips,
        start: 1,
        end: 120,
        currentFrame: _frame,
        onCurrentFrameChanged: (value) => setState(() => _frame = value),
      ),
      BlenderEditorType.clipEditor => const BlenderClipEditor(
        markers: <BlenderClipMarker>[
          BlenderClipMarker(id: 'track-a', position: Offset(120, 90)),
          BlenderClipMarker(id: 'track-b', position: Offset(260, 140)),
          BlenderClipMarker(id: 'track-c', position: Offset(410, 70)),
        ],
      ),
      BlenderEditorType.pythonConsole => BlenderConsoleEditor(
        lines: _consoleLines,
        onCommand: (command) => _setStatus('Ran: $command'),
      ),
      BlenderEditorType.infoEditor => const BlenderInfoEditor(
        reports: <BlenderInfoReport>[
          BlenderInfoReport(
            id: 'saved',
            message: 'Saved showcase.blend',
            level: BlenderNoticeLevel.success,
            timestamp: 'Now',
          ),
          BlenderInfoReport(
            id: 'preview',
            message: '3D viewport is represented by a lightweight 2D preview',
            level: BlenderNoticeLevel.info,
            timestamp: 'Now',
          ),
        ],
      ),
      BlenderEditorType.textEditor => const BlenderTextEditor(
        text: '# Blender UI text editor\nprint("Hello from Flutter")',
      ),
      BlenderEditorType.spreadsheet => BlenderSpreadsheetEditor(
        columns: _spreadsheetColumns,
        rows: _spreadsheetRows,
      ),
      BlenderEditorType.outliner => BlenderOutliner<String>(
        roots: _outlinerRoots,
        selectedId: _selectedObject.toLowerCase(),
        displayMode: _outlinerDisplayMode,
        onDisplayModeChanged: (mode) =>
            setState(() => _outlinerDisplayMode = mode),
        onSelected: (node) {
          if (node.value != null) _setStatus('Selected ${node.value}');
        },
      ),
      BlenderEditorType.properties => BlenderPropertiesEditor(
        groups: _propertyGroups,
      ),
      BlenderEditorType.preferences => BlenderPreferencesEditor(
        categories: const <String>['Interface', 'Editing', 'Keymap', 'System'],
        selectedCategory: _preferenceCategory,
        onCategoryChanged: (value) =>
            setState(() => _preferenceCategory = value),
        sections: <BlenderPreferenceSection>[
          BlenderPreferenceSection(
            id: 'theme',
            category: 'Interface',
            title: 'Theme',
            child: BlenderCheckbox(
              value: _showGrid,
              label: 'Show editor decorations',
              onChanged: (value) => setState(() => _showGrid = value),
            ),
          ),
          BlenderPreferenceSection(
            id: 'navigation',
            category: 'Editing',
            title: 'Navigation',
            child: BlenderSegmentedControl<String>(
              value: _wireframe ? 'Orbit' : 'Turntable',
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Turntable', label: 'Turntable'),
                BlenderMenuItem<String>(value: 'Orbit', label: 'Orbit'),
              ],
              onChanged: (value) =>
                  setState(() => _wireframe = value == 'Orbit'),
            ),
          ),
          BlenderPreferenceSection(
            id: 'input',
            category: 'Keymap',
            title: 'Input',
            child: BlenderPathField(
              controller: _searchController,
              placeholder: 'Keymap search path',
            ),
          ),
          const BlenderPreferenceSection(
            id: 'system',
            category: 'System',
            title: 'System',
            child: const BlenderProgressBar(value: .68, label: 'UI resources'),
          ),
        ],
      ),
      BlenderEditorType.fileBrowser => BlenderFileBrowser(
        entries: const <BlenderFileEntry>[
          BlenderFileEntry(
            path: '/showcase/assets',
            name: 'assets',
            isDirectory: true,
            detail: 'Folder',
          ),
          BlenderFileEntry(
            path: '/showcase/scene.blend',
            name: 'scene.blend',
            detail: '2.4 MB',
          ),
          BlenderFileEntry(
            path: '/showcase/materials.blend',
            name: 'materials.blend',
            detail: '840 KB',
          ),
          BlenderFileEntry(
            path: '/showcase/readme.txt',
            name: 'readme.txt',
            detail: 'Text file',
          ),
        ],
        searchController: _fileSearchController,
        pathSegments: const <String>['/', 'showcase'],
        selectedPath: _selectedFile,
        gridView: _fileGrid,
        onGridViewChanged: (value) => setState(() => _fileGrid = value),
        onSelected: (entry) => setState(() => _selectedFile = entry.path),
        onOpen: (entry) => _setStatus('Opened ${entry.name}'),
        onPathSelected: (index) => _setStatus('Path segment $index'),
      ),
      BlenderEditorType.assetBrowser => BlenderFileBrowser(
        entries: const <BlenderFileEntry>[
          BlenderFileEntry(
            path: '/showcase/assets',
            name: 'assets',
            isDirectory: true,
            detail: 'Asset Library',
          ),
          BlenderFileEntry(
            path: '/showcase/assets/cube.blend',
            name: 'cube.blend',
            detail: 'Object Asset',
          ),
          BlenderFileEntry(
            path: '/showcase/assets/materials.blend',
            name: 'materials.blend',
            detail: 'Material Asset',
          ),
        ],
        searchController: _fileSearchController,
        pathSegments: const <String>['/', 'assets'],
        selectedPath: _selectedFile,
        gridView: true,
        onSelected: (entry) => setState(() => _selectedFile = entry.path),
        onOpen: (entry) => _setStatus('Opened ${entry.name}'),
        onPathSelected: (index) => _setStatus('Asset path segment $index'),
      ),
      BlenderEditorType.shaderEditor ||
      BlenderEditorType.geometryNodeEditor ||
      BlenderEditorType.compositor ||
      BlenderEditorType.textureNodeEditor => BlenderNodeEditor(
        model: _nodeGraph,
        onNodeSelected: (node) => _setStatus('Selected node ${node.title}'),
        onNodeMoved: _moveNode,
      ),
    };
    return BlenderContextMenu<String>(
      items: const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
        BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
        BlenderMenuItem<String>(value: 'Frame', label: 'Frame Selected'),
      ],
      onSelected: _setStatus,
      child: surface,
    );
  }

  Widget _buildRightTopArea() {
    if (_rightTopEditorType != BlenderEditorType.outliner) {
      return _buildSwappableSidebarArea(
        editorType: _rightTopEditorType,
        onChanged: (value) => setState(() => _rightTopEditorType = value),
      );
    }
    return BlenderOutliner<String>(
      title: 'Scene Collection',
      roots: _outlinerRoots,
      selectedId: _selectedObject.toLowerCase(),
      editorType: _rightTopEditorType,
      onEditorTypeChanged: (value) =>
          setState(() => _rightTopEditorType = value),
      displayMode: _outlinerDisplayMode,
      onDisplayModeChanged: (mode) =>
          setState(() => _outlinerDisplayMode = mode),
      showVisibility: true,
      showLock: true,
      headerActions: <Widget>[
        SizedBox(
          width: 108,
          child: BlenderSearchField(
            controller: _outlinerSearchController,
            placeholder: 'Search',
          ),
        ),
      ],
      onSelected: (node) {
        setState(() => _selectedObject = node.value ?? node.label);
        _setStatus('Selected ${node.label}');
      },
      onVisibilityChanged: (node) =>
          _setStatus('${node.visible ? 'Hide' : 'Show'} ${node.label}'),
      onLockChanged: (node) =>
          _setStatus('${node.locked ? 'Unlock' : 'Lock'} ${node.label}'),
    );
  }

  Widget _buildRightBottomArea() {
    if (_rightBottomEditorType == BlenderEditorType.properties) {
      return _buildPropertiesColumn();
    }
    return _buildSwappableSidebarArea(
      editorType: _rightBottomEditorType,
      onChanged: (value) => setState(() => _rightBottomEditorType = value),
    );
  }

  Widget _buildSwappableSidebarArea({
    required BlenderEditorType editorType,
    required ValueChanged<BlenderEditorType> onChanged,
  }) {
    return BlenderEditorFrame(
      child: Column(
        children: <Widget>[
          BlenderAreaHeader(
            height: 30,
            editorType: editorType,
            showEditorLabel: false,
            onEditorTypeChanged: onChanged,
            menus: _editorMenus(<String>['View']),
            actions: const <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.more,
                tooltip: 'Editor options',
              ),
            ],
          ),
          Expanded(
            child: BlenderRegion(
              title: editorType.label,
              child: Center(
                child: Text(
                  '${editorType.label} assigned to this area',
                  style: BlenderTheme.of(context).textTheme.caption,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesColumn() {
    return Column(
      children: <Widget>[
        _buildPropertiesHeader(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlenderPropertyTabs(
                tabs: _propertyTabs,
                visibleTabIds: _visiblePropertyTabIds,
                onVisibilityChanged: _setVisiblePropertyTabs,
                selectedIndex: _propertyTab,
                onChanged: (value) {
                  setState(() => _propertyTab = value);
                  _setStatus('Properties tab changed');
                },
              ),
              Expanded(
                child: BlenderSplitter(
                  direction: BlenderSplitDirection.vertical,
                  initialFraction: .72,
                  first: BlenderPropertiesEditor(
                    groups: _visiblePropertyGroups,
                    searchController: _propertiesSearchController,
                    body: _propertyTab == 0 ? _buildToolSettingsBody() : null,
                    topContent: _propertyTab == 5 ? _propertyTopContent : null,
                    joinNavigationRail: true,
                    title: _propertiesContextTitle,
                    headerLeading: BlenderIcon(
                      _propertiesContextGlyph,
                      size: 18,
                      color: _propertyTab == 0 ? const Color(0xFFFFB84A) : null,
                    ),
                    headerActions: _propertyTab == 0
                        ? null
                        : <Widget>[
                            BlenderIconButton(
                              glyph: BlenderGlyph.pin,
                              selected: false,
                              onPressed: () => _setStatus('Properties pinned'),
                              tooltip: 'Pin Properties context',
                              size: 24,
                            ),
                          ],
                  ),
                  second: BlenderPanel(
                    title: 'Quick Controls',
                    child: BlenderScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          BlenderButton(
                            label: 'Apply Modifier',
                            onPressed: () => _setStatus('Modifier applied'),
                          ),
                          const SizedBox(height: 6),
                          BlenderButton(
                            label: 'Add Keyframe',
                            onPressed: () => _setStatus('Keyframe added'),
                          ),
                          const SizedBox(height: 6),
                          BlenderButton(
                            label: 'Reset Object',
                            onPressed: () => _setStatus('Object reset'),
                          ),
                          const BlenderSeparator(),
                          Text(
                            'Viewport Display',
                            style: BlenderTheme.of(context).textTheme.heading,
                          ),
                          const SizedBox(height: 4),
                          BlenderSegmentedControl<String>(
                            value: _wireframe ? 'Wire' : 'Solid',
                            items: const <BlenderMenuItem<String>>[
                              BlenderMenuItem<String>(
                                value: 'Solid',
                                label: 'Solid',
                              ),
                              BlenderMenuItem<String>(
                                value: 'Wire',
                                label: 'Wire',
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _wireframe = value == 'Wire'),
                          ),
                          const SizedBox(height: 6),
                          BlenderColorField(
                            label: 'Accent',
                            color: _accentColor,
                            onPressed: () => _setStatus('Color picker focused'),
                          ),
                          const SizedBox(height: 6),
                          BlenderColorPicker(
                            color: _accentColor,
                            onChanged: (value) =>
                                setState(() => _accentColor = value),
                          ),
                          const SizedBox(height: 6),
                          const BlenderProgressBar(
                            value: .68,
                            label: 'Preview 68%',
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Shortcuts',
                            style: BlenderTheme.of(context).textTheme.heading,
                          ),
                          const SizedBox(height: 4),
                          const Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: const <Widget>[
                              BlenderKeycap('G'),
                              SizedBox(width: 4),
                              Text('Move'),
                              BlenderKeycap('R'),
                              SizedBox(width: 4),
                              Text('Rotate'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPropertiesHeader() {
    return BlenderAreaHeader(
      key: const ValueKey<String>('properties-area-header'),
      // Blender keeps the area-type selector separate from the Properties
      // context caption below it. Selecting another type swaps this area.
      height: 26,
      background: BlenderTheme.of(context).colors.propertiesBackground,
      editorType: _rightBottomEditorType,
      showEditorLabel: false,
      onEditorTypeChanged: (value) =>
          setState(() => _rightBottomEditorType = value),
      leading: const <Widget>[],
      menus: const <Widget>[],
      center: SizedBox(
        // Blender's string-property search occupies six 20px widget units.
        width: 120,
        child: BlenderSearchField(
          controller: _propertiesSearchController,
          placeholder: 'Search',
        ),
      ),
      showBottomBorder: false,
      actions: <Widget>[_buildPropertiesContextOptions()],
    );
  }

  void _setVisiblePropertyTabs(Set<String> visible) {
    setState(() {
      _visiblePropertyTabIds = visible;
      if (!visible.contains(_propertyTabs[_propertyTab].id)) {
        _propertyTab = _propertyTabs.indexWhere(
          (tab) => visible.contains(tab.id),
        );
      }
    });
  }

  Widget _buildPropertiesContextOptions() {
    final theme = BlenderTheme.of(context);
    return BlenderPopover(
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      onOpenChanged: (open) =>
          setState(() => _propertiesContextMenuOpen = open),
      child: BlenderIconButton(
        key: const ValueKey<String>('properties-context-options-button'),
        glyph: BlenderGlyph.panelDisclosureDown,
        selected: _propertiesContextMenuOpen,
        tooltip: 'Properties context options',
        size: 20,
      ),
      popover: (context, close) => SizedBox(
        width: 320,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.menuBackground,
            border: Border.all(color: theme.colors.borderSubtle),
            borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Sync with Outliner',
                  style: theme.textTheme.body.copyWith(
                    color: theme.colors.foregroundMuted,
                  ),
                ),
                const SizedBox(height: 8),
                BlenderSegmentedControl<String>(
                  value: _syncWithOutliner,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'Always', label: 'Always'),
                    BlenderMenuItem<String>(value: 'Never', label: 'Never'),
                    BlenderMenuItem<String>(value: 'Auto', label: 'Auto'),
                  ],
                  onChanged: (value) =>
                      setState(() => _syncWithOutliner = value),
                ),
                const SizedBox(height: 14),
                BlenderCheckbox(
                  value: _propertiesSelectable,
                  label: 'Selectable',
                  onChanged: (value) =>
                      setState(() => _propertiesSelectable = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomEditor() {
    final bottomLabel = switch (_bottomTab) {
      0 => 'Timeline',
      1 => 'Action',
      2 => 'Shader Editor',
      3 => 'Spreadsheet',
      4 => 'Keymap',
      _ => 'UI Catalog',
    };
    return Column(
      children: <Widget>[
        BlenderToolbar(
          height: 30,
          scrollable: true,
          children: <Widget>[
            BlenderIconButton(
              glyph: _bottomTab == 1
                  ? BlenderGlyph.action
                  : BlenderGlyph.timeline,
              tooltip: _bottomTab == 1 ? 'Action editor' : 'Timeline editor',
              size: 24,
            ),
            BlenderMenuButton<int>(
              label: bottomLabel,
              items: const <BlenderMenuItem<int>>[
                BlenderMenuItem<int>(value: 0, label: 'Timeline'),
                BlenderMenuItem<int>(value: 1, label: 'Action'),
                BlenderMenuItem<int>(value: 2, label: 'Shader Editor'),
                BlenderMenuItem<int>(value: 3, label: 'Spreadsheet'),
                BlenderMenuItem<int>(value: 4, label: 'Keymap'),
                BlenderMenuItem<int>(value: 5, label: 'UI Catalog'),
              ],
              onSelected: (value) => setState(() => _bottomTab = value),
            ),
            BlenderMenuButton<String>(
              label: 'View',
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Frame', label: 'Frame All'),
                BlenderMenuItem<String>(
                  value: 'Selected',
                  label: 'Frame Selected',
                ),
              ],
              onSelected: _setStatus,
            ),
            BlenderMenuButton<String>(
              label: 'Marker',
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'Add Marker',
                  label: 'Add Marker',
                ),
                BlenderMenuItem<String>(
                  value: 'Rename',
                  label: 'Rename Marker',
                ),
              ],
              onSelected: _setStatus,
            ),
            if (_bottomTab == 1) ...<Widget>[
              BlenderMenuButton<String>(
                label: 'Select',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'All', label: 'All Keyframes'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
                onSelected: _setStatus,
              ),
              BlenderMenuButton<String>(
                label: 'Channel',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Group',
                    label: 'Group Channels',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Delete',
                    label: 'Delete Channels',
                  ),
                ],
                onSelected: _setStatus,
              ),
              BlenderMenuButton<String>(
                label: 'Key',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Insert',
                    label: 'Insert Keyframes',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Delete',
                    label: 'Delete Keyframes',
                  ),
                ],
                onSelected: _setStatus,
              ),
              SizedBox(
                width: 220,
                child: BlenderActionSelector<String>(
                  value: _activeAction,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'CubeAction',
                      label: 'CubeAction',
                    ),
                    BlenderMenuItem<String>(
                      value: 'CameraAction',
                      label: 'CameraAction',
                    ),
                  ],
                  onChanged: (value) => setState(() => _activeAction = value),
                  onNew: () => _setStatus('New Action'),
                  onUnlink: () => _setStatus('Unlink Action'),
                  userCount: 1,
                ),
              ),
            ],
            BlenderMenuButton<String>(
              label: 'Playback',
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Play', label: 'Play Animation'),
                BlenderMenuItem<String>(value: 'Loop', label: 'Loop Playback'),
              ],
              onSelected: _setStatus,
            ),
            BlenderPlaybackControls(
              playing: _playing,
              onFirst: () => setState(() => _frame = 1),
              onPrevious: () => setState(
                () => _frame = (_frame - 1).clamp(1, 120).toDouble(),
              ),
              onPlay: () => setState(() => _playing = !_playing),
              onNext: () => setState(
                () => _frame = (_frame + 1).clamp(1, 120).toDouble(),
              ),
              onLast: () => setState(() => _frame = 120),
              onRecord: () => _setStatus('Record toggled'),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 110,
              child: BlenderNumberField(
                value: _frame,
                min: 1,
                max: 120,
                step: 1,
                decimalDigits: 0,
                onChanged: (value) => setState(() => _frame = value),
              ),
            ),
            const SizedBox(width: 6),
            Text('$_status'),
          ],
        ),
        Expanded(child: _buildBottomContent()),
      ],
    );
  }

  Widget _buildBottomContent() {
    return switch (_bottomTab) {
      0 => BlenderTimeline(
        title: null,
        model: _timelineModel,
        onCurrentFrameChanged: (value) => setState(() => _frame = value),
      ),
      1 => BlenderDopeSheetEditor(
        title: 'Action',
        model: _actionModel,
        onCurrentFrameChanged: (value) => setState(() => _frame = value),
      ),
      2 => BlenderNodeEditor(
        model: _nodeGraph,
        onNodeSelected: (node) => _setStatus('Selected node ${node.title}'),
        onNodeMoved: _moveNode,
      ),
      3 => BlenderSpreadsheetEditor(
        columns: _spreadsheetColumns,
        rows: _spreadsheetRows,
      ),
      4 => BlenderKeymapEditor(
        searchController: _keymapSearchController,
        selectedId: _selectedShortcut,
        entries: const <BlenderKeymapEntry>[
          BlenderKeymapEntry(
            id: 'move',
            action: 'Move',
            shortcut: 'G',
            category: '3D View',
          ),
          BlenderKeymapEntry(
            id: 'rotate',
            action: 'Rotate',
            shortcut: 'R',
            category: '3D View',
          ),
          BlenderKeymapEntry(
            id: 'save',
            action: 'Save Mainfile',
            shortcut: 'Ctrl+S',
            category: 'Window',
          ),
        ],
        onSelected: (entry) => setState(() {
          _selectedShortcut = entry.id;
          _status = 'Selected ${entry.action}';
        }),
      ),
      _ => _buildControlGallery(),
    };
  }

  Widget _buildControlGallery() {
    return BlenderPanel(
      title: 'UI Catalog',
      padding: EdgeInsets.zero,
      child: BlenderScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Core controls',
                style: BlenderTheme.of(context).textTheme.heading,
              ),
              const SizedBox(height: 6),
              BlenderFlow(
                children: <Widget>[
                  for (final variant in BlenderButtonVariant.values)
                    BlenderButton(
                      label: variant.name,
                      variant: variant,
                      onPressed: () => _setStatus('${variant.name} pressed'),
                    ),
                  BlenderIconButton(
                    glyph: BlenderGlyph.settings,
                    onPressed: () => _setStatus('Icon pressed'),
                    tooltip: 'Catalog icon button',
                  ),
                  BlenderButton(
                    label: 'Alert dialog',
                    onPressed: _showCatalogAlert,
                  ),
                  BlenderButton(
                    label: 'Property dialog',
                    onPressed: _showCatalogPropertyDialog,
                  ),
                  BlenderOperatorRedoPopup(
                    title: 'Set Frame Range',
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      BlenderPropertyDescriptor<double>(
                        id: 'start',
                        label: 'Start',
                        value: _frameStart,
                        editorBuilder: (context, value, onChanged) =>
                            BlenderNumberField(
                              value: value,
                              min: 1,
                              max: 10000,
                              decimalDigits: 0,
                              onChanged: onChanged,
                            ),
                        onChanged: (value) =>
                            setState(() => _frameStart = value),
                      ),
                      BlenderPropertyDescriptor<bool>(
                        id: 'preview',
                        label: 'Preview Range',
                        value: _renderRegion,
                        editorBuilder: (context, value, onChanged) =>
                            BlenderCheckbox(
                              value: value,
                              label: '',
                              onChanged: onChanged,
                            ),
                        onChanged: (value) =>
                            setState(() => _renderRegion = value),
                      ),
                    ],
                  ),
                  BlenderCheckbox(
                    value: _useSmoothShading,
                    label: 'Checkbox',
                    onChanged: (value) =>
                        setState(() => _useSmoothShading = value),
                  ),
                  BlenderToggle(
                    value: _galleryToggle,
                    label: 'Toggle',
                    onChanged: (value) =>
                        setState(() => _galleryToggle = value),
                  ),
                  BlenderRadio<String>(
                    value: 'Regular',
                    groupValue: _galleryMode,
                    label: 'Radio',
                    onChanged: (value) => setState(() => _galleryMode = value),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: BlenderSlider(
                      value: _gallerySlider,
                      onChanged: (value) =>
                          setState(() => _gallerySlider = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 120,
                    child: BlenderNumberField(
                      value: _gallerySlider,
                      min: 0,
                      max: 1,
                      step: .01,
                      onChanged: (value) =>
                          setState(() => _gallerySlider = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Templates',
                style: BlenderTheme.of(context).textTheme.heading,
              ),
              const SizedBox(height: 6),
              BlenderVectorField(
                values: <double>[_locationX, _locationY, _gallerySlider],
                onChanged: (values) => setState(() {
                  _locationX = values[0];
                  _locationY = values[1];
                  _gallerySlider = values[2];
                }),
              ),
              const SizedBox(height: 6),
              BlenderMatrixField(
                values: _galleryMatrix,
                rowLabels: const <String>['X', 'Y', 'Z'],
                columnLabels: const <String>['X', 'Y', 'Z'],
                onChanged: (values) => setState(() => _galleryMatrix = values),
              ),
              const SizedBox(height: 6),
              BlenderMatrixTransformPanel(
                values: const BlenderMatrixTransformValues(
                  location: <double>[1.25, -0.5, 3],
                  rotation: <double>[0, 45, 90],
                  scale: <double>[1, 1, 1],
                  hasShear: true,
                ),
                onRotationModeChanged: (mode) =>
                    _setStatus('Rotation mode: $mode'),
              ),
              const SizedBox(height: 6),
              BlenderAttributeSearch<String>(
                value: _galleryAttribute,
                options: const <BlenderAttributeOption<String>>[
                  BlenderAttributeOption<String>(
                    name: 'position',
                    value: 'position',
                    domain: 'Point',
                    dataType: 'Float3',
                  ),
                  BlenderAttributeOption<String>(
                    name: 'uv_map',
                    value: 'uv_map',
                    domain: 'Corner',
                    dataType: 'Float2',
                  ),
                  BlenderAttributeOption<String>(
                    name: 'material_index',
                    value: 'material_index',
                    domain: 'Face',
                    dataType: 'Int',
                  ),
                ],
                onChanged: (value) => setState(() => _galleryAttribute = value),
                onCreate: (value) => setState(() => _galleryAttribute = value),
                onClear: () => setState(() => _galleryAttribute = null),
              ),
              const SizedBox(height: 6),
              BlenderLayerSelector(
                layers: [
                  for (var index = 1; index <= 8; index++)
                    BlenderLayerItem(
                      id: '$index',
                      label: '$index',
                      active: _galleryLayers.contains('$index'),
                      used: index == 2 || index == 5,
                    ),
                ],
                onChanged: (value) =>
                    setState(() => _galleryLayers = value.toSet()),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: BlenderUnitVector(
                      value: _galleryVector,
                      onChanged: (value) =>
                          setState(() => _galleryVector = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BlenderPathField(
                      controller: _galleryPathController,
                      onBrowse: () => _setStatus('Browse path'),
                      placeholder: 'File name',
                    ),
                  ),
                  const SizedBox(width: 8),
                  const BlenderPreviewTile(label: 'Preview'),
                ],
              ),
              const SizedBox(height: 6),
              BlenderPreviewPanel(
                preview: const ColoredBox(
                  color: Color(0xFF202020),
                  child: Center(
                    child: BlenderIcon(BlenderGlyph.material, size: 56),
                  ),
                ),
                previewModes: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Material', label: 'Material'),
                  BlenderMenuItem<String>(value: 'World', label: 'World'),
                ],
                previewMode: 'Material',
                onPreviewModeChanged: (value) =>
                    _setStatus('Preview mode: $value'),
                usePreviewWorld: true,
                onUsePreviewWorldChanged: (value) =>
                    _setStatus('Preview world: $value'),
                textureModes: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Texture', label: 'Texture'),
                  BlenderMenuItem<String>(value: 'Material', label: 'Material'),
                  BlenderMenuItem<String>(value: 'Both', label: 'Both'),
                ],
                textureMode: 'Both',
                onTextureModeChanged: (value) =>
                    _setStatus('Texture mode: $value'),
                usePreviewAlpha: true,
                onUsePreviewAlphaChanged: (value) =>
                    _setStatus('Preview alpha: $value'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: BlenderSearchMenu<String>(
                  controller: _operatorSearchController,
                  title: 'Search Preview',
                  previewRows: 2,
                  previewColumns: 4,
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
                    BlenderMenuItem<String>(
                      value: 'material',
                      label: 'Material',
                      icon: BlenderIcon(BlenderGlyph.material, size: 30),
                    ),
                    BlenderMenuItem<String>(
                      value: 'world',
                      label: 'World',
                      icon: BlenderIcon(BlenderGlyph.world, size: 30),
                    ),
                  ],
                  onSelected: (item) => _setStatus('Search: ${item.label}'),
                ),
              ),
              const SizedBox(height: 8),
              BlenderFileOperatorPanel(
                operatorName: 'Open Blender File',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<bool>(
                    id: 'relative-path',
                    label: 'Relative Path',
                    value: true,
                    editorBuilder: (context, value, onChanged) =>
                        BlenderCheckbox(
                          value: value,
                          label: '',
                          onChanged: onChanged,
                        ),
                    onChanged: (value) => _setStatus('Relative path: $value'),
                  ),
                  BlenderPropertyDescriptor<String>(
                    id: 'display',
                    label: 'Display',
                    value: 'Thumbnails',
                    editorBuilder: (context, value, onChanged) =>
                        BlenderDropdown<String>(
                          value: value,
                          items: const <BlenderMenuItem<String>>[
                            BlenderMenuItem<String>(
                              value: 'Thumbnails',
                              label: 'Thumbnails',
                            ),
                            BlenderMenuItem<String>(
                              value: 'List',
                              label: 'List',
                            ),
                          ],
                          onChanged: onChanged,
                        ),
                    onChanged: (value) => _setStatus('Display: $value'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderFileExecutionPanel(
                filenameController: _galleryPathController,
                overwriteAlert: true,
                onDecrement: () => _setStatus('Previous filename'),
                onIncrement: () => _setStatus('Next filename'),
                onCancel: () => _setStatus('File operation canceled'),
                onExecute: () => _setStatus('Overwrite file'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 270,
                child: BlenderFileBrowserHint(
                  title: 'Internet Access Required',
                  icon: BlenderGlyph.internetOffline,
                  message:
                      'Allow Online Access in order to browse and download online assets, or turn off the "Remote Assets" filter to show only the downloaded assets.\n\nYou can adjust this later from the "System" preferences.',
                  actions: <BlenderFileBrowserHintAction>[
                    BlenderFileBrowserHintAction(
                      label: 'Continue Offline',
                      icon: BlenderGlyph.close,
                      onPressed: () => _setStatus('Continue offline'),
                    ),
                    BlenderFileBrowserHintAction(
                      label: 'Allow Online Access',
                      icon: BlenderGlyph.check,
                      onPressed: () => _setStatus('Allow online access'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 250,
                child: BlenderFileAssetCatalogPanel(
                  libraryValue: 'Local',
                  libraryItems: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'Local', label: 'Local'),
                    BlenderMenuItem<String>(
                      value: 'Essentials',
                      label: 'Essentials',
                    ),
                  ],
                  catalogRoots: const <BlenderTreeNode<String>>[
                    BlenderTreeNode<String>(
                      id: 'environment',
                      label: 'Environment',
                      icon: BlenderGlyph.collection,
                      initiallyExpanded: true,
                      children: <BlenderTreeNode<String>>[
                        BlenderTreeNode<String>(
                          id: 'studio',
                          label: 'Studio Lighting',
                          icon: BlenderGlyph.folder,
                          value: 'studio',
                        ),
                        BlenderTreeNode<String>(
                          id: 'outdoor',
                          label: 'Outdoor',
                          icon: BlenderGlyph.folder,
                          value: 'outdoor',
                        ),
                      ],
                    ),
                  ],
                  onLibraryChanged: (value) => _setStatus('Library: $value'),
                  onRefresh: () => _setStatus('Refresh asset library'),
                  onBundleInstall: () => _setStatus('Install asset bundle'),
                  onNewCatalog: (node) =>
                      _setStatus('New catalog under ${node.label}'),
                  onCatalogContextMenuSelected: (node, action) =>
                      _setStatus('$action catalog: ${node.label}'),
                  onSelected: (node) => _setStatus('Catalog: ${node.label}'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 360,
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
                      isEssentials: true,
                      builtIn: true,
                      includeOnlineEssentials: true,
                    ),
                    BlenderAssetLibraryPreference(
                      id: 'local',
                      name: 'Studio Assets',
                      path: '/showcase/assets',
                      enabled: true,
                      useRelativePath: true,
                    ),
                    BlenderAssetLibraryPreference(
                      id: 'remote',
                      name: 'Remote Repository',
                      isRemote: true,
                      remoteUrl: 'https://assets.example.test',
                      importMethod: 'Append',
                      invalid: true,
                    ),
                  ],
                  onSelected: (library) =>
                      _setStatus('Asset library: ${library.name}'),
                  onEnabledChanged: (library, value) =>
                      _setStatus('${library.name}: enabled $value'),
                  onPathChanged: (library, value) =>
                      _setStatus('${library.name}: $value'),
                  onImportMethodChanged: (library, value) =>
                      _setStatus('${library.name}: import $value'),
                  onRelativePathChanged: (library, value) =>
                      _setStatus('${library.name}: relative $value'),
                  onIncludeOnlineEssentialsChanged: (value) =>
                      _setStatus('Online Essentials: $value'),
                  onAdd: () => _setStatus('Add asset library'),
                  onRemove: () => _setStatus('Remove asset library'),
                ),
              ),
              const SizedBox(height: 8),
              BlenderTextureUserSelector(
                selectedId: 'noise',
                users: const <BlenderTextureUser>[
                  BlenderTextureUser(
                    id: 'noise',
                    name: 'Base Color',
                    textureName: 'Noise Texture',
                    category: 'Material',
                    icon: BlenderGlyph.texture,
                  ),
                  BlenderTextureUser(
                    id: 'roughness',
                    name: 'Roughness',
                    textureName: 'Musgrave',
                    category: 'Material',
                    icon: BlenderGlyph.texture,
                  ),
                ],
                onChanged: (user) => _setStatus('Texture user: ${user.name}'),
                onShowTexture: () => _setStatus('Show texture in Texture tab'),
              ),
              const SizedBox(height: 8),
              BlenderCollectionImporterPanel(
                importer: BlenderCollectionImporter(
                  label: 'FBX Importer',
                  filepathController: _importerPathController,
                  properties: <BlenderPropertyDescriptor<dynamic>>[
                    BlenderPropertyDescriptor<bool>(
                      id: 'keep-collections',
                      label: 'Keep Collections',
                      value: true,
                      editorBuilder: (context, value, onChanged) =>
                          BlenderCheckbox(
                            value: value,
                            label: '',
                            onChanged: onChanged,
                          ),
                      onChanged: (value) =>
                          _setStatus('Keep collections: $value'),
                    ),
                  ],
                  onRemove: () => _setStatus('Remove collection importer'),
                  onBrowse: () => _setStatus('Browse importer path'),
                ),
              ),
              const SizedBox(height: 8),
              BlenderCollectionExportersPanel(
                selectedId: _selectedExporterId,
                exporters: <BlenderCollectionExporter>[
                  BlenderCollectionExporter(
                    id: 'gltf',
                    label: 'glTF 2.0',
                    filepathController: _exporterPathController,
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      BlenderPropertyDescriptor<bool>(
                        id: 'apply-modifiers',
                        label: 'Apply Modifiers',
                        value: true,
                        editorBuilder: (context, value, onChanged) =>
                            BlenderCheckbox(
                              value: value,
                              label: '',
                              onChanged: onChanged,
                            ),
                        onChanged: (value) =>
                            _setStatus('Apply modifiers: $value'),
                      ),
                      BlenderPropertyDescriptor<double>(
                        id: 'scale',
                        label: 'Scale',
                        value: 1,
                        editorBuilder: (context, value, onChanged) =>
                            BlenderNumberField(
                              value: value,
                              min: .01,
                              max: 100,
                              step: .1,
                              onChanged: onChanged,
                            ),
                      ),
                    ],
                  ),
                  const BlenderCollectionExporter(
                    id: 'usd',
                    label: 'USD',
                    valid: false,
                  ),
                ],
                onSelected: (exporter) => setState(() {
                  _selectedExporterId = exporter.id;
                  _setStatus('Exporter: ${exporter.label}');
                }),
                onAdd: () => _setStatus('Add collection exporter'),
                onRemove: () => _setStatus('Remove collection exporter'),
                onMoveUp: () => _setStatus('Move exporter up'),
                onMoveDown: () => _setStatus('Move exporter down'),
                onExportAll: () => _setStatus('Export all collections'),
                onExport: () => _setStatus('Export collection'),
                onPresets: () => _setStatus('Exporter presets'),
                onBrowse: () => _setStatus('Browse exporter path'),
              ),
              const SizedBox(height: 8),
              BlenderColorPalette(
                title: 'Palette',
                colors: const <Color>[
                  Color(0xFFB84A4A),
                  Color(0xFFD68A3B),
                  Color(0xFFD5C34A),
                  Color(0xFF6DAA5C),
                  Color(0xFF4F8EA8),
                  Color(0xFF7965A8),
                  Color(0xFFB45B91),
                  Color(0xFF6E747A),
                ],
                selectedIndex: 2,
                onSelected: (index) => _setStatus('Palette color $index'),
                onAdd: () => _setStatus('Add palette color'),
                onRemove: () => _setStatus('Remove palette color'),
                onMoveUp: () => _setStatus('Move palette color up'),
                onMoveDown: () => _setStatus('Move palette color down'),
                sortItems: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'hue', label: 'Hue'),
                  BlenderMenuItem<String>(
                    value: 'saturation',
                    label: 'Saturation',
                  ),
                  BlenderMenuItem<String>(value: 'value', label: 'Value'),
                  BlenderMenuItem<String>(
                    value: 'luminance',
                    label: 'Luminance',
                  ),
                ],
                onSort: (value) => _setStatus('Sort palette by $value'),
              ),
              const SizedBox(height: 8),
              BlenderColorRamp(
                stops: _galleryRamp,
                onChanged: (stops) => setState(() => _galleryRamp = stops),
                onAdd: _addGalleryRampStop,
                onRemove: _removeGalleryRampStop,
              ),
              const SizedBox(height: 8),
              BlenderCurveMapping(
                points: _galleryCurve,
                onChanged: (points) => setState(() => _galleryCurve = points),
              ),
              const SizedBox(height: 8),
              BlenderCurveProfile(
                points: _galleryProfile,
                presets: const <BlenderCurveProfilePreset>[
                  BlenderCurveProfilePreset(
                    name: 'Default',
                    points: <Offset>[Offset(0, 0), Offset(1, 1)],
                  ),
                  BlenderCurveProfilePreset(
                    name: 'Support Loops',
                    points: <Offset>[
                      Offset(0, 0),
                      Offset(.25, .1),
                      Offset(1, 1),
                    ],
                  ),
                ],
                onChanged: (points) => setState(() => _galleryProfile = points),
              ),
              const SizedBox(height: 8),
              const BlenderScopeView(
                type: BlenderScopeType.waveform,
                title: 'Waveform',
                height: 120,
                series: <BlenderScopeSeries>[
                  BlenderScopeSeries(
                    color: Color(0xFF71A8FF),
                    points: <Offset>[
                      Offset(0, .2),
                      Offset(.12, .65),
                      Offset(.24, .4),
                      Offset(.38, .85),
                      Offset(.52, .3),
                      Offset(.68, .72),
                      Offset(.82, .48),
                      Offset(1, .8),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderColorManagement(
                settings: _galleryColorManagement,
                onChanged: (settings) =>
                    setState(() => _galleryColorManagement = settings),
              ),
              const SizedBox(height: 8),
              BlenderDataBlockField<String>(
                label: 'Material',
                value: 'Principled',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Principled',
                    label: 'Principled BSDF',
                    icon: BlenderIcon(BlenderGlyph.material, size: 14),
                  ),
                  BlenderMenuItem<String>(
                    value: 'Toon',
                    label: 'Toon Material',
                    icon: BlenderIcon(BlenderGlyph.material, size: 14),
                  ),
                  BlenderMenuItem<String>(
                    value: 'Glass',
                    label: 'Glass Material',
                    icon: BlenderIcon(BlenderGlyph.material, size: 14),
                  ),
                ],
                showPreviews: true,
                userCount: 3,
                fakeUser: true,
                linked: true,
                onChanged: (value) => _setStatus('Material: $value'),
                onNew: () => _setStatus('Make new material'),
                onOpen: () => _setStatus('Open material'),
                onMakeSingleUser: () => _setStatus('Make material single-user'),
                onMakeLocal: () => _setStatus('Make material local'),
                onToggleFakeUser: (value) => _setStatus('Fake user: $value'),
                onUnlink: () => _setStatus('Unlink material'),
              ),
              const SizedBox(height: 8),
              BlenderActionSelector<String>(
                value: 'walk',
                label: 'Action',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'walk',
                    label: 'Walk Cycle',
                    icon: BlenderIcon(BlenderGlyph.action, size: 14),
                  ),
                  BlenderMenuItem<String>(
                    value: 'idle',
                    label: 'Idle',
                    icon: BlenderIcon(BlenderGlyph.action, size: 14),
                  ),
                ],
                userCount: 2,
                onChanged: (value) => _setStatus('Action: $value'),
                onNew: () => _setStatus('New action'),
                onUnlink: () => _setStatus('Unlink action'),
              ),
              const SizedBox(height: 8),
              BlenderCryptoPicker(
                label: 'Cryptomatte',
                onPressed: () => _setStatus('Pick Cryptomatte color'),
              ),
              const SizedBox(height: 8),
              BlenderKeymapItemProperties(
                title: 'Keymap Item Properties',
                properties: <BlenderKeymapProperty>[
                  BlenderKeymapProperty(
                    id: 'repeat',
                    label: 'Repeat',
                    editor: BlenderCheckbox(
                      value: true,
                      label: 'Repeat',
                      onChanged: (_) {},
                    ),
                    onUnset: () => _setStatus('Unset repeat'),
                  ),
                  BlenderKeymapProperty(
                    id: 'threshold',
                    label: 'Threshold',
                    editor: BlenderNumberField(
                      value: .5,
                      min: 0,
                      max: 1,
                      step: .05,
                      onChanged: (_) {},
                    ),
                    onUnset: () => _setStatus('Unset threshold'),
                  ),
                  BlenderKeymapProperty(
                    id: 'direction',
                    label: 'Direction',
                    editor: const Text('Inherited'),
                    isSet: false,
                    onUnset: () => _setStatus('Unset direction'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderModifierStack(
                modifiers: <BlenderModifierDescriptor>[
                  BlenderModifierDescriptor(
                    id: 'bevel',
                    name: 'Bevel',
                    icon: BlenderGlyph.modifier,
                    child: BlenderNumberField(
                      value: .1,
                      label: 'Amount',
                      min: 0,
                      max: 1,
                      step: .01,
                      onChanged: (_) {},
                    ),
                    onToggleEnabled: () => _setStatus('Toggle Bevel'),
                    onToggleViewport: () => _setStatus('Toggle viewport'),
                    onToggleRender: () => _setStatus('Toggle render'),
                    onMoveUp: () => _setStatus('Move Bevel up'),
                    onMoveDown: () => _setStatus('Move Bevel down'),
                    onRemove: () => _setStatus('Remove Bevel'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderNodeInputs(
                groups: <BlenderNodeInputGroup>[
                  BlenderNodeInputGroup(
                    id: 'surface',
                    title: 'Surface',
                    inputs: <BlenderNodeInputDescriptor>[
                      const BlenderNodeInputDescriptor(
                        id: 'color',
                        label: 'Base Color',
                        editor: BlenderColorSwatch(color: Color(0xFF4772B3)),
                      ),
                      BlenderNodeInputDescriptor(
                        id: 'roughness',
                        label: 'Roughness',
                        editor: BlenderNumberField(
                          value: .35,
                          min: 0,
                          max: 1,
                          step: .01,
                          onChanged: (_) {},
                        ),
                      ),
                      const BlenderNodeInputDescriptor(
                        id: 'normal',
                        label: 'Normal',
                        editor: SizedBox.shrink(),
                        linked: true,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const BlenderNoticeBanner(
                message: 'Drag the color-ramp handles and curve points.',
                level: BlenderNoticeLevel.info,
              ),
              const SizedBox(height: 8),
              BlenderReportBanner(
                message: 'Preview built successfully. Click to open Info.',
                level: BlenderNoticeLevel.success,
                onPressed: () => _setStatus('Info report opened'),
              ),
              const SizedBox(height: 8),
              BlenderStatusInfo(
                statusText: 'Scene 1  |  Collection  |  12 Objects',
                versionText: 'Blender 4.5.0',
                extensionStatus: BlenderExtensionStatus.updates,
                extensionCount: 2,
                onExtensionPressed: () => _setStatus('Open extension updates'),
                warningMessage: 'Color Management',
                warningTooltip: 'Displays or color spaces were changed',
                onWarningPressed: () => _setStatus('Open color management'),
              ),
              const SizedBox(height: 8),
              const BlenderInputStatus(
                items: <BlenderInputStatusItem>[
                  BlenderInputStatusItem(
                    event: 'LMB drag',
                    label: 'Split/Dock',
                  ),
                  BlenderInputStatusItem(
                    modifiers: <String>['Shift'],
                    event: 'LMB drag',
                    label: 'Duplicate into Window',
                  ),
                  BlenderInputStatusItem(
                    modifiers: <String>['Ctrl'],
                    event: 'LMB drag',
                    label: 'Swap Areas',
                  ),
                  BlenderInputStatusItem(event: 'MMB drag', label: 'Pan'),
                  BlenderInputStatusItem(event: 'RMB', label: 'Options'),
                  BlenderInputStatusItem(
                    modifiers: <String>['Shift'],
                    events: <String>['X', 'Y', 'Z'],
                    label: 'Axis',
                  ),
                  BlenderInputStatusItem(
                    events: <String>['X', 'Y', 'Z'],
                    label: 'Plane',
                  ),
                  BlenderInputStatusItem(
                    events: <String>['+', '-', 'Wheel'],
                    label: 'Proportional Size',
                  ),
                  BlenderInputStatusItem(
                    label: 'Active object has non-uniform scale',
                    icon: BlenderGlyph.warning,
                    warning: true,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const BlenderStatusContextBar(
                kind: BlenderStatusContextKind.splitDock,
              ),
              const SizedBox(height: 8),
              const BlenderStatusContextBar(
                kind: BlenderStatusContextKind.header,
              ),
              const SizedBox(height: 8),
              const BlenderStatusContextBar(
                kind: BlenderStatusContextKind.viewportWarning,
                warningText: 'Active object has non-uniform scale',
              ),
              const SizedBox(height: 8),
              BlenderJobProgress(
                name: 'Building preview',
                progress: .68,
                icon: BlenderGlyph.image,
                onCancel: () => _setStatus('Preview build canceled'),
              ),
              const SizedBox(height: 8),
              BlenderRecentFiles(
                files: const <BlenderRecentFile>[
                  BlenderRecentFile(
                    id: 'scene',
                    name: 'showcase.blend',
                    path: '/showcase/showcase.blend',
                    detail: '2.4 MB',
                  ),
                  BlenderRecentFile(
                    id: 'library',
                    name: 'materials.blend',
                    path: '/showcase/materials.blend',
                    detail: '840 KB',
                  ),
                ],
                onSelected: (file) => _setStatus('Opened ${file.name}'),
              ),
              const SizedBox(height: 8),
              BlenderConstraintStack(
                constraints: <BlenderConstraintDescriptor>[
                  BlenderConstraintDescriptor(
                    id: 'copy-location',
                    name: 'Copy Location',
                    icon: BlenderGlyph.transform,
                    child: BlenderPropertyRow(
                      label: 'Influence',
                      editor: BlenderNumberField(
                        value: .75,
                        min: 0,
                        max: 1,
                        step: .01,
                        onChanged: (_) {},
                      ),
                    ),
                    onToggleEnabled: () => _setStatus('Constraint toggled'),
                    onMenu: () => _setStatus('Constraint menu'),
                    onMoveUp: () => _setStatus('Constraint moved up'),
                    onMoveDown: () => _setStatus('Constraint moved down'),
                    onRemove: () => _setStatus('Constraint removed'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderShaderEffectStack(
                effects: <BlenderShaderEffectDescriptor>[
                  BlenderShaderEffectDescriptor(
                    id: 'shadow',
                    name: 'Drop Shadow',
                    child: BlenderPropertyRow(
                      label: 'Opacity',
                      editor: BlenderNumberField(
                        value: .5,
                        min: 0,
                        max: 1,
                        step: .01,
                        onChanged: (_) {},
                      ),
                    ),
                    onToggleEnabled: () => _setStatus('Shader effect toggled'),
                    onMoveUp: () => _setStatus('Shader effect moved up'),
                    onMoveDown: () => _setStatus('Shader effect moved down'),
                    onRemove: () => _setStatus('Shader effect removed'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const BlenderNodeTreeInterface(
                items: <BlenderNodeInterfaceItem>[
                  BlenderNodeInterfaceItem.panel(
                    BlenderNodeInterfacePanel(
                      id: 'surface',
                      name: 'Surface',
                      children: <BlenderNodeInterfaceItem>[
                        BlenderNodeInterfaceItem.socket(
                          BlenderNodeInterfaceSocket(
                            id: 'base-color',
                            label: 'Base Color',
                            input: true,
                            color: Color(0xFF8BC34A),
                          ),
                        ),
                        BlenderNodeInterfaceItem.socket(
                          BlenderNodeInterfaceSocket(
                            id: 'shader',
                            label: 'Shader',
                            input: false,
                            output: true,
                            color: Color(0xFFFFB74D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderBoneCollectionTree(
                collections: <BlenderBoneCollection>[
                  BlenderBoneCollection(
                    id: 'rig',
                    name: 'Rig Controls',
                    active: true,
                    children: <BlenderBoneCollection>[
                      BlenderBoneCollection(
                        id: 'deform',
                        name: 'Deform',
                        hasSelectedBones: true,
                        onActivate: () => _setStatus('Deform active'),
                        onVisibilityChanged: (value) =>
                            _setStatus('Deform visible: $value'),
                        onSoloChanged: (value) =>
                            _setStatus('Deform solo: $value'),
                      ),
                      BlenderBoneCollection(
                        id: 'controls',
                        name: 'Controls',
                        solo: true,
                        onActivate: () => _setStatus('Controls active'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderAssetShelfPopover(
                label: 'Asset Shelf',
                big: true,
                assets: const <BlenderAssetShelfPopoverItem>[
                  BlenderAssetShelfPopoverItem(
                    id: 'cube',
                    label: 'Cube',
                    color: Color(0xFF4772B3),
                  ),
                  BlenderAssetShelfPopoverItem(
                    id: 'sphere',
                    label: 'Sphere',
                    color: Color(0xFFAC8737),
                  ),
                  BlenderAssetShelfPopoverItem(
                    id: 'light',
                    label: 'Studio Light',
                    color: Color(0xFF6A8F65),
                  ),
                ],
                onSelected: (asset) => _setStatus('Selected ${asset.label}'),
              ),
              const SizedBox(height: 8),
              BlenderComponentMenu<String>(
                value: _galleryMode,
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Regular', label: 'Regular'),
                  BlenderMenuItem<String>(value: 'Compact', label: 'Compact'),
                  BlenderMenuItem<String>(value: 'Expanded', label: 'Expanded'),
                ],
                onChanged: (value) => setState(() => _galleryMode = value),
              ),
              const SizedBox(height: 8),
              BlenderIconView<String>(
                value: _galleryMode,
                items: const <BlenderIconViewItem<String>>[
                  BlenderIconViewItem<String>(
                    value: 'Regular',
                    label: 'Regular',
                    icon: BlenderIcon(BlenderGlyph.object, size: 30),
                  ),
                  BlenderIconViewItem<String>(
                    value: 'Compact',
                    label: 'Compact',
                    icon: BlenderIcon(BlenderGlyph.collection, size: 30),
                  ),
                  BlenderIconViewItem<String>(
                    value: 'Expanded',
                    label: 'Expanded',
                    icon: BlenderIcon(BlenderGlyph.material, size: 30),
                  ),
                  BlenderIconViewItem<String>(
                    value: 'Preview',
                    label: 'Preview',
                    icon: BlenderIcon(BlenderGlyph.image, size: 30),
                  ),
                ],
                onChanged: (value) => setState(() => _galleryMode = value),
              ),
              const SizedBox(height: 8),
              BlenderCompactList<String>(
                selectedIndex: _galleryListIndex,
                onChanged: (value) => setState(() => _galleryListIndex = value),
                items: const <BlenderListItem<String>>[
                  BlenderListItem<String>(
                    id: 'one',
                    label: 'First component',
                    value: 'one',
                    detail: 'A',
                  ),
                  BlenderListItem<String>(
                    id: 'two',
                    label: 'Second component',
                    value: 'two',
                    detail: 'B',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderCacheFilePanel(
                settings: _galleryCacheFile,
                onChanged: (settings) =>
                    setState(() => _galleryCacheFile = settings),
                onBrowse: () => _setStatus('Browse cache file'),
                onReload: () => _setStatus('Reload cache file'),
              ),
              const SizedBox(height: 8),
              BlenderLightLinkingCollection(
                collectionLabel: 'Studio Lights',
                items: <BlenderLightLinkingItem>[
                  BlenderLightLinkingItem(
                    id: 'key',
                    label: 'Key Light',
                    icon: BlenderGlyph.light,
                    onStateChanged: (state) =>
                        _setStatus('Key Light ${state.name}'),
                  ),
                  BlenderLightLinkingItem(
                    id: 'fill',
                    label: 'Fill Collection',
                    icon: BlenderGlyph.collection,
                    state: BlenderLightLinkingState.exclude,
                    onStateChanged: (state) =>
                        _setStatus('Fill Collection ${state.name}'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderGreasePencilLayerTree(
                searchController: _layerSearchController,
                layers: <BlenderGreasePencilLayer>[
                  BlenderGreasePencilLayer(
                    id: 'characters',
                    name: 'Characters',
                    isGroup: true,
                    active: true,
                    children: <BlenderGreasePencilLayer>[
                      BlenderGreasePencilLayer(
                        id: 'outline',
                        name: 'Outline',
                        useMasks: true,
                        onActivate: () => _setStatus('Outline active'),
                        onMasksChanged: (value) =>
                            _setStatus('Outline masks: $value'),
                        onHiddenChanged: (value) =>
                            _setStatus('Outline hidden: $value'),
                        onLockedChanged: (value) =>
                            _setStatus('Outline locked: $value'),
                      ),
                      BlenderGreasePencilLayer(
                        id: 'fill',
                        name: 'Fill',
                        useOnionSkinning: true,
                        onActivate: () => _setStatus('Fill active'),
                      ),
                    ],
                  ),
                  BlenderGreasePencilLayer(
                    id: 'background',
                    name: 'Background',
                    onActivate: () => _setStatus('Background active'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addGalleryRampStop() {
    setState(() {
      _galleryRamp = <BlenderColorRampStop>[
        ..._galleryRamp,
        const BlenderColorRampStop(position: .5, color: Color(0xFFAC8737)),
      ];
    });
  }

  void _showCatalogAlert() {
    showBlenderAlertDialog(
      context: context,
      title: 'Unsaved Changes',
      message:
          'The current workspace has unsaved changes.\nSave before closing?',
      icon: BlenderGlyph.warning,
      confirmLabel: 'Save',
      onConfirm: () => _setStatus('Workspace saved'),
      onCancel: () => _setStatus('Save canceled'),
    );
  }

  void _showCatalogPropertyDialog() {
    showBlenderOperatorPropertiesDialog(
      context: context,
      title: 'Set Frame Range',
      message: 'Choose the range used by the active scene.',
      confirmLabel: 'Apply',
      onConfirm: () => _setStatus('Frame range updated'),
      properties: <BlenderPropertyDescriptor<dynamic>>[
        BlenderPropertyDescriptor<double>(
          id: 'start',
          label: 'Start',
          value: _frameStart,
          editorBuilder: (context, value, onChanged) => BlenderNumberField(
            value: value,
            min: 1,
            max: 10000,
            decimalDigits: 0,
            onChanged: onChanged,
          ),
          onChanged: (value) => setState(() => _frameStart = value),
        ),
        BlenderPropertyDescriptor<double>(
          id: 'end',
          label: 'End',
          value: _frameEnd,
          editorBuilder: (context, value, onChanged) => BlenderNumberField(
            value: value,
            min: 1,
            max: 10000,
            decimalDigits: 0,
            onChanged: onChanged,
          ),
          onChanged: (value) => setState(() => _frameEnd = value),
        ),
        BlenderPropertyDescriptor<bool>(
          id: 'preview',
          label: 'Use Preview Range',
          value: _renderRegion,
          editorBuilder: (context, value, onChanged) =>
              BlenderCheckbox(value: value, label: '', onChanged: onChanged),
          onChanged: (value) => setState(() => _renderRegion = value),
        ),
      ],
    );
  }

  void _removeGalleryRampStop() {
    if (_galleryRamp.length <= 2) return;
    setState(
      () => _galleryRamp = _galleryRamp.sublist(0, _galleryRamp.length - 1),
    );
  }
}

/// Keeps Blender's aligned transform value, lock decorator, and animation
/// decorator together as one reusable value-column control.
class _ObjectTransformValueEditor extends StatelessWidget {
  const _ObjectTransformValueEditor({
    required this.value,
    required this.decimalDigits,
    required this.locked,
    required this.onChanged,
    required this.onLockChanged,
    required this.onKeyframe,
    this.suffix,
  });

  final double value;
  final int decimalDigits;
  final bool locked;
  final ValueChanged<double> onChanged;
  final VoidCallback onLockChanged;
  final VoidCallback onKeyframe;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: BlenderNumberField(
            value: value,
            step: decimalDigits == 0 ? 1 : .1,
            decimalDigits: decimalDigits,
            suffix: suffix,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 3),
        Semantics(
          button: true,
          label: locked ? 'Unlock transform axis' : 'Lock transform axis',
          child: BlenderIconButton(
            glyph: locked ? BlenderGlyph.lock : BlenderGlyph.unlock,
            selected: locked,
            tooltip: locked ? 'Unlock transform axis' : 'Lock transform axis',
            size: 20,
            onPressed: onLockChanged,
          ),
        ),
        _ObjectKeyframeDot(
          color: theme.colors.foreground,
          onPressed: onKeyframe,
        ),
      ],
    );
  }
}

class _ObjectRotationModeEditor extends StatelessWidget {
  const _ObjectRotationModeEditor({
    required this.value,
    required this.onChanged,
    required this.onKeyframe,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onKeyframe;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: BlenderDropdown<String>(
            value: value,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'XYZ Euler', label: 'XYZ Euler'),
              BlenderMenuItem<String>(value: 'XZY Euler', label: 'XZY Euler'),
              BlenderMenuItem<String>(value: 'YXZ Euler', label: 'YXZ Euler'),
              BlenderMenuItem<String>(value: 'Quaternion', label: 'Quaternion'),
              BlenderMenuItem<String>(value: 'Axis Angle', label: 'Axis Angle'),
            ],
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 23),
        _ObjectKeyframeDot(
          color: BlenderTheme.of(context).colors.foreground,
          onPressed: onKeyframe,
        ),
      ],
    );
  }
}

class _ObjectKeyframeDot extends StatelessWidget {
  const _ObjectKeyframeDot({required this.color, required this.onPressed});

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Insert keyframe',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: 14,
          height: 20,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: 5),
            ),
          ),
        ),
      ),
    );
  }
}
