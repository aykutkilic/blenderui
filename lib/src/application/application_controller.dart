part of '../application.dart';

/// Owns the framework-level state needed by a dockable desktop application.
///
/// Domain state remains generic and immutable. The controller scopes its
/// history store and command registry through [services], allowing editors and
/// commands to share application state without a global singleton. Services
/// supplied to the constructor are adopted by that container along with the
/// defaults; [dispose] delegates service teardown to the container and only
/// tears down composition-only listeners/controllers itself.
class BlenderApplicationController<T> implements BlenderServiceDisposable {
  BlenderApplicationController({
    required T initialState,
    BlenderDockNode<String>? workspace,
    BlenderWorkspaceService<String>? workspaceService,
    BlenderStateEquality<T>? stateEquals,
    BlenderStatusService? status,
    BlenderJobService? jobs,
    BlenderReportService? reports,
    BlenderCommandBindings? commandBindings,
    BlenderEditorSessionService? editorSession,
    BlenderInterfacePreferencesService? interfacePreferences,
    BlenderThemeService? themeService,
    BlenderWindowAppearanceAdapter? windowAppearanceAdapter,
    this.preferences,
    BlenderApplicationPresentationService? presentation,
    this.historyLimit = 50,
  }) : assert(
         workspace == null || workspaceService == null,
         'Provide either workspace or workspaceService, not both.',
       ),
       state = BlenderHistoryStore<T>(
         initialState,
         equals: stateEquals,
         historyLimit: historyLimit,
       ),
       status = status ?? BlenderStatusService(),
       jobs = jobs ?? BlenderJobService(),
       reports = reports ?? BlenderReportService(),
       commandBindings = commandBindings ?? BlenderCommandBindings(),
       editorSession = editorSession ?? BlenderEditorSessionService(),
       interfacePreferences = interfacePreferences,
       themeService = themeService,
       presentation = presentation ?? BlenderApplicationPresentationService(),
       workspaces =
           workspaceService ??
           BlenderWorkspaceService<String>(
             workspaces: <BlenderWorkspaceDefinition<String>>[
               BlenderWorkspaceDefinition<String>(
                 id: 'default',
                 layout:
                     workspace ??
                     const BlenderDockAreaNode<String>(
                       id: 'application-root',
                       value: 'application-root',
                     ),
               ),
             ],
           ),
       commands = BlenderCommandRegistry(),
       services = BlenderServiceContainer() {
    final interfacePreferences = this.interfacePreferences;
    final themeService = this.themeService;
    if (interfacePreferences != null) {
      themeController = BlenderThemeController(
        source: Listenable.merge(<Listenable>[
          interfacePreferences,
          if (themeService != null) themeService,
        ]),
        resolve: () {
          final activeTheme = themeService?.activeTheme;
          return activeTheme == null
              ? const BlenderThemeData().withInterfacePreferences(
                  interfacePreferences.value,
                )
              : const BlenderThemeData()
                    .copyWith(colors: activeTheme.colors)
                    .withInterfaceMetrics(interfacePreferences.value);
        },
      );
    } else {
      themeController = null;
    }
    windowAppearance =
        windowAppearanceAdapter == null || themeController == null
        ? null
        : BlenderWindowAppearanceController(
            theme: themeController!,
            adapter: windowAppearanceAdapter,
          );
    commands
      ..register(
        BlenderCommand(
          id: 'application.undo',
          label: 'Undo',
          shortcut: 'Ctrl Z',
          menuPath: const <String>['Edit'],
          glyph: BlenderGlyph.undo,
          enabled: () => state.canUndo,
          execute: () {
            state.undo();
          },
        ),
      )
      ..register(
        BlenderCommand(
          id: 'application.redo',
          label: 'Redo',
          shortcut: 'Ctrl Shift Z',
          menuPath: const <String>['Edit'],
          glyph: BlenderGlyph.redo,
          enabled: () => state.canRedo,
          execute: () {
            state.redo();
          },
        ),
      );
    void registerDefaultBinding(BlenderCommandBinding binding) {
      if (this.commandBindings.commandFor(binding.activator) == null) {
        this.commandBindings.register(binding);
      }
    }

    registerDefaultBinding(
      const BlenderCommandBinding(
        commandId: 'application.undo',
        activator: SingleActivator(LogicalKeyboardKey.keyZ, control: true),
      ),
    );
    registerDefaultBinding(
      const BlenderCommandBinding(
        commandId: 'application.redo',
        activator: SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ),
      ),
    );
    services
      ..registerSingleton<BlenderHistoryStore<T>>(state)
      ..registerSingleton<BlenderWorkspaceService<String>>(workspaces)
      // Retain the original singleton for one-workspace applications.
      ..registerSingleton<BlenderDockingController<String>>(docking)
      ..registerSingleton<BlenderCommandRegistry>(commands)
      ..registerSingleton<BlenderCommandBindings>(this.commandBindings)
      ..registerSingleton<BlenderStatusService>(this.status)
      ..registerSingleton<BlenderJobService>(this.jobs)
      ..registerSingleton<BlenderReportService>(this.reports)
      ..registerSingleton<BlenderEditorSessionService>(this.editorSession)
      ..registerSingleton<BlenderApplicationPresentationService>(
        this.presentation,
      );
    if (interfacePreferences != null) {
      services.registerSingleton<BlenderInterfacePreferencesService>(
        interfacePreferences,
      );
    }
    if (themeService != null) {
      services.registerSingleton<BlenderThemeService>(themeService);
    }
    final preferences = this.preferences;
    if (preferences != null) {
      preferences.bindThemeController(themeController);
      services.registerSingleton<BlenderPreferencesService>(preferences);
    }
    state.addListener(commands.refresh);
  }

  final int historyLimit;
  final BlenderHistoryStore<T> state;
  final BlenderWorkspaceService<String> workspaces;

  /// Backwards-compatible access to the active dock layout.
  BlenderDockingController<String> get docking => workspaces.activeController;
  final BlenderCommandRegistry commands;
  final BlenderCommandBindings commandBindings;
  final BlenderStatusService status;
  final BlenderJobService jobs;
  final BlenderReportService reports;
  final BlenderEditorSessionService editorSession;
  final BlenderInterfacePreferencesService? interfacePreferences;
  final BlenderThemeService? themeService;
  late final BlenderThemeController? themeController;
  late final BlenderWindowAppearanceController? windowAppearance;
  final BlenderPreferencesService? preferences;
  final BlenderApplicationPresentationService presentation;
  final BlenderServiceContainer services;
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    state.removeListener(commands.refresh);
    windowAppearance?.dispose();
    themeController?.dispose();
    services.dispose();
  }
}

/// Installs [BlenderApplicationController] services around custom app chrome.
///
/// Use this when an application already owns routing or a native title bar but
/// still needs BlenderUI's scoped state/history, command bindings, status,
/// presentation, Preferences, and editor-session services. For a dockable
/// frame, use [BlenderWorkspaceShell] instead.
class BlenderApplicationScope<T> extends StatefulWidget {
  const BlenderApplicationScope({
    super.key,
    required this.controller,
    required this.child,
    this.baseTheme = const BlenderThemeData(),
  });

  final BlenderApplicationController<T> controller;
  final Widget child;
  final BlenderThemeData baseTheme;

  @override
  State<BlenderApplicationScope<T>> createState() =>
      _BlenderApplicationScopeState<T>();
}

class _BlenderApplicationScopeState<T> extends State<BlenderApplicationScope<T>>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(widget.controller.editorSession.restore());
    final interfacePreferences = widget.controller.interfacePreferences;
    if (interfacePreferences != null) {
      unawaited(interfacePreferences.restore());
    }
    final themeService = widget.controller.themeService;
    if (themeService != null) unawaited(themeService.restore());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (interfacePreferences != null) await interfacePreferences.restore();
      if (themeService != null) await themeService.restore();
      if (!mounted) return;
      unawaited(
        widget.controller.presentation.showStartupSplash(
          context,
          enabled: interfacePreferences?.value.showSplash ?? true,
        ),
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(widget.controller.editorSession.flush());
      unawaited(widget.controller.interfacePreferences?.flush());
      unawaited(widget.controller.themeService?.flush());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.controller.editorSession.flush());
    unawaited(widget.controller.interfacePreferences?.flush());
    unawaited(widget.controller.themeService?.flush());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final child = BlenderCommandBindingScope(
      commands: controller.commands,
      bindings: controller.commandBindings,
      child: BlenderServiceScope(
        services: controller.services,
        child: BlenderStateScope<T>(
          store: controller.state,
          child: BlenderEditorSessionScope(
            session: controller.editorSession,
            child: widget.child,
          ),
        ),
      ),
    );
    final interfacePreferences = controller.interfacePreferences;
    if (interfacePreferences == null) return child;
    return BlenderInterfaceTheme(
      preferences: interfacePreferences,
      baseTheme: widget.baseTheme,
      themeService: controller.themeService,
      child: child,
    );
  }
}
