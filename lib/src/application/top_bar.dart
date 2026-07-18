part of '../application.dart';

/// Backwards-compatible name for the shared menu descriptor.
///
/// Application menus do not carry different semantics from other descriptor-
/// driven menus, so keeping a subclass would create a parallel vocabulary.
typedef BlenderApplicationMenu<T> = BlenderMenuDescriptor<T>;

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
    return _BlenderApplicationTopBarSurface(
      height: height,
      child: BlenderToolbar(
        height: height,
        scrollable: scrollable,
        background: theme.colors.topBar,
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

enum BlenderApplicationTopBarOverflow { workspaceOnly, shared }

class _BlenderApplicationTopBarSurface extends StatelessWidget {
  const _BlenderApplicationTopBarSurface({
    required this.child,
    this.height = 30,
  });

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colors.topBar,
        border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: child,
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
/// [overflow] selects whether only workspaces scroll or whether leading,
/// menus, workspaces, and workspace actions share one scroll surface. Fixed
/// context controls and trailing groups remain reachable in either mode.
class BlenderApplicationTopBar<MenuValue, WorkspaceValue>
    extends StatelessWidget {
  const BlenderApplicationTopBar({
    super.key,
    required this.menus,
    required this.workspaces,
    required this.activeWorkspace,
    required this.onWorkspaceSelected,
    this.leading = const <Widget>[],
    this.workspaceActions = const <Widget>[],
    this.contextControls = const <Widget>[],
    this.trailing = const <Widget>[],
    this.overflow = BlenderApplicationTopBarOverflow.workspaceOnly,
    this.height = 30,
  });

  final List<BlenderApplicationMenu<MenuValue>> menus;
  final List<BlenderApplicationWorkspace<WorkspaceValue>> workspaces;
  final WorkspaceValue activeWorkspace;
  final ValueChanged<WorkspaceValue> onWorkspaceSelected;
  final List<Widget> leading;

  /// Extra controls that follow the workspace tabs, such as Add Workspace.
  /// They remain in the scrolling/fading workspace region.
  final List<Widget> workspaceActions;

  /// Fixed document/scene controls placed before [trailing].
  final List<Widget> contextControls;

  /// Global controls fixed at the far right, such as AI actions or status.
  final List<Widget> trailing;
  final BlenderApplicationTopBarOverflow overflow;
  final double height;

  List<Widget> _menuWidgets(BlenderThemeData theme) => <Widget>[
    ...leading,
    for (final menu in menus) menu.build(),
    if ((leading.isNotEmpty || menus.isNotEmpty) &&
        workspaces.isNotEmpty) ...<Widget>[
      SizedBox(width: theme.density.spacing * 2),
      SizedBox(height: 22, child: ColoredBox(color: theme.colors.editorBorder)),
      SizedBox(width: theme.density.spacing * 2),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final prefix = _menuWidgets(theme);
    return _BlenderApplicationTopBarSurface(
      height: height,
      child: Row(
        children: <Widget>[
          if (overflow == BlenderApplicationTopBarOverflow.workspaceOnly)
            ...prefix,
          Expanded(
            child: _BlenderApplicationWorkspaceStrip<WorkspaceValue>(
              prefix: overflow == BlenderApplicationTopBarOverflow.shared
                  ? prefix
                  : const <Widget>[],
              workspaces: workspaces,
              activeWorkspace: activeWorkspace,
              onWorkspaceSelected: onWorkspaceSelected,
              actions: workspaceActions,
            ),
          ),
          ...contextControls,
          ...trailing,
        ],
      ),
    );
  }
}

class _BlenderApplicationWorkspaceStrip<T> extends StatefulWidget {
  const _BlenderApplicationWorkspaceStrip({
    this.prefix = const <Widget>[],
    required this.workspaces,
    required this.activeWorkspace,
    required this.onWorkspaceSelected,
    required this.actions,
  });

  final List<Widget> prefix;
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
    final background = theme.colors.topBar;
    final content = ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ...widget.prefix,
            for (final workspace in widget.workspaces)
              _workspaceButton(workspace),
            ...widget.actions,
          ],
        ),
      ),
    );
    return SizedBox(
      height: theme.density.rowHeight,
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
