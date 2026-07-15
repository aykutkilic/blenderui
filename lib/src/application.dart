import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'docking.dart';
import 'docking_model.dart';
import 'layout.dart';
import 'non3d_editors.dart';
import 'services.dart';
import 'theme.dart';

/// A top-level application menu descriptor for [BlenderApplicationMenuBar].
///
/// The menu's values and command routing remain application-owned; the
/// framework only provides the desktop menu-bar presentation.
class BlenderApplicationMenu<T> {
  const BlenderApplicationMenu({
    required this.label,
    required this.items,
    this.onSelected,
    this.enabled = true,
  });

  final String label;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onSelected;
  final bool enabled;
}

/// A reusable Blender-style top application menu bar.
///
/// [leading] and [trailing] allow applications to place branding, workspace
/// selectors, or document controls around the descriptor-driven menus without
/// reimplementing the toolbar, scroll, and border anatomy.
class BlenderApplicationMenuBar<T> extends StatelessWidget {
  const BlenderApplicationMenuBar({
    super.key,
    required this.menus,
    this.leading = const <Widget>[],
    this.trailing = const <Widget>[],
    this.height = 30,
    this.scrollable = true,
  });

  final List<BlenderApplicationMenu<T>> menus;
  final List<Widget> leading;
  final List<Widget> trailing;
  final double height;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colors.canvas,
        border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: BlenderToolbar(
        height: height,
        scrollable: scrollable,
        background: theme.colors.canvas,
        children: <Widget>[
          ...leading,
          for (final menu in menus)
            BlenderMenuButton<T>(
              label: menu.label,
              items: menu.items,
              enabled: menu.enabled,
              variant: BlenderButtonVariant.topBar,
              onSelected: menu.onSelected,
            ),
          ...trailing,
        ],
      ),
    );
  }
}

/// Immutable inputs for the optional Preferences window in a
/// [BlenderWorkspaceShell].
///
/// Preference values and persistence remain application-owned. This object
/// only describes how the reusable Preferences editor is presented.
class BlenderPreferencesConfiguration {
  const BlenderPreferencesConfiguration({
    required this.categories,
    required this.sections,
    this.categoryGroups = const <BlenderPreferenceCategoryGroup>[],
    this.initialCategory,
    this.title = 'Preferences',
    this.width = 1040,
    this.height = 700,
    this.onCategoryChanged,
  });

  final List<String> categories;
  final List<BlenderPreferenceSection> sections;
  final List<BlenderPreferenceCategoryGroup> categoryGroups;
  final String? initialCategory;
  final String title;
  final double width;
  final double height;
  final ValueChanged<String>? onCategoryChanged;
}

/// Opens a source-shaped temporary Preferences window.
///
/// Use this from a menu command after the menu route has closed. The returned
/// future completes when the window is dismissed.
Future<void> showBlenderPreferencesWindow(
  BuildContext context, {
  required BlenderPreferencesConfiguration configuration,
}) {
  return showBlenderDialog<void>(
    context: context,
    barrierLabel: 'Dismiss ${configuration.title}',
    builder: (_) => BlenderPreferencesWindow(
      categories: configuration.categories,
      categoryGroups: configuration.categoryGroups,
      sections: configuration.sections,
      initialCategory: configuration.initialCategory,
      title: configuration.title,
      width: configuration.width,
      height: configuration.height,
      onCategoryChanged: configuration.onCategoryChanged,
    ),
  );
}

/// Owns the framework-level state needed by a dockable desktop application.
///
/// Domain state remains generic and immutable. The controller scopes its
/// history store and command registry through [services], allowing editors and
/// commands to share application state without a global singleton.
class BlenderApplicationController<T> implements BlenderServiceDisposable {
  BlenderApplicationController({
    required T initialState,
    required BlenderDockNode<String> workspace,
    BlenderStateEquality<T>? stateEquals,
    this.historyLimit = 50,
  }) : state = BlenderHistoryStore<T>(
         initialState,
         equals: stateEquals,
         historyLimit: historyLimit,
       ),
       docking = BlenderDockingController<String>(root: workspace),
       commands = BlenderCommandRegistry(),
       services = BlenderServiceContainer() {
    services
      ..registerSingleton<BlenderHistoryStore<T>>(state)
      ..registerSingleton<BlenderDockingController<String>>(docking)
      ..registerSingleton<BlenderCommandRegistry>(commands);
    state.addListener(commands.refresh);
  }

  final int historyLimit;
  final BlenderHistoryStore<T> state;
  final BlenderDockingController<String> docking;
  final BlenderCommandRegistry commands;
  final BlenderServiceContainer services;
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    state.removeListener(commands.refresh);
    docking.dispose();
    services.dispose();
  }
}

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

class _BlenderWorkspaceShellState<T> extends State<BlenderWorkspaceShell<T>> {
  /// Opens the configured Preferences window, if this shell exposes one.
  void showPreferences() {
    final preferences = widget.preferences;
    if (preferences == null) return;
    final navigatorContext = widget.navigatorKey?.currentContext ?? context;
    // Menu popovers remove their route in the action frame. Deferring the
    // dialog preserves the new route instead of allowing that cleanup to pop it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showBlenderPreferencesWindow(
        navigatorContext,
        configuration: preferences,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return BlenderApp(
      title: widget.title,
      theme: widget.theme,
      navigatorKey: widget.navigatorKey,
      home: BlenderServiceScope(
        services: controller.services,
        child: BlenderStateScope<T>(
          store: controller.state,
          child: BlenderEditorShell(
            topBar: widget.topBar,
            main:
                widget.workspaceContent ??
                BlenderDockingWorkspace<String>(
                  controller: controller.docking,
                  cloneValue: widget.cloneArea,
                  areaBuilder: widget.areaBuilder,
                ),
            statusBar: widget.statusBar,
          ),
        ),
      ),
    );
  }
}
