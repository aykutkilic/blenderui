import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../demo/demo_workbench.dart';
import 'showcase_status_bar.dart';
import '../showcase_viewport.dart';

part 'showcase_catalog_actions.dart';

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final BlenderApplicationController<Object?> _application =
      BlenderApplicationController<Object?>(
        initialState: null,
        workspace: const BlenderDockSplitNode<String>(
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
  final TextEditingController _mainOutlinerSearchController =
      TextEditingController();
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
  final bool _showGrid = true;
  bool _wireframe = false;
  String _viewportShading = 'Solid';
  bool _showGizmos = true;
  bool _showOverlays = true;
  bool _showXray = false;
  String _transformOrientation = 'Global';
  String _transformPivot = 'Median Point';
  bool _snapEnabled = false;
  bool _proportionalEditing = false;
  int _workspaceIndex = 0;
  int _toolIndex = 0;
  int _propertyTab = 0;
  String _renderEngine = 'Eevee';
  BlenderOutlinerDisplayMode _outlinerDisplayMode =
      BlenderOutlinerDisplayMode.viewLayer;
  bool _outlinerSyncSelection = true;
  String _outlinerOverrideViewMode = 'Hierarchies';
  bool _outlinerUseIdFilter = false;
  String _outlinerIdFilterType = 'All';
  final bool _outlinerHasKeyingSet = true;
  String _outlinerKeyingSet = 'Location';
  Set<String> _visiblePropertyTabIds = <String>{
    'tool',
    'render',
    'output',
    'view_layer',
    'scene',
    'world',
    'collection',
    'object',
    'modifier',
    'shaderfx',
    'particles',
    'physics',
    'constraint',
    'data',
    'bone',
    'bone_constraint',
    'material',
    'texture',
    'strip',
    'strip_modifier',
  };
  int _bottomTab = 0;
  String _activeAction = 'CubeAction';
  bool _animationOverlays = true;
  final bool _animationAutoKeying = false;
  final bool _animationPlayheadSnap = false;
  final bool _animationProportional = false;
  bool _animationSelectedOnly = true;
  bool _animationShowErrors = false;
  bool _animationShowSeconds = false;
  bool _animationShowLockedTime = false;
  bool _graphNormalize = false;
  bool _graphAutoNormalize = false;
  bool _graphGhostCurves = false;
  final bool _graphSnap = false;
  final bool _graphProportional = false;
  String _nodeTreeContext = 'Object';
  bool _nodeShowBackdrop = false;
  bool _nodeGizmos = false;
  bool _nodeSnap = false;
  bool _nodeOverlays = true;
  bool _nlaSnap = false;
  bool _nlaSelectedOnly = true;
  bool _nlaShowHidden = false;
  bool _nlaShowMissing = false;
  bool _nlaShowErrors = false;
  String _clipMode = 'Tracking';
  String _clipView = 'Clip';
  bool _clipGizmos = true;
  bool _clipOverlays = true;
  bool _clipProportional = false;
  bool _imageUvSync = false;
  bool _imageSnap = false;
  bool _imageProportional = false;
  bool _imageGizmos = true;
  bool _imageOverlays = true;
  bool _spreadsheetOnlySelected = false;
  bool _spreadsheetFilter = false;
  String _sequencerViewType = 'Sequencer & Preview';
  String _sequencerDisplayMode = 'Image';
  String _sequencerOverlapMode = 'Overwrite';
  bool _sequencerSnap = false;
  bool _sequencerGizmos = true;
  bool _sequencerOverlays = true;
  String _preferenceCategory = 'Interface';
  bool _lockObjectModes = true;
  bool _playing = false;
  bool _fileGrid = false;
  bool _galleryToggle = true;
  String _galleryMode = 'Regular';
  int _galleryListIndex = 0;
  String _frameRate = '24 fps';
  String _mediaType = 'Image';
  String _fileFormat = 'PNG (.png)';
  String _colorMode = 'RGBA';
  String _colorDepth = '8';
  double _compression = 36;
  String _selectionMode = 'Set';
  String _syncWithOutliner = 'Auto';
  bool _propertiesContextMenuOpen = false;
  bool _toolOptionsExpanded = true;
  bool _toolTransformExpanded = true;
  bool _toolWorkspaceExpanded = false;
  bool _toolWorkspaceFilterExpanded = true;
  bool _toolBrushExpanded = true;
  bool _toolBrushSettingsExpanded = true;
  final Map<String, bool> _toolBrushPanelExpanded = <String, bool>{};
  final Map<String, bool> _toolModePanelExpanded = <String, bool>{};
  bool _workspacePinScene = false;
  bool _workspaceSyncTime = true;
  String _workspaceMode = 'Object Mode';
  bool _workspaceFilterByOwner = true;
  bool _workspaceAnimationAddon = true;
  bool _workspaceModelingAddon = true;
  bool _workspaceUnknownAddon = false;
  bool _toolAffectOrigins = false;
  bool _toolAffectLocations = false;
  bool _toolAffectParents = false;
  bool _stereoscopy = false;
  String _formatPreset = 'Custom';

  BlenderGlyph get _dataPropertiesGlyph => switch (_selectedObject) {
    'Camera' => BlenderGlyph.camera,
    'Light' => BlenderGlyph.light,
    'Curve' => BlenderGlyph.curve,
    'Text' => BlenderGlyph.curve,
    'Curves' => BlenderGlyph.curves,
    'Point Cloud' => BlenderGlyph.pointcloud,
    'Speaker' => BlenderGlyph.speaker,
    'Volume' => BlenderGlyph.volume,
    'Light Probe' => BlenderGlyph.lightprobe,
    'Grease Pencil' => BlenderGlyph.greasepencil,
    'Empty' => BlenderGlyph.empty,
    'Lattice' => BlenderGlyph.lattice,
    'Metaball' => BlenderGlyph.metaball,
    'Armature' => BlenderGlyph.armature,
    'Bone' => BlenderGlyph.bone,
    _ => BlenderGlyph.mesh,
  };

  String get _dataPropertiesTitle => switch (_selectedObject) {
    'Camera' => 'Camera Data',
    'Light' => 'Light Data',
    'Curve' => 'Curve Data',
    'Text' => 'Text Data',
    'Curves' => 'Curves Data',
    'Point Cloud' => 'Point Cloud Data',
    'Speaker' => 'Speaker Data',
    'Volume' => 'Volume Data',
    'Light Probe' => 'Light Probe Data',
    'Grease Pencil' => 'Grease Pencil Data',
    'Empty' => 'Empty Data',
    'Lattice' => 'Lattice Data',
    'Metaball' => 'Metaball Data',
    'Armature' => 'Armature Data',
    'Bone' => 'Bone Properties',
    _ => 'Mesh Data',
  };

  List<BlenderPropertyTab> get _propertyTabs => <BlenderPropertyTab>[
    const BlenderPropertyTab(
      id: 'tool',
      label: 'Tool',
      glyph: BlenderGlyph.tool,
      group: 0,
    ),
    const BlenderPropertyTab(
      id: 'render',
      label: 'Render',
      glyph: BlenderGlyph.render,
      group: 1,
    ),
    const BlenderPropertyTab(
      id: 'output',
      label: 'Output',
      glyph: BlenderGlyph.output,
      group: 1,
    ),
    const BlenderPropertyTab(
      id: 'view_layer',
      label: 'View Layer',
      glyph: BlenderGlyph.viewLayer,
      group: 2,
    ),
    const BlenderPropertyTab(
      id: 'scene',
      label: 'Scene',
      glyph: BlenderGlyph.scene,
      group: 2,
    ),
    const BlenderPropertyTab(
      id: 'world',
      label: 'World',
      glyph: BlenderGlyph.world,
      group: 2,
    ),
    const BlenderPropertyTab(
      id: 'collection',
      label: 'Collection',
      glyph: BlenderGlyph.collection,
      group: 3,
    ),
    const BlenderPropertyTab(
      id: 'object',
      label: 'Object',
      glyph: BlenderGlyph.object,
      group: 3,
    ),
    const BlenderPropertyTab(
      id: 'modifier',
      label: 'Modifiers',
      glyph: BlenderGlyph.modifier,
      group: 3,
    ),
    const BlenderPropertyTab(
      id: 'shaderfx',
      label: 'Effects',
      glyph: BlenderGlyph.shaderfx,
      group: 5,
    ),
    const BlenderPropertyTab(
      id: 'particles',
      label: 'Particles',
      glyph: BlenderGlyph.physics,
      group: 6,
    ),
    const BlenderPropertyTab(
      id: 'physics',
      label: 'Physics',
      glyph: BlenderGlyph.physics,
      group: 6,
    ),
    const BlenderPropertyTab(
      id: 'constraint',
      label: 'Constraints',
      glyph: BlenderGlyph.link,
      group: 3,
    ),
    BlenderPropertyTab(
      id: 'data',
      label: 'Data',
      glyph: _dataPropertiesGlyph,
      group: 5,
    ),
    const BlenderPropertyTab(
      id: 'bone',
      label: 'Bone',
      glyph: BlenderGlyph.bone,
      group: 5,
    ),
    const BlenderPropertyTab(
      id: 'bone_constraint',
      label: 'Bone Constraints',
      glyph: BlenderGlyph.link,
      group: 3,
    ),
    const BlenderPropertyTab(
      id: 'material',
      label: 'Material',
      glyph: BlenderGlyph.material,
      group: 4,
    ),
    const BlenderPropertyTab(
      id: 'texture',
      label: 'Texture',
      glyph: BlenderGlyph.texture,
      group: 4,
    ),
    const BlenderPropertyTab(
      id: 'strip',
      label: 'Strip',
      glyph: BlenderGlyph.sequence,
      group: 7,
    ),
    const BlenderPropertyTab(
      id: 'strip_modifier',
      label: 'Strip Modifiers',
      glyph: BlenderGlyph.modifier,
      group: 7,
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
    _application.dispose();
    _searchController.dispose();
    _fileSearchController.dispose();
    _keymapSearchController.dispose();
    _mainOutlinerSearchController.dispose();
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
                id: 'curve',
                label: 'Curve',
                value: 'Curve',
                icon: BlenderGlyph.curve,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'curve-data',
                    label: 'Curve',
                    icon: BlenderGlyph.curve,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'curves',
                label: 'Curves',
                value: 'Curves',
                icon: BlenderGlyph.curves,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'curves-data',
                    label: 'Curves',
                    icon: BlenderGlyph.curves,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'point-cloud',
                label: 'Point Cloud',
                value: 'Point Cloud',
                icon: BlenderGlyph.pointcloud,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'point-cloud-data',
                    label: 'Point Cloud',
                    icon: BlenderGlyph.pointcloud,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'speaker',
                label: 'Speaker',
                value: 'Speaker',
                icon: BlenderGlyph.speaker,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'speaker-data',
                    label: 'Speaker',
                    icon: BlenderGlyph.speaker,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'volume',
                label: 'Volume',
                value: 'Volume',
                icon: BlenderGlyph.volume,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'volume-data',
                    label: 'Volume',
                    icon: BlenderGlyph.volume,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'light-probe',
                label: 'Light Probe',
                value: 'Light Probe',
                icon: BlenderGlyph.lightprobe,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'light-probe-data',
                    label: 'Light Probe',
                    icon: BlenderGlyph.lightprobe,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'grease-pencil',
                label: 'Grease Pencil',
                value: 'Grease Pencil',
                icon: BlenderGlyph.greasepencil,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'grease-pencil-data',
                    label: 'Grease Pencil',
                    icon: BlenderGlyph.greasepencil,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'empty',
                label: 'Empty',
                value: 'Empty',
                icon: BlenderGlyph.empty,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'empty-data',
                    label: 'Empty',
                    icon: BlenderGlyph.empty,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'lattice',
                label: 'Lattice',
                value: 'Lattice',
                icon: BlenderGlyph.lattice,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'lattice-data',
                    label: 'Lattice',
                    icon: BlenderGlyph.lattice,
                    iconColor: colors.iconObjectData,
                  ),
                ],
              ),
              BlenderTreeNode<String>(
                id: 'metaball',
                label: 'Metaball',
                value: 'Metaball',
                icon: BlenderGlyph.metaball,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'metaball-data',
                    label: 'Metaball',
                    icon: BlenderGlyph.metaball,
                    iconColor: colors.iconObjectData,
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
              BlenderTreeNode<String>(
                id: 'armature',
                label: 'Armature',
                value: 'Armature',
                icon: BlenderGlyph.armature,
                iconColor: colors.iconObject,
                initiallyExpanded: true,
                children: <BlenderTreeNode<String>>[
                  BlenderTreeNode<String>(
                    id: 'armature-data',
                    label: 'Armature',
                    icon: BlenderGlyph.armature,
                    iconColor: colors.iconObjectData,
                  ),
                  BlenderTreeNode<String>(
                    id: 'armature-bone',
                    label: 'Bone',
                    value: 'Bone',
                    icon: BlenderGlyph.bone,
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
    BlenderPropertyDescriptor<bool> boolProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> choice(
      String id,
      String label,
      String value,
      List<String> values,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: <BlenderMenuItem<String>>[
            for (final item in values)
              BlenderMenuItem<String>(value: item, label: item),
          ],
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

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
        initiallyExpanded: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderPathField(
              controller: _galleryPathController,
              onBrowse: () => _setStatus('Browse output path'),
              placeholder: '/tmp/',
            ),
            const SizedBox(height: 4),
            BlenderPropertyRow(
              label: 'Saving',
              editor: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BlenderCheckbox(
                    value: _fileExtensions,
                    label: 'File Extensions',
                    onChanged: (value) =>
                        setState(() => _fileExtensions = value),
                  ),
                  BlenderCheckbox(
                    value: _cacheResult,
                    label: 'Cache Result',
                    onChanged: (value) => setState(() => _cacheResult = value),
                  ),
                ],
              ),
            ),
          ],
        ),
        properties: <BlenderPropertyDescriptor<dynamic>>[
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
          BlenderPropertyDescriptor<String>(
            id: 'color-depth',
            label: 'Color Depth',
            value: _colorDepth,
            editorBuilder: (context, value, onChanged) =>
                BlenderSegmentedControl<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: '8', label: '8'),
                    BlenderMenuItem<String>(value: '16', label: '16'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (value) => setState(() => _colorDepth = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'compression',
            label: 'Compression',
            value: _compression,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 100,
              decimalDigits: 0,
              suffix: '%',
              onChanged: onChanged,
            ),
            onChanged: (value) => setState(() => _compression = value),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'post-processing',
        title: 'Post Processing',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          boolProperty('post-compositing', 'Compositing', true),
          boolProperty('post-sequencer', 'Sequencer', true),
          numberProperty('post-dither', 'Dither', 1, min: 0, max: 2),
        ],
      ),
      BlenderPropertyGroup(
        id: 'metadata',
        title: 'Metadata',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          choice('metadata-input', 'Input', 'Scene', <String>[
            'Scene',
            'Strip',
          ]),
          boolProperty('metadata-date', 'Date', true),
          boolProperty('metadata-time', 'Time', true),
          boolProperty('metadata-frame', 'Frame', true),
          boolProperty('metadata-camera', 'Camera', false),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'metadata-note',
            title: 'Note',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              boolProperty('metadata-note-enabled', 'Use Note', false),
              choice('metadata-note-text', 'Text', 'Showcase render', <String>[
                'Showcase render',
                'Preview output',
              ]),
            ],
          ),
          BlenderPropertyGroup(
            id: 'metadata-burn',
            title: 'Burn Into Image',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              boolProperty('metadata-burn-enabled', 'Use Stamp', false),
              numberProperty(
                'metadata-font-size',
                'Font Size',
                24,
                min: 8,
                max: 128,
                decimalDigits: 0,
              ),
              boolProperty('metadata-labels', 'Include Labels', true),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'views',
        title: 'Views',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          choice('views-format', 'Views Format', 'Individual', <String>[
            'Individual',
            'Stereo 3D',
          ]),
          boolProperty('views-left', 'Left', true),
          boolProperty('views-right', 'Right', true),
        ],
      ),
      BlenderPropertyGroup(
        id: 'output-color-management',
        title: 'Color Management',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          choice(
            'output-color-mode',
            'Color Management',
            'Follow Scene',
            <String>['Follow Scene', 'Override'],
          ),
          choice('output-display-device', 'Display Device', 'sRGB', <String>[
            'sRGB',
            'Display P3',
          ]),
          choice('output-view-transform', 'View Transform', 'AgX', <String>[
            'AgX',
            'Standard',
          ]),
        ],
      ),
      BlenderPropertyGroup(
        id: 'pixel-density',
        title: 'Pixel Density',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'pixel-density-pixels',
            'Pixels',
            72,
            min: 1,
            max: 10000,
            decimalDigits: 0,
          ),
          choice('pixel-density-unit', 'Unit', 'Inch', <String>[
            'Inch',
            'Centimeter',
            'Meter',
            'Custom',
          ]),
          numberProperty('pixel-density-base', 'Base', .0254, min: 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'encoding',
        title: 'Encoding',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          choice('encoding-container', 'Container', 'MPEG-4', <String>[
            'MPEG-4',
            'Matroska',
            'WebM',
          ]),
          boolProperty('encoding-autosplit', 'Autosplit Output', false),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'encoding-video',
            title: 'Video',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              choice('encoding-codec', 'Codec', 'H.264', <String>[
                'H.264',
                'H.265',
                'AV1',
              ]),
              choice('encoding-quality', 'Quality', 'Medium', <String>[
                'Low',
                'Medium',
                'High',
              ]),
              numberProperty(
                'encoding-bitrate',
                'Bitrate',
                8,
                min: 1,
                max: 1000,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'encoding-audio',
            title: 'Audio',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              choice('encoding-audio-codec', 'Audio Codec', 'AAC', <String>[
                'AAC',
                'FLAC',
                'PCM',
              ]),
              choice('encoding-audio-channels', 'Channels', 'Stereo', <String>[
                'Mono',
                'Stereo',
                '5.1',
              ]),
              numberProperty(
                'encoding-sample-rate',
                'Sample Rate',
                48000,
                min: 8000,
                max: 192000,
                decimalDigits: 0,
              ),
            ],
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _workbenchRenderPropertyGroups {
    const aaChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: '2', label: '2'),
      BlenderMenuItem<String>(value: '4', label: '4'),
      BlenderMenuItem<String>(value: '8', label: '8'),
      BlenderMenuItem<String>(value: '16', label: '16'),
    ];
    const lightingChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Studio', label: 'Studio'),
      BlenderMenuItem<String>(value: 'Matcap', label: 'Matcap'),
      BlenderMenuItem<String>(value: 'Flat', label: 'Flat'),
    ];
    const colorChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Material', label: 'Material'),
      BlenderMenuItem<String>(value: 'Object', label: 'Object'),
      BlenderMenuItem<String>(value: 'Random', label: 'Random'),
      BlenderMenuItem<String>(value: 'Texture', label: 'Texture'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyGroup panel(
      String id,
      String title, {
      bool expanded = false,
      List<BlenderPropertyDescriptor<dynamic>> properties =
          const <BlenderPropertyDescriptor<dynamic>>[],
      List<BlenderPropertyGroup> children = const <BlenderPropertyGroup>[],
    }) {
      return BlenderPropertyGroup(
        id: id,
        title: title,
        initiallyExpanded: expanded,
        properties: properties,
        children: children,
      );
    }

    return <BlenderPropertyGroup>[
      panel(
        'workbench-sampling',
        'Sampling',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('workbench-render-aa', 'Render', '8', aaChoices),
          enumProperty('workbench-viewport-aa', 'Viewport', '8', aaChoices),
        ],
      ),
      panel(
        'workbench-film',
        'Film',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('workbench-transparent', 'Transparent', false),
        ],
      ),
      panel(
        'workbench-lighting',
        'Lighting',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'workbench-lighting-type',
            'Lighting',
            'Studio',
            lightingChoices,
          ),
          enumProperty(
            'workbench-studio-light',
            'Studio Light',
            'Basic.sl',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem(value: 'Basic.sl', label: 'Basic.sl'),
              BlenderMenuItem(value: 'Paint.sl', label: 'Paint.sl'),
            ],
          ),
          booleanProperty(
            'workbench-world-lighting',
            'World Space Lighting',
            false,
          ),
          numberProperty('workbench-light-rotation', 'Rotation', 0),
        ],
      ),
      panel(
        'workbench-color',
        'Object Color',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'workbench-color-type',
            'Color Type',
            'Material',
            colorChoices,
          ),
          enumProperty(
            'workbench-background-type',
            'Background',
            'Theme',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem(value: 'Theme', label: 'Theme'),
              BlenderMenuItem(value: 'World', label: 'World'),
              BlenderMenuItem(value: 'Viewport', label: 'Viewport'),
            ],
          ),
        ],
      ),
      panel(
        'workbench-options',
        'Options',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty(
            'workbench-backface-culling',
            'Backface Culling',
            false,
          ),
          booleanProperty('workbench-outline', 'Outline', true),
          booleanProperty('workbench-xray', 'X-Ray', false),
          booleanProperty('workbench-shadows', 'Shadows', true),
          booleanProperty('workbench-depth-of-field', 'Depth of Field', false),
          booleanProperty('workbench-cavity', 'Cavity', true),
          numberProperty('workbench-shadow-direction', 'Shadow Direction', 0),
          numberProperty('workbench-shadow-focus', 'Shadow Focus', .5),
        ],
      ),
      panel(
        'workbench-simplify',
        'Simplify',
        children: <BlenderPropertyGroup>[
          panel(
            'workbench-simplify-viewport',
            'Viewport',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'workbench-simplify-subdivision',
                'Max Subdivision',
                2,
                decimalDigits: 0,
              ),
              numberProperty(
                'workbench-simplify-particles',
                'Max Child Particles',
                1,
                decimalDigits: 0,
              ),
              numberProperty(
                'workbench-simplify-volumes',
                'Volume Resolution',
                1,
                decimalDigits: 0,
              ),
              booleanProperty('workbench-simplify-normals', 'Normals', true),
            ],
          ),
          panel(
            'workbench-simplify-render',
            'Render',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'workbench-simplify-render-subdivision',
                'Max Subdivision',
                2,
                decimalDigits: 0,
              ),
              numberProperty(
                'workbench-simplify-render-particles',
                'Max Child Particles',
                1,
                decimalDigits: 0,
              ),
            ],
          ),
          panel(
            'workbench-simplify-grease-pencil',
            'Grease Pencil',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'workbench-simplify-gp',
                'Simplify Grease Pencil',
                0,
              ),
            ],
          ),
        ],
      ),
      panel(
        'workbench-color-management',
        'Color Management',
        children: <BlenderPropertyGroup>[
          panel(
            'workbench-color-working-space',
            'Working Space',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'workbench-working-file',
                'File',
                'sRGB',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem(value: 'sRGB', label: 'sRGB'),
                  BlenderMenuItem(value: 'Rec.709', label: 'Rec.709'),
                ],
              ),
            ],
          ),
          panel(
            'workbench-color-advanced',
            'Advanced',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('workbench-emulation', 'Emulation', false),
            ],
          ),
          panel(
            'workbench-color-curves',
            'Curves',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'workbench-color-curves-enabled',
                'Use Curve Mapping',
                false,
              ),
            ],
          ),
          panel(
            'workbench-color-white-balance',
            'White Balance',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'workbench-white-temperature',
                'Temperature',
                6500,
              ),
              numberProperty('workbench-white-tint', 'Tint', 10),
            ],
          ),
        ],
      ),
      panel(
        'workbench-freestyle',
        'Freestyle',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty(
            'workbench-freestyle-enable',
            'Enable Freestyle',
            false,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _renderPropertyGroups {
    if (_renderEngine == 'Workbench') {
      return _workbenchRenderPropertyGroups;
    }
    const axisChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Center', label: 'Center'),
      BlenderMenuItem<String>(value: 'Start', label: 'Start'),
      BlenderMenuItem<String>(value: 'End', label: 'End'),
    ];
    const deviceChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'CPU', label: 'CPU'),
      BlenderMenuItem<String>(value: 'GPU', label: 'GPU'),
    ];
    const giMethods = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Screen Tracing', label: 'Screen Tracing'),
      BlenderMenuItem<String>(value: 'Ray Tracing', label: 'Ray Tracing'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderCheckbox(
          value: value,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      double step = 1,
      int decimalDigits = 2,
      String? suffix,
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          step: step,
          decimalDigits: decimalDigits,
          suffix: suffix,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    Widget headerToggle(String title) => BlenderCheckbox(
      value: true,
      onChanged: (value) =>
          _setStatus('$title ${value ? 'enabled' : 'disabled'}'),
    );

    BlenderPropertyGroup panel(
      String id,
      String title, {
      bool expanded = false,
      bool toggle = false,
      List<Widget>? headerActions,
      List<BlenderPropertyDescriptor<dynamic>> properties =
          const <BlenderPropertyDescriptor<dynamic>>[],
      List<BlenderPropertyGroup> children = const <BlenderPropertyGroup>[],
    }) {
      return BlenderPropertyGroup(
        id: id,
        title: title,
        initiallyExpanded: expanded,
        headerLeading: toggle ? headerToggle(title) : null,
        properties: properties,
        children: children,
      );
    }

    return <BlenderPropertyGroup>[
      panel(
        'render-sampling',
        'Sampling',
        expanded: true,
        children: <BlenderPropertyGroup>[
          panel(
            'render-sampling-viewport',
            'Viewport',
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-taa-samples',
                'Samples',
                64,
                min: 1,
                max: 4096,
                decimalDigits: 0,
              ),
              booleanProperty(
                'render-temporal-reprojection',
                'Temporal Reprojection',
                true,
              ),
              booleanProperty(
                'render-jittered-shadows',
                'Jittered Shadows',
                true,
              ),
            ],
          ),
          panel(
            'render-sampling-render',
            'Render',
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-samples',
                'Samples',
                64,
                min: 1,
                max: 4096,
                decimalDigits: 0,
              ),
            ],
          ),
          panel(
            'render-sampling-shadows',
            'Shadows',
            toggle: true,
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-shadow-rays',
                'Rays',
                1,
                min: 1,
                max: 128,
                decimalDigits: 0,
              ),
              numberProperty(
                'render-shadow-steps',
                'Steps',
                4,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
              booleanProperty('render-volume-shadows', 'Volume Shadows', true),
              numberProperty(
                'render-volume-shadow-steps',
                'Steps',
                4,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
              numberProperty(
                'render-shadow-resolution',
                'Resolution',
                100,
                min: 1,
                max: 100,
                suffix: '%',
              ),
            ],
          ),
          panel(
            'render-sampling-advanced',
            'Advanced',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-light-threshold',
                'Light Threshold',
                .01,
                min: 0,
                step: .01,
              ),
            ],
          ),
        ],
      ),
      panel(
        'render-light-paths',
        'Light Paths',
        children: <BlenderPropertyGroup>[
          panel(
            'render-clamping',
            'Clamping',
            children: <BlenderPropertyGroup>[
              panel(
                'render-clamping-surface',
                'Surface',
                expanded: true,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty(
                    'render-clamp-surface-direct',
                    'Direct Light',
                    10,
                  ),
                  numberProperty(
                    'render-clamp-surface-indirect',
                    'Indirect Light',
                    10,
                  ),
                ],
              ),
              panel(
                'render-clamping-volume',
                'Volume',
                expanded: true,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty(
                    'render-clamp-volume-direct',
                    'Direct Light',
                    10,
                  ),
                  numberProperty(
                    'render-clamp-volume-indirect',
                    'Indirect Light',
                    10,
                  ),
                ],
              ),
            ],
          ),
          panel(
            'render-light-path-intensity',
            'Intensity',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('render-direct-intensity', 'Direct Light', 1),
              numberProperty('render-indirect-intensity', 'Indirect Light', 1),
            ],
          ),
        ],
      ),
      panel(
        'render-raytracing',
        'Raytracing',
        toggle: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'render-raytracing-method',
            'Method',
            'Screen Tracing',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Screen Tracing',
                label: 'Screen Tracing',
              ),
              BlenderMenuItem<String>(
                value: 'Ray Tracing',
                label: 'Ray Tracing',
              ),
            ],
          ),
          numberProperty(
            'render-raytracing-resolution',
            'Resolution',
            100,
            min: 25,
            max: 100,
            suffix: '%',
          ),
        ],
        children: <BlenderPropertyGroup>[
          panel(
            'render-screen-tracing',
            'Screen Tracing',
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-screen-trace-precision',
                'Precision',
                .5,
                min: 0,
                max: 1,
              ),
              numberProperty(
                'render-screen-trace-thickness',
                'Thickness',
                .2,
                min: 0,
                step: .01,
              ),
              booleanProperty('render-screen-trace-backface', 'Backface', true),
              numberProperty(
                'render-screen-trace-radiance',
                'Radiance',
                .5,
                min: 0,
                max: 1,
              ),
            ],
          ),
          panel(
            'render-fast-gi',
            'Fast GI Approximation',
            toggle: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-fast-gi-threshold',
                'Threshold',
                .5,
                min: 0,
                max: 1,
              ),
              enumProperty(
                'render-fast-gi-method',
                'Method',
                'Screen Tracing',
                giMethods,
              ),
              enumProperty(
                'render-fast-gi-resolution',
                'Resolution',
                'Half',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Full', label: 'Full'),
                  BlenderMenuItem<String>(value: 'Half', label: 'Half'),
                  BlenderMenuItem<String>(value: 'Quarter', label: 'Quarter'),
                ],
              ),
              numberProperty(
                'render-fast-gi-rays',
                'Rays',
                4,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
              numberProperty(
                'render-fast-gi-steps',
                'Steps',
                8,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
              numberProperty('render-fast-gi-distance', 'Distance', 3),
              numberProperty(
                'render-fast-gi-thickness',
                'Thickness',
                .2,
                min: 0,
                step: .01,
              ),
              numberProperty('render-fast-gi-bias', 'Bias', .5, min: 0, max: 1),
            ],
          ),
          panel(
            'render-denoising',
            'Denoising',
            toggle: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('render-denoise-spatial', 'Spatial', true),
              booleanProperty('render-denoise-temporal', 'Temporal', true),
              booleanProperty('render-denoise-bilateral', 'Bilateral', true),
            ],
          ),
        ],
      ),
      panel(
        'render-volumes',
        'Volumes',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'render-volume-resolution',
            'Resolution',
            '8 px',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: '2 px', label: '2 px'),
              BlenderMenuItem<String>(value: '8 px', label: '8 px'),
              BlenderMenuItem<String>(value: '16 px', label: '16 px'),
            ],
          ),
          numberProperty(
            'render-volume-steps',
            'Steps',
            64,
            min: 1,
            max: 1024,
            decimalDigits: 0,
          ),
          numberProperty(
            'render-volume-distribution',
            'Distribution',
            .5,
            min: 0,
            max: 1,
          ),
          numberProperty(
            'render-volume-depth',
            'Max Depth',
            64,
            min: 1,
            max: 1024,
            decimalDigits: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          panel(
            'render-volume-range',
            'Custom Range',
            toggle: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('render-volume-start', 'Start', 0),
              numberProperty('render-volume-end', 'End', 100),
            ],
          ),
        ],
      ),
      panel(
        'render-depth-of-field',
        'Depth of Field',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'render-bokeh-max-size',
            'Max Size',
            10,
            min: 0,
            max: 100,
          ),
          numberProperty(
            'render-bokeh-threshold',
            'Threshold',
            1,
            min: 0,
            max: 100,
          ),
          numberProperty(
            'render-bokeh-neighbor-max',
            'Neighbor Max',
            10,
            min: 0,
            max: 100,
          ),
          booleanProperty('render-bokeh-jittered', 'Jitter Camera', true),
          numberProperty(
            'render-bokeh-overblur',
            'Overblur',
            0,
            min: 0,
            max: 100,
          ),
        ],
      ),
      panel(
        'render-motion-blur',
        'Motion Blur',
        toggle: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'render-motion-position',
            'Position',
            'Center',
            axisChoices,
          ),
          numberProperty(
            'render-motion-shutter',
            'Shutter',
            .5,
            min: 0,
            max: 2,
          ),
          numberProperty('render-motion-depth-scale', 'Depth Scale', 1, min: 0),
          numberProperty(
            'render-motion-max',
            'Max',
            64,
            min: 1,
            max: 256,
            decimalDigits: 0,
          ),
          numberProperty(
            'render-motion-steps',
            'Steps',
            2,
            min: 1,
            max: 32,
            decimalDigits: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          panel(
            'render-shutter-curve',
            'Shutter Curve',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'render-shutter-curve-shape',
                'Preset',
                'Smooth',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Smooth', label: 'Smooth'),
                  BlenderMenuItem<String>(value: 'Round', label: 'Round'),
                  BlenderMenuItem<String>(value: 'Sharp', label: 'Sharp'),
                  BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
                ],
              ),
            ],
          ),
        ],
      ),
      panel(
        'render-film',
        'Film',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'render-filter-size',
            'Filter Size',
            1.5,
            min: 0,
            max: 20,
          ),
          booleanProperty('render-film-transparent', 'Transparent', false),
          booleanProperty('render-overscan', 'Overscan', false),
          numberProperty(
            'render-overscan-size',
            'Size',
            3,
            min: 0,
            max: 100,
            suffix: '%',
          ),
        ],
      ),
      panel(
        'render-curves',
        'Curves',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'render-curves-shape',
            'Shape',
            '3D Curves',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: '3D Curves', label: '3D Curves'),
              BlenderMenuItem<String>(value: '2D Curves', label: '2D Curves'),
            ],
          ),
          numberProperty(
            'render-curves-subdivision',
            'Subdivision',
            2,
            min: 0,
            max: 10,
            decimalDigits: 0,
          ),
        ],
      ),
      panel(
        'render-performance',
        'Performance',
        children: <BlenderPropertyGroup>[
          panel(
            'render-performance-memory',
            'Memory',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-shadow-pool',
                'Shadow Pool',
                512,
                min: 0,
                suffix: ' MB',
              ),
              numberProperty(
                'render-probe-pool',
                'Light Probes Volume Pool',
                256,
                min: 0,
                suffix: ' MB',
              ),
            ],
          ),
          panel(
            'render-performance-viewport',
            'Viewport',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-preview-pixel-size',
                'Pixel Size',
                1,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
            ],
          ),
          panel(
            'render-performance-compositor',
            'Compositor',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'render-compositor-device',
                'Device',
                'CPU',
                deviceChoices,
              ),
              enumProperty(
                'render-compositor-precision',
                'Precision',
                'Full',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Full', label: 'Full'),
                  BlenderMenuItem<String>(value: 'Half', label: 'Half'),
                ],
              ),
            ],
            children: <BlenderPropertyGroup>[
              panel(
                'render-performance-denoise',
                'Denoise Nodes',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  enumProperty(
                    'render-denoise-device',
                    'Denoising Device',
                    'CPU',
                    deviceChoices,
                  ),
                  enumProperty(
                    'render-denoise-preview-quality',
                    'Preview Quality',
                    'Fast',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Fast', label: 'Fast'),
                      BlenderMenuItem<String>(
                        value: 'Accurate',
                        label: 'Accurate',
                      ),
                    ],
                  ),
                  enumProperty(
                    'render-denoise-final-quality',
                    'Final Quality',
                    'High',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'High', label: 'High'),
                      BlenderMenuItem<String>(value: 'Low', label: 'Low'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      panel(
        'render-grease-pencil',
        'Grease Pencil',
        children: <BlenderPropertyGroup>[
          panel(
            'render-grease-pencil-viewport',
            'Viewport',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-gp-smaa-viewport',
                'SMAA Threshold',
                .1,
                min: 0,
                max: 1,
              ),
            ],
          ),
          panel(
            'render-grease-pencil-render',
            'Render',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-gp-smaa-render',
                'SMAA Threshold',
                .1,
                min: 0,
                max: 1,
              ),
              numberProperty(
                'render-gp-ssaa-samples',
                'SSAA Samples',
                8,
                min: 1,
                max: 64,
                decimalDigits: 0,
              ),
              numberProperty(
                'render-gp-motion-steps',
                'Motion Blur Steps',
                4,
                min: 1,
                max: 32,
                decimalDigits: 0,
              ),
            ],
          ),
        ],
      ),
      panel(
        'render-simplify',
        'Simplify',
        toggle: true,
        children: <BlenderPropertyGroup>[
          panel(
            'render-simplify-viewport',
            'Viewport',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-simplify-subdivision',
                'Max Subdivision',
                2,
                min: 0,
                max: 12,
                decimalDigits: 0,
              ),
              numberProperty(
                'render-simplify-particles',
                'Max Child Particles',
                1,
                min: 0,
                max: 100000,
                decimalDigits: 0,
              ),
              numberProperty(
                'render-simplify-volumes',
                'Volume Resolution',
                1,
                min: 0,
                max: 100,
                decimalDigits: 0,
              ),
              booleanProperty('render-simplify-normals', 'Normals', true),
            ],
          ),
          panel(
            'render-simplify-render',
            'Render',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-simplify-render-subdivision',
                'Max Subdivision',
                2,
                min: 0,
                max: 12,
                decimalDigits: 0,
              ),
              numberProperty(
                'render-simplify-render-particles',
                'Max Child Particles',
                1,
                min: 0,
                max: 100000,
                decimalDigits: 0,
              ),
            ],
          ),
          panel(
            'render-simplify-grease-pencil',
            'Grease Pencil',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'render-simplify-gp',
                'Simplify Grease Pencil',
                true,
              ),
            ],
          ),
        ],
      ),
      panel(
        'render-color-management',
        'Color Management',
        children: <BlenderPropertyGroup>[
          panel(
            'render-color-working-space',
            'Working Space',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'render-working-file',
                'File',
                'sRGB',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'sRGB', label: 'sRGB'),
                  BlenderMenuItem<String>(value: 'ACEScg', label: 'ACEScg'),
                ],
              ),
              enumProperty(
                'render-working-sequencer',
                'Sequencer',
                'sRGB',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'sRGB', label: 'sRGB'),
                  BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
                ],
              ),
            ],
          ),
          panel(
            'render-color-advanced',
            'Advanced',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'render-color-emulation',
                'Emulation',
                'sRGB',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'sRGB', label: 'sRGB'),
                  BlenderMenuItem<String>(
                    value: 'Display P3',
                    label: 'Display P3',
                  ),
                ],
              ),
            ],
          ),
          panel(
            'render-color-curves',
            'Curves',
            toggle: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'render-color-curve-mapping',
                'Use Curve Mapping',
                true,
              ),
            ],
          ),
          panel(
            'render-color-white-balance',
            'White Balance',
            toggle: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'render-white-temperature',
                'Temperature',
                6500,
                min: 1000,
                max: 20000,
                decimalDigits: 0,
                suffix: ' K',
              ),
              numberProperty(
                'render-white-tint',
                'Tint',
                10,
                min: -100,
                max: 100,
              ),
            ],
          ),
        ],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'render-display-device',
            'Display Device',
            'sRGB',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'sRGB', label: 'sRGB'),
              BlenderMenuItem<String>(value: 'Display P3', label: 'Display P3'),
            ],
          ),
          enumProperty(
            'render-view-transform',
            'View Transform',
            'AgX',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'AgX', label: 'AgX'),
              BlenderMenuItem<String>(value: 'Standard', label: 'Standard'),
            ],
          ),
          enumProperty(
            'render-look',
            'Look',
            'None',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'None', label: 'None'),
              BlenderMenuItem<String>(
                value: 'Medium High Contrast',
                label: 'Medium High Contrast',
              ),
            ],
          ),
          numberProperty('render-exposure', 'Exposure', 0, min: -10, max: 10),
          numberProperty('render-gamma', 'Gamma', 1, min: .1, max: 5),
        ],
      ),
      panel(
        'render-freestyle',
        'Freestyle',
        toggle: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'freestyle-line-thickness-mode',
            'Line Thickness Mode',
            'Absolute',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Absolute', label: 'Absolute'),
              BlenderMenuItem<String>(value: 'Relative', label: 'Relative'),
            ],
          ),
          numberProperty(
            'freestyle-line-thickness',
            'Line Thickness',
            1,
            min: 0,
            max: 10,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _scenePropertyGroups {
    const sceneChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
      BlenderMenuItem<String>(value: 'Scene.001', label: 'Scene.001'),
    ];
    const unitChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'None', label: 'None'),
      BlenderMenuItem<String>(value: 'Metric', label: 'Metric'),
      BlenderMenuItem<String>(value: 'Imperial', label: 'Imperial'),
    ];
    const rotationChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Degrees', label: 'Degrees'),
      BlenderMenuItem<String>(value: 'Radians', label: 'Radians'),
    ];
    const distanceChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'HRTF', label: 'HRTF'),
      BlenderMenuItem<String>(value: 'Inverse', label: 'Inverse'),
      BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderCheckbox(
          value: value,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      double step = 1,
      int decimalDigits = 2,
      String? suffix,
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          step: step,
          decimalDigits: decimalDigits,
          suffix: suffix,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<List<double>> vectorProperty(
      String id,
      String label,
      List<double> value, {
      double? min,
      double? max,
      double step = .1,
      int decimalDigits = 3,
    }) {
      return BlenderPropertyDescriptor<List<double>>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderVectorField(
          values: value,
          min: min,
          max: max,
          step: step,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<bool> actionProperty(String id, String label) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: false,
        labelPlacement: BlenderPropertyLabelPlacement.splitColumn,
        editorBuilder: (context, value, onChanged) =>
            BlenderButton(label: label, onPressed: () => _setStatus(label)),
      );
    }

    BlenderPropertyGroup panel(
      String id,
      String title, {
      bool expanded = false,
      bool toggle = false,
      List<Widget>? headerActions,
      List<BlenderPropertyDescriptor<dynamic>> properties =
          const <BlenderPropertyDescriptor<dynamic>>[],
      List<BlenderPropertyGroup> children = const <BlenderPropertyGroup>[],
    }) {
      return BlenderPropertyGroup(
        id: id,
        title: title,
        initiallyExpanded: expanded,
        headerLeading: toggle
            ? BlenderCheckbox(
                value: true,
                onChanged: (value) =>
                    _setStatus('$title ${value ? 'enabled' : 'disabled'}'),
              )
            : null,
        headerActions: headerActions,
        properties: properties,
        children: children,
      );
    }

    return <BlenderPropertyGroup>[
      panel(
        'scene-scene',
        'Scene',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'scene-camera',
            'Camera',
            'Camera',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
              BlenderMenuItem<String>(value: 'Camera.001', label: 'Camera.001'),
            ],
          ),
          enumProperty(
            'scene-background-set',
            'Background Set',
            'None',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'None', label: 'None'),
              ...sceneChoices,
            ],
          ),
          enumProperty(
            'scene-active-clip',
            'Active Clip',
            'None',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'None', label: 'None'),
              BlenderMenuItem<String>(
                value: 'Tracking Clip',
                label: 'Tracking Clip',
              ),
            ],
          ),
        ],
      ),
      panel(
        'scene-units',
        'Units',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'scene-unit-system',
            'Unit System',
            'Metric',
            unitChoices,
          ),
          numberProperty(
            'scene-scale-length',
            'Scale Length',
            1,
            min: .0001,
            step: .01,
          ),
          booleanProperty('scene-separate-units', 'Separate Units', false),
          enumProperty(
            'scene-rotation-system',
            'Rotation',
            'Degrees',
            rotationChoices,
          ),
          enumProperty('scene-length-unit', 'Length', 'Meters', const <
            BlenderMenuItem<String>
          >[
            BlenderMenuItem<String>(value: 'Meters', label: 'Meters'),
            BlenderMenuItem<String>(value: 'Centimeters', label: 'Centimeters'),
          ]),
          enumProperty(
            'scene-mass-unit',
            'Mass',
            'Kilograms',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Kilograms', label: 'Kilograms'),
              BlenderMenuItem<String>(value: 'Grams', label: 'Grams'),
            ],
          ),
          enumProperty(
            'scene-time-unit',
            'Time',
            'Seconds',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Seconds', label: 'Seconds'),
              BlenderMenuItem<String>(value: 'Frames', label: 'Frames'),
            ],
          ),
          enumProperty(
            'scene-temperature-unit',
            'Temperature',
            'Kelvin',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Kelvin', label: 'Kelvin'),
              BlenderMenuItem<String>(value: 'Celsius', label: 'Celsius'),
            ],
          ),
        ],
      ),
      panel(
        'scene-keying-sets',
        'Keying Sets',
        children: <BlenderPropertyGroup>[
          panel(
            'scene-keyframing-settings',
            'Keyframing Settings',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('scene-key-needed', 'Needed', true),
              booleanProperty('scene-key-visual', 'Visual', false),
              booleanProperty('scene-key-available', 'Available', true),
            ],
          ),
          panel(
            'scene-active-keying-set',
            'Active Keying Set',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'scene-key-target',
                'Target ID-Block',
                'Cube',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
                  BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
                ],
              ),
              enumProperty(
                'scene-key-data-path',
                'Data Path',
                'Location',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Location', label: 'Location'),
                  BlenderMenuItem<String>(value: 'Rotation', label: 'Rotation'),
                ],
              ),
              booleanProperty('scene-key-array-all', 'Array All Items', true),
              enumProperty(
                'scene-key-grouping',
                'F-Curve Grouping',
                'Named',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Named', label: 'Named'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
            ],
          ),
        ],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'scene-keying-set',
            'Keying Set',
            'Location & Rotation',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Location & Rotation',
                label: 'Location & Rotation',
              ),
              BlenderMenuItem<String>(value: 'Available', label: 'Available'),
            ],
          ),
        ],
      ),
      panel(
        'scene-audio',
        'Audio',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('scene-audio-volume', 'Volume', 1, min: 0, max: 2),
          enumProperty(
            'scene-audio-distance',
            'Distance Model',
            'HRTF',
            distanceChoices,
          ),
          numberProperty(
            'scene-audio-doppler-speed',
            'Doppler Speed',
            343,
            min: 0,
          ),
          numberProperty(
            'scene-audio-doppler-factor',
            'Doppler Factor',
            1,
            min: 0,
          ),
          actionProperty('scene-audio-bake', 'Bake Animation'),
        ],
      ),
      panel(
        'scene-gravity',
        'Gravity',
        toggle: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          vectorProperty('scene-gravity-vector', 'Gravity', <double>[
            0,
            0,
            -9.81,
          ], step: .01),
        ],
      ),
      panel(
        'scene-simulation',
        'Simulation',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty(
            'scene-custom-simulation-range',
            'Simulation Range',
            true,
          ),
          numberProperty(
            'scene-simulation-start',
            'Start',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          numberProperty(
            'scene-simulation-end',
            'End',
            250,
            min: 0,
            decimalDigits: 0,
          ),
        ],
      ),
      panel(
        'scene-rigid-body-world',
        'Rigid Body World',
        toggle: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          actionProperty('scene-rigid-remove', 'Remove'),
        ],
        children: <BlenderPropertyGroup>[
          panel(
            'scene-rigid-body-settings',
            'Settings',
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'scene-rigid-collection',
                'Collection',
                'RigidBodyWorld',
                sceneChoices,
              ),
              enumProperty(
                'scene-rigid-constraints',
                'Constraints',
                'RigidBodyConstraints',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'RigidBodyConstraints',
                    label: 'RigidBodyConstraints',
                  ),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
              numberProperty(
                'scene-rigid-speed',
                'Speed',
                1,
                min: 0,
                step: .01,
              ),
              booleanProperty(
                'scene-rigid-split-impulse',
                'Split Impulse',
                true,
              ),
              numberProperty(
                'scene-rigid-substeps',
                'Substeps Per Frame',
                10,
                min: 1,
                max: 100,
                decimalDigits: 0,
              ),
              numberProperty(
                'scene-rigid-solver-iterations',
                'Solver Iterations',
                10,
                min: 1,
                max: 100,
                decimalDigits: 0,
              ),
            ],
          ),
          panel(
            'scene-rigid-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'scene-rigid-cache-start',
                'Frame Start',
                1,
                min: 0,
                decimalDigits: 0,
              ),
              numberProperty(
                'scene-rigid-cache-end',
                'End',
                250,
                min: 0,
                decimalDigits: 0,
              ),
              enumProperty(
                'scene-rigid-cache-type',
                'Simulation',
                'Replay',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Replay', label: 'Replay'),
                  BlenderMenuItem<String>(value: 'Fixed', label: 'Fixed'),
                ],
              ),
            ],
          ),
          panel(
            'scene-rigid-field-weights',
            'Field Weights',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'scene-rigid-gravity-weight',
                'Gravity',
                1,
                min: 0,
                max: 1,
              ),
              numberProperty(
                'scene-rigid-all-weight',
                'All',
                1,
                min: 0,
                max: 1,
              ),
            ],
          ),
        ],
      ),
      panel(
        'scene-light-probes',
        'Light Probes',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'scene-probe-resolution',
            'Spheres Resolution',
            '256',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: '64', label: '64'),
              BlenderMenuItem<String>(value: '128', label: '128'),
              BlenderMenuItem<String>(value: '256', label: '256'),
            ],
          ),
          actionProperty('scene-probe-bake', 'Bake All Light Probe Volumes'),
        ],
      ),
      panel(
        'scene-animation',
        'Animation',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('scene-action', 'Action', 'SceneAction', const <
            BlenderMenuItem<String>
          >[
            BlenderMenuItem<String>(value: 'SceneAction', label: 'SceneAction'),
            BlenderMenuItem<String>(value: 'None', label: 'None'),
          ]),
          enumProperty('scene-slot', 'Slot', 'Scene', sceneChoices),
        ],
      ),
      panel(
        'scene-custom-properties',
        'Custom Properties',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'scene-custom-property',
            'example_value',
            1,
            decimalDigits: 2,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _worldPropertyGroups {
    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      double step = 1,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          step: step,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyGroup panel(
      String id,
      String title, {
      bool expanded = false,
      bool toggle = false,
      List<BlenderPropertyDescriptor<dynamic>> properties =
          const <BlenderPropertyDescriptor<dynamic>>[],
      List<BlenderPropertyGroup> children = const <BlenderPropertyGroup>[],
    }) {
      return BlenderPropertyGroup(
        id: id,
        title: title,
        initiallyExpanded: expanded,
        headerLeading: toggle
            ? BlenderCheckbox(
                value: true,
                onChanged: (value) =>
                    _setStatus('$title ${value ? 'enabled' : 'disabled'}'),
              )
            : null,
        properties: properties,
        children: children,
      );
    }

    return <BlenderPropertyGroup>[
      panel(
        'world-surface',
        'Surface',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'world-surface-node',
            'Surface',
            'Background',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Background', label: 'Background'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
      panel(
        'world-volume',
        'Volume',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'world-volume-node',
            'Volume',
            'Principled Volume',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Principled Volume',
                label: 'Principled Volume',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'world-volume-convert',
            label: 'Convert Volume',
            value: false,
            labelPlacement: BlenderPropertyLabelPlacement.splitColumn,
            editorBuilder: (context, value, onChanged) => BlenderButton(
              label: 'Convert Volume',
              onPressed: () => _setStatus('Convert volume to mesh'),
            ),
          ),
        ],
      ),
      panel(
        'world-mist',
        'Mist Pass',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('world-mist-start', 'Start', 5, min: 0),
          numberProperty('world-mist-depth', 'Depth', 25, min: 0),
          enumProperty(
            'world-mist-falloff',
            'Falloff',
            'Quadratic',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Quadratic', label: 'Quadratic'),
              BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
              BlenderMenuItem<String>(
                value: 'Inverse Quadratic',
                label: 'Inverse Quadratic',
              ),
            ],
          ),
        ],
      ),
      panel(
        'world-settings',
        'Settings',
        children: <BlenderPropertyGroup>[
          panel(
            'world-light-probe',
            'Light Probe',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'world-probe-resolution',
                'Resolution',
                '256',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: '64', label: '64'),
                  BlenderMenuItem<String>(value: '128', label: '128'),
                  BlenderMenuItem<String>(value: '256', label: '256'),
                ],
              ),
            ],
          ),
          panel(
            'world-sun',
            'Sun',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('world-sun-threshold', 'Threshold', .1, min: 0),
              numberProperty(
                'world-sun-angle',
                'Angle',
                .526,
                min: 0,
                max: 3.14,
                step: .01,
              ),
            ],
            children: <BlenderPropertyGroup>[
              panel(
                'world-sun-shadow',
                'Shadow',
                toggle: true,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty('world-sun-shadow-jitter', 'Jitter', true),
                  numberProperty(
                    'world-sun-shadow-overblur',
                    'Overblur',
                    .1,
                    min: 0,
                  ),
                  numberProperty(
                    'world-sun-shadow-filter',
                    'Filter',
                    3,
                    min: 0,
                  ),
                  numberProperty(
                    'world-sun-shadow-resolution',
                    'Resolution Limit',
                    2048,
                    min: 1,
                    decimalDigits: 0,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      panel(
        'world-viewport-display',
        'Viewport Display',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<Color>(
            id: 'world-color',
            label: 'Color',
            value: const Color(0xFF202020),
            editorBuilder: (context, value, onChanged) => BlenderColorField(
              color: value,
              onPressed: () => _setStatus('World color picker opened'),
            ),
          ),
        ],
      ),
      panel(
        'world-animation',
        'Animation',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('world-action', 'World', 'WorldAction', const <
            BlenderMenuItem<String>
          >[
            BlenderMenuItem<String>(value: 'WorldAction', label: 'WorldAction'),
            BlenderMenuItem<String>(value: 'None', label: 'None'),
          ]),
          enumProperty(
            'world-node-action',
            'Shader Node Tree',
            'WorldNodes',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'WorldNodes', label: 'WorldNodes'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
      panel(
        'world-custom-properties',
        'Custom Properties',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('world-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _materialPropertyGroups {
    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      double step = 1,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          step: step,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyGroup panel(
      String id,
      String title, {
      bool expanded = false,
      List<BlenderPropertyDescriptor<dynamic>> properties =
          const <BlenderPropertyDescriptor<dynamic>>[],
      List<BlenderPropertyGroup> children = const <BlenderPropertyGroup>[],
    }) {
      return BlenderPropertyGroup(
        id: id,
        title: title,
        initiallyExpanded: expanded,
        properties: properties,
        children: children,
      );
    }

    const shaderChoices = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(
        value: 'Principled BSDF',
        label: 'Principled BSDF',
      ),
      BlenderMenuItem<String>(value: 'Diffuse BSDF', label: 'Diffuse BSDF'),
      BlenderMenuItem<String>(value: 'None', label: 'None'),
    ];
    const renderMethods = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Dithered', label: 'Dithered'),
      BlenderMenuItem<String>(value: 'Blended', label: 'Blended'),
      BlenderMenuItem<String>(value: 'Opaque', label: 'Opaque'),
    ];

    return <BlenderPropertyGroup>[
      panel(
        'material-preview',
        'Preview',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'material-preview-shape',
            'Preview Shape',
            'Sphere',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
              BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
              BlenderMenuItem<String>(
                value: 'Shader Ball',
                label: 'Shader Ball',
              ),
            ],
          ),
        ],
      ),
      panel(
        'material-surface',
        'Surface',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'material-surface-node',
            'Surface',
            'Principled BSDF',
            shaderChoices,
          ),
        ],
      ),
      panel(
        'material-volume',
        'Volume',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'material-volume-node',
            'Volume',
            'Principled BSDF',
            shaderChoices,
          ),
        ],
      ),
      panel(
        'material-displacement',
        'Displacement',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'material-displacement-node',
            'Displacement',
            'None',
            shaderChoices,
          ),
        ],
      ),
      panel(
        'material-thickness',
        'Thickness',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'material-thickness-node',
            'Thickness',
            'None',
            shaderChoices,
          ),
        ],
      ),
      panel(
        'material-settings',
        'Settings',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'material-pass-index',
            'Pass Index',
            0,
            min: 0,
            max: 32767,
            decimalDigits: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          panel(
            'material-settings-surface',
            'Surface',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'material-backface-camera',
                'Backface Culling Camera',
                false,
              ),
              booleanProperty(
                'material-backface-shadow',
                'Backface Culling Shadow',
                false,
              ),
              booleanProperty(
                'material-backface-probe',
                'Backface Culling Light Probe Volume',
                false,
              ),
              enumProperty(
                'material-displacement-method',
                'Displacement',
                'Bump',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Bump', label: 'Bump'),
                  BlenderMenuItem<String>(
                    value: 'Displacement',
                    label: 'Displacement',
                  ),
                ],
              ),
              numberProperty(
                'material-max-displacement',
                'Max Distance',
                0,
                min: 0,
              ),
              booleanProperty(
                'material-transparent-shadow',
                'Transparent Shadow',
                true,
              ),
              enumProperty(
                'material-render-method',
                'Render Method',
                'Dithered',
                renderMethods,
              ),
              booleanProperty(
                'material-transparency-overlap',
                'Transparency Overlap',
                true,
              ),
              enumProperty(
                'material-thickness-mode',
                'Thickness',
                'Slab',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Slab', label: 'Slab'),
                  BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
                ],
              ),
            ],
          ),
          panel(
            'material-settings-volume',
            'Volume',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'material-volume-intersection',
                'Intersection',
                'Fast',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Fast', label: 'Fast'),
                  BlenderMenuItem<String>(value: 'Accurate', label: 'Accurate'),
                ],
              ),
            ],
          ),
        ],
      ),
      panel(
        'material-viewport-display',
        'Viewport Display',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<Color>(
            id: 'material-diffuse-color',
            label: 'Color',
            value: const Color(0xFF4772B3),
            editorBuilder: (context, value, onChanged) => BlenderColorField(
              color: value,
              onPressed: () => _setStatus('Material color picker opened'),
            ),
          ),
          numberProperty('material-metallic', 'Metallic', .2, min: 0, max: 1),
          numberProperty(
            'material-roughness',
            'Roughness',
            .35,
            min: 0,
            max: 1,
          ),
        ],
      ),
      panel(
        'material-line-art',
        'Line Art',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('material-mask', 'Material Mask', false),
          numberProperty(
            'material-occlusion',
            'Levels',
            0,
            min: 0,
            max: 8,
            decimalDigits: 0,
          ),
          booleanProperty(
            'material-intersection-override',
            'Intersection Priority Override',
            false,
          ),
          numberProperty(
            'material-intersection-priority',
            'Intersection Priority',
            0,
            min: 0,
            max: 255,
            decimalDigits: 0,
          ),
        ],
      ),
      panel(
        'material-freestyle-line',
        'Freestyle Line',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<Color>(
            id: 'material-freestyle-line-color',
            label: 'Line Color',
            value: const Color(0xFF101010),
            editorBuilder: (context, value, onChanged) => BlenderColorField(
              color: value,
              onPressed: () => _setStatus('Freestyle line color opened'),
            ),
          ),
          numberProperty(
            'material-freestyle-line-priority',
            'Priority',
            0,
            min: 0,
            max: 32767,
            decimalDigits: 0,
          ),
        ],
      ),
      panel(
        'material-grease-pencil',
        'Grease Pencil',
        children: <BlenderPropertyGroup>[
          panel(
            'material-grease-pencil-surface',
            'Surface',
            expanded: true,
            children: <BlenderPropertyGroup>[
              panel(
                'material-grease-pencil-stroke',
                'Stroke',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  enumProperty(
                    'material-grease-pencil-stroke-mode',
                    'Mode',
                    'Line',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Line', label: 'Line'),
                      BlenderMenuItem<String>(value: 'Dots', label: 'Dots'),
                      BlenderMenuItem<String>(value: 'Box', label: 'Box'),
                    ],
                  ),
                  enumProperty(
                    'material-grease-pencil-stroke-style',
                    'Style',
                    'Solid',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Solid', label: 'Solid'),
                      BlenderMenuItem<String>(
                        value: 'Texture',
                        label: 'Texture',
                      ),
                    ],
                  ),
                  booleanProperty(
                    'material-grease-pencil-stroke-holdout',
                    'Holdout',
                    false,
                  ),
                ],
                children: <BlenderPropertyGroup>[
                  panel(
                    'material-grease-pencil-randomize',
                    'Randomize',
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      numberProperty(
                        'material-grease-pencil-random-radius',
                        'Radius',
                        0,
                        min: 0,
                      ),
                      numberProperty(
                        'material-grease-pencil-random-opacity',
                        'Opacity',
                        0,
                        min: 0,
                        max: 1,
                      ),
                    ],
                  ),
                ],
              ),
              panel(
                'material-grease-pencil-fill',
                'Fill',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<Color>(
                    id: 'material-grease-pencil-fill-color',
                    label: 'Base Color',
                    value: const Color(0xFF4772B3),
                    editorBuilder: (context, value, onChanged) =>
                        BlenderColorField(
                          color: value,
                          onPressed: () => _setStatus('GP fill color picker'),
                        ),
                  ),
                  booleanProperty(
                    'material-grease-pencil-fill-holdout',
                    'Holdout',
                    false,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      panel(
        'material-animation',
        'Animation',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'material-action',
            'Material',
            'MaterialAction',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'MaterialAction',
                label: 'MaterialAction',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          enumProperty(
            'material-node-action',
            'Shader Node Tree',
            'MaterialNodes',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'MaterialNodes',
                label: 'MaterialNodes',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
      panel(
        'material-custom-properties',
        'Custom Properties',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('material-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  Widget _meshListContent({
    required List<BlenderListItem<String>> items,
    required String label,
    bool showMoveButtons = false,
  }) {
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: BlenderBox(
              padding: EdgeInsets.zero,
              child: BlenderListView<String>(
                items: items,
                selectedId: items.isEmpty ? null : items.first.id,
                onSelected: (item) => _setStatus('$label: ${item.label}'),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.plus,
                onPressed: () => _setStatus('Add $label'),
                tooltip: 'Add $label',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: () => _setStatus('Remove $label'),
                tooltip: 'Remove $label',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.more,
                onPressed: () => _setStatus('$label specials'),
                tooltip: '$label specials',
                size: 22,
              ),
              if (showMoveButtons) ...<Widget>[
                BlenderIconButton(
                  glyph: BlenderGlyph.stepBack,
                  onPressed: () => _setStatus('Move $label up'),
                  tooltip: 'Move $label up',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.stepForward,
                  onPressed: () => _setStatus('Move $label down'),
                  tooltip: 'Move $label down',
                  size: 22,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<BlenderPropertyGroup> get _meshPropertyGroups {
    const remeshModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Voxel', label: 'Voxel'),
      BlenderMenuItem<String>(value: 'QuadriFlow', label: 'QuadriFlow'),
    ];
    const textureMeshes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Original', label: 'Original'),
      BlenderMenuItem<String>(value: 'None', label: 'None'),
    ];

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'mesh-vertex-groups',
        title: 'Vertex Groups',
        content: _meshListContent(
          label: 'Vertex Group',
          showMoveButtons: true,
          items: const <BlenderListItem<String>>[
            BlenderListItem<String>(
              id: 'mesh-vgroup-deform',
              label: 'Deform',
              icon: BlenderGlyph.collection,
              detail: '0.000',
            ),
            BlenderListItem<String>(
              id: 'mesh-vgroup-secondary',
              label: 'Secondary',
              icon: BlenderGlyph.collection,
            ),
          ],
        ),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'mesh-vgroup-weight',
            label: 'Weight',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 1,
              decimalDigits: 3,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Vertex group weight changed'),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'mesh-vgroup-normalize',
            label: 'Auto Normalize',
            value: true,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Auto Normalize changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mesh-shape-keys',
        title: 'Shape Keys',
        content: _meshListContent(
          label: 'Shape Key',
          showMoveButtons: true,
          items: const <BlenderListItem<String>>[
            BlenderListItem<String>(
              id: 'mesh-shape-basis',
              label: 'Basis',
              icon: BlenderGlyph.keyframe,
            ),
            BlenderListItem<String>(
              id: 'mesh-shape-smile',
              label: 'Smile',
              icon: BlenderGlyph.keyframe,
            ),
          ],
        ),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<bool>(
            id: 'mesh-shape-relative',
            label: 'Relative',
            value: true,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Shape key mode changed'),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'mesh-shape-edit-mode',
            label: 'Edit Mode',
            value: false,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Shape key Edit Mode changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mesh-uv-maps',
        title: 'UV Maps',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: _meshListContent(
          label: 'UV Map',
          items: const <BlenderListItem<String>>[
            BlenderListItem<String>(
              id: 'mesh-uvmap-primary',
              label: 'UVMap',
              icon: BlenderGlyph.uv,
              detail: 'Render',
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'mesh-color-attributes',
        title: 'Color Attributes',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: _meshListContent(
          label: 'Color Attribute',
          items: const <BlenderListItem<String>>[
            BlenderListItem<String>(
              id: 'mesh-color-attribute',
              label: 'Color',
              icon: BlenderGlyph.color,
              detail: 'Point - Color',
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'mesh-attributes',
        title: 'Attributes',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: _meshListContent(
          label: 'Attribute',
          items: const <BlenderListItem<String>>[
            BlenderListItem<String>(
              id: 'mesh-attribute-position',
              label: 'position',
              detail: 'Point - Float3',
            ),
            BlenderListItem<String>(
              id: 'mesh-attribute-material',
              label: 'material_index',
              detail: 'Face - Int',
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'mesh-texture-space',
        title: 'Texture Space',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'mesh-texture-mesh',
            label: 'Texture Mesh',
            value: 'Original',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: textureMeshes,
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Texture Mesh changed'),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'mesh-auto-texspace',
            label: 'Auto Texture Space',
            value: true,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Auto Texture Space changed'),
          ),
          BlenderPropertyDescriptor<List<double>>(
            id: 'mesh-texspace-location',
            label: 'Location',
            value: const <double>[0, 0, 0],
            editorBuilder: (context, value, onChanged) =>
                BlenderVectorField(values: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Texture space location changed'),
          ),
          BlenderPropertyDescriptor<List<double>>(
            id: 'mesh-texspace-size',
            label: 'Size',
            value: const <double>[2, 2, 2],
            editorBuilder: (context, value, onChanged) =>
                BlenderVectorField(values: value, min: 0, onChanged: onChanged),
            onChanged: (_) => _setStatus('Texture space size changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mesh-remesh',
        title: 'Remesh',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'mesh-remesh-mode',
            label: 'Mode',
            value: 'Voxel',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: remeshModes,
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Remesh mode changed'),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'mesh-remesh-voxel-size',
            label: 'Voxel Size',
            value: .1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: .001,
              max: 10,
              decimalDigits: 3,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Voxel Size changed'),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'mesh-remesh-adaptivity',
            label: 'Adaptivity',
            value: 0,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 1,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Adaptivity changed'),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'mesh-remesh-preserve-volume',
            label: 'Preserve Volume',
            value: true,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Preserve Volume changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mesh-geometry-data',
        title: 'Geometry Data',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderButton(
              label: 'Clear Custom Normals',
              onPressed: () => _setStatus('Clear Custom Normals'),
            ),
            const SizedBox(height: 4),
            BlenderButton(
              label: 'Reorder Vertices Spatially',
              onPressed: () => _setStatus('Reorder vertices'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'mesh-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Mesh', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'MeshAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'MeshAction',
                  label: 'MeshAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Mesh action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'mesh-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'mesh-custom-property',
            label: 'example_value',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Mesh custom property changed'),
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _cameraPropertyGroups {
    const cameraTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Perspective', label: 'Perspective'),
      BlenderMenuItem<String>(value: 'Orthographic', label: 'Orthographic'),
      BlenderMenuItem<String>(value: 'Panoramic', label: 'Panoramic'),
    ];
    const lensUnits = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Millimeters', label: 'Millimeters'),
      BlenderMenuItem<String>(value: 'Field of View', label: 'Field of View'),
    ];
    const sensorFits = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Auto', label: 'Auto'),
      BlenderMenuItem<String>(value: 'Horizontal', label: 'Horizontal'),
      BlenderMenuItem<String>(value: 'Vertical', label: 'Vertical'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderCheckbox(
          value: value,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    Widget backgroundImages() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        BlenderButton(
          label: 'Add Image',
          onPressed: () => _setStatus('Add camera background image'),
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 70,
          child: BlenderBox(
            padding: EdgeInsets.zero,
            child: BlenderListView<String>(
              items: const <BlenderListItem<String>>[
                BlenderListItem<String>(
                  id: 'camera-background-image',
                  label: 'Reference Image',
                  icon: BlenderGlyph.image,
                  detail: 'Visible',
                ),
              ],
              selectedId: 'camera-background-image',
              onSelected: (item) => _setStatus('Background: ${item.label}'),
            ),
          ),
        ),
      ],
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'camera-lens',
        title: 'Lens',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('camera-type', 'Type', 'Perspective', cameraTypes),
          numberProperty('camera-lens', 'Focal Length', 50, min: 1, max: 500),
          enumProperty('camera-lens-unit', 'Unit', 'Millimeters', lensUnits),
          numberProperty('camera-shift-x', 'Shift X', 0, decimalDigits: 3),
          numberProperty('camera-shift-y', 'Y', 0, decimalDigits: 3),
          numberProperty('camera-clip-start', 'Clip Start', .1, min: .001),
          numberProperty('camera-clip-end', 'End', 1000, min: .001),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-stereoscopy',
        title: 'Stereoscopy',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('camera-stereo-convergence', 'Convergence', true),
          numberProperty(
            'camera-stereo-interocular',
            'Interocular Distance',
            .065,
            min: 0,
            decimalDigits: 3,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-settings',
        title: 'Camera',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('camera-sensor-fit', 'Sensor Fit', 'Auto', sensorFits),
          numberProperty(
            'camera-sensor-width',
            'Sensor Width',
            36,
            min: 1,
            max: 100,
          ),
          numberProperty(
            'camera-sensor-height',
            'Sensor Height',
            24,
            min: 1,
            max: 100,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-depth-of-field',
        title: 'Depth of Field',
        initiallyExpanded: false,
        headerLeading: booleanProperty(
          'camera-use-dof-header',
          '',
          true,
        ).buildEditor(context),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'camera-focus-object',
            'Focus on Object',
            'Empty',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Empty', label: 'Empty'),
              BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
            ],
          ),
          numberProperty('camera-focus-distance', 'Focus Distance', 10, min: 0),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'camera-aperture',
            title: 'Aperture',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'camera-fstop',
                'F-Stop',
                2.8,
                min: .1,
                max: 128,
                decimalDigits: 2,
              ),
              numberProperty(
                'camera-aperture-blades',
                'Blades',
                6,
                min: 0,
                max: 32,
                decimalDigits: 0,
              ),
              numberProperty(
                'camera-aperture-rotation',
                'Rotation',
                0,
                decimalDigits: 2,
              ),
              numberProperty(
                'camera-aperture-ratio',
                'Ratio',
                1,
                min: .01,
                max: 1,
                decimalDigits: 2,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-background-images',
        title: 'Background Images',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: backgroundImages(),
      ),
      BlenderPropertyGroup(
        id: 'camera-display',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('camera-display-size', 'Size', 1, min: .01),
          booleanProperty('camera-show-limits', 'Limits', false),
          booleanProperty('camera-show-mist', 'Mist', false),
          booleanProperty('camera-show-sensor', 'Sensor', true),
          booleanProperty('camera-show-name', 'Name', true),
          booleanProperty('camera-show-passepartout', 'Passepartout', true),
          numberProperty(
            'camera-passepartout-alpha',
            'Alpha',
            .5,
            min: 0,
            max: 1,
            decimalDigits: 2,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'camera-composition-guides',
            title: 'Composition Guides',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('camera-guides-thirds', 'Thirds', true),
              booleanProperty('camera-guides-center', 'Center', false),
              booleanProperty('camera-guides-diagonal', 'Diagonal', false),
              booleanProperty('camera-guides-golden', 'Golden', false),
              booleanProperty('camera-guides-harmony', 'Harmony', false),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-safe-areas',
        title: 'Safe Areas',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('camera-safe-areas-show', 'Show Safe Areas', true),
          numberProperty(
            'camera-safe-title',
            'Title',
            .8,
            min: 0,
            max: 1,
            decimalDigits: 2,
          ),
          numberProperty(
            'camera-safe-action',
            'Action',
            .9,
            min: 0,
            max: 1,
            decimalDigits: 2,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'camera-center-cut',
            title: 'Center-Cut Safe Areas',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('camera-safe-center', 'Show Center-Cut', false),
              numberProperty(
                'camera-safe-title-center',
                'Title',
                .8,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
              numberProperty(
                'camera-safe-action-center',
                'Action',
                .9,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'camera-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Camera', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'CameraAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'CameraAction',
                  label: 'CameraAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Camera action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'camera-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('camera-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _curvePropertyGroups {
    const dimensions = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: '2D', label: '2D'),
      BlenderMenuItem<String>(value: '3D', label: '3D'),
    ];
    const twistModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Z-Up', label: 'Z-Up'),
      BlenderMenuItem<String>(value: 'Minimum', label: 'Minimum'),
      BlenderMenuItem<String>(value: 'Tangent', label: 'Tangent'),
    ];
    const fillModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Half', label: 'Half'),
      BlenderMenuItem<String>(value: 'Full', label: 'Full'),
      BlenderMenuItem<String>(value: 'Front', label: 'Front'),
      BlenderMenuItem<String>(value: 'Back', label: 'Back'),
    ];
    const bevelModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Round', label: 'Round'),
      BlenderMenuItem<String>(value: 'Object', label: 'Object'),
      BlenderMenuItem<String>(value: 'Profile', label: 'Profile'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'curve-shape',
        title: 'Shape',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('curve-dimensions', 'Dimensions', '3D', dimensions),
          numberProperty(
            'curve-resolution-preview',
            'Resolution Preview U',
            12,
            min: 1,
            max: 64,
            decimalDigits: 0,
          ),
          numberProperty(
            'curve-resolution-render',
            'Render U',
            24,
            min: 1,
            max: 64,
            decimalDigits: 0,
          ),
          enumProperty('curve-twist-mode', 'Twist Mode', 'Z-Up', twistModes),
          numberProperty('curve-twist-smooth', 'Smooth', 12, min: 0, max: 32),
          enumProperty('curve-fill-mode', 'Fill Mode', 'Half', fillModes),
          enumProperty(
            'curve-fill-solver',
            'Fill Solver',
            'Even Offset',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Even Offset',
                label: 'Even Offset',
              ),
              BlenderMenuItem<String>(value: 'CDT', label: 'CDT'),
            ],
          ),
          enumProperty(
            'curve-fill-rule',
            'Fill Rule',
            'Even Odd',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Even Odd', label: 'Even Odd'),
              BlenderMenuItem<String>(value: 'Non Zero', label: 'Non Zero'),
            ],
          ),
          booleanProperty('curve-use-radius', 'Curve Deform Radius', true),
          booleanProperty('curve-use-stretch', 'Curve Deform Stretch', true),
          booleanProperty(
            'curve-use-deform-bounds',
            'Curve Deform Bounds',
            false,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'curve-texture-space',
        title: 'Texture Space',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('curve-auto-texspace', 'Auto Texture Space', true),
          numberProperty('curve-texspace-x', 'Location X', 0),
          numberProperty('curve-texspace-y', 'Location Y', 0),
          numberProperty('curve-texspace-z', 'Location Z', 0),
          numberProperty('curve-texspace-size', 'Size', 2),
        ],
      ),
      BlenderPropertyGroup(
        id: 'curve-geometry',
        title: 'Geometry',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('curve-offset', 'Offset', 0),
          numberProperty('curve-extrude', 'Extrude', 0, min: 0),
          BlenderPropertyDescriptor<String>(
            id: 'curve-taper-object',
            label: 'Taper Object',
            value: 'None',
            editorBuilder: (context, value, onChanged) =>
                BlenderDataBlockField<String>(
                  value: value,
                  icon: BlenderGlyph.object,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                    BlenderMenuItem<String>(value: 'Taper', label: 'Taper'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Taper Object changed'),
          ),
          enumProperty(
            'curve-taper-radius-mode',
            'Taper Radius Mode',
            'Override',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Override', label: 'Override'),
              BlenderMenuItem<String>(value: 'Multiply', label: 'Multiply'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'curve-bevel',
            title: 'Bevel',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty('curve-bevel-mode', 'Mode', 'Round', bevelModes),
              numberProperty('curve-bevel-depth', 'Depth', .02, min: 0),
              numberProperty(
                'curve-bevel-resolution',
                'Resolution',
                4,
                min: 0,
                max: 32,
                decimalDigits: 0,
              ),
              booleanProperty('curve-fill-caps', 'Fill Caps', true),
            ],
          ),
          BlenderPropertyGroup(
            id: 'curve-start-end',
            title: 'Start & End Mapping',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('curve-factor-start', 'Factor Start', 0, min: 0),
              numberProperty('curve-factor-end', 'End', 1, min: 0),
              enumProperty(
                'curve-mapping-start',
                'Mapping Start',
                'RESOLUTION',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'RESOLUTION',
                    label: 'Resolution',
                  ),
                  BlenderMenuItem<String>(value: 'SEGMENTS', label: 'Segments'),
                ],
              ),
              enumProperty(
                'curve-mapping-end',
                'End',
                'RESOLUTION',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'RESOLUTION',
                    label: 'Resolution',
                  ),
                  BlenderMenuItem<String>(value: 'SEGMENTS', label: 'Segments'),
                ],
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'curve-path-animation',
        title: 'Path Animation',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('curve-use-path', 'Use Path', true),
          numberProperty('curve-path-duration', 'Frames', 100, min: 1),
          numberProperty('curve-eval-time', 'Evaluation Time', 0),
          booleanProperty('curve-path-clamp', 'Clamp', false),
          booleanProperty('curve-path-follow', 'Follow', false),
        ],
      ),
      BlenderPropertyGroup(
        id: 'curve-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Curve', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'CurveAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'CurveAction',
                  label: 'CurveAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Curve action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'curve-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('curve-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _fontCurvePropertyGroups {
    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> fontField(String id, String label) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: 'Bfont',
        editorBuilder: (context, value, onChanged) =>
            BlenderDataBlockField<String>(
              value: value,
              icon: BlenderGlyph.curve,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Bfont', label: 'Bfont'),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: onChanged,
            ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'font-shape',
        title: 'Shape',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('font-resolution', 'Resolution Preview U', 12, min: 1),
          booleanProperty('font-fast-edit', 'Fast Editing', false),
          enumProperty(
            'font-fill-mode',
            'Fill Mode',
            'Half',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Half', label: 'Half'),
              BlenderMenuItem<String>(value: 'Both', label: 'Both'),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'font-texture-space',
        title: 'Texture Space',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('font-auto-texspace', 'Auto Texture Space', true),
          numberProperty('font-texspace-x', 'Location X', 0),
          numberProperty('font-texspace-y', 'Location Y', 0),
          numberProperty('font-texspace-z', 'Location Z', 0),
          numberProperty('font-texspace-size', 'Size', 2),
        ],
      ),
      BlenderPropertyGroup(
        id: 'font-settings',
        title: 'Font',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          fontField('font-regular', 'Regular'),
          fontField('font-bold', 'Bold'),
          fontField('font-italic', 'Italic'),
          fontField('font-bold-italic', 'Bold & Italic'),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'font-transform',
            title: 'Transform',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('font-size', 'Size', 1, min: 0),
              numberProperty('font-shear', 'Shear', 0, min: -1, max: 1),
              fontField('font-family', 'Family'),
              fontField('font-follow-curve', 'Follow Curve'),
              numberProperty(
                'font-underline-position',
                'Underline Position',
                -0.1,
              ),
              numberProperty(
                'font-underline-height',
                'Underline Thickness',
                0.05,
              ),
              numberProperty('font-small-caps-scale', 'Small Caps Scale', 0.75),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'font-paragraph',
        title: 'Paragraph',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'font-alignment',
            title: 'Alignment',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'font-align-x',
                'Horizontal',
                'Left',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Left', label: 'Left'),
                  BlenderMenuItem<String>(value: 'Center', label: 'Center'),
                  BlenderMenuItem<String>(value: 'Right', label: 'Right'),
                ],
              ),
              enumProperty(
                'font-align-y',
                'Vertical',
                'Top',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Top', label: 'Top'),
                  BlenderMenuItem<String>(value: 'Center', label: 'Center'),
                  BlenderMenuItem<String>(value: 'Bottom', label: 'Bottom'),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'font-spacing',
            title: 'Spacing',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('font-space-character', 'Character Spacing', 1),
              numberProperty('font-space-word', 'Word Spacing', 1),
              numberProperty('font-space-line', 'Line Spacing', 1),
              numberProperty('font-offset-x', 'Offset X', 0),
              numberProperty('font-offset-y', 'Y', 0),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'font-text-boxes',
        title: 'Text Boxes',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'font-overflow',
            'Overflow',
            'Overflow',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Overflow', label: 'Overflow'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
        content: Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: BlenderButton(
            label: 'Add Text Box',
            leading: const BlenderIcon(BlenderGlyph.plus, size: 14),
            onPressed: () => _setStatus('Add text box'),
            width: double.infinity,
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'font-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          fontField('font-action', 'Action'),
          fontField('font-slot', 'Slot'),
        ],
      ),
      BlenderPropertyGroup(
        id: 'font-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('font-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _curvesPropertyGroups {
    BlenderPropertyDescriptor<String> surfaceProperty(
      String id,
      String label,
      String value,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderDataBlockField<String>(
              value: value,
              icon: BlenderGlyph.mesh,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'None', label: 'None'),
                BlenderMenuItem<String>(value: 'Surface', label: 'Surface'),
              ],
              onChanged: onChanged,
            ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'curves-surface',
        title: 'Surface',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          surfaceProperty('curves-surface-object', 'Surface', 'None'),
          surfaceProperty('curves-surface-uv-map', 'UV Map', 'None'),
        ],
      ),
      BlenderPropertyGroup(
        id: 'curves-attributes',
        title: 'Attributes',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const BlenderListView<String>(
              items: <BlenderListItem<String>>[
                BlenderListItem<String>(
                  id: 'curves-radius',
                  label: 'radius',
                  detail: 'Point  •  Float',
                ),
                BlenderListItem<String>(
                  id: 'curves-color',
                  label: 'color',
                  detail: 'Point  •  Color',
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Expanded(
                  child: BlenderButton(
                    label: 'Add Attribute',
                    onPressed: () => _setStatus('Add Curves attribute'),
                  ),
                ),
                const SizedBox(width: 4),
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  tooltip: 'Remove attribute',
                  onPressed: () => _setStatus('Remove Curves attribute'),
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'curves-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Curves', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'CurvesAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'CurvesAction',
                  label: 'CurvesAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Curves action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'curves-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'curves-custom-property',
            label: 'example_value',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Curves custom property changed'),
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _pointCloudPropertyGroups {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'point-cloud-attributes',
        title: 'Attributes',
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const SizedBox(
              height: 88,
              child: BlenderListView<String>(
                items: <BlenderListItem<String>>[
                  BlenderListItem<String>(
                    id: 'point-radius',
                    label: 'radius',
                    detail: 'Float',
                  ),
                  BlenderListItem<String>(
                    id: 'point-color',
                    label: 'color',
                    detail: 'Float Color',
                  ),
                  BlenderListItem<String>(
                    id: 'point-id',
                    label: 'id',
                    detail: 'Integer',
                  ),
                  BlenderListItem<String>(
                    id: 'point-velocity',
                    label: 'velocity',
                    detail: 'Float Vector',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                Expanded(
                  child: BlenderButton(
                    label: 'Add Attribute',
                    onPressed: () => _setStatus('Add Point Cloud attribute'),
                  ),
                ),
                const SizedBox(width: 4),
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  tooltip: 'Remove attribute',
                  onPressed: () => _setStatus('Remove Point Cloud attribute'),
                  size: 24,
                ),
              ],
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'point-cloud-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'point-cloud-custom-property',
            label: 'example_value',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Point Cloud custom property changed'),
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _speakerPropertyGroups {
    const attenuation = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Inverse', label: 'Inverse'),
      BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
      BlenderMenuItem<String>(value: 'Exponential', label: 'Exponential'),
    ];
    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value,
    ) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: 0,
          max: 360,
          decimalDigits: 2,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'speaker-sound',
        title: 'Sound',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'speaker-sound-file',
            label: 'Sound',
            value: 'sound.wav',
            editorBuilder: (context, value, onChanged) =>
                BlenderDataBlockField<String>(
                  value: value,
                  icon: BlenderGlyph.speaker,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'sound.wav',
                      label: 'sound.wav',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Sound changed'),
          ),
          booleanProperty('speaker-muted', 'Muted', false),
          numberProperty('speaker-volume', 'Volume', 1),
          numberProperty('speaker-pitch', 'Pitch', 1),
        ],
      ),
      BlenderPropertyGroup(
        id: 'speaker-distance',
        title: 'Distance',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('speaker-volume-min', 'Volume Min', 0),
          numberProperty('speaker-volume-max', 'Max', 1),
          BlenderPropertyDescriptor<String>(
            id: 'speaker-attenuation',
            label: 'Attenuation',
            value: 'Inverse',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: attenuation,
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Attenuation changed'),
          ),
          numberProperty('speaker-distance-max', 'Max Distance', 100),
          numberProperty('speaker-distance-reference', 'Distance Reference', 1),
        ],
      ),
      BlenderPropertyGroup(
        id: 'speaker-cone',
        title: 'Cone',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('speaker-cone-outer', 'Angle Outer', 360),
          numberProperty('speaker-cone-inner', 'Inner', 360),
          numberProperty('speaker-cone-volume', 'Volume Outer', 1),
        ],
      ),
      BlenderPropertyGroup(
        id: 'speaker-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Speaker', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'SpeakerAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'SpeakerAction',
                  label: 'SpeakerAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Speaker action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'speaker-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('speaker-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _volumePropertyGroups {
    const wireframeTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Boxes', label: 'Boxes'),
      BlenderMenuItem<String>(value: 'Points', label: 'Points'),
      BlenderMenuItem<String>(value: 'Wire', label: 'Wire'),
    ];
    const interpolation = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
      BlenderMenuItem<String>(value: 'Cubic', label: 'Cubic'),
    ];

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value,
    ) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: 0,
          decimalDigits: 2,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'volume-file',
        title: 'OpenVDB File',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'volume-filepath',
            label: 'File Path',
            value: '//smoke.vdb',
            editorBuilder: (context, value, onChanged) =>
                BlenderDataBlockField<String>(
                  value: value,
                  icon: BlenderGlyph.file,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: '//smoke.vdb',
                      label: '//smoke.vdb',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Volume file changed'),
          ),
          booleanProperty('volume-sequence', 'Is Sequence', true),
          numberProperty('volume-frame-duration', 'Frames', 100),
          numberProperty('volume-frame-start', 'Start', 1),
          numberProperty('volume-frame-offset', 'Offset', 0),
          enumProperty(
            'volume-sequence-mode',
            'Mode',
            'REPEAT',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'REPEAT', label: 'Repeat'),
              BlenderMenuItem<String>(value: 'CLIP', label: 'Clip'),
            ],
          ),
        ],
      ),
      const BlenderPropertyGroup(
        id: 'volume-grids',
        title: 'Grids',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: const SizedBox(
          height: 66,
          child: BlenderListView<String>(
            items: const <BlenderListItem<String>>[
              BlenderListItem<String>(
                id: 'density-grid',
                label: 'density',
                detail: 'Float',
              ),
              BlenderListItem<String>(
                id: 'temperature-grid',
                label: 'temperature',
                detail: 'Float',
              ),
              BlenderListItem<String>(
                id: 'velocity-grid',
                label: 'velocity',
                detail: 'Vector',
              ),
            ],
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'volume-render',
        title: 'Render',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'volume-render-space',
            'Space',
            'WORLD',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'WORLD', label: 'World'),
              BlenderMenuItem<String>(value: 'OBJECT', label: 'Object'),
            ],
          ),
          numberProperty('volume-step-size', 'Step Size', .1),
          numberProperty('volume-clipping', 'Clipping', 0),
          enumProperty(
            'volume-precision',
            'Precision',
            'FULL',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'FULL', label: 'Full'),
              BlenderMenuItem<String>(value: 'HALF', label: 'Half'),
            ],
          ),
          BlenderPropertyDescriptor<String>(
            id: 'volume-velocity-grid',
            label: 'Velocity Grid',
            value: 'velocity',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'velocity',
                      label: 'velocity',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Velocity Grid changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'volume-viewport',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'volume-wireframe-type',
            'Wireframe Type',
            'Boxes',
            wireframeTypes,
          ),
          numberProperty('volume-wireframe-detail', 'Detail', 1),
          numberProperty('volume-density', 'Density', 1),
          enumProperty(
            'volume-interpolation',
            'Interpolation',
            'Linear',
            interpolation,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'volume-slicing',
            title: 'Slicing',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('volume-use-slice', 'Use Slice', false),
              enumProperty(
                'volume-slice-axis',
                'Axis',
                'X',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'X', label: 'X'),
                  BlenderMenuItem<String>(value: 'Y', label: 'Y'),
                  BlenderMenuItem<String>(value: 'Z', label: 'Z'),
                ],
              ),
              numberProperty('volume-slice-depth', 'Depth', .5),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'volume-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Volume', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'VolumeAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'VolumeAction',
                  label: 'VolumeAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Volume action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'volume-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('volume-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _lightProbePropertyGroups {
    const probeTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Volume', label: 'Volume'),
      BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
      BlenderMenuItem<String>(value: 'Plane', label: 'Plane'),
    ];
    const influenceTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Box', label: 'Box'),
      BlenderMenuItem<String>(value: 'Ellipsoid', label: 'Ellipsoid'),
    ];
    const parallaxTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Box', label: 'Box'),
      BlenderMenuItem<String>(value: 'Ellipsoid', label: 'Ellipsoid'),
    ];

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderCheckbox(
          value: value,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    Widget actionRow() => Row(
      children: <Widget>[
        Expanded(
          child: BlenderButton(
            label: 'Bake Probe',
            onPressed: () => _setStatus('Bake probe'),
          ),
        ),
        const SizedBox(width: 4),
        BlenderIconButton(
          glyph: BlenderGlyph.deleteIcon,
          onPressed: () => _setStatus('Free probe bake'),
          tooltip: 'Free probe bake',
          size: 24,
        ),
      ],
    );

    Widget animation(String label) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(label, style: BlenderTheme.of(context).textTheme.caption),
        const SizedBox(height: 4),
        BlenderDataBlockField<String>(
          value: '${label}Action',
          icon: BlenderGlyph.action,
          items: <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: '${label}Action',
              label: '${label}Action',
            ),
            const BlenderMenuItem<String>(value: 'None', label: 'None'),
          ],
          onChanged: (value) => _setStatus('$label action: $value'),
        ),
      ],
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'light-probe-probe',
        title: 'Probe',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('light-probe-type', 'Type', 'Volume', probeTypes),
          enumProperty(
            'light-probe-influence-type',
            'Influence Type',
            'Box',
            influenceTypes,
          ),
          numberProperty('light-probe-distance', 'Distance', 10, min: 0),
          numberProperty('light-probe-falloff', 'Falloff', 1, min: 0),
          numberProperty('light-probe-intensity', 'Intensity', 1, min: 0),
          numberProperty(
            'light-probe-resolution-x',
            'Resolution X',
            32,
            min: 1,
            decimalDigits: 0,
          ),
          numberProperty(
            'light-probe-resolution-y',
            'Y',
            32,
            min: 1,
            decimalDigits: 0,
          ),
          numberProperty(
            'light-probe-resolution-z',
            'Z',
            32,
            min: 1,
            decimalDigits: 0,
          ),
          numberProperty('light-probe-clipping-start', 'Clipping Start', .1),
          numberProperty('light-probe-clipping-end', 'End', 40),
          numberProperty('light-probe-normal-bias', 'Normal Bias', .6),
          numberProperty('light-probe-view-bias', 'View Bias', .8),
          numberProperty('light-probe-facing-bias', 'Facing Bias', .5),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'light-probe-visibility',
            title: 'Visibility',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('light-probe-visibility-bias', 'Bias', .05),
              numberProperty(
                'light-probe-visibility-bleed-bias',
                'Bleed Bias',
                .2,
              ),
              numberProperty('light-probe-visibility-blur', 'Blur', .1),
              BlenderPropertyDescriptor<String>(
                id: 'light-probe-visibility-collection',
                label: 'Collection',
                value: 'Collection',
                editorBuilder: (context, value, onChanged) =>
                    BlenderDataBlockField<String>(
                      value: value,
                      icon: BlenderGlyph.collection,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(
                          value: 'Collection',
                          label: 'Collection',
                        ),
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                      ],
                      onChanged: onChanged,
                    ),
                onChanged: (_) => _setStatus('Visibility collection changed'),
              ),
              booleanProperty(
                'light-probe-invert-visibility',
                'Invert Visibility',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-probe-capture',
        title: 'Capture',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('light-probe-capture-start', 'Clipping Start', .1),
          numberProperty('light-probe-capture-end', 'End', 40),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-probe-bake',
        title: 'Bake',
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: actionRow(),
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'light-probe-bake-resolution',
            title: 'Resolution',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'light-probe-bake-resolution-x',
                'Resolution X',
                32,
                min: 1,
                decimalDigits: 0,
              ),
              numberProperty(
                'light-probe-bake-resolution-y',
                'Y',
                32,
                min: 1,
                decimalDigits: 0,
              ),
              numberProperty(
                'light-probe-bake-resolution-z',
                'Z',
                32,
                min: 1,
                decimalDigits: 0,
              ),
              numberProperty(
                'light-probe-bake-samples',
                'Bake Samples',
                128,
                min: 1,
                decimalDigits: 0,
              ),
              numberProperty(
                'light-probe-bake-surfel-density',
                'Surfel Density',
                8,
                min: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'light-probe-bake-capture',
            title: 'Capture',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'light-probe-capture-distance',
                'Distance',
                20,
                min: 0,
              ),
              booleanProperty('light-probe-capture-world', 'World', true),
              booleanProperty(
                'light-probe-capture-indirect',
                'Indirect Light',
                true,
              ),
              booleanProperty('light-probe-capture-emission', 'Emission', true),
            ],
            children: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'light-probe-bake-offset',
                title: 'Offset',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty(
                    'light-probe-surface-bias',
                    'Surface Bias',
                    .1,
                  ),
                  numberProperty('light-probe-escape-bias', 'Escape Bias', .1),
                ],
              ),
              BlenderPropertyGroup(
                id: 'light-probe-bake-clamping',
                title: 'Clamping',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty(
                    'light-probe-clamp-direct',
                    'Direct Light',
                    0,
                    min: 0,
                  ),
                  numberProperty(
                    'light-probe-clamp-indirect',
                    'Indirect Light',
                    10,
                    min: 0,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-probe-parallax',
        title: 'Custom Parallax',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty(
            'light-probe-use-parallax',
            'Use Custom Parallax',
            true,
          ),
          enumProperty(
            'light-probe-parallax-type',
            'Type',
            'Box',
            parallaxTypes,
          ),
          numberProperty('light-probe-parallax-distance', 'Size', 10, min: 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-probe-display',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('light-probe-show-data', 'Data', true),
          numberProperty('light-probe-display-size', 'Size', 1, min: 0),
          booleanProperty('light-probe-show-clip', 'Clipping', true),
          booleanProperty('light-probe-show-influence', 'Influence', true),
          booleanProperty('light-probe-show-parallax', 'Parallax', true),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-probe-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: animation('Light Probe'),
      ),
      BlenderPropertyGroup(
        id: 'light-probe-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('light-probe-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _greasePencilPropertyGroups {
    const blendModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Regular', label: 'Regular'),
      BlenderMenuItem<String>(value: 'Multiply', label: 'Multiply'),
      BlenderMenuItem<String>(value: 'Screen', label: 'Screen'),
      BlenderMenuItem<String>(value: 'Add', label: 'Add'),
    ];
    const onionModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Absolute', label: 'Absolute'),
      BlenderMenuItem<String>(value: 'Relative', label: 'Relative'),
      BlenderMenuItem<String>(value: 'Selected', label: 'Selected'),
    ];
    const keyframeTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Keyframe', label: 'Keyframe'),
      BlenderMenuItem<String>(value: 'Extreme', label: 'Extreme'),
      BlenderMenuItem<String>(value: 'Breakdown', label: 'Breakdown'),
    ];

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    Widget actionButton(BlenderGlyph glyph, String label) => BlenderIconButton(
      glyph: glyph,
      onPressed: () => _setStatus(label),
      tooltip: label,
      size: 22,
    );

    Widget layerList() => SizedBox(
      height: 132,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(
            child: BlenderBox(
              padding: EdgeInsets.zero,
              child: BlenderListView<String>(
                items: <BlenderListItem<String>>[
                  BlenderListItem<String>(
                    id: 'gp-layer-main',
                    label: 'Main',
                    icon: BlenderGlyph.greasepencil,
                  ),
                  BlenderListItem<String>(
                    id: 'gp-layer-ink',
                    label: 'Ink',
                    icon: BlenderGlyph.greasepencil,
                  ),
                  BlenderListItem<String>(
                    id: 'gp-layer-shadow',
                    label: 'Shadow',
                    icon: BlenderGlyph.greasepencil,
                  ),
                ],
                selectedId: 'gp-layer-main',
              ),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              actionButton(BlenderGlyph.plus, 'Add Grease Pencil layer'),
              actionButton(BlenderGlyph.folder, 'Add Grease Pencil group'),
              actionButton(BlenderGlyph.minus, 'Remove Grease Pencil layer'),
              actionButton(BlenderGlyph.more, 'Grease Pencil layer specials'),
              actionButton(BlenderGlyph.stepBack, 'Move layer up'),
              actionButton(BlenderGlyph.stepForward, 'Move layer down'),
            ],
          ),
        ],
      ),
    );

    Widget animation() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Grease Pencil',
          style: BlenderTheme.of(context).textTheme.caption,
        ),
        const SizedBox(height: 4),
        BlenderDataBlockField<String>(
          value: 'GreasePencilAction',
          icon: BlenderGlyph.action,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: 'GreasePencilAction',
              label: 'GreasePencilAction',
            ),
            BlenderMenuItem<String>(value: 'None', label: 'None'),
          ],
          onChanged: (value) => _setStatus('Grease Pencil action: $value'),
        ),
      ],
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'grease-pencil-layers',
        title: 'Layers',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'grease-pencil-blend-mode',
            'Blend Mode',
            'Regular',
            blendModes,
          ),
          numberProperty('grease-pencil-opacity', 'Opacity', 1, min: 0, max: 1),
          booleanProperty('grease-pencil-lights', 'Lights', true),
        ],
        content: layerList(),
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'grease-pencil-masks',
            title: 'Masks',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('grease-pencil-use-masks', 'Use Masks', true),
            ],
            content: const SizedBox(
              height: 66,
              child: BlenderListView<String>(
                items: <BlenderListItem<String>>[
                  BlenderListItem<String>(id: 'gp-mask-ink', label: 'Ink'),
                  BlenderListItem<String>(
                    id: 'gp-mask-shadow',
                    label: 'Shadow',
                  ),
                ],
              ),
            ),
          ),
          BlenderPropertyGroup(
            id: 'grease-pencil-transform',
            title: 'Transform',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('grease-pencil-translation-x', 'Translation X', 0),
              numberProperty('grease-pencil-translation-y', 'Y', 0),
              numberProperty('grease-pencil-translation-z', 'Z', 0),
              numberProperty('grease-pencil-rotation', 'Rotation', 0),
              numberProperty('grease-pencil-scale', 'Scale', 1),
            ],
          ),
          BlenderPropertyGroup(
            id: 'grease-pencil-adjustments',
            title: 'Adjustments',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('grease-pencil-tint-factor', 'Tint Factor', 0),
              numberProperty(
                'grease-pencil-radius-offset',
                'Stroke Thickness',
                0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'grease-pencil-relations',
            title: 'Relations',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyDescriptor<String>(
                id: 'grease-pencil-parent',
                label: 'Parent',
                value: 'None',
                editorBuilder: (context, value, onChanged) =>
                    BlenderDropdown<String>(
                      value: value,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                        BlenderMenuItem<String>(
                          value: 'Armature',
                          label: 'Armature',
                        ),
                      ],
                      onChanged: onChanged,
                    ),
                onChanged: (_) => _setStatus('Parent changed'),
              ),
              numberProperty(
                'grease-pencil-pass-index',
                'Pass Index',
                0,
                min: 0,
                decimalDigits: 0,
              ),
              booleanProperty(
                'grease-pencil-view-layer-mask',
                'View Layer Masks',
                false,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'grease-pencil-layer-display',
            title: 'Display',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'grease-pencil-channel-color',
                'Channel Color',
                true,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'grease-pencil-onion-skinning',
        title: 'Onion Skinning',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'grease-pencil-onion-mode',
            'Mode',
            'Absolute',
            onionModes,
          ),
          numberProperty(
            'grease-pencil-onion-opacity',
            'Opacity',
            .5,
            min: 0,
            max: 1,
          ),
          enumProperty(
            'grease-pencil-onion-keyframe-type',
            'Keyframe Type',
            'Keyframe',
            keyframeTypes,
          ),
          numberProperty(
            'grease-pencil-ghost-before',
            'Frames Before',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          numberProperty(
            'grease-pencil-ghost-after',
            'Frames After',
            1,
            min: 0,
            decimalDigits: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'grease-pencil-onion-colors',
            title: 'Custom Colors',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'grease-pencil-custom-colors',
                'Use Custom Colors',
                false,
              ),
              booleanProperty('grease-pencil-color-before', 'Before', true),
              booleanProperty('grease-pencil-color-after', 'After', true),
            ],
          ),
          BlenderPropertyGroup(
            id: 'grease-pencil-onion-display',
            title: 'Display',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('grease-pencil-onion-fade', 'Fade', true),
              booleanProperty(
                'grease-pencil-onion-loop',
                'Show Start Frame',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'grease-pencil-settings',
        title: 'Settings',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'grease-pencil-stroke-depth-order',
            'Stroke Depth Order',
            '2D Layers',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: '2D Layers', label: '2D Layers'),
              BlenderMenuItem<String>(
                value: '3D Location',
                label: '3D Location',
              ),
            ],
          ),
        ],
      ),
      const BlenderPropertyGroup(
        id: 'grease-pencil-attributes',
        title: 'Attributes',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: const SizedBox(
          height: 66,
          child: BlenderListView<String>(
            items: <BlenderListItem<String>>[
              BlenderListItem<String>(
                id: 'gp-attribute-position',
                label: 'position',
                detail: 'Float Vector',
              ),
              BlenderListItem<String>(
                id: 'gp-attribute-radius',
                label: 'radius',
                detail: 'Float',
              ),
              BlenderListItem<String>(
                id: 'gp-attribute-opacity',
                label: 'opacity',
                detail: 'Float',
              ),
            ],
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'grease-pencil-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: animation(),
      ),
      BlenderPropertyGroup(
        id: 'grease-pencil-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('grease-pencil-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _emptyPropertyGroups {
    const displayTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Plain Axes', label: 'Plain Axes'),
      BlenderMenuItem<String>(value: 'Arrows', label: 'Arrows'),
      BlenderMenuItem<String>(value: 'Single Arrow', label: 'Single Arrow'),
      BlenderMenuItem<String>(value: 'Circle', label: 'Circle'),
      BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
      BlenderMenuItem<String>(value: 'Image', label: 'Image'),
    ];
    const imageDepth = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Default', label: 'Default'),
      BlenderMenuItem<String>(value: 'Front', label: 'Front'),
      BlenderMenuItem<String>(value: 'Back', label: 'Back'),
    ];
    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value,
    ) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: 0,
          decimalDigits: 2,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'empty',
        title: 'Empty',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'empty-display-type',
            label: 'Display As',
            value: 'Plain Axes',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: displayTypes,
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Display As changed'),
          ),
          numberProperty('empty-display-size', 'Size', 1),
          numberProperty('empty-image-offset-x', 'Offset X', 0),
          numberProperty('empty-image-offset-y', 'Y', 0),
          BlenderPropertyDescriptor<String>(
            id: 'empty-image-depth',
            label: 'Depth',
            value: 'Default',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: imageDepth,
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Image Depth changed'),
          ),
          booleanProperty('empty-show-orthographic', 'Orthographic', true),
          booleanProperty('empty-show-perspective', 'Perspective', true),
          booleanProperty('empty-axis-aligned', 'Only Axis Aligned', false),
          booleanProperty('empty-alpha', 'Use Alpha', true),
          numberProperty('empty-opacity', 'Opacity', .8),
        ],
      ),
      BlenderPropertyGroup(
        id: 'empty-image',
        title: 'Image',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'empty-image-file',
            label: 'Image',
            value: 'reference.png',
            editorBuilder: (context, value, onChanged) =>
                BlenderDataBlockField<String>(
                  value: value,
                  icon: BlenderGlyph.image,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'reference.png',
                      label: 'reference.png',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Empty image changed'),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'empty-image-sequence',
            label: 'Sequence',
            value: false,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Image sequence changed'),
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _latticePropertyGroups {
    const interpolationTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
      BlenderMenuItem<String>(value: 'Cardinal', label: 'Cardinal'),
      BlenderMenuItem<String>(value: 'B-Spline', label: 'B-Spline'),
    ];

    BlenderPropertyDescriptor<int> integerProperty(
      String id,
      String label,
      int value,
    ) {
      return BlenderPropertyDescriptor<int>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value.toDouble(),
          min: 1,
          max: 64,
          decimalDigits: 0,
          onChanged: (next) => onChanged(next.round()),
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: interpolationTypes,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'lattice',
        title: 'Lattice',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          integerProperty('lattice-points-u', 'Resolution U', 4),
          integerProperty('lattice-points-v', 'V', 4),
          integerProperty('lattice-points-w', 'W', 4),
          enumProperty('lattice-interpolation-u', 'Interpolation U', 'Linear'),
          enumProperty('lattice-interpolation-v', 'V', 'Linear'),
          enumProperty('lattice-interpolation-w', 'W', 'B-Spline'),
          BlenderPropertyDescriptor<bool>(
            id: 'lattice-use-outside',
            label: 'Outside',
            value: false,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (_) => _setStatus('Outside changed'),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'lattice-vertex-group',
            label: 'Vertex Group',
            value: 'None',
            editorBuilder: (context, value, onChanged) =>
                BlenderDataBlockField<String>(
                  value: value,
                  icon: BlenderGlyph.object,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                    BlenderMenuItem<String>(value: 'Deform', label: 'Deform'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Vertex Group changed'),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'lattice-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Lattice', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'LatticeAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'LatticeAction',
                  label: 'LatticeAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Lattice action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'lattice-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'lattice-custom-property',
            label: 'example_value',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Lattice custom property changed'),
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _metaballPropertyGroups {
    const elementTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Ball', label: 'Ball'),
      BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
      BlenderMenuItem<String>(value: 'Capsule', label: 'Capsule'),
      BlenderMenuItem<String>(value: 'Ellipsoid', label: 'Ellipsoid'),
      BlenderMenuItem<String>(value: 'Plane', label: 'Plane'),
    ];
    const updateMethods = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Continuous', label: 'Continuous'),
      BlenderMenuItem<String>(value: 'Half', label: 'Half'),
      BlenderMenuItem<String>(value: 'Fast', label: 'Fast'),
    ];

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value,
    ) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: 0,
          decimalDigits: 3,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'metaball',
        title: 'Metaball',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('metaball-resolution', 'Resolution Viewport', .4),
          numberProperty('metaball-render-resolution', 'Render', .2),
          numberProperty('metaball-threshold', 'Influence Threshold', .6),
          enumProperty(
            'metaball-update-method',
            'Update on Edit',
            'Continuous',
            updateMethods,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'metaball-texture-space',
        title: 'Texture Space',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('metaball-auto-texspace', 'Auto Texture Space', true),
          numberProperty('metaball-texspace-location', 'Location', 0),
          numberProperty('metaball-texspace-size', 'Size', 2),
        ],
      ),
      BlenderPropertyGroup(
        id: 'metaball-active-element',
        title: 'Active Element',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('metaball-element-type', 'Type', 'Ball', elementTypes),
          numberProperty('metaball-stiffness', 'Stiffness', 2),
          numberProperty('metaball-radius', 'Radius', 1),
          booleanProperty('metaball-negative', 'Negative', false),
          booleanProperty('metaball-hide', 'Hide', false),
          numberProperty('metaball-size-x', 'Size X', 1),
          numberProperty('metaball-size-y', 'Y', 1),
          numberProperty('metaball-size-z', 'Z', 1),
        ],
      ),
      BlenderPropertyGroup(
        id: 'metaball-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Metaball', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'MetaballAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'MetaballAction',
                  label: 'MetaballAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Metaball action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'metaball-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('metaball-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _armaturePropertyGroups {
    const displayTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Octahedral', label: 'Octahedral'),
      BlenderMenuItem<String>(value: 'Stick', label: 'Stick'),
      BlenderMenuItem<String>(value: 'B-Bone', label: 'B-Bone'),
      BlenderMenuItem<String>(value: 'Envelope', label: 'Envelope'),
    ];
    const posePositions = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Pose Position', label: 'Pose Position'),
      BlenderMenuItem<String>(value: 'Rest Position', label: 'Rest Position'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderCheckbox(
          value: value,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    Widget boneCollections() => SizedBox(
      height: 132,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(
            child: BlenderBox(
              padding: EdgeInsets.zero,
              child: BlenderBoneCollectionTree(
                showPanel: false,
                collections: const <BlenderBoneCollection>[
                  BlenderBoneCollection(
                    id: 'armature-deform',
                    name: 'Deform',
                    active: true,
                    initiallyExpanded: true,
                    children: <BlenderBoneCollection>[
                      BlenderBoneCollection(
                        id: 'armature-spine',
                        name: 'Spine',
                        hasSelectedBones: true,
                      ),
                      BlenderBoneCollection(
                        id: 'armature-limbs',
                        name: 'Limbs',
                      ),
                    ],
                  ),
                  BlenderBoneCollection(
                    id: 'armature-controls',
                    name: 'Controls',
                    visible: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.plus,
                onPressed: () => _setStatus('Add bone collection'),
                tooltip: 'Add bone collection',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: () => _setStatus('Remove bone collection'),
                tooltip: 'Remove bone collection',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.more,
                onPressed: () => _setStatus('Bone collection specials'),
                tooltip: 'Bone collection specials',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.stepBack,
                onPressed: () => _setStatus('Move bone collection up'),
                tooltip: 'Move bone collection up',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.stepForward,
                onPressed: () => _setStatus('Move bone collection down'),
                tooltip: 'Move bone collection down',
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );

    Widget selectionSets() => SizedBox(
      height: 82,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: BlenderBox(
              padding: EdgeInsets.zero,
              child: BlenderListView<String>(
                items: const <BlenderListItem<String>>[
                  BlenderListItem<String>(id: 'sel-all', label: 'All Controls'),
                  BlenderListItem<String>(
                    id: 'sel-face',
                    label: 'Face Controls',
                  ),
                ],
                selectedId: 'sel-all',
                onSelected: (item) =>
                    _setStatus('Selection set: ${item.label}'),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.plus,
                onPressed: () => _setStatus('Add selection set'),
                tooltip: 'Add selection set',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: () => _setStatus('Remove selection set'),
                tooltip: 'Remove selection set',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.more,
                onPressed: () => _setStatus('Selection set specials'),
                tooltip: 'Selection set specials',
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'armature-pose',
        title: 'Pose',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'armature-pose-position',
            'Position',
            'Pose Position',
            posePositions,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'armature-display',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'armature-display-type',
            'Display As',
            'Octahedral',
            displayTypes,
          ),
          booleanProperty('armature-show-names', 'Names', true),
          booleanProperty('armature-show-shapes', 'Shapes', true),
          booleanProperty('armature-show-colors', 'Bone Colors', true),
          booleanProperty('armature-in-front', 'In Front', false),
          booleanProperty('armature-show-axes', 'Axes', false),
          enumProperty(
            'armature-axes-position',
            'Position',
            'Tail',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Head', label: 'Head'),
              BlenderMenuItem<String>(value: 'Tail', label: 'Tail'),
            ],
          ),
          enumProperty(
            'armature-relation-lines',
            'Relations',
            'Head to Tail',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Head to Tail',
                label: 'Head to Tail',
              ),
              BlenderMenuItem<String>(
                value: 'Tail to Head',
                label: 'Tail to Head',
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'armature-bone-collections',
        title: 'Bone Collections',
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: boneCollections(),
      ),
      BlenderPropertyGroup(
        id: 'armature-ik',
        title: 'Inverse Kinematics',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'armature-ik-solver',
            'Solver',
            'Standard',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Standard', label: 'Standard'),
              BlenderMenuItem<String>(value: 'iTaSC', label: 'iTaSC'),
            ],
          ),
          numberProperty(
            'armature-ik-precision',
            'Precision',
            .001,
            min: 0,
            decimalDigits: 4,
          ),
          numberProperty(
            'armature-ik-iterations',
            'Iterations',
            500,
            min: 1,
            decimalDigits: 0,
          ),
          booleanProperty('armature-ik-auto-step', 'Auto Step', true),
        ],
      ),
      BlenderPropertyGroup(
        id: 'armature-motion-paths',
        title: 'Motion Paths',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('armature-motion-paths-show', 'Show Paths', true),
          numberProperty(
            'armature-motion-paths-frame-before',
            'Before',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          numberProperty(
            'armature-motion-paths-frame-after',
            'After',
            20,
            min: 0,
            decimalDigits: 0,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'armature-motion-paths-display',
            title: 'Display',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'armature-motion-paths-keyframes',
                'Keyframes',
                true,
              ),
              booleanProperty(
                'armature-motion-paths-bone-heads',
                'Bone Heads',
                false,
              ),
              booleanProperty(
                'armature-motion-paths-bone-tail',
                'Bone Tails',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'armature-selection-sets',
        title: 'Selection Sets',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: selectionSets(),
      ),
      BlenderPropertyGroup(
        id: 'armature-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Armature', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'ArmatureAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'ArmatureAction',
                  label: 'ArmatureAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Armature action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'armature-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('armature-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _bonePropertyGroups {
    const rotationModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'XYZ Euler', label: 'XYZ Euler'),
      BlenderMenuItem<String>(value: 'Quaternion', label: 'Quaternion'),
      BlenderMenuItem<String>(value: 'Axis Angle', label: 'Axis Angle'),
    ];
    const displayTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Octahedral', label: 'Octahedral'),
      BlenderMenuItem<String>(value: 'Stick', label: 'Stick'),
      BlenderMenuItem<String>(value: 'B-Bone', label: 'B-Bone'),
      BlenderMenuItem<String>(value: 'Envelope', label: 'Envelope'),
      BlenderMenuItem<String>(value: 'Wire', label: 'Wire'),
    ];
    const handleTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Automatic', label: 'Automatic'),
      BlenderMenuItem<String>(value: 'Absolute', label: 'Absolute'),
      BlenderMenuItem<String>(value: 'Relative', label: 'Relative'),
      BlenderMenuItem<String>(value: 'Tangent', label: 'Tangent'),
    ];

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderCheckbox(
          value: value,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    Widget boneCollections() => SizedBox(
      height: 82,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Expanded(
            child: BlenderBox(
              padding: EdgeInsets.zero,
              child: BlenderListView<String>(
                items: <BlenderListItem<String>>[
                  BlenderListItem<String>(
                    id: 'bone-collection-deform',
                    label: 'Deform',
                    icon: BlenderGlyph.collection,
                  ),
                  BlenderListItem<String>(
                    id: 'bone-collection-controls',
                    label: 'Controls',
                    icon: BlenderGlyph.collection,
                  ),
                ],
                selectedId: 'bone-collection-deform',
              ),
            ),
          ),
          const SizedBox(width: 4),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.eye,
                onPressed: () =>
                    _setStatus('Toggle bone collection visibility'),
                tooltip: 'Toggle bone collection visibility',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.lock,
                onPressed: () => _setStatus('Toggle bone collection solo'),
                tooltip: 'Toggle bone collection solo',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: () => _setStatus('Unassign bone collection'),
                tooltip: 'Unassign bone collection',
                size: 22,
              ),
            ],
          ),
        ],
      ),
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'bone-transform',
        title: 'Transform',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('bone-location-x', 'Location X', 0),
          numberProperty('bone-location-y', 'Y', 0),
          numberProperty('bone-location-z', 'Z', 0),
          numberProperty('bone-rotation-x', 'Rotation X', 0),
          numberProperty('bone-rotation-y', 'Y', 0),
          numberProperty('bone-rotation-z', 'Z', 0),
          enumProperty(
            'bone-rotation-mode',
            'Mode',
            'XYZ Euler',
            rotationModes,
          ),
          numberProperty('bone-scale-x', 'Scale X', 1),
          numberProperty('bone-scale-y', 'Y', 1),
          numberProperty('bone-scale-z', 'Z', 1),
          numberProperty('bone-head-x', 'Head X', 0),
          numberProperty('bone-tail-x', 'Tail X', 1),
          numberProperty('bone-length', 'Length', 1, min: 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-bendy-bones',
        title: 'Bendy Bones',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'bone-bbone-segments',
            'Segments',
            4,
            min: 1,
            decimalDigits: 0,
          ),
          numberProperty('bone-bbone-size-x', 'Display Size X', .25, min: 0),
          numberProperty('bone-bbone-size-z', 'Z', .25, min: 0),
          enumProperty(
            'bone-bbone-mapping',
            'Vertex Mapping',
            'Automatic',
            handleTypes,
          ),
          numberProperty('bone-bbone-curve-in-x', 'Curve In X', 0),
          numberProperty('bone-bbone-curve-out-x', 'Curve Out X', 0),
          numberProperty('bone-bbone-roll-in', 'Roll In', 0),
          numberProperty('bone-bbone-roll-out', 'Out', 0),
          numberProperty('bone-bbone-ease-in', 'Ease In', 1, min: 0),
          numberProperty('bone-bbone-ease-out', 'Out', 1, min: 0),
          enumProperty(
            'bone-bbone-handle-start',
            'Start Handle',
            'Automatic',
            handleTypes,
          ),
          enumProperty(
            'bone-bbone-handle-end',
            'End Handle',
            'Automatic',
            handleTypes,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-relations',
        title: 'Relations',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'bone-parent',
            label: 'Parent',
            value: 'Upper Arm',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'Upper Arm',
                      label: 'Upper Arm',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Bone parent changed'),
          ),
          booleanProperty('bone-relative-parent', 'Relative Parent', false),
          booleanProperty('bone-connected', 'Connected', true),
          booleanProperty('bone-local-location', 'Local Location', true),
          booleanProperty('bone-inherit-rotation', 'Inherit Rotation', true),
          enumProperty(
            'bone-inherit-scale',
            'Inherit Scale',
            'Full',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Full', label: 'Full'),
              BlenderMenuItem<String>(value: 'Fix Shear', label: 'Fix Shear'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'bone-collections',
            title: 'Bone Collections',
            properties: const <BlenderPropertyDescriptor<dynamic>>[],
            content: boneCollections(),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-display',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('bone-hide', 'Hide', false),
          booleanProperty('bone-hide-select', 'Selectable', true),
          enumProperty(
            'bone-display-type',
            'Display As',
            'Octahedral',
            displayTypes,
          ),
          enumProperty(
            'bone-color-palette',
            'Bone Color',
            'Pose Bone Color Set 1',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Pose Bone Color Set 1',
                label: 'Pose Bone Color Set 1',
              ),
              BlenderMenuItem<String>(value: 'Custom', label: 'Custom'),
            ],
          ),
          enumProperty(
            'bone-pose-color-palette',
            'Pose Bone Color',
            'Pose Bone Color Set 1',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Pose Bone Color Set 1',
                label: 'Pose Bone Color Set 1',
              ),
              BlenderMenuItem<String>(value: 'Custom', label: 'Custom'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'bone-custom-shape',
            title: 'Custom Shape',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyDescriptor<String>(
                id: 'bone-custom-shape-object',
                label: 'Custom Shape',
                value: 'None',
                editorBuilder: (context, value, onChanged) =>
                    BlenderDropdown<String>(
                      value: value,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                        BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
                      ],
                      onChanged: onChanged,
                    ),
                onChanged: (_) => _setStatus('Custom shape changed'),
              ),
              numberProperty('bone-custom-shape-translation', 'Translation', 0),
              numberProperty('bone-custom-shape-rotation', 'Rotation', 0),
              numberProperty('bone-custom-shape-scale', 'Scale', 1, min: 0),
              booleanProperty('bone-custom-shape-wire', 'Wireframe', false),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-inverse-kinematics',
        title: 'Inverse Kinematics',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('bone-ik-stretch', 'IK Stretch', 1, min: 0, max: 1),
          booleanProperty('bone-lock-ik-x', 'Lock IK X', false),
          booleanProperty('bone-lock-ik-y', 'Y', false),
          booleanProperty('bone-lock-ik-z', 'Z', false),
          numberProperty(
            'bone-ik-stiffness-x',
            'Stiffness X',
            0,
            min: 0,
            max: 1,
          ),
          numberProperty('bone-ik-stiffness-y', 'Y', 0, min: 0, max: 1),
          numberProperty('bone-ik-stiffness-z', 'Z', 0, min: 0, max: 1),
          booleanProperty('bone-ik-limit-x', 'Limit X', false),
          booleanProperty('bone-ik-limit-y', 'Y', false),
          booleanProperty('bone-ik-limit-z', 'Z', false),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-deform',
        title: 'Deform',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('bone-use-deform', 'Use Deform', true),
          numberProperty(
            'bone-envelope-distance',
            'Envelope Distance',
            .25,
            min: 0,
          ),
          numberProperty('bone-envelope-weight', 'Envelope Weight', 1, min: 0),
          booleanProperty('bone-envelope-multiply', 'Envelope Multiply', false),
          numberProperty('bone-head-radius', 'Radius Head', .1, min: 0),
          numberProperty('bone-tail-radius', 'Tail', .1, min: 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'bone-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('bone-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _lightPropertyGroups {
    const lightTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Point', label: 'Point'),
      BlenderMenuItem<String>(value: 'Sun', label: 'Sun'),
      BlenderMenuItem<String>(value: 'Spot', label: 'Spot'),
      BlenderMenuItem<String>(value: 'Area', label: 'Area'),
    ];
    const areaShapes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Square', label: 'Square'),
      BlenderMenuItem<String>(value: 'Disk', label: 'Disk'),
      BlenderMenuItem<String>(value: 'Rectangle', label: 'Rectangle'),
      BlenderMenuItem<String>(value: 'Ellipse', label: 'Ellipse'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderCheckbox(
          value: value,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      const BlenderPropertyGroup(
        id: 'light-preview',
        title: 'Preview',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: SizedBox(
          height: 90,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFF202020)),
            child: Center(child: BlenderIcon(BlenderGlyph.light, size: 46)),
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'light-settings',
        title: 'Light',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('light-type', 'Type', 'Point', lightTypes),
          booleanProperty('light-temperature', 'Use Temperature', false),
          numberProperty(
            'light-temperature-value',
            'Temperature',
            6500,
            min: 1000,
            max: 20000,
            decimalDigits: 0,
          ),
          numberProperty(
            'light-energy',
            'Power',
            1000,
            min: 0,
            decimalDigits: 0,
          ),
          numberProperty('light-exposure', 'Exposure', 0, decimalDigits: 2),
          booleanProperty('light-normalize', 'Normalize', true),
          numberProperty(
            'light-radius',
            'Radius',
            .25,
            min: 0,
            decimalDigits: 3,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'light-shadow',
            title: 'Shadow',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('light-use-shadow', 'Use Shadow', true),
              booleanProperty('light-shadow-jitter', 'Jitter', false),
              numberProperty(
                'light-shadow-filter',
                'Filter',
                1,
                min: 0,
                decimalDigits: 2,
              ),
              numberProperty(
                'light-shadow-resolution',
                'Resolution Limit',
                2048,
                min: 1,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'light-influence',
            title: 'Influence',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'light-diffuse',
                'Diffuse',
                1,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
              numberProperty(
                'light-glossy',
                'Glossy',
                1,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
              numberProperty(
                'light-transmission',
                'Transmission',
                1,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
              numberProperty(
                'light-volume',
                'Volume Scatter',
                1,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'light-custom-distance',
            title: 'Custom Distance',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'light-use-custom-distance',
                'Use Custom Distance',
                false,
              ),
              numberProperty(
                'light-cutoff-distance',
                'Distance',
                40,
                min: 0,
                decimalDigits: 2,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'light-beam-shape',
            title: 'Beam Shape',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'light-spot-angle',
                'Angle',
                .785,
                min: 0,
                max: 3.14,
                decimalDigits: 3,
              ),
              numberProperty(
                'light-spot-blend',
                'Blend',
                .15,
                min: 0,
                max: 1,
                decimalDigits: 2,
              ),
              enumProperty('light-area-shape', 'Shape', 'Square', areaShapes),
              numberProperty(
                'light-area-size',
                'Size',
                1,
                min: 0,
                decimalDigits: 2,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'light-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Light', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'LightAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'LightAction',
                  label: 'LightAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Light action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'light-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('light-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _texturePropertyGroups {
    const textureTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Clouds', label: 'Clouds'),
      BlenderMenuItem<String>(value: 'Marble', label: 'Marble'),
      BlenderMenuItem<String>(value: 'Voronoi', label: 'Voronoi'),
      BlenderMenuItem<String>(value: 'Image or Movie', label: 'Image or Movie'),
    ];
    const textureCoordinates = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Generated', label: 'Generated'),
      BlenderMenuItem<String>(value: 'UV', label: 'UV'),
      BlenderMenuItem<String>(value: 'Object', label: 'Object'),
      BlenderMenuItem<String>(value: 'Global', label: 'Global'),
    ];
    const blendTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Mix', label: 'Mix'),
      BlenderMenuItem<String>(value: 'Multiply', label: 'Multiply'),
      BlenderMenuItem<String>(value: 'Screen', label: 'Screen'),
      BlenderMenuItem<String>(value: 'Add', label: 'Add'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    return <BlenderPropertyGroup>[
      const BlenderPropertyGroup(
        id: 'texture-preview',
        title: 'Preview',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: const SizedBox(
          height: 92,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFF202020)),
            child: Center(child: BlenderIcon(BlenderGlyph.texture, size: 44)),
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'texture-context',
        title: 'Texture',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderPropertyRow(
              label: 'Texture User',
              editor: BlenderTextureUserSelector(
                inTextureProperties: true,
                selectedId: 'base-color',
                users: const <BlenderTextureUser>[
                  BlenderTextureUser(
                    id: 'base-color',
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
                  BlenderTextureUser(
                    id: 'modifier',
                    name: 'Displace',
                    textureName: 'Image Texture',
                    category: 'Modifiers',
                    icon: BlenderGlyph.modifier,
                  ),
                ],
                onChanged: (user) => _setStatus('Texture user: ${user.name}'),
              ),
            ),
          ],
        ),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('texture-type', 'Type', 'Clouds', textureTypes),
          booleanProperty('texture-use-nodes', 'Use Nodes', false),
        ],
      ),
      BlenderPropertyGroup(
        id: 'texture-node',
        title: 'Node',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('texture-node-active', 'Use Texture Node', true),
        ],
        content: const SizedBox(
          height: 42,
          child: BlenderBox(child: Center(child: Text('Texture Node'))),
        ),
      ),
      BlenderPropertyGroup(
        id: 'texture-clouds',
        title: 'Clouds',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'texture-noise-basis',
            'Noise Basis',
            'Improved Perlin',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Improved Perlin',
                label: 'Improved Perlin',
              ),
              BlenderMenuItem<String>(
                value: 'Original Perlin',
                label: 'Original Perlin',
              ),
              BlenderMenuItem<String>(value: 'Voronoi', label: 'Voronoi'),
            ],
          ),
          numberProperty('texture-noise-scale', 'Scale', .25, min: 0),
          numberProperty(
            'texture-noise-depth',
            'Depth',
            2,
            min: 0,
            max: 30,
            decimalDigits: 0,
          ),
          numberProperty('texture-noise-nabla', 'Nabla', .03, min: 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'texture-mapping',
        title: 'Mapping',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'texture-coordinates',
            'Coordinates',
            'Generated',
            textureCoordinates,
          ),
          enumProperty(
            'texture-projection',
            'Projection',
            'Flat',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Flat', label: 'Flat'),
              BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
              BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
            ],
          ),
          numberProperty('texture-offset-x', 'Offset X', 0),
          numberProperty('texture-offset-y', 'Y', 0),
          numberProperty('texture-offset-z', 'Z', 0),
          numberProperty('texture-scale-x', 'Scale X', 1),
          numberProperty('texture-scale-y', 'Y', 1),
          numberProperty('texture-scale-z', 'Z', 1),
        ],
      ),
      BlenderPropertyGroup(
        id: 'texture-influence',
        title: 'Influence',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('texture-blend-type', 'Blend', 'Mix', blendTypes),
          numberProperty('texture-color-factor', 'Color', 1, min: 0, max: 1),
          numberProperty('texture-alpha-factor', 'Alpha', 1, min: 0, max: 1),
          numberProperty('texture-normal-factor', 'Normal', 1, min: 0, max: 1),
          booleanProperty('texture-use-map-time', 'General Time', false),
          booleanProperty('texture-use-map-life', 'Lifetime', false),
          booleanProperty('texture-use-map-density', 'Density', false),
        ],
      ),
      BlenderPropertyGroup(
        id: 'texture-colors',
        title: 'Colors',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('texture-clamp', 'Clamp', false),
          numberProperty('texture-multiply-red', 'Multiply R', 1, min: 0),
          numberProperty('texture-multiply-green', 'G', 1, min: 0),
          numberProperty('texture-multiply-blue', 'B', 1, min: 0),
          numberProperty('texture-intensity', 'Intensity', 1, min: 0),
          numberProperty('texture-contrast', 'Contrast', 1, min: 0),
          numberProperty('texture-saturation', 'Saturation', 1, min: 0),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'texture-color-ramp',
            title: 'Color Ramp',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('texture-use-color-ramp', 'Use Color Ramp', true),
            ],
            content: const SizedBox(
              height: 36,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[Color(0xFF202020), Color(0xFF4772B3)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'texture-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Texture', style: BlenderTheme.of(context).textTheme.caption),
            const SizedBox(height: 4),
            BlenderDataBlockField<String>(
              value: 'TextureAction',
              icon: BlenderGlyph.action,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'TextureAction',
                  label: 'TextureAction',
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
              onChanged: (value) => _setStatus('Texture action: $value'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'texture-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('texture-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _collectionPropertyGroups {
    const lineArtUsages = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Inclusive', label: 'Inclusive'),
      BlenderMenuItem<String>(value: 'Exclusive', label: 'Exclusive'),
      BlenderMenuItem<String>(value: 'None', label: 'None'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    Widget exporterContent() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const SizedBox(
          height: 70,
          child: BlenderListView<String>(
            items: const <BlenderListItem<String>>[
              BlenderListItem<String>(id: 'collection-gltf', label: 'glTF 2.0'),
              BlenderListItem<String>(id: 'collection-fbx', label: 'FBX'),
            ],
            selectedId: 'collection-gltf',
          ),
        ),
        const SizedBox(height: 4),
        BlenderPathField(
          controller: _exporterPathController,
          placeholder: 'File Path',
          onBrowse: () => _setStatus('Browse exporter path'),
        ),
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            Expanded(
              child: BlenderButton(
                label: 'Export All',
                onPressed: () => _setStatus('Export all collections'),
              ),
            ),
            const SizedBox(width: 4),
            BlenderIconButton(
              glyph: BlenderGlyph.plus,
              onPressed: () => _setStatus('Add exporter'),
              tooltip: 'Add exporter',
              size: 24,
            ),
            BlenderIconButton(
              glyph: BlenderGlyph.minus,
              onPressed: () => _setStatus('Remove exporter'),
              tooltip: 'Remove exporter',
              size: 24,
            ),
          ],
        ),
      ],
    );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'collection-visibility',
        title: 'Visibility',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('collection-selectable', 'Selectable', true),
          booleanProperty('collection-renders', 'Renders', true),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'collection-view-layer',
            title: 'View Layer',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('collection-include', 'Include', true),
              booleanProperty('collection-holdout', 'Holdout', false),
              booleanProperty(
                'collection-indirect-only',
                'Indirect Only',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'collection-importer',
        title: 'Importer',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty(
            'collection-keep-collections',
            'Keep Collections',
            true,
          ),
        ],
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderPathField(
              controller: _importerPathController,
              placeholder: 'File Path',
              onBrowse: () => _setStatus('Browse importer path'),
            ),
            const SizedBox(height: 4),
            BlenderButton(
              label: 'Remove Importer',
              onPressed: () => _setStatus('Remove collection importer'),
            ),
          ],
        ),
      ),
      BlenderPropertyGroup(
        id: 'collection-exporters',
        title: 'Exporters',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: exporterContent(),
      ),
      BlenderPropertyGroup(
        id: 'collection-instancing',
        title: 'Instancing',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'collection-instance-offset-x',
            'Instance Offset X',
            0,
          ),
          numberProperty('collection-instance-offset-y', 'Y', 0),
          numberProperty('collection-instance-offset-z', 'Z', 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'collection-line-art',
        title: 'Line Art',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'collection-lineart-usage',
            'Usage',
            'Inclusive',
            lineArtUsages,
          ),
          booleanProperty('collection-lineart-mask', 'Collection Mask', false),
          booleanProperty(
            'collection-lineart-priority-enabled',
            'Intersection Priority',
            false,
          ),
          numberProperty(
            'collection-lineart-priority',
            'Priority',
            0,
            min: 0,
            decimalDigits: 0,
          ),
          booleanProperty('collection-lineart-mask-1', 'Mask 1', true),
          booleanProperty('collection-lineart-mask-2', 'Mask 2', false),
          booleanProperty('collection-lineart-mask-3', 'Mask 3', false),
          booleanProperty('collection-lineart-mask-4', 'Mask 4', false),
        ],
      ),
      BlenderPropertyGroup(
        id: 'collection-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('collection-custom-property', 'example_value', 1),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _viewLayerPropertyGroups {
    const overrideSamples = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
      BlenderMenuItem<String>(value: '128', label: '128'),
      BlenderMenuItem<String>(value: '256', label: '256'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 0,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    Widget listContent({required List<BlenderListItem<String>> items}) =>
        SizedBox(
          height: 76,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: BlenderBox(
                  padding: EdgeInsets.zero,
                  child: BlenderListView<String>(items: items),
                ),
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BlenderIconButton(
                    glyph: BlenderGlyph.plus,
                    onPressed: () => _setStatus('Add view layer item'),
                    tooltip: 'Add view layer item',
                    size: 22,
                  ),
                  BlenderIconButton(
                    glyph: BlenderGlyph.minus,
                    onPressed: () => _setStatus('Remove view layer item'),
                    tooltip: 'Remove view layer item',
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
        );

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'view-layer-settings',
        title: 'View Layer',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('view-layer-use', 'Use for Rendering', true),
          booleanProperty(
            'view-layer-single-layer',
            'Render Single Layer',
            false,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'view-layer-passes',
        title: 'Passes',
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'view-layer-passes-data',
            title: 'Data',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('view-layer-pass-combined', 'Combined', true),
              booleanProperty('view-layer-pass-z', 'Z', false),
              booleanProperty('view-layer-pass-mist', 'Mist', false),
              booleanProperty('view-layer-pass-normal', 'Normal', false),
              booleanProperty('view-layer-pass-position', 'Position', false),
              booleanProperty('view-layer-pass-vector', 'Vector', false),
              booleanProperty(
                'view-layer-pass-grease-pencil',
                'Grease Pencil',
                true,
              ),
              booleanProperty(
                'view-layer-pass-denoising',
                'Denoising Data',
                false,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'view-layer-passes-light',
            title: 'Light',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'view-layer-diffuse-direct',
                'Diffuse Light',
                true,
              ),
              booleanProperty(
                'view-layer-diffuse-color',
                'Diffuse Color',
                false,
              ),
              booleanProperty(
                'view-layer-glossy-direct',
                'Specular Light',
                false,
              ),
              booleanProperty(
                'view-layer-glossy-color',
                'Specular Color',
                false,
              ),
              booleanProperty(
                'view-layer-volume-direct',
                'Volume Light',
                false,
              ),
              booleanProperty('view-layer-emission', 'Emission', false),
              booleanProperty('view-layer-environment', 'Environment', false),
              booleanProperty('view-layer-shadow', 'Shadow', false),
              booleanProperty('view-layer-ao', 'Ambient Occlusion', false),
              booleanProperty('view-layer-transparent', 'Transparent', false),
              numberProperty(
                'view-layer-ao-distance',
                'Occlusion Distance',
                10,
                min: 0,
                decimalDigits: 2,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'view-layer-passes-aov',
            title: 'Shader AOV',
            properties: const <BlenderPropertyDescriptor<dynamic>>[],
            content: listContent(
              items: const <BlenderListItem<String>>[
                BlenderListItem<String>(
                  id: 'aov-beauty',
                  label: 'Beauty',
                  detail: 'Color',
                ),
                BlenderListItem<String>(
                  id: 'aov-mask',
                  label: 'Mask',
                  detail: 'Value',
                ),
                BlenderListItem<String>(
                  id: 'aov-depth',
                  label: 'Depth',
                  detail: 'Value',
                ),
              ],
            ),
          ),
          BlenderPropertyGroup(
            id: 'view-layer-passes-cryptomatte',
            title: 'Cryptomatte',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('view-layer-crypto-object', 'Object', true),
              booleanProperty('view-layer-crypto-material', 'Material', false),
              booleanProperty('view-layer-crypto-asset', 'Asset', false),
              numberProperty(
                'view-layer-crypto-depth',
                'Levels',
                6,
                min: 1,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'view-layer-passes-lightgroups',
            title: 'Light Groups',
            properties: const <BlenderPropertyDescriptor<dynamic>>[],
            content: listContent(
              items: const <BlenderListItem<String>>[
                BlenderListItem<String>(
                  id: 'lightgroup-key',
                  label: 'Key Light',
                ),
                BlenderListItem<String>(
                  id: 'lightgroup-fill',
                  label: 'Fill Light',
                ),
              ],
            ),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'view-layer-filter',
        title: 'Filter',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('view-layer-filter-environment', 'Environment', true),
          booleanProperty('view-layer-filter-surfaces', 'Surfaces', true),
          booleanProperty('view-layer-filter-curves', 'Curves', true),
          booleanProperty('view-layer-filter-volumes', 'Volumes', true),
          booleanProperty(
            'view-layer-filter-grease-pencil',
            'Grease Pencil',
            true,
          ),
          booleanProperty('view-layer-filter-motion-blur', 'Motion Blur', true),
        ],
      ),
      BlenderPropertyGroup(
        id: 'view-layer-override',
        title: 'Override',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'view-layer-material-override',
            label: 'Material Override',
            value: 'None',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                    BlenderMenuItem<String>(
                      value: 'Override Material',
                      label: 'Override Material',
                    ),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('Material override changed'),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'view-layer-world-override',
            label: 'World Override',
            value: 'None',
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                    BlenderMenuItem<String>(
                      value: 'Night World',
                      label: 'Night World',
                    ),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (_) => _setStatus('World override changed'),
          ),
          enumProperty(
            'view-layer-samples',
            'Samples',
            'Scene',
            overrideSamples,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'view-layer-freestyle',
        title: 'Freestyle',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'freestyle-control-mode',
            'Control Mode',
            'Editor',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Editor', label: 'Editor'),
              BlenderMenuItem<String>(value: 'Python', label: 'Python'),
            ],
          ),
          booleanProperty('freestyle-view-map-cache', 'View Map Cache', true),
          booleanProperty('freestyle-render-pass', 'As Render Pass', false),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'freestyle-edge-detection',
            title: 'Edge Detection',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'freestyle-crease-angle',
                'Crease Angle',
                0.785,
                min: 0,
                max: 3.14,
                decimalDigits: 3,
              ),
              booleanProperty('freestyle-culling', 'Culling', true),
              booleanProperty(
                'freestyle-face-smoothness',
                'Face Smoothness',
                true,
              ),
              booleanProperty(
                'freestyle-material-boundaries',
                'Material Boundaries',
                false,
              ),
              booleanProperty(
                'freestyle-ridges-valleys',
                'Ridges and Valleys',
                false,
              ),
              booleanProperty(
                'freestyle-suggestive-contours',
                'Suggestive Contours',
                false,
              ),
              numberProperty(
                'freestyle-sphere-radius',
                'Sphere Radius',
                0.1,
                min: 0,
                decimalDigits: 3,
              ),
              numberProperty(
                'freestyle-kr-derivative-epsilon',
                'Kr Derivative Epsilon',
                0.01,
                min: 0,
                decimalDigits: 3,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-style-modules',
            title: 'Style Modules',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('freestyle-use-python', 'Use Python', false),
            ],
            content: listContent(
              items: const <BlenderListItem<String>>[
                BlenderListItem<String>(
                  id: 'freestyle-module-cartoon',
                  label: 'cartoon.py',
                  detail: 'Enabled',
                ),
                BlenderListItem<String>(
                  id: 'freestyle-module-sketch',
                  label: 'sketchy.py',
                  detail: 'Disabled',
                ),
              ],
            ),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-lineset',
        title: 'Freestyle Line Set',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty(
            'freestyle-lineset-image-border',
            'Select by Image Border',
            false,
          ),
          enumProperty(
            'freestyle-lineset-style',
            'Line Style',
            'Freestyle LineStyle',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Freestyle LineStyle',
                label: 'Freestyle LineStyle',
              ),
              BlenderMenuItem<String>(value: 'Thin Ink', label: 'Thin Ink'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'freestyle-visibility',
            title: 'Visibility',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('freestyle-visible-ridges', 'Ridges', true),
              booleanProperty('freestyle-visible-valleys', 'Valleys', true),
              booleanProperty(
                'freestyle-visible-silhouette',
                'Silhouette',
                true,
              ),
              enumProperty(
                'freestyle-visibility-type',
                'Type',
                'Visible',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Visible', label: 'Visible'),
                  BlenderMenuItem<String>(value: 'Range', label: 'Range'),
                ],
              ),
              numberProperty(
                'freestyle-qi-start',
                'QI Start',
                0,
                min: 0,
                decimalDigits: 0,
              ),
              numberProperty(
                'freestyle-qi-end',
                'QI End',
                1,
                min: 0,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-edge-type',
            title: 'Edge Type',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('freestyle-edge-silhouette', 'Silhouette', true),
              booleanProperty('freestyle-edge-border', 'Border', true),
              booleanProperty('freestyle-edge-crease', 'Crease', false),
              booleanProperty('freestyle-edge-mark', 'Edge Mark', false),
              booleanProperty('freestyle-edge-contour', 'Contour', true),
              booleanProperty(
                'freestyle-edge-external-contour',
                'External Contour',
                true,
              ),
              booleanProperty(
                'freestyle-edge-material-boundary',
                'Material Boundary',
                false,
              ),
              booleanProperty(
                'freestyle-edge-suggestive-contour',
                'Suggestive Contour',
                false,
              ),
              booleanProperty(
                'freestyle-edge-ridge-valley',
                'Ridge Valley',
                false,
              ),
              enumProperty(
                'freestyle-edge-negation',
                'Negation',
                'AND',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'AND', label: 'AND'),
                  BlenderMenuItem<String>(value: 'OR', label: 'OR'),
                ],
              ),
              enumProperty(
                'freestyle-edge-combination',
                'Combination',
                'AND',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'AND', label: 'AND'),
                  BlenderMenuItem<String>(value: 'OR', label: 'OR'),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-face-marks',
            title: 'Face Marks',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'freestyle-face-mark-negation',
                'Negation',
                'AND',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'AND', label: 'AND'),
                  BlenderMenuItem<String>(value: 'OR', label: 'OR'),
                ],
              ),
              enumProperty(
                'freestyle-face-mark-condition',
                'Condition',
                'Equal',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Equal', label: 'Equal'),
                  BlenderMenuItem<String>(
                    value: 'Not Equal',
                    label: 'Not Equal',
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-line-collection',
            title: 'Collection',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'freestyle-collection-name',
                'Line Set Collection',
                'All Collections',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'All Collections',
                    label: 'All Collections',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Characters',
                    label: 'Characters',
                  ),
                ],
              ),
              booleanProperty(
                'freestyle-collection-negation',
                'Negation',
                false,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-strokes',
        title: 'Freestyle Strokes',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'freestyle-strokes-caps',
            'Caps',
            'Butt',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Butt', label: 'Butt'),
              BlenderMenuItem<String>(value: 'Round', label: 'Round'),
              BlenderMenuItem<String>(value: 'Square', label: 'Square'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'freestyle-strokes-chaining',
            title: 'Chaining',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('freestyle-use-chaining', 'Use Chaining', true),
              enumProperty(
                'freestyle-chaining-method',
                'Method',
                'Plain',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Plain', label: 'Plain'),
                  BlenderMenuItem<String>(value: 'Sketchy', label: 'Sketchy'),
                ],
              ),
              numberProperty(
                'freestyle-chaining-rounds',
                'Rounds',
                3,
                min: 1,
                decimalDigits: 0,
              ),
              booleanProperty(
                'freestyle-chaining-same-object',
                'Same Object',
                true,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-strokes-splitting',
            title: 'Splitting',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'freestyle-min-2d-angle',
                'Min 2D Angle',
                0.1,
                min: 0,
                decimalDigits: 2,
              ),
              numberProperty(
                'freestyle-max-2d-angle',
                'Max 2D Angle',
                1.5,
                min: 0,
                decimalDigits: 2,
              ),
              numberProperty(
                'freestyle-2d-length',
                '2D Length',
                10,
                min: 0,
                decimalDigits: 1,
              ),
              booleanProperty(
                'freestyle-material-boundary-split',
                'Material Boundary',
                false,
              ),
              booleanProperty(
                'freestyle-split-pattern',
                'Split Pattern',
                false,
              ),
              numberProperty(
                'freestyle-split-dash-1',
                'Dash 1',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              numberProperty(
                'freestyle-split-gap-1',
                'Gap 1',
                1,
                min: 0,
                decimalDigits: 1,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-strokes-sorting',
            title: 'Sorting',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('freestyle-use-sorting', 'Use Sorting', false),
              enumProperty(
                'freestyle-sort-key',
                'Sort Key',
                'Distance from Camera',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Distance from Camera',
                    label: 'Distance from Camera',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Projected X',
                    label: 'Projected X',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Projected Y',
                    label: 'Projected Y',
                  ),
                ],
              ),
              enumProperty(
                'freestyle-integration-type',
                'Integration Type',
                'Mean',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Mean', label: 'Mean'),
                  BlenderMenuItem<String>(value: 'Min', label: 'Min'),
                  BlenderMenuItem<String>(value: 'Max', label: 'Max'),
                ],
              ),
              enumProperty(
                'freestyle-sort-order',
                'Sort Order',
                'Ascending',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Ascending',
                    label: 'Ascending',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Descending',
                    label: 'Descending',
                  ),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-strokes-selection',
            title: 'Selection',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'freestyle-min-2d-length',
                'Min 2D Length',
                0,
                min: 0,
                decimalDigits: 1,
              ),
              numberProperty(
                'freestyle-max-2d-length',
                'Max 2D Length',
                100,
                min: 0,
                decimalDigits: 1,
              ),
              numberProperty(
                'freestyle-chain-count',
                'Chain Count',
                1,
                min: 0,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'freestyle-strokes-dashed-line',
            title: 'Dashed Line',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'freestyle-use-dashed-line',
                'Use Dashed Line',
                false,
              ),
              numberProperty(
                'freestyle-dash-1',
                'Dash 1',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              numberProperty(
                'freestyle-dash-2',
                'Dash 2',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              numberProperty(
                'freestyle-dash-3',
                'Dash 3',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              numberProperty(
                'freestyle-gap-1',
                'Gap 1',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              numberProperty(
                'freestyle-gap-2',
                'Gap 2',
                1,
                min: 0,
                decimalDigits: 1,
              ),
              numberProperty(
                'freestyle-gap-3',
                'Gap 3',
                1,
                min: 0,
                decimalDigits: 1,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-color',
        title: 'Freestyle Color',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'freestyle-color-target',
            'Target',
            'Material',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Material', label: 'Material'),
              BlenderMenuItem<String>(value: 'Line Style', label: 'Line Style'),
              BlenderMenuItem<String>(value: 'Random', label: 'Random'),
            ],
          ),
          booleanProperty('freestyle-color-material', 'Material', true),
          booleanProperty('freestyle-color-random', 'Random', false),
          booleanProperty('freestyle-color-ramp', 'Use Color Ramp', false),
          numberProperty(
            'freestyle-color-amplitude',
            'Amplitude',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          numberProperty(
            'freestyle-color-period',
            'Period',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          numberProperty(
            'freestyle-color-seed',
            'Seed',
            0,
            min: 0,
            decimalDigits: 0,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-alpha',
        title: 'Freestyle Alpha',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'freestyle-alpha-base',
            'Base Transparency',
            1,
            min: 0,
            max: 1,
            decimalDigits: 2,
          ),
        ],
        content: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: BlenderButton(
            label: 'Add Modifier',
            leading: const BlenderIcon(BlenderGlyph.plus, size: 14),
            onPressed: () => _setStatus('Add alpha modifier'),
            width: double.infinity,
          ),
        ),
      ),
      BlenderPropertyGroup(
        id: 'freestyle-thickness',
        title: 'Freestyle Thickness',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('freestyle-thickness-value', 'Thickness', 1, min: 0),
          booleanProperty('freestyle-thickness-material', 'Material', false),
          enumProperty(
            'freestyle-thickness-position',
            'Position',
            'Center',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Center', label: 'Center'),
              BlenderMenuItem<String>(value: 'Inside', label: 'Inside'),
              BlenderMenuItem<String>(value: 'Outside', label: 'Outside'),
            ],
          ),
          numberProperty(
            'freestyle-thickness-ratio',
            'Ratio',
            0.5,
            min: 0,
            max: 1,
            decimalDigits: 2,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-geometry',
        title: 'Freestyle Geometry',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'freestyle-geometry-target',
            'Target',
            'Sampling',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Sampling', label: 'Sampling'),
              BlenderMenuItem<String>(
                value: 'Displacement',
                label: 'Displacement',
              ),
              BlenderMenuItem<String>(
                value: 'Guiding Lines',
                label: 'Guiding Lines',
              ),
            ],
          ),
          numberProperty(
            'freestyle-geometry-sampling',
            'Sampling',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          numberProperty(
            'freestyle-geometry-error',
            'Error',
            0.1,
            min: 0,
            decimalDigits: 2,
          ),
          numberProperty(
            'freestyle-geometry-wavelength',
            'Wavelength',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          numberProperty(
            'freestyle-geometry-amplitude',
            'Amplitude',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          numberProperty(
            'freestyle-geometry-frequency',
            'Frequency',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          numberProperty(
            'freestyle-geometry-angle',
            'Angle',
            0,
            min: 0,
            decimalDigits: 2,
          ),
          numberProperty(
            'freestyle-geometry-backbone-length',
            'Backbone Length',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          numberProperty(
            'freestyle-geometry-tip-length',
            'Tip Length',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          enumProperty(
            'freestyle-geometry-shape',
            'Shape',
            'Circle',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Circle', label: 'Circle'),
              BlenderMenuItem<String>(value: 'Square', label: 'Square'),
            ],
          ),
          booleanProperty(
            'freestyle-geometry-pure-random',
            'Pure Random',
            false,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-texture',
        title: 'Freestyle Texture',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('freestyle-texture-use-nodes', 'Use Nodes', false),
          numberProperty(
            'freestyle-texture-spacing',
            'Spacing Along Stroke',
            1,
            min: 0,
            decimalDigits: 2,
          ),
          enumProperty(
            'freestyle-texture-slot',
            'Texture',
            'None',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'None', label: 'None'),
              BlenderMenuItem<String>(
                value: 'Line Texture',
                label: 'Line Texture',
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'freestyle-animation',
        title: 'Freestyle Animation',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'freestyle-animation-action',
            'Action',
            'FreestyleAction',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'FreestyleAction',
                label: 'FreestyleAction',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          enumProperty(
            'freestyle-animation-slot',
            'Slot',
            'Slot 1',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Slot 1', label: 'Slot 1'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'view-layer-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'view-layer-custom-property',
            'example_value',
            1,
            decimalDigits: 2,
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _physicsPropertyGroups {
    const bendingModels = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Angular', label: 'Angular'),
      BlenderMenuItem<String>(value: 'Bending', label: 'Bending'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) =>
            BlenderCheckbox(value: value, onChanged: onChanged),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          min: min,
          max: max,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    Widget physicsButtons() {
      Widget button(String label) {
        return BlenderButton(
          label: label,
          onPressed: () => _setStatus('$label physics'),
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                button('Force Field'),
                button('Collision'),
                button('Cloth'),
                button('Dynamic Paint'),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                button('Soft Body'),
                button('Fluid'),
                button('Rigid Body'),
                button('Rigid Body Constraint'),
              ],
            ),
          ),
        ],
      );
    }

    BlenderPropertyGroup closedPanel(
      String id,
      String title, {
      List<BlenderPropertyDescriptor<dynamic>> properties =
          const <BlenderPropertyDescriptor<dynamic>>[],
      List<BlenderPropertyGroup> children = const <BlenderPropertyGroup>[],
    }) {
      return BlenderPropertyGroup(
        id: id,
        title: title,
        initiallyExpanded: false,
        properties: properties,
        children: children,
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'physics-add',
        title: 'Add Physics',
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: physicsButtons(),
      ),
      BlenderPropertyGroup(
        id: 'physics-cloth',
        title: 'Cloth',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('cloth-quality', 'Quality Steps', 5, min: 1, max: 80),
          numberProperty(
            'cloth-speed',
            'Speed Multiplier',
            1,
            min: .01,
            max: 10,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'cloth-physical-properties',
            title: 'Physical Properties',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('cloth-mass', 'Vertex Mass', .3, min: 0),
              numberProperty('cloth-air-damping', 'Air Viscosity', 1, min: 0),
              enumProperty(
                'cloth-bending-model',
                'Bending Model',
                'Angular',
                bendingModels,
              ),
            ],
            children: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'cloth-stiffness',
                title: 'Stiffness',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty('cloth-tension', 'Tension', 15, min: 0),
                  numberProperty(
                    'cloth-compression',
                    'Compression',
                    15,
                    min: 0,
                  ),
                  numberProperty('cloth-shear', 'Shear', 5, min: 0),
                  numberProperty('cloth-bending', 'Bending', .5, min: 0),
                ],
              ),
              BlenderPropertyGroup(
                id: 'cloth-damping',
                title: 'Damping',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty('cloth-tension-damping', 'Tension', 5, min: 0),
                  numberProperty(
                    'cloth-compression-damping',
                    'Compression',
                    5,
                    min: 0,
                  ),
                  numberProperty('cloth-shear-damping', 'Shear', 5, min: 0),
                  numberProperty(
                    'cloth-bending-damping',
                    'Bending',
                    .5,
                    min: 0,
                  ),
                ],
              ),
              closedPanel(
                'cloth-internal-springs',
                'Internal Springs',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty(
                    'cloth-use-internal-springs',
                    'Enabled',
                    false,
                  ),
                  numberProperty(
                    'cloth-internal-max-length',
                    'Max Spring Creation Length',
                    0.2,
                    min: 0,
                  ),
                  numberProperty(
                    'cloth-internal-tension',
                    'Tension',
                    15,
                    min: 0,
                  ),
                  numberProperty(
                    'cloth-internal-compression',
                    'Compression',
                    15,
                    min: 0,
                  ),
                ],
              ),
              closedPanel(
                'cloth-pressure',
                'Pressure',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty('cloth-use-pressure', 'Enabled', false),
                  numberProperty(
                    'cloth-pressure-force',
                    'Uniform Pressure Force',
                    1,
                    min: 0,
                  ),
                  booleanProperty(
                    'cloth-custom-volume',
                    'Custom Volume',
                    false,
                  ),
                  numberProperty('cloth-pressure-factor', 'Pressure Factor', 1),
                ],
              ),
            ],
          ),
          closedPanel(
            'cloth-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'cloth-cache-start',
                'Simulation Start',
                1,
                min: 0,
              ),
              numberProperty(
                'cloth-cache-end',
                'End',
                250,
                min: 1,
                decimalDigits: 0,
              ),
              booleanProperty('cloth-cache-disk', 'Disk Cache', false),
            ],
          ),
          closedPanel(
            'cloth-shape',
            'Shape',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyDescriptor<String>(
                id: 'cloth-pin-group',
                label: 'Pin Group',
                value: 'Pin',
                editorBuilder: (context, value, onChanged) =>
                    BlenderDropdown<String>(
                      value: value,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(value: 'Pin', label: 'Pin'),
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                      ],
                      onChanged: onChanged,
                    ),
                onChanged: (_) => _setStatus('Pin Group changed'),
              ),
              numberProperty(
                'cloth-pin-stiffness',
                'Stiffness',
                1,
                min: 0,
                max: 1,
              ),
              booleanProperty('cloth-sewing', 'Sewing', false),
              numberProperty(
                'cloth-shrinking',
                'Shrinking Factor',
                0,
                min: -1,
                max: 1,
              ),
              booleanProperty('cloth-dynamic-mesh', 'Dynamic Mesh', false),
            ],
          ),
          BlenderPropertyGroup(
            id: 'cloth-collisions',
            title: 'Collisions',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'cloth-collision-quality',
                'Quality',
                2,
                min: 1,
                max: 20,
              ),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel(
                'cloth-object-collisions',
                'Object Collisions',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty(
                    'cloth-object-collision-enabled',
                    'Enabled',
                    true,
                  ),
                  numberProperty(
                    'cloth-object-distance',
                    'Distance',
                    .015,
                    min: 0,
                  ),
                  numberProperty(
                    'cloth-object-impulse',
                    'Impulse Clamp',
                    0,
                    min: 0,
                  ),
                ],
              ),
              closedPanel(
                'cloth-self-collisions',
                'Self Collisions',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty(
                    'cloth-self-collision-enabled',
                    'Enabled',
                    false,
                  ),
                  numberProperty('cloth-self-friction', 'Friction', 0, min: 0),
                  numberProperty(
                    'cloth-self-distance',
                    'Distance',
                    .02,
                    min: 0,
                  ),
                ],
              ),
            ],
          ),
          closedPanel(
            'cloth-property-weights',
            'Property Weights',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'cloth-weight-structural',
                'Structural Max',
                1,
                min: 0,
              ),
              numberProperty('cloth-weight-shear', 'Shear Max', 1, min: 0),
              numberProperty('cloth-weight-bending', 'Bending Max', 1, min: 0),
              numberProperty('cloth-weight-shrink', 'Shrinking Max', 1, min: 0),
            ],
          ),
          closedPanel(
            'cloth-field-weights',
            'Field Weights',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('cloth-field-gravity', 'Gravity', 1, min: 0),
              numberProperty('cloth-field-wind', 'Wind', 1, min: 0),
              numberProperty('cloth-field-turbulence', 'Turbulence', 1, min: 0),
            ],
          ),
        ],
      ),
      closedPanel(
        'physics-soft-body',
        'Soft Body',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('soft-body-mass', 'Mass', 1, min: 0),
          numberProperty('soft-body-speed', 'Speed', 1, min: 0),
        ],
        children: <BlenderPropertyGroup>[
          closedPanel(
            'soft-body-object',
            'Object',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('soft-body-friction', 'Friction', .5, min: 0),
              numberProperty('soft-body-object-mass', 'Mass', 1, min: 0),
              enumProperty(
                'soft-body-control-point',
                'Control Point',
                'None',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                  BlenderMenuItem<String>(value: 'Mass', label: 'Mass'),
                ],
              ),
            ],
          ),
          closedPanel(
            'soft-body-simulation',
            'Simulation',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('soft-body-simulation-speed', 'Speed', 1, min: 0),
            ],
          ),
          closedPanel(
            'soft-body-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('soft-body-cache-start', 'Simulation Start', 1),
              numberProperty('soft-body-cache-end', 'End', 250),
              booleanProperty('soft-body-cache-disk', 'Disk Cache', false),
            ],
          ),
          BlenderPropertyGroup(
            id: 'soft-body-goal',
            title: 'Goal',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('soft-body-use-goal', 'Enabled', false),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel(
                'soft-body-goal-strengths',
                'Strengths',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty('soft-body-goal-default', 'Default', .5),
                  numberProperty('soft-body-goal-min', 'Min', 0),
                  numberProperty('soft-body-goal-max', 'Max', 1),
                ],
              ),
              closedPanel(
                'soft-body-goal-settings',
                'Settings',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty('soft-body-goal-spring', 'Stiffness', .5),
                  numberProperty('soft-body-goal-friction', 'Damping', .5),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'soft-body-edges',
            title: 'Edges',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('soft-body-use-edges', 'Enabled', true),
              numberProperty('soft-body-pull', 'Pull', .5),
              numberProperty('soft-body-push', 'Push', .5),
              numberProperty('soft-body-edge-damping', 'Damping', .5),
              numberProperty('soft-body-bend', 'Bend', .5),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel(
                'soft-body-aerodynamics',
                'Aerodynamics',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty('soft-body-aero-factor', 'Factor', 1),
                ],
              ),
              closedPanel(
                'soft-body-edge-stiffness',
                'Stiffness',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty('soft-body-spring-length', 'Length', 1),
                  booleanProperty('soft-body-edge-collision', 'Edge', false),
                  booleanProperty('soft-body-face-collision', 'Face', false),
                ],
              ),
            ],
          ),
          closedPanel(
            'soft-body-self-collision',
            'Self Collision',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('soft-body-use-self-collision', 'Enabled', false),
              numberProperty('soft-body-self-friction', 'Friction', .5),
              numberProperty('soft-body-self-distance', 'Ball Size', .1),
            ],
          ),
          BlenderPropertyGroup(
            id: 'soft-body-solver',
            title: 'Solver',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('soft-body-min-step', 'Min Step', .01),
              numberProperty('soft-body-max-step', 'Max Step', .1),
              numberProperty('soft-body-choke', 'Choke', .5),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('soft-body-diagnostics', 'Diagnostics'),
              closedPanel('soft-body-helpers', 'Helpers'),
            ],
          ),
          closedPanel(
            'soft-body-field-weights',
            'Field Weights',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('soft-body-field-gravity', 'Gravity', 1),
              numberProperty('soft-body-field-wind', 'Wind', 1),
              numberProperty('soft-body-field-turbulence', 'Turbulence', 1),
            ],
          ),
        ],
      ),
      closedPanel(
        'physics-fluid',
        'Fluid',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'fluid-type',
            'Fluid Type',
            'Domain',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Domain', label: 'Domain'),
              BlenderMenuItem<String>(value: 'Flow', label: 'Flow'),
              BlenderMenuItem<String>(value: 'Effector', label: 'Effector'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'fluid-settings',
            title: 'Settings',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'fluid-resolution',
                'Resolution Divisions',
                '128',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: '64', label: '64'),
                  BlenderMenuItem<String>(value: '128', label: '128'),
                  BlenderMenuItem<String>(value: '256', label: '256'),
                ],
              ),
              numberProperty('fluid-time-scale', 'Time Scale', 1),
              booleanProperty('fluid-is-resumable', 'Is Resumable', false),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel(
                'fluid-border-collisions',
                'Border Collisions',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty('fluid-border-x', 'X', true),
                  booleanProperty('fluid-border-y', 'Y', true),
                  booleanProperty('fluid-border-z', 'Z', true),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'fluid-gas',
            title: 'Gas',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('fluid-vorticity', 'Vorticity', 2),
              booleanProperty('fluid-dissolve', 'Dissolve', false),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('fluid-dissolve', 'Dissolve'),
            ],
          ),
          closedPanel(
            'fluid-liquid',
            'Liquid',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('fluid-liquid-spray', 'Spray', true),
              booleanProperty('fluid-liquid-flip', 'FLIP', true),
            ],
          ),
          closedPanel(
            'fluid-flow-source',
            'Flow Source',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'fluid-flow-behavior',
                'Flow Behavior',
                'Inflow',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Inflow', label: 'Inflow'),
                  BlenderMenuItem<String>(value: 'Outflow', label: 'Outflow'),
                  BlenderMenuItem<String>(value: 'Geometry', label: 'Geometry'),
                ],
              ),
              numberProperty('fluid-flow-surface', 'Surface', 1),
            ],
          ),
          closedPanel(
            'fluid-adaptive-domain',
            'Adaptive Domain',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('fluid-adaptive-domain-enabled', 'Enabled', true),
              numberProperty('fluid-adaptive-margin', 'Margin', 4),
            ],
          ),
          closedPanel(
            'fluid-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'fluid-cache-type',
                'Type',
                'Modular',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Modular', label: 'Modular'),
                  BlenderMenuItem<String>(value: 'Replay', label: 'Replay'),
                  BlenderMenuItem<String>(value: 'Final', label: 'Final'),
                ],
              ),
              numberProperty('fluid-cache-start', 'Simulation Start', 1),
              numberProperty('fluid-cache-end', 'End', 250),
            ],
          ),
          closedPanel(
            'fluid-viewport-display',
            'Viewport Display',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'fluid-display-thickness',
                'Display Thickness',
                'Both',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Both', label: 'Both'),
                  BlenderMenuItem<String>(value: 'Slice', label: 'Slice'),
                  BlenderMenuItem<String>(value: 'Full', label: 'Full'),
                ],
              ),
              numberProperty('fluid-display-slice', 'Slice', .5),
            ],
          ),
          closedPanel(
            'fluid-render',
            'Render',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('fluid-render-bake', 'Bake', false),
              numberProperty('fluid-render-resolution', 'Resolution', 64),
            ],
          ),
        ],
      ),
      closedPanel(
        'physics-dynamic-paint',
        'Dynamic Paint',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'dynamic-paint-ui-type',
            'Type',
            'Canvas',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Canvas', label: 'Canvas'),
              BlenderMenuItem<String>(value: 'Brush', label: 'Brush'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'dynamic-paint-settings',
            title: 'Settings',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('dynamic-paint-enabled', 'Enabled', true),
              numberProperty('dynamic-paint-frame-start', 'Frame Start', 1),
              numberProperty('dynamic-paint-frame-end', 'End', 250),
            ],
          ),
          BlenderPropertyGroup(
            id: 'dynamic-paint-surface',
            title: 'Surface',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'dynamic-paint-surface-type',
                'Surface Type',
                'Paint',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Paint', label: 'Paint'),
                  BlenderMenuItem<String>(value: 'Displace', label: 'Displace'),
                  BlenderMenuItem<String>(value: 'Wave', label: 'Wave'),
                ],
              ),
              enumProperty(
                'dynamic-paint-surface-format',
                'Format',
                'Vertex',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Vertex', label: 'Vertex'),
                  BlenderMenuItem<String>(value: 'Image', label: 'Image'),
                ],
              ),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel(
                'dynamic-paint-dry',
                'Dry',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty(
                    'dynamic-paint-dry-enabled',
                    'Enabled',
                    false,
                  ),
                  numberProperty('dynamic-paint-dry-speed', 'Speed', .5),
                ],
              ),
              closedPanel(
                'dynamic-paint-dissolve',
                'Dissolve',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty(
                    'dynamic-paint-dissolve-enabled',
                    'Enabled',
                    false,
                  ),
                  numberProperty('dynamic-paint-dissolve-time', 'Time', 1),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'dynamic-paint-output',
            title: 'Output',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'dynamic-paint-output-paintmaps',
                'Paintmaps',
                true,
              ),
              booleanProperty('dynamic-paint-output-wetmaps', 'Wetmaps', false),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('dynamic-paint-paintmaps', 'Paintmaps'),
              closedPanel('dynamic-paint-wetmaps', 'Wetmaps'),
            ],
          ),
          BlenderPropertyGroup(
            id: 'dynamic-paint-effects',
            title: 'Effects',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('dynamic-paint-effects-enabled', 'Enabled', true),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('dynamic-paint-spread', 'Spread'),
              BlenderPropertyGroup(
                id: 'dynamic-paint-drip',
                title: 'Drip',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
                children: <BlenderPropertyGroup>[
                  closedPanel('dynamic-paint-drip-weights', 'Weights'),
                ],
              ),
              closedPanel('dynamic-paint-shrink', 'Shrink'),
            ],
          ),
          closedPanel(
            'dynamic-paint-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'dynamic-paint-cache-start',
                'Simulation Start',
                1,
              ),
              numberProperty('dynamic-paint-cache-end', 'End', 250),
              booleanProperty('dynamic-paint-cache-baked', 'Baked', false),
            ],
          ),
          closedPanel(
            'dynamic-paint-source',
            'Source',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'dynamic-paint-source-type',
                'Paint Source',
                'Mesh Volume',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Mesh Volume',
                    label: 'Mesh Volume',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Proximity',
                    label: 'Proximity',
                  ),
                ],
              ),
              numberProperty('dynamic-paint-source-radius', 'Radius', 1),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('dynamic-paint-falloff-ramp', 'Falloff Ramp'),
            ],
          ),
          BlenderPropertyGroup(
            id: 'dynamic-paint-velocity',
            title: 'Velocity',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'dynamic-paint-velocity-enabled',
                'Enabled',
                true,
              ),
              numberProperty('dynamic-paint-velocity-factor', 'Factor', 1),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('dynamic-paint-velocity-ramp', 'Ramp'),
              closedPanel('dynamic-paint-velocity-smudge', 'Smudge'),
            ],
          ),
          closedPanel(
            'dynamic-paint-waves',
            'Waves',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('dynamic-paint-waves-enabled', 'Enabled', false),
              numberProperty('dynamic-paint-wave-timescale', 'Timescale', 1),
              numberProperty('dynamic-paint-wave-speed', 'Speed', 1),
            ],
          ),
        ],
      ),
      closedPanel(
        'physics-force-field',
        'Force Fields',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'force-field-type',
            'Type',
            'Force',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Force', label: 'Force'),
              BlenderMenuItem<String>(value: 'Wind', label: 'Wind'),
              BlenderMenuItem<String>(value: 'Vortex', label: 'Vortex'),
            ],
          ),
          numberProperty('force-field-strength', 'Strength', 1),
        ],
        children: <BlenderPropertyGroup>[
          closedPanel('force-field-settings', 'Settings'),
          closedPanel('force-field-falloff', 'Falloff'),
          closedPanel('force-field-texture', 'Texture'),
        ],
      ),
      closedPanel(
        'physics-rigid-body',
        'Rigid Body',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'rigid-body-type',
            'Type',
            'Active',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Active', label: 'Active'),
              BlenderMenuItem<String>(value: 'Passive', label: 'Passive'),
            ],
          ),
          numberProperty('rigid-body-mass', 'Mass', 1, min: 0),
        ],
        children: <BlenderPropertyGroup>[
          closedPanel(
            'rigid-body-settings',
            'Settings',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('rigid-body-enabled', 'Dynamic', true),
              booleanProperty('rigid-body-kinematic', 'Animated', false),
            ],
          ),
          BlenderPropertyGroup(
            id: 'rigid-body-collisions',
            title: 'Collisions',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'rigid-body-collision-shape',
                'Shape',
                'Convex Hull',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Box', label: 'Box'),
                  BlenderMenuItem<String>(
                    value: 'Convex Hull',
                    label: 'Convex Hull',
                  ),
                  BlenderMenuItem<String>(value: 'Mesh', label: 'Mesh'),
                ],
              ),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel(
                'rigid-body-surface-response',
                'Surface Response',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty('rigid-body-friction', 'Friction', .5),
                  numberProperty('rigid-body-restitution', 'Bounciness', .5),
                ],
              ),
              closedPanel(
                'rigid-body-sensitivity',
                'Sensitivity',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty('rigid-body-use-margin', 'Use Margin', false),
                  numberProperty('rigid-body-margin', 'Margin', .04),
                ],
              ),
              closedPanel('rigid-body-collections', 'Collections'),
            ],
          ),
          BlenderPropertyGroup(
            id: 'rigid-body-dynamics',
            title: 'Dynamics',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'rigid-body-deactivate',
                'Enable Deactivation',
                false,
              ),
              numberProperty(
                'rigid-body-linear-velocity',
                'Linear Velocity',
                .4,
              ),
              numberProperty(
                'rigid-body-angular-velocity',
                'Angular Velocity',
                .5,
              ),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('rigid-body-deactivation', 'Deactivation'),
            ],
          ),
          closedPanel(
            'rigid-body-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('rigid-body-cache-start', 'Simulation Start', 1),
              numberProperty('rigid-body-cache-end', 'End', 250),
            ],
          ),
        ],
      ),
      closedPanel(
        'physics-rigid-body-constraint',
        'Rigid Body Constraint',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'rigid-body-constraint-type',
            'Type',
            'Fixed',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Fixed', label: 'Fixed'),
              BlenderMenuItem<String>(value: 'Hinge', label: 'Hinge'),
              BlenderMenuItem<String>(value: 'Generic', label: 'Generic'),
              BlenderMenuItem<String>(value: 'Motor', label: 'Motor'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          closedPanel(
            'rigid-body-constraint-settings',
            'Settings',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('rigid-body-constraint-enabled', 'Enabled', true),
              booleanProperty(
                'rigid-body-constraint-disable-collisions',
                'Disable Collisions',
                false,
              ),
              booleanProperty(
                'rigid-body-constraint-breaking',
                'Breakable',
                false,
              ),
              numberProperty(
                'rigid-body-constraint-threshold',
                'Threshold',
                10,
              ),
            ],
          ),
          closedPanel(
            'rigid-body-constraint-objects',
            'Objects',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'rigid-body-constraint-first',
                'First',
                'Cube',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Cube', label: 'Cube'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
              enumProperty(
                'rigid-body-constraint-second',
                'Second',
                'Sphere',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'rigid-body-constraint-limits',
            title: 'Limits',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[],
            children: <BlenderPropertyGroup>[
              closedPanel(
                'rigid-body-constraint-linear',
                'Linear',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty('rigid-body-limit-x', 'X', false),
                  numberProperty('rigid-body-limit-x-lower', 'X Lower', -1),
                  numberProperty('rigid-body-limit-x-upper', 'Upper', 1),
                  booleanProperty('rigid-body-limit-y', 'Y', false),
                  booleanProperty('rigid-body-limit-z', 'Z', false),
                ],
              ),
              closedPanel(
                'rigid-body-constraint-angular',
                'Angular',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty('rigid-body-limit-ang-x', 'X', false),
                  numberProperty('rigid-body-limit-ang-x-lower', 'X Lower', -1),
                  numberProperty('rigid-body-limit-ang-x-upper', 'Upper', 1),
                  booleanProperty('rigid-body-limit-ang-y', 'Y', false),
                  booleanProperty('rigid-body-limit-ang-z', 'Z', false),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'rigid-body-constraint-motor',
            title: 'Motor',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('rigid-body-motor-enabled', 'Enabled', false),
              numberProperty(
                'rigid-body-motor-target-velocity',
                'Target Velocity',
                1,
              ),
              numberProperty('rigid-body-motor-max-impulse', 'Max Impulse', 1),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('rigid-body-motor-angular', 'Angular'),
              closedPanel('rigid-body-motor-linear', 'Linear'),
            ],
          ),
          BlenderPropertyGroup(
            id: 'rigid-body-constraint-springs',
            title: 'Springs',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[],
            children: <BlenderPropertyGroup>[
              closedPanel('rigid-body-springs-angular', 'Angular'),
              closedPanel('rigid-body-springs-linear', 'Linear'),
            ],
          ),
        ],
      ),
      closedPanel(
        'physics-particles',
        'Particle System',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'particle-type',
            'Type',
            'Emitter',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Emitter', label: 'Emitter'),
              BlenderMenuItem<String>(value: 'Hair', label: 'Hair'),
              BlenderMenuItem<String>(value: 'Boids', label: 'Boids'),
            ],
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'particle-emission',
            title: 'Emission',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('particle-number', 'Number', 1000, min: 0),
              numberProperty('particle-frame-start', 'Frame Start', 1),
              numberProperty('particle-frame-end', 'End', 200),
              numberProperty('particle-lifetime', 'Lifetime', 50, min: 0),
              numberProperty(
                'particle-lifetime-random',
                'Randomize',
                0,
                min: 0,
              ),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel(
                'particle-source',
                'Source',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  enumProperty(
                    'particle-source-surface',
                    'Emit From',
                    'Faces',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Faces', label: 'Faces'),
                      BlenderMenuItem<String>(
                        value: 'Vertices',
                        label: 'Vertices',
                      ),
                      BlenderMenuItem<String>(value: 'Volume', label: 'Volume'),
                    ],
                  ),
                  numberProperty('particle-source-jitter', 'Jitter', 0),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-hair-dynamics',
            title: 'Hair Dynamics',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'particle-hair-dynamics-enabled',
                'Enabled',
                false,
              ),
              numberProperty(
                'particle-hair-dynamics-quality',
                'Quality Steps',
                5,
                min: 1,
              ),
              numberProperty(
                'particle-hair-dynamics-pin-stiffness',
                'Pin Goal Strength',
                0.5,
                min: 0,
                max: 1,
              ),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel(
                'particle-hair-dynamics-collisions',
                'Collisions',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty(
                    'particle-hair-collision-quality',
                    'Quality',
                    5,
                    min: 1,
                  ),
                  numberProperty(
                    'particle-hair-collision-distance',
                    'Distance',
                    0.005,
                    min: 0,
                  ),
                  numberProperty(
                    'particle-hair-collision-impulse',
                    'Impulse Clamp',
                    0,
                    min: 0,
                  ),
                ],
              ),
              closedPanel(
                'particle-hair-dynamics-structure',
                'Structure',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty('particle-hair-mass', 'Mass', 1, min: 0),
                  numberProperty(
                    'particle-hair-stiffness',
                    'Stiffness',
                    15,
                    min: 0,
                  ),
                  numberProperty('particle-hair-damping', 'Damping', 5, min: 0),
                ],
              ),
              closedPanel(
                'particle-hair-dynamics-volume',
                'Volume',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty(
                    'particle-hair-air-damping',
                    'Air Drag',
                    1,
                    min: 0,
                  ),
                  numberProperty(
                    'particle-hair-density-target',
                    'Density Target',
                    1,
                    min: 0,
                  ),
                ],
              ),
            ],
          ),
          closedPanel(
            'particle-cache',
            'Cache',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('particle-cache-start', 'Simulation Start', 1),
              numberProperty('particle-cache-end', 'End', 200),
              booleanProperty('particle-cache-baked', 'Baked', false),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-velocity',
            title: 'Velocity',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('particle-normal-velocity', 'Normal', 1),
              numberProperty('particle-object-velocity', 'Object Aligned', 0),
              numberProperty('particle-tangent-velocity', 'Tangent', 0),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-rotation',
            title: 'Rotation',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty('particle-rotation-enabled', 'Enabled', false),
              enumProperty(
                'particle-rotation-orientation',
                'Orientation Axis',
                'Velocity / Hair',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Velocity / Hair',
                    label: 'Velocity / Hair',
                  ),
                  BlenderMenuItem<String>(value: 'Normal', label: 'Normal'),
                ],
              ),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel(
                'particle-angular-velocity',
                'Angular Velocity',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  numberProperty('particle-angular-factor', 'Factor', 1),
                  numberProperty('particle-angular-random', 'Randomize', 0),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-physics',
            title: 'Physics',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'particle-physics-type',
                'Physics Type',
                'Newtonian',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Newtonian',
                    label: 'Newtonian',
                  ),
                  BlenderMenuItem<String>(value: 'Boids', label: 'Boids'),
                  BlenderMenuItem<String>(value: 'Keyed', label: 'Keyed'),
                  BlenderMenuItem<String>(value: 'Fluid', label: 'Fluid'),
                ],
              ),
              numberProperty(
                'particle-physics-size',
                'Particle Size',
                .05,
                min: 0,
              ),
              numberProperty(
                'particle-physics-brownian',
                'Brownian',
                0,
                min: 0,
              ),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('particle-physics-advanced', 'Advanced'),
              BlenderPropertyGroup(
                id: 'particle-physics-springs',
                title: 'Springs',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
                children: <BlenderPropertyGroup>[
                  BlenderPropertyGroup(
                    id: 'particle-physics-viscoelastic-springs',
                    title: 'Viscoelastic Springs',
                    initiallyExpanded: false,
                    properties: <BlenderPropertyDescriptor<dynamic>>[],
                    children: <BlenderPropertyGroup>[
                      closedPanel(
                        'particle-physics-viscoelastic-advanced',
                        'Advanced',
                      ),
                    ],
                  ),
                ],
              ),
              closedPanel('particle-physics-movement', 'Movement'),
              closedPanel('particle-physics-battle', 'Battle'),
              closedPanel('particle-physics-misc', 'Misc'),
              closedPanel('particle-physics-relations', 'Relations'),
              closedPanel(
                'particle-physics-fluid-interaction',
                'Fluid Interaction',
              ),
              closedPanel('particle-physics-deflection', 'Deflection'),
              closedPanel('particle-physics-forces', 'Forces'),
              closedPanel('particle-physics-integration', 'Integration'),
              closedPanel('particle-physics-boid-brain', 'Boid Brain'),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-render',
            title: 'Render',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'particle-render-as',
                'Render As',
                'Halo',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Halo', label: 'Halo'),
                  BlenderMenuItem<String>(value: 'Object', label: 'Object'),
                  BlenderMenuItem<String>(
                    value: 'Collection',
                    label: 'Collection',
                  ),
                  BlenderMenuItem<String>(value: 'Path', label: 'Path'),
                ],
              ),
              numberProperty('particle-render-scale', 'Scale', .05, min: 0),
              numberProperty(
                'particle-render-random-scale',
                'Randomize',
                0,
                min: 0,
              ),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('particle-render-extra', 'Extra'),
              closedPanel('particle-render-path', 'Path'),
              closedPanel('particle-render-timing', 'Timing'),
              closedPanel('particle-render-object', 'Object'),
              BlenderPropertyGroup(
                id: 'particle-render-collection',
                title: 'Collection',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
                children: <BlenderPropertyGroup>[
                  closedPanel('particle-render-use-count', 'Use Count'),
                ],
              ),
            ],
          ),
          closedPanel(
            'particle-viewport-display',
            'Viewport Display',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'particle-viewport-display-as',
                'Display As',
                'Rendered',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Rendered', label: 'Rendered'),
                  BlenderMenuItem<String>(value: 'Point', label: 'Point'),
                  BlenderMenuItem<String>(value: 'Cross', label: 'Cross'),
                ],
              ),
              numberProperty(
                'particle-viewport-percentage',
                'Amount',
                100,
                min: 0,
                max: 100,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-children',
            title: 'Children',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'particle-children-type',
                'Type',
                'Simple',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Simple', label: 'Simple'),
                  BlenderMenuItem<String>(
                    value: 'Interpolated',
                    label: 'Interpolated',
                  ),
                ],
              ),
              numberProperty(
                'particle-children-count',
                'Display Amount',
                10,
                min: 0,
              ),
            ],
            children: <BlenderPropertyGroup>[
              closedPanel('particle-children-parting', 'Parting'),
              BlenderPropertyGroup(
                id: 'particle-children-clumping',
                title: 'Clumping',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[],
                children: <BlenderPropertyGroup>[
                  closedPanel('particle-children-clump-noise', 'Clump Noise'),
                ],
              ),
              closedPanel('particle-children-roughness', 'Roughness'),
              closedPanel('particle-children-kink', 'Kink'),
            ],
          ),
          closedPanel(
            'particle-field-weights',
            'Field Weights',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('particle-field-gravity', 'Gravity', 1),
              numberProperty('particle-field-wind', 'Wind', 1),
              numberProperty('particle-field-turbulence', 'Turbulence', 1),
            ],
          ),
          BlenderPropertyGroup(
            id: 'particle-force-field-settings',
            title: 'Force Field Settings',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'particle-force-field-type',
                'Type',
                'Force',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Force', label: 'Force'),
                  BlenderMenuItem<String>(value: 'Wind', label: 'Wind'),
                  BlenderMenuItem<String>(value: 'Vortex', label: 'Vortex'),
                ],
              ),
              numberProperty('particle-force-field-strength', 'Strength', 1),
            ],
            children: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'particle-force-field-type-1',
                title: 'Type 1',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  enumProperty(
                    'particle-force-field-type-1-kind',
                    'Type 1',
                    'Force',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Force', label: 'Force'),
                      BlenderMenuItem<String>(value: 'Wind', label: 'Wind'),
                      BlenderMenuItem<String>(value: 'Vortex', label: 'Vortex'),
                    ],
                  ),
                  numberProperty(
                    'particle-force-field-type-1-strength',
                    'Strength',
                    1,
                  ),
                ],
                children: <BlenderPropertyGroup>[
                  closedPanel(
                    'particle-force-field-type-1-falloff',
                    'Falloff',
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      numberProperty(
                        'particle-force-field-type-1-distance',
                        'Maximum Distance',
                        10,
                        min: 0,
                      ),
                      numberProperty(
                        'particle-force-field-type-1-power',
                        'Power',
                        1,
                        min: 0,
                      ),
                    ],
                  ),
                ],
              ),
              BlenderPropertyGroup(
                id: 'particle-force-field-type-2',
                title: 'Type 2',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  enumProperty(
                    'particle-force-field-type-2-kind',
                    'Type 2',
                    'Force',
                    const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Force', label: 'Force'),
                      BlenderMenuItem<String>(value: 'Wind', label: 'Wind'),
                      BlenderMenuItem<String>(value: 'Vortex', label: 'Vortex'),
                    ],
                  ),
                  numberProperty(
                    'particle-force-field-type-2-strength',
                    'Strength',
                    1,
                  ),
                ],
                children: <BlenderPropertyGroup>[
                  closedPanel(
                    'particle-force-field-type-2-falloff',
                    'Falloff',
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      numberProperty(
                        'particle-force-field-type-2-distance',
                        'Maximum Distance',
                        10,
                        min: 0,
                      ),
                      numberProperty(
                        'particle-force-field-type-2-power',
                        'Power',
                        1,
                        min: 0,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          closedPanel(
            'particle-vertex-groups',
            'Vertex Groups',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'particle-vertex-density',
                'Density',
                'Density',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Density', label: 'Density'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
              enumProperty(
                'particle-vertex-length',
                'Length',
                'Length',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Length', label: 'Length'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
              enumProperty(
                'particle-vertex-clump',
                'Clump',
                'Clump',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Clump', label: 'Clump'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
              enumProperty(
                'particle-vertex-kink',
                'Kink',
                'Kink',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Kink', label: 'Kink'),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
            ],
          ),
          closedPanel(
            'particle-textures',
            'Textures',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'particle-active-texture',
                'Texture',
                'None',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                  BlenderMenuItem<String>(value: 'Clouds', label: 'Clouds'),
                  BlenderMenuItem<String>(value: 'Noise', label: 'Noise'),
                ],
              ),
            ],
          ),
          closedPanel(
            'particle-hair-shape',
            'Hair Shape',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'particle-hair-shape-strand',
                'Strand Shape',
                0,
                min: -1,
                max: 1,
              ),
              numberProperty(
                'particle-hair-shape-root',
                'Diameter Root',
                1,
                min: 0,
              ),
              numberProperty('particle-hair-shape-tip', 'Tip', 0, min: 0),
              numberProperty(
                'particle-hair-shape-radius-scale',
                'Radius Scale',
                1,
                min: 0,
              ),
              booleanProperty(
                'particle-hair-shape-close-tip',
                'Close Tip',
                false,
              ),
            ],
          ),
          closedPanel(
            'particle-animation',
            'Animation',
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'particle-animation-use-keyed',
                'Use Animation',
                false,
              ),
              numberProperty(
                'particle-animation-time-offset',
                'Time Offset',
                0,
              ),
            ],
          ),
          closedPanel('particle-custom-properties', 'Custom Properties'),
        ],
      ),
      closedPanel(
        'physics-geometry-nodes',
        'Simulation Nodes',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('physics-geometry-nodes-enabled', 'Enabled', true),
          enumProperty(
            'physics-geometry-nodes-node-group',
            'Node Group',
            'Simulation Nodes',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Simulation Nodes',
                label: 'Simulation Nodes',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
    ];
  }

  List<BlenderPropertyGroup> get _particlePropertyGroups {
    final particleSystem = _physicsPropertyGroups.firstWhere(
      (group) => group.title == 'Particle System',
    );
    return particleSystem.children;
  }

  List<BlenderPropertyGroup> get _dataPropertyGroups =>
      switch (_selectedObject) {
        'Camera' => _cameraPropertyGroups,
        'Light' => _lightPropertyGroups,
        'Curve' => _curvePropertyGroups,
        'Text' => _fontCurvePropertyGroups,
        'Curves' => _curvesPropertyGroups,
        'Point Cloud' => _pointCloudPropertyGroups,
        'Speaker' => _speakerPropertyGroups,
        'Volume' => _volumePropertyGroups,
        'Light Probe' => _lightProbePropertyGroups,
        'Grease Pencil' => _greasePencilPropertyGroups,
        'Empty' => _emptyPropertyGroups,
        'Lattice' => _latticePropertyGroups,
        'Metaball' => _metaballPropertyGroups,
        'Armature' => _armaturePropertyGroups,
        'Bone' => _bonePropertyGroups,
        _ => _meshPropertyGroups,
      };

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
    final updated = BlenderPropertyValues.replaceAt(values, index, value);
    setState(() => assign(updated));
  }

  void _toggleObjectVectorLock(
    List<bool> locks,
    int index,
    void Function(List<bool>) assign,
  ) {
    final updated = BlenderPropertyValues.toggleAt(locks, index);
    setState(() => assign(updated));
  }

  List<BlenderPropertyGroup> get _objectPropertyGroups {
    const axes = <String>['X', 'Y', 'Z'];
    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<bool>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderCheckbox(
          value: value,
          enabled: enabled,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items, {
      bool enabled = true,
    }) {
      return BlenderPropertyDescriptor<String>(
        id: id,
        label: label,
        value: value,
        enabled: enabled,
        editorBuilder: (context, value, onChanged) => BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      int decimalDigits = 0,
      double step = 1,
    }) {
      return BlenderPropertyDescriptor<double>(
        id: id,
        label: label,
        value: value,
        editorBuilder: (context, value, onChanged) => BlenderNumberField(
          value: value,
          step: step,
          decimalDigits: decimalDigits,
          onChanged: onChanged,
        ),
        onChanged: (_) => _setStatus('$label changed'),
      );
    }

    const parentTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Object', label: 'Object'),
      BlenderMenuItem<String>(value: 'Bone', label: 'Bone'),
      BlenderMenuItem<String>(value: 'Vertex', label: 'Vertex'),
      BlenderMenuItem<String>(value: 'Collection', label: 'Collection'),
    ];
    const displayTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Textured', label: 'Textured'),
      BlenderMenuItem<String>(value: 'Solid', label: 'Solid'),
      BlenderMenuItem<String>(value: 'Wire', label: 'Wire'),
      BlenderMenuItem<String>(value: 'Bounds', label: 'Bounds'),
    ];
    const instanceTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'None', label: 'None'),
      BlenderMenuItem<String>(value: 'Vertices', label: 'Vertices'),
      BlenderMenuItem<String>(value: 'Faces', label: 'Faces'),
      BlenderMenuItem<String>(value: 'Collection', label: 'Collection'),
    ];
    const axisItems = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'X', label: 'X'),
      BlenderMenuItem<String>(value: 'Y', label: 'Y'),
      BlenderMenuItem<String>(value: 'Z', label: 'Z'),
      BlenderMenuItem<String>(value: '-Z', label: '-Z'),
    ];
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
                  BlenderTransformAxisField(
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
                  BlenderTransformAxisField(
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
                BlenderRotationModeField(
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
                  BlenderTransformAxisField(
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
          BlenderPropertyGroup(
            id: 'object-parent-inverse-transform',
            title: 'Parent Inverse Transform',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-relations',
        title: 'Relations',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'object-parent',
            'Parent',
            'Scene',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
              BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
              BlenderMenuItem<String>(value: 'Empty', label: 'Empty'),
            ],
          ),
          enumProperty(
            'object-parent-type',
            'Parent Type',
            'Object',
            parentTypes,
          ),
          booleanProperty(
            'object-camera-lock-parent',
            'Camera Lock Parent',
            true,
          ),
          enumProperty('object-track-axis', 'Tracking Axis', '-Z', axisItems),
          enumProperty('object-up-axis', 'Up Axis', 'Y', axisItems),
          numberProperty('object-pass-index', 'Pass Index', 0),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-collections',
        title: 'Collections',
        initiallyExpanded: false,
        headerActions: <Widget>[
          BlenderIconButton(
            glyph: BlenderGlyph.plus,
            onPressed: () => _setStatus('Add to Collection'),
            tooltip: 'Add to Collection',
            size: 22,
          ),
        ],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('object-collection', 'Collection', 'Collection', const <
            BlenderMenuItem<String>
          >[
            BlenderMenuItem<String>(value: 'Collection', label: 'Collection'),
            BlenderMenuItem<String>(value: 'Environment', label: 'Environment'),
          ]),
          numberProperty(
            'object-instance-offset',
            'Instance Offset',
            0,
            decimalDigits: 2,
            step: .1,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-instancing',
        title: 'Instancing',
        initiallyExpanded: false,
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'object-instancing-size',
            title: 'Scale by Face Size',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              booleanProperty(
                'object-instance-face-scale',
                'Scale by Face Size',
                false,
              ),
              numberProperty(
                'object-instance-face-factor',
                'Factor',
                1,
                decimalDigits: 3,
                step: .01,
              ),
            ],
          ),
        ],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'object-instance-type',
            'Instance Type',
            'None',
            instanceTypes,
          ),
          booleanProperty(
            'object-instance-vertex-rotation',
            'Align to Vertex Normal',
            false,
          ),
          enumProperty(
            'object-instance-collection',
            'Collection',
            'Collection',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Collection', label: 'Collection'),
              BlenderMenuItem<String>(
                value: 'Environment',
                label: 'Environment',
              ),
            ],
          ),
          booleanProperty(
            'object-show-instancer-viewport',
            'Show Instancer Viewport',
            true,
          ),
          booleanProperty(
            'object-show-instancer-render',
            'Show Instancer Render',
            true,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-motion-paths',
        title: 'Motion Paths',
        initiallyExpanded: false,
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'object-motion-paths-display',
            title: 'Display',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'object-motion-paths-type',
                'Type',
                'Around Frame',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Around Frame',
                    label: 'Around Frame',
                  ),
                  BlenderMenuItem<String>(value: 'Range', label: 'Range'),
                ],
              ),
              booleanProperty(
                'object-motion-paths-frame-numbers',
                'Frame Numbers',
                true,
              ),
              booleanProperty(
                'object-motion-paths-keyframes',
                'Keyframes',
                true,
              ),
            ],
          ),
        ],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('object-motion-paths-before', 'Before', 20),
          numberProperty('object-motion-paths-after', 'After', 20),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-viewport-display',
        title: 'Viewport Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('object-show-name', 'Name', true),
          booleanProperty('object-show-axis', 'Axes', false),
          booleanProperty('object-show-wire', 'Wireframe', false),
          booleanProperty('object-show-all-edges', 'All Edges', false),
          booleanProperty('object-show-texture-space', 'Texture Space', false),
          booleanProperty('object-show-shadows', 'Shadow', true),
          booleanProperty('object-show-in-front', 'In Front', false),
          enumProperty(
            'object-display-type',
            'Display As',
            'Textured',
            displayTypes,
          ),
          booleanProperty('object-show-bounds', 'Bounds', false),
          enumProperty(
            'object-bounds-type',
            'Bounds Type',
            'Box',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Box', label: 'Box'),
              BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
              BlenderMenuItem<String>(value: 'Cylinder', label: 'Cylinder'),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-shading',
        title: 'Shading',
        initiallyExpanded: false,
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'object-light-linking',
            title: 'Light Linking',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'object-light-linking-collection',
                'Receiver Collection',
                'Collection',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Collection',
                    label: 'Collection',
                  ),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'object-shadow-linking',
            title: 'Shadow Linking',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              enumProperty(
                'object-shadow-linking-collection',
                'Blocker Collection',
                'Collection',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Collection',
                    label: 'Collection',
                  ),
                  BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'object-shadow-terminator',
            title: 'Shadow Terminator',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'object-shadow-normal-offset',
                'Normal Offset',
                0,
                decimalDigits: 3,
                step: .01,
              ),
              numberProperty(
                'object-shadow-geometry-offset',
                'Geometry Offset',
                0,
                decimalDigits: 3,
                step: .01,
              ),
            ],
          ),
        ],
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
      ),
      BlenderPropertyGroup(
        id: 'object-visibility',
        title: 'Visibility',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('object-selectable', 'Selectable', true),
          booleanProperty('object-surface-picking', 'Surface Picking', true),
          booleanProperty('object-hide-viewport', 'Viewports', true),
          booleanProperty('object-hide-render', 'Renders', true),
          booleanProperty(
            'object-visible-camera',
            'Ray Visibility Camera',
            true,
          ),
          booleanProperty(
            'object-visible-shadow',
            'Ray Visibility Shadow',
            true,
          ),
          booleanProperty(
            'object-visible-raycast',
            'Ray Visibility Raycast',
            true,
          ),
          booleanProperty(
            'object-hide-probe-volume',
            'Light Probes Volume',
            false,
          ),
          booleanProperty(
            'object-hide-probe-sphere',
            'Light Probes Sphere',
            false,
          ),
          booleanProperty(
            'object-hide-probe-plane',
            'Light Probes Plane',
            false,
          ),
          booleanProperty('object-holdout', 'Holdout', false),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-line-art',
        title: 'Line Art',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'object-line-art-usage',
            'Usage',
            'Include',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Include', label: 'Include'),
              BlenderMenuItem<String>(value: 'Exclude', label: 'Exclude'),
            ],
          ),
          booleanProperty(
            'object-line-art-crease-override',
            'Override Crease',
            false,
          ),
          numberProperty(
            'object-line-art-crease-threshold',
            'Crease Threshold',
            0,
            decimalDigits: 3,
            step: .01,
          ),
          booleanProperty(
            'object-line-art-intersection-override',
            'Override Intersection Priority',
            false,
          ),
          numberProperty(
            'object-line-art-intersection-priority',
            'Intersection Priority',
            0,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('object-animation-use-nla', 'NLA Tracks', true),
          booleanProperty('object-animation-use-action', 'Action', true),
        ],
      ),
      BlenderPropertyGroup(
        id: 'object-custom-properties',
        title: 'Custom Properties',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'object-custom-property-example',
            label: 'example_value',
            value: 1,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              decimalDigits: 2,
              onChanged: onChanged,
            ),
            onChanged: (_) => _setStatus('Custom property changed'),
          ),
        ],
      ),
    ];
  }

  String get _propertiesContextTitle => switch (_propertyTab) {
    0 => 'Select Box',
    1 => 'Render',
    2 => 'Output',
    3 => 'View Layer',
    4 => 'Scene',
    5 => 'World',
    6 => 'Collection',
    7 => _selectedObject,
    8 => 'Modifiers',
    9 => 'Effects',
    10 => 'Particles',
    11 => 'Physics',
    12 => 'Constraints',
    13 => _dataPropertiesTitle,
    14 => 'Bone Properties',
    15 => 'Bone Constraints',
    16 => 'Material',
    17 => 'Texture',
    18 => 'Strip',
    19 => 'Strip Modifiers',
    _ => _dataPropertiesTitle,
  };

  BlenderGlyph get _propertiesContextGlyph => switch (_propertyTab) {
    0 => BlenderGlyph.selectBox,
    1 => BlenderGlyph.render,
    2 => BlenderGlyph.output,
    3 => BlenderGlyph.viewLayer,
    4 => BlenderGlyph.scene,
    5 => BlenderGlyph.world,
    6 => BlenderGlyph.collection,
    7 => BlenderGlyph.object,
    8 => BlenderGlyph.modifier,
    9 => BlenderGlyph.shaderfx,
    10 => BlenderGlyph.physics,
    11 => BlenderGlyph.physics,
    12 => BlenderGlyph.link,
    14 => BlenderGlyph.bone,
    15 => BlenderGlyph.link,
    16 => BlenderGlyph.material,
    17 => BlenderGlyph.texture,
    18 => BlenderGlyph.sequence,
    19 => BlenderGlyph.modifier,
    _ => _dataPropertiesGlyph,
  };

  List<BlenderPropertyGroup> get _visiblePropertyGroups =>
      switch (_propertyTab) {
        0 => _toolPropertyGroups,
        1 => _renderPropertyGroups,
        2 => _propertyGroups,
        3 => _viewLayerPropertyGroups,
        4 => _scenePropertyGroups,
        5 => _worldPropertyGroups,
        6 => _collectionPropertyGroups,
        7 => _objectPropertyGroups,
        8 => const <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'modifier-context',
            title: 'Modifiers',
            properties: <BlenderPropertyDescriptor<dynamic>>[],
          ),
        ],
        9 => const <BlenderPropertyGroup>[],
        10 => _particlePropertyGroups,
        11 => _physicsPropertyGroups,
        12 => const <BlenderPropertyGroup>[],
        13 => _dataPropertyGroups,
        14 => _bonePropertyGroups,
        15 => const <BlenderPropertyGroup>[],
        16 => _materialPropertyGroups,
        17 => _texturePropertyGroups,
        18 => const <BlenderPropertyGroup>[],
        19 => const <BlenderPropertyGroup>[],
        _ => const <BlenderPropertyGroup>[],
      };

  Widget? get _propertyTopContent {
    if (_propertyTab == 1) {
      return BlenderPropertyRow(
        label: 'Render Engine',
        editor: BlenderDropdown<String>(
          key: const ValueKey<String>('active-render-engine-field'),
          value: _renderEngine,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Eevee', label: 'Eevee'),
            BlenderMenuItem<String>(value: 'Cycles', label: 'Cycles'),
            BlenderMenuItem<String>(value: 'Workbench', label: 'Workbench'),
          ],
          onChanged: (value) => setState(() {
            _renderEngine = value;
            _status = 'Render engine: $value';
          }),
        ),
      );
    }
    if (_propertyTab == 4) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-scene-field'),
        value: 'Scene',
        icon: BlenderGlyph.scene,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Scene',
            label: 'Scene',
            icon: BlenderIcon(BlenderGlyph.scene, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Scene.001',
            label: 'Scene.001',
            icon: BlenderIcon(BlenderGlyph.scene, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected scene $value'),
      );
    }
    if (_propertyTab == 10) {
      return SizedBox(
        height: 92,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Expanded(
              child: BlenderBox(
                key: ValueKey<String>('particle-system-list'),
                padding: EdgeInsets.zero,
                child: BlenderListView<String>(
                  items: <BlenderListItem<String>>[
                    BlenderListItem<String>(
                      id: 'particle-system-emitter',
                      label: 'Particle System',
                      icon: BlenderGlyph.physics,
                    ),
                    BlenderListItem<String>(
                      id: 'particle-system-hair',
                      label: 'Hair System',
                      icon: BlenderGlyph.physics,
                    ),
                  ],
                  selectedId: 'particle-system-emitter',
                ),
              ),
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BlenderIconButton(
                  glyph: BlenderGlyph.plus,
                  onPressed: () => _setStatus('Add particle system'),
                  tooltip: 'Add particle system',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  onPressed: () => _setStatus('Remove particle system'),
                  tooltip: 'Remove particle system',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.more,
                  onPressed: () => _setStatus('Particle system menu'),
                  tooltip: 'Particle system menu',
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      );
    }
    if (_propertyTab == 14) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-bone-field'),
        value: 'Upper Arm',
        icon: BlenderGlyph.bone,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Upper Arm',
            label: 'Upper Arm',
            icon: BlenderIcon(BlenderGlyph.bone, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Forearm',
            label: 'Forearm',
            icon: BlenderIcon(BlenderGlyph.bone, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Hand',
            label: 'Hand',
            icon: BlenderIcon(BlenderGlyph.bone, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected bone $value'),
      );
    }
    if (_propertyTab == 17) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-texture-field'),
        value: 'Noise Texture',
        icon: BlenderGlyph.texture,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Noise Texture',
            label: 'Noise Texture',
            icon: BlenderIcon(BlenderGlyph.texture, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Musgrave',
            label: 'Musgrave',
            icon: BlenderIcon(BlenderGlyph.texture, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Image Texture',
            label: 'Image Texture',
            icon: BlenderIcon(BlenderGlyph.image, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected texture $value'),
      );
    }
    if (_propertyTab == 6) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-collection-field'),
        value: 'Collection',
        icon: BlenderGlyph.collection,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Collection',
            label: 'Collection',
            icon: BlenderIcon(BlenderGlyph.collection, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Environment',
            label: 'Environment',
            icon: BlenderIcon(BlenderGlyph.collection, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Characters',
            label: 'Characters',
            icon: BlenderIcon(BlenderGlyph.collection, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected collection $value'),
      );
    }
    if (_propertyTab == 3) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-view-layer-field'),
        value: 'ViewLayer',
        icon: BlenderGlyph.viewLayer,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'ViewLayer',
            label: 'ViewLayer',
            icon: BlenderIcon(BlenderGlyph.viewLayer, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Lighting',
            label: 'Lighting',
            icon: BlenderIcon(BlenderGlyph.viewLayer, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Compositing',
            label: 'Compositing',
            icon: BlenderIcon(BlenderGlyph.viewLayer, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected view layer $value'),
      );
    }
    if (_propertyTab == 16) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 110,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Expanded(
                  child: BlenderListView<String>(
                    items: const <BlenderListItem<String>>[
                      BlenderListItem<String>(
                        id: 'material-slot-0',
                        label: 'Material',
                        value: 'Material',
                        icon: BlenderGlyph.material,
                      ),
                      BlenderListItem<String>(
                        id: 'material-slot-1',
                        label: 'Metallic Accent',
                        value: 'Metallic Accent',
                        icon: BlenderGlyph.material,
                      ),
                    ],
                    selectedId: 'material-slot-0',
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    BlenderIconButton(
                      glyph: BlenderGlyph.plus,
                      onPressed: () => _setStatus('Add material slot'),
                      tooltip: 'Add material slot',
                      size: 22,
                    ),
                    BlenderIconButton(
                      glyph: BlenderGlyph.minus,
                      onPressed: () => _setStatus('Remove material slot'),
                      tooltip: 'Remove material slot',
                      size: 22,
                    ),
                    BlenderIconButton(
                      glyph: BlenderGlyph.stepBack,
                      onPressed: () => _setStatus('Move material slot up'),
                      tooltip: 'Move material slot up',
                      size: 22,
                    ),
                    BlenderIconButton(
                      glyph: BlenderGlyph.stepForward,
                      onPressed: () => _setStatus('Move material slot down'),
                      tooltip: 'Move material slot down',
                      size: 22,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          BlenderDataBlockField<String>(
            key: const ValueKey<String>('active-material-field'),
            value: 'Material',
            icon: BlenderGlyph.material,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Material',
                label: 'Material',
                icon: BlenderIcon(BlenderGlyph.material, size: 14),
              ),
              BlenderMenuItem<String>(
                value: 'Metallic Accent',
                label: 'Metallic Accent',
                icon: BlenderIcon(BlenderGlyph.material, size: 14),
              ),
            ],
            onChanged: (value) => _setStatus('Selected material $value'),
          ),
        ],
      );
    }
    if (_propertyTab == 13) {
      final isCamera = _selectedObject == 'Camera';
      final isLight = _selectedObject == 'Light';
      final isCurve = _selectedObject == 'Curve';
      final isText = _selectedObject == 'Text';
      final isCurves = _selectedObject == 'Curves';
      final isPointCloud = _selectedObject == 'Point Cloud';
      final isSpeaker = _selectedObject == 'Speaker';
      final isVolume = _selectedObject == 'Volume';
      final isLightProbe = _selectedObject == 'Light Probe';
      final isGreasePencil = _selectedObject == 'Grease Pencil';
      final isEmpty = _selectedObject == 'Empty';
      final isLattice = _selectedObject == 'Lattice';
      final isMetaball = _selectedObject == 'Metaball';
      final isArmature = _selectedObject == 'Armature';
      final isBone = _selectedObject == 'Bone';
      final dataName = isCamera
          ? 'Camera'
          : isLight
          ? 'Light'
          : isCurve
          ? 'Curve'
          : isText
          ? 'Text'
          : isCurves
          ? 'Curves'
          : isPointCloud
          ? 'Point Cloud'
          : isSpeaker
          ? 'Speaker'
          : isVolume
          ? 'Volume'
          : isLightProbe
          ? 'Light Probe'
          : isGreasePencil
          ? 'Grease Pencil'
          : isEmpty
          ? 'Empty'
          : isLattice
          ? 'Lattice'
          : isMetaball
          ? 'Metaball'
          : isArmature
          ? 'Armature'
          : isBone
          ? 'Bone'
          : 'Cube';
      final dataIcon = isCamera
          ? BlenderGlyph.camera
          : isLight
          ? BlenderGlyph.light
          : isCurve
          ? BlenderGlyph.curve
          : isText
          ? BlenderGlyph.curve
          : isCurves
          ? BlenderGlyph.curves
          : isPointCloud
          ? BlenderGlyph.pointcloud
          : isSpeaker
          ? BlenderGlyph.speaker
          : isVolume
          ? BlenderGlyph.volume
          : isLightProbe
          ? BlenderGlyph.lightprobe
          : isGreasePencil
          ? BlenderGlyph.greasepencil
          : isEmpty
          ? BlenderGlyph.empty
          : isLattice
          ? BlenderGlyph.lattice
          : isMetaball
          ? BlenderGlyph.metaball
          : isArmature
          ? BlenderGlyph.armature
          : isBone
          ? BlenderGlyph.bone
          : BlenderGlyph.mesh;
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-data-field'),
        value: dataName,
        icon: dataIcon,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Cube',
            label: 'Cube',
            icon: BlenderIcon(BlenderGlyph.mesh, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Suzanne',
            label: 'Suzanne',
            icon: BlenderIcon(BlenderGlyph.mesh, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Camera',
            label: 'Camera',
            icon: BlenderIcon(BlenderGlyph.camera, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Light',
            label: 'Light',
            icon: BlenderIcon(BlenderGlyph.light, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Curve',
            label: 'Curve',
            icon: BlenderIcon(BlenderGlyph.curve, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Text',
            label: 'Text',
            icon: BlenderIcon(BlenderGlyph.curve, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Curves',
            label: 'Curves',
            icon: BlenderIcon(BlenderGlyph.curves, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Point Cloud',
            label: 'Point Cloud',
            icon: BlenderIcon(BlenderGlyph.pointcloud, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Speaker',
            label: 'Speaker',
            icon: BlenderIcon(BlenderGlyph.speaker, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Volume',
            label: 'Volume',
            icon: BlenderIcon(BlenderGlyph.volume, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Light Probe',
            label: 'Light Probe',
            icon: BlenderIcon(BlenderGlyph.lightprobe, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Grease Pencil',
            label: 'Grease Pencil',
            icon: BlenderIcon(BlenderGlyph.greasepencil, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Empty',
            label: 'Empty',
            icon: BlenderIcon(BlenderGlyph.empty, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Empty',
            label: 'Empty',
            icon: BlenderIcon(BlenderGlyph.empty, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Volume',
            label: 'Volume',
            icon: BlenderIcon(BlenderGlyph.volume, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Speaker',
            label: 'Speaker',
            icon: BlenderIcon(BlenderGlyph.speaker, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Lattice',
            label: 'Lattice',
            icon: BlenderIcon(BlenderGlyph.lattice, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Metaball',
            label: 'Metaball',
            icon: BlenderIcon(BlenderGlyph.metaball, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Armature',
            label: 'Armature',
            icon: BlenderIcon(BlenderGlyph.armature, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Bone',
            label: 'Bone',
            icon: BlenderIcon(BlenderGlyph.bone, size: 14),
          ),
        ],
        onChanged: (value) => setState(() {
          _selectedObject = value;
          _status = 'Selected data $value';
        }),
      );
    }
    if (_propertyTab == 5) {
      return BlenderDataBlockField<String>(
        key: const ValueKey<String>('active-world-field'),
        value: 'World',
        icon: BlenderGlyph.world,
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'World',
            label: 'World',
            icon: BlenderIcon(BlenderGlyph.world, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'World.001',
            label: 'World.001',
            icon: BlenderIcon(BlenderGlyph.world, size: 14),
          ),
        ],
        onChanged: (value) => _setStatus('Selected world $value'),
      );
    }
    if (_propertyTab == 7) {
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
            value: 'Curve',
            label: 'Curve',
            icon: BlenderIcon(BlenderGlyph.curve, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Curves',
            label: 'Curves',
            icon: BlenderIcon(BlenderGlyph.curves, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Point Cloud',
            label: 'Point Cloud',
            icon: BlenderIcon(BlenderGlyph.pointcloud, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Lattice',
            label: 'Lattice',
            icon: BlenderIcon(BlenderGlyph.lattice, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Metaball',
            label: 'Metaball',
            icon: BlenderIcon(BlenderGlyph.metaball, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Light',
            label: 'Light',
            icon: BlenderIcon(BlenderGlyph.light, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Light Probe',
            label: 'Light Probe',
            icon: BlenderIcon(BlenderGlyph.lightprobe, size: 14),
          ),
          BlenderMenuItem<String>(
            value: 'Grease Pencil',
            label: 'Grease Pencil',
            icon: BlenderIcon(BlenderGlyph.greasepencil, size: 14),
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

  List<String> get _preferenceCategories => const <String>[
    'Interface',
    'Viewport',
    'Lights',
    'Editing',
    'Animation',
    'Get Extensions',
    'Add-ons',
    'Themes',
    'Input',
    'Navigation',
    'Keymap',
    'System',
    'Save & Load',
    'File Paths',
    'Assets',
    'Developer Tools',
    'Experimental',
  ];

  List<BlenderPreferenceCategoryGroup> get _preferenceCategoryGroups =>
      const <BlenderPreferenceCategoryGroup>[
        BlenderPreferenceCategoryGroup(
          id: 'core',
          categories: <String>[
            'Interface',
            'Viewport',
            'Lights',
            'Editing',
            'Animation',
          ],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'extensions',
          categories: <String>['Get Extensions'],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'addons',
          categories: <String>['Add-ons', 'Themes'],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'assets',
          categories: <String>['Assets'],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'input',
          categories: <String>['Input', 'Navigation', 'Keymap'],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'system',
          categories: <String>['System', 'Save & Load', 'File Paths'],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'developer',
          categories: <String>['Developer Tools', 'Experimental'],
        ),
      ];

  List<BlenderPreferenceSection> get _preferenceSections {
    Widget body(List<Widget> children) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      );
    }

    Widget check(String label, {bool value = true}) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderCheckbox(value: value, onChanged: (_) {}),
      );
    }

    Widget number(String label, double value) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderNumberField(
          value: value,
          decimalDigits: 2,
          onChanged: (_) {},
        ),
      );
    }

    Widget choice(String label, String value, List<String> values) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderDropdown<String>(
          value: value,
          items: <BlenderMenuItem<String>>[
            for (final item in values)
              BlenderMenuItem<String>(value: item, label: item),
          ],
          onChanged: (_) {},
        ),
      );
    }

    Widget buttons(List<String> labels) {
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        children: <Widget>[
          for (final label in labels)
            BlenderButton(label: label, onPressed: () => _setStatus(label)),
        ],
      );
    }

    Widget panel(String title, List<Widget> children, {bool expanded = false}) {
      return BlenderPanel(
        title: title,
        collapsible: true,
        initiallyExpanded: expanded,
        child: body(children),
      );
    }

    BlenderPreferenceSection section(
      String category,
      String id,
      String title,
      List<Widget> children, {
      bool expanded = false,
    }) {
      return BlenderPreferenceSection(
        id: 'preferences-$category-$id',
        category: category,
        title: title,
        initiallyExpanded: expanded,
        child: body(children),
      );
    }

    return <BlenderPreferenceSection>[
      section('Interface', 'display', 'Display', <Widget>[
        number('Resolution Scale', 1),
        number('Line Width', 1),
        check('Splash Screen'),
        check('Developer Extras', value: false),
        panel('Tooltips', <Widget>[
          check('User Tooltips'),
          check('Python Tooltips', value: false),
        ], expanded: true),
        panel('Search', <Widget>[
          check('Sort by Most Recent'),
          check('Show Hidden'),
        ]),
      ], expanded: true),
      section('Interface', 'text', 'Text Rendering', <Widget>[
        check('Anti-Aliasing'),
        choice('Hinting', 'Auto', <String>['Auto', 'None', 'Slight', 'Full']),
        panel('Text Editor Font', <Widget>[
          BlenderPathField(
            controller: _searchController,
            placeholder: 'UI Font',
          ),
          BlenderPathField(
            controller: _searchController,
            placeholder: 'Monospace Font',
          ),
        ]),
      ]),
      section('Interface', 'language', 'Language', <Widget>[
        choice('Language', 'English', <String>['English', 'Turkish', 'German']),
        check('Tooltips'),
        check('Interface'),
        check('Reports'),
        choice('Date Format', 'Automatic', <String>[
          'Automatic',
          'International',
          'US',
        ]),
      ]),
      section('Interface', 'accessibility', 'Accessibility', <Widget>[
        check('Reduce Motion', value: false),
      ]),
      section('Interface', 'editors', 'Editors', <Widget>[
        check('Region Overlap'),
        check('Area Handles'),
        check('Numeric Input Arrows'),
        choice('Color Picker Type', 'Circle', <String>[
          'Circle',
          'Square',
          'Picker',
        ]),
        panel('Temporary Editors', <Widget>[
          choice('Render In', 'Image Editor', <String>[
            'Image Editor',
            'New Window',
          ]),
          choice('File Browser', 'Temporary Window', <String>[
            'Temporary Window',
            'Full Screen',
          ]),
          choice('Preferences', 'Temporary Window', <String>[
            'Temporary Window',
            'Full Screen',
          ]),
        ]),
        panel('Status Bar', <Widget>[
          check('Scene Statistics'),
          check('Scene Duration'),
          check('System Memory'),
          check('Video Memory'),
          check('Extensions Updates'),
          check('Blender Version'),
        ]),
      ], expanded: true),
      section('Interface', 'menus', 'Menus', <Widget>[
        check('Close Menus on Mouse Click'),
        panel('Open on Mouse Over', <Widget>[
          number('Top Level Delay', .3),
          number('Sub Level Delay', .1),
        ]),
        panel('Pie Menus', <Widget>[
          number('Animation Timeout', .3),
          number('Tap Timeout', .2),
          number('Menu Radius', 100),
          number('Threshold', 12),
        ]),
      ]),

      section('Editing', 'objects', 'Objects', <Widget>[
        panel('New Objects', <Widget>[
          choice('Align To', 'World', <String>['World', 'View', '3D Cursor']),
          check('Enter Edit Mode'),
        ], expanded: true),
        panel('Copy on Duplicate', <Widget>[
          check('Linked Data'),
          check('Object Data'),
          check('Materials'),
        ]),
      ], expanded: true),
      section('Editing', 'cursor', '3D Cursor', <Widget>[
        choice('Rotation Mode', 'Euler', <String>['Euler', 'Quaternion']),
        check('Surface Project'),
      ]),
      section('Editing', 'grease-pencil', 'Grease Pencil', <Widget>[
        check('Allow Overlap'),
        number('Smooth Stroke', .5),
      ]),
      section('Editing', 'annotations', 'Annotations', <Widget>[
        check('Default Color'),
        number('Default Thickness', 3),
      ]),
      section('Editing', 'weight-paint', 'Weight Paint', <Widget>[
        check('Use Multi-Paint'),
        check('Show Zero Weights'),
      ]),
      section('Editing', 'text-editor', 'Text Editor', <Widget>[
        check('Highlight Line'),
        check('Show Line Numbers'),
      ]),
      section('Editing', 'node-editor', 'Node Editor', <Widget>[
        check('Auto-Offset'),
        check('Synchronized Node Selection'),
      ]),
      section('Editing', 'sequencer', 'Video Sequencer', <Widget>[
        check('Use Insert Offset'),
        choice('Default Thumbnail Size', 'Medium', <String>[
          'Small',
          'Medium',
          'Large',
        ]),
      ]),
      section('Editing', 'misc', 'Miscellaneous', <Widget>[
        check('Adjust Last Operation'),
        check('Emulate Numpad'),
      ]),

      section('Animation', 'timeline', 'Timeline', <Widget>[
        check('Allow Negative Frames', value: false),
        number('Minimum Grid Spacing', 45),
        choice('Timecode Style', 'Minimal Info', <String>[
          'Minimal Info',
          'SMPTE',
          'Milliseconds',
        ]),
        choice('Zoom to Frame Type', 'Keep Range', <String>[
          'Keep Range',
          'Seconds',
          'Keyframes',
        ]),
      ], expanded: true),
      section('Animation', 'keyframes', 'Keyframes', <Widget>[
        BlenderPropertyRow(
          label: 'Default Key Channels',
          editor: BlenderSegmentedControl<String>(
            value: 'Location',
            expanded: true,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Location', label: 'Location'),
              BlenderMenuItem<String>(value: 'Rotation', label: 'Rotation'),
              BlenderMenuItem<String>(value: 'Scale', label: 'Scale'),
              BlenderMenuItem<String>(
                value: 'Rotation Mode',
                label: 'Rotation Mode',
              ),
              BlenderMenuItem<String>(
                value: 'Custom Properties',
                label: 'Custom Properties',
              ),
            ],
            onChanged: (_) {},
          ),
        ),
        BlenderPropertyRow(
          label: 'Only Insert Needed',
          editor: BlenderSegmentedControl<String>(
            value: 'Auto',
            expanded: true,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Manual', label: 'Manual'),
              BlenderMenuItem<String>(value: 'Auto', label: 'Auto'),
            ],
            onChanged: (_) {},
          ),
        ),
        check('Visual Keying', value: false),
        check('Enable in New Scenes', value: false),
        check('Show Warning'),
        check('Only Insert Available', value: false),
      ], expanded: true),
      section('Animation', 'fcurves', 'F-Curves', <Widget>[
        BlenderPropertyRow(
          label: 'Unselected Opacity',
          editor: BlenderSlider(value: .25, onChanged: (_) {}),
        ),
        choice('Default Smoothing Mode', 'Continuous Acceleration', <String>[
          'Continuous Acceleration',
          'None',
        ]),
        choice('Default Interpolation', 'Bezier', <String>[
          'Bezier',
          'Linear',
          'Constant',
        ]),
        choice('Default Handles', 'Auto Clamped', <String>[
          'Auto Clamped',
          'Automatic',
          'Vector',
        ]),
        check('XYZ to RGB'),
        check('Channel Group Colors', value: false),
      ], expanded: true),
      section('Animation', 'advanced', 'Advanced', <Widget>[
        check('Only Insert Available'),
        number('Slowdown Factor', 0),
      ]),

      section('System', 'sound', 'Sound', <Widget>[
        choice('Audio Device', 'None', <String>['None', 'System Default']),
        choice('Speaker', 'SDL', <String>['SDL', 'OpenAL']),
        number('Sample Rate', 48),
        number('Channels', 2),
      ], expanded: true),
      section('System', 'cycles', 'Cycles Render Devices', <Widget>[
        choice('Device', 'CPU', <String>['CPU', 'GPU Compute']),
        buttons(<String>['Refresh']),
      ]),
      section('System', 'graphics', 'Display Graphics', <Widget>[
        choice('GPU Backend', 'OpenGL', <String>['OpenGL', 'Metal', 'Vulkan']),
        check('Texture Limit'),
      ]),
      section('System', 'os', 'Operating System Settings', <Widget>[
        check('Use Native Windows'),
        check('Open File Browser'),
      ]),
      section('System', 'network', 'Network', <Widget>[
        check('Allow Online Access'),
        number('Connection Timeout', 10),
      ]),
      section('System', 'memory', 'Memory & Limits', <Widget>[
        number('Undo Steps', 32),
        number('Undo Memory Limit', 256),
        number('Console Scrollback Lines', 256),
      ]),
      section('System', 'video-sequencer', 'Video Sequencer', <Widget>[
        check('Prefetch Frames'),
        number('Memory Cache Limit', 1024),
      ]),

      section('Viewport', 'display', 'Display', <Widget>[
        choice('3D Viewport Axes', 'Positive', <String>[
          'Positive',
          'Negative',
          'None',
        ]),
        check('Show Name'),
        check('Show Weight'),
        check('Show Text'),
      ], expanded: true),
      section('Viewport', 'quality', 'Quality', <Widget>[
        number('Viewport Anti-Aliasing', 8),
        check('Use High Quality Normals'),
      ]),
      section('Viewport', 'textures', 'Textures', <Widget>[
        choice('Image Draw Method', '2D Textures', <String>[
          '2D Textures',
          'GLSL',
        ]),
        number('Limit Size', 4096),
      ]),
      section('Viewport', 'subdivision', 'Subdivision', <Widget>[
        number('Viewport Levels', 1),
        number('Render Levels', 2),
      ]),

      section('Themes', 'presets', 'Presets', <Widget>[
        buttons(<String>['Default', 'Save Theme', 'Load Theme']),
      ], expanded: true),
      section('Themes', 'themes', 'Themes', <Widget>[
        choice('Theme', 'Blender Dark', <String>[
          'Blender Dark',
          'Blender Light',
        ]),
      ]),
      section('Themes', 'interface', 'User Interface', <Widget>[
        panel('Panel', <Widget>[number('Header', 1), number('Panel', 1)]),
        panel('State', <Widget>[check('Selected'), check('Active')]),
        panel('Editor & Widgets', <Widget>[
          check('Widget Emboss'),
          check('Rounded Corners'),
          panel('Transparent Checkerboard', <Widget>[
            choice('Primary Color', 'Light', <String>['Light', 'Dark']),
            choice('Secondary Color', 'Dark', <String>['Dark', 'Light']),
            number('Size', 8),
          ]),
        ]),
        panel('Axes & Gizmos', <Widget>[
          check('Show Gizmos'),
          check('Show Navigation Gizmo'),
        ]),
        panel('Icons', <Widget>[
          number('Icon Saturation', 1),
          number('Icon Contrast', 1),
        ]),
        panel('Text Style', <Widget>[
          choice('Font Style', 'Regular', <String>[
            'Regular',
            'Bold',
            'Italic',
          ]),
        ]),
      ]),
      section('Themes', 'color-sets', 'Color Sets', <Widget>[
        panel('Bone Color Sets', <Widget>[check('Use Theme Colors')]),
        panel('Collection Colors', <Widget>[check('Use Collection Colors')]),
        panel('Sequencer Strip Color Tags', <Widget>[check('Use Strip Tags')]),
      ]),

      section('File Paths', 'data', 'Data', <Widget>[
        BlenderPathField(
          controller: _galleryPathController,
          placeholder: 'Fonts',
        ),
        BlenderPathField(
          controller: _galleryPathController,
          placeholder: 'Textures',
        ),
        panel('Render', <Widget>[
          BlenderPathField(
            controller: _galleryPathController,
            placeholder: 'Render Output',
          ),
        ]),
      ], expanded: true),
      section('File Paths', 'scripts', 'Script Directories', <Widget>[
        buttons(<String>['Add', 'Remove']),
        BlenderPathField(
          controller: _galleryPathController,
          placeholder: '/showcase/scripts',
        ),
      ]),
      section('File Paths', 'applications', 'Applications', <Widget>[
        panel('Text Editor', <Widget>[
          BlenderPathField(
            controller: _galleryPathController,
            placeholder: 'Text Editor',
          ),
        ]),
      ]),
      section('File Paths', 'development', 'Development', <Widget>[
        check('Allow Online Access'),
      ]),

      section('Save & Load', 'blend-files', 'Blend Files', <Widget>[
        number('Save Versions', 2),
        check('Auto Save'),
        number('Auto Save Time', 2),
        check('Load UI'),
        check('Filter File Extensions'),
        panel('Auto Run Python Scripts', <Widget>[
          check('Enable Auto Run'),
          buttons(<String>['Add Excluded Path', 'Remove Excluded Path']),
        ]),
      ], expanded: true),
      section('Save & Load', 'file-browser', 'File Browser', <Widget>[
        check('Show Thumbnails'),
        check('Show Recent Locations'),
        check('Show System Bookmarks'),
      ]),

      section('Input', 'keyboard', 'Keyboard', <Widget>[
        check('Emulate Numpad'),
        check('Orbit Around Selection'),
      ], expanded: true),
      section('Input', 'mouse', 'Mouse', <Widget>[
        choice('Select With', 'Left', <String>['Left', 'Right']),
        check('Continuous Grab'),
      ]),
      section('Input', 'tablet', 'Tablet', <Widget>[
        choice('Tablet API', 'Automatic', <String>[
          'Automatic',
          'Wintab',
          'Windows Ink',
        ]),
        number('Pressure Softness', .5),
      ]),
      section('Input', 'touchpad', 'Touchpad', <Widget>[
        check('Natural Trackpad Direction'),
        number('Scroll Sensitivity', 1),
      ]),
      section('Input', 'ndof', 'NDOF', <Widget>[
        check('Pan'),
        check('Orbit'),
        check('Zoom'),
      ]),

      section('Navigation', 'orbit', 'Orbit & Pan', <Widget>[
        choice('Orbit Method', 'Turntable', <String>['Turntable', 'Trackball']),
        check('Orbit Around Selection'),
        check('Auto Perspective'),
      ], expanded: true),
      section('Navigation', 'zoom', 'Zoom', <Widget>[
        choice('Zoom Method', 'Continue', <String>[
          'Continue',
          'Dolly',
          'Scale',
        ]),
        check('Zoom to Mouse Position'),
      ]),
      section('Navigation', 'fly-walk', 'Fly & Walk', <Widget>[
        choice('View Axis', 'Forward', <String>['Forward', 'Up']),
        panel('Walk', <Widget>[number('Speed', 2.5), check('Gravity')]),
        panel('Gravity', <Widget>[
          number('Weight', 1),
          number('Jump Height', 1),
        ]),
      ]),

      section('Keymap', 'presets', 'KeyPresets', <Widget>[
        choice('Preset', 'Blender', <String>['Blender', 'Industry Compatible']),
        buttons(<String>['Restore', 'Save']),
      ], expanded: true),
      section('Keymap', 'keymap', 'Keymap', <Widget>[
        BlenderPathField(
          controller: _keymapSearchController,
          placeholder: 'Search Keymap',
        ),
        check('Emulate Numpad'),
        check('Select Mouse Button'),
      ]),

      section('Get Extensions', 'extensions', 'Extensions', <Widget>[
        check('Allow Online Access'),
        buttons(<String>['Refresh', 'Install']),
      ], expanded: true),
      section('Get Extensions', 'repositories', 'Repositories', <Widget>[
        buttons(<String>['Add Repository', 'Remove Repository']),
        choice('Active Repository', 'Official', <String>['Official', 'User']),
      ]),
      section(
        'Get Extensions',
        'repository-actions',
        'Active Repository',
        <Widget>[
          BlenderPathField(
            controller: _galleryPathController,
            placeholder: 'Repository URL',
          ),
          check('Check for Updates'),
        ],
      ),
      section(
        'Get Extensions',
        'remove-repository',
        'Remove Extension Repository',
        <Widget>[
          buttons(<String>['Remove']),
        ],
      ),

      section('Add-ons', 'filter', 'Add-ons Filter', <Widget>[
        BlenderPathField(
          controller: _searchController,
          placeholder: 'Search Add-ons',
        ),
        choice('Category', 'All', <String>[
          'All',
          '3D View',
          'Add Curve',
          'Render',
        ]),
      ], expanded: true),
      section('Add-ons', 'addons', 'Add-ons', <Widget>[
        check('Enabled Add-on'),
        check('Community'),
        buttons(<String>['Install from Disk']),
      ]),

      section('Assets', 'assets', 'Assets', <Widget>[
        BlenderAssetLibrariesPreferencesPanel(
          selectedId: 'studio',
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
              id: 'studio',
              name: 'Studio Assets',
              path: '/showcase/assets',
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
          onSelected: (library) => _setStatus('Asset library: ${library.name}'),
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
      ], expanded: true),
      section('Lights', 'matcaps', 'MatCaps', <Widget>[
        buttons(<String>['Add MatCap', 'Remove']),
        check('Studio Light Rotation'),
      ], expanded: true),
      section('Lights', 'hdris', 'HDRIs', <Widget>[
        buttons(<String>['Add HDRI', 'Remove']),
      ]),
      section('Lights', 'studio-lights', 'Studio Lights', <Widget>[
        panel('Editor', <Widget>[
          choice('Light Type', 'Area', <String>['Area', 'Sun', 'Spot']),
          number('Rotation', 0),
          number('Energy', 1),
        ]),
      ]),

      section('Developer Tools', 'debug', 'Debug', <Widget>[
        check('Developer UI'),
        check('Debug Value'),
        buttons(<String>['Reload Scripts']),
      ], expanded: true),
      section('Experimental', 'virtual-reality', 'Virtual Reality', <Widget>[
        check('Enable Virtual Reality', value: false),
      ], expanded: true),
      section('Experimental', 'new-features', 'New Features', <Widget>[
        check('Experimental Features'),
        check('Extensions Development'),
      ]),
      section('Experimental', 'prototypes', 'Prototypes', <Widget>[
        check('Prototype Features', value: false),
      ]),
      section('Experimental', 'tweaks', 'Tweaks', <Widget>[
        check('Developer Tweaks', value: false),
      ]),
    ];
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
            if (_workspaceMode == 'Object Mode')
              _buildToolSettingsPanel(
                title: 'Options',
                expanded: _toolOptionsExpanded,
                onToggle: () => setState(
                  () => _toolOptionsExpanded = !_toolOptionsExpanded,
                ),
                child: _buildObjectModeOptionsPanel(),
              )
            else
              ..._buildModeSpecificToolPanels(),
            const SizedBox(height: 4),
            _buildToolSettingsPanel(
              title: 'Workspace',
              expanded: _toolWorkspaceExpanded,
              onToggle: () => setState(
                () => _toolWorkspaceExpanded = !_toolWorkspaceExpanded,
              ),
              child: _buildWorkspaceToolPanel(),
            ),
            const SizedBox(height: 4),
            _buildToolSettingsPanel(
              title: 'Brush Asset',
              expanded: _toolBrushExpanded,
              onToggle: () =>
                  setState(() => _toolBrushExpanded = !_toolBrushExpanded),
              child: _buildBrushAssetPanel(),
            ),
            const SizedBox(height: 4),
            _buildToolSettingsPanel(
              title: 'Brush Settings',
              expanded: _toolBrushSettingsExpanded,
              onToggle: () => setState(
                () => _toolBrushSettingsExpanded = !_toolBrushSettingsExpanded,
              ),
              child: _buildBrushSettingsPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectModeOptionsPanel() {
    final theme = BlenderTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildNestedToolHeader(
          title: 'Transform',
          expanded: _toolTransformExpanded,
          onToggle: () =>
              setState(() => _toolTransformExpanded = !_toolTransformExpanded),
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
                      style: theme.textTheme.body.copyWith(fontSize: 12),
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
                        onChanged: (value) =>
                            setState(() => _toolAffectOrigins = value),
                      ),
                      const SizedBox(height: 3),
                      _buildToolCheckbox(
                        value: _toolAffectLocations,
                        label: 'Locations',
                        onChanged: (value) =>
                            setState(() => _toolAffectLocations = value),
                      ),
                      const SizedBox(height: 3),
                      _buildToolCheckbox(
                        value: _toolAffectParents,
                        label: 'Parents',
                        onChanged: (value) =>
                            setState(() => _toolAffectParents = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  List<Widget> _buildModeSpecificToolPanels() {
    Widget checkbox(String label, {bool value = true}) =>
        _buildToolCheckbox(value: value, label: label, onChanged: (_) {});

    Widget number(String label, double value) => BlenderPropertyRow(
      label: label,
      editor: BlenderNumberField(
        value: value,
        decimalDigits: 2,
        onChanged: (_) {},
      ),
    );

    Widget dropdown(String label, String value, List<String> values) =>
        BlenderPropertyRow(
          label: label,
          editor: BlenderDropdown<String>(
            value: value,
            items: <BlenderMenuItem<String>>[
              for (final item in values)
                BlenderMenuItem<String>(value: item, label: item),
            ],
            onChanged: (_) {},
          ),
        );

    Widget panel(String title, Widget child) {
      final expanded = _toolModePanelExpanded[title] ?? false;
      return _buildToolSettingsPanel(
        title: title,
        expanded: expanded,
        onToggle: () => setState(() {
          _toolModePanelExpanded[title] = !expanded;
        }),
        child: child,
      );
    }

    Widget nested(String title, Widget child) {
      final expanded = _toolModePanelExpanded[title] ?? false;
      return _buildNestedToolPanel(
        title: title,
        expanded: expanded,
        onToggle: () => setState(() {
          _toolModePanelExpanded[title] = !expanded;
        }),
        child: child,
      );
    }

    Widget editOptions() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        nested(
          'Transform',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Correct Face Attributes'),
              checkbox('Keep Connected', value: false),
              checkbox('Auto Merge', value: false),
              number('Threshold', .001),
              BlenderPropertyRow(
                label: 'Mirror',
                editor: BlenderSegmentedControl<String>(
                  value: 'X',
                  items: <BlenderMenuItem<String>>[
                    const BlenderMenuItem<String>(value: 'X', label: 'X'),
                    const BlenderMenuItem<String>(value: 'Y', label: 'Y'),
                    const BlenderMenuItem<String>(value: 'Z', label: 'Z'),
                  ],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        nested('UVs', checkbox('Live Unwrap')),
      ],
    );

    Widget sculptOptions() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        checkbox('Show Low Resolution'),
        checkbox('Delay Updates', value: false),
        checkbox('Deform Only', value: false),
        const SizedBox(height: 4),
        nested(
          'Gravity',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              number('Factor', .5),
              dropdown('Object', 'None', <String>['None', 'Cube']),
            ],
          ),
        ),
      ],
    );

    Widget symmetry() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        checkbox('Mirror X'),
        checkbox('Mirror Y'),
        checkbox('Mirror Z'),
        checkbox('Lock X', value: false),
        checkbox('Lock Y', value: false),
        checkbox('Lock Z', value: false),
        number('Radial', 1),
      ],
    );

    Widget paintOptions() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        number('Seam Bleed', 2),
        number('Dither', 0),
        checkbox('Occlude', value: false),
        checkbox('Backface Culling', value: false),
        nested(
          'External',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              number('Screen Grab Size', 512),
              const BlenderButton(label: 'Quick Edit'),
              const BlenderButton(label: 'Apply'),
            ],
          ),
        ),
      ],
    );

    Widget particleOptions() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        nested(
          'Cut Particles to Shape',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              dropdown('Shape Object', 'None', <String>['None', 'Cube']),
              const BlenderButton(label: 'Cut'),
            ],
          ),
        ),
        const SizedBox(height: 3),
        nested(
          'Viewport Display',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              number('Path Steps', 5),
              checkbox('Particles'),
              checkbox('Fade Time', value: false),
            ],
          ),
        ),
      ],
    );

    Widget paintDataPanel(String title, Widget child) {
      final expanded = _toolModePanelExpanded[title] ?? false;
      return _buildToolSettingsPanel(
        title: title,
        expanded: expanded,
        onToggle: () => setState(() {
          _toolModePanelExpanded[title] = !expanded;
        }),
        child: child,
      );
    }

    Widget nestedPaintDataPanel(String title, Widget child) {
      final expanded = _toolModePanelExpanded[title] ?? false;
      return _buildNestedToolPanel(
        title: title,
        expanded: expanded,
        onToggle: () => setState(() {
          _toolModePanelExpanded[title] = !expanded;
        }),
        child: child,
      );
    }

    Widget listPanel({required String active, required String addLabel}) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderPropertyRow(
              label: 'Active',
              editor: BlenderDropdown<String>(
                value: active,
                items: <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: active, label: active),
                  const BlenderMenuItem<String>(value: 'None', label: 'None'),
                ],
                onChanged: (_) {},
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: <Widget>[
                Expanded(child: BlenderButton(label: addLabel)),
                const SizedBox(width: 4),
                const Expanded(child: BlenderButton(label: 'Remove')),
              ],
            ),
          ],
        );

    Widget texturePaintDataPanels() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        paintDataPanel(
          'Texture Slots',
          listPanel(active: 'Material Slot', addLabel: 'Add Slot'),
        ),
        const SizedBox(height: 4),
        paintDataPanel(
          'Canvas',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              dropdown('Source', 'Material', <String>[
                'Material',
                'Image',
                'Color Attribute',
              ]),
              const BlenderPropertyRow(
                label: 'Image',
                editor: const BlenderDataBlockField<String>(
                  value: 'Paint Canvas',
                  items: <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'Paint Canvas',
                      label: 'Paint Canvas',
                    ),
                    BlenderMenuItem<String>(value: 'None', label: 'None'),
                  ],
                  icon: BlenderGlyph.image,
                ),
              ),
              const BlenderButton(label: 'Save All Images'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        paintDataPanel(
          'Color Attributes',
          listPanel(active: 'Color', addLabel: 'Add Attribute'),
        ),
        const SizedBox(height: 4),
        paintDataPanel(
          'Vertex Groups',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              listPanel(active: 'Group', addLabel: 'Add Group'),
              const SizedBox(height: 4),
              const Row(
                children: <Widget>[
                  Expanded(child: BlenderButton(label: 'Move Up')),
                  const SizedBox(width: 4),
                  Expanded(child: BlenderButton(label: 'Move Down')),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    Widget texturePaintMasking() => paintDataPanel(
      'Masking',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          nestedPaintDataPanel(
            'Stencil Mask',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                checkbox('Use Stencil Layer'),
                const BlenderPropertyRow(
                  label: 'Stencil Image',
                  editor: const BlenderDataBlockField<String>(
                    value: 'Stencil',
                    items: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Stencil',
                        label: 'Stencil',
                      ),
                      BlenderMenuItem<String>(value: 'None', label: 'None'),
                    ],
                    icon: BlenderGlyph.image,
                  ),
                ),
                dropdown('UV Map', 'UVMap', <String>['UVMap', 'None']),
              ],
            ),
          ),
          const SizedBox(height: 3),
          nestedPaintDataPanel(
            'Cavity Mask',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                checkbox('Use Cavity'),
                dropdown('Type', 'World', <String>['World', 'Both']),
                number('Ridge Factor', 1),
                number('Valley Factor', 1),
              ],
            ),
          ),
        ],
      ),
    );

    Widget greasePencilColor({required bool includePalette}) {
      final color = BlenderTheme.of(context).colors.buttonSelected;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          dropdown('Color Mode', 'Vertex Color', <String>[
            'Vertex Color',
            'Material',
          ]),
          BlenderColorPicker(color: color, onChanged: (_) {}),
          number('Mix Factor', .5),
          if (includePalette) ...<Widget>[
            const SizedBox(height: 4),
            nested(
              'Palette',
              Row(
                children: <Widget>[
                  for (final swatch in <Color>[
                    const Color(0xFFCC5544),
                    const Color(0xFFDD9944),
                    const Color(0xFF5D8FCE),
                    const Color(0xFF6EAA68),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: BlenderColorSwatch(color: swatch),
                    ),
                  const Spacer(),
                  const BlenderButton(label: 'New'),
                ],
              ),
            ),
          ],
        ],
      );
    }

    Widget greasePencilFalloff() => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        dropdown('Shape', 'Smooth', <String>[
          'Smooth',
          'Sphere',
          'Root',
          'Sharp',
        ]),
        number('Radius', .5),
        number('Curve', .5),
      ],
    );

    return switch (_workspaceMode) {
      'Edit Mode' => <Widget>[panel('Options', editOptions())],
      'Armature Edit' => <Widget>[
        panel(
          'Options',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[checkbox('X-Axis Mirror')],
          ),
        ),
      ],
      'Pose Mode' => <Widget>[
        panel(
          'Pose Options',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Auto IK', value: false),
              checkbox('X-Axis Mirror', value: false),
              checkbox('Relative Mirror', value: false),
              checkbox('Affect Locations'),
            ],
          ),
        ),
      ],
      'Sculpt Mode' => <Widget>[
        panel(
          'Dyntopo',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Enable Dynamic Topology', value: false),
              number('Detail Size', 12),
              dropdown('Refine Method', 'Subdivide Collapse', <String>[
                'Subdivide Collapse',
                'Subdivide',
                'Collapse',
              ]),
              dropdown('Detailing', 'Relative', <String>[
                'Relative',
                'Constant',
                'Manual',
              ]),
            ],
          ),
        ),
        const SizedBox(height: 4),
        panel(
          'Remesh',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              number('Voxel Size', .1),
              number('Adaptivity', 0),
              checkbox('Preserve Volume'),
              checkbox('Preserve Attributes'),
              const BlenderButton(label: 'Remesh'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        panel('Options', sculptOptions()),
        const SizedBox(height: 4),
        panel('Symmetry', symmetry()),
      ],
      'Curves Sculpt' => <Widget>[
        panel(
          'Symmetry',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Mirror X'),
              checkbox('Mirror Y'),
              checkbox('Mirror Z'),
            ],
          ),
        ),
      ],
      'Weight Paint' => <Widget>[
        panel('Symmetry', symmetry()),
        const SizedBox(height: 4),
        panel(
          'Options',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Auto Normalize'),
              checkbox('Lock-Relative', value: false),
              checkbox('Multi-Paint', value: false),
              checkbox('Group Restrict', value: false),
            ],
          ),
        ),
      ],
      'Vertex Paint' => <Widget>[panel('Symmetry', symmetry())],
      'Grease Pencil Draw' => <Widget>[
        panel('Color', greasePencilColor(includePalette: true)),
      ],
      'Grease Pencil Sculpt' => const <Widget>[],
      'Grease Pencil Weight Paint' => <Widget>[
        panel(
          'Options',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              checkbox('Auto Normalize'),
              checkbox('Lock Relative', value: false),
            ],
          ),
        ),
      ],
      'Grease Pencil Vertex Paint' => <Widget>[
        panel('Color', greasePencilColor(includePalette: true)),
        const SizedBox(height: 4),
        panel('Falloff', greasePencilFalloff()),
      ],
      'Texture Paint' => <Widget>[
        texturePaintDataPanels(),
        const SizedBox(height: 4),
        texturePaintMasking(),
        const SizedBox(height: 4),
        panel('Symmetry', symmetry()),
        const SizedBox(height: 4),
        panel('Options', paintOptions()),
      ],
      'Particle Edit' => <Widget>[
        panel(
          'Particle Tool',
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              dropdown('Editing Type', 'Particles', <String>[
                'Particles',
                'Hair',
                'Cloth',
              ]),
              checkbox('Auto-Velocity', value: false),
              checkbox('Strand Lengths'),
              checkbox('Root Positions'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        panel('Options', particleOptions()),
      ],
      _ => const <Widget>[],
    };
  }

  Widget _buildToolSettingsPanel({
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
    Widget? headerAction,
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
                    if (headerAction != null) headerAction,
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

  Widget _buildWorkspaceAddonRow({
    required String label,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = BlenderTheme.of(context);
    final active = _workspaceFilterByOwner;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.body.copyWith(
                color: active
                    ? theme.colors.foreground
                    : theme.colors.foregroundDisabled,
              ),
            ),
          ),
          BlenderCheckbox(
            value: enabled,
            label: '',
            onChanged: active ? onChanged : null,
          ),
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

  Widget _buildWorkspaceToolPanel() {
    final theme = BlenderTheme.of(context);
    return Container(
      color: theme.colors.panelSubSurface,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderPropertyRow(
            label: 'Pin Scene',
            editor: _buildToolCheckbox(
              value: _workspacePinScene,
              label: '',
              onChanged: (value) => setState(() => _workspacePinScene = value),
            ),
          ),
          BlenderPropertyRow(
            label: 'Mode',
            editor: BlenderDropdown<String>(
              key: const ValueKey<String>('tool-workspace-mode'),
              value: _workspaceMode,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'Object Mode',
                  label: 'Object Mode',
                ),
                BlenderMenuItem<String>(value: 'Edit Mode', label: 'Edit Mode'),
                BlenderMenuItem<String>(
                  value: 'Armature Edit',
                  label: 'Armature Edit',
                ),
                BlenderMenuItem<String>(
                  value: 'Sculpt Mode',
                  label: 'Sculpt Mode',
                ),
                BlenderMenuItem<String>(
                  value: 'Curves Sculpt',
                  label: 'Curves Sculpt',
                ),
                BlenderMenuItem<String>(value: 'Pose Mode', label: 'Pose Mode'),
                BlenderMenuItem<String>(
                  value: 'Weight Paint',
                  label: 'Weight Paint',
                ),
                BlenderMenuItem<String>(
                  value: 'Vertex Paint',
                  label: 'Vertex Paint',
                ),
                BlenderMenuItem<String>(
                  value: 'Texture Paint',
                  label: 'Texture Paint',
                ),
                BlenderMenuItem<String>(
                  value: 'Particle Edit',
                  label: 'Particle Edit',
                ),
                BlenderMenuItem<String>(
                  value: 'Grease Pencil Draw',
                  label: 'Grease Pencil Draw',
                ),
                BlenderMenuItem<String>(
                  value: 'Grease Pencil Sculpt',
                  label: 'Grease Pencil Sculpt',
                ),
                BlenderMenuItem<String>(
                  value: 'Grease Pencil Weight Paint',
                  label: 'Grease Pencil Weight Paint',
                ),
                BlenderMenuItem<String>(
                  value: 'Grease Pencil Vertex Paint',
                  label: 'Grease Pencil Vertex Paint',
                ),
              ],
              onChanged: (value) => setState(() => _workspaceMode = value),
            ),
          ),
          const BlenderPropertyRow(
            label: 'Sequencer Scene',
            editor: const BlenderDataBlockField<String>(
              value: 'Scene',
              icon: BlenderGlyph.scene,
              items: <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'Scene',
                  label: 'Scene',
                  icon: BlenderIcon(BlenderGlyph.scene, size: 14),
                ),
                BlenderMenuItem<String>(value: 'None', label: 'None'),
              ],
            ),
          ),
          BlenderPropertyRow(
            label: 'Scene Time Sync',
            editor: _buildToolCheckbox(
              value: _workspaceSyncTime,
              label: '',
              onChanged: (value) => setState(() => _workspaceSyncTime = value),
            ),
          ),
          const SizedBox(height: 6),
          _buildToolSettingsPanel(
            title: 'Filter Add-ons',
            expanded: _toolWorkspaceFilterExpanded,
            onToggle: () => setState(
              () =>
                  _toolWorkspaceFilterExpanded = !_toolWorkspaceFilterExpanded,
            ),
            headerAction: BlenderCheckbox(
              key: const ValueKey<String>('tool-workspace-filter-by-owner'),
              value: _workspaceFilterByOwner,
              label: '',
              onChanged: (value) =>
                  setState(() => _workspaceFilterByOwner = value),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildWorkspaceAddonRow(
                    label: 'Animation: Built-in',
                    enabled: _workspaceAnimationAddon,
                    onChanged: (value) =>
                        setState(() => _workspaceAnimationAddon = value),
                  ),
                  _buildWorkspaceAddonRow(
                    label: 'Modeling: Mesh Tools',
                    enabled: _workspaceModelingAddon,
                    onChanged: (value) =>
                        setState(() => _workspaceModelingAddon = value),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 7, bottom: 3),
                    child: Row(
                      children: <Widget>[
                        BlenderIcon(
                          BlenderGlyph.warningFilled,
                          size: 14,
                          color: theme.colors.warning,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Unknown add-ons',
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.caption.copyWith(
                              color: theme.colors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colors.panelSubSurface,
                      border: Border.all(color: theme.colors.panelOutline),
                    ),
                    child: _buildWorkspaceAddonRow(
                      label: 'legacy_tools',
                      enabled: _workspaceUnknownAddon,
                      onChanged: (value) =>
                          setState(() => _workspaceUnknownAddon = value),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildNestedToolHeader(
            title: 'Custom Properties',
            expanded: false,
            onToggle: () => _setStatus('Workspace custom properties'),
          ),
        ],
      ),
    );
  }

  Widget _buildBrushAssetPanel() {
    return Container(
      color: BlenderTheme.of(context).colors.panelSubSurface,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: BlenderButton(
                  label: 'Sculpt Clay',
                  leading: const BlenderIcon(
                    BlenderGlyph.assetManager,
                    size: 14,
                  ),
                  variant: BlenderButtonVariant.toolbar,
                  onPressed: () => _setStatus('Brush asset selected'),
                ),
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.menu,
                size: 22,
                tooltip: 'Brush Asset menu',
                onPressed: () => _setStatus('Brush Asset menu opened'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBrushSettingsPanel() {
    if (_workspaceMode.startsWith('Grease Pencil')) {
      return _buildGreasePencilBrushSettingsPanel();
    }

    Widget number(String label, double value) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderNumberField(
          value: value,
          decimalDigits: 2,
          onChanged: (_) {},
        ),
      );
    }

    Widget dropdown(String label, String value, List<String> values) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderDropdown<String>(
          value: value,
          items: <BlenderMenuItem<String>>[
            for (final item in values)
              BlenderMenuItem<String>(value: item, label: item),
          ],
          onChanged: (_) {},
        ),
      );
    }

    Widget nestedPanel(String title, Widget child) {
      final expanded = _toolBrushPanelExpanded[title] ?? false;
      return _buildNestedToolPanel(
        title: title,
        expanded: expanded,
        onToggle: () => setState(() {
          _toolBrushPanelExpanded[title] = !expanded;
        }),
        child: child,
      );
    }

    Widget nestedBrushPanel(String title) {
      Widget child = _buildPaintToolSubpanelContent(title);
      if (title == 'Stroke') {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            child,
            nestedPanel(
              'Stabilize Stroke',
              _buildPaintToolSubpanelContent('Stabilize Stroke'),
            ),
          ],
        );
      } else if (title == 'Falloff') {
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            child,
            nestedPanel(
              'Front-Face Falloff',
              _buildPaintToolSubpanelContent('Front-Face Falloff'),
            ),
            nestedPanel(
              'Normal Falloff',
              _buildPaintToolSubpanelContent('Normal Falloff'),
            ),
          ],
        );
      }
      return nestedPanel(title, child);
    }

    return Container(
      color: BlenderTheme.of(context).colors.panelSubSurface,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          dropdown('Tool', 'Draw', <String>['Draw', 'Smooth', 'Grab']),
          number('Radius', .5),
          number('Strength', .5),
          _buildToolCheckbox(
            value: true,
            label: 'Use Pressure Strength',
            onChanged: (_) {},
          ),
          const SizedBox(height: 6),
          nestedBrushPanel('Advanced'),
          const SizedBox(height: 3),
          nestedBrushPanel('Color Picker'),
          const SizedBox(height: 3),
          nestedBrushPanel('Color Palette'),
          const SizedBox(height: 3),
          nestedBrushPanel('Clone from Paint Slot'),
          const SizedBox(height: 3),
          nestedBrushPanel('Cursor'),
          const SizedBox(height: 3),
          nestedBrushPanel('Texture'),
          const SizedBox(height: 3),
          nestedBrushPanel('Texture Mask'),
          const SizedBox(height: 3),
          nestedBrushPanel('Stroke'),
          const SizedBox(height: 3),
          nestedBrushPanel('Falloff'),
        ],
      ),
    );
  }

  Widget _buildGreasePencilBrushSettingsPanel() {
    Widget checkbox(String label, {bool value = true}) =>
        _buildToolCheckbox(value: value, label: label, onChanged: (_) {});

    Widget number(String label, double value) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderNumberField(
          value: value,
          decimalDigits: 2,
          onChanged: (_) {},
        ),
      );
    }

    Widget dropdown(String label, String value, List<String> values) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderDropdown<String>(
          value: value,
          items: <BlenderMenuItem<String>>[
            for (final item in values)
              BlenderMenuItem<String>(value: item, label: item),
          ],
          onChanged: (_) {},
        ),
      );
    }

    Widget nested(String title, Widget child) {
      final expanded = _toolBrushPanelExpanded[title] ?? false;
      return _buildNestedToolPanel(
        title: title,
        expanded: expanded,
        onToggle: () => setState(() {
          _toolBrushPanelExpanded[title] = !expanded;
        }),
        child: child,
      );
    }

    Widget content(String title) {
      final theme = BlenderTheme.of(context);
      return switch (title) {
        'Advanced' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            dropdown('Locked Size', 'Scene', <String>['Scene', 'View']),
            number('Spacing', 10),
            number('Active Smooth', .5),
            number('Angle', 0),
            number('Hardness', .5),
            number('Aspect', 1),
            const SizedBox(height: 4),
            nested(
              'Gap Closure',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  checkbox('Use Gap Closure'),
                  number('Size', 10),
                  dropdown('Mode', 'Extend', <String>['Extend', 'Radius']),
                ],
              ),
            ),
          ],
        ),
        'Stroke' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            dropdown('Method', 'Draw', <String>['Draw', 'Erase', 'Fill']),
            nested(
              'Post-Processing',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  checkbox('Use Post-Processing'),
                  number('Smooth Factor', .5),
                  number('Smooth Steps', 2),
                  number('Subdivisions', 1),
                  checkbox('Trim'),
                ],
              ),
            ),
            const SizedBox(height: 3),
            nested(
              'Randomize',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  checkbox('Use Randomize'),
                  number('Radius', 0),
                  number('Strength', 0),
                  number('Rotation', 0),
                  number('Jitter', 0),
                ],
              ),
            ),
            const SizedBox(height: 3),
            nested(
              'Stabilize Stroke',
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  checkbox('Smooth Stroke'),
                  number('Radius', .5),
                  number('Factor', .5),
                ],
              ),
            ),
          ],
        ),
        'Falloff' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            dropdown('Shape', 'Smooth', <String>[
              'Smooth',
              'Sphere',
              'Root',
              'Sharp',
            ]),
            number('Radius', .5),
            number('Curve', .5),
          ],
        ),
        'Cursor' => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            checkbox('Show Cursor'),
            BlenderPropertyRow(
              label: 'Color',
              editor: BlenderColorSwatch(color: theme.colors.buttonSelected),
            ),
          ],
        ),
        _ => const SizedBox.shrink(),
      };
    }

    Widget nestedBrushPanel(String title) => nested(title, content(title));

    final children = <Widget>[
      if (_workspaceMode == 'Grease Pencil Draw') ...<Widget>[
        dropdown('Tool', 'Draw', <String>['Draw', 'Fill', 'Erase', 'Tint']),
        const BlenderPropertyRow(
          label: 'Material',
          editor: const BlenderDataBlockField<String>(
            value: 'Material',
            items: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Material', label: 'Material'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
            icon: BlenderGlyph.material,
          ),
        ),
        number('Radius', .5),
        number('Strength', .5),
        _buildToolCheckbox(
          value: true,
          label: 'Use Pressure Strength',
          onChanged: (_) {},
        ),
        const SizedBox(height: 6),
        nestedBrushPanel('Advanced'),
        const SizedBox(height: 3),
        nestedBrushPanel('Stroke'),
        const SizedBox(height: 3),
        nestedBrushPanel('Cursor'),
      ] else if (_workspaceMode == 'Grease Pencil Sculpt') ...<Widget>[
        dropdown('Tool', 'Smooth', <String>['Smooth', 'Grab', 'Randomize']),
        number('Radius', .5),
        number('Strength', .5),
        nestedBrushPanel('Cursor'),
      ] else if (_workspaceMode == 'Grease Pencil Weight Paint') ...<Widget>[
        dropdown('Tool', 'Weight', <String>['Weight', 'Blur', 'Smear']),
        number('Radius', .5),
        number('Strength', .5),
        nestedBrushPanel('Falloff'),
        const SizedBox(height: 3),
        nestedBrushPanel('Cursor'),
      ] else ...<Widget>[
        dropdown('Tool', 'Draw', <String>['Draw', 'Blur', 'Smear']),
        number('Radius', .5),
        number('Strength', .5),
        nestedBrushPanel('Cursor'),
      ],
    ];

    return Container(
      color: BlenderTheme.of(context).colors.panelSubSurface,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildPaintToolSubpanelContent(String title) {
    final theme = BlenderTheme.of(context);
    Widget number(String label, double value) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderNumberField(
          value: value,
          decimalDigits: 2,
          onChanged: (_) {},
        ),
      );
    }

    Widget dropdown(String label, String value, List<String> values) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderDropdown<String>(
          value: value,
          items: <BlenderMenuItem<String>>[
            for (final item in values)
              BlenderMenuItem<String>(value: item, label: item),
          ],
          onChanged: (_) {},
        ),
      );
    }

    Widget button(String label) {
      return BlenderButton(label: label, onPressed: () => _setStatus(label));
    }

    final content = switch (title) {
      'Advanced' => <Widget>[
        number('Hardness', .5),
        number('Spacing', 10),
        _buildToolCheckbox(
          value: true,
          label: 'Use Pressure Size',
          onChanged: (_) {},
        ),
      ],
      'Color Picker' => <Widget>[
        BlenderColorPicker(
          color: BlenderTheme.of(context).colors.buttonSelected,
          onChanged: (_) {},
        ),
        _buildToolCheckbox(
          value: false,
          label: 'Unified Color',
          onChanged: (_) {},
        ),
      ],
      'Color Palette' => <Widget>[
        Row(
          children: <Widget>[
            for (final color in <Color>[
              const Color(0xFFCC5544),
              const Color(0xFFDD9944),
              const Color(0xFF5D8FCE),
              const Color(0xFF6EAA68),
            ])
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: BlenderColorSwatch(color: color),
              ),
            const Spacer(),
            button('New'),
            const SizedBox(width: 4),
            button('Delete'),
          ],
        ),
      ],
      'Clone' || 'Clone from Paint Slot' => <Widget>[
        dropdown('Mode', 'Material', <String>['Material', 'Color']),
        number('Alpha', .5),
        number('Offset', 0),
      ],
      'Texture' => <Widget>[
        dropdown('Texture', 'Voronoi', <String>['Voronoi', 'Noise', 'Image']),
        dropdown('Mapping', '3D', <String>['3D', '2D', 'View Plane']),
        number('Opacity', .5),
      ],
      'Texture Mask' => <Widget>[
        dropdown('Texture', 'Voronoi', <String>['Voronoi', 'Noise', 'Image']),
        number('Angle', 0),
        number('Scale', 1),
      ],
      'Stroke' => <Widget>[
        dropdown('Method', 'Space', <String>['Space', 'Airbrush', 'Dots']),
        number('Spacing', 10),
        number('Jitter', 0),
        number('Input Samples', 4),
      ],
      'Stabilize Stroke' => <Widget>[
        _buildToolCheckbox(
          value: true,
          label: 'Smooth Stroke',
          onChanged: (_) {},
        ),
        number('Radius', 0.5),
        number('Factor', .5),
      ],
      'Falloff' => <Widget>[
        dropdown('Shape', 'Smooth', <String>[
          'Smooth',
          'Sphere',
          'Root',
          'Sharp',
        ]),
        number('Radius', .5),
      ],
      'Cursor' || 'Brush Cursor' => <Widget>[
        _buildToolCheckbox(
          value: true,
          label: 'Show Cursor',
          onChanged: (_) {},
        ),
        _buildToolCheckbox(
          value: false,
          label: 'Show Outline',
          onChanged: (_) {},
        ),
        BlenderPropertyRow(
          label: 'Color',
          editor: BlenderColorSwatch(color: theme.colors.buttonSelected),
        ),
      ],
      'Front-Face Falloff' => <Widget>[
        _buildToolCheckbox(
          value: true,
          label: 'Use Front-Face Falloff',
          onChanged: (_) {},
        ),
        number('Angle', .5),
      ],
      'Normal Falloff' => <Widget>[
        _buildToolCheckbox(
          value: false,
          label: 'Use Normal Falloff',
          onChanged: (_) {},
        ),
        number('Angle', .5),
      ],
      _ => const <Widget>[],
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: content,
      ),
    );
  }

  Widget _buildNestedToolPanel({
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
          _buildNestedToolHeader(
            title: title,
            expanded: expanded,
            onToggle: onToggle,
          ),
          if (expanded) child,
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

  /// Lets showcase part files mutate this state's app-specific sample model
  /// without bypassing the State lifecycle contract.
  void _update(VoidCallback mutation) => setState(mutation);

  void _showPreferencesWindow() {
    // The menu route closes in the same frame as its action callback. Push
    // the temporary window afterward so that route cleanup cannot dismiss it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final navigatorContext = _navigatorKey.currentContext;
      if (navigatorContext == null) return;
      showBlenderPreferencesWindow(
        navigatorContext,
        configuration: _preferencesConfiguration,
      );
    });
  }

  BlenderPreferencesConfiguration get _preferencesConfiguration =>
      BlenderPreferencesConfiguration(
        categories: _preferenceCategories,
        categoryGroups: _preferenceCategoryGroups,
        sections: _preferenceSections,
        initialCategory: 'Animation',
        onCategoryChanged: (category) {
          setState(() => _preferenceCategory = category);
        },
      );

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
    return BlenderWorkspaceShell<Object?>(
      title: 'Blender UI — workspace showcase',
      navigatorKey: _navigatorKey,
      controller: _application,
      topBar: _buildMainToolbar(),
      areaBuilder: _buildDockedArea,
      preferences: _preferencesConfiguration,
      workspaceContent: _workspaceIndex == 10
          ? DemoWorkbench(onStatus: _setStatus)
          : null,
      cloneArea: (value) {
        _setStatus('Area split: $value');
        return value;
      },
      statusBar: ShowcaseStatusBar(status: _status, onStatus: _setStatus),
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
    Widget menu(
      String label,
      List<BlenderMenuItem<String>> items, {
      ValueChanged<String>? onSelected,
    }) {
      return BlenderMenuButton<String>(
        label: label,
        items: items,
        variant: BlenderButtonVariant.topBar,
        onSelected: onSelected ?? _setStatus,
      );
    }

    final theme = BlenderTheme.of(context);
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: theme.colors.topBar,
        border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: BlenderToolbar(
              height: 30,
              scrollable: true,
              background: theme.colors.topBar,
              children: <Widget>[
                BlenderPopover(
                  child: const BlenderIconButton(
                    glyph: BlenderGlyph.cube,
                    tooltip: 'Blender',
                    size: 30,
                  ),
                  popover: (context, close) => BlenderMenu<String>(
                    items: const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Splash Screen',
                        label: 'Splash Screen',
                      ),
                      BlenderMenuItem<String>(
                        value: 'About Blender',
                        label: 'About Blender',
                      ),
                      BlenderMenuItem<String>(
                        value: 'separator',
                        label: '',
                        separator: true,
                      ),
                      BlenderMenuItem<String>(
                        value: 'Install Application Template...',
                        label: 'Install Application Template...',
                      ),
                      BlenderMenuItem<String>(
                        value: 'System',
                        label: 'System',
                        submenu: <BlenderMenuItem<String>>[
                          BlenderMenuItem<String>(
                            value: 'Reload Scripts',
                            label: 'Reload Scripts',
                          ),
                          BlenderMenuItem<String>(
                            value: 'Memory Statistics',
                            label: 'Memory Statistics',
                          ),
                          BlenderMenuItem<String>(
                            value: 'Debug Menu',
                            label: 'Debug Menu',
                          ),
                          BlenderMenuItem<String>(
                            value: 'Redraw Timer',
                            label: 'Redraw Timer',
                            submenu: <BlenderMenuItem<String>>[
                              BlenderMenuItem<String>(
                                value: 'Draw',
                                label: 'Draw',
                              ),
                              BlenderMenuItem<String>(
                                value: 'Swap',
                                label: 'Swap',
                              ),
                              BlenderMenuItem<String>(
                                value: 'Frame',
                                label: 'Frame',
                              ),
                              BlenderMenuItem<String>(
                                value: 'Animation',
                                label: 'Animation',
                              ),
                            ],
                          ),
                          BlenderMenuItem<String>(
                            value: 'Clean Up Spacedata',
                            label: 'Clean Up Spacedata',
                          ),
                          BlenderMenuItem<String>(
                            value: 'Clean Up Operator Presets',
                            label: 'Clean Up Operator Presets',
                          ),
                        ],
                      ),
                    ],
                    onSelected: (item) {
                      _setStatus(item.value);
                      close();
                    },
                  ),
                ),
                menu('File', const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'New',
                    label: 'New',
                    shortcut: '⌘ N',
                    icon: BlenderIcon(BlenderGlyph.file, size: 18),
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'General',
                        label: 'General',
                      ),
                      BlenderMenuItem<String>(
                        value: '2D Animation',
                        label: '2D Animation',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Sculpting',
                        label: 'Sculpting',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Storyboarding',
                        label: 'Storyboarding',
                      ),
                      BlenderMenuItem<String>(value: 'VFX', label: 'VFX'),
                      BlenderMenuItem<String>(
                        value: 'Video Editing',
                        label: 'Video Editing',
                      ),
                    ],
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
                      BlenderMenuItem<String>(
                        value: 'Recover Auto Save',
                        label: 'Auto Save...',
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
                      BlenderMenuItem<String>(
                        value: 'Make Paths Relative',
                        label: 'Make Paths Relative',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Make Paths Absolute',
                        label: 'Make Paths Absolute',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Report Missing Files',
                        label: 'Report Missing Files',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Find Missing Files...',
                        label: 'Find Missing Files...',
                      ),
                    ],
                  ),
                  BlenderMenuItem<String>(
                    value: 'Clean Up',
                    label: 'Clean Up',
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(
                        value: 'Unused Data',
                        label: 'Purge Unused Data...',
                      ),
                      BlenderMenuItem<String>(
                        value: 'Manage Unused Data',
                        label: 'Manage Unused Data...',
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
                menu(
                  'Edit',
                  <BlenderMenuItem<String>>[
                    const BlenderMenuItem<String>(
                      value: 'Undo',
                      label: 'Undo',
                      shortcut: '⌘ Z',
                      icon: const BlenderIcon(BlenderGlyph.undo, size: 18),
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Redo',
                      label: 'Redo',
                      shortcut: '⇧ ⌘ Z',
                      enabled: false,
                      icon: const BlenderIcon(BlenderGlyph.redo, size: 18),
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Undo History',
                      label: 'Undo History',
                      submenu: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(
                          value: 'Undo History Initial State',
                          label: 'Initial State',
                        ),
                      ],
                    ),
                    const BlenderMenuItem<String>(
                      value: 'separator-edit-history',
                      label: '',
                      separator: true,
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Adjust Last Operation...',
                      label: 'Adjust Last Operation...',
                      shortcut: 'F9',
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Repeat Last',
                      label: 'Repeat Last',
                      shortcut: '⇧ R',
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Repeat History...',
                      label: 'Repeat History...',
                    ),
                    const BlenderMenuItem<String>(
                      value: 'separator-edit-search',
                      label: '',
                      separator: true,
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Menu Search...',
                      label: 'Menu Search...',
                      shortcut: 'F3',
                      icon: const BlenderIcon(BlenderGlyph.search, size: 18),
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Operator Search...',
                      label: 'Operator Search...',
                      shortcut: 'F3',
                      icon: const BlenderIcon(BlenderGlyph.search, size: 18),
                    ),
                    const BlenderMenuItem<String>(
                      value: 'separator-edit-rename',
                      label: '',
                      separator: true,
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Rename Active Item...',
                      label: 'Rename Active Item...',
                      shortcut: 'F2',
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Batch Rename...',
                      label: 'Batch Rename...',
                      shortcut: '⌘ F2',
                    ),
                    const BlenderMenuItem<String>(
                      value: 'separator-edit-preferences',
                      label: '',
                      separator: true,
                    ),
                    BlenderMenuItem<String>(
                      value: 'Lock Object Modes',
                      label: 'Lock Object Modes',
                      checked: _lockObjectModes,
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Preferences...',
                      label: 'Preferences...',
                      shortcut: '⌘ ,',
                      icon: const BlenderIcon(
                        BlenderGlyph.preferences,
                        size: 18,
                      ),
                    ),
                    const BlenderMenuItem<String>(
                      value: 'Project Setup...',
                      label: 'Project Setup...',
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'Lock Object Modes':
                        setState(() => _lockObjectModes = !_lockObjectModes);
                        _setStatus(
                          _lockObjectModes
                              ? 'Lock Object Modes enabled'
                              : 'Lock Object Modes disabled',
                        );
                      case 'Preferences...':
                        _showPreferencesWindow();
                      default:
                        _setStatus(value);
                    }
                  },
                ),
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
                  BlenderMenuItem<String>(
                    value: 'separator-render-view',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Render Audio...',
                    label: 'Render Audio...',
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-render-result',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'View Render',
                    label: 'View Render',
                  ),
                  BlenderMenuItem<String>(
                    value: 'View Animation',
                    label: 'View Animation',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Lock Interface',
                    label: 'Lock Interface',
                  ),
                ]),
                menu('Window', const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'New Window',
                    label: 'New Window',
                  ),
                  BlenderMenuItem<String>(
                    value: 'New Main Window',
                    label: 'New Main Window',
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-window-fullscreen',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Toggle Fullscreen',
                    label: 'Toggle Fullscreen',
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-window-workspace',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Next Workspace',
                    label: 'Next Workspace',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Previous Workspace',
                    label: 'Previous Workspace',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Show Status Bar',
                    label: 'Show Status Bar',
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-window-screenshot',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Save Screenshot...',
                    label: 'Save Screenshot...',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Save Screenshot (Editor)...',
                    label: 'Save Screenshot (Editor)...',
                  ),
                ]),
                menu('Help', const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Manual', label: 'Manual'),
                  BlenderMenuItem<String>(value: 'Support', label: 'Support'),
                  BlenderMenuItem<String>(
                    value: 'User Communities',
                    label: 'User Communities',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Get Involved',
                    label: 'Get Involved',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Release Notes',
                    label: 'Release Notes',
                  ),
                  BlenderMenuItem<String>(
                    value: 'separator-help-report',
                    label: '',
                    separator: true,
                  ),
                  BlenderMenuItem<String>(
                    value: 'Report a Bug',
                    label: 'Report a Bug',
                  ),
                  BlenderMenuItem<String>(
                    value: 'System Information',
                    label: 'System Information',
                  ),
                ]),
                const SizedBox(width: 8),
                SizedBox(
                  width: 1,
                  height: 24,
                  child: ColoredBox(color: theme.colors.editorOutline),
                ),
                const SizedBox(width: 6),
                // The toolbar owns the top-bar viewport. Keep workspace tabs
                // in its single scrolling layout so they never pan separately
                // from the menus or Add Workspace control.
                BlenderTabBar(
                  scrollable: false,
                  variant: BlenderButtonVariant.tab,
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
                    'Components',
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
                              'Storyboarding',
                              'VFX',
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
      BlenderEditorType.timeline || BlenderEditorType.dopeSheet =>
        _buildAnimationEditorHeader(_mainEditorType),
      BlenderEditorType.nlaEditor => _buildNlaEditorHeader(),
      BlenderEditorType.graphEditor ||
      BlenderEditorType.drivers => _buildGraphEditorHeader(_mainEditorType),
      BlenderEditorType.sequencer || BlenderEditorType.videoEditing =>
        _buildSequencerEditorHeader(_mainEditorType),
      BlenderEditorType.shaderEditor ||
      BlenderEditorType.geometryNodeEditor ||
      BlenderEditorType.compositor ||
      BlenderEditorType.textureNodeEditor => _buildNodeEditorHeader(
        _mainEditorType,
      ),
      BlenderEditorType.clipEditor => _buildClipEditorHeader(),
      BlenderEditorType.spreadsheet => _buildSpreadsheetEditorHeader(),
      _ => _buildUtilityEditorHeader(_mainEditorType),
    };
  }

  Widget _buildView3dHeader() {
    return BlenderAreaHeader(
      height: 30,
      editorType: _mainEditorType,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      actionsScrollable: true,
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
        SizedBox(
          width: 88,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('viewport-transform-orientation'),
            value: _transformOrientation,
            compact: true,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Global', label: 'Global'),
              BlenderMenuItem<String>(value: 'Local', label: 'Local'),
              BlenderMenuItem<String>(value: 'Normal', label: 'Normal'),
              BlenderMenuItem<String>(value: 'View', label: 'View'),
              BlenderMenuItem<String>(value: 'Cursor', label: 'Cursor'),
            ],
            onChanged: (value) => setState(() => _transformOrientation = value),
          ),
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-transform-pivot'),
          glyph: BlenderGlyph.transform,
          selected: _transformPivot == 'Median Point',
          onPressed: () => setState(
            () => _transformPivot = _transformPivot == 'Median Point'
                ? 'Individual Origins'
                : 'Median Point',
          ),
          tooltip: 'Pivot Point: $_transformPivot',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-snap'),
          glyph: BlenderGlyph.snap,
          selected: _snapEnabled,
          onPressed: () => setState(() => _snapEnabled = !_snapEnabled),
          tooltip: 'Snap',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-proportional-editing'),
          glyph: BlenderGlyph.transform,
          selected: _proportionalEditing,
          onPressed: () =>
              setState(() => _proportionalEditing = !_proportionalEditing),
          tooltip: 'Proportional Editing',
        ),
        const BlenderIconButton(
          key: const ValueKey<String>('viewport-object-visibility'),
          glyph: BlenderGlyph.eye,
          tooltip: 'Object visibility',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('viewport-gizmo'),
            glyph: BlenderGlyph.gizmo,
            selected: _showGizmos,
            onPressed: () => setState(() => _showGizmos = !_showGizmos),
            tooltip: 'Toggle gizmos',
          ),
          popover: (context, close) =>
              _buildViewportPopoverPanel('Gizmo Display', <Widget>[
                BlenderCheckbox(
                  value: _showGizmos,
                  label: 'Show Gizmos',
                  onChanged: (value) => setState(() => _showGizmos = value),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Navigate Gizmo',
                  onChanged: (value) => _setStatus('Navigate gizmo toggled'),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Tool Gizmos',
                  onChanged: (value) => _setStatus('Tool gizmos toggled'),
                ),
              ]),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('viewport-overlays'),
            glyph: BlenderGlyph.overlay,
            selected: _showOverlays,
            onPressed: () => setState(() => _showOverlays = !_showOverlays),
            tooltip: 'Toggle overlays',
          ),
          popover: (context, close) =>
              _buildViewportPopoverPanel('Overlays', <Widget>[
                BlenderCheckbox(
                  value: _showOverlays,
                  label: 'Show Overlays',
                  onChanged: (value) => setState(() => _showOverlays = value),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Floor',
                  onChanged: (value) => _setStatus('Floor overlay toggled'),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Relationship Lines',
                  onChanged: (value) =>
                      _setStatus('Relationship lines toggled'),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Text Info',
                  onChanged: (value) => _setStatus('Text info toggled'),
                ),
              ]),
        ),
        BlenderIconButton(
          key: const ValueKey<String>('viewport-xray'),
          glyph: BlenderGlyph.xray,
          selected: _showXray,
          onPressed: () => setState(() => _showXray = !_showXray),
          tooltip: 'X-Ray',
        ),
        for (final shading in const <String>[
          'Wireframe',
          'Solid',
          'Material Preview',
          'Rendered',
        ])
          BlenderIconButton(
            key: ValueKey<String>(
              'viewport-shading-${shading.toLowerCase().replaceAll(' ', '-')}',
            ),
            glyph: switch (shading) {
              'Wireframe' => BlenderGlyph.wireframe,
              'Solid' => BlenderGlyph.solid,
              'Material Preview' => BlenderGlyph.materialPreview,
              _ => BlenderGlyph.rendered,
            },
            selected: _viewportShading == shading,
            onPressed: () => setState(() {
              _viewportShading = shading;
              _wireframe = shading == 'Wireframe';
            }),
            tooltip: shading,
          ),
        BlenderPopover(
          child: const BlenderIconButton(
            key: const ValueKey<String>('viewport-shading-options'),
            glyph: BlenderGlyph.settings,
            tooltip: 'Viewport shading options',
          ),
          popover: (context, close) => _buildViewportPopoverPanel(
            'Shading',
            <Widget>[
              BlenderDropdown<String>(
                value: _viewportShading,
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Wireframe',
                    label: 'Wireframe',
                  ),
                  BlenderMenuItem<String>(value: 'Solid', label: 'Solid'),
                  BlenderMenuItem<String>(
                    value: 'Material Preview',
                    label: 'Material Preview',
                  ),
                  BlenderMenuItem<String>(value: 'Rendered', label: 'Rendered'),
                ],
                onChanged: (value) => setState(() {
                  _viewportShading = value;
                  _wireframe = value == 'Wireframe';
                }),
              ),
              const SizedBox(height: 6),
              BlenderCheckbox(
                value: _showXray,
                label: 'X-Ray',
                onChanged: (value) => setState(() => _showXray = value),
              ),
              BlenderCheckbox(
                value: true,
                label: 'Cavity',
                onChanged: (value) => _setStatus('Cavity toggled'),
              ),
              BlenderCheckbox(
                value: true,
                label: 'Outline',
                onChanged: (value) => _setStatus('Outline toggled'),
              ),
            ],
          ),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Area options',
        ),
      ],
    );
  }

  Widget _buildViewportPopoverPanel(String title, List<Widget> children) {
    return SizedBox(
      width: 240,
      child: BlenderPanel(
        title: title,
        initiallyExpanded: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Map<String, List<BlenderMenuItem<String>>> _imageEditorMenuDescriptors(
    bool uvEditor,
  ) {
    BlenderMenuItem<String> item(
      String label, {
      List<BlenderMenuItem<String>>? submenu,
    }) {
      return BlenderMenuItem<String>(
        value: label,
        label: label,
        submenu: submenu,
      );
    }

    BlenderMenuItem<String> separator(String id) {
      return BlenderMenuItem<String>(value: id, label: '', separator: true);
    }

    List<BlenderMenuItem<String>> items(Iterable<String> labels) =>
        <BlenderMenuItem<String>>[for (final label in labels) item(label)];

    return <String, List<BlenderMenuItem<String>>>{
      'View': <BlenderMenuItem<String>>[
        ...items(<String>[
          'Toolbar',
          'Sidebar',
          'Tool Header',
          'Asset Shelf',
          'HUD',
          'Use Realtime Update',
          'Show Metadata',
        ]),
        separator('view-separator-1'),
        ...items(<String>[
          'Frame Selected',
          'View All',
          'Center View to Cursor',
        ]),
        item(
          'Zoom',
          submenu: items(<String>[
            '12.5% (1:8)',
            '25% (1:4)',
            '50% (1:2)',
            '100% (1:1)',
            '200% (2:1)',
            '400% (4:1)',
            '800% (8:1)',
            'Zoom In',
            'Zoom Out',
            'Zoom to Fit',
            'Zoom Region...',
          ]),
        ),
        separator('view-separator-2'),
        ...items(<String>[
          'Render Border',
          'Clear Render Border',
          'Render Slot Cycle Next',
          'Render Slot Cycle Previous',
          'Show Same Material',
          'Area',
        ]),
      ],
      'Select': <BlenderMenuItem<String>>[
        ...items(<String>['All', 'None', 'Invert']),
        separator('select-separator-1'),
        ...items(<String>[
          'Box Select',
          'Box Select Pinned',
          'Circle Select',
          'Lasso Select',
          'More',
          'Less',
          'Select Similar',
        ]),
        item(
          'Select Linked',
          submenu: items(<String>['Linked', 'Shortest Path', 'Pinned']),
        ),
        separator('select-separator-2'),
        item(
          'Select All by Trait',
          submenu: items(<String>['Tile', 'Pinned', 'Overlap', 'Winding']),
        ),
        item('Select Split'),
      ],
      'Image': <BlenderMenuItem<String>>[
        ...items(<String>['New...', 'Open...', 'Read View Layers']),
        separator('image-separator-1'),
        ...items(<String>[
          'Replace...',
          'Reload',
          'Edit Externally',
          'Copy',
          'Paste',
        ]),
        separator('image-separator-2'),
        ...items(<String>[
          'Save',
          'Save As...',
          'Save a Copy...',
          'Save All Images',
          'Save Sequence',
        ]),
        separator('image-separator-3'),
        item(
          'Invert',
          submenu: items(<String>[
            'Invert Image Colors',
            'Invert Red Channel',
            'Invert Green Channel',
            'Invert Blue Channel',
            'Invert Alpha Channel',
          ]),
        ),
        ...items(<String>['Resize', 'Transform', 'Pack', 'Unpack']),
        item('Extract Palette'),
      ],
      'UVs': <BlenderMenuItem<String>>[
        item(
          'Transform',
          submenu: items(<String>[
            'Grab',
            'Rotate',
            'Scale',
            'Shear',
            'Warp',
            'Slide',
          ]),
        ),
        item('Mirror', submenu: items(<String>['Mirror X', 'Mirror Y'])),
        item(
          'Snap',
          submenu: items(<String>[
            'Selected to Pixels',
            'Selected to Pixels (Center)',
            'Selected to Cursor',
            'Cursor to Selected',
          ]),
        ),
        item(
          'Pixel Round Mode',
          submenu: items(<String>['Disabled', 'Corner', 'Center']),
        ),
        item('Lock Bounds'),
        separator('uv-separator-1'),
        ...items(<String>[
          'Merge',
          'Split',
          'Rip',
          'Live Unwrap',
          'Unwrap',
          'Pin',
          'Unpin',
          'Invert Pins',
          'Mark Seam',
          'Clear Seam',
          'Seams from Islands',
        ]),
        separator('uv-separator-2'),
        ...items(<String>[
          'Pack Islands',
          'Average Islands Scale',
          'Arrange Islands',
          'Minimize Stretch',
          'Stitch',
          'Align',
          'Align Rotation',
          'Move on Axis',
          'Copy',
          'Paste',
          'Show/Hide Faces',
          'Reset',
        ]),
      ],
    };
  }

  BlenderAreaHeader _buildImageEditorHeader(BlenderEditorType type) {
    final uvEditor = type == BlenderEditorType.uvEditor;
    final menus = <String>[
      'View',
      if (uvEditor) 'Select',
      'Image',
      if (uvEditor) 'UVs',
    ];
    final menuItems = <String, List<String>>{
      'View': <String>[
        'Toolbar',
        'Sidebar',
        'Tool Header',
        'Asset Shelf',
        'HUD',
        'Frame Selected',
        'View All',
        'Center View to Cursor',
        'Zoom',
        'Area',
      ],
      'Select': <String>[
        'All',
        'None',
        'Invert',
        'Box Select',
        'Box Select Pinned',
        'Circle Select',
        'Lasso Select',
        'More',
        'Less',
        'Select Similar',
        'Select Linked',
      ],
      'Image': <String>[
        'New...',
        'Open...',
        'Read View Layers',
        'Replace...',
        'Reload',
        'Save',
        'Save As...',
        'Save All Images',
        'Resize',
        'Transform',
      ],
      'UVs': <String>[
        'Unwrap',
        'Smart UV Project',
        'Project from View',
        'Pack Islands',
        'Average Islands Scale',
        'Minimize Stretch',
        'Transform',
        'Snap',
        'Mirror',
        'Merge',
        'Split',
      ],
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      leading: <Widget>[
        SizedBox(
          width: 86,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('image-display-source'),
            value: uvEditor ? 'UV Map' : 'Image',
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Image', label: 'Image'),
              BlenderMenuItem<String>(value: 'UV Map', label: 'UV Map'),
            ],
            onChanged: _setStatus,
          ),
        ),
      ],
      menus: _editorMenus(
        menus,
        menuItems: menuItems,
        menuDescriptors: _imageEditorMenuDescriptors(uvEditor),
      ),
      actions: <Widget>[
        if (uvEditor)
          BlenderIconButton(
            key: const ValueKey<String>('image-uv-sync-button'),
            glyph: BlenderGlyph.link,
            selected: _imageUvSync,
            onPressed: () => setState(() => _imageUvSync = !_imageUvSync),
            tooltip: 'UV selection sync',
          ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('image-snap-button'),
            glyph: BlenderGlyph.snap,
            selected: _imageSnap,
            tooltip: 'UV snapping',
          ),
          onOpenChanged: (open) => setState(() => _imageSnap = open),
          popover: (context, close) => _buildAnimationPopoverPanel(
            'Snapping',
            <Widget>[
              Text(
                'Snap Target',
                style: BlenderTheme.of(context).textTheme.caption,
              ),
              BlenderDropdown<String>(
                value: 'Vertex',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Vertex', label: 'Vertex'),
                  BlenderMenuItem<String>(value: 'Edge', label: 'Edge'),
                  BlenderMenuItem<String>(value: 'Face', label: 'Face'),
                  BlenderMenuItem<String>(
                    value: 'Increment',
                    label: 'Increment',
                  ),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 6),
              Text(
                'Snap Base',
                style: BlenderTheme.of(context).textTheme.caption,
              ),
              BlenderDropdown<String>(
                value: 'Median',
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Median', label: 'Median'),
                  BlenderMenuItem<String>(value: 'Closest', label: 'Closest'),
                  BlenderMenuItem<String>(value: 'Active', label: 'Active'),
                ],
                onChanged: (_) {},
              ),
              const SizedBox(height: 6),
              BlenderCheckbox(value: true, label: 'Move', onChanged: (_) {}),
              BlenderCheckbox(value: false, label: 'Rotate', onChanged: (_) {}),
              BlenderCheckbox(value: false, label: 'Scale', onChanged: (_) {}),
            ],
          ),
        ),
        if (uvEditor)
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('image-proportional-button'),
              glyph: BlenderGlyph.transform,
              selected: _imageProportional,
              tooltip: 'Proportional editing',
            ),
            onOpenChanged: (open) => setState(() => _imageProportional = open),
            popover: (context, close) =>
                _buildAnimationPopoverPanel('Proportional Editing', <Widget>[
                  BlenderCheckbox(
                    value: true,
                    label: 'Connected',
                    onChanged: (_) {},
                  ),
                  Text(
                    'Falloff',
                    style: BlenderTheme.of(context).textTheme.caption,
                  ),
                  BlenderDropdown<String>(
                    value: 'Smooth',
                    items: const <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Smooth', label: 'Smooth'),
                      BlenderMenuItem<String>(value: 'Sphere', label: 'Sphere'),
                      BlenderMenuItem<String>(value: 'Sharp', label: 'Sharp'),
                    ],
                    onChanged: (_) {},
                  ),
                ]),
          ),
        const BlenderIconButton(
          key: const ValueKey<String>('image-pin-button'),
          glyph: BlenderGlyph.pin,
          tooltip: 'Pin image',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('image-gizmo-button'),
            glyph: BlenderGlyph.gizmo,
            selected: _imageGizmos,
            tooltip: 'Image gizmos',
          ),
          popover: (context, close) =>
              _buildAnimationPopoverPanel('Gizmos', <Widget>[
                BlenderCheckbox(
                  value: _imageGizmos,
                  label: 'Show Gizmos',
                  onChanged: (value) => setState(() => _imageGizmos = value),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Navigate Gizmo',
                  onChanged: (_) {},
                ),
              ]),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('image-overlay-button'),
            glyph: BlenderGlyph.overlay,
            selected: _imageOverlays,
            tooltip: 'Image overlays',
          ),
          popover: (context, close) =>
              _buildAnimationPopoverPanel('Overlays', <Widget>[
                BlenderCheckbox(
                  value: _imageOverlays,
                  label: 'Show Overlays',
                  onChanged: (value) => setState(() => _imageOverlays = value),
                ),
                BlenderCheckbox(
                  value: true,
                  label: 'Image Metadata',
                  onChanged: (_) {},
                ),
                BlenderCheckbox(value: true, label: 'Grid', onChanged: (_) {}),
              ]),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  BlenderAreaHeader _buildSpreadsheetEditorHeader() {
    return BlenderAreaHeader(
      height: 30,
      editorType: BlenderEditorType.spreadsheet,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      menus: _editorMenus(
        const <String>['View'],
        menuItems: const <String, List<String>>{
          'View': <String>['Toolbar', 'Sidebar', 'Internal Attributes', 'Area'],
        },
      ),
      actions: <Widget>[
        BlenderIconButton(
          key: const ValueKey<String>('spreadsheet-only-selected-button'),
          glyph: BlenderGlyph.eye,
          selected: _spreadsheetOnlySelected,
          onPressed: () => setState(
            () => _spreadsheetOnlySelected = !_spreadsheetOnlySelected,
          ),
          tooltip: 'Only Selected',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('spreadsheet-filter-button'),
          glyph: BlenderGlyph.filter,
          selected: _spreadsheetFilter,
          onPressed: () =>
              setState(() => _spreadsheetFilter = !_spreadsheetFilter),
          tooltip: 'Use Filter',
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  List<BlenderMenuItem<String>> _clipMenuItems(String menu) {
    return switch (menu) {
      'View' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Toolbar', label: 'Toolbar'),
        BlenderMenuItem<String>(value: 'Sidebar', label: 'Sidebar'),
        BlenderMenuItem<String>(value: 'View All', label: 'View All'),
        BlenderMenuItem<String>(value: 'View Selected', label: 'View Selected'),
        BlenderMenuItem<String>(value: 'Zoom In', label: 'Zoom In'),
        BlenderMenuItem<String>(value: 'Zoom Out', label: 'Zoom Out'),
        BlenderMenuItem<String>(value: 'Area', label: 'Area'),
      ],
      'Select' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'All', label: 'All'),
        BlenderMenuItem<String>(value: 'None', label: 'None'),
        BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
        BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
        BlenderMenuItem<String>(value: 'Circle Select', label: 'Circle Select'),
        BlenderMenuItem<String>(value: 'Lasso Select', label: 'Lasso Select'),
        BlenderMenuItem<String>(
          value: 'Select Grouped',
          label: 'Select Grouped',
        ),
      ],
      'Clip' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Open Clip', label: 'Open Clip'),
        BlenderMenuItem<String>(value: 'Reload', label: 'Reload'),
        BlenderMenuItem<String>(
          value: 'Set Scene Frames',
          label: 'Set Scene Frames',
        ),
        BlenderMenuItem<String>(value: 'Prefetch', label: 'Prefetch'),
        BlenderMenuItem<String>(value: 'Refine', label: 'Refine'),
      ],
      'Track' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Track Motion', label: 'Track Motion'),
        BlenderMenuItem<String>(
          value: 'Clear Track Path',
          label: 'Clear Track Path',
        ),
        BlenderMenuItem<String>(
          value: 'Refine Markers',
          label: 'Refine Markers',
        ),
        BlenderMenuItem<String>(
          value: 'Solve Camera Motion',
          label: 'Solve Camera Motion',
        ),
        BlenderMenuItem<String>(value: 'Clean Tracks', label: 'Clean Tracks'),
      ],
      'Reconstruction' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Set Floor', label: 'Set Floor'),
        BlenderMenuItem<String>(value: 'Set Wall', label: 'Set Wall'),
        BlenderMenuItem<String>(value: 'Set Origin', label: 'Set Origin'),
        BlenderMenuItem<String>(
          value: 'Apply Solution Scale',
          label: 'Apply Solution Scale',
        ),
      ],
      'Add' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Add Marker', label: 'Add Marker'),
        BlenderMenuItem<String>(
          value: 'Add Plane Track',
          label: 'Add Plane Track',
        ),
        BlenderMenuItem<String>(value: 'Add Mask', label: 'Add Mask'),
      ],
      'Mask' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'New Mask', label: 'New Mask'),
        BlenderMenuItem<String>(value: 'New Layer', label: 'New Layer'),
        BlenderMenuItem<String>(
          value: 'Duplicate Layer',
          label: 'Duplicate Layer',
        ),
        BlenderMenuItem<String>(value: 'Delete Layer', label: 'Delete Layer'),
      ],
      _ => const <BlenderMenuItem<String>>[],
    };
  }

  Widget _buildClipGizmoPopover() =>
      _buildAnimationPopoverPanel('Gizmos', <Widget>[
        BlenderCheckbox(
          value: _clipGizmos,
          label: 'Show Gizmos',
          onChanged: (value) => setState(() => _clipGizmos = value),
        ),
        BlenderCheckbox(
          value: true,
          label: 'Navigate Gizmo',
          onChanged: (_) {},
        ),
        BlenderCheckbox(value: true, label: 'Tool Gizmos', onChanged: (_) {}),
      ]);

  Widget _buildClipOverlayPopover() =>
      _buildAnimationPopoverPanel('Overlays', <Widget>[
        BlenderCheckbox(
          value: _clipOverlays,
          label: 'Show Overlays',
          onChanged: (value) => setState(() => _clipOverlays = value),
        ),
        BlenderCheckbox(value: true, label: '3D Markers', onChanged: (_) {}),
        BlenderCheckbox(value: true, label: 'Grid', onChanged: (_) {}),
        BlenderCheckbox(value: true, label: 'Annotation', onChanged: (_) {}),
        BlenderCheckbox(value: false, label: 'Names', onChanged: (_) {}),
      ]);

  BlenderAreaHeader _buildClipEditorHeader() {
    final masking = _clipMode == 'Mask';
    final graph = _clipView == 'Graph';
    final menus = masking
        ? <String>['View', 'Select', 'Clip', 'Add', 'Mask']
        : graph
        ? <String>['View', 'Select']
        : <String>['View', 'Select', 'Clip', 'Track', 'Reconstruction'];
    final menuItems = <String, List<String>>{
      for (final menu in menus)
        menu: _clipMenuItems(menu).map((item) => item.label).toList(),
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: BlenderEditorType.clipEditor,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      leading: <Widget>[
        SizedBox(
          width: 82,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('clip-mode-selector'),
            value: _clipMode,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Tracking', label: 'Tracking'),
              BlenderMenuItem<String>(value: 'Mask', label: 'Mask'),
            ],
            onChanged: (value) => setState(() => _clipMode = value),
          ),
        ),
        if (!masking)
          SizedBox(
            width: 70,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('clip-view-selector'),
              value: _clipView,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Clip', label: 'Clip'),
                BlenderMenuItem<String>(value: 'Graph', label: 'Graph'),
                BlenderMenuItem<String>(
                  value: 'Dope Sheet',
                  label: 'Dope Sheet',
                ),
              ],
              onChanged: (value) => setState(() => _clipView = value),
            ),
          ),
      ],
      menus: _editorMenus(menus, menuItems: menuItems),
      actions: <Widget>[
        if (masking)
          BlenderIconButton(
            key: const ValueKey<String>('clip-proportional-button'),
            glyph: BlenderGlyph.transform,
            selected: _clipProportional,
            onPressed: () =>
                setState(() => _clipProportional = !_clipProportional),
            tooltip: 'Proportional editing',
          ),
        const BlenderIconButton(
          key: const ValueKey<String>('clip-lock-button'),
          glyph: BlenderGlyph.lock,
          tooltip: 'Lock selection',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('clip-gizmo-button'),
            glyph: BlenderGlyph.gizmo,
            selected: _clipGizmos,
            tooltip: 'Clip gizmos',
          ),
          popover: (context, close) => _buildClipGizmoPopover(),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('clip-overlay-button'),
            glyph: BlenderGlyph.overlay,
            selected: _clipOverlays,
            tooltip: 'Clip overlays',
          ),
          popover: (context, close) => _buildClipOverlayPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  List<BlenderMenuItem<String>> _nlaMenuItems(String menu) {
    return switch (menu) {
      'View' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Sidebar', label: 'Sidebar'),
        BlenderMenuItem<String>(value: 'Channels', label: 'Channels'),
        BlenderMenuItem<String>(
          value: 'Playback Controls',
          label: 'Playback Controls',
        ),
        BlenderMenuItem<String>(value: 'View Selected', label: 'View Selected'),
        BlenderMenuItem<String>(value: 'View All', label: 'View All'),
        BlenderMenuItem<String>(
          value: 'Frame Scene Range',
          label: 'Frame Scene Range',
        ),
        BlenderMenuItem<String>(value: 'View Frame', label: 'View Frame'),
        BlenderMenuItem<String>(
          value: 'Realtime Update',
          label: 'Realtime Update',
        ),
        BlenderMenuItem<String>(
          value: 'Show Strip Curves',
          label: 'Show Strip Curves',
        ),
        BlenderMenuItem<String>(value: 'Show Markers', label: 'Show Markers'),
        BlenderMenuItem<String>(
          value: 'Show Local Markers',
          label: 'Show Local Markers',
        ),
        BlenderMenuItem<String>(value: 'Show Seconds', label: 'Show Seconds'),
        BlenderMenuItem<String>(
          value: 'Show Locked Time',
          label: 'Show Locked Time',
        ),
        BlenderMenuItem<String>(
          value: 'Set Preview Range',
          label: 'Set Preview Range',
        ),
        BlenderMenuItem<String>(
          value: 'Clear Preview Range',
          label: 'Clear Preview Range',
        ),
        BlenderMenuItem<String>(
          value: 'Set NLA Preview Range',
          label: 'Set NLA Preview Range',
        ),
        BlenderMenuItem<String>(value: 'Area', label: 'Area'),
      ],
      'Select' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'All', label: 'All'),
        BlenderMenuItem<String>(value: 'None', label: 'None'),
        BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
        BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
        BlenderMenuItem<String>(
          value: 'Box Select (Axis Range)',
          label: 'Box Select (Axis Range)',
        ),
        BlenderMenuItem<String>(
          value: 'Before Current Frame',
          label: 'Before Current Frame',
        ),
        BlenderMenuItem<String>(
          value: 'After Current Frame',
          label: 'After Current Frame',
        ),
      ],
      'Marker' => _animationMarkerMenuItems(),
      'Add' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Action', label: 'Action'),
        BlenderMenuItem<String>(value: 'Transition', label: 'Transition'),
        BlenderMenuItem<String>(value: 'Sound', label: 'Sound'),
        BlenderMenuItem<String>(
          value: 'Selected Objects',
          label: 'Selected Objects',
        ),
      ],
      'Track' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Add', label: 'Add'),
        BlenderMenuItem<String>(
          value: 'Add Above Selected',
          label: 'Add Above Selected',
        ),
        BlenderMenuItem<String>(value: 'Move', label: 'Move'),
        BlenderMenuItem<String>(value: 'Clean Empty', label: 'Clean Empty'),
        BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
      ],
      'Strip' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
        BlenderMenuItem<String>(value: 'Snap', label: 'Snap'),
        BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
        BlenderMenuItem<String>(
          value: 'Linked Duplicate',
          label: 'Linked Duplicate',
        ),
        BlenderMenuItem<String>(value: 'Make Meta', label: 'Make Meta'),
        BlenderMenuItem<String>(value: 'Remove Meta', label: 'Remove Meta'),
        BlenderMenuItem<String>(value: 'Split', label: 'Split'),
        BlenderMenuItem<String>(value: 'Mute', label: 'Mute'),
        BlenderMenuItem<String>(value: 'Bake Action', label: 'Bake Action'),
        BlenderMenuItem<String>(value: 'Apply Scale', label: 'Apply Scale'),
        BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
      ],
      _ => const <BlenderMenuItem<String>>[],
    };
  }

  Widget _buildNlaFiltersPopover() =>
      _buildAnimationPopoverPanel('Filters', <Widget>[
        BlenderCheckbox(
          value: _nlaSelectedOnly,
          label: 'Only Selected',
          onChanged: (value) => setState(() => _nlaSelectedOnly = value),
        ),
        BlenderCheckbox(
          value: _nlaShowHidden,
          label: 'Show Hidden',
          onChanged: (value) => setState(() => _nlaShowHidden = value),
        ),
        BlenderCheckbox(
          value: _nlaShowMissing,
          label: 'Show Missing',
          onChanged: (value) => setState(() => _nlaShowMissing = value),
        ),
        BlenderCheckbox(
          value: _nlaShowErrors,
          label: 'Only Errors',
          onChanged: (value) => setState(() => _nlaShowErrors = value),
        ),
        const BlenderSeparator(),
        BlenderPropertyRow(
          label: 'F-Curve Name',
          editor: BlenderTextField(
            controller: TextEditingController(),
            placeholder: 'Search F-Curves',
          ),
        ),
        BlenderPropertyRow(
          label: 'Collection',
          editor: BlenderTextField(
            controller: TextEditingController(),
            placeholder: 'Search Collections',
          ),
        ),
        const BlenderSeparator(),
        const Text('Filter by Type'),
        for (final label in const <String>[
          'Scenes',
          'Node Trees',
          'Armatures',
          'Cameras',
          'Grease Pencil Objects',
          'Lights',
          'Meshes',
          'Curves',
          'Lattices',
          'Metaballs',
          'Volumes',
          'Worlds',
          'Particles',
          'Speakers',
          'Materials',
          'Textures',
          'Shape Keys',
          'Movie Clips',
        ])
          BlenderCheckbox(value: true, label: label, onChanged: (_) {}),
        const BlenderSeparator(),
        BlenderCheckbox(value: true, label: 'Transforms', onChanged: (_) {}),
        BlenderCheckbox(value: true, label: 'Modifiers', onChanged: (_) {}),
        const BlenderSeparator(),
        BlenderCheckbox(
          value: true,
          label: 'Use Data-Block Sort',
          onChanged: (_) {},
        ),
      ]);

  Widget _buildNlaSnappingPopover() =>
      _buildAnimationPopoverPanel('Snapping', <Widget>[
        const Text('Snap To'),
        BlenderDropdown<String>(
          value: 'Frame',
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
            BlenderMenuItem<String>(value: 'Second', label: 'Second'),
            BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
          ],
          onChanged: (value) => _setStatus('NLA snap target $value'),
        ),
        BlenderCheckbox(
          value: _nlaSnap,
          label: 'Absolute Time',
          onChanged: (value) => setState(() => _nlaSnap = value),
        ),
      ]);

  Widget _buildNlaPlaybackFooter() {
    return BlenderToolbar(
      key: const ValueKey<String>('nla-playback-footer'),
      height: 30,
      scrollable: true,
      background: BlenderTheme.of(context).colors.canvas,
      children: <Widget>[
        BlenderPopover(
          child: const BlenderButton(
            key: ValueKey<String>('nla-playback-settings-button'),
            label: 'Playback',
            variant: BlenderButtonVariant.topBar,
          ),
          popover: (context, close) => _buildAnimationPlaybackPopover(),
        ),
        BlenderPlaybackControls(
          playing: _playing,
          onFirst: () => setState(() => _frame = 1),
          onPrevious: () =>
              setState(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
          onPlay: () => setState(() => _playing = !_playing),
          onNext: () =>
              setState(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
          onLast: () => setState(() => _frame = 120),
          onRecord: () => _setStatus('Record toggled'),
        ),
        SizedBox(
          width: 92,
          child: BlenderNumberField(
            value: _frame,
            min: 1,
            max: 120,
            step: 1,
            decimalDigits: 0,
            onChanged: (value) => setState(() => _frame = value),
          ),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('nla-playhead-snap-button'),
            glyph: BlenderGlyph.snap,
            selected: _nlaSnap,
            tooltip: 'NLA playhead snapping',
          ),
          popover: (context, close) => _buildAnimationPlayheadSnappingPopover(),
        ),
      ],
    );
  }

  BlenderAreaHeader _buildNlaEditorHeader() {
    final menuItems = <String, List<String>>{
      for (final menu in const <String>[
        'View',
        'Select',
        'Marker',
        'Add',
        'Track',
        'Strip',
      ])
        menu: _nlaMenuItems(menu).map((item) => item.label).toList(),
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: BlenderEditorType.nlaEditor,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      actionsScrollable: true,
      menus: _editorMenus(const <String>[
        'View',
        'Select',
        'Marker',
        'Add',
        'Track',
        'Strip',
      ], menuItems: menuItems),
      actions: <Widget>[
        BlenderIconButton(
          key: const ValueKey<String>('nla-only-selected-button'),
          glyph: BlenderGlyph.object,
          selected: _nlaSelectedOnly,
          onPressed: () => setState(() => _nlaSelectedOnly = !_nlaSelectedOnly),
          tooltip: 'Only Selected',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('nla-show-hidden-button'),
          glyph: BlenderGlyph.eye,
          selected: _nlaShowHidden,
          onPressed: () => setState(() => _nlaShowHidden = !_nlaShowHidden),
          tooltip: 'Show Hidden',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('nla-show-missing-button'),
          glyph: BlenderGlyph.warning,
          selected: _nlaShowMissing,
          onPressed: () => setState(() => _nlaShowMissing = !_nlaShowMissing),
          tooltip: 'Show Missing',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('nla-only-errors-button'),
          glyph: BlenderGlyph.error,
          selected: _nlaShowErrors,
          onPressed: () => setState(() => _nlaShowErrors = !_nlaShowErrors),
          tooltip: 'Only Errors',
        ),
        BlenderPopover(
          child: const BlenderIconButton(
            key: ValueKey<String>('nla-filters-button'),
            glyph: BlenderGlyph.filter,
            tooltip: 'NLA filters',
          ),
          popover: (context, close) => _buildNlaFiltersPopover(),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('nla-snapping-button'),
            glyph: BlenderGlyph.snap,
            selected: _nlaSnap,
            tooltip: 'NLA snapping',
          ),
          popover: (context, close) => _buildNlaSnappingPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  BlenderAreaHeader _buildAnimationEditorHeader(BlenderEditorType type) {
    final timeline = type == BlenderEditorType.timeline;
    final menuLabels = timeline
        ? const <String>['View', 'Marker']
        : const <String>[
            'View',
            'Select',
            'Marker',
            'Channel',
            'Key',
            'Action',
          ];
    final menuItems = <String, List<String>>{
      'View': _animationViewMenuItems(
        timeline: timeline,
      ).map((item) => item.label).toList(),
      'Marker': _animationMarkerMenuItems().map((item) => item.label).toList(),
      if (!timeline) ...<String, List<String>>{
        'Select': _animationSelectMenuItems()
            .map((item) => item.label)
            .toList(),
        'Channel': _animationChannelMenuItems()
            .map((item) => item.label)
            .toList(),
        'Key': _animationKeyMenuItems().map((item) => item.label).toList(),
        'Action': _animationActionMenuItems()
            .map((item) => item.label)
            .toList(),
      },
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      actionsScrollable: true,
      leading: <Widget>[
        if (!timeline)
          SizedBox(
            width: 220,
            child: BlenderActionSelector<String>(
              key: const ValueKey<String>('main-animation-action-selector'),
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
      menus: _editorMenus(menuLabels, menuItems: menuItems),
      actions: <Widget>[
        if (timeline) ...<Widget>[
          BlenderPopover(
            child: const BlenderButton(
              key: ValueKey<String>('main-animation-playback-button'),
              label: 'Playback',
              variant: BlenderButtonVariant.topBar,
            ),
            popover: (context, close) => _buildAnimationPlaybackPopover(),
          ),
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('main-animation-autokey-button'),
              glyph: BlenderGlyph.keyframe,
              selected: _animationAutoKeying,
              tooltip: 'Auto Keying',
              size: 24,
            ),
            popover: (context, close) => _buildAnimationAutoKeyingPopover(),
          ),
          BlenderPlaybackControls(
            playing: _playing,
            onFirst: () => setState(() => _frame = 1),
            onPrevious: () =>
                setState(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
            onPlay: () => setState(() => _playing = !_playing),
            onNext: () =>
                setState(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
            onLast: () => setState(() => _frame = 120),
            onRecord: () => _setStatus('Record toggled'),
          ),
          BlenderTimeJumpControls(
            key: const ValueKey<String>('main-animation-time-jump-controls'),
            onBackward: () =>
                setState(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
            onForward: () =>
                setState(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
            popover: (context, close) => _buildAnimationTimeJumpPopover(),
          ),
          SizedBox(
            width: 92,
            child: BlenderNumberField(
              value: _frame,
              min: 1,
              max: 120,
              step: 1,
              decimalDigits: 0,
              onChanged: (value) => setState(() => _frame = value),
            ),
          ),
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('main-animation-playhead-snap'),
              glyph: BlenderGlyph.snap,
              selected: _animationPlayheadSnap,
              tooltip: 'Playhead snapping',
              size: 24,
            ),
            popover: (context, close) =>
                _buildAnimationPlayheadSnappingPopover(),
          ),
        ] else ...<Widget>[
          BlenderPopover(
            child: const BlenderIconButton(
              key: ValueKey<String>('main-animation-filters-button'),
              glyph: BlenderGlyph.filter,
              tooltip: 'Animation filters',
              size: 24,
            ),
            popover: (context, close) => _buildAnimationFiltersPopover(),
          ),
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('main-animation-snapping-button'),
              glyph: BlenderGlyph.snap,
              selected: _animationPlayheadSnap,
              tooltip: 'Animation snapping',
              size: 24,
            ),
            popover: (context, close) => _buildAnimationSnappingPopover(),
          ),
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('main-animation-proportional-button'),
              glyph: BlenderGlyph.transform,
              selected: _animationProportional,
              tooltip: 'Proportional editing',
              size: 24,
            ),
            popover: (context, close) => _buildProportionalEditingPopover(),
          ),
        ],
        BlenderPopover(
          child: BlenderIconButton(
            key: ValueKey<String>(
              timeline
                  ? 'main-animation-overlay-button'
                  : 'main-animation-dope-overlay-button',
            ),
            glyph: BlenderGlyph.overlay,
            selected: _animationOverlays,
            tooltip: 'Animation overlays',
            size: 24,
          ),
          popover: (context, close) => _buildAnimationOverlayPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  List<BlenderMenuItem<String>> _sequencerViewMenuItems({
    required bool sequencerView,
    required bool preview,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(
      value: 'Show Region Toolbar',
      label: 'Show Region Toolbar',
    ),
    const BlenderMenuItem<String>(
      value: 'Show Region UI',
      label: 'Show Region UI',
    ),
    const BlenderMenuItem<String>(
      value: 'Show Tool Header',
      label: 'Show Tool Header',
    ),
    if (sequencerView)
      const BlenderMenuItem<String>(
        value: 'Show Region HUD',
        label: 'Show Region HUD',
      ),
    if (sequencerView)
      const BlenderMenuItem<String>(
        value: 'Show Region Channels',
        label: 'Show Region Channels',
      ),
    const BlenderMenuItem<String>(
      value: 'Playback Controls',
      label: 'Playback Controls',
    ),
    if (preview)
      const BlenderMenuItem<String>(
        value: 'Preview During Transform',
        label: 'Preview During Transform',
      ),
    const BlenderMenuItem<String>(value: 'Refresh All', label: 'Refresh All'),
    const BlenderMenuItem<String>(
      value: 'Frame Selected',
      label: 'Frame Selected',
    ),
    if (sequencerView) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(value: 'View All', label: 'View All'),
      const BlenderMenuItem<String>(
        value: 'Frame Preview Range',
        label: 'Frame Preview Range',
      ),
      const BlenderMenuItem<String>(value: 'View Frame', label: 'View Frame'),
      const BlenderMenuItem<String>(value: 'Clamp View', label: 'Clamp View'),
    ],
    if (preview) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Fit Preview in Window',
        label: 'Fit Preview in Window',
      ),
      const BlenderMenuItem<String>(
        value: 'Preview Zoom',
        label: 'Preview Zoom',
      ),
      const BlenderMenuItem<String>(value: 'Auto Zoom', label: 'Auto Zoom'),
      const BlenderMenuItem<String>(value: 'Proxy', label: 'Proxy'),
    ],
    const BlenderMenuItem<String>(value: 'Show Seconds', label: 'Show Seconds'),
    if (sequencerView) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Show Markers',
        label: 'Show Markers',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Locked Time',
        label: 'Show Locked Time',
      ),
      const BlenderMenuItem<String>(value: 'Navigation', label: 'Navigation'),
      const BlenderMenuItem<String>(value: 'Range', label: 'Range'),
    ],
    const BlenderMenuItem<String>(
      value: 'Render Still Preview',
      label: 'Render Still Preview',
    ),
    const BlenderMenuItem<String>(
      value: 'Render Sequence Preview',
      label: 'Render Sequence Preview',
    ),
    const BlenderMenuItem<String>(
      value: 'Export Subtitles',
      label: 'Export Subtitles',
    ),
    const BlenderMenuItem<String>(
      value: 'Toggle Sequencer/Preview',
      label: 'Toggle Sequencer/Preview',
    ),
    const BlenderMenuItem<String>(value: 'Area', label: 'Area'),
  ];

  List<BlenderMenuItem<String>> _sequencerSelectMenuItems({
    required bool sequencerView,
    required bool preview,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(value: 'All', label: 'All'),
    const BlenderMenuItem<String>(value: 'None', label: 'None'),
    const BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
    const BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
    if (sequencerView)
      const BlenderMenuItem<String>(
        value: 'Box Select (Include Handles)',
        label: 'Box Select (Include Handles)',
      ),
    if (sequencerView) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(value: 'More', label: 'More'),
      const BlenderMenuItem<String>(value: 'Less', label: 'Less'),
    ],
    const BlenderMenuItem<String>(
      value: 'Select All by Type',
      label: 'Select All by Type',
    ),
    const BlenderMenuItem<String>(
      value: 'Select Grouped',
      label: 'Select Grouped',
    ),
    if (sequencerView) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Select Linked',
        label: 'Select Linked',
      ),
      const BlenderMenuItem<String>(
        value: 'Side of Frame',
        label: 'Side of Frame',
      ),
      const BlenderMenuItem<String>(value: 'Handle', label: 'Handle'),
      const BlenderMenuItem<String>(value: 'Channel', label: 'Channel'),
    ],
  ];

  List<BlenderMenuItem<String>> _sequencerAddMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Search...', label: 'Search...'),
        BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
        BlenderMenuItem<String>(value: 'Clip', label: 'Clip'),
        BlenderMenuItem<String>(value: 'Mask', label: 'Mask'),
        BlenderMenuItem<String>(value: 'Movie...', label: 'Movie...'),
        BlenderMenuItem<String>(value: 'Sound...', label: 'Sound...'),
        BlenderMenuItem<String>(
          value: 'Image/Sequence...',
          label: 'Image/Sequence...',
        ),
        BlenderMenuItem<String>(value: 'Color', label: 'Color'),
        BlenderMenuItem<String>(value: 'Text', label: 'Text'),
        BlenderMenuItem<String>(
          value: 'Adjustment Layer',
          label: 'Adjustment Layer',
        ),
        BlenderMenuItem<String>(value: 'Compositor', label: 'Compositor'),
        BlenderMenuItem<String>(value: 'Scene Strip', label: 'Scene Strip'),
        BlenderMenuItem<String>(value: 'Transition', label: 'Transition'),
        BlenderMenuItem<String>(value: 'Wipe', label: 'Wipe'),
        BlenderMenuItem<String>(value: 'Glow', label: 'Glow'),
        BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
        BlenderMenuItem<String>(value: 'Speed', label: 'Speed'),
      ];

  List<BlenderMenuItem<String>> _sequencerStripMenuItems({
    required bool sequencerView,
    required bool preview,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
    if (preview) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(value: 'Mirror', label: 'Mirror'),
      const BlenderMenuItem<String>(value: 'Copy', label: 'Copy'),
      const BlenderMenuItem<String>(value: 'Paste', label: 'Paste'),
      const BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
      const BlenderMenuItem<String>(value: 'Animation', label: 'Animation'),
      const BlenderMenuItem<String>(value: 'Show/Hide', label: 'Show/Hide'),
      const BlenderMenuItem<String>(value: 'Text', label: 'Text'),
    ],
    if (sequencerView) ...<BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(value: 'Retiming', label: 'Retiming'),
      const BlenderMenuItem<String>(value: 'Split', label: 'Split'),
      const BlenderMenuItem<String>(value: 'Hold Split', label: 'Hold Split'),
      const BlenderMenuItem<String>(
        value: 'Duplicate Linked',
        label: 'Duplicate Linked',
      ),
      const BlenderMenuItem<String>(value: 'Modifiers', label: 'Modifiers'),
      const BlenderMenuItem<String>(value: 'Meta', label: 'Meta'),
      const BlenderMenuItem<String>(value: 'Color Tag', label: 'Color Tag'),
      const BlenderMenuItem<String>(value: 'Lock/Mute', label: 'Lock/Mute'),
      const BlenderMenuItem<String>(value: 'Connect', label: 'Connect'),
      const BlenderMenuItem<String>(value: 'Input', label: 'Input'),
    ],
    const BlenderMenuItem<String>(
      value: 'Ripple Delete',
      label: 'Ripple Delete',
    ),
    const BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
  ];

  List<BlenderMenuItem<String>> _sequencerImageMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
        BlenderMenuItem<String>(value: 'Clear', label: 'Clear'),
        BlenderMenuItem<String>(value: 'Apply', label: 'Apply'),
        BlenderMenuItem<String>(value: 'Scale To Fit', label: 'Scale To Fit'),
        BlenderMenuItem<String>(value: 'Scale to Fill', label: 'Scale to Fill'),
        BlenderMenuItem<String>(
          value: 'Stretch To Fill',
          label: 'Stretch To Fill',
        ),
      ];

  Widget _buildSequencerSnappingPopover() {
    return _buildAnimationPopoverPanel('Snapping', <Widget>[
      const Text('Snap To'),
      BlenderSegmentedControl<String>(
        value: 'Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
          BlenderMenuItem<String>(value: 'Second', label: 'Second'),
          BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
        ],
        onChanged: (value) => _setStatus('Sequencer snap target $value'),
      ),
      BlenderCheckbox(
        value: _sequencerSnap,
        label: 'Use Snapping',
        onChanged: (value) => setState(() => _sequencerSnap = value),
      ),
    ]);
  }

  Widget _buildSequencerGizmoPopover() {
    return _buildAnimationPopoverPanel('Gizmos', <Widget>[
      BlenderCheckbox(
        value: _sequencerGizmos,
        label: 'Show Gizmos',
        onChanged: (value) => setState(() => _sequencerGizmos = value),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Navigate',
        onChanged: (value) => _setStatus('Sequencer navigate gizmo toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Active Tools',
        onChanged: (value) => _setStatus('Sequencer tool gizmo toggled'),
      ),
    ]);
  }

  Widget _buildSequencerOverlayPopover() {
    return _buildAnimationPopoverPanel('Overlays', <Widget>[
      BlenderCheckbox(
        value: _sequencerOverlays,
        label: 'Show Overlays',
        onChanged: (value) => setState(() => _sequencerOverlays = value),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Grid',
        onChanged: (value) => _setStatus('Sequencer grid toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Cache',
        onChanged: (value) => _setStatus('Sequencer cache overlay toggled'),
      ),
      const BlenderSeparator(),
      const Text('Strips'),
      for (final label in const <String>[
        'Name',
        'Source',
        'Duration',
        'Animation Curves',
        'Color Tags',
        'Offsets',
        'Retiming',
      ])
        BlenderCheckbox(
          value: true,
          label: label,
          onChanged: (value) => _setStatus('$label overlay toggled'),
        ),
      const BlenderSeparator(),
      const Text('Preview Overlays'),
      for (final label in const <String>[
        'Frame Overlay',
        'Metadata',
        'Annotations',
        'Cursor',
        'Safe Areas',
        'Guides',
      ])
        BlenderCheckbox(
          value: true,
          label: label,
          onChanged: (value) => _setStatus('$label preview overlay toggled'),
        ),
    ]);
  }

  BlenderAreaHeader _buildSequencerEditorHeader(BlenderEditorType type) {
    final sequencerView = _sequencerViewType != 'Preview';
    final preview = _sequencerViewType != 'Sequencer';
    final menus = <String>[
      'View',
      'Select',
      if (sequencerView) 'Marker',
      if (sequencerView) 'Add',
      'Strip',
      if (preview) 'Image',
    ];
    final menuItems = <String, List<String>>{
      'View': _sequencerViewMenuItems(
        sequencerView: sequencerView,
        preview: preview,
      ).map((item) => item.label).toList(),
      'Select': _sequencerSelectMenuItems(
        sequencerView: sequencerView,
        preview: preview,
      ).map((item) => item.label).toList(),
      'Marker': _animationMarkerMenuItems().map((item) => item.label).toList(),
      'Add': _sequencerAddMenuItems().map((item) => item.label).toList(),
      'Strip': _sequencerStripMenuItems(
        sequencerView: sequencerView,
        preview: preview,
      ).map((item) => item.label).toList(),
      'Image': _sequencerImageMenuItems().map((item) => item.label).toList(),
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      actionsScrollable: true,
      leading: <Widget>[
        SizedBox(
          width: 132,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('sequencer-view-type'),
            value: _sequencerViewType,
            compact: true,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Sequencer', label: 'Sequencer'),
              BlenderMenuItem<String>(value: 'Preview', label: 'Preview'),
              BlenderMenuItem<String>(
                value: 'Sequencer & Preview',
                label: 'Sequencer & Preview',
              ),
            ],
            onChanged: (value) => setState(() => _sequencerViewType = value),
          ),
        ),
      ],
      menus: _editorMenus(menus, menuItems: menuItems),
      actions: <Widget>[
        if (sequencerView)
          SizedBox(
            width: 92,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('sequencer-scene-selector'),
              value: 'Scene',
              compact: true,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
                BlenderMenuItem<String>(
                  value: 'Preview Scene',
                  label: 'Preview Scene',
                ),
              ],
              onChanged: (value) => _setStatus('Sequencer scene $value'),
            ),
          ),
        if (sequencerView)
          SizedBox(
            width: 92,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('sequencer-overlap-mode'),
              value: _sequencerOverlapMode,
              compact: true,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Overwrite', label: 'Overwrite'),
                BlenderMenuItem<String>(value: 'Expand', label: 'Expand'),
                BlenderMenuItem<String>(value: 'Shuffle', label: 'Shuffle'),
              ],
              onChanged: (value) =>
                  setState(() => _sequencerOverlapMode = value),
            ),
          ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('sequencer-snapping-button'),
            glyph: BlenderGlyph.snap,
            selected: _sequencerSnap,
            tooltip: 'Sequencer snapping',
          ),
          popover: (context, close) => _buildSequencerSnappingPopover(),
        ),
        if (preview) ...<Widget>[
          SizedBox(
            width: 72,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('sequencer-display-mode'),
              value: _sequencerDisplayMode,
              compact: true,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Image', label: 'Image'),
                BlenderMenuItem<String>(value: 'Waveform', label: 'Waveform'),
              ],
              onChanged: (value) =>
                  setState(() => _sequencerDisplayMode = value),
            ),
          ),
          const SizedBox(
            width: 72,
            child: BlenderDropdown<String>(
              key: ValueKey<String>('sequencer-preview-channels'),
              value: 'All Channels',
              compact: true,
              items: <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'All Channels',
                  label: 'All Channels',
                ),
                BlenderMenuItem<String>(value: 'RGB', label: 'RGB'),
                BlenderMenuItem<String>(value: 'Alpha', label: 'Alpha'),
              ],
              onChanged: null,
            ),
          ),
          BlenderPopover(
            child: BlenderIconButton(
              key: const ValueKey<String>('sequencer-gizmo-button'),
              glyph: BlenderGlyph.gizmo,
              selected: _sequencerGizmos,
              tooltip: 'Sequencer gizmos',
            ),
            popover: (context, close) => _buildSequencerGizmoPopover(),
          ),
        ],
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('sequencer-overlay-button'),
            glyph: BlenderGlyph.overlay,
            selected: _sequencerOverlays,
            tooltip: 'Sequencer overlays',
          ),
          popover: (context, close) => _buildSequencerOverlayPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

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
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      leading: <Widget>[
        SizedBox(
          width: 92,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('node-tree-context'),
            value: contextValue,
            items: contextItems,
            onChanged: (value) => setState(() => _nodeTreeContext = value),
          ),
        ),
      ],
      menus: _editorMenus(
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
                setState(() => _nodeShowBackdrop = !_nodeShowBackdrop),
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
          onPressed: () => setState(() => _nodeSnap = !_nodeSnap),
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
          onChanged: (value) => setState(() => _nodeGizmos = value),
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
        onChanged: (value) => setState(() => _nodeOverlays = value),
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
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      menus: _editorMenus(menus, menuItems: menuItems),
      actions: const <Widget>[
        BlenderIconButton(glyph: BlenderGlyph.more, tooltip: 'Editor options'),
      ],
    );
  }

  List<Widget> _editorMenus(
    List<String> labels, {
    Map<String, List<String>> menuItems = const <String, List<String>>{},
    Map<String, List<BlenderMenuItem<String>>> menuDescriptors =
        const <String, List<BlenderMenuItem<String>>>{},
  }) => <Widget>[
    for (final label in labels)
      BlenderMenuButton<String>(
        label: label,
        items:
            menuDescriptors[label] ??
            <BlenderMenuItem<String>>[
              for (final item in menuItems[label] ?? <String>['$label Options'])
                BlenderMenuItem<String>(value: item, label: item),
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
          sidebar: const BlenderViewportSidebar(),
        ),
      ),
      BlenderEditorType.imageEditor => const BlenderImageEditor(
        label: 'Image Editor',
        sidebar: BlenderImageEditorSidebar(),
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
        sidebar: BlenderImageEditorSidebar(uvEditor: true),
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
        footer: _buildNlaPlaybackFooter(),
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
        maskSidebar: BlenderMaskProperties(),
        sidebar: BlenderClipEditorSidebar(),
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
        sidebar: BlenderTextEditorSidebar(),
      ),
      BlenderEditorType.project => const BlenderProjectEditor(),
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
        filterController: _mainOutlinerSearchController,
        syncSelection: _outlinerSyncSelection,
        onSyncSelectionChanged: (value) =>
            setState(() => _outlinerSyncSelection = value),
        libraryOverrideViewMode: _outlinerOverrideViewMode,
        onLibraryOverrideViewModeChanged: (value) =>
            setState(() => _outlinerOverrideViewMode = value),
        useIdFilter: _outlinerUseIdFilter,
        onIdFilterChanged: (value) =>
            setState(() => _outlinerUseIdFilter = value),
        idFilterType: _outlinerIdFilterType,
        onIdFilterTypeChanged: (value) =>
            setState(() => _outlinerIdFilterType = value),
        onNewCollection: () => _setStatus('New collection'),
        onPurgeUnusedData: () => _setStatus('Purge unused data'),
        hasActiveKeyingSet: _outlinerHasKeyingSet,
        activeKeyingSet: _outlinerKeyingSet,
        onKeyingSetChanged: (value) =>
            setState(() => _outlinerKeyingSet = value),
        onKeyingSetAdd: () => _setStatus('Added selected to keying set'),
        onKeyingSetRemove: () => _setStatus('Removed selected from keying set'),
        onKeyframeInsert: () => _setStatus('Inserted keyframe'),
        onKeyframeDelete: () => _setStatus('Deleted keyframe'),
        onSelected: (node) {
          if (node.value != null) _setStatus('Selected ${node.value}');
        },
      ),
      BlenderEditorType.properties => BlenderPropertiesEditor(
        groups: _propertyGroups,
      ),
      BlenderEditorType.preferences => BlenderPreferencesEditor(
        categories: _preferenceCategories,
        categoryGroups: _preferenceCategoryGroups,
        selectedCategory: _preferenceCategory,
        onCategoryChanged: (value) =>
            setState(() => _preferenceCategory = value),
        sections: _preferenceSections,
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
        sidebar: const BlenderFileBrowserSidebar(),
        onBack: () => _setStatus('Back'),
        onForward: () => _setStatus('Forward'),
        onParent: () => _setStatus('Parent directory'),
        onRefresh: () => _setStatus('Refreshed'),
        onNewFolder: () => _setStatus('New folder'),
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
        onBack: () => _setStatus('Back'),
        onForward: () => _setStatus('Forward'),
        onParent: () => _setStatus('Parent directory'),
        onRefresh: () => _setStatus('Refreshed'),
        onNewFolder: () => _setStatus('New folder'),
        sidebar: BlenderFileBrowserSidebar(
          assetBrowser: true,
          assetCatalog: BlenderFileAssetCatalogPanel(
            libraryValue: 'Local',
            libraryItems: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Local', label: 'Local'),
              BlenderMenuItem<String>(value: 'Essentials', label: 'Essentials'),
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
        assetBrowser: true,
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
        sidebar: BlenderNodeEditorSidebar(
          geometryNodeEditor:
              _mainEditorType == BlenderEditorType.geometryNodeEditor,
          compositor: _mainEditorType == BlenderEditorType.compositor,
        ),
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
      syncSelection: _outlinerSyncSelection,
      onSyncSelectionChanged: (value) =>
          setState(() => _outlinerSyncSelection = value),
      libraryOverrideViewMode: _outlinerOverrideViewMode,
      onLibraryOverrideViewModeChanged: (value) =>
          setState(() => _outlinerOverrideViewMode = value),
      useIdFilter: _outlinerUseIdFilter,
      onIdFilterChanged: (value) =>
          setState(() => _outlinerUseIdFilter = value),
      idFilterType: _outlinerIdFilterType,
      onIdFilterTypeChanged: (value) =>
          setState(() => _outlinerIdFilterType = value),
      onNewCollection: () => _setStatus('New collection'),
      onPurgeUnusedData: () => _setStatus('Purge unused data'),
      hasActiveKeyingSet: _outlinerHasKeyingSet,
      activeKeyingSet: _outlinerKeyingSet,
      onKeyingSetChanged: (value) => setState(() => _outlinerKeyingSet = value),
      onKeyingSetAdd: () => _setStatus('Added selected to keying set'),
      onKeyingSetRemove: () => _setStatus('Removed selected from keying set'),
      onKeyframeInsert: () => _setStatus('Inserted keyframe'),
      onKeyframeDelete: () => _setStatus('Deleted keyframe'),
      showVisibility: true,
      showLock: true,
      filterController: _outlinerSearchController,
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

  Widget _buildModifierPropertiesBody({String title = 'Modifiers'}) {
    const addModifierItems = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(
        value: 'Edit',
        label: 'Edit',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Data Transfer',
            label: 'Data Transfer',
          ),
          BlenderMenuItem<String>(value: 'UV Project', label: 'UV Project'),
          BlenderMenuItem<String>(value: 'Mesh Cache', label: 'Mesh Cache'),
        ],
      ),
      BlenderMenuItem<String>(
        value: 'Generate',
        label: 'Generate',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Array', label: 'Array'),
          BlenderMenuItem<String>(value: 'Bevel', label: 'Bevel'),
          BlenderMenuItem<String>(value: 'Boolean', label: 'Boolean'),
          BlenderMenuItem<String>(
            value: 'Subdivision Surface',
            label: 'Subdivision Surface',
          ),
          BlenderMenuItem<String>(value: 'Solidify', label: 'Solidify'),
        ],
      ),
      BlenderMenuItem<String>(
        value: 'Deform',
        label: 'Deform',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Armature', label: 'Armature'),
          BlenderMenuItem<String>(value: 'Cast', label: 'Cast'),
          BlenderMenuItem<String>(value: 'Shrinkwrap', label: 'Shrinkwrap'),
          BlenderMenuItem<String>(value: 'Wave', label: 'Wave'),
        ],
      ),
      BlenderMenuItem<String>(
        value: 'Normals',
        label: 'Normals',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Normal Edit', label: 'Normal Edit'),
          BlenderMenuItem<String>(
            value: 'Weighted Normal',
            label: 'Weighted Normal',
          ),
        ],
      ),
      BlenderMenuItem<String>(
        value: 'Physics',
        label: 'Physics',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Cloth', label: 'Cloth'),
          BlenderMenuItem<String>(value: 'Collision', label: 'Collision'),
          BlenderMenuItem<String>(value: 'Fluid', label: 'Fluid'),
          BlenderMenuItem<String>(value: 'Soft Body', label: 'Soft Body'),
        ],
      ),
      BlenderMenuItem<String>(
        value: 'Color',
        label: 'Color',
        submenu: <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Tint', label: 'Tint'),
          BlenderMenuItem<String>(value: 'Opacity', label: 'Opacity'),
        ],
      ),
    ];

    return BlenderScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderMenuButton<String>(
            label: 'Add Modifier',
            items: addModifierItems,
            onSelected: (value) => _setStatus('Add $value modifier'),
          ),
          const SizedBox(height: 8),
          BlenderModifierStack(
            title: title,
            modifiers: <BlenderModifierDescriptor>[
              BlenderModifierDescriptor(
                id: 'bevel',
                name: 'Bevel',
                icon: BlenderGlyph.modifier,
                child: Column(
                  children: <Widget>[
                    BlenderPropertyRow(
                      label: 'Amount',
                      editor: BlenderNumberField(
                        value: .1,
                        min: 0,
                        max: 1,
                        step: .01,
                        onChanged: (_) {},
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Segments',
                      editor: BlenderNumberField(
                        value: 3,
                        min: 1,
                        max: 32,
                        decimalDigits: 0,
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Toggle Bevel'),
                onToggleViewport: () => _setStatus('Toggle Bevel viewport'),
                onToggleRender: () => _setStatus('Toggle Bevel render'),
                onMoveUp: () => _setStatus('Move Bevel up'),
                onMoveDown: () => _setStatus('Move Bevel down'),
                onRemove: () => _setStatus('Remove Bevel'),
              ),
              BlenderModifierDescriptor(
                id: 'subdivision-surface',
                name: 'Subdivision Surface',
                icon: BlenderGlyph.modifier,
                initiallyExpanded: false,
                child: BlenderPropertyRow(
                  label: 'Levels Viewport',
                  editor: BlenderNumberField(
                    value: 2,
                    min: 0,
                    max: 6,
                    decimalDigits: 0,
                    onChanged: (_) {},
                  ),
                ),
                onToggleEnabled: () => _setStatus('Toggle Subdivision'),
                onToggleViewport: () =>
                    _setStatus('Toggle Subdivision viewport'),
                onToggleRender: () => _setStatus('Toggle Subdivision render'),
                onRemove: () => _setStatus('Remove Subdivision'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintPropertiesBody({String title = 'Object Constraints'}) {
    Widget numberRow(
      String label,
      double value, {
      double min = 0,
      double max = 1,
    }) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderNumberField(
          value: value,
          min: min,
          max: max,
          step: .01,
          onChanged: (_) {},
        ),
      );
    }

    Widget dropdownRow(
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyRow(
        label: label,
        editor: BlenderDropdown<String>(
          value: value,
          items: items,
          onChanged: (_) {},
        ),
      );
    }

    final isBoneConstraint = title == 'Bone Constraints';
    final addLabel = isBoneConstraint
        ? 'Add Bone Constraint'
        : 'Add Object Constraint';
    final addItems = <BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Copy Location',
        label: 'Copy Location',
      ),
      const BlenderMenuItem<String>(value: 'Child Of', label: 'Child Of'),
      const BlenderMenuItem<String>(value: 'Follow Path', label: 'Follow Path'),
      const BlenderMenuItem<String>(
        value: 'Limit Rotation',
        label: 'Limit Rotation',
      ),
      const BlenderMenuItem<String>(value: 'Armature', label: 'Armature'),
    ];

    return BlenderScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderMenuButton<String>(
            label: addLabel,
            items: addItems,
            onSelected: (value) => _setStatus('Add $value constraint'),
          ),
          const SizedBox(height: 6),
          BlenderConstraintStack(
            title: title,
            actionSize: 17,
            constraints: <BlenderConstraintDescriptor>[
              BlenderConstraintDescriptor(
                id: 'constraint-copy-location',
                name: 'Copy Location',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    dropdownRow('Target', 'Camera', const <
                      BlenderMenuItem<String>
                    >[
                      BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
                      BlenderMenuItem<String>(value: 'Light', label: 'Light'),
                    ]),
                    numberRow('Influence', .75),
                    const BlenderPropertyRow(
                      label: 'Axes',
                      editor: Text('X  Y  Z'),
                    ),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Copy Location toggled'),
                onMenu: () => _setStatus('Copy Location menu'),
                onRemove: () => _setStatus('Copy Location removed'),
              ),
              BlenderConstraintDescriptor(
                id: 'constraint-child-of',
                name: 'Child Of',
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    dropdownRow('Target', 'Empty', const <
                      BlenderMenuItem<String>
                    >[
                      BlenderMenuItem<String>(value: 'Empty', label: 'Empty'),
                      BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
                    ]),
                    numberRow('Influence', 1),
                    numberRow('Location', 0, min: -10, max: 10),
                    numberRow('Rotation', 0, min: -180, max: 180),
                    numberRow('Scale', 1, min: 0, max: 10),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Child Of toggled'),
                onMenu: () => _setStatus('Child Of menu'),
                onRemove: () => _setStatus('Child Of removed'),
              ),
              BlenderConstraintDescriptor(
                id: 'constraint-follow-path',
                name: 'Follow Path',
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    dropdownRow(
                      'Target',
                      'BezierCurve',
                      const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(
                          value: 'BezierCurve',
                          label: 'BezierCurve',
                        ),
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                      ],
                    ),
                    numberRow('Offset', 0, min: -100, max: 100),
                    numberRow('Influence', 1),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Follow Path toggled'),
                onMenu: () => _setStatus('Follow Path menu'),
                onRemove: () => _setStatus('Follow Path removed'),
              ),
              BlenderConstraintDescriptor(
                id: 'constraint-limit-rotation',
                name: 'Limit Rotation',
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const BlenderPropertyRow(
                      label: 'Owner Space',
                      editor: Text('World Space'),
                    ),
                    numberRow('X Min', -1, min: -3.14, max: 3.14),
                    numberRow('X Max', 1, min: -3.14, max: 3.14),
                    numberRow('Influence', 1),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Limit Rotation toggled'),
                onMenu: () => _setStatus('Limit Rotation menu'),
                onRemove: () => _setStatus('Limit Rotation removed'),
              ),
              BlenderConstraintDescriptor(
                id: 'constraint-armature',
                name: 'Armature',
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    dropdownRow(
                      'Target',
                      'Armature',
                      const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(
                          value: 'Armature',
                          label: 'Armature',
                        ),
                        BlenderMenuItem<String>(value: 'None', label: 'None'),
                      ],
                    ),
                    numberRow('Influence', 1),
                  ],
                ),
                onToggleEnabled: () =>
                    _setStatus('Armature constraint toggled'),
                onMenu: () => _setStatus('Armature constraint menu'),
                onRemove: () => _setStatus('Armature constraint removed'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShaderFxPropertiesBody() {
    const effectItems = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Drop Shadow', label: 'Drop Shadow'),
      BlenderMenuItem<String>(value: 'Colorize', label: 'Colorize'),
      BlenderMenuItem<String>(value: 'Glow', label: 'Glow'),
      BlenderMenuItem<String>(value: 'Wave', label: 'Wave'),
      BlenderMenuItem<String>(value: 'Pixelate', label: 'Pixelate'),
    ];
    return BlenderScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderMenuButton<String>(
            label: 'Add Effect',
            items: effectItems,
            onSelected: (value) => _setStatus('Add $value effect'),
          ),
          const SizedBox(height: 6),
          BlenderShaderEffectStack(
            title: 'Effects',
            effects: <BlenderShaderEffectDescriptor>[
              BlenderShaderEffectDescriptor(
                id: 'shaderfx-drop-shadow',
                name: 'Drop Shadow',
                icon: BlenderGlyph.shaderfx,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    BlenderPropertyRow(
                      label: 'Opacity',
                      editor: BlenderNumberField(
                        value: .5,
                        min: 0,
                        max: 1,
                        step: .01,
                        onChanged: (_) {},
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Offset X',
                      editor: BlenderNumberField(
                        value: 4,
                        decimalDigits: 1,
                        onChanged: (_) {},
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Offset Y',
                      editor: BlenderNumberField(
                        value: -4,
                        decimalDigits: 1,
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Shader effect toggled'),
                onMoveUp: () => _setStatus('Shader effect moved up'),
                onMoveDown: () => _setStatus('Shader effect moved down'),
                onRemove: () => _setStatus('Shader effect removed'),
              ),
              BlenderShaderEffectDescriptor(
                id: 'shaderfx-colorize',
                name: 'Colorize',
                icon: BlenderGlyph.color,
                initiallyExpanded: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    BlenderPropertyRow(
                      label: 'Factor',
                      editor: BlenderNumberField(
                        value: .8,
                        min: 0,
                        max: 1,
                        step: .01,
                        onChanged: (_) {},
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Blend Mode',
                      editor: BlenderDropdown<String>(
                        value: 'Multiply',
                        items: const <BlenderMenuItem<String>>[
                          BlenderMenuItem<String>(
                            value: 'Multiply',
                            label: 'Multiply',
                          ),
                          BlenderMenuItem<String>(
                            value: 'Screen',
                            label: 'Screen',
                          ),
                        ],
                        onChanged: (_) {},
                      ),
                    ),
                  ],
                ),
                onToggleEnabled: () => _setStatus('Colorize toggled'),
                onMoveUp: () => _setStatus('Colorize moved up'),
                onMoveDown: () => _setStatus('Colorize moved down'),
                onRemove: () => _setStatus('Colorize removed'),
              ),
            ],
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
                    topContent:
                        _propertyTab == 1 ||
                            _propertyTab == 4 ||
                            _propertyTab == 5 ||
                            _propertyTab == 7 ||
                            _propertyTab == 13 ||
                            _propertyTab == 16 ||
                            _propertyTab == 3 ||
                            _propertyTab == 6 ||
                            _propertyTab == 17 ||
                            _propertyTab == 10 ||
                            _propertyTab == 14
                        ? _propertyTopContent
                        : null,
                    body: _propertyTab == 18
                        ? const BlenderStripProperties()
                        : _propertyTab == 15
                        ? _buildConstraintPropertiesBody(
                            title: 'Bone Constraints',
                          )
                        : _propertyTab == 12
                        ? _buildConstraintPropertiesBody()
                        : _propertyTab == 9
                        ? _buildShaderFxPropertiesBody()
                        : _propertyTab == 19
                        ? _buildModifierPropertiesBody(title: 'Strip Modifiers')
                        : _propertyTab == 8
                        ? _buildModifierPropertiesBody()
                        : _propertyTab == 0
                        ? _buildToolSettingsBody()
                        : null,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimationPopoverPanel(String title, List<Widget> children) {
    return SizedBox(
      width: 280,
      child: BlenderPanel(
        title: title,
        initiallyExpanded: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  Widget _buildAnimationFiltersPopover() {
    return _buildAnimationPopoverPanel('Filters', <Widget>[
      BlenderCheckbox(
        value: true,
        label: 'Summary',
        onChanged: (value) =>
            _setStatus('Summary filter ${value ? 'on' : 'off'}'),
      ),
      BlenderCheckbox(
        value: _animationSelectedOnly,
        label: 'Only Selected',
        onChanged: (value) => setState(() => _animationSelectedOnly = value),
      ),
      BlenderCheckbox(
        value: false,
        label: 'Show Hidden',
        onChanged: (value) => _setStatus('Hidden-channel filter toggled'),
      ),
      BlenderCheckbox(
        value: _animationShowErrors,
        label: 'Only Errors',
        onChanged: (value) => setState(() => _animationShowErrors = value),
      ),
      const BlenderSeparator(),
      const Text('Filter by Type'),
      BlenderCheckbox(
        value: true,
        label: 'Scenes',
        onChanged: (value) => _setStatus('Scene filter toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Objects',
        onChanged: (value) => _setStatus('Object filter toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Materials',
        onChanged: (value) => _setStatus('Material filter toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Transforms',
        onChanged: (value) => _setStatus('Transform filter toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Modifiers',
        onChanged: (value) => _setStatus('Modifier filter toggled'),
      ),
    ]);
  }

  Widget _buildAnimationSnappingPopover() {
    return _buildAnimationPopoverPanel('Snapping', <Widget>[
      const Text('Snap To'),
      BlenderDropdown<String>(
        value: 'Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
          BlenderMenuItem<String>(value: 'Second', label: 'Second'),
          BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
          BlenderMenuItem<String>(
            value: 'Absolute Time',
            label: 'Absolute Time',
          ),
        ],
        onChanged: (value) => _setStatus('Snap to $value'),
      ),
      const SizedBox(height: 6),
      BlenderCheckbox(
        value: false,
        label: 'Absolute Time',
        onChanged: (value) => _setStatus('Absolute snap toggled'),
      ),
      BlenderCheckbox(
        value: false,
        label: 'Snap Playhead',
        onChanged: (value) => _setStatus('Playhead snap toggled'),
      ),
    ]);
  }

  Widget _buildAnimationOverlayPopover() {
    return _buildAnimationPopoverPanel('Overlays', <Widget>[
      BlenderCheckbox(
        value: _animationOverlays,
        label: 'Show Overlays',
        onChanged: (value) => setState(() => _animationOverlays = value),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Show Markers',
        onChanged: (value) => _setStatus('Markers toggled'),
      ),
      BlenderCheckbox(
        value: _animationShowSeconds,
        label: 'Show Seconds',
        onChanged: (value) => setState(() => _animationShowSeconds = value),
      ),
      BlenderCheckbox(
        value: _animationShowLockedTime,
        label: 'Show Locked Time',
        onChanged: (value) => setState(() => _animationShowLockedTime = value),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Only Selected Keys',
        onChanged: (value) => _setStatus('Selected keys toggled'),
      ),
    ]);
  }

  Widget _buildProportionalEditingPopover() {
    return _buildAnimationPopoverPanel('Proportional Editing', <Widget>[
      BlenderDropdown<String>(
        value: 'Connected',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Connected', label: 'Connected'),
          BlenderMenuItem<String>(value: 'Projected', label: 'Projected'),
        ],
        onChanged: (value) => _setStatus('Proportional falloff $value'),
      ),
      const SizedBox(height: 6),
      BlenderNumberField(
        value: 1,
        min: 0,
        max: 10,
        step: .1,
        label: 'Size',
        onChanged: (_) {},
      ),
    ]);
  }

  List<BlenderMenuItem<String>> _animationViewMenuItems({
    required bool timeline,
  }) {
    if (timeline) {
      return <BlenderMenuItem<String>>[
        const BlenderMenuItem<String>(
          value: 'Show Region UI',
          label: 'Show Region UI',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Region HUD',
          label: 'Show Region HUD',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Region Channels',
          label: 'Show Region Channels',
        ),
        const BlenderMenuItem<String>(
          value: 'Playback Controls',
          label: 'Playback Controls',
        ),
        const BlenderMenuItem<String>(value: 'Frame All', label: 'Frame All'),
        const BlenderMenuItem<String>(
          value: 'Frame Scene Range',
          label: 'Frame Scene Range',
        ),
        const BlenderMenuItem<String>(value: 'View Frame', label: 'View Frame'),
        const BlenderMenuItem<String>(
          value: 'Show Markers',
          label: 'Show Markers',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Seconds',
          label: 'Show Seconds',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Locked Time',
          label: 'Show Locked Time',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Only Selected',
          label: 'Show Only Selected',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Errors',
          label: 'Show Errors',
        ),
        const BlenderMenuItem<String>(value: 'Cache', label: 'Cache'),
        const BlenderMenuItem<String>(value: 'Area', label: 'Area'),
      ];
    }
    return <BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Show Region UI',
        label: 'Show Region UI',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Region HUD',
        label: 'Show Region HUD',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Region Channels',
        label: 'Show Region Channels',
      ),
      const BlenderMenuItem<String>(
        value: 'Playback Controls',
        label: 'Playback Controls',
      ),
      const BlenderMenuItem<String>(
        value: 'View Selected',
        label: 'View Selected',
      ),
      const BlenderMenuItem<String>(value: 'Frame All', label: 'View All'),
      const BlenderMenuItem<String>(
        value: 'Frame Scene Range',
        label: 'Frame Scene Range',
      ),
      const BlenderMenuItem<String>(value: 'View Frame', label: 'View Frame'),
      const BlenderMenuItem<String>(
        value: 'Multi-Word Match Search',
        label: 'Multi-Word Match Search',
      ),
      const BlenderMenuItem<String>(
        value: 'Realtime Update',
        label: 'Realtime Update',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Sliders',
        label: 'Show Sliders',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Interpolation',
        label: 'Show Interpolation',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Extremes',
        label: 'Show Extremes',
      ),
      const BlenderMenuItem<String>(
        value: 'Auto Merge Keyframes',
        label: 'Auto Merge Keyframes',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Markers',
        label: 'Show Markers',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Seconds',
        label: 'Show Seconds',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Locked Time',
        label: 'Show Locked Time',
      ),
      const BlenderMenuItem<String>(
        value: 'Set Preview Range',
        label: 'Set Preview Range',
      ),
      const BlenderMenuItem<String>(
        value: 'Clear Preview Range',
        label: 'Clear Preview Range',
      ),
      const BlenderMenuItem<String>(
        value: 'Toggle Graph Editor',
        label: 'Toggle Graph Editor',
      ),
      const BlenderMenuItem<String>(value: 'Cache', label: 'Cache'),
      const BlenderMenuItem<String>(value: 'Area', label: 'Area'),
    ];
  }

  List<BlenderMenuItem<String>> _animationMarkerMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Lock Markers', label: 'Lock Markers'),
        BlenderMenuItem<String>(
          value: 'Jump to Previous Marker',
          label: 'Jump to Previous Marker',
        ),
        BlenderMenuItem<String>(
          value: 'Jump to Next Marker',
          label: 'Jump to Next Marker',
        ),
        BlenderMenuItem<String>(
          value: 'Bind Camera to Marker',
          label: 'Bind Camera to Marker',
        ),
        BlenderMenuItem<String>(value: 'Select Marker', label: 'Select Marker'),
        BlenderMenuItem<String>(value: 'Move Marker', label: 'Move Marker'),
        BlenderMenuItem<String>(value: 'Rename Marker', label: 'Rename Marker'),
        BlenderMenuItem<String>(value: 'Delete Marker', label: 'Delete Marker'),
        BlenderMenuItem<String>(
          value: 'Duplicate Marker',
          label: 'Duplicate Marker',
        ),
        BlenderMenuItem<String>(value: 'Add Marker', label: 'Add Marker'),
      ];

  List<BlenderMenuItem<String>> _animationSelectMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'All', label: 'All'),
        BlenderMenuItem<String>(value: 'None', label: 'None'),
        BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
        BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
        BlenderMenuItem<String>(
          value: 'Box Select (Axis Range)',
          label: 'Box Select (Axis Range)',
        ),
        BlenderMenuItem<String>(value: 'Circle Select', label: 'Circle Select'),
        BlenderMenuItem<String>(value: 'Lasso Select', label: 'Lasso Select'),
        BlenderMenuItem<String>(value: 'More', label: 'More'),
        BlenderMenuItem<String>(value: 'Less', label: 'Less'),
        BlenderMenuItem<String>(value: 'Select Linked', label: 'Select Linked'),
        BlenderMenuItem<String>(
          value: 'Select by Type',
          label: 'Select by Type',
        ),
        BlenderMenuItem<String>(
          value: 'Columns on Selected Keys',
          label: 'Columns on Selected Keys',
        ),
        BlenderMenuItem<String>(
          value: 'Before Current Frame',
          label: 'Before Current Frame',
        ),
        BlenderMenuItem<String>(
          value: 'After Current Frame',
          label: 'After Current Frame',
        ),
      ];

  List<BlenderMenuItem<String>>
  _animationChannelMenuItems() => const <BlenderMenuItem<String>>[
    BlenderMenuItem<String>(value: 'Delete Channels', label: 'Delete Channels'),
    BlenderMenuItem<String>(value: 'Clean Channels', label: 'Clean Channels'),
    BlenderMenuItem<String>(value: 'Group Channels', label: 'Group Channels'),
    BlenderMenuItem<String>(
      value: 'Ungroup Channels',
      label: 'Ungroup Channels',
    ),
    BlenderMenuItem<String>(
      value: 'Toggle Channel Setting',
      label: 'Toggle Channel Setting',
    ),
    BlenderMenuItem<String>(
      value: 'Enable Channel Setting',
      label: 'Enable Channel Setting',
    ),
    BlenderMenuItem<String>(
      value: 'Disable Channel Setting',
      label: 'Disable Channel Setting',
    ),
    BlenderMenuItem<String>(value: 'Toggle Editable', label: 'Toggle Editable'),
    BlenderMenuItem<String>(
      value: 'Extrapolation Mode',
      label: 'Extrapolation Mode',
    ),
    BlenderMenuItem<String>(value: 'Expand Channels', label: 'Expand Channels'),
    BlenderMenuItem<String>(
      value: 'Collapse Channels',
      label: 'Collapse Channels',
    ),
    BlenderMenuItem<String>(value: 'Move Channels', label: 'Move Channels'),
    BlenderMenuItem<String>(value: 'Bake Channels', label: 'Bake Channels'),
    BlenderMenuItem<String>(
      value: 'View Selected Channels',
      label: 'View Selected Channels',
    ),
  ];

  List<BlenderMenuItem<String>>
  _animationKeyMenuItems() => const <BlenderMenuItem<String>>[
    BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
    BlenderMenuItem<String>(value: 'Mirror', label: 'Mirror'),
    BlenderMenuItem<String>(value: 'Snap', label: 'Snap'),
    BlenderMenuItem<String>(
      value: 'Jump to Selected',
      label: 'Jump to Selected',
    ),
    BlenderMenuItem<String>(value: 'Copy', label: 'Copy'),
    BlenderMenuItem<String>(value: 'Paste', label: 'Paste'),
    BlenderMenuItem<String>(value: 'Paste Flipped', label: 'Paste Flipped'),
    BlenderMenuItem<String>(value: 'Insert Keyframe', label: 'Insert Keyframe'),
    BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
    BlenderMenuItem<String>(value: 'Keyframe Type', label: 'Keyframe Type'),
    BlenderMenuItem<String>(value: 'Handle Type', label: 'Handle Type'),
    BlenderMenuItem<String>(
      value: 'Interpolation Mode',
      label: 'Interpolation Mode',
    ),
    BlenderMenuItem<String>(value: 'Easing Mode', label: 'Easing Mode'),
    BlenderMenuItem<String>(value: 'Clean Keyframes', label: 'Clean Keyframes'),
    BlenderMenuItem<String>(value: 'Bake Keyframes', label: 'Bake Keyframes'),
    BlenderMenuItem<String>(
      value: 'Discontinuity (Euler) Filter',
      label: 'Discontinuity (Euler) Filter',
    ),
    BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
  ];

  List<BlenderMenuItem<String>>
  _animationActionMenuItems() => const <BlenderMenuItem<String>>[
    BlenderMenuItem<String>(value: 'Merge Animation', label: 'Merge Animation'),
    BlenderMenuItem<String>(value: 'Separate Slots', label: 'Separate Slots'),
    BlenderMenuItem<String>(value: 'Replace Action', label: 'Replace Action'),
    BlenderMenuItem<String>(
      value: 'Replace Action New',
      label: 'Replace Action New',
    ),
    BlenderMenuItem<String>(
      value: 'Replace Action Duplicate',
      label: 'Replace Action Duplicate',
    ),
    BlenderMenuItem<String>(
      value: 'Move Channels to New Action',
      label: 'Move Channels to New Action',
    ),
    BlenderMenuItem<String>(
      value: 'Push Down Action',
      label: 'Push Down Action',
    ),
    BlenderMenuItem<String>(value: 'Stash Action', label: 'Stash Action'),
  ];

  Widget _buildAnimationPlaybackPopover() {
    return _buildAnimationPopoverPanel('Playback', <Widget>[
      BlenderDropdown<String>(
        value: 'Play Every Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Play Every Frame',
            label: 'Play Every Frame',
          ),
          BlenderMenuItem<String>(
            value: 'Frame Dropping',
            label: 'Frame Dropping',
          ),
        ],
        onChanged: (value) => _setStatus('Playback sync $value'),
      ),
      const SizedBox(height: 6),
      BlenderCheckbox(
        value: true,
        label: 'Audio Scrubbing',
        onChanged: (value) => _setStatus('Audio scrubbing toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Use Audio',
        onChanged: (value) => _setStatus('Audio playback toggled'),
      ),
      BlenderCheckbox(
        value: false,
        label: 'Limit to Frame Range',
        onChanged: (value) => _setStatus('Frame range limit toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Follow Current Frame',
        onChanged: (value) => _setStatus('Follow current frame toggled'),
      ),
      BlenderDropdown<String>(
        value: 'Cycle',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Cycle', label: 'Cycle'),
          BlenderMenuItem<String>(value: 'Hold', label: 'Hold'),
          BlenderMenuItem<String>(value: 'Ping-Pong', label: 'Ping-Pong'),
        ],
        onChanged: (value) => _setStatus('Playback loop $value'),
      ),
    ]);
  }

  Widget _buildAnimationAutoKeyingPopover() {
    return _buildAnimationPopoverPanel('Auto Keying', <Widget>[
      BlenderSegmentedControl<String>(
        value: 'Add & Replace',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Add & Replace',
            label: 'Add & Replace',
          ),
          BlenderMenuItem<String>(value: 'Replace', label: 'Replace'),
        ],
        onChanged: (value) => _setStatus('Auto keying mode $value'),
      ),
      const SizedBox(height: 6),
      BlenderCheckbox(
        value: false,
        label: 'Only Active Keying Set',
        onChanged: (value) =>
            _setStatus('Active keying set restriction toggled'),
      ),
      BlenderCheckbox(
        value: false,
        label: 'Layered Recording',
        onChanged: (value) => _setStatus('Layered recording toggled'),
      ),
    ]);
  }

  Widget _buildAnimationTimeJumpPopover() {
    return _buildAnimationPopoverPanel('Time Jump', <Widget>[
      const Text('Jump Unit'),
      BlenderSegmentedControl<String>(
        value: 'Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
          BlenderMenuItem<String>(value: 'Second', label: 'Second'),
        ],
        onChanged: (value) => _setStatus('Jump unit $value'),
      ),
      const SizedBox(height: 6),
      BlenderNumberField(
        value: 1,
        min: 1,
        max: 120,
        step: 1,
        decimalDigits: 0,
        label: 'Delta',
        onChanged: (value) => _setStatus('Jump delta $value'),
      ),
    ]);
  }

  Widget _buildAnimationPlayheadSnappingPopover() {
    return _buildAnimationPopoverPanel('Playhead', <Widget>[
      BlenderNumberField(
        value: 2,
        min: 0,
        max: 20,
        step: 1,
        decimalDigits: 0,
        label: 'Snap Distance',
        onChanged: (_) {},
      ),
      const SizedBox(height: 6),
      const Text('Snap Target'),
      BlenderSegmentedControl<String>(
        value: 'Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
          BlenderMenuItem<String>(value: 'Second', label: 'Second'),
          BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
        ],
        onChanged: (value) => _setStatus('Playhead snap target $value'),
      ),
      const SizedBox(height: 6),
      BlenderNumberField(
        value: 1,
        min: 1,
        max: 120,
        step: 1,
        decimalDigits: 0,
        label: 'Frame Step',
        onChanged: (_) {},
      ),
    ]);
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
            if (_bottomTab <= 1) ...<Widget>[
              BlenderMenuButton<String>(
                key: const ValueKey<String>('animation-view-menu'),
                label: 'View',
                items: _animationViewMenuItems(timeline: _bottomTab == 0),
                onSelected: _setStatus,
              ),
              BlenderMenuButton<String>(
                key: const ValueKey<String>('animation-marker-menu'),
                label: 'Marker',
                items: _animationMarkerMenuItems(),
                onSelected: _setStatus,
              ),
              if (_bottomTab == 1) ...<Widget>[
                BlenderMenuButton<String>(
                  key: const ValueKey<String>('animation-select-menu'),
                  label: 'Select',
                  items: _animationSelectMenuItems(),
                  onSelected: _setStatus,
                ),
                BlenderMenuButton<String>(
                  key: const ValueKey<String>('animation-channel-menu'),
                  label: 'Channel',
                  items: _animationChannelMenuItems(),
                  onSelected: _setStatus,
                ),
                BlenderMenuButton<String>(
                  key: const ValueKey<String>('animation-key-menu'),
                  label: 'Key',
                  items: _animationKeyMenuItems(),
                  onSelected: _setStatus,
                ),
                BlenderMenuButton<String>(
                  key: const ValueKey<String>('animation-action-menu'),
                  label: 'Action',
                  items: _animationActionMenuItems(),
                  onSelected: _setStatus,
                ),
              ],
            ],
            if (_bottomTab == 1) ...<Widget>[
              BlenderPopover(
                child: const BlenderIconButton(
                  key: ValueKey<String>('animation-filters-button'),
                  glyph: BlenderGlyph.filter,
                  tooltip: 'Animation filters',
                  size: 24,
                ),
                popover: (context, close) => _buildAnimationFiltersPopover(),
              ),
              BlenderPopover(
                child: BlenderIconButton(
                  key: const ValueKey<String>('animation-snapping-button'),
                  glyph: BlenderGlyph.snap,
                  selected: _animationPlayheadSnap,
                  tooltip: 'Animation snapping',
                  size: 24,
                ),
                popover: (context, close) => _buildAnimationSnappingPopover(),
              ),
            ],
            if (_bottomTab == 1) ...<Widget>[
              BlenderPopover(
                child: BlenderIconButton(
                  key: const ValueKey<String>('animation-proportional-button'),
                  glyph: BlenderGlyph.transform,
                  selected: _animationProportional,
                  tooltip: 'Proportional editing',
                  size: 24,
                ),
                popover: (context, close) => _buildProportionalEditingPopover(),
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
            if (_bottomTab == 0) ...<Widget>[
              BlenderPopover(
                child: const BlenderButton(
                  key: ValueKey<String>('animation-playback-button'),
                  label: 'Playback',
                  variant: BlenderButtonVariant.topBar,
                ),
                popover: (context, close) => _buildAnimationPlaybackPopover(),
              ),
              BlenderPopover(
                child: BlenderIconButton(
                  key: const ValueKey<String>('animation-autokey-button'),
                  glyph: BlenderGlyph.keyframe,
                  selected: _animationAutoKeying,
                  tooltip: 'Auto Keying',
                  size: 24,
                ),
                popover: (context, close) => _buildAnimationAutoKeyingPopover(),
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
              BlenderTimeJumpControls(
                key: const ValueKey<String>('animation-time-jump-controls'),
                onBackward: () => setState(
                  () => _frame = (_frame - 1).clamp(1, 120).toDouble(),
                ),
                onForward: () => setState(
                  () => _frame = (_frame + 1).clamp(1, 120).toDouble(),
                ),
                popover: (context, close) => _buildAnimationTimeJumpPopover(),
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
              BlenderPopover(
                child: BlenderIconButton(
                  key: const ValueKey<String>(
                    'animation-playhead-snapping-button',
                  ),
                  glyph: BlenderGlyph.snap,
                  selected: _animationPlayheadSnap,
                  tooltip: 'Playhead snapping',
                  size: 24,
                ),
                popover: (context, close) =>
                    _buildAnimationPlayheadSnappingPopover(),
              ),
            ],
            if (_bottomTab <= 1)
              BlenderPopover(
                child: BlenderIconButton(
                  key: const ValueKey<String>('animation-overlay-button'),
                  glyph: BlenderGlyph.overlay,
                  selected: _animationOverlays,
                  tooltip: 'Animation overlays',
                  size: 24,
                ),
                popover: (context, close) => _buildAnimationOverlayPopover(),
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

  List<BlenderMenuItem<String>> _graphViewMenuItems({
    required bool drivers,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(
      value: 'Show Region UI',
      label: 'Show Region UI',
    ),
    const BlenderMenuItem<String>(
      value: 'Show Region HUD',
      label: 'Show Region HUD',
    ),
    const BlenderMenuItem<String>(
      value: 'Show Region Channels',
      label: 'Show Region Channels',
    ),
    if (!drivers)
      const BlenderMenuItem<String>(
        value: 'Playback Controls',
        label: 'Playback Controls',
      ),
    const BlenderMenuItem<String>(
      value: 'View Selected',
      label: 'View Selected',
    ),
    const BlenderMenuItem<String>(value: 'View All', label: 'View All'),
    const BlenderMenuItem<String>(value: 'Local View', label: 'Local View'),
    const BlenderMenuItem<String>(
      value: 'Frame Scene Range',
      label: 'Frame Scene Range',
    ),
    const BlenderMenuItem<String>(value: 'View Frame', label: 'View Frame'),
    const BlenderMenuItem<String>(
      value: 'Realtime Update',
      label: 'Realtime Update',
    ),
    const BlenderMenuItem<String>(value: 'Show Sliders', label: 'Show Sliders'),
    const BlenderMenuItem<String>(
      value: 'Auto Merge Keyframes',
      label: 'Auto Merge Keyframes',
    ),
    const BlenderMenuItem<String>(
      value: 'Auto Lock Translation Axis',
      label: 'Auto Lock Translation Axis',
    ),
    if (!drivers)
      const BlenderMenuItem<String>(
        value: 'Show Markers',
        label: 'Show Markers',
      ),
    const BlenderMenuItem<String>(value: 'Show Cursor', label: 'Show Cursor'),
    const BlenderMenuItem<String>(value: 'Show Seconds', label: 'Show Seconds'),
    const BlenderMenuItem<String>(
      value: 'Show Locked Time',
      label: 'Show Locked Time',
    ),
    const BlenderMenuItem<String>(
      value: 'Show Extrapolation',
      label: 'Show Extrapolation',
    ),
    const BlenderMenuItem<String>(value: 'Show Handles', label: 'Show Handles'),
    const BlenderMenuItem<String>(
      value: 'Only Selected Keyframe Handles',
      label: 'Only Selected Keyframe Handles',
    ),
    const BlenderMenuItem<String>(
      value: 'Set Preview Range',
      label: 'Set Preview Range',
    ),
    const BlenderMenuItem<String>(
      value: 'Clear Preview Range',
      label: 'Clear Preview Range',
    ),
    const BlenderMenuItem<String>(
      value: 'Toggle Dope Sheet',
      label: 'Toggle Dope Sheet',
    ),
    const BlenderMenuItem<String>(value: 'Area', label: 'Area'),
  ];

  List<BlenderMenuItem<String>> _graphSelectMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'All', label: 'All'),
        BlenderMenuItem<String>(value: 'None', label: 'None'),
        BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
        BlenderMenuItem<String>(
          value: 'Box Select (Include Handles)',
          label: 'Box Select (Include Handles)',
        ),
        BlenderMenuItem<String>(
          value: 'Box Select (Axis Range)',
          label: 'Box Select (Axis Range)',
        ),
        BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
        BlenderMenuItem<String>(value: 'Circle Select', label: 'Circle Select'),
        BlenderMenuItem<String>(value: 'Lasso Select', label: 'Lasso Select'),
        BlenderMenuItem<String>(value: 'More', label: 'More'),
        BlenderMenuItem<String>(value: 'Less', label: 'Less'),
        BlenderMenuItem<String>(value: 'Select Linked', label: 'Select Linked'),
        BlenderMenuItem<String>(
          value: 'Columns on Selected Keys',
          label: 'Columns on Selected Keys',
        ),
        BlenderMenuItem<String>(
          value: 'Column on Current Frame',
          label: 'Column on Current Frame',
        ),
        BlenderMenuItem<String>(
          value: 'Before Current Frame',
          label: 'Before Current Frame',
        ),
        BlenderMenuItem<String>(
          value: 'After Current Frame',
          label: 'After Current Frame',
        ),
        BlenderMenuItem<String>(
          value: 'Select Handles',
          label: 'Select Handles',
        ),
        BlenderMenuItem<String>(value: 'Select Key', label: 'Select Key'),
      ];

  List<BlenderMenuItem<String>> _graphChannelMenuItems({
    required bool drivers,
  }) => <BlenderMenuItem<String>>[
    const BlenderMenuItem<String>(
      value: 'Delete Channels',
      label: 'Delete Channels',
    ),
    if (drivers)
      const BlenderMenuItem<String>(
        value: 'Delete Invalid Drivers',
        label: 'Delete Invalid Drivers',
      ),
    const BlenderMenuItem<String>(
      value: 'Group Channels',
      label: 'Group Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Ungroup Channels',
      label: 'Ungroup Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Toggle Channel Setting',
      label: 'Toggle Channel Setting',
    ),
    const BlenderMenuItem<String>(
      value: 'Enable Channel Setting',
      label: 'Enable Channel Setting',
    ),
    const BlenderMenuItem<String>(
      value: 'Disable Channel Setting',
      label: 'Disable Channel Setting',
    ),
    const BlenderMenuItem<String>(
      value: 'Toggle Editable',
      label: 'Toggle Editable',
    ),
    const BlenderMenuItem<String>(
      value: 'Extrapolation Mode',
      label: 'Extrapolation Mode',
    ),
    const BlenderMenuItem<String>(
      value: 'Add F-Curve Modifier',
      label: 'Add F-Curve Modifier',
    ),
    const BlenderMenuItem<String>(
      value: 'Delete F-Curve Modifiers',
      label: 'Delete F-Curve Modifiers',
    ),
    const BlenderMenuItem<String>(
      value: 'Hide Selected Curves',
      label: 'Hide Selected Curves',
    ),
    const BlenderMenuItem<String>(
      value: 'Hide Unselected Curves',
      label: 'Hide Unselected Curves',
    ),
    const BlenderMenuItem<String>(value: 'Reveal', label: 'Reveal'),
    const BlenderMenuItem<String>(
      value: 'Expand Channels',
      label: 'Expand Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Collapse Channels',
      label: 'Collapse Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Move Channels',
      label: 'Move Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Keys to Samples',
      label: 'Keys to Samples',
    ),
    const BlenderMenuItem<String>(
      value: 'Samples to Keys',
      label: 'Samples to Keys',
    ),
    const BlenderMenuItem<String>(
      value: 'Sound to Samples',
      label: 'Sound to Samples',
    ),
    const BlenderMenuItem<String>(
      value: 'Bake Channels',
      label: 'Bake Channels',
    ),
    const BlenderMenuItem<String>(
      value: 'Discontinuity (Euler) Filter',
      label: 'Discontinuity (Euler) Filter',
    ),
    const BlenderMenuItem<String>(
      value: 'View Selected Channels',
      label: 'View Selected Channels',
    ),
  ];

  List<BlenderMenuItem<String>> _graphKeyMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
        BlenderMenuItem<String>(value: 'Snap', label: 'Snap'),
        BlenderMenuItem<String>(value: 'Mirror', label: 'Mirror'),
        BlenderMenuItem<String>(
          value: 'Jump to Selected',
          label: 'Jump to Selected',
        ),
        BlenderMenuItem<String>(value: 'Copy', label: 'Copy'),
        BlenderMenuItem<String>(value: 'Paste', label: 'Paste'),
        BlenderMenuItem<String>(value: 'Paste Flipped', label: 'Paste Flipped'),
        BlenderMenuItem<String>(value: 'Insert', label: 'Insert'),
        BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
        BlenderMenuItem<String>(value: 'Handle Type', label: 'Handle Type'),
        BlenderMenuItem<String>(
          value: 'Interpolation Mode',
          label: 'Interpolation Mode',
        ),
        BlenderMenuItem<String>(value: 'Easing Type', label: 'Easing Type'),
        BlenderMenuItem<String>(value: 'Density', label: 'Density'),
        BlenderMenuItem<String>(value: 'Blend', label: 'Blend'),
        BlenderMenuItem<String>(value: 'Smooth', label: 'Smooth'),
        BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
      ];

  Widget _buildGraphFiltersPopover({required bool drivers}) {
    return _buildAnimationPopoverPanel('Filters', <Widget>[
      BlenderCheckbox(
        value: true,
        label: 'Only Selected',
        onChanged: (value) => _setStatus('Graph selected-only filter toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Show Hidden',
        onChanged: (value) => _setStatus('Graph hidden filter toggled'),
      ),
      BlenderCheckbox(
        value: false,
        label: 'Only Errors',
        onChanged: (value) => _setStatus('Graph error filter toggled'),
      ),
      const BlenderSeparator(),
      const Text('Search Filters'),
      BlenderCheckbox(
        value: true,
        label: 'Multi-Word Match Search',
        onChanged: (value) => _setStatus('Graph search filter toggled'),
      ),
      if (drivers)
        BlenderCheckbox(
          value: false,
          label: 'Driver Fallback as Error',
          onChanged: (value) => _setStatus('Driver fallback filter toggled'),
        ),
    ]);
  }

  Widget _buildGraphSnappingPopover({required bool drivers}) {
    return _buildAnimationPopoverPanel('Snapping', <Widget>[
      const Text('Snap To'),
      BlenderDropdown<String>(
        value: drivers ? 'Absolute Time' : 'Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
          BlenderMenuItem<String>(value: 'Second', label: 'Second'),
          BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
          BlenderMenuItem<String>(
            value: 'Absolute Time',
            label: 'Absolute Time',
          ),
        ],
        onChanged: (value) => _setStatus('Graph snap target $value'),
      ),
      if (drivers)
        BlenderCheckbox(
          value: false,
          label: 'Absolute Time',
          onChanged: (value) => _setStatus('Driver absolute snap toggled'),
        ),
    ]);
  }

  Widget _buildGraphProportionalPopover() {
    return _buildAnimationPopoverPanel('Proportional Editing', <Widget>[
      BlenderDropdown<String>(
        value: 'Connected',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Connected', label: 'Connected'),
          BlenderMenuItem<String>(value: 'Projected', label: 'Projected'),
        ],
        onChanged: (value) => _setStatus('Graph proportional falloff $value'),
      ),
      const SizedBox(height: 6),
      BlenderNumberField(
        value: 1,
        min: 0,
        max: 10,
        step: .1,
        label: 'Size',
        onChanged: (_) {},
      ),
    ]);
  }

  BlenderAreaHeader _buildGraphEditorHeader(BlenderEditorType type) {
    final drivers = type == BlenderEditorType.drivers;
    final menus = <String>[
      'View',
      'Select',
      if (!drivers) 'Marker',
      'Channel',
      'Key',
    ];
    final menuItems = <String, List<String>>{
      'View': _graphViewMenuItems(
        drivers: drivers,
      ).map((item) => item.label).toList(),
      'Select': _graphSelectMenuItems().map((item) => item.label).toList(),
      'Channel': _graphChannelMenuItems(
        drivers: drivers,
      ).map((item) => item.label).toList(),
      'Key': _graphKeyMenuItems().map((item) => item.label).toList(),
      if (!drivers)
        'Marker': _animationMarkerMenuItems()
            .map((item) => item.label)
            .toList(),
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: type,
      showEditorLabel: false,
      onEditorTypeChanged: (value) => setState(() => _mainEditorType = value),
      actionsScrollable: true,
      menus: _editorMenus(menus, menuItems: menuItems),
      actions: <Widget>[
        BlenderIconButton(
          key: const ValueKey<String>('graph-normalize-button'),
          glyph: BlenderGlyph.scale,
          selected: _graphNormalize,
          onPressed: () => setState(() => _graphNormalize = !_graphNormalize),
          tooltip: 'Normalize F-Curves',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('graph-auto-normalize-button'),
          glyph: BlenderGlyph.refresh,
          selected: _graphAutoNormalize,
          onPressed: () =>
              setState(() => _graphAutoNormalize = !_graphAutoNormalize),
          tooltip: 'Auto Normalize',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('graph-ghost-curves-button'),
          glyph: BlenderGlyph.keyframe,
          selected: _graphGhostCurves,
          onPressed: () =>
              setState(() => _graphGhostCurves = !_graphGhostCurves),
          tooltip: _graphGhostCurves
              ? 'Clear Ghost Curves'
              : 'Create Ghost Curves',
        ),
        BlenderPopover(
          child: const BlenderIconButton(
            key: ValueKey<String>('graph-filters-button'),
            glyph: BlenderGlyph.filter,
            tooltip: 'Graph filters',
          ),
          popover: (context, close) =>
              _buildGraphFiltersPopover(drivers: drivers),
        ),
        const BlenderIconButton(
          key: ValueKey<String>('graph-pivot-button'),
          glyph: BlenderGlyph.transform,
          tooltip: 'Pivot Point',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('graph-snapping-button'),
            glyph: BlenderGlyph.snap,
            selected: _graphSnap,
            tooltip: 'Graph snapping',
          ),
          popover: (context, close) =>
              _buildGraphSnappingPopover(drivers: drivers),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('graph-proportional-button'),
            glyph: BlenderGlyph.transform,
            selected: _graphProportional,
            tooltip: 'Graph proportional editing',
          ),
          popover: (context, close) => _buildGraphProportionalPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
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
              const SizedBox(
                height: 180,
                child: BlenderFileBrowserUnreadableLibraryHint(
                  path: '/showcase/library.blend',
                  reports: const <BlenderFileBrowserReport>[
                    BlenderFileBrowserReport(
                      message: 'File is not a valid Blender library.',
                      level: BlenderNoticeLevel.error,
                    ),
                    BlenderFileBrowserReport(
                      message: 'The file may be incomplete or corrupted.',
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
}
