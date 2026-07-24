import 'dart:async';

import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'demo_workbook.dart';
import 'workbook_application_storage.dart';
import 'workbook_runtime_preferences.dart';
import 'workbook_runtime_controller.dart';
import 'workbook_shadow_file_manager.dart';
import 'workbook_workspace.dart';

part 'workbook_app_commands.dart';

class WorkbookExampleApp extends StatefulWidget {
  const WorkbookExampleApp({this.startRuntime = true, super.key});

  /// Starts application-support discovery and optional auto-connect.
  ///
  /// The workbook itself is always constructed immediately and remains usable
  /// without a Jupyter installation or network connection.
  final bool startRuntime;

  @override
  State<WorkbookExampleApp> createState() => _WorkbookExampleAppState();
}

class _WorkbookExampleAppState extends State<WorkbookExampleApp> {
  late final WorkbookSessionController _session;
  late final BlenderApplicationController<WorkbookDocument> _application;
  late final BlenderInterfacePreferencesService _interfacePreferences;
  late final BlenderThemeService _themeService;
  late final BlenderEditorSessionService _editorSession;
  late final BlenderWorkspaceService<String> _workspaces;
  late final WorkbookRuntimeController _runtime;
  final _commands = BlenderCommandRegistry();
  final _bindings = BlenderCommandBindings();
  final _applicationStorage = WorkbookApplicationStorage();
  final _installer = JupyterRuntimeInstaller();
  final _lifecycleBridge = BlenderApplicationLifecycleBridge();
  final _shadowFiles = WorkbookShadowFileManager();
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _keymapSearch = TextEditingController();
  final Map<String, BlenderEditorAreaController<WorkbookEditorView>>
  _editorAreas = <String, BlenderEditorAreaController<WorkbookEditorView>>{};
  Timer? _keymapPersistenceTimer;
  Timer? _shadowFilePreparationTimer;
  var _editorSyncScheduled = false;

  @override
  void initState() {
    super.initState();
    _lifecycleBridge.attach(onPreferencesRequested: _showPreferences);
    _interfacePreferences = BlenderInterfacePreferencesService(
      persistence: BlenderInterfacePreferencesPersistence(
        storage: _applicationStorage,
        storageKey: 'workbook.interface-preferences',
      ),
    );
    _themeService = BlenderThemeService(
      persistence: BlenderThemePersistence(
        storage: _applicationStorage,
        storageKey: 'workbook.themes',
      ),
    );
    _editorSession = BlenderEditorSessionService(
      persistence: BlenderEditorSessionPersistence(
        storage: _applicationStorage,
        storageKey: 'workbook.editor-session',
      ),
    );
    _workspaces = BlenderWorkspaceService<String>(
      initialWorkspaceId: 'workbook',
      workspaces: workbookWorkspaceDefinitions,
      persistence: BlenderWorkspacePersistence<String>(
        storage: _applicationStorage,
        storageKey: 'workbook.workspaces',
        valueCodec: BlenderWorkspaceValueCodec<String>(
          toJson: (value) => value,
          fromJson: (value) => value is String ? value : 'workbook',
        ),
      ),
    );
    _application = BlenderApplicationController<WorkbookDocument>(
      initialState: demoWorkbook,
      commandRegistry: _commands,
      commandBindings: _bindings,
      workspaceService: _workspaces,
      editorSession: _editorSession,
      interfacePreferences: _interfacePreferences,
      themeService: _themeService,
      preferences: BlenderPreferencesService(configuration: _preferences),
      presentation: BlenderApplicationPresentationService(
        about: BlenderAboutDialogConfiguration(
          title: 'BlenderUI Workbook',
          version: '0.1.0',
          message: 'An offline-first native Python and Jupyter workbook.',
        ),
      ),
    );
    _session = WorkbookSessionController(
      document: demoWorkbook,
      history: _application.state,
    );
    _runtime = WorkbookRuntimeController(
      session: _session,
      application: _application,
      installer: _installer,
      shadowFiles: _shadowFiles,
    )..addListener(_handleRuntimeChanged);
    _session.addListener(_handleSessionChanged);
    _workspaces.addListener(_synchronizeEditorSession);
    _registerCommandsAndKeymap();
    unawaited(_restoreApplicationServices());
    if (widget.startRuntime) unawaited(_runtime.initialize());
  }

  Future<void> _openDocument() async {
    try {
      final selected = await openFile(
        acceptedTypeGroups: const <XTypeGroup>[
          XTypeGroup(
            label: 'Python and Jupyter documents',
            extensions: <String>['ipynb', 'py', 'txt'],
          ),
        ],
      );
      if (selected == null) return;
      final contents = await selected.readAsString();
      final document = selected.name.toLowerCase().endsWith('.ipynb')
          ? const JupyterNotebookCodec().decode(
              contents,
              fallbackTitle: selected.name,
            )
          : WorkbookDocument(
              id: 'file-${DateTime.now().microsecondsSinceEpoch}',
              title: selected.name,
              cells: <WorkbookCell>[
                WorkbookCell(id: 'cell-1', source: contents),
              ],
            );
      _session.replaceDocument(document);
      _application.state.clearHistory();
      await _runtime.prepareWorkspace();
      _application.status.report('Opened ${selected.name}');
      if (mounted) setState(() {});
    } on Object catch (error) {
      _application.reports.report(
        'Could not open document: $error',
        level: BlenderStatusLevel.error,
      );
      _runtime.report('File open failed: $error');
    }
  }

  void _refreshAfterShadowFilePreparation() {
    if (mounted) setState(() {});
  }

  void _handleRuntimeChanged() {
    if (mounted) setState(() {});
  }

  BlenderPreferencesConfiguration get _preferences =>
      BlenderPreferencesConfiguration(
        title: 'Workbook Preferences',
        categories: const <String>['Runtime', 'Interface', 'Themes', 'Keymap'],
        sections: <BlenderPreferenceSection>[
          BlenderPreferenceSection(
            id: 'workbook-runtime-jupyter',
            category: 'Runtime',
            title: 'Python and Jupyter',
            searchTerms: const <String>[
              'offline',
              'Jupyter',
              'Python',
              'install',
              'server',
              'token',
              'auto-connect',
            ],
            child: WorkbookRuntimePreferencesPanel(
              settings: () => _runtime.settings,
              installer: _installer,
              runtimeStatus: () => _runtime.status,
              initialToken: '',
              busy: () => _runtime.busy,
              onSettingsChanged: (value) => _runtime.updateSettings(value),
              onTokenChanged: (value) => _runtime.updateRemoteToken(value),
              onInstallAndConnect: () => _runtime.installAndConnect(),
              onConnect: () => _runtime.connect(),
              onDisconnect: () => _runtime.disconnect(),
            ),
          ),
          ...blenderInterfacePreferenceSections(
            preferences: _interfacePreferences,
            themeService: _themeService,
          ),
          BlenderPreferenceSection(
            id: 'workbook-keymap',
            category: 'Keymap',
            title: 'Workbook Keymap',
            searchTerms: const <String>[
              'open',
              'undo',
              'redo',
              'run all',
              'interrupt',
              'preferences',
            ],
            child: SizedBox(
              height: 520,
              child: BlenderKeymapEditor(
                searchController: _keymapSearch,
                bindings: _bindings,
                commands: _commands,
              ),
            ),
          ),
        ],
      );

  Widget _buildArea(BuildContext context, BlenderDockAreaNode<String> area) {
    final workspaceId = _workspaces.activeWorkspaceId;
    final key = '$workspaceId:${area.id}';
    final initial =
        workbookEditorViewCodec.decode(area.value) ??
        WorkbookEditorView.workbook;
    final controller = _editorAreas.putIfAbsent(
      key,
      () => BlenderEditorAreaController<WorkbookEditorView>(
        session: _editorSession,
        workspaceId: workspaceId,
        areaId: area.id,
        initialValue: initial,
        codec: workbookEditorViewCodec,
        availableValues: WorkbookEditorView.values,
      ),
    );
    return BlenderEditorAreaHost<WorkbookEditorView>(
      controller: controller,
      views: <BlenderEditorAreaView<WorkbookEditorView>>[
        for (final view in WorkbookEditorView.values)
          BlenderEditorAreaView<WorkbookEditorView>(
            value: view,
            builder: (_) => _buildEditorView(view),
          ),
      ],
      frameBuilder: (context, view, select, editor) => WorkbookEditorAreaFrame(
        view: view,
        onViewSelected: select,
        child: editor,
      ),
    );
  }

  Widget _buildEditorView(WorkbookEditorView view) => switch (view) {
    WorkbookEditorView.workbook => WorkbookView(
      controller: _session,
      lspConfig: _runtime.lspConfig,
      aiCompletionProvider: _runtime.aiProvider,
      filePathForCell: _runtime.filePathForCell,
      persistFileChanges: false,
    ),
    WorkbookEditorView.outline => WorkbookOutline(controller: _session),
    WorkbookEditorView.runtime => WorkbookRuntimeInspector(
      session: _session,
      installer: _installer,
      status: () => _runtime.status,
      busy: () => _runtime.busy,
      onConnect: () => _runtime.connect(),
      onDisconnect: () => _runtime.disconnect(),
      onInstall: () => _runtime.installAndConnect(),
    ),
    WorkbookEditorView.reports => WorkbookReportsView(
      reports: _application.reports,
    ),
  };

  BlenderApplicationMenu<String> _commandMenu(
    String label,
    List<String> commandIds,
  ) => BlenderApplicationMenu<String>(
    label: label,
    items: <BlenderMenuItem<String>>[
      for (final id in commandIds)
        if (_commands[id] case final command?)
          BlenderMenuItem<String>(
            value: id,
            label: command.label,
            enabled: command.isEnabled,
          ),
    ],
    onSelected: (id) => unawaited(_commands.execute(id)),
  );

  Widget _buildTopBar(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge(<Listenable>[
      _workspaces,
      _session,
      _application.state,
      _commands,
    ]),
    builder: (context, _) => BlenderApplicationTopBar<String, String>(
      overflow: BlenderApplicationTopBarOverflow.shared,
      leading: const <Widget>[
        BlenderIconButton(
          glyph: BlenderGlyph.console,
          tooltip: 'Math and AI Workbook',
          size: 30,
        ),
      ],
      menus: <BlenderApplicationMenu<String>>[
        _commandMenu('File', const <String>['workbook.file.open']),
        _commandMenu('Edit', const <String>[
          'application.undo',
          'application.redo',
          'workbook.preferences',
        ]),
        _commandMenu('Kernel', const <String>[
          'workbook.runtime.install',
          'workbook.runtime.connect',
          'workbook.runtime.disconnect',
          'workbook.runAll',
          'workbook.interrupt',
          'workbook.restart',
        ]),
        _commandMenu('Window', const <String>['workbook.workspace.reset']),
        _commandMenu('Help', const <String>['workbook.about']),
      ],
      workspaces: const <BlenderApplicationWorkspace<String>>[
        BlenderApplicationWorkspace(value: 'workbook', label: 'Workbook'),
        BlenderApplicationWorkspace(value: 'scripting', label: 'Scripting'),
        BlenderApplicationWorkspace(value: 'inspect', label: 'Inspect'),
      ],
      activeWorkspace: _workspaces.activeWorkspaceId,
      onWorkspaceSelected: _workspaces.selectWorkspace,
      contextControls: <Widget>[
        BlenderButton(label: _session.document.title, onPressed: null),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlenderWorkspaceShell<WorkbookDocument>(
      title: 'BlenderUI — ${_session.document.title}',
      controller: _application,
      navigatorKey: _navigatorKey,
      preferences: _preferences,
      areaBuilder: _buildArea,
      cloneArea: (value) => value,
      topBar: Builder(builder: _buildTopBar),
      statusBar: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          _session,
          _installer,
          _runtime,
          _workspaces,
        ]),
        builder: (context, _) => BlenderApplicationStatusBar(
          status: _application.status,
          jobs: _application.jobs,
          reports: _application.reports,
          right: <Widget>[
            Text('Kernel: ${_session.kernelState.name}'),
            const SizedBox(width: 12),
            Text(_runtime.lspConfig == null ? 'LSP off' : 'Python LSP'),
            const SizedBox(width: 12),
            Text(_workspaces.activeWorkspaceId),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lifecycleBridge.dispose();
    _keymapPersistenceTimer?.cancel();
    _shadowFilePreparationTimer?.cancel();
    _bindings.removeListener(_scheduleKeymapPersistence);
    _session.removeListener(_handleSessionChanged);
    _runtime.removeListener(_handleRuntimeChanged);
    _workspaces.removeListener(_synchronizeEditorSession);
    for (final controller in _editorAreas.values) {
      controller.dispose();
    }
    _installer.cancel();
    _runtime.dispose();
    _installer.dispose();
    _session.dispose();
    _application.dispose();
    _keymapSearch.dispose();
    super.dispose();
  }
}
