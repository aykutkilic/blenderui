part of '../showcase_app.dart';

mixin _ShowcaseUiState on State<ShowcaseApp> {
  final BlenderCommandRegistry _commandRegistry = BlenderCommandRegistry();
  final BlenderCommandBindings _commandBindings = BlenderCommandBindings();
  _ShowcaseTemplateMode _templateMode = _ShowcaseTemplateMode.general;
  bool _templateSecondaryWorkspace = false;
  BlenderGreasePencilHeaderState _greasePencilHeaderState =
      const BlenderGreasePencilHeaderState();
  BlenderGreasePencilToolSettings _greasePencilToolSettings =
      const BlenderGreasePencilToolSettings();
  List<BlenderGreasePencilMaterial> _greasePencilMaterials =
      const <BlenderGreasePencilMaterial>[
        BlenderGreasePencilMaterial(id: 'Solid Stroke', label: 'Solid Stroke'),
        BlenderGreasePencilMaterial(
          id: 'Squares Stroke',
          label: 'Squares Stroke',
          strokeColor: Color(0xFFE62920),
        ),
        BlenderGreasePencilMaterial(
          id: 'Solid Fill',
          label: 'Solid Fill',
          strokeColor: Color(0xFFB8B8B8),
        ),
        BlenderGreasePencilMaterial(
          id: 'Dots Stroke',
          label: 'Dots Stroke',
          locked: true,
        ),
      ];
  BlenderGreasePencilTool _greasePencilTool = BlenderGreasePencilTool.draw;
  String? _selectedStoryboardStrip = 'shot-001';
  final BlenderPlaybackController _playback = BlenderPlaybackController(
    initialFrame: 24,
    rangeStart: 1,
    rangeEnd: 120,
  );
  final BlenderGraphViewportController _graphViewport =
      BlenderGraphViewportController(
        const BlenderGraphViewport(
          frameStart: -5,
          frameEnd: 125,
          valueMin: -1.35,
          valueMax: 1.35,
        ),
      );
  final BlenderGraphViewportController _driverViewport =
      BlenderGraphViewportController(
        const BlenderGraphViewport(
          frameStart: -1.25,
          frameEnd: 1.25,
          valueMin: -1,
          valueMax: 1,
        ),
      );
  Offset _graphCursor = const Offset(24, 0);
  Set<BlenderGraphKeyframeRef> _selectedGraphKeys = <BlenderGraphKeyframeRef>{
    const BlenderGraphKeyframeRef('location-z', 'location-z-60'),
  };
  String _activeGraphChannel = 'location-z';
  Set<String> _collapsedGraphNodes = <String>{};
  List<BlenderCurveChannel> _graphCurves = const <BlenderCurveChannel>[
    BlenderCurveChannel(
      id: 'location-x',
      label: 'X Location (Cube)',
      dataPath: 'location',
      arrayIndex: 0,
      color: Color(0xFFFF3352),
      keyframes: <BlenderGraphKeyframe>[
        BlenderGraphKeyframe(id: 'location-x-1', frame: 1, value: -.55),
        BlenderGraphKeyframe(id: 'location-x-20', frame: 20, value: -.85),
        BlenderGraphKeyframe(id: 'location-x-40', frame: 40, value: .55),
        BlenderGraphKeyframe(id: 'location-x-60', frame: 60, value: -.45),
        BlenderGraphKeyframe(id: 'location-x-80', frame: 80, value: .62),
        BlenderGraphKeyframe(id: 'location-x-100', frame: 100, value: -.42),
        BlenderGraphKeyframe(id: 'location-x-120', frame: 120, value: .58),
      ],
    ),
    BlenderCurveChannel(
      id: 'location-y',
      label: 'Y Location (Cube)',
      dataPath: 'location',
      arrayIndex: 1,
      color: Color(0xFF8BDC00),
      keyframes: <BlenderGraphKeyframe>[
        BlenderGraphKeyframe(id: 'location-y-1', frame: 1, value: .15),
        BlenderGraphKeyframe(id: 'location-y-24', frame: 24, value: .85),
        BlenderGraphKeyframe(id: 'location-y-48', frame: 48, value: .05),
        BlenderGraphKeyframe(id: 'location-y-72', frame: 72, value: .92),
        BlenderGraphKeyframe(id: 'location-y-96', frame: 96, value: .12),
        BlenderGraphKeyframe(id: 'location-y-120', frame: 120, value: .76),
      ],
    ),
    BlenderCurveChannel(
      id: 'location-z',
      label: 'Z Location (Cube)',
      dataPath: 'location',
      arrayIndex: 2,
      color: Color(0xFF2196FF),
      selected: true,
      active: true,
      keyframes: <BlenderGraphKeyframe>[
        BlenderGraphKeyframe(id: 'location-z-1', frame: 1, value: .75),
        BlenderGraphKeyframe(id: 'location-z-18', frame: 18, value: -.10),
        BlenderGraphKeyframe(id: 'location-z-36', frame: 36, value: .88),
        BlenderGraphKeyframe(id: 'location-z-52', frame: 52, value: -.18),
        BlenderGraphKeyframe(
          id: 'location-z-60',
          frame: 60,
          value: .95,
          selected: true,
        ),
        BlenderGraphKeyframe(id: 'location-z-72', frame: 72, value: -.12),
        BlenderGraphKeyframe(id: 'location-z-86', frame: 86, value: .82),
        BlenderGraphKeyframe(id: 'location-z-100', frame: 100, value: -.16),
        BlenderGraphKeyframe(id: 'location-z-116', frame: 116, value: .70),
      ],
    ),
  ];
  double get _frame => _playback.currentFrame;
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
  bool _useSmoothShading = true;
  bool _renderRegion = false;
  bool _cropToRenderRegion = false;
  bool _fileExtensions = true;
  bool _cacheResult = false;
  final bool _showGrid = true;
  BlenderView3dEditorHeaderState _view3dHeaderState =
      const BlenderView3dEditorHeaderState();
  int _workspaceIndex = 0;
  int _toolIndex = 0;
  // Match Blender's factory Layout workspace: the selected cube opens Object
  // Properties, while Tool settings remain one click away in the same rail.
  int _propertyTab = 7;
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
  BlenderDopeSheetEditorHeaderState _animationHeaderState =
      const BlenderDopeSheetEditorHeaderState();
  BlenderGraphEditorHeaderState _graphHeaderState =
      const BlenderGraphEditorHeaderState();
  String _nodeTreeContext = 'Object';
  bool _nodeShowBackdrop = false;
  bool _nodeGizmos = false;
  bool _nodeSnap = false;
  bool _nodeOverlays = true;
  bool _nodePinned = false;
  bool _nodeWireColors = true;
  bool _nodeShowNamedAttributes = true;
  bool _nodeShowTimings = true;
  int _nodeToolIndex = 0;
  String? _selectedNodeId;
  BlenderNlaEditorHeaderState _nlaHeaderState =
      const BlenderNlaEditorHeaderState();
  BlenderClipEditorHeaderState _clipHeaderState =
      const BlenderClipEditorHeaderState();
  BlenderImageEditorHeaderState _imageHeaderState =
      const BlenderImageEditorHeaderState();
  int _imageToolIndex = 0;
  BlenderSpreadsheetEditorHeaderState _spreadsheetHeaderState =
      const BlenderSpreadsheetEditorHeaderState();
  BlenderSequencerEditorHeaderState _sequencerHeaderState =
      const BlenderSequencerEditorHeaderState();
  String _preferenceCategory = 'Interface';
  bool _lockObjectModes = true;
  bool _fileGrid = false;
  BlenderFileBrowserHeaderState _fileBrowserHeaderState =
      const BlenderFileBrowserHeaderState();
  BlenderFileBrowserHeaderState _assetBrowserHeaderState =
      const BlenderFileBrowserHeaderState(
        displayMode: BlenderFileDisplayMode.thumbnails,
      );
  String _selectedFileSource = 'home';
  String _selectedAssetCatalog = '__all__';
  bool _galleryToggle = true;
  bool _galleryEyedropperActive = false;
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
}
