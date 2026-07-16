import 'dart:async';

import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'docking.dart';
import 'docking_model.dart';
import 'layout.dart';
import 'non3d_editors.dart';
import 'services.dart';
import 'theme.dart';
import 'workspaces.dart';

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

/// Immutable descriptor for a selectable application workspace.
///
/// Workspaces are perspectives composed from editor areas. They are not
/// routes, editor types, or menu items.
class BlenderApplicationWorkspace<T> {
  const BlenderApplicationWorkspace({
    required this.value,
    required this.label,
    this.icon,
    this.selectedIcon,
    this.tooltip,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget? icon;
  final Widget? selectedIcon;
  final String? tooltip;
  final bool enabled;
}

/// Blender's application-level chrome: menus, workspace perspectives, and
/// fixed right-aligned action groups.
///
/// The menu row is deliberately not scrollable. Only workspace tabs scroll
/// beneath edge fades, so File/Edit/Window/Help and global action groups stay
/// in their expected positions as the available width changes.
class BlenderApplicationTopBar<MenuValue, WorkspaceValue>
    extends StatelessWidget {
  const BlenderApplicationTopBar({
    super.key,
    required this.menus,
    required this.workspaces,
    required this.activeWorkspace,
    required this.onWorkspaceSelected,
    this.workspaceActions = const <Widget>[],
    this.trailing = const <Widget>[],
  });

  final List<BlenderApplicationMenu<MenuValue>> menus;
  final List<BlenderApplicationWorkspace<WorkspaceValue>> workspaces;
  final WorkspaceValue activeWorkspace;
  final ValueChanged<WorkspaceValue> onWorkspaceSelected;

  /// Extra controls that follow the workspace tabs, such as Add Workspace.
  /// They remain in the scrolling/fading workspace region.
  final List<Widget> workspaceActions;

  /// Global controls fixed at the far right, such as AI actions or status.
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Row(
      children: <Widget>[
        for (final menu in menus)
          BlenderMenuButton<MenuValue>(
            label: menu.label,
            items: menu.items,
            enabled: menu.enabled,
            variant: BlenderButtonVariant.topBar,
            onSelected: menu.onSelected,
          ),
        if (menus.isNotEmpty && workspaces.isNotEmpty) ...<Widget>[
          SizedBox(width: theme.density.spacing * 2),
          SizedBox(
            height: 22,
            child: ColoredBox(color: theme.colors.editorBorder),
          ),
          SizedBox(width: theme.density.spacing * 2),
        ],
        Expanded(
          child: _BlenderApplicationWorkspaceStrip<WorkspaceValue>(
            workspaces: workspaces,
            activeWorkspace: activeWorkspace,
            onWorkspaceSelected: onWorkspaceSelected,
            actions: workspaceActions,
          ),
        ),
        ...trailing,
      ],
    );
  }
}

class _BlenderApplicationWorkspaceStrip<T> extends StatefulWidget {
  const _BlenderApplicationWorkspaceStrip({
    required this.workspaces,
    required this.activeWorkspace,
    required this.onWorkspaceSelected,
    required this.actions,
  });

  final List<BlenderApplicationWorkspace<T>> workspaces;
  final T activeWorkspace;
  final ValueChanged<T> onWorkspaceSelected;
  final List<Widget> actions;

  @override
  State<_BlenderApplicationWorkspaceStrip<T>> createState() =>
      _BlenderApplicationWorkspaceStripState<T>();
}

class _BlenderApplicationWorkspaceStripState<T>
    extends State<_BlenderApplicationWorkspaceStrip<T>> {
  final ScrollController _controller = ScrollController();
  bool _showLeftFade = false;
  bool _showRightFade = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_syncFades);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFades());
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_syncFades)
      ..dispose();
    super.dispose();
  }

  void _syncFades() {
    if (!_controller.hasClients) return;
    final showLeft = _controller.offset > 1;
    final showRight =
        _controller.offset < _controller.position.maxScrollExtent - 1;
    if (_showLeftFade == showLeft && _showRightFade == showRight) return;
    if (!mounted) return;
    setState(() {
      _showLeftFade = showLeft;
      _showRightFade = showRight;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final background = theme.colors.canvas;
    final content = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final workspace in widget.workspaces)
              _workspaceButton(workspace),
            ...widget.actions,
          ],
        ),
      ),
    );
    return SizedBox(
      height: theme.density.controlHeight,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          content,
          if (_showLeftFade)
            _BlenderApplicationTopBarFade(
              alignment: Alignment.centerLeft,
              background: background,
            ),
          if (_showRightFade)
            _BlenderApplicationTopBarFade(
              alignment: Alignment.centerRight,
              background: background,
            ),
        ],
      ),
    );
  }

  Widget _workspaceButton(BlenderApplicationWorkspace<T> workspace) {
    final button = BlenderButton(
      label: workspace.label,
      variant: BlenderButtonVariant.tab,
      selected: workspace.value == widget.activeWorkspace,
      leading: workspace.value == widget.activeWorkspace
          ? workspace.selectedIcon ?? workspace.icon
          : workspace.icon,
      onPressed: workspace.enabled
          ? () => widget.onWorkspaceSelected(workspace.value)
          : null,
    );
    final tooltip = workspace.tooltip;
    return tooltip == null
        ? button
        : BlenderTooltip(message: tooltip, child: button);
  }
}

class _BlenderApplicationTopBarFade extends StatelessWidget {
  const _BlenderApplicationTopBarFade({
    required this.alignment,
    required this.background,
  });

  final Alignment alignment;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;
    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      top: 0,
      bottom: 0,
      width: 28,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
              end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
              colors: <Color>[background, background.withAlpha(0)],
            ),
          ),
        ),
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

/// Framework-owned presenter for an application's temporary Preferences
/// window.
///
/// Applications own the actual preference sections and persistence. This
/// service owns only the menu-safe temporary-window presentation, so Edit >
/// Preferences has the same behavior in every BlenderUI application.
class BlenderPreferencesService {
  const BlenderPreferencesService({required this.configuration});

  final BlenderPreferencesConfiguration configuration;

  Future<void> show(BuildContext context) =>
      showBlenderPreferencesWindow(context, configuration: configuration);
}

/// Opens a source-shaped temporary Preferences window.
///
/// Use this from a menu command after the menu route has closed. The returned
/// future completes when the window is dismissed.
Future<void> showBlenderPreferencesWindow(
  BuildContext context, {
  required BlenderPreferencesConfiguration configuration,
}) {
  // A menu item removes its own popover route after its callback returns. Open
  // the temporary Preferences window in the next frame so that cleanup cannot
  // pop the newly created window. Centralizing this here lets every app use
  // the same safe presentation path, rather than repeating the workaround at
  // each Edit > Preferences command.
  final completion = Completer<void>();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!context.mounted) {
      completion.complete();
      return;
    }
    try {
      await showBlenderDialog<void>(
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
      completion.complete();
    } catch (error, stackTrace) {
      completion.completeError(error, stackTrace);
    }
  });
  return completion.future;
}

/// Owns the framework-level state needed by a dockable desktop application.
///
/// Domain state remains generic and immutable. The controller scopes its
/// history store and command registry through [services], allowing editors and
/// commands to share application state without a global singleton.
class BlenderApplicationController<T> implements BlenderServiceDisposable {
  BlenderApplicationController({
    required T initialState,
    BlenderDockNode<String>? workspace,
    BlenderWorkspaceService<String>? workspaceService,
    BlenderStateEquality<T>? stateEquals,
    this.historyLimit = 50,
  }) : assert(
         workspace != null || workspaceService != null,
         'Provide a workspace or workspaceService.',
       ),
       assert(
         workspace == null || workspaceService == null,
         'Provide either workspace or workspaceService, not both.',
       ),
       state = BlenderHistoryStore<T>(
         initialState,
         equals: stateEquals,
         historyLimit: historyLimit,
       ),
       workspaces =
           workspaceService ??
           BlenderWorkspaceService<String>(
             workspaces: <BlenderWorkspaceDefinition<String>>[
               BlenderWorkspaceDefinition<String>(
                 id: 'default',
                 layout: workspace!,
               ),
             ],
           ),
       commands = BlenderCommandRegistry(),
       services = BlenderServiceContainer() {
    services
      ..registerSingleton<BlenderHistoryStore<T>>(state)
      ..registerSingleton<BlenderWorkspaceService<String>>(workspaces)
      // Retain the original singleton for one-workspace applications.
      ..registerSingleton<BlenderDockingController<String>>(docking)
      ..registerSingleton<BlenderCommandRegistry>(commands);
    state.addListener(commands.refresh);
  }

  final int historyLimit;
  final BlenderHistoryStore<T> state;
  final BlenderWorkspaceService<String> workspaces;

  /// Backwards-compatible access to the active dock layout.
  BlenderDockingController<String> get docking => workspaces.activeController;
  final BlenderCommandRegistry commands;
  final BlenderServiceContainer services;
  bool _disposed = false;

  bool get isDisposed => _disposed;

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    state.removeListener(commands.refresh);
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
    showBlenderPreferencesWindow(navigatorContext, configuration: preferences);
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
                BlenderWorkspaceHost<String>(
                  service: controller.workspaces,
                  cloneArea: widget.cloneArea,
                  areaBuilder: widget.areaBuilder,
                ),
            statusBar: widget.statusBar,
          ),
        ),
      ),
    );
  }
}
