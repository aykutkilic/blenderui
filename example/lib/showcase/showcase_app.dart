import 'dart:async';

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

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
part 'showcase_app/editor_shell.dart';
part 'showcase_app/clip_and_nla_headers.dart';
part 'showcase_app/animation_and_sequencer_headers.dart';
part 'showcase_app/node_and_utility_headers.dart';
part 'showcase_app/editor_surfaces.dart';
part 'showcase_app/properties_surface.dart';
part 'showcase_app/animation_menus.dart';
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

class ShowcaseApp extends StatefulWidget {
  const ShowcaseApp({super.key});

  @override
  State<ShowcaseApp> createState() => _ShowcaseAppState();
}

class _ShowcaseAppState extends State<ShowcaseApp> with _ShowcaseUiState {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late final BlenderApplicationController<Object?> _application;
  late final Map<BlenderEditorType, BlenderEditorHeaderPreset>
  _editorHeaderPresets;
  final BlenderInterfacePreferencesService _interfacePreferences =
      BlenderInterfacePreferencesService();
  final BlenderThemeService _themeService = BlenderThemeService();
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
  String? _selectedShortcut;
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
    _application = BlenderApplicationController<Object?>(
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
      preferences: BlenderPreferencesService(
        configuration: _preferencesConfiguration,
      ),
      interfacePreferences: _interfacePreferences,
      themeService: _themeService,
      windowAppearanceAdapter: const ShowcaseWindowAppearanceAdapter(),
      presentation: BlenderApplicationPresentationService(
        splash: const BlenderSplashScreenConfiguration(
          title: 'Blender UI showcase',
          message: 'Explore Blender-inspired editor components.',
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

  void _editorAreaChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
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

  void _setStatus(String message) {
    _application.status.report(message);
  }

  /// Lets showcase part files mutate this state's app-specific sample model
  /// without bypassing the State lifecycle contract.
  void _update(VoidCallback mutation) => setState(mutation);

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

  void _moveNode(BlenderGraphNode node, Offset position) {
    setState(() {
      final updated = _nodeGraph.moveNode(node.id, position);
      _nodes
        ..clear()
        ..addAll(updated.nodes);
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
    );
  }
}
