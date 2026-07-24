import 'dart:async';

import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_daw/blender_ui_daw.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'demo_project.dart';
import 'daw_application_storage.dart';

class DawExampleApp extends StatefulWidget {
  const DawExampleApp({super.key});

  @override
  State<DawExampleApp> createState() => _DawExampleAppState();
}

class _DawExampleAppState extends State<DawExampleApp> {
  late final BlenderApplicationController<DawProject> _application;
  late final DawSessionController _session;
  late final DawTransportController _transport;
  late final DawPluginHost _pluginHost;
  late final DawAudioEngine _audioEngine;
  late final DawAudioDeviceController _audioDevices;
  late final DawNativeMidiDeviceService _midiDevices;
  late final DawProjectPersistenceController _persistence;
  final BlenderCommandRegistry _commands = BlenderCommandRegistry();
  final BlenderCommandBindings _bindings = BlenderCommandBindings();
  final _lifecycleBridge = BlenderApplicationLifecycleBridge();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final TextEditingController _keymapSearch = TextEditingController();
  final Map<String, BlenderEditorAreaController<DawEditorView>> _editorAreas =
      <String, BlenderEditorAreaController<DawEditorView>>{};
  bool _metronome = true;
  Object? _reportedTransportError;

  @override
  void initState() {
    super.initState();
    _lifecycleBridge.attach(
      onPreferencesRequested: _showPreferences,
      onUnhandledMethodCall: _handleLifecycleCall,
    );
    final project = buildDemoProject();
    final workspaces = BlenderWorkspaceService<String>(
      initialWorkspaceId: 'song',
      workspaces: <BlenderWorkspaceDefinition<String>>[
        const BlenderWorkspaceDefinition<String>(
          id: 'song',
          layout: _songLayout,
        ),
        const BlenderWorkspaceDefinition<String>(id: 'mix', layout: _mixLayout),
        const BlenderWorkspaceDefinition<String>(
          id: 'edit',
          layout: _editLayout,
        ),
      ],
    );
    final nativeMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    _audioEngine = nativeMacOS
        ? DawNativeAudioEngine()
        : DawInMemoryAudioEngine();
    _audioDevices = DawAudioDeviceController(engine: _audioEngine);
    _midiDevices = DawNativeMidiDeviceService();
    _pluginHost = nativeMacOS
        ? DawNativePluginHost()
        : DawInMemoryPluginHost(catalog: dawBuiltinPluginCatalog);
    _application = BlenderApplicationController<DawProject>(
      initialState: project,
      commandRegistry: _commands,
      commandBindings: _bindings,
      workspaceService: workspaces,
      preferences: BlenderPreferencesService(configuration: _preferences),
    );
    _session = DawSessionController(
      initialProject: project,
      history: _application.state,
    );
    _transport = DawTransportController(
      session: _session,
      audioEngine: _audioEngine,
    );
    _persistence = DawProjectPersistenceController(
      store: DawApplicationStorage(),
    );
    _session.projectChanges.addListener(_synchronizeProjectServices);
    _transport.addListener(_reportTransportError);
    unawaited(
      _audioDevices.initialize(preferredSampleRate: project.sampleRate),
    );
    if (_pluginHost is DawNativePluginHost) unawaited(_discoverPlugins());
    unawaited(_midiDevices.refresh());
    _session.selectClip('drums', 'drum-pattern-a');
    _registerCommands();
    unawaited(_synchronizeProjectServicesAsync());
    _application.status.report('Audio engine ready');
  }

  static const BlenderDockNode<String> _songLayout =
      BlenderDockSplitNode<String>(
        id: 'song-root',
        direction: BlenderSplitDirection.horizontal,
        fraction: .18,
        first: BlenderDockAreaNode<String>(
          id: 'song-browser',
          value: 'plugin-browser',
        ),
        second: BlenderDockSplitNode<String>(
          id: 'song-right',
          direction: BlenderSplitDirection.vertical,
          fraction: .62,
          first: BlenderDockAreaNode<String>(
            id: 'song-arrangement',
            value: 'arrangement',
          ),
          second: BlenderDockSplitNode<String>(
            id: 'song-bottom',
            direction: BlenderSplitDirection.horizontal,
            fraction: .68,
            first: BlenderDockAreaNode<String>(
              id: 'song-piano',
              value: 'piano-roll',
            ),
            second: BlenderDockAreaNode<String>(
              id: 'song-mixer',
              value: 'mixer',
            ),
          ),
        ),
      );

  static const BlenderDockNode<String> _mixLayout =
      BlenderDockSplitNode<String>(
        id: 'mix-root',
        direction: BlenderSplitDirection.horizontal,
        fraction: .68,
        first: BlenderDockAreaNode<String>(id: 'mix-mixer', value: 'mixer'),
        second: BlenderDockSplitNode<String>(
          id: 'mix-right',
          direction: BlenderSplitDirection.vertical,
          fraction: .5,
          first: BlenderDockAreaNode<String>(
            id: 'mix-rack',
            value: 'plugin-rack',
          ),
          second: BlenderDockAreaNode<String>(
            id: 'mix-automation',
            value: 'automation',
          ),
        ),
      );

  static const BlenderDockNode<String> _editLayout =
      BlenderDockSplitNode<String>(
        id: 'edit-root',
        direction: BlenderSplitDirection.vertical,
        fraction: .52,
        first: BlenderDockAreaNode<String>(id: 'edit-wave', value: 'wave'),
        second: BlenderDockSplitNode<String>(
          id: 'edit-bottom',
          direction: BlenderSplitDirection.horizontal,
          fraction: .58,
          first: BlenderDockAreaNode<String>(
            id: 'edit-piano',
            value: 'piano-roll',
          ),
          second: BlenderDockAreaNode<String>(
            id: 'edit-automation',
            value: 'automation',
          ),
        ),
      );

  BlenderPreferencesConfiguration
  get _preferences => BlenderPreferencesConfiguration(
    categories: const <String>['Audio', 'MIDI', 'Plugins', 'Keymap'],
    sections: <BlenderPreferenceSection>[
      BlenderPreferenceSection(
        id: 'preferences-Audio-device',
        category: 'Audio',
        title: 'Audio Device',
        searchTerms: const <String>[
          'audio device',
          'sample rate',
          'buffer size',
        ],
        child: DawAudioPreferencesPanel(controller: _audioDevices),
      ),
      BlenderPreferenceSection(
        id: 'preferences-MIDI-devices',
        category: 'MIDI',
        title: 'MIDI Devices',
        searchTerms: const <String>['midi input', 'midi output', 'controller'],
        child: DawMidiPreferencesPanel(devices: _midiDevices),
      ),
      BlenderPreferenceSection(
        id: 'preferences-Plugins-installed',
        category: 'Plugins',
        title: 'Installed Instruments and Effects',
        searchTerms: const <String>['VST3', 'Audio Unit', 'AU', 'scan'],
        child: AnimatedBuilder(
          animation: _pluginHost,
          builder: (context, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                '${_pluginHost.catalog.length} installed plug-ins discovered',
              ),
              const SizedBox(height: 8),
              BlenderButton(
                label: _pluginHost.scanning ? 'Scanning…' : 'Rescan Plug-ins',
                onPressed: _pluginHost.scanning ? null : _discoverPlugins,
              ),
            ],
          ),
        ),
      ),
      BlenderPreferenceSection(
        id: 'daw-keymap',
        category: 'Keymap',
        title: 'Keymap',
        child: SizedBox(
          height: 500,
          child: BlenderKeymapEditor(
            searchController: _keymapSearch,
            bindings: _bindings,
            commands: _commands,
          ),
        ),
      ),
    ],
  );

  void _registerCommands() {
    void command(
      String id,
      String label,
      VoidCallback execute, {
      List<String> path = const <String>[],
    }) {
      _application.commands.register(
        BlenderCommand(id: id, label: label, menuPath: path, execute: execute),
      );
    }

    command(
      'daw.transport.play',
      'Play / Stop',
      _transport.togglePlay,
      path: const <String>['Transport'],
    );
    command(
      'daw.transport.record',
      'Record',
      _transport.toggleRecord,
      path: const <String>['Transport'],
    );
    command(
      'daw.edit.undo',
      'Undo',
      _session.undo,
      path: const <String>['Edit'],
    );
    command(
      'daw.edit.redo',
      'Redo',
      _session.redo,
      path: const <String>['Edit'],
    );
    command(
      'daw.edit.delete',
      'Delete Selection',
      _session.deleteSelection,
      path: const <String>['Edit'],
    );
    command(
      'daw.clip.split',
      'Split Clip at Playhead',
      _session.splitSelectedClip,
      path: const <String>['Pattern'],
    );
    command(
      'daw.clip.duplicate',
      'Duplicate Clip',
      _session.duplicateSelectedClip,
      path: const <String>['Pattern'],
    );
    command(
      'daw.file.save',
      'Save Project',
      _saveProject,
      path: const <String>['File'],
    );
    command(
      'daw.view.preferences',
      'Preferences...',
      _showPreferences,
      path: const <String>['Edit'],
    );

    void bind(String commandId, SingleActivator activator) {
      if (_application.commandBindings.commandFor(activator) != null) return;
      _application.commandBindings.register(
        BlenderCommandBinding(
          commandId: commandId,
          activator: activator,
          keymap: 'DAW Window',
        ),
      );
    }

    bind('daw.transport.play', const SingleActivator(LogicalKeyboardKey.space));
    bind(
      'daw.transport.record',
      const SingleActivator(LogicalKeyboardKey.keyR),
    );
    bind('daw.edit.delete', const SingleActivator(LogicalKeyboardKey.delete));
    bind(
      'daw.edit.undo',
      const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
    );
    bind(
      'daw.edit.redo',
      const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true),
    );
    bind(
      'daw.clip.split',
      const SingleActivator(LogicalKeyboardKey.keyE, meta: true),
    );
    bind(
      'daw.clip.duplicate',
      const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
    );
    bind(
      'daw.file.save',
      const SingleActivator(LogicalKeyboardKey.keyS, meta: true),
    );
    bind(
      'daw.view.preferences',
      const SingleActivator(LogicalKeyboardKey.comma, meta: true),
    );
  }

  void _synchronizeProjectServices() {
    unawaited(_synchronizeProjectServicesAsync());
    _persistence.scheduleAutosave(_session.project);
  }

  void _reportTransportError() {
    final error = _transport.engineError;
    if (error == null || identical(error, _reportedTransportError)) return;
    _reportedTransportError = error;
    _application.status.report('Audio transport command failed: $error');
  }

  Future<void> _synchronizeProjectServicesAsync() async {
    try {
      await _audioEngine.synchronizeProject(_session.project);
    } on Object catch (error) {
      _application.status.report('Audio engine synchronization failed: $error');
    }
  }

  Future<void> _discoverPlugins() async {
    try {
      final catalog = await _pluginHost.scan(const <String>[
        '/Library/Audio/Plug-Ins/VST3',
        '~/Library/Audio/Plug-Ins/VST3',
        '/System/Library/Audio/Plug-Ins/VST3',
      ]);
      _application.status.report('${catalog.length} plug-ins discovered');
    } catch (error) {
      _application.status.report('Plug-in scan unavailable: $error');
    }
  }

  Future<void> _saveProject() async {
    final fileName = '${_session.project.name}.buidaw';
    try {
      await _persistence.save(_session.project, location: fileName);
      _application.status.report('Saved $fileName');
    } on Object catch (error) {
      _application.status.report('Could not save $fileName: $error');
    }
  }

  Future<void> _handleLifecycleCall(MethodCall call) async {
    if (call.method != 'quitRequested') return;
    final context = _navigatorKey.currentContext;
    if (!mounted || context == null) {
      await _lifecycleBridge.invoke<void>('quitDecision', 'cancel');
      return;
    }
    var decision = BlenderQuitDecision.discard;
    if (_persistence.dirty) {
      decision = await const BlenderQuitConfirmationService().show(
        context,
        fileName: _persistence.location ?? '${_session.project.name}.buidaw',
        onSave: () async {
          await _saveProject();
          return !_persistence.dirty;
        },
      );
    }
    await _lifecycleBridge.invoke<void>('quitDecision', decision.name);
  }

  void _showPreferences() {
    final context = _navigatorKey.currentContext;
    if (context != null) unawaited(_application.preferences?.show(context));
  }

  Widget _buildArea(BuildContext context, BlenderDockAreaNode<String> area) {
    final workspaceId = _application.workspaces.activeWorkspaceId;
    final key = '$workspaceId:${area.id}';
    final initial =
        dawEditorViewCodec.decode(area.value) ?? DawEditorView.arrangement;
    final controller = _editorAreas.putIfAbsent(
      key,
      () => BlenderEditorAreaController<DawEditorView>(
        session: _application.editorSession,
        workspaceId: workspaceId,
        areaId: area.id,
        initialValue: initial,
        codec: dawEditorViewCodec,
        availableValues: DawEditorView.values,
      ),
    );
    return BlenderEditorAreaHost<DawEditorView>(
      controller: controller,
      views: <BlenderEditorAreaView<DawEditorView>>[
        for (final view in DawEditorView.values)
          BlenderEditorAreaView<DawEditorView>(
            value: view,
            builder: (_) => _buildEditorView(view),
          ),
      ],
      frameBuilder: (context, view, select, editor) =>
          DawEditorAreaScope(view: view, onViewSelected: select, child: editor),
    );
  }

  Widget _buildEditorView(DawEditorView view) => switch (view) {
    DawEditorView.arrangement => DawArrangementEditor(session: _session),
    DawEditorView.pianoRoll => DawPianoRollEditor(session: _session),
    DawEditorView.wave => DawWaveEditor(
      session: _session,
      clip: _firstAudioClip,
    ),
    DawEditorView.automation => DawAutomationEditor(
      session: _session,
      trackId: 'drums',
      laneId: 'drum-filter',
    ),
    DawEditorView.mixer => DawMixerEditor(session: _session),
    DawEditorView.pluginRack => DawPluginRack(host: _pluginHost),
    DawEditorView.pluginBrowser => DawPluginBrowser(
      host: _pluginHost,
      searchPaths: const <String>[
        '/Library/Audio/Plug-Ins/VST3',
        '~/Library/Audio/Plug-Ins/VST3',
      ],
      onPluginSelected: (plugin) {
        unawaited(() async {
          try {
            await _pluginHost.instantiate(plugin.id);
            _application.status.report('Loaded ${plugin.name}');
          } catch (error) {
            _application.status.report('Could not load ${plugin.name}: $error');
          }
        }());
      },
    ),
    DawEditorView.effectChain => DawEffectChainEditor(
      session: _session,
      host: _pluginHost,
      audioEngine: _audioEngine,
    ),
    DawEditorView.audioGraph => DawAudioGraphEditor(
      session: _session,
      host: _pluginHost,
    ),
  };

  DawAudioClip? get _firstAudioClip {
    for (final track in _session.project.tracks) {
      for (final clip in track.clips) {
        if (clip is DawAudioClip) return clip;
      }
    }
    return null;
  }

  Widget _buildTopBar(BuildContext context) => AnimatedBuilder(
    animation: _application.workspaces,
    builder: (context, _) => Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BlenderApplicationTopBar<String, String>(
          overflow: BlenderApplicationTopBarOverflow.shared,
          leading: const <Widget>[
            BlenderIconButton(
              glyph: BlenderGlyph.speaker,
              tooltip: 'BlenderUI DAW',
              size: 30,
            ),
          ],
          menus: <BlenderApplicationMenu<String>>[
            _menu('File', const <String>[
              'New',
              'Open...',
              'Save',
              'Save As...',
              'Import MIDI...',
              'Export Audio...',
            ]),
            _menu('Edit', const <String>[
              'Undo',
              'Redo',
              'Cut',
              'Copy',
              'Paste',
              'Preferences...',
            ]),
            _menu('Track', const <String>[
              'Add Audio Track',
              'Add MIDI Track',
              'Add Instrument Track',
              'Add Automation',
            ]),
            _menu('Pattern', const <String>[
              'New Pattern',
              'Clone Pattern',
              'Make Unique',
            ]),
            _menu('View', const <String>[
              'Arrangement',
              'Piano Roll',
              'Wave Editor',
              'Mixer',
              'Plugin Rack',
            ]),
            _menu('Help', const <String>[
              'DAW Manual',
              'Keyboard Shortcuts',
              'About',
            ]),
          ],
          workspaces: const <BlenderApplicationWorkspace<String>>[
            BlenderApplicationWorkspace(value: 'song', label: 'Song'),
            BlenderApplicationWorkspace(value: 'mix', label: 'Mix'),
            BlenderApplicationWorkspace(value: 'edit', label: 'Edit'),
          ],
          activeWorkspace: _application.workspaces.activeWorkspaceId,
          onWorkspaceSelected: _application.workspaces.selectWorkspace,
          contextControls: <Widget>[
            BlenderButton(label: _session.project.name, onPressed: null),
          ],
        ),
        DawTransportBar(
          session: _session,
          transport: _transport,
          metronomeEnabled: _metronome,
          onMetronome: () => setState(() => _metronome = !_metronome),
          onSave: _saveProject,
        ),
      ],
    ),
  );

  BlenderApplicationMenu<String> _menu(String label, List<String> values) =>
      BlenderApplicationMenu<String>(
        label: label,
        items: <BlenderMenuItem<String>>[
          for (final value in values)
            BlenderMenuItem<String>(value: value, label: value),
        ],
        onSelected: (value) {
          switch (value) {
            case 'Save':
              _saveProject();
            case 'Undo':
              _session.undo();
            case 'Redo':
              _session.redo();
            case 'Preferences...':
              _showPreferences();
            default:
              _application.status.report(value);
          }
        },
      );

  @override
  Widget build(BuildContext context) => BlenderWorkspaceShell<DawProject>(
    title: 'BlenderUI DAW — ${_session.project.name}',
    navigatorKey: _navigatorKey,
    controller: _application,
    topBar: Builder(builder: _buildTopBar),
    areaBuilder: _buildArea,
    cloneArea: (value) => value,
    statusBar: AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _application.status,
        _session,
        _pluginHost,
        _audioEngine,
        _midiDevices,
        _persistence,
      ]),
      builder: (context, _) => BlenderStatusBar(
        left: <Widget>[Text(_application.status.message?.text ?? 'Ready')],
        right: <Widget>[
          Text('${_session.project.tracks.length} tracks'),
          const SizedBox(width: 12),
          Text('${_pluginHost.instances.length} plug-ins'),
          const SizedBox(width: 12),
          Text(
            '${_audioEngine.configuration?.sampleRate ?? _session.project.sampleRate} Hz',
          ),
          const SizedBox(width: 12),
          Text('${(_audioEngine.meters.cpuLoad * 100).round()}% DSP'),
          const SizedBox(width: 12),
          Text('Snap ${_session.snapBeats} beat'),
        ],
      ),
    ),
  );

  @override
  void dispose() {
    _lifecycleBridge.dispose();
    for (final controller in _editorAreas.values) {
      controller.dispose();
    }
    _session.projectChanges.removeListener(_synchronizeProjectServices);
    _transport.removeListener(_reportTransportError);
    _transport.dispose();
    _session.dispose();
    _audioDevices.dispose();
    _midiDevices.dispose();
    if (_pluginHost case final ChangeNotifier notifier) notifier.dispose();
    if (_audioEngine case final ChangeNotifier notifier) notifier.dispose();
    _persistence.dispose();
    _keymapSearch.dispose();
    _application.dispose();
    super.dispose();
  }
}
