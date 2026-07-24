import 'dart:async';

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import '../demo/demo_workbench.dart';
import 'showcase_status_bar.dart';
import '../showcase_viewport.dart';
import 'window_appearance_adapter.dart';

part 'showcase_catalog_actions.dart';
part 'showcase_app/scene_models.dart';
part 'showcase_app/base_properties.dart';
part 'showcase_app/render_properties.dart';
part 'showcase_app/render_raytracing_properties.dart';
part 'showcase_app/scene_world_properties.dart';
part 'showcase_app/material_properties.dart';
part 'showcase_app/mesh_camera_properties.dart';
part 'showcase_app/curve_properties.dart';
part 'showcase_app/audio_volume_properties.dart';
part 'showcase_app/light_probe_properties.dart';
part 'showcase_app/grease_pencil_properties.dart';
part 'showcase_app/armature_properties.dart';
part 'showcase_app/bone_light_properties.dart';
part 'showcase_app/texture_collection_properties.dart';
part 'showcase_app/view_layer_properties.dart';
part 'showcase_app/freestyle_properties.dart';
part 'showcase_app/physics_properties.dart';
part 'showcase_app/fluid_rigid_body_properties.dart';
part 'showcase_app/particle_properties.dart';
part 'showcase_app/object_properties.dart';
part 'showcase_app/property_top_content.dart';
part 'showcase_app/preferences.dart';
part 'showcase_app/tool_settings.dart';
part 'showcase_app/tool_panels.dart';
part 'showcase_app/brush_panels.dart';
part 'showcase_app/brush_controls.dart';
part 'showcase_app/main_toolbar.dart';
part 'showcase_app/menu_search.dart';
part 'showcase_app/editor_shell.dart';
part 'showcase_app/clip_and_nla_headers.dart';
part 'showcase_app/animation_and_sequencer_headers.dart';
part 'showcase_app/node_and_utility_headers.dart';
part 'showcase_app/node_document_interactions.dart';
part 'showcase_app/node_graph_fixtures.dart';
part 'showcase_app/editor_surfaces.dart';
part 'showcase_app/browser_surfaces.dart';
part 'showcase_app/properties_surface.dart';
part 'showcase_app/bottom_graph_editor.dart';
part 'showcase_app/gallery_controls.dart';
part 'showcase_app/gallery_templates.dart';
part 'showcase_app/ui_state.dart';
part 'showcase_app/preferences_interface.dart';
part 'showcase_app/preferences_editing.dart';
part 'showcase_app/preferences_animation.dart';
part 'showcase_app/preferences_system.dart';
part 'showcase_app/preferences_viewport.dart';
part 'showcase_app/preferences_themes.dart';
part 'showcase_app/preferences_files.dart';
part 'showcase_app/preferences_input.dart';
part 'showcase_app/preferences_extensions.dart';
part 'showcase_app/preferences_developer.dart';
part 'showcase_app/animation_templates.dart';

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key, this.showSplash = false});

  /// The runnable example enables the native-style startup splash. Widget
  /// tests keep it opt-in so the modal surface does not obscure editor tests.
  final bool showSplash;

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> with _ShowcaseUiState {
  bool _hasUnsavedChanges = false;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final _lifecycleBridge = BlenderApplicationLifecycleBridge();
  late final BlenderApplicationController<Object?> _application;
  late final Map<BlenderEditorType, BlenderEditorHeaderPreset>
  _editorHeaderPresets;
  final BlenderInterfacePreferencesService _interfacePreferences =
      BlenderInterfacePreferencesService();
  final BlenderThemeService _themeService = BlenderThemeService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fileSearchController = TextEditingController();
  final TextEditingController _filePathController = TextEditingController(
    text: '/Users/aykutkilic/',
  );
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
  final TextEditingController _nlaCurveSearchController =
      TextEditingController();
  final TextEditingController _nlaCollectionSearchController =
      TextEditingController();
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
  final List<BlenderGraphLink> _nodeLinks = _shaderNodeLinkFixture();
  final List<BlenderGraphNode> _geometryNodes = <BlenderGraphNode>[
    const BlenderGraphNode(
      id: 'scatter-frame',
      title: 'Scatter Pebbles on Geometry',
      position: Offset(44, 54),
      size: Size(1360, 500),
      kind: BlenderGraphNodeKind.frame,
      headerColor: Color(0xFF4A4A4A),
    ),
    const BlenderGraphNode(
      id: 'group-input',
      title: 'Group Input',
      position: Offset(92, 138),
      size: Size(210, 196),
      parentId: 'scatter-frame',
      headerColor: Color(0xFF496D50),
      outputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'geometry',
          label: 'Geometry',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
          description: 'Geometry supplied by the modifier.',
        ),
        BlenderNodeSocketDefinition(
          id: 'selection',
          label: 'Selection',
          detail: 'True',
          dataType: BlenderNodeSocketDataType.boolean,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'distance-min',
          label: 'Distance Min',
          detail: '0.25 m',
          dataType: BlenderNodeSocketDataType.floatingPoint,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'distance-max',
          label: 'Distance Max',
          detail: '0.60 m',
          dataType: BlenderNodeSocketDataType.floatingPoint,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'radius',
          label: 'Pebble Radius',
          detail: '0.08 m',
          dataType: BlenderNodeSocketDataType.floatingPoint,
          connected: true,
        ),
      ],
    ),
    const BlenderGraphNode(
      id: 'distribute',
      title: 'Distribute Points on Faces',
      label: 'Poisson Disk',
      position: Offset(364, 104),
      size: Size(238, 226),
      parentId: 'scatter-frame',
      headerColor: Color(0xFF35665C),
      selected: true,
      active: true,
      executionTime: '0.18 ms',
      inputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'mesh',
          label: 'Mesh',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'selection',
          label: 'Selection',
          dataType: BlenderNodeSocketDataType.boolean,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'distance-min',
          label: 'Distance Min',
          dataType: BlenderNodeSocketDataType.floatingPoint,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'distance-max',
          label: 'Distance Max',
          dataType: BlenderNodeSocketDataType.floatingPoint,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'density',
          label: 'Density Max',
          detail: '10.000',
          dataType: BlenderNodeSocketDataType.floatingPoint,
        ),
      ],
      outputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'points',
          label: 'Points',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'normal',
          label: 'Normal',
          dataType: BlenderNodeSocketDataType.vector,
        ),
        BlenderNodeSocketDefinition(
          id: 'rotation',
          label: 'Rotation',
          dataType: BlenderNodeSocketDataType.rotation,
          connected: true,
        ),
      ],
    ),
    const BlenderGraphNode(
      id: 'icosphere',
      title: 'Icosphere',
      position: Offset(382, 366),
      size: Size(202, 134),
      parentId: 'scatter-frame',
      headerColor: Color(0xFF4C6280),
      inputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'radius',
          label: 'Radius',
          dataType: BlenderNodeSocketDataType.floatingPoint,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'subdivisions',
          label: 'Subdivisions',
          detail: '2',
          dataType: BlenderNodeSocketDataType.integer,
        ),
      ],
      outputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'mesh',
          label: 'Mesh',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
        ),
      ],
    ),
    const BlenderGraphNode(
      id: 'instance',
      title: 'Instance on Points',
      position: Offset(664, 132),
      size: Size(230, 242),
      parentId: 'scatter-frame',
      headerColor: Color(0xFF35665C),
      executionTime: '0.07 ms',
      inputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'points',
          label: 'Points',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'selection',
          label: 'Selection',
          detail: 'True',
          dataType: BlenderNodeSocketDataType.boolean,
        ),
        BlenderNodeSocketDefinition(
          id: 'instance',
          label: 'Instance',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
          multiInput: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'pick-instance',
          label: 'Pick Instance',
          detail: 'False',
          dataType: BlenderNodeSocketDataType.boolean,
        ),
        BlenderNodeSocketDefinition(
          id: 'rotation',
          label: 'Rotation',
          dataType: BlenderNodeSocketDataType.rotation,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'scale',
          label: 'Scale',
          detail: '1.000',
          dataType: BlenderNodeSocketDataType.vector,
        ),
      ],
      outputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'instances',
          label: 'Instances',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
        ),
      ],
    ),
    const BlenderGraphNode(
      id: 'realize',
      title: 'Realize Instances',
      position: Offset(958, 178),
      size: Size(202, 126),
      parentId: 'scatter-frame',
      headerColor: Color(0xFF35665C),
      executionTime: '0.11 ms',
      inputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'geometry',
          label: 'Geometry',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
        ),
        BlenderNodeSocketDefinition(
          id: 'selection',
          label: 'Selection',
          detail: 'True',
          dataType: BlenderNodeSocketDataType.boolean,
        ),
        BlenderNodeSocketDefinition(
          id: 'realize-all',
          label: 'Realize All',
          detail: 'True',
          dataType: BlenderNodeSocketDataType.boolean,
        ),
      ],
      outputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'geometry',
          label: 'Geometry',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
        ),
      ],
    ),
    const BlenderGraphNode(
      id: 'result-reroute',
      title: 'Reroute',
      position: Offset(1198, 226),
      kind: BlenderGraphNodeKind.reroute,
      parentId: 'scatter-frame',
      inputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'input',
          label: '',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
        ),
      ],
      outputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'output',
          label: '',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
        ),
      ],
    ),
    const BlenderGraphNode(
      id: 'group-output',
      title: 'Group Output',
      position: Offset(1262, 178),
      size: Size(178, 94),
      parentId: 'scatter-frame',
      headerColor: Color(0xFF496D50),
      inputs: <BlenderNodeSocketDefinition>[
        BlenderNodeSocketDefinition(
          id: 'geometry',
          label: 'Geometry',
          dataType: BlenderNodeSocketDataType.geometry,
          connected: true,
        ),
      ],
    ),
  ];
  final List<BlenderGraphLink> _geometryLinks = _geometryNodeLinkFixture();

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
  late final BlenderEditorAreaController<BlenderEditorType> _mainEditorArea;
  late final BlenderEditorAreaController<BlenderEditorType> _rightTopEditorArea;
  late final BlenderEditorAreaController<BlenderEditorType>
  _rightBottomEditorArea;

  BlenderEditorType get _mainEditorType => _mainEditorArea.value;
  BlenderEditorType get _rightTopEditorType => _rightTopEditorArea.value;
  BlenderEditorType get _rightBottomEditorType => _rightBottomEditorArea.value;
  String _selectedObject = 'Cube';
  String? _selectedFile;
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
  void initState() {
    super.initState();
    _lifecycleBridge.attach(
      onPreferencesRequested: _showPreferencesWindow,
      onUnhandledMethodCall: _handleLifecycleCall,
    );
    _application = BlenderApplicationController<Object?>(
      initialState: null,
      commandRegistry: _commandRegistry,
      commandBindings: _commandBindings,
      workspace: _generalTemplateLayout,
      preferences: BlenderPreferencesService(
        configuration: _preferencesConfiguration,
      ),
      interfacePreferences: _interfacePreferences,
      themeService: _themeService,
      windowAppearanceAdapter: const ShowcaseWindowAppearanceAdapter(),
      presentation: BlenderApplicationPresentationService(
        splash: BlenderSplashScreenConfiguration(
          title: 'Blender UI showcase',
          message: 'Explore Blender-inspired editor components.',
          width: 760,
          showOnStartup: widget.showSplash,
          content: _ShowcaseSplashContent(
            onTemplateSelected: _launchStartupTemplate,
            onStatus: _noopSplashStatus,
          ),
        ),
        about: const BlenderAboutDialogConfiguration(
          title: 'Blender UI showcase',
          version: '0.1.0',
          message: 'A Flutter component workbench for dense editor apps.',
        ),
      ),
    );
    _editorHeaderPresets = <BlenderEditorType, BlenderEditorHeaderPreset>{
      for (final type in BlenderEditorType.values)
        type: BlenderEditorHeaderPreset.forType(type),
    };
    for (final preset in _editorHeaderPresets.values) {
      preset.registerCommands(
        _application.commands,
        (commandId) => _setStatus(commandId),
      );
    }
    _registerMenuSearchCommands();
    _mainEditorArea = BlenderEditorAreaController<BlenderEditorType>(
      session: _application.editorSession,
      workspaceId: 'showcase',
      areaId: 'main-area',
      initialValue: BlenderEditorType.view3d,
      codec: blenderEditorTypeViewCodec,
      availableValues: BlenderEditorType.values,
    )..addListener(_editorAreaChanged);
    _rightTopEditorArea = BlenderEditorAreaController<BlenderEditorType>(
      session: _application.editorSession,
      workspaceId: 'showcase',
      areaId: 'outliner-area',
      initialValue: BlenderEditorType.outliner,
      codec: blenderEditorTypeViewCodec,
      availableValues: BlenderEditorType.values,
    )..addListener(_editorAreaChanged);
    _rightBottomEditorArea = BlenderEditorAreaController<BlenderEditorType>(
      session: _application.editorSession,
      workspaceId: 'showcase',
      areaId: 'properties-area',
      initialValue: BlenderEditorType.properties,
      codec: blenderEditorTypeViewCodec,
      availableValues: BlenderEditorType.values,
    )..addListener(_editorAreaChanged);
    _application.status.report('Ready');
    _application.reports.report(
      'Saved "scene.blend"',
      level: BlenderStatusLevel.success,
    );
    _application.jobs.register(
      BlenderJob(
        id: 'asset-preview',
        name: 'Building Asset Preview',
        progress: .68,
        remainingTime: '00:12',
        elapsedTime: '00:08',
        onCancel: () => _setStatus('Job canceled'),
      ),
    );
    _application.editorSession
      ..selectOutlinerItem('showcase', _selectedObject)
      ..inspectPropertiesTarget('showcase', _propertyTabs[_propertyTab].id);
  }

  Future<void> _handleLifecycleCall(MethodCall call) async {
    if (call.method != 'quitRequested') return;
    final navigatorContext = _navigatorKey.currentContext;
    if (!mounted || navigatorContext == null) {
      await _lifecycleBridge.invoke<void>('quitDecision', 'cancel');
      return;
    }
    var decision = BlenderQuitDecision.discard;
    if (_hasUnsavedChanges) {
      decision = await const BlenderQuitConfirmationService().show(
        navigatorContext,
        fileName: 'Untitled.blend',
        onSave: () {
          if (mounted) {
            setState(() => _hasUnsavedChanges = false);
          }
          return true;
        },
      );
    }
    await _lifecycleBridge.invoke<void>('quitDecision', decision.name);
  }

  void _requestQuit() {
    unawaited(() async {
      try {
        await _lifecycleBridge.invoke<void>('requestQuit');
      } on MissingPluginException {
        // Embedded runners and widget tests do not own a native window.
      } on PlatformException {
        // Native termination is best effort; keep the editor usable.
      }
    }());
  }

  void _editorAreaChanged() => setState(() {});

  @override
  void dispose() {
    _lifecycleBridge.dispose();
    _mainEditorArea
      ..removeListener(_editorAreaChanged)
      ..dispose();
    _rightTopEditorArea
      ..removeListener(_editorAreaChanged)
      ..dispose();
    _rightBottomEditorArea
      ..removeListener(_editorAreaChanged)
      ..dispose();
    _application.dispose();
    _searchController.dispose();
    _fileSearchController.dispose();
    _filePathController.dispose();
    _keymapSearchController.dispose();
    _mainOutlinerSearchController.dispose();
    _outlinerSearchController.dispose();
    _propertiesSearchController.dispose();
    _operatorSearchController.dispose();
    _layerSearchController.dispose();
    _nlaCurveSearchController.dispose();
    _nlaCollectionSearchController.dispose();
    _galleryPathController.dispose();
    _importerPathController.dispose();
    _exporterPathController.dispose();
    _playback.dispose();
    _graphViewport.dispose();
    _driverViewport.dispose();
    super.dispose();
  }

  void _setStatus(String message) => _application.status.report(message);

  /// Lets showcase part files mutate this state's app-specific sample model
  /// without bypassing the State lifecycle contract.
  void _update(VoidCallback mutation) {
    setState(() {
      mutation();
      _hasUnsavedChanges = true;
    });
  }

  void _showPreferencesWindow() {
    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext == null) return;
    unawaited(_application.preferences?.show(navigatorContext));
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

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: const ValueKey<String>('showcase-workspace'),
      child: BlenderWorkspaceShell<Object?>(
        title: 'Blender UI — workspace showcase',
        navigatorKey: _navigatorKey,
        controller: _application,
        topBar: _buildMainToolbar(),
        areaBuilder: _buildDockedArea,
        workspaceContent: _workspaceIndex == 10
            ? DemoWorkbench(onStatus: _setStatus)
            : null,
        cloneArea: (value) {
          _setStatus('Area split: $value');
          return value;
        },
        statusBar: ShowcaseStatusBar(
          status: _application.status,
          jobs: _application.jobs,
          reports: _application.reports,
          onStatus: _setStatus,
        ),
      ),
    );
  }
}

void _noopSplashStatus(String message) {}
