part of '../application.dart';

/// The reusable desktop application frame for a dockable Blender-style UI.
///
/// The shell deliberately accepts application-specific menus, editor-area
/// composition, and status widgets. It owns only reusable framework concerns:
/// app/theme setup, service/state scopes, docking layout, and an optional
/// temporary Preferences window.
class BlenderWorkspaceShell<T> extends StatefulWidget {
  const BlenderWorkspaceShell({
    super.key,
    required this.controller,
    required this.areaBuilder,
    this.workspaceContent,
    this.cloneArea,
    this.topBar,
    this.statusBar,
    this.preferences,
    this.title = 'Blender UI',
    this.theme = const BlenderThemeData(),
    this.navigatorKey,
  });

  final BlenderApplicationController<T> controller;
  final BlenderDockAreaBuilder<String> areaBuilder;

  /// Optional application-specific content that replaces the dock workspace.
  ///
  /// This is useful for a catalog, welcome screen, or other non-editor
  /// workspace while retaining the same app frame and service scopes.
  final Widget? workspaceContent;
  final String Function(String value)? cloneArea;
  final Widget? topBar;
  final Widget? statusBar;
  final BlenderPreferencesConfiguration? preferences;
  final String title;
  final BlenderThemeData theme;
  final GlobalKey<NavigatorState>? navigatorKey;

  @override
  State<BlenderWorkspaceShell<T>> createState() =>
      _BlenderWorkspaceShellState<T>();
}

class _BlenderWorkspaceShellState<T> extends State<BlenderWorkspaceShell<T>>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Restore after the shell has installed the application's scopes. The
    // service starts from declared defaults meanwhile, so a missing or stale
    // session never blocks first paint.
    unawaited(widget.controller.workspaces.restore());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(widget.controller.workspaces.flush());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(widget.controller.workspaces.flush());
    super.dispose();
  }

  /// Opens the configured Preferences window, if this shell exposes one.
  void showPreferences() {
    final preferences =
        widget.preferences ?? widget.controller.preferences?.configuration;
    if (preferences == null) return;
    final navigatorContext = widget.navigatorKey?.currentContext ?? context;
    showBlenderPreferencesWindow(navigatorContext, configuration: preferences);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return BlenderApp(
      title: widget.title,
      theme: widget.theme,
      navigatorKey: widget.navigatorKey,
      home: BlenderApplicationScope<T>(
        controller: controller,
        baseTheme: widget.theme,
        child: BlenderEditorShell(
          topBar: widget.topBar,
          main:
              widget.workspaceContent ??
              BlenderWorkspaceHost<String>(
                service: controller.workspaces,
                cloneArea: widget.cloneArea,
                areaBuilder: widget.areaBuilder,
              ),
          statusBar: widget.statusBar,
        ),
      ),
    );
  }
}
