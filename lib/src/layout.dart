import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'icons.dart';
import 'theme.dart';

class BlenderPanel extends StatelessWidget {
  const BlenderPanel({
    super.key,
    this.title,
    this.child,
    this.headerActions,
    this.padding,
    this.backgroundColor,
    this.headerLeading,
    this.headerTitleStyle,
    this.headerHandle,
    this.showHandle = false,
    this.collapsible = false,
    this.initiallyExpanded = true,
    this.expanded,
    this.onExpansionChanged,
  });

  final String? title;
  final Widget? child;
  final List<Widget>? headerActions;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Widget? headerLeading;
  final TextStyle? headerTitleStyle;
  final Widget? headerHandle;
  final bool showHandle;
  final bool collapsible;
  final bool initiallyExpanded;
  final bool? expanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final content = child == null
        ? const SizedBox.shrink()
        : Padding(
            padding: padding ?? EdgeInsets.all(theme.density.panelPadding),
            child: child,
          );
    if (title == null) return content;
    if (!collapsible) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final body = constraints.hasBoundedHeight
              ? Flexible(child: content)
              : content;
          return ClipRRect(
            borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor ?? theme.colors.panelBackground,
                border: Border.all(color: theme.colors.panelOutline),
                borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  BlenderPanelHeader(
                    title: title!,
                    actions: headerActions,
                    leading: headerLeading,
                    titleStyle: headerTitleStyle,
                    handle: headerHandle,
                    showHandle: showHandle,
                  ),
                  body,
                ],
              ),
            ),
          );
        },
      );
    }
    return _CollapsiblePanel(
      title: title!,
      actions: headerActions,
      content: content,
      initiallyExpanded: initiallyExpanded,
      expanded: expanded,
      backgroundColor: backgroundColor,
      leading: headerLeading,
      titleStyle: headerTitleStyle,
      handle: headerHandle,
      showHandle: showHandle,
      onExpansionChanged: onExpansionChanged,
    );
  }
}

class BlenderPanelHeader extends StatelessWidget {
  const BlenderPanelHeader({
    super.key,
    required this.title,
    this.actions,
    this.onTap,
    this.expanded = true,
    this.leading,
    this.titleStyle,
    this.handle,
    this.showHandle = false,
  });

  final String title;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final bool expanded;
  final Widget? leading;
  final TextStyle? titleStyle;
  final Widget? handle;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: theme.density.headerHeight,
        padding: EdgeInsets.symmetric(horizontal: theme.density.panelPadding),
        decoration: BoxDecoration(color: theme.colors.panelHeader),
        child: Row(
          children: <Widget>[
            if (onTap != null)
              BlenderIcon(
                expanded
                    ? BlenderGlyph.panelDisclosureDown
                    : BlenderGlyph.panelDisclosureRight,
                size: 9,
                color: theme.colors.foregroundMuted,
              ),
            if (onTap != null) SizedBox(width: theme.density.spacing / 2),
            if (leading != null) ...<Widget>[
              leading!,
              SizedBox(width: theme.density.spacing),
            ],
            Expanded(
              child: Text(
                title,
                style: titleStyle ?? theme.textTheme.panelTitle,
              ),
            ),
            if (actions case final actions? when actions.isNotEmpty)
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(mainAxisSize: MainAxisSize.min, children: actions),
                ),
              ),
            if (handle != null)
              handle!
            else if (showHandle)
              Padding(
                padding: EdgeInsets.only(left: theme.density.spacing / 2),
                child: BlenderIcon(
                  BlenderGlyph.dragHandle,
                  size: 7,
                  color: theme.colors.foreground.withAlpha(128),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CollapsiblePanel extends StatefulWidget {
  const _CollapsiblePanel({
    required this.title,
    required this.content,
    required this.initiallyExpanded,
    this.expanded,
    this.actions,
    this.leading,
    this.titleStyle,
    this.handle,
    this.backgroundColor,
    this.showHandle = false,
    this.onExpansionChanged,
  });

  final String title;
  final Widget content;
  final bool initiallyExpanded;
  final bool? expanded;
  final List<Widget>? actions;
  final Widget? leading;
  final TextStyle? titleStyle;
  final Widget? handle;
  final Color? backgroundColor;
  final bool showHandle;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  State<_CollapsiblePanel> createState() => _CollapsiblePanelState();
}

class _CollapsiblePanelState extends State<_CollapsiblePanel> {
  late bool _expanded = widget.initiallyExpanded;

  bool get _effectiveExpanded => widget.expanded ?? _expanded;

  void _toggleExpanded() {
    final expanded = !_effectiveExpanded;
    if (widget.expanded == null) {
      setState(() => _expanded = expanded);
    }
    widget.onExpansionChanged?.call(expanded);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final radius = BorderRadius.circular(theme.shapes.panelRadius);
    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? theme.colors.panelBackground,
          border: Border.all(color: theme.colors.panelOutline),
          borderRadius: radius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderPanelHeader(
              title: widget.title,
              actions: widget.actions,
              expanded: _effectiveExpanded,
              leading: widget.leading,
              titleStyle: widget.titleStyle,
              handle: widget.handle,
              showHandle: widget.showHandle,
              onTap: _toggleExpanded,
            ),
            if (_effectiveExpanded) widget.content,
          ],
        ),
      ),
    );
  }
}

class BlenderToolbar extends StatefulWidget {
  const BlenderToolbar({
    super.key,
    required this.children,
    this.height,
    this.scrollable = false,
    this.background,
    this.edgeFade = true,
  });

  final List<Widget> children;
  final double? height;
  final bool scrollable;
  final Color? background;
  final bool edgeFade;

  @override
  State<BlenderToolbar> createState() => _BlenderToolbarState();
}

Widget _blenderHeaderScrollSurface(BuildContext context, Widget child) {
  return ScrollConfiguration(
    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
    child: child,
  );
}

class _BlenderToolbarState extends State<BlenderToolbar> {
  late final ScrollController _scrollController;
  bool _showLeftFade = false;
  bool _showRightFade = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_syncFadeState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFadeState());
  }

  void _syncFadeState() {
    if (!_scrollController.hasClients) return;
    final showLeft = _scrollController.offset > 1;
    final showRight =
        _scrollController.offset <
        _scrollController.position.maxScrollExtent - 1;
    if (showLeft == _showLeftFade && showRight == _showRightFade) return;
    if (!mounted) return;
    setState(() {
      _showLeftFade = showLeft;
      _showRightFade = showRight;
    });
  }

  Widget _content(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final row = Row(
      mainAxisSize: widget.scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: <Widget>[
        for (var i = 0; i < widget.children.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: theme.density.spacing),
          widget.children[i],
        ],
      ],
    );
    if (!widget.scrollable) return row;
    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      constrainedAxis: Axis.vertical,
      child: row,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncFadeState)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    // Blender headers use the themed header surface (`#303030` in the default
    // dark theme), not the darker editor body behind them.
    final background = widget.background ?? theme.colors.surfaceElevated;
    final content = widget.scrollable
        ? _blenderHeaderScrollSurface(
            context,
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: _content(context),
            ),
          )
        : _content(context);
    return Container(
      height: widget.height ?? theme.density.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: theme.density.panelPadding),
      decoration: BoxDecoration(
        color: background,
        border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: widget.scrollable && widget.edgeFade
          ? Stack(
              fit: StackFit.expand,
              children: <Widget>[
                content,
                if (_showLeftFade)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 28,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: <Color>[
                              background,
                              background.withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (_showRightFade)
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 28,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerRight,
                            end: Alignment.centerLeft,
                            colors: <Color>[
                              background,
                              background.withAlpha(0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : content,
    );
  }
}

class BlenderBox extends StatelessWidget {
  const BlenderBox({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
    this.radius,
  });

  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final Color? borderColor;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.colors.panelSubSurface,
        border: Border.all(color: borderColor ?? theme.colors.editorBorder),
        borderRadius: BorderRadius.circular(radius ?? theme.shapes.panelRadius),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(theme.density.panelPadding),
        child: child,
      ),
    );
  }
}

class BlenderFlow extends StatelessWidget {
  const BlenderFlow({
    super.key,
    required this.children,
    this.spacing = 4,
    this.runSpacing = 4,
    this.alignment = WrapAlignment.start,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      children: children,
    );
  }
}

class BlenderGrid extends StatelessWidget {
  const BlenderGrid({
    super.key,
    required this.children,
    this.minItemWidth = 100,
    this.itemHeight = 80,
    this.spacing = 4,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double itemHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = math.max(
          1,
          (constraints.maxWidth / minItemWidth).floor(),
        );
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: itemHeight,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}

class BlenderOverlap extends StatelessWidget {
  const BlenderOverlap({
    super.key,
    required this.children,
    this.fit = StackFit.loose,
  });

  final List<Widget> children;
  final StackFit fit;

  @override
  Widget build(BuildContext context) {
    return Stack(fit: fit, children: children);
  }
}

enum BlenderEditorType {
  view3d,
  imageEditor,
  uvEditor,
  compositor,
  textureNodeEditor,
  shaderEditor,
  geometryNodeEditor,
  timeline,
  dopeSheet,
  graphEditor,
  nlaEditor,
  sequencer,
  clipEditor,
  videoEditing,
  drivers,
  textEditor,
  pythonConsole,
  infoEditor,
  outliner,
  properties,
  preferences,
  fileBrowser,
  assetBrowser,
  spreadsheet,
  project,
}

extension BlenderEditorTypePresentation on BlenderEditorType {
  String get label => switch (this) {
    BlenderEditorType.view3d => '3D Viewport',
    BlenderEditorType.imageEditor => 'Image Editor',
    BlenderEditorType.uvEditor => 'UV Editor',
    BlenderEditorType.compositor => 'Compositor',
    BlenderEditorType.textureNodeEditor => 'Texture Node Editor',
    BlenderEditorType.shaderEditor => 'Shader Editor',
    BlenderEditorType.geometryNodeEditor => 'Geometry Node Editor',
    BlenderEditorType.timeline => 'Timeline',
    BlenderEditorType.dopeSheet => 'Dope Sheet',
    BlenderEditorType.graphEditor => 'Graph Editor',
    BlenderEditorType.nlaEditor => 'Nonlinear Animation',
    BlenderEditorType.sequencer => 'Video Sequencer',
    BlenderEditorType.clipEditor => 'Movie Clip Editor',
    BlenderEditorType.videoEditing => 'Video Editing',
    BlenderEditorType.drivers => 'Drivers',
    BlenderEditorType.textEditor => 'Text Editor',
    BlenderEditorType.pythonConsole => 'Python Console',
    BlenderEditorType.infoEditor => 'Info',
    BlenderEditorType.outliner => 'Outliner',
    BlenderEditorType.properties => 'Properties',
    BlenderEditorType.preferences => 'Preferences',
    BlenderEditorType.fileBrowser => 'File Browser',
    BlenderEditorType.assetBrowser => 'Asset Browser',
    BlenderEditorType.spreadsheet => 'Spreadsheet',
    BlenderEditorType.project => 'Project',
  };

  BlenderGlyph get glyph => switch (this) {
    BlenderEditorType.view3d => BlenderGlyph.cube,
    BlenderEditorType.imageEditor => BlenderGlyph.image,
    BlenderEditorType.uvEditor => BlenderGlyph.uv,
    BlenderEditorType.compositor ||
    BlenderEditorType.textureNodeEditor ||
    BlenderEditorType.shaderEditor ||
    BlenderEditorType.geometryNodeEditor => BlenderGlyph.node,
    BlenderEditorType.timeline ||
    BlenderEditorType.dopeSheet ||
    BlenderEditorType.graphEditor ||
    BlenderEditorType.nlaEditor => BlenderGlyph.timeline,
    BlenderEditorType.sequencer ||
    BlenderEditorType.videoEditing => BlenderGlyph.sequence,
    BlenderEditorType.clipEditor => BlenderGlyph.movie,
    BlenderEditorType.drivers => BlenderGlyph.timeline,
    BlenderEditorType.textEditor => BlenderGlyph.text,
    BlenderEditorType.pythonConsole => BlenderGlyph.console,
    BlenderEditorType.infoEditor => BlenderGlyph.info,
    BlenderEditorType.outliner => BlenderGlyph.outliner,
    BlenderEditorType.properties => BlenderGlyph.properties,
    BlenderEditorType.preferences => BlenderGlyph.settings,
    BlenderEditorType.fileBrowser => BlenderGlyph.folder,
    BlenderEditorType.assetBrowser => BlenderGlyph.folder,
    BlenderEditorType.spreadsheet => BlenderGlyph.spreadsheet,
    BlenderEditorType.project => BlenderGlyph.folder,
  };

  String get description => switch (this) {
    BlenderEditorType.view3d => 'Manipulate objects in a 3D environment',
    BlenderEditorType.imageEditor => 'View and edit image data',
    BlenderEditorType.uvEditor => 'Unwrap and edit UV coordinates',
    BlenderEditorType.compositor => 'Compose rendered image data',
    BlenderEditorType.textureNodeEditor => 'Build texture node graphs',
    BlenderEditorType.shaderEditor => 'Build shader node graphs',
    BlenderEditorType.geometryNodeEditor => 'Build geometry node graphs',
    BlenderEditorType.timeline => 'Control playback and frame range',
    BlenderEditorType.dopeSheet => 'Edit animation keys and channels',
    BlenderEditorType.graphEditor => 'Edit animation curves',
    BlenderEditorType.nlaEditor => 'Arrange non-linear animation strips',
    BlenderEditorType.drivers => 'Edit animation drivers',
    BlenderEditorType.sequencer => 'Arrange video and audio strips',
    BlenderEditorType.videoEditing => 'Arrange video editing strips',
    BlenderEditorType.clipEditor => 'Track and edit movie clips',
    BlenderEditorType.textEditor => 'Edit text data and scripts',
    BlenderEditorType.pythonConsole => 'Run Python commands',
    BlenderEditorType.infoEditor => 'Review application reports',
    BlenderEditorType.outliner => 'Browse scene data hierarchies',
    BlenderEditorType.properties => 'Edit context-sensitive properties',
    BlenderEditorType.preferences => 'Configure Blender preferences',
    BlenderEditorType.fileBrowser => 'Browse files and directories',
    BlenderEditorType.assetBrowser => 'Browse reusable assets',
    BlenderEditorType.spreadsheet => 'Inspect tabular data',
    BlenderEditorType.project => 'Manage project settings and files',
  };

  String? get shortcut => switch (this) {
    BlenderEditorType.view3d => '⇧ F5',
    BlenderEditorType.imageEditor || BlenderEditorType.uvEditor => '⇧ F10',
    BlenderEditorType.dopeSheet || BlenderEditorType.timeline => '⇧ F12',
    BlenderEditorType.graphEditor || BlenderEditorType.drivers => '⇧ F6',
    BlenderEditorType.textEditor => '⇧ F11',
    BlenderEditorType.pythonConsole => '⇧ F4',
    BlenderEditorType.infoEditor => null,
    BlenderEditorType.project => null,
    BlenderEditorType.geometryNodeEditor ||
    BlenderEditorType.compositor ||
    BlenderEditorType.shaderEditor ||
    BlenderEditorType.textureNodeEditor => '⇧ F3',
    BlenderEditorType.sequencer || BlenderEditorType.videoEditing => '⇧ F8',
    BlenderEditorType.clipEditor => '⇧ F2',
    _ => '⇧ F1',
  };
}

class BlenderEditorTypeSelector extends StatefulWidget {
  const BlenderEditorTypeSelector({
    super.key,
    required this.value,
    this.onChanged,
    this.width,
    this.compact = false,
  });

  final BlenderEditorType value;
  final ValueChanged<BlenderEditorType>? onChanged;
  final double? width;
  final bool compact;

  @override
  State<BlenderEditorTypeSelector> createState() =>
      _BlenderEditorTypeSelectorState();
}

class _BlenderEditorTypeSelectorState extends State<BlenderEditorTypeSelector> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final button = BlenderButton(
      label: widget.compact ? '' : widget.value.label,
      leading: BlenderIcon(widget.value.glyph, size: widget.compact ? 17 : 14),
      trailing: const BlenderIcon(BlenderGlyph.panelDisclosureDown, size: 9),
      padding: widget.compact ? EdgeInsets.zero : null,
      selected: _open,
      variant: BlenderButtonVariant.menuTrigger,
      onPressed: widget.onChanged == null ? null : () {},
    );
    return SizedBox(
      width: widget.width ?? (widget.compact ? 76 : 132),
      child: BlenderPopover(
        onOpenChanged: (open) {
          if (mounted) setState(() => _open = open);
        },
        child: BlenderTooltip(
          message: widget.value.label,
          content: _BlenderEditorTypeTooltip(value: widget.value),
          child: IgnorePointer(child: button),
        ),
        popover: (context, close) => _BlenderEditorTypeMenu(
          selected: widget.value,
          onSelected: (next) {
            widget.onChanged?.call(next);
            close();
          },
        ),
      ),
    );
  }
}

class _BlenderEditorTypeTooltip extends StatelessWidget {
  const _BlenderEditorTypeTooltip({required this.value});

  final BlenderEditorType value;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: 'Editor Type: ', style: theme.textTheme.body),
                TextSpan(
                  text: value.label,
                  style: theme.textTheme.body.copyWith(
                    color: theme.colors.link,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(value.description, style: theme.textTheme.body),
          if (value.shortcut != null) ...<Widget>[
            const SizedBox(height: 4),
            Text('Shortcut: ${value.shortcut}', style: theme.textTheme.body),
          ],
        ],
      ),
    );
  }
}

class _BlenderEditorTypeMenu extends StatelessWidget {
  const _BlenderEditorTypeMenu({
    required this.selected,
    required this.onSelected,
  });

  final BlenderEditorType selected;
  final ValueChanged<BlenderEditorType> onSelected;

  static const _categories = <({String title, List<BlenderEditorType> items})>[
    (
      title: 'General',
      items: <BlenderEditorType>[
        BlenderEditorType.view3d,
        BlenderEditorType.imageEditor,
        BlenderEditorType.uvEditor,
        BlenderEditorType.geometryNodeEditor,
        BlenderEditorType.compositor,
        BlenderEditorType.shaderEditor,
        BlenderEditorType.textureNodeEditor,
        BlenderEditorType.sequencer,
        BlenderEditorType.clipEditor,
      ],
    ),
    (
      title: 'Animation',
      items: <BlenderEditorType>[
        BlenderEditorType.dopeSheet,
        BlenderEditorType.timeline,
        BlenderEditorType.graphEditor,
        BlenderEditorType.drivers,
        BlenderEditorType.nlaEditor,
      ],
    ),
    (
      title: 'Scripting',
      items: <BlenderEditorType>[
        BlenderEditorType.textEditor,
        BlenderEditorType.pythonConsole,
        BlenderEditorType.infoEditor,
      ],
    ),
    (
      title: 'Data',
      items: <BlenderEditorType>[
        BlenderEditorType.outliner,
        BlenderEditorType.properties,
        BlenderEditorType.fileBrowser,
        BlenderEditorType.assetBrowser,
        BlenderEditorType.spreadsheet,
        BlenderEditorType.preferences,
        BlenderEditorType.project,
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: BlenderMultiColumnMenu<BlenderEditorType>(
        groups: <BlenderMultiColumnMenuGroup<BlenderEditorType>>[
          for (final category in _categories)
            BlenderMultiColumnMenuGroup<BlenderEditorType>(
              id: category.title,
              title: category.title,
              items: <BlenderMultiColumnMenuItem<BlenderEditorType>>[
                for (final item in category.items)
                  BlenderMultiColumnMenuItem<BlenderEditorType>(
                    id: item.name,
                    value: item,
                    label: item.label,
                    glyph: item.glyph,
                    trailingLabel: item.shortcut,
                  ),
              ],
            ),
        ],
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}

/// A descriptor for one category in a compact Blender-style menu.
///
/// Applications provide their own values and labels; BlenderUI owns the
/// shared geometry, highlighting, and menu chrome used by editor-type menus.
class BlenderMultiColumnMenuGroup<T> {
  const BlenderMultiColumnMenuGroup({
    required this.id,
    required this.title,
    required this.items,
  });

  final String id;
  final String title;
  final List<BlenderMultiColumnMenuItem<T>> items;
}

/// A selectable entry in a [BlenderMultiColumnMenuGroup].
class BlenderMultiColumnMenuItem<T> {
  const BlenderMultiColumnMenuItem({
    required this.id,
    required this.value,
    required this.label,
    required this.glyph,
    this.trailingLabel,
    this.enabled = true,
  });

  final String id;
  final T value;
  final String label;
  final BlenderGlyph glyph;
  final String? trailingLabel;
  final bool enabled;
}

/// The compact, four-or-more-column menu used for Blender editor types and
/// application-owned type pickers.
///
/// It intentionally uses the same 24px rows, 11px labels, and 12px column
/// gaps as Blender's editor-type popover. It is data-driven so applications do
/// not need to fork a visual control merely to present a different catalogue.
class BlenderMultiColumnMenu<T> extends StatelessWidget {
  const BlenderMultiColumnMenu({
    super.key,
    required this.groups,
    required this.onSelected,
    this.selected,
    this.menuId,
    this.semanticLabel,
    this.maxWidth = 820,
  });

  final List<BlenderMultiColumnMenuGroup<T>> groups;
  final T? selected;
  final ValueChanged<T>? onSelected;
  final String? menuId;
  final String? semanticLabel;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Semantics(
      label: semanticLabel ?? 'Multi-column menu',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.min(maxWidth, constraints.maxWidth).toDouble();
          return SizedBox(
            width: width,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.menuBackground,
                border: Border.all(color: theme.colors.borderSubtle),
                borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (
                      var index = 0;
                      index < groups.length;
                      index++
                    ) ...<Widget>[
                      if (index > 0) const SizedBox(width: 12),
                      Expanded(
                        child: _BlenderMultiColumnMenuCategory<T>(
                          group: groups[index],
                          selected: selected,
                          onSelected: onSelected,
                          menuId: menuId,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlenderMultiColumnMenuCategory<T> extends StatelessWidget {
  const _BlenderMultiColumnMenuCategory({
    required this.group,
    required this.selected,
    required this.onSelected,
    required this.menuId,
  });

  final BlenderMultiColumnMenuGroup<T> group;
  final T? selected;
  final ValueChanged<T>? onSelected;
  final String? menuId;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Column(
      key: menuId == null
          ? null
          : ValueKey<String>('$menuId-group-${group.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            group.title,
            style: theme.textTheme.heading.copyWith(fontSize: 11),
          ),
        ),
        SizedBox(
          height: 1,
          child: ColoredBox(color: theme.colors.borderSubtle),
        ),
        const SizedBox(height: 4),
        for (final item in group.items)
          _BlenderMultiColumnMenuEntry<T>(
            item: item,
            selected: item.value == selected,
            enabled: item.enabled && onSelected != null,
            onTap: onSelected == null ? null : () => onSelected!(item.value),
            itemKey: menuId == null
                ? null
                : ValueKey<String>('$menuId-item-${item.id}'),
          ),
      ],
    );
  }
}

class _BlenderMultiColumnMenuEntry<T> extends StatefulWidget {
  const _BlenderMultiColumnMenuEntry({
    required this.item,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.itemKey,
  });

  final BlenderMultiColumnMenuItem<T> item;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final Key? itemKey;

  @override
  State<_BlenderMultiColumnMenuEntry<T>> createState() =>
      _BlenderMultiColumnMenuEntryState<T>();
}

class _BlenderMultiColumnMenuEntryState<T>
    extends State<_BlenderMultiColumnMenuEntry<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final highlighted = widget.selected || (_hovered && widget.enabled);
    return MouseRegion(
      cursor: widget.enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: widget.enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: widget.enabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? widget.onTap : null,
        child: Container(
          key: widget.itemKey,
          height: 24,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: highlighted ? theme.colors.menuSelection : null,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Row(
            children: <Widget>[
              BlenderIcon(
                widget.item.glyph,
                size: 15,
                color: widget.enabled ? null : theme.colors.foregroundDisabled,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.item.label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.body.copyWith(
                    fontSize: 11,
                    height: 1.1,
                    color: widget.enabled
                        ? null
                        : theme.colors.foregroundDisabled,
                  ),
                ),
              ),
              if (widget.item.trailingLabel != null)
                Text(
                  widget.item.trailingLabel!,
                  style: theme.textTheme.caption.copyWith(fontSize: 9),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlenderAreaHeader extends StatelessWidget {
  const BlenderAreaHeader({
    super.key,
    required this.editorType,
    this.onEditorTypeChanged,
    this.menus = const <Widget>[],
    this.leading = const <Widget>[],
    this.actions = const <Widget>[],
    this.center,
    this.background,
    this.height,
    this.showEditorLabel = true,
    this.editorSelectorWidth,
    this.showBottomBorder = true,
    this.actionsScrollable = false,
  });

  final BlenderEditorType editorType;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final List<Widget> menus;
  final List<Widget> leading;
  final List<Widget> actions;
  final Widget? center;
  final Color? background;
  final double? height;
  final bool showEditorLabel;
  final double? editorSelectorWidth;
  final bool showBottomBorder;
  final bool actionsScrollable;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Container(
      height: height ?? theme.density.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: theme.density.panelPadding),
      decoration: BoxDecoration(
        color: background ?? theme.colors.surface,
        border: showBottomBorder
            ? Border(bottom: BorderSide(color: theme.colors.editorBorder))
            : const Border(),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: editorSelectorWidth ?? (showEditorLabel ? 132 : 76),
                child: BlenderEditorTypeSelector(
                  value: editorType,
                  compact: !showEditorLabel,
                  onChanged: onEditorTypeChanged,
                ),
              ),
              ...leading,
              Expanded(
                child: actionsScrollable
                    ? Row(
                        children: <Widget>[
                          Expanded(
                            child: _blenderHeaderScrollSurface(
                              context,
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: menus,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: _blenderHeaderScrollSurface(
                              context,
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: actions,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _blenderHeaderScrollSurface(
                        context,
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: menus,
                          ),
                        ),
                      ),
              ),
              if (!actionsScrollable) ...actions,
            ],
          ),
          if (center != null) Center(child: center),
        ],
      ),
    );
  }
}

/// A compact Blender ID-template control.
///
/// Blender uses this composition for the Scene and View Layer controls in the
/// top header: a browse selector, a rename field, and compact data-block
/// actions. The optional pin is intentionally part of the rename field rather
/// than a separate toolbar button (matching `template_ID()` in Blender).
class BlenderDataBlockGroup<T> extends StatelessWidget {
  const BlenderDataBlockGroup({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.onNamePressed,
    this.onPin,
    this.onDuplicate,
    this.onClose,
    this.tooltip,
    this.nameWidth = 96,
    this.selectorWidth = 30,
  });

  final T value;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onChanged;
  final VoidCallback? onNamePressed;
  final VoidCallback? onPin;
  final VoidCallback? onDuplicate;
  final VoidCallback? onClose;
  final String? tooltip;
  final double nameWidth;
  final double selectorWidth;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    BlenderMenuItem<T>? selectedItem;
    for (final item in items) {
      if (item.value == value) {
        selectedItem = item;
        break;
      }
    }
    Widget divider() => SizedBox(
      width: 1,
      height: 22,
      child: ColoredBox(color: theme.colors.editorOutline),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 22,
        decoration: BoxDecoration(
          color: theme.colors.textField,
          border: Border.all(color: theme.colors.editorOutline),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BlenderPopover(
              offset: const Offset(0, 2),
              child: SizedBox(
                width: selectorWidth - 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (selectedItem?.icon != null) selectedItem!.icon!,
                      const SizedBox(width: 2),
                      BlenderIcon(
                        key: ValueKey<String>(
                          'data-block-selector-disclosure-$value',
                        ),
                        BlenderGlyph.panelDisclosureDown,
                        size: 9,
                        color: theme.colors.foregroundMuted,
                      ),
                    ],
                  ),
                ),
              ),
              popover: (context, close) => BlenderMenu<T>(
                items: <BlenderMenuItem<T>>[
                  for (final item in items)
                    item.copyWith(selected: item.value == value),
                ],
                onSelected: (item) {
                  onChanged?.call(item.value);
                  close();
                },
              ),
            ),
            divider(),
            SizedBox(
              width: nameWidth,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onNamePressed,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6, right: 2),
                        child: Text(
                          '$value',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.body.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (onPin != null)
                    _BlenderDataBlockFlatAction(
                      glyph: BlenderGlyph.pin,
                      onTap: onPin,
                      tooltip: 'Pin ${tooltip ?? value}',
                    ),
                ],
              ),
            ),
            if (onDuplicate != null) ...<Widget>[
              divider(),
              _BlenderDataBlockFlatAction(
                glyph: BlenderGlyph.duplicate,
                onTap: onDuplicate,
                tooltip: 'Duplicate ${tooltip ?? value}',
              ),
            ],
            if (onClose != null) ...<Widget>[
              divider(),
              _BlenderDataBlockFlatAction(
                glyph: BlenderGlyph.close,
                onTap: onClose,
                tooltip: 'Close ${tooltip ?? value}',
                muted: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BlenderDataBlockFlatAction extends StatelessWidget {
  const _BlenderDataBlockFlatAction({
    required this.glyph,
    required this.onTap,
    required this.tooltip,
    this.muted = false,
  });

  final BlenderGlyph glyph;
  final VoidCallback? onTap;
  final String tooltip;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderTooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 22,
          height: 22,
          child: Center(
            child: BlenderIcon(
              glyph,
              size: 13,
              color: muted
                  ? theme.colors.foregroundDisabled
                  : theme.colors.foregroundMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class BlenderBreadcrumbs extends StatelessWidget {
  const BlenderBreadcrumbs({super.key, required this.items, this.onSelected});

  final List<String> items;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var index = 0; index < items.length; index++) ...<Widget>[
          if (index > 0)
            BlenderIcon(
              BlenderGlyph.chevronRight,
              size: 12,
              color: theme.colors.foregroundMuted,
            ),
          GestureDetector(
            onTap: onSelected == null ? null : () => onSelected!(index),
            child: Text(
              items[index],
              style: theme.textTheme.caption.copyWith(
                color: index == items.length - 1
                    ? theme.colors.foreground
                    : theme.colors.foregroundMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class BlenderStatusBar extends StatelessWidget {
  const BlenderStatusBar({
    super.key,
    this.left = const <Widget>[],
    this.center = const <Widget>[],
    this.right = const <Widget>[],
    this.height,
  });

  final List<Widget> left;
  final List<Widget> center;
  final List<Widget> right;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Container(
      height: height ?? theme.density.headerHeight,
      padding: EdgeInsets.symmetric(horizontal: theme.density.panelPadding),
      decoration: BoxDecoration(
        color: theme.colors.canvas,
        border: Border(top: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.caption.copyWith(
          color: theme.colors.foregroundMuted,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: ClipRect(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(mainAxisSize: MainAxisSize.min, children: left),
                ),
              ),
            ),
            if (center.isNotEmpty) ...<Widget>[
              SizedBox(width: theme.density.spacing),
              Flexible(
                child: Align(
                  alignment: Alignment.center,
                  child: ClipRect(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (right.isNotEmpty) ...<Widget>[
              SizedBox(width: theme.density.spacing),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ClipRect(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: right,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BlenderToolShelf extends StatelessWidget {
  const BlenderToolShelf({
    super.key,
    required this.tools,
    required this.selectedIndex,
    required this.onChanged,
    this.onOptionSelected,
    this.width = 32,
  });

  final List<BlenderToolDefinition> tools;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ValueChanged<BlenderToolOption>? onOptionSelected;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.surface,
        border: Border(right: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: SizedBox(
        width: width,
        child: ListView.builder(
          padding: const EdgeInsets.only(top: 4),
          itemCount: tools.length,
          itemExtent: width,
          itemBuilder: (context, index) {
            final tool = tools[index];
            final button = BlenderIconButton(
              glyph: tool.glyph,
              selected: index == selectedIndex,
              enabled: tool.enabled,
              onPressed: tool.options.isEmpty ? () => onChanged(index) : () {},
              tooltip: tool.options.isEmpty ? tool.tooltip : null,
              size: width - 2,
            );
            if (tool.options.isEmpty) return button;
            return BlenderTooltip(
              message: tool.tooltip,
              child: BlenderPopover(
                targetAnchor: Alignment.centerRight,
                followerAnchor: Alignment.centerLeft,
                offset: const Offset(4, 0),
                child: IgnorePointer(child: button),
                popover: (context, close) => _BlenderToolOptionMenu(
                  options: tool.options,
                  selectedIndex: tool.selectedOption,
                  onSelected: (option) {
                    onChanged(index);
                    onOptionSelected?.call(option);
                    close();
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BlenderToolOption {
  const BlenderToolOption({
    required this.label,
    required this.glyph,
    this.shortcut,
    this.description,
    this.enabled = true,
  });

  final String label;
  final BlenderGlyph glyph;
  final String? shortcut;
  final String? description;
  final bool enabled;
}

class BlenderToolDefinition {
  const BlenderToolDefinition({
    required this.glyph,
    required this.tooltip,
    this.enabled = true,
    this.options = const <BlenderToolOption>[],
    this.selectedOption = 0,
  });

  final BlenderGlyph glyph;
  final String tooltip;
  final bool enabled;
  final List<BlenderToolOption> options;
  final int selectedOption;
}

class _BlenderToolOptionMenu extends StatelessWidget {
  const _BlenderToolOptionMenu({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<BlenderToolOption> options;
  final int selectedIndex;
  final ValueChanged<BlenderToolOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return SizedBox(
      width: 260,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var index = 0; index < options.length; index++)
                _BlenderToolOptionRow(
                  option: options[index],
                  selected: index == selectedIndex,
                  onSelected: () => onSelected(options[index]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlenderToolOptionRow extends StatefulWidget {
  const _BlenderToolOptionRow({
    required this.option,
    required this.selected,
    required this.onSelected,
  });

  final BlenderToolOption option;
  final bool selected;
  final VoidCallback onSelected;

  @override
  State<_BlenderToolOptionRow> createState() => _BlenderToolOptionRowState();
}

class _BlenderToolOptionRowState extends State<_BlenderToolOptionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final highlighted = widget.selected || _hovered;
    final content = Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: highlighted ? theme.colors.menuSelection : null,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: <Widget>[
          BlenderIcon(widget.option.glyph, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.option.label,
              style: theme.textTheme.body.copyWith(fontSize: 14),
            ),
          ),
          if (widget.option.shortcut != null)
            Text(
              widget.option.shortcut!,
              style: theme.textTheme.caption.copyWith(fontSize: 10),
            ),
        ],
      ),
    );
    final row = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.option.enabled ? widget.onSelected : null,
        child: content,
      ),
    );
    if (widget.option.description == null) return row;
    return BlenderTooltip(
      message: widget.option.label,
      content: SizedBox(
        width: 300,
        child: Text(
          '${widget.option.description}\n'
          '${widget.option.shortcut == null ? '' : 'Shortcut: ${widget.option.shortcut}'}',
          style: theme.textTheme.body,
        ),
      ),
      child: row,
    );
  }
}

class BlenderTabBar extends StatelessWidget {
  const BlenderTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.variant = BlenderButtonVariant.tab,
    this.scrollable = true,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final BlenderButtonVariant variant;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final entry in tabs.indexed)
          Padding(
            padding: EdgeInsets.only(right: theme.density.spacing),
            child: BlenderTooltip(
              message: entry.$1 == selectedIndex
                  ? 'Active workspace showing in the window.'
                  : 'Switch to ${entry.$2} workspace.',
              child: BlenderButton(
                label: entry.$2,
                variant: variant,
                selected: entry.$1 == selectedIndex,
                onPressed: () => onChanged(entry.$1),
              ),
            ),
          ),
      ],
    );
    return SizedBox(
      height: theme.density.headerHeight,
      child: scrollable
          ? _blenderHeaderScrollSurface(
              context,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: row,
              ),
            )
          : row,
    );
  }
}

enum BlenderSplitDirection { horizontal, vertical }

class BlenderSplitter extends StatefulWidget {
  const BlenderSplitter({
    super.key,
    required this.first,
    required this.second,
    this.direction = BlenderSplitDirection.horizontal,
    this.initialFraction = .5,
    this.onFractionChanged,
    this.dividerExtent = 4,
  });

  final Widget first;
  final Widget second;
  final BlenderSplitDirection direction;
  final double initialFraction;
  final ValueChanged<double>? onFractionChanged;
  final double dividerExtent;

  @override
  State<BlenderSplitter> createState() => _BlenderSplitterState();
}

class _BlenderSplitterState extends State<BlenderSplitter> {
  late double _fraction = widget.initialFraction.clamp(.05, .95).toDouble();
  bool _hovered = false;
  bool _dragging = false;

  @override
  void didUpdateWidget(BlenderSplitter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFraction != widget.initialFraction) {
      _fraction = widget.initialFraction.clamp(.05, .95).toDouble();
    }
  }

  void _move(double delta, double extent) {
    final next = (_fraction + delta / extent).clamp(.05, .95).toDouble();
    if (next == _fraction) return;
    setState(() => _fraction = next);
    widget.onFractionChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final dragCursor = widget.direction == BlenderSplitDirection.horizontal
        ? SystemMouseCursors.resizeColumn
        : SystemMouseCursors.resizeRow;
    return MouseRegion(
      key: const ValueKey<String>('blender-splitter-drag-surface'),
      // A divider moves underneath the pointer while it is being dragged.
      // Keep the active resize cursor on the whole splitter surface so the
      // divider's small MouseRegion cannot briefly lose ownership during
      // relayout.
      cursor: _dragging ? dragCursor : MouseCursor.defer,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isHorizontal =
              widget.direction == BlenderSplitDirection.horizontal;
          final extent = isHorizontal
              ? constraints.maxWidth
              : constraints.maxHeight;
          final available = (extent - widget.dividerExtent).clamp(
            0,
            double.infinity,
          );
          final firstExtent = available * _fraction;
          final divider = Semantics(
            label: isHorizontal
                ? 'Resize editor width'
                : 'Resize editor height',
            child: MouseRegion(
              cursor: isHorizontal
                  ? SystemMouseCursors.resizeColumn
                  : SystemMouseCursors.resizeRow,
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) {
                if (!_dragging) setState(() => _hovered = false);
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: isHorizontal
                    ? (_) => setState(() => _dragging = true)
                    : null,
                onVerticalDragStart: !isHorizontal
                    ? (_) => setState(() => _dragging = true)
                    : null,
                onHorizontalDragUpdate: isHorizontal
                    ? (details) => _move(details.delta.dx, extent)
                    : null,
                onVerticalDragUpdate: !isHorizontal
                    ? (details) => _move(details.delta.dy, extent)
                    : null,
                onHorizontalDragEnd: isHorizontal ? (_) => _endDrag() : null,
                onVerticalDragEnd: !isHorizontal ? (_) => _endDrag() : null,
                onHorizontalDragCancel: isHorizontal ? _endDrag : null,
                onVerticalDragCancel: !isHorizontal ? _endDrag : null,
                child: SizedBox(
                  width: isHorizontal ? widget.dividerExtent : double.infinity,
                  height: isHorizontal ? double.infinity : widget.dividerExtent,
                  child: Stack(
                    clipBehavior: Clip.none,
                    fit: StackFit.expand,
                    children: <Widget>[
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _hovered
                                ? theme.colors.editorOutlineActive
                                : theme.colors.editorBorder,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: theme.colors.editorOutline,
                                spreadRadius: .5,
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: isHorizontal ? 1 : double.infinity,
                            height: isHorizontal ? double.infinity : 1,
                          ),
                        ),
                      ),
                      Center(
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _dragging ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            child: DecoratedBox(
                              decoration: const BoxDecoration(
                                color: const Color(0xFFE8E8E8),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Color(0xB0000000),
                                    blurRadius: 2,
                                    spreadRadius: .5,
                                  ),
                                ],
                              ),
                              child: SizedBox(
                                width: isHorizontal ? 2 : double.infinity,
                                height: isHorizontal ? double.infinity : 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: IgnorePointer(
                          child: AnimatedOpacity(
                            opacity: _dragging ? 1 : 0,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            child: OverflowBox(
                              maxWidth: double.infinity,
                              maxHeight: double.infinity,
                              child: SizedBox(
                                width: isHorizontal ? 44 : 30,
                                height: isHorizontal ? 30 : 44,
                                child: CustomPaint(
                                  painter: _BlenderSplitHandlePainter(
                                    verticalDivider: isHorizontal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          if (isHorizontal) {
            return Row(
              children: <Widget>[
                SizedBox(width: firstExtent, child: widget.first),
                divider,
                Expanded(child: widget.second),
              ],
            );
          }
          return Column(
            children: <Widget>[
              SizedBox(height: firstExtent, child: widget.first),
              divider,
              Expanded(child: widget.second),
            ],
          );
        },
      ),
    );
  }

  void _endDrag() {
    if (!mounted) return;
    setState(() => _dragging = false);
  }
}

class _BlenderSplitHandlePainter extends CustomPainter {
  const _BlenderSplitHandlePainter({required this.verticalDivider});

  final bool verticalDivider;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void draw(Path path) {
      stroke
        ..color = const Color(0xD0000000)
        ..strokeWidth = 6;
      canvas.drawPath(path, stroke);
      stroke
        ..color = const Color(0xFFF2F2F2)
        ..strokeWidth = 2.5;
      canvas.drawPath(path, stroke);
    }

    final center = Offset(size.width / 2, size.height / 2);
    if (verticalDivider) {
      draw(
        Path()
          ..moveTo(center.dx, center.dy - 8)
          ..lineTo(center.dx, center.dy + 8),
      );
      draw(
        Path()
          ..moveTo(center.dx - 7, center.dy - 7)
          ..lineTo(center.dx - 13, center.dy)
          ..lineTo(center.dx - 7, center.dy + 7),
      );
      draw(
        Path()
          ..moveTo(center.dx + 7, center.dy - 7)
          ..lineTo(center.dx + 13, center.dy)
          ..lineTo(center.dx + 7, center.dy + 7),
      );
      return;
    }
    draw(
      Path()
        ..moveTo(center.dx - 8, center.dy)
        ..lineTo(center.dx + 8, center.dy),
    );
    draw(
      Path()
        ..moveTo(center.dx - 7, center.dy - 7)
        ..lineTo(center.dx, center.dy - 13)
        ..lineTo(center.dx + 7, center.dy - 7),
    );
    draw(
      Path()
        ..moveTo(center.dx - 7, center.dy + 7)
        ..lineTo(center.dx, center.dy + 13)
        ..lineTo(center.dx + 7, center.dy + 7),
    );
  }

  @override
  bool shouldRepaint(covariant _BlenderSplitHandlePainter oldDelegate) {
    return oldDelegate.verticalDivider != verticalDivider;
  }
}

class BlenderScrollView extends StatefulWidget {
  const BlenderScrollView({
    super.key,
    required this.child,
    this.controller,
    this.axis = Axis.vertical,
  });

  final Widget child;
  final ScrollController? controller;
  final Axis axis;

  @override
  State<BlenderScrollView> createState() => _BlenderScrollViewState();
}

class _BlenderScrollViewState extends State<BlenderScrollView> {
  ScrollController? _internalController;

  ScrollController get _controller =>
      widget.controller ?? (_internalController ??= ScrollController());

  @override
  void didUpdateWidget(covariant BlenderScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller &&
        widget.controller != null) {
      _internalController?.dispose();
      _internalController = null;
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlenderScrollbar(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        primary: false,
        scrollDirection: widget.axis,
        child: widget.child,
      ),
    );
  }
}

/// A Blender-style narrow scrollbar with a comfortable invisible drag target.
class BlenderScrollbar extends StatelessWidget {
  const BlenderScrollbar({
    super.key,
    required this.controller,
    required this.child,
    this.thickness = 3,
    this.thumbColor,
  });

  final ScrollController controller;
  final Widget child;
  final double thickness;
  final Color? thumbColor;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return RawScrollbar(
      controller: controller,
      thumbVisibility: true,
      interactive: true,
      thickness: thickness,
      radius: Radius.circular(thickness),
      crossAxisMargin: 1,
      mainAxisMargin: 2,
      minThumbLength: 20,
      thumbColor: thumbColor ?? theme.colors.borderSubtle,
      notificationPredicate: (notification) => notification.depth == 0,
      child: child,
    );
  }
}

class BlenderRegion extends StatelessWidget {
  const BlenderRegion({
    super.key,
    required this.child,
    this.title,
    this.actions,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(title: title, headerActions: actions, child: child);
  }
}

/// A Blender editor-area boundary with the same quiet idle and active-hover
/// outlines used around native screen areas.
class BlenderEditorFrame extends StatefulWidget {
  const BlenderEditorFrame({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.showLeftBorder = true,
    this.showTopBorder = true,
    this.squareTopCorners = false,
  });

  final Widget child;
  final Color? backgroundColor;
  final double? borderRadius;
  final bool showTopBorder;
  final bool squareTopCorners;

  /// Omits the leading outline when an editor is directly attached to a
  /// navigation rail (for example Properties context tabs). The rail supplies
  /// the quiet seam, so drawing both borders creates a visible gutter.
  final bool showLeftBorder;

  @override
  State<BlenderEditorFrame> createState() => _BlenderEditorFrameState();
}

class _BlenderEditorFrameState extends State<BlenderEditorFrame> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? theme.colors.surface,
          border: Border(
            top: widget.showTopBorder
                ? BorderSide(
                    color: _hovered
                        ? theme.colors.editorOutlineActive
                        : theme.colors.editorOutline,
                  )
                : BorderSide.none,
            right: BorderSide(
              color: _hovered
                  ? theme.colors.editorOutlineActive
                  : theme.colors.editorOutline,
            ),
            bottom: BorderSide(
              color: _hovered
                  ? theme.colors.editorOutlineActive
                  : theme.colors.editorOutline,
            ),
            left: widget.showLeftBorder
                ? BorderSide(
                    color: _hovered
                        ? theme.colors.editorOutlineActive
                        : theme.colors.editorOutline,
                  )
                : BorderSide.none,
          ),
          borderRadius: widget.squareTopCorners
              ? BorderRadius.vertical(
                  bottom: Radius.circular(
                    widget.borderRadius ?? theme.shapes.panelRadius,
                  ),
                )
              : BorderRadius.circular(
                  widget.borderRadius ?? theme.shapes.panelRadius,
                ),
        ),
        child: widget.child,
      ),
    );
  }
}

class BlenderEditorShell extends StatelessWidget {
  const BlenderEditorShell({
    super.key,
    required this.main,
    this.topBar,
    this.left,
    this.right,
    this.bottom,
    this.statusBar,
    this.leftWidth = 240,
    this.rightWidth = 280,
    this.bottomHeight = 180,
  });

  final Widget main;
  final Widget? topBar;
  final Widget? left;
  final Widget? right;
  final Widget? bottom;
  final Widget? statusBar;
  final double leftWidth;
  final double rightWidth;
  final double bottomHeight;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final editorColumn = bottom == null
        ? main
        : LayoutBuilder(
            builder: (context, constraints) {
              final fraction =
                  ((constraints.maxHeight - bottomHeight) /
                          constraints.maxHeight)
                      .clamp(.05, .95)
                      .toDouble();
              return BlenderSplitter(
                direction: BlenderSplitDirection.vertical,
                initialFraction: fraction,
                first: main,
                second: bottom!,
              );
            },
          );
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (left != null) SizedBox(width: leftWidth, child: left),
        Expanded(
          child: right == null
              ? editorColumn
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final fraction =
                        ((constraints.maxWidth - rightWidth) /
                                constraints.maxWidth)
                            .clamp(.05, .95)
                            .toDouble();
                    return BlenderSplitter(
                      initialFraction: fraction,
                      first: editorColumn,
                      second: right!,
                    );
                  },
                ),
        ),
      ],
    );
    return ColoredBox(
      color: theme.colors.canvas,
      child: Column(
        children: <Widget>[
          if (topBar != null) topBar!,
          Expanded(child: content),
          if (statusBar != null) statusBar!,
        ],
      ),
    );
  }
}
