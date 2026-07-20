part of '../showcase_app.dart';

mixin _ShowcaseUiState on State<ShowcaseApp> {
  final BlenderPlaybackController _playback = BlenderPlaybackController(
    initialFrame: 24,
    rangeStart: 1,
    rangeEnd: 120,
  );
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
  Color _accentColor = const Color(0xFF4772B3);
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
