import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'advanced_controls.dart';
import 'collections.dart';
import 'controls.dart';
import 'icons.dart';
import 'layout.dart';
import 'overlay_host.dart';
import 'theme.dart';

typedef BlenderPropertyEditorBuilder<T> =
    Widget Function(BuildContext context, T value, ValueChanged<T> onChanged);

/// Controls where a property name is drawn in Blender's split property layout.
///
/// Most properties place their name in the 40% label column. Boolean
/// properties are the notable exception: Blender keeps the checkbox and its
/// name together in the 60% value column.
enum BlenderPropertyLabelPlacement { splitColumn, valueColumn }

/// The independent tree displays provided by Blender's Outliner editor.
enum BlenderOutlinerDisplayMode {
  scenes,
  viewLayer,
  videoSequencer,
  blenderFile,
  dataApi,
  libraryOverrides,
  unusedData,
}

class BlenderOutlinerDisplayModePresentation {
  const BlenderOutlinerDisplayModePresentation._(this.label, this.glyph);

  final String label;
  final BlenderGlyph glyph;

  static BlenderOutlinerDisplayModePresentation of(
    BlenderOutlinerDisplayMode mode,
  ) => switch (mode) {
    BlenderOutlinerDisplayMode.scenes =>
      const BlenderOutlinerDisplayModePresentation._(
        'Scenes',
        BlenderGlyph.scene,
      ),
    BlenderOutlinerDisplayMode.viewLayer =>
      const BlenderOutlinerDisplayModePresentation._(
        'View Layer',
        BlenderGlyph.image,
      ),
    BlenderOutlinerDisplayMode.videoSequencer =>
      const BlenderOutlinerDisplayModePresentation._(
        'Video Sequencer',
        BlenderGlyph.sequence,
      ),
    BlenderOutlinerDisplayMode.blenderFile =>
      const BlenderOutlinerDisplayModePresentation._(
        'Blender File',
        BlenderGlyph.file,
      ),
    BlenderOutlinerDisplayMode.dataApi =>
      const BlenderOutlinerDisplayModePresentation._(
        'Data API',
        BlenderGlyph.link,
      ),
    BlenderOutlinerDisplayMode.libraryOverrides =>
      const BlenderOutlinerDisplayModePresentation._(
        'Library Overrides',
        BlenderGlyph.linkBroken,
      ),
    BlenderOutlinerDisplayMode.unusedData =>
      const BlenderOutlinerDisplayModePresentation._(
        'Unused Data',
        BlenderGlyph.material,
      ),
  };
}

class BlenderPropertyDescriptor<T> {
  const BlenderPropertyDescriptor({
    required this.id,
    required this.label,
    required this.value,
    required this.editorBuilder,
    this.onChanged,
    this.enabled = true,
    this.tooltip,
    this.state = BlenderPropertyState.normal,
    this.onKeyframe,
    this.onReset,
    this.labelPlacement,
  });

  final String id;
  final String label;
  final T value;
  final BlenderPropertyEditorBuilder<T> editorBuilder;
  final ValueChanged<T>? onChanged;
  final bool enabled;
  final String? tooltip;
  final BlenderPropertyState state;
  final VoidCallback? onKeyframe;
  final VoidCallback? onReset;
  final BlenderPropertyLabelPlacement? labelPlacement;

  BlenderPropertyLabelPlacement get effectiveLabelPlacement =>
      labelPlacement ??
      (value is bool
          ? BlenderPropertyLabelPlacement.valueColumn
          : BlenderPropertyLabelPlacement.splitColumn);

  Widget buildEditor(BuildContext context) {
    return editorBuilder(context, value, onChanged ?? (_) {});
  }
}

class BlenderPropertyGroup {
  const BlenderPropertyGroup({
    required this.id,
    required this.title,
    required this.properties,
    this.initiallyExpanded = true,
    this.headerLeading,
    this.headerActions,
    this.content,
    this.children = const <BlenderPropertyGroup>[],
  });

  final String id;
  final String title;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final bool initiallyExpanded;
  final Widget? headerLeading;
  final List<Widget>? headerActions;

  /// Optional source-shaped content for panels whose Blender implementation
  /// is primarily a list/tree rather than property rows.
  final Widget? content;

  /// Child panels rendered inside this panel, matching Blender's
  /// `bl_parent_id` panel relationship.
  final List<BlenderPropertyGroup> children;
}

class BlenderPropertyRow extends StatelessWidget {
  const BlenderPropertyRow({
    super.key,
    required this.label,
    required this.editor,
    this.tooltip,
    this.state = BlenderPropertyState.normal,
    this.onKeyframe,
    this.onReset,
    this.labelPlacement = BlenderPropertyLabelPlacement.splitColumn,
  });

  final String label;
  final Widget editor;
  final String? tooltip;
  final BlenderPropertyState state;
  final VoidCallback? onKeyframe;
  final VoidCallback? onReset;
  final BlenderPropertyLabelPlacement labelPlacement;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    // Blender gives the label and editor proportional space so values remain
    // usable as a Properties region is resized. A fixed editor width makes the
    // panel look acceptable at one size but quickly diverges from Blender on
    // narrow or wide desktop layouts.
    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: theme.density.spacing / 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: labelPlacement == BlenderPropertyLabelPlacement.splitColumn
                ? _BlenderSplitPropertyLabel(label: label, state: state)
                : const SizedBox.shrink(),
          ),
          SizedBox(width: theme.density.spacing * 2),
          Expanded(
            flex: 3,
            child: _BlenderPropertyValueColumn(
              label: label,
              editor: editor,
              showLabel:
                  labelPlacement == BlenderPropertyLabelPlacement.valueColumn,
            ),
          ),
          if (onKeyframe != null)
            BlenderIconButton(
              glyph: BlenderGlyph.keyframe,
              onPressed: onKeyframe,
              tooltip: 'Insert keyframe',
              size: 20,
            ),
          if (onReset != null)
            BlenderIconButton(
              glyph: BlenderGlyph.refresh,
              onPressed: onReset,
              tooltip: 'Reset value',
              size: 20,
            ),
        ],
      ),
    );
    return tooltip == null
        ? row
        : BlenderTooltip(message: tooltip!, child: row);
  }
}

class _BlenderSplitPropertyLabel extends StatelessWidget {
  const _BlenderSplitPropertyLabel({required this.label, required this.state});

  final String label;
  final BlenderPropertyState state;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Row(
      children: <Widget>[
        if (state != BlenderPropertyState.normal) ...<Widget>[
          BlenderPropertyIndicator(state: state),
          SizedBox(width: theme.density.spacing),
        ],
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.label,
            textAlign: state == BlenderPropertyState.normal
                ? TextAlign.right
                : TextAlign.left,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _BlenderPropertyValueColumn extends StatelessWidget {
  const _BlenderPropertyValueColumn({
    required this.label,
    required this.editor,
    required this.showLabel,
  });

  final String label;
  final Widget editor;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    if (!showLabel) return editor;
    final theme = BlenderTheme.of(context);
    return Row(
      children: <Widget>[
        editor,
        SizedBox(width: theme.density.spacing),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class BlenderPropertiesEditor extends StatefulWidget {
  const BlenderPropertiesEditor({
    super.key,
    required this.groups,
    this.title = 'Properties',
    this.headerActions,
    this.headerLeading,
    this.headerTitleStyle,
    this.topContent,
    this.body,
    this.joinNavigationRail = false,
    this.onGroupOrderChanged,
    this.searchController,
  });

  final List<BlenderPropertyGroup> groups;
  final String title;
  final List<Widget>? headerActions;
  final Widget? headerLeading;
  final TextStyle? headerTitleStyle;
  final Widget? topContent;

  /// Optional specialised scroll body for editor contexts such as Tool.
  /// When supplied it replaces descriptor-generated property panels.
  final Widget? body;

  /// Lets a Properties navigation rail meet this editor without a doubled
  /// leading outline or exposed parent-colour gutter.
  final bool joinNavigationRail;

  /// Called after a grip drag commits a new panel order.
  ///
  /// Group IDs are used instead of indexes so callers can persist the order
  /// across descriptor changes without coupling to a particular build.
  final ValueChanged<List<String>>? onGroupOrderChanged;

  /// Filters panel and property labels using Blender's Properties search
  /// behavior. Matching panels are temporarily expanded without changing the
  /// user's stored expansion state.
  final TextEditingController? searchController;

  @override
  State<BlenderPropertiesEditor> createState() =>
      _BlenderPropertiesEditorState();
}

class _BlenderPropertiesEditorState extends State<BlenderPropertiesEditor> {
  late final ScrollController _scrollController;
  late List<String> _groupOrder = widget.groups
      .map((group) => group.id)
      .toList();
  late final Set<String> _expanded = {
    for (final group in _allGroups(widget.groups))
      if (group.initiallyExpanded) group.id,
  };

  Iterable<BlenderPropertyGroup> _allGroups(
    Iterable<BlenderPropertyGroup> groups,
  ) sync* {
    for (final group in groups) {
      yield group;
      yield* _allGroups(group.children);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BlenderPropertiesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ids = _allGroups(widget.groups).map((group) => group.id).toSet();
    final oldIds = _allGroups(
      oldWidget.groups,
    ).map((group) => group.id).toSet();
    _expanded.retainWhere(ids.contains);
    _expanded.addAll(
      _allGroups(widget.groups)
          .where(
            (group) => !oldIds.contains(group.id) && group.initiallyExpanded,
          )
          .map((group) => group.id),
    );
    _groupOrder = <String>[
      for (final id in _groupOrder)
        if (ids.contains(id)) id,
      for (final group in widget.groups)
        if (!_groupOrder.contains(group.id)) group.id,
    ];
  }

  List<BlenderPropertyGroup> get _orderedGroups {
    final groupsById = <String, BlenderPropertyGroup>{
      for (final group in widget.groups) group.id: group,
    };
    return <BlenderPropertyGroup>[
      for (final id in _groupOrder)
        if (groupsById[id] case final group?) group,
    ];
  }

  _PropertiesGroupView? _filteredGroup(
    BlenderPropertyGroup group,
    String normalizedQuery,
  ) {
    if (normalizedQuery.isEmpty ||
        group.title.toLowerCase().contains(normalizedQuery)) {
      return _PropertiesGroupView(
        group: group,
        properties: group.properties,
        children: <_PropertiesGroupView>[
          for (final child in group.children)
            _PropertiesGroupView.fromGroup(child),
        ],
      );
    }
    final properties = group.properties
        .where(
          (property) => property.label.toLowerCase().contains(normalizedQuery),
        )
        .toList();
    final children = <_PropertiesGroupView>[
      for (final child in group.children)
        if (_filteredGroup(child, normalizedQuery) case final match?) match,
    ];
    if (properties.isEmpty && children.isEmpty) return null;
    return _PropertiesGroupView(
      group: group,
      properties: properties,
      children: children,
    );
  }

  List<_PropertiesGroupView> _filteredGroups(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    return <_PropertiesGroupView>[
      for (final group in _orderedGroups)
        if (_filteredGroup(group, normalizedQuery) case final match?) match,
    ];
  }

  Widget _buildGroupContents(
    BuildContext context,
    _PropertiesGroupView view,
    bool searchActive,
  ) {
    return Column(
      children: <Widget>[
        if (view.group.content != null) view.group.content!,
        for (final property in view.properties)
          BlenderPropertyRow(
            label: property.label,
            tooltip: property.tooltip,
            state: property.state,
            labelPlacement: property.effectiveLabelPlacement,
            onKeyframe: property.onKeyframe,
            onReset: property.onReset,
            editor: property.buildEditor(context),
          ),
        for (final child in view.children)
          _buildPanel(context, child, searchActive: searchActive, nested: true),
      ],
    );
  }

  Widget _buildPanel(
    BuildContext context,
    _PropertiesGroupView view, {
    required bool searchActive,
    bool nested = false,
    Widget? headerHandle,
  }) {
    final theme = BlenderTheme.of(context);
    final group = view.group;
    final expanded = _expanded.contains(group.id);
    return BlenderPanel(
      title: group.title,
      collapsible: true,
      initiallyExpanded: expanded,
      expanded: searchActive ? true : expanded,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      backgroundColor: nested
          ? theme.colors.panelSubSurface
          : theme.colors.panelBackground,
      headerTitleStyle: theme.textTheme.panelTitle,
      headerLeading: group.headerLeading,
      headerActions: group.headerActions,
      onExpansionChanged: searchActive
          ? null
          : (isExpanded) {
              setState(() {
                if (isExpanded) {
                  _expanded.add(group.id);
                } else {
                  _expanded.remove(group.id);
                }
              });
            },
      headerHandle: headerHandle,
      child: _buildGroupContents(context, view, searchActive),
    );
  }

  void _reorderGroups(
    List<_PropertiesGroupView> visibleGroups,
    int oldIndex,
    int newIndex,
  ) {
    setState(() {
      final visibleIds = visibleGroups.map((view) => view.group.id).toList();
      final id = visibleIds.removeAt(oldIndex);
      visibleIds.insert(newIndex.clamp(0, visibleIds.length), id);

      final oldFullIndex = _groupOrder.indexOf(id);
      _groupOrder.remove(id);
      final visibleIndex = visibleIds.indexOf(id);
      final insertionIndex = visibleIds.length == 1
          ? oldFullIndex
          : visibleIndex == visibleIds.length - 1
          ? _groupOrder.indexOf(visibleIds[visibleIndex - 1]) + 1
          : _groupOrder.indexOf(visibleIds[visibleIndex + 1]);
      _groupOrder.insert(insertionIndex.clamp(0, _groupOrder.length), id);
    });
    widget.onGroupOrderChanged?.call(List<String>.unmodifiable(_groupOrder));
  }

  Widget _buildPropertiesList(BuildContext context, String query) {
    final theme = BlenderTheme.of(context);
    final groups = _filteredGroups(query);
    final searchActive = query.trim().isNotEmpty;
    return BlenderScrollbar(
      controller: _scrollController,
      child: BlenderEnsureOverlay(
        child: ReorderableList(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
          itemCount: groups.length,
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            _reorderGroups(groups, oldIndex, newIndex);
          },
          proxyDecorator: (child, index, animation) => AnimatedBuilder(
            animation: animation,
            child: child,
            builder: (context, child) => DecoratedBox(
              decoration: const BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
          itemBuilder: (context, index) {
            final view = groups[index];
            final group = view.group;
            return KeyedSubtree(
              key: ValueKey<String>('property-group-${group.id}'),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: index == groups.length - 1
                      ? 0
                      : theme.density.spacing / 2,
                ),
                child: _buildPanel(
                  context,
                  view,
                  searchActive: searchActive,
                  headerHandle: ReorderableDragStartListener(
                    index: index,
                    child: MouseRegion(
                      key: ValueKey<String>(
                        'property-group-handle-${group.id}',
                      ),
                      cursor: SystemMouseCursors.grab,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: theme.density.spacing / 2,
                        ),
                        child: BlenderIcon(
                          BlenderGlyph.dragHandle,
                          size: 7,
                          color: theme.colors.foreground.withAlpha(128),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPropertiesBody(BuildContext context) {
    if (widget.body case final body?) return body;
    if (widget.searchController case final controller?) {
      return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) =>
            _buildPropertiesList(context, value.text),
      );
    }
    return _buildPropertiesList(context, '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderEditorFrame(
      backgroundColor: theme.colors.propertiesBackground,
      showLeftBorder: !widget.joinNavigationRail,
      // The Properties caption is the editor's own top edge. A second
      // outline here creates a dark seam between that caption and its body.
      showTopBorder: false,
      squareTopCorners: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PropertiesContextCaption(
            title: widget.title,
            leading: widget.headerLeading,
            actions: widget.headerActions,
            titleStyle: widget.headerTitleStyle,
            horizontalPadding: 10,
          ),
          if (widget.topContent != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
              child: widget.topContent!,
            ),
          ],
          Expanded(child: _buildPropertiesBody(context)),
        ],
      ),
    );
  }
}

class _PropertiesGroupView {
  const _PropertiesGroupView({
    required this.group,
    required this.properties,
    this.children = const <_PropertiesGroupView>[],
  });

  _PropertiesGroupView.fromGroup(BlenderPropertyGroup group)
    : this(
        group: group,
        properties: group.properties,
        children: <_PropertiesGroupView>[
          for (final child in group.children)
            _PropertiesGroupView.fromGroup(child),
        ],
      );

  final BlenderPropertyGroup group;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final List<_PropertiesGroupView> children;
}

class _PropertiesContextCaption extends StatelessWidget {
  const _PropertiesContextCaption({
    required this.title,
    this.leading,
    this.actions,
    this.titleStyle,
    required this.horizontalPadding,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final TextStyle? titleStyle;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return SizedBox(
      height: 38,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading!,
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: titleStyle ?? theme.textTheme.body,
              ),
            ),
            ...?actions,
          ],
        ),
      ),
    );
  }
}

class BlenderTreeNode<T> {
  const BlenderTreeNode({
    required this.id,
    required this.label,
    this.value,
    this.children = const [],
    this.icon,
    this.iconColor,
    this.initiallyExpanded = false,
    this.selectable = true,
    this.visible = true,
    this.locked = false,
    this.actionIcon,
    this.actionTooltip,
    this.onAction,
    this.dropTarget = false,
    this.dropHint,
  });

  final String id;
  final String label;
  final T? value;
  final List<BlenderTreeNode<T>> children;
  final BlenderGlyph? icon;
  final Color? iconColor;
  final bool initiallyExpanded;
  final bool selectable;
  final bool visible;
  final bool locked;
  final BlenderGlyph? actionIcon;
  final String? actionTooltip;
  final VoidCallback? onAction;
  final bool dropTarget;
  final String? dropHint;
}

class _VisibleTreeNode<T> {
  const _VisibleTreeNode({
    required this.node,
    required this.depth,
    required this.ancestorHasNext,
    required this.isLast,
  });

  final BlenderTreeNode<T> node;
  final int depth;
  final List<bool> ancestorHasNext;
  final bool isLast;
}

class BlenderTree<T> extends StatefulWidget {
  const BlenderTree({
    super.key,
    required this.roots,
    this.selectedId,
    this.onSelected,
    this.rowHeight,
    this.indent = 16,
    this.showVisibility = false,
    this.showLock = false,
    this.onVisibilityChanged,
    this.onLockChanged,
    this.contextMenuItemsBuilder,
    this.onContextMenuSelected,
  });

  final List<BlenderTreeNode<T>> roots;
  final String? selectedId;
  final ValueChanged<BlenderTreeNode<T>>? onSelected;
  final double? rowHeight;
  final double indent;
  final bool showVisibility;
  final bool showLock;
  final ValueChanged<BlenderTreeNode<T>>? onVisibilityChanged;
  final ValueChanged<BlenderTreeNode<T>>? onLockChanged;
  final List<BlenderMenuItem<String>> Function(BlenderTreeNode<T>)?
  contextMenuItemsBuilder;
  final void Function(BlenderTreeNode<T>, String)? onContextMenuSelected;

  @override
  State<BlenderTree<T>> createState() => _BlenderTreeState<T>();
}

class _BlenderTreeState<T> extends State<BlenderTree<T>> {
  late final ScrollController _scrollController;
  late final Set<String> _expanded;
  String? _hoveredNodeId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _expanded = <String>{};
    void addInitiallyExpanded(BlenderTreeNode<T> node) {
      if (node.initiallyExpanded) _expanded.add(node.id);
      for (final child in node.children) {
        addInitiallyExpanded(child);
      }
    }

    for (final root in widget.roots) {
      addInitiallyExpanded(root);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<_VisibleTreeNode<T>> _flatten() {
    final result = <_VisibleTreeNode<T>>[];
    void add(
      BlenderTreeNode<T> node,
      int depth,
      List<bool> ancestorHasNext,
      bool isLast,
    ) {
      result.add(
        _VisibleTreeNode<T>(
          node: node,
          depth: depth,
          ancestorHasNext: ancestorHasNext,
          isLast: isLast,
        ),
      );
      if (_expanded.contains(node.id)) {
        for (var index = 0; index < node.children.length; index++) {
          final childIsLast = index == node.children.length - 1;
          add(node.children[index], depth + 1, <bool>[
            ...ancestorHasNext,
            !isLast,
          ], childIsLast);
        }
      }
    }

    for (var index = 0; index < widget.roots.length; index++) {
      add(
        widget.roots[index],
        0,
        const <bool>[],
        index == widget.roots.length - 1,
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final visible = _flatten();
    final rowHeight = widget.rowHeight ?? theme.density.rowHeight;
    return BlenderScrollbar(
      controller: _scrollController,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          IgnorePointer(
            child: CustomPaint(
              painter: _BlenderTreeAlternatingRowsPainter(rowHeight: rowHeight),
            ),
          ),
          ListView.builder(
            controller: _scrollController,
            itemCount: visible.length,
            itemExtent: rowHeight,
            itemBuilder: (context, index) {
              final entry = visible[index];
              final node = entry.node;
              final hasChildren = node.children.isNotEmpty;
              final selected = node.id == widget.selectedId;
              final alternate = index.isOdd;
              final contextMenuItems =
                  widget.contextMenuItemsBuilder?.call(node) ??
                  const <BlenderMenuItem<String>>[];
              Widget row = GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: node.selectable
                    ? () => widget.onSelected?.call(node)
                    : null,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colors.selection
                        : alternate
                        ? const Color(0x04FFFFFF)
                        : null,
                    border: node.dropTarget
                        ? Border(
                            bottom: BorderSide(
                              color: theme.colors.accent,
                              width: 2,
                            ),
                          )
                        : null,
                  ),
                  child: Stack(
                    children: <Widget>[
                      if (entry.depth > 0)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: _BlenderTreeGuidePainter(
                                indent: widget.indent,
                                depth: entry.depth,
                                ancestorHasNext: entry.ancestorHasNext,
                                isLast: entry.isLast,
                                color: theme.colors.foregroundMuted.withAlpha(
                                  62,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: entry.depth * widget.indent,
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: widget.indent,
                              child: hasChildren
                                  ? GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        setState(() {
                                          if (_expanded.contains(node.id)) {
                                            _expanded.remove(node.id);
                                          } else {
                                            _expanded.add(node.id);
                                          }
                                        });
                                      },
                                      child: Center(
                                        child: BlenderIcon(
                                          key: ValueKey<String>(
                                            'tree-disclosure-${node.id}',
                                          ),
                                          _expanded.contains(node.id)
                                              ? BlenderGlyph.panelDisclosureDown
                                              : BlenderGlyph
                                                    .panelDisclosureRight,
                                          size: 9,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            if (node.icon != null) ...<Widget>[
                              BlenderIcon(
                                node.icon!,
                                size: 14,
                                color: node.iconColor,
                              ),
                              SizedBox(width: theme.density.spacing),
                            ],
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      node.label,
                                      maxLines: 1,
                                      style: theme.textTheme.label.copyWith(
                                        color: node.selectable
                                            ? theme.colors.foreground
                                            : theme.colors.foregroundMuted,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (node.dropHint != null)
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 4),
                                        child: Text(
                                          node.dropHint!,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.caption
                                              .copyWith(
                                                color: theme.colors.accent,
                                              ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (hasChildren && !_expanded.contains(node.id))
                              _BlenderCollapsedTreeSummary(
                                children: node.children,
                              ),
                            if (widget.showVisibility)
                              BlenderIconButton(
                                glyph: BlenderGlyph.eye,
                                selected: false,
                                onPressed: widget.onVisibilityChanged == null
                                    ? null
                                    : () => widget.onVisibilityChanged!(node),
                                tooltip: node.visible ? 'Hide' : 'Show',
                                size: 20,
                              ),
                            if (widget.showLock)
                              BlenderIconButton(
                                glyph: BlenderGlyph.lock,
                                selected: false,
                                onPressed: widget.onLockChanged == null
                                    ? null
                                    : () => widget.onLockChanged!(node),
                                tooltip: node.locked ? 'Unlock' : 'Lock',
                                size: 20,
                              ),
                            if (node.actionIcon != null &&
                                (_hoveredNodeId == node.id || node.dropTarget))
                              BlenderIconButton(
                                glyph: node.actionIcon!,
                                onPressed: node.onAction,
                                tooltip: node.actionTooltip,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
              row = MouseRegion(
                onEnter: (_) => setState(() => _hoveredNodeId = node.id),
                onExit: (_) {
                  if (_hoveredNodeId == node.id) {
                    setState(() => _hoveredNodeId = null);
                  }
                },
                child: row,
              );
              if (contextMenuItems.isNotEmpty) {
                row = BlenderContextMenu<String>(
                  items: contextMenuItems,
                  onSelected: (item) =>
                      widget.onContextMenuSelected?.call(node, item),
                  child: row,
                );
              }
              return row;
            },
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(covariant BlenderTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reconcile against the complete tree. Retaining only root IDs causes
    // nested collections to collapse whenever the parent rebuilds, which can
    // turn the collapsed-child summary into an unexpectedly wide row.
    final ids = <String>{};
    void collectIds(BlenderTreeNode<T> node) {
      if (node.children.isNotEmpty) ids.add(node.id);
      for (final child in node.children) {
        collectIds(child);
      }
    }

    for (final root in widget.roots) {
      collectIds(root);
    }
    _expanded.retainWhere(ids.contains);
  }
}

class _BlenderCollapsedTreeSummary extends StatelessWidget {
  const _BlenderCollapsedTreeSummary({required this.children});

  final List<BlenderTreeNode<dynamic>> children;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final counts = <BlenderGlyph, int>{};
    for (final child in children) {
      final glyph = child.icon;
      if (glyph != null) counts[glyph] = (counts[glyph] ?? 0) + 1;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final entry in counts.entries.take(4))
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                BlenderIcon(
                  entry.key,
                  size: 14,
                  color: theme.colors.foregroundMuted,
                ),
                if (entry.value > 1)
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Text(
                      '${entry.value}',
                      style: theme.textTheme.caption.copyWith(fontSize: 8),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BlenderTreeGuidePainter extends CustomPainter {
  const _BlenderTreeGuidePainter({
    required this.indent,
    required this.depth,
    required this.ancestorHasNext,
    required this.isLast,
    required this.color,
  });

  final double indent;
  final int depth;
  final List<bool> ancestorHasNext;
  final bool isLast;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    final centerY = size.height / 2;
    for (var level = 0; level < depth; level++) {
      final x = level * indent + indent / 2;
      final continues =
          level < ancestorHasNext.length && ancestorHasNext[level];
      if (continues)
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    final currentX = depth * indent + indent / 2;
    const linePadding = 5.0;
    canvas.drawLine(
      Offset(currentX, linePadding),
      Offset(currentX, isLast ? centerY : size.height - linePadding),
      paint,
    );
    canvas.drawLine(
      Offset(currentX, centerY),
      Offset(currentX + indent / 2, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BlenderTreeGuidePainter oldDelegate) =>
      indent != oldDelegate.indent ||
      depth != oldDelegate.depth ||
      ancestorHasNext != oldDelegate.ancestorHasNext ||
      isLast != oldDelegate.isLast ||
      color != oldDelegate.color;
}

class _BlenderTreeAlternatingRowsPainter extends CustomPainter {
  const _BlenderTreeAlternatingRowsPainter({required this.rowHeight});

  final double rowHeight;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x04FFFFFF);
    for (var row = 1; row * rowHeight < size.height; row += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, row * rowHeight, size.width, rowHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderTreeAlternatingRowsPainter oldDelegate) =>
      oldDelegate.rowHeight != rowHeight;
}

class BlenderOutliner<T> extends StatelessWidget {
  const BlenderOutliner({
    super.key,
    required this.roots,
    this.selectedId,
    this.onSelected,
    this.showVisibility = false,
    this.showLock = false,
    this.onVisibilityChanged,
    this.onLockChanged,
    this.title = 'Outliner',
    this.headerActions,
    this.filterController,
    this.onFilterChanged,
    this.filterPlaceholder = 'Search',
    this.displayMode = BlenderOutlinerDisplayMode.viewLayer,
    this.onDisplayModeChanged,
    this.syncSelection = true,
    this.onSyncSelectionChanged,
    this.libraryOverrideViewMode = 'Hierarchies',
    this.onLibraryOverrideViewModeChanged,
    this.useIdFilter = false,
    this.onIdFilterChanged,
    this.idFilterType = 'All',
    this.idFilterTypes = const <String>[
      'All',
      'Actions',
      'Armatures',
      'Cameras',
      'Collections',
      'Materials',
      'Meshes',
      'Objects',
      'Scenes',
      'Worlds',
    ],
    this.onIdFilterTypeChanged,
    this.onNewCollection,
    this.onPurgeUnusedData,
    this.hasActiveKeyingSet = false,
    this.activeKeyingSet = 'Location',
    this.keyingSets = const <String>['Location', 'Rotation', 'Scale'],
    this.onKeyingSetChanged,
    this.onKeyingSetAdd,
    this.onKeyingSetRemove,
    this.onKeyframeInsert,
    this.onKeyframeDelete,
    this.editorType = BlenderEditorType.outliner,
    this.onEditorTypeChanged,
  });

  final List<BlenderTreeNode<T>> roots;
  final String? selectedId;
  final ValueChanged<BlenderTreeNode<T>>? onSelected;
  final bool showVisibility;
  final bool showLock;
  final ValueChanged<BlenderTreeNode<T>>? onVisibilityChanged;
  final ValueChanged<BlenderTreeNode<T>>? onLockChanged;
  final String title;
  final List<Widget>? headerActions;
  final TextEditingController? filterController;
  final ValueChanged<String>? onFilterChanged;
  final String filterPlaceholder;
  final BlenderOutlinerDisplayMode displayMode;
  final ValueChanged<BlenderOutlinerDisplayMode>? onDisplayModeChanged;
  final bool syncSelection;
  final ValueChanged<bool>? onSyncSelectionChanged;
  final String libraryOverrideViewMode;
  final ValueChanged<String>? onLibraryOverrideViewModeChanged;
  final bool useIdFilter;
  final ValueChanged<bool>? onIdFilterChanged;
  final String idFilterType;
  final List<String> idFilterTypes;
  final ValueChanged<String>? onIdFilterTypeChanged;
  final VoidCallback? onNewCollection;
  final VoidCallback? onPurgeUnusedData;
  final bool hasActiveKeyingSet;
  final String activeKeyingSet;
  final List<String> keyingSets;
  final ValueChanged<String>? onKeyingSetChanged;
  final VoidCallback? onKeyingSetAdd;
  final VoidCallback? onKeyingSetRemove;
  final VoidCallback? onKeyframeInsert;
  final VoidCallback? onKeyframeDelete;

  /// The editor assigned to this area. Keeping this separate from
  /// [displayMode] mirrors Blender: the first control chooses the area editor,
  /// while the second chooses how the Outliner represents its data.
  final BlenderEditorType editorType;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;

  List<Widget> _buildSourceHeaderControls() {
    final controls = <Widget>[];
    switch (displayMode) {
      case BlenderOutlinerDisplayMode.videoSequencer:
        controls.add(
          BlenderIconButton(
            glyph: BlenderGlyph.sync,
            selected: syncSelection,
            onPressed: onSyncSelectionChanged == null
                ? null
                : () => onSyncSelectionChanged!(!syncSelection),
            tooltip: 'Sync Selection',
            size: 24,
          ),
        );
      case BlenderOutlinerDisplayMode.scenes:
      case BlenderOutlinerDisplayMode.viewLayer:
      case BlenderOutlinerDisplayMode.libraryOverrides:
        controls.add(const _BlenderOutlinerFilterMenu());
      case BlenderOutlinerDisplayMode.blenderFile:
      case BlenderOutlinerDisplayMode.unusedData:
        controls.add(
          BlenderIconButton(
            glyph: BlenderGlyph.filter,
            selected: useIdFilter,
            onPressed: onIdFilterChanged == null
                ? null
                : () => onIdFilterChanged!(!useIdFilter),
            tooltip: 'Filter ID Types',
            size: 24,
          ),
        );
        controls.add(
          SizedBox(
            width: 86,
            child: BlenderDropdown<String>(
              value: idFilterType,
              items: <BlenderMenuItem<String>>[
                for (final type in idFilterTypes)
                  BlenderMenuItem<String>(value: type, label: type),
              ],
              compact: true,
              enabled: useIdFilter,
              onChanged: onIdFilterTypeChanged ?? (_) {},
            ),
          ),
        );
      case BlenderOutlinerDisplayMode.dataApi:
        controls.add(
          BlenderIconButton(
            glyph: BlenderGlyph.plus,
            onPressed: onKeyingSetAdd,
            tooltip: 'Add Selected to Keying Set',
            size: 24,
          ),
        );
        controls.add(
          BlenderIconButton(
            glyph: BlenderGlyph.minus,
            onPressed: onKeyingSetRemove,
            tooltip: 'Remove Selected from Keying Set',
            size: 24,
          ),
        );
        if (hasActiveKeyingSet) {
          controls.add(
            SizedBox(
              width: 92,
              child: BlenderDropdown<String>(
                value: activeKeyingSet,
                items: <BlenderMenuItem<String>>[
                  for (final keyingSet in keyingSets)
                    BlenderMenuItem<String>(value: keyingSet, label: keyingSet),
                ],
                compact: true,
                onChanged: onKeyingSetChanged ?? (_) {},
              ),
            ),
          );
          controls.add(
            BlenderIconButton(
              glyph: BlenderGlyph.keyframe,
              onPressed: onKeyframeInsert,
              tooltip: 'Insert Keyframe',
              size: 24,
            ),
          );
          controls.add(
            BlenderIconButton(
              glyph: BlenderGlyph.keyframe,
              onPressed: onKeyframeDelete,
              tooltip: 'Delete Keyframe',
              size: 24,
            ),
          );
        } else {
          controls.add(const Text('No Keying Set Active'));
        }
    }
    if (displayMode == BlenderOutlinerDisplayMode.libraryOverrides) {
      controls.insert(
        0,
        SizedBox(
          width: 92,
          child: BlenderDropdown<String>(
            value: libraryOverrideViewMode,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Hierarchies',
                label: 'Hierarchies',
              ),
              BlenderMenuItem<String>(value: 'Properties', label: 'Properties'),
            ],
            compact: true,
            onChanged: onLibraryOverrideViewModeChanged ?? (_) {},
          ),
        ),
      );
    }
    if (displayMode == BlenderOutlinerDisplayMode.viewLayer) {
      controls.add(
        BlenderIconButton(
          glyph: BlenderGlyph.plus,
          onPressed: onNewCollection,
          tooltip: 'Add collection',
          size: 24,
        ),
      );
    } else if (displayMode == BlenderOutlinerDisplayMode.unusedData) {
      controls.add(
        BlenderButton(
          label: 'Purge',
          variant: BlenderButtonVariant.toolbar,
          onPressed: onPurgeUnusedData,
        ),
      );
    }
    return controls;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderEditorFrame(
      backgroundColor: theme.colors.surface,
      child: Column(
        children: <Widget>[
          BlenderToolbar(
            height: 30,
            scrollable: true,
            children: <Widget>[
              BlenderEditorTypeSelector(
                value: editorType,
                compact: true,
                width: 42,
                onChanged: onEditorTypeChanged,
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 42,
                child: BlenderDropdown<BlenderOutlinerDisplayMode>(
                  value: displayMode,
                  compact: true,
                  items: <BlenderMenuItem<BlenderOutlinerDisplayMode>>[
                    for (final mode in BlenderOutlinerDisplayMode.values)
                      BlenderMenuItem<BlenderOutlinerDisplayMode>(
                        value: mode,
                        label: BlenderOutlinerDisplayModePresentation.of(
                          mode,
                        ).label,
                        icon: BlenderIcon(
                          BlenderOutlinerDisplayModePresentation.of(mode).glyph,
                          size: 16,
                        ),
                      ),
                  ],
                  onChanged: onDisplayModeChanged ?? (_) {},
                ),
              ),
              if (filterController != null &&
                  !(displayMode ==
                          BlenderOutlinerDisplayMode.libraryOverrides &&
                      libraryOverrideViewMode == 'Hierarchies'))
                SizedBox(
                  width: 108,
                  child: BlenderSearchField(
                    controller: filterController!,
                    onChanged: onFilterChanged,
                    placeholder: filterPlaceholder,
                  ),
                ),
              ...?headerActions,
              ..._buildSourceHeaderControls(),
            ],
          ),
          Expanded(
            child: BlenderTree<T>(
              roots: roots,
              selectedId: selectedId,
              onSelected: onSelected,
              showVisibility: showVisibility,
              showLock: showLock,
              onVisibilityChanged: onVisibilityChanged,
              onLockChanged: onLockChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlenderOutlinerFilterMenu extends StatelessWidget {
  const _BlenderOutlinerFilterMenu();

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPopover(
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      child: const BlenderIconButton(
        glyph: BlenderGlyph.filter,
        tooltip: 'Filter options',
        size: 28,
      ),
      popover: (context, close) {
        var sortAlphabetically = true;
        var syncSelection = true;
        var showModeColumn = true;
        var collections = true;
        var objects = true;
        var objectContents = true;
        var objectChildren = true;
        var meshes = true;
        var lights = true;
        var cameras = true;
        var empties = true;
        Widget option(String label, bool value, ValueChanged<bool> onChanged) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: BlenderCheckbox(
              value: value,
              label: label,
              onChanged: onChanged,
            ),
          );
        }

        return StatefulBuilder(
          builder: (context, setState) => ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350, maxHeight: 590),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.menuBackground,
                border: Border.all(color: theme.colors.borderSubtle),
                borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x99000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Restriction Toggles',
                      style: theme.textTheme.body.copyWith(
                        color: theme.colors.foregroundMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: const <Widget>[
                        BlenderIconButton(
                          glyph: BlenderGlyph.check,
                          selected: true,
                          size: 28,
                        ),
                        BlenderIconButton(
                          glyph: BlenderGlyph.pointer,
                          size: 28,
                        ),
                        BlenderIconButton(
                          glyph: BlenderGlyph.eye,
                          selected: true,
                          size: 28,
                        ),
                        BlenderIconButton(glyph: BlenderGlyph.lock, size: 28),
                      ],
                    ),
                    const SizedBox(height: 12),
                    option(
                      'Sort Alphabetically',
                      sortAlphabetically,
                      (value) => setState(() => sortAlphabetically = value),
                    ),
                    option(
                      'Sync Selection',
                      syncSelection,
                      (value) => setState(() => syncSelection = value),
                    ),
                    option(
                      'Show Mode Column',
                      showModeColumn,
                      (value) => setState(() => showModeColumn = value),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Filter',
                      style: theme.textTheme.body.copyWith(
                        color: theme.colors.foregroundMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    option(
                      'Collections',
                      collections,
                      (value) => setState(() => collections = value),
                    ),
                    option(
                      'Objects',
                      objects,
                      (value) => setState(() => objects = value),
                    ),
                    option(
                      'Object Contents',
                      objectContents,
                      (value) => setState(() => objectContents = value),
                    ),
                    option(
                      'Object Children',
                      objectChildren,
                      (value) => setState(() => objectChildren = value),
                    ),
                    option(
                      'Meshes',
                      meshes,
                      (value) => setState(() => meshes = value),
                    ),
                    option(
                      'Lights',
                      lights,
                      (value) => setState(() => lights = value),
                    ),
                    option(
                      'Cameras',
                      cameras,
                      (value) => setState(() => cameras = value),
                    ),
                    option(
                      'Empties',
                      empties,
                      (value) => setState(() => empties = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BlenderFileEntry {
  const BlenderFileEntry({
    required this.path,
    required this.name,
    this.isDirectory = false,
    this.detail,
  });

  final String path;
  final String name;
  final bool isDirectory;
  final String? detail;
}

class BlenderFileBrowser extends StatelessWidget {
  const BlenderFileBrowser({
    super.key,
    required this.entries,
    this.selectedPath,
    this.onSelected,
    this.onOpen,
    this.searchController,
    this.pathSegments = const <String>[],
    this.onPathSelected,
    this.gridView = false,
    this.onGridViewChanged,
    this.onBack,
    this.onForward,
    this.onParent,
    this.onRefresh,
    this.onNewFolder,
    this.sidebar,
    this.sidebarWidth = 220,
    this.assetBrowser = false,
    this.title = 'File Browser',
  });

  final List<BlenderFileEntry> entries;
  final String? selectedPath;
  final ValueChanged<BlenderFileEntry>? onSelected;
  final ValueChanged<BlenderFileEntry>? onOpen;
  final TextEditingController? searchController;
  final List<String> pathSegments;
  final ValueChanged<int>? onPathSelected;
  final bool gridView;
  final ValueChanged<bool>? onGridViewChanged;
  final VoidCallback? onBack;
  final VoidCallback? onForward;
  final VoidCallback? onParent;
  final VoidCallback? onRefresh;
  final VoidCallback? onNewFolder;
  final Widget? sidebar;
  final double sidebarWidth;
  final bool assetBrowser;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final content = searchController == null
        ? _buildFilteredContent(context, entries, theme, '')
        : ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController!,
            builder: (context, value, child) => _buildFilteredContent(
              context,
              entries,
              theme,
              value.text.trim().toLowerCase(),
            ),
          );
    return BlenderPanel(
      title: title,
      headerActions: <Widget>[
        _headerAction(BlenderGlyph.stepBack, 'Back', onBack),
        _headerAction(BlenderGlyph.stepForward, 'Forward', onForward),
        _headerAction(BlenderGlyph.folder, 'Parent Directory', onParent),
        _headerAction(BlenderGlyph.refresh, 'Refresh', onRefresh),
        _headerAction(BlenderGlyph.plus, 'New Folder', onNewFolder),
        _BlenderFileBrowserPopover(assetBrowser: assetBrowser, filter: false),
        _BlenderFileBrowserPopover(assetBrowser: assetBrowser, filter: true),
        if (onGridViewChanged != null) ...<Widget>[
          BlenderIconButton(
            glyph: BlenderGlyph.outliner,
            selected: !gridView,
            onPressed: () => onGridViewChanged!(false),
            tooltip: 'List view',
            size: 22,
          ),
          BlenderIconButton(
            glyph: BlenderGlyph.grid,
            selected: gridView,
            onPressed: () => onGridViewChanged!(true),
            tooltip: 'Grid view',
            size: 22,
          ),
        ],
      ],
      child: sidebar == null
          ? content
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: content),
                SizedBox(
                  width: sidebarWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.surface,
                      border: Border(
                        left: BorderSide(color: theme.colors.editorBorder),
                      ),
                    ),
                    child: sidebar,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _headerAction(
    BlenderGlyph glyph,
    String tooltip,
    VoidCallback? callback,
  ) {
    return BlenderIconButton(
      glyph: glyph,
      tooltip: tooltip,
      onPressed: callback ?? () {},
      size: 22,
    );
  }

  Widget _buildFilteredContent(
    BuildContext context,
    List<BlenderFileEntry> source,
    BlenderThemeData theme,
    String query,
  ) {
    final visible = query.isEmpty
        ? source
        : source
              .where(
                (entry) =>
                    entry.name.toLowerCase().contains(query) ||
                    entry.path.toLowerCase().contains(query) ||
                    (entry.detail?.toLowerCase().contains(query) ?? false),
              )
              .toList(growable: false);
    return Column(
      children: <Widget>[
        if (pathSegments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 2),
            child: BlenderBreadcrumbs(
              items: pathSegments,
              onSelected: onPathSelected,
            ),
          ),
        if (searchController != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 4),
            child: BlenderFilterBar(
              controller: searchController!,
              placeholder: 'Search files',
            ),
          ),
        if (gridView)
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 140,
                mainAxisExtent: 72,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: visible.length,
              itemBuilder: (context, index) =>
                  _buildGridEntry(context, visible[index]),
            ),
          )
        else
          Expanded(
            child: BlenderListView<BlenderFileEntry>(
              items: [
                for (final entry in visible)
                  BlenderListItem<BlenderFileEntry>(
                    id: entry.path,
                    value: entry,
                    label: entry.name,
                    detail: entry.detail,
                    icon: entry.isDirectory
                        ? BlenderGlyph.folder
                        : BlenderGlyph.file,
                    iconColor: entry.isDirectory
                        ? theme.colors.iconFolder
                        : theme.colors.foregroundMuted,
                  ),
              ],
              selectedId: selectedPath,
              onSelected: onSelected == null
                  ? null
                  : (item) => onSelected!(item.value!),
              onActivated: onOpen == null
                  ? null
                  : (item) => onOpen!(item.value!),
            ),
          ),
      ],
    );
  }

  Widget _buildGridEntry(BuildContext context, BlenderFileEntry entry) {
    final theme = BlenderTheme.of(context);
    final selected = entry.path == selectedPath;
    return GestureDetector(
      onTap: () => onSelected?.call(entry),
      onDoubleTap: () => onOpen?.call(entry),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? theme.colors.selection : theme.colors.surface,
          border: Border.all(color: theme.colors.editorBorder),
          borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BlenderIcon(
              entry.isDirectory ? BlenderGlyph.folder : BlenderGlyph.file,
              color: entry.isDirectory
                  ? theme.colors.iconFolder
                  : theme.colors.foregroundMuted,
            ),
            const SizedBox(height: 3),
            Text(entry.name, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

/// Source-shaped File Browser and Asset Browser header popovers from
/// `space_filebrowser.py`.
class _BlenderFileBrowserPopover extends StatelessWidget {
  const _BlenderFileBrowserPopover({
    required this.assetBrowser,
    required this.filter,
  });

  final bool assetBrowser;
  final bool filter;

  Widget _check(String label, {bool value = true}) => BlenderPropertyRow(
    label: label,
    editor: BlenderCheckbox(value: value, onChanged: (_) {}),
  );

  Widget _choice(String label, String value, List<String> values) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderDropdown<String>(
        value: value,
        items: <BlenderMenuItem<String>>[
          for (final item in values)
            BlenderMenuItem<String>(value: item, label: item),
        ],
        onChanged: (_) {},
      ),
    );
  }

  List<Widget> _displayChildren() {
    if (assetBrowser) {
      return <Widget>[
        _choice('Display Type', 'Thumbnail', <String>[
          'Thumbnail',
          'List Horizontal',
          'List Vertical',
        ]),
        _choice('Preview Size', 'Medium', <String>['Small', 'Medium', 'Large']),
        _choice('Sort By', 'Name', <String>['Name', 'Asset Type', 'Modified']),
      ];
    }
    return <Widget>[
      _choice('Display Type', 'List Vertical', <String>[
        'List Vertical',
        'List Horizontal',
        'Thumbnail',
      ]),
      _choice('Size', 'Medium', <String>['Small', 'Medium', 'Large']),
      _check('Date', value: false),
      _choice('Recursions', 'None', <String>['None', 'One Level', 'All']),
      _choice('Sort By', 'Name', <String>['Name', 'Modified', 'Size', 'Type']),
      _check('Invert Sort', value: false),
    ];
  }

  List<Widget> _filterChildren() {
    if (assetBrowser) {
      return <Widget>[
        _check('Blender IDs'),
        _check('Objects'),
        _check('Materials'),
        _check('Collections'),
        _check('Worlds', value: false),
        _choice('Access', 'All', <String>['All', 'Local', 'Remote']),
      ];
    }
    return <Widget>[
      _check('Folders'),
      _check('.blend Files'),
      _check('Backup .blend Files', value: false),
      _check('Image Files'),
      _check('Movie Files', value: false),
      _check('Script Files', value: false),
      _check('Font Files', value: false),
      _check('Sound Files', value: false),
      _check('Text Files', value: false),
      _check('Volume Files', value: false),
      _check('Show Hidden', value: false),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final title = filter
        ? (assetBrowser ? 'Filter' : 'Filter Settings')
        : (assetBrowser ? 'Display Settings' : 'Display Settings');
    return BlenderPopover(
      child: BlenderIconButton(
        glyph: filter ? BlenderGlyph.filter : BlenderGlyph.settings,
        tooltip: title,
        size: 22,
      ),
      popover: (context, close) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330, maxHeight: 620),
        child: SingleChildScrollView(
          child: BlenderPanel(
            title: title,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: filter ? _filterChildren() : _displayChildren(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Source-shaped File Browser and Asset Browser side panels.
///
/// Blender owns the region visibility, file operations, asset metadata, and
/// catalog mutation. This widget only provides the visual panel anatomy so a
/// host can supply those behaviors separately.
class BlenderFileBrowserSidebar extends StatelessWidget {
  const BlenderFileBrowserSidebar({
    super.key,
    this.assetBrowser = false,
    this.assetCatalog,
  });

  final bool assetBrowser;
  final Widget? assetCatalog;

  Widget _body(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );

  Widget _panel(String title, List<Widget> children, {bool expanded = false}) {
    return BlenderPanel(
      title: title,
      collapsible: true,
      initiallyExpanded: expanded,
      child: _body(children),
    );
  }

  Widget _check(String label, {bool value = true}) => BlenderPropertyRow(
    label: label,
    editor: BlenderCheckbox(value: value, onChanged: (_) {}),
  );

  Widget _choice(String label, String value, List<String> values) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderDropdown<String>(
        value: value,
        items: <BlenderMenuItem<String>>[
          for (final item in values)
            BlenderMenuItem<String>(value: item, label: item),
        ],
        onChanged: (_) {},
      ),
    );
  }

  Widget _actions(List<String> labels) => Wrap(
    spacing: 4,
    runSpacing: 4,
    children: <Widget>[
      for (final label in labels) BlenderButton(label: label, onPressed: () {}),
    ],
  );

  Widget _list(List<String> labels) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      for (final label in labels)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          child: Row(
            children: <Widget>[
              const BlenderIcon(BlenderGlyph.folder, size: 14),
              const SizedBox(width: 5),
              Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final panels = assetBrowser
        ? <Widget>[
            _panel('Library', <Widget>[
              _choice('Access', 'All', <String>['All', 'Local', 'Remote']),
              _actions(<String>['Refresh', 'Reload Listing']),
            ], expanded: true),
            if (assetCatalog != null)
              SizedBox(height: 300, child: assetCatalog)
            else
              _panel('Catalog', <Widget>[
                _actions(<String>['Undo', 'Redo', 'Save', 'New']),
              ]),
            _panel('Asset', <Widget>[
              _actions(<String>['Clear Asset', 'Open Containing File']),
            ]),
            _panel('Asset Metadata', <Widget>[
              BlenderPropertyRow(
                label: 'Name',
                editor: BlenderTextField(
                  controller: TextEditingController(text: 'Showcase Asset'),
                  readOnly: true,
                ),
              ),
              BlenderPropertyRow(
                label: 'Description',
                editor: BlenderTextField(
                  controller: TextEditingController(
                    text: 'Source-shaped asset',
                  ),
                  readOnly: true,
                ),
              ),
              _choice('License', 'CC0', <String>['CC0', 'GPL', 'Unknown']),
              _choice('Author', 'Blender UI', <String>[
                'Blender UI',
                'Unknown',
              ]),
            ], expanded: true),
            _panel('Import', <Widget>[
              _check('Use Preferred Method'),
              _choice('Preferred Method', 'Link', <String>['Link', 'Append']),
            ]),
            _panel('Preview', <Widget>[
              const SizedBox(
                height: 70,
                child: Center(child: BlenderIcon(BlenderGlyph.image, size: 32)),
              ),
              _actions(<String>['Load', 'Generate', 'Remove']),
            ]),
            _panel('Tags', <Widget>[
              _list(<String>['Environment', 'Asset']),
              _actions(<String>['Add', 'Remove']),
            ]),
          ]
        : <Widget>[
            _panel('Directory Path', <Widget>[
              _actions(<String>['Back', 'Forward', 'Parent', 'Refresh']),
              BlenderTextField(
                controller: TextEditingController(text: '/showcase/assets'),
                readOnly: true,
              ),
              _actions(<String>['New Folder']),
            ], expanded: true),
            _panel('Volumes', <Widget>[
              _list(<String>['Home', 'Documents']),
            ], expanded: true),
            _panel('System', <Widget>[
              _list(<String>['Desktop', 'Downloads']),
            ]),
            _panel('Bookmarks', <Widget>[
              _list(<String>['Showcase', 'Assets']),
              _actions(<String>['Add', 'Remove', 'Move']),
            ]),
            _panel('Recent', <Widget>[
              _list(<String>['scene.blend', 'assets']),
              _actions(<String>['Clear']),
            ]),
            _panel('Advanced Filter', <Widget>[
              _check('Blender Files Only'),
              _check('Asset Data', value: false),
              _check('Fonts', value: false),
              _check('Images', value: false),
              _check('Movies', value: false),
            ]),
          ];
    return ListView(padding: const EdgeInsets.all(4), children: panels);
  }
}

class BlenderTimelineKeyframe {
  const BlenderTimelineKeyframe(this.frame, {this.color});

  final double frame;
  final Color? color;
}

class BlenderTimelineTrack {
  const BlenderTimelineTrack({
    required this.id,
    required this.label,
    this.keyframes = const <BlenderTimelineKeyframe>[],
  });

  final String id;
  final String label;
  final List<BlenderTimelineKeyframe> keyframes;
}

class BlenderTimelineModel {
  const BlenderTimelineModel({
    required this.start,
    required this.end,
    required this.currentFrame,
    this.tracks = const <BlenderTimelineTrack>[],
  });

  final double start;
  final double end;
  final double currentFrame;
  final List<BlenderTimelineTrack> tracks;
}

class BlenderTimeline extends StatelessWidget {
  const BlenderTimeline({
    super.key,
    required this.model,
    required this.onCurrentFrameChanged,
    this.title = 'Timeline',
    this.trackHeight = 24,
  });

  final BlenderTimelineModel model;
  final ValueChanged<double> onCurrentFrameChanged;
  final String? title;
  final double trackHeight;

  double _frameForPosition(double width, double x) {
    return model.start + (model.end - model.start) * (x / math.max(1, width));
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final height = math
        .max(64, model.tracks.length * trackHeight + 28)
        .toDouble();
    return BlenderPanel(
      title: title,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) => onCurrentFrameChanged(
              _frameForPosition(constraints.maxWidth, details.localPosition.dx),
            ),
            onHorizontalDragUpdate: (details) => onCurrentFrameChanged(
              _frameForPosition(constraints.maxWidth, details.localPosition.dx),
            ),
            child: SizedBox(
              height: height,
              child: CustomPaint(
                painter: _BlenderTimelinePainter(
                  model: model,
                  trackHeight: trackHeight,
                  colors: theme.colors,
                  textTheme: theme.textTheme,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BlenderTimelinePainter extends CustomPainter {
  _BlenderTimelinePainter({
    required this.model,
    required this.trackHeight,
    required this.colors,
    required this.textTheme,
  });

  final BlenderTimelineModel model;
  final double trackHeight;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;

  @override
  void paint(Canvas canvas, Size size) {
    final range = math.max(.0001, model.end - model.start);
    const headerHeight = 28.0;
    final linePaint = Paint()..color = colors.borderSubtle;
    final mutedPaint = Paint()..color = colors.foregroundMuted;
    canvas.drawLine(
      const Offset(0, headerHeight),
      Offset(size.width, headerHeight),
      linePaint,
    );
    for (
      var frame = model.start.ceilToDouble();
      frame <= model.end;
      frame += 10
    ) {
      final x = (frame - model.start) / range * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
      final textPainter = TextPainter(
        text: TextSpan(
          text: frame.toStringAsFixed(0),
          style: textTheme.caption.copyWith(color: colors.foregroundMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, Offset(x + 2, 5));
    }
    for (var index = 0; index < model.tracks.length; index++) {
      final y = headerHeight + index * trackHeight;
      canvas.drawLine(
        Offset(0, y + trackHeight),
        Offset(size.width, y + trackHeight),
        linePaint,
      );
      final labelPainter = TextPainter(
        text: TextSpan(
          text: model.tracks[index].label,
          style: textTheme.caption.copyWith(color: colors.foreground),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 100);
      labelPainter.paint(canvas, Offset(6, y + 5));
      for (final keyframe in model.tracks[index].keyframes) {
        final x = (keyframe.frame - model.start) / range * size.width;
        final color = keyframe.color ?? colors.accent;
        final keyframePaint = Paint()..color = color;
        final points = <Offset>[
          Offset(x, y + trackHeight / 2),
          Offset(x + 5, y + trackHeight / 2 - 5),
          Offset(x + 10, y + trackHeight / 2),
          Offset(x + 5, y + trackHeight / 2 + 5),
        ];
        canvas.drawPath(Path()..addPolygon(points, true), keyframePaint);
      }
    }
    final cursorX = (model.currentFrame - model.start) / range * size.width;
    canvas.drawLine(
      Offset(cursorX, 0),
      Offset(cursorX, size.height),
      mutedPaint..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_BlenderTimelinePainter oldDelegate) {
    return model != oldDelegate.model ||
        trackHeight != oldDelegate.trackHeight ||
        colors != oldDelegate.colors;
  }
}

class BlenderNodeSocketDefinition {
  const BlenderNodeSocketDefinition({
    required this.id,
    required this.label,
    this.color,
    this.detail,
  });

  final String id;
  final String label;
  final Color? color;
  final String? detail;
}

class BlenderNodeSocket extends StatelessWidget {
  const BlenderNodeSocket({
    super.key,
    required this.label,
    this.color,
    this.detail,
    this.output = false,
  });

  final String label;
  final Color? color;
  final String? detail;
  final bool output;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final socket = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color ?? theme.colors.panelHeader,
        shape: BoxShape.circle,
        border: Border.all(color: theme.colors.borderSubtle),
      ),
    );
    final labelWidget = Flexible(
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        textAlign: output ? TextAlign.right : TextAlign.left,
        style: theme.textTheme.caption,
      ),
    );
    final detailWidget = detail == null
        ? const SizedBox.shrink()
        : Text(
            detail!,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.caption.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          );
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisAlignment: output
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: output
            ? <Widget>[
                detailWidget,
                const SizedBox(width: 3),
                labelWidget,
                const SizedBox(width: 4),
                socket,
              ]
            : <Widget>[
                socket,
                const SizedBox(width: 4),
                labelWidget,
                const SizedBox(width: 3),
                detailWidget,
              ],
      ),
    );
  }
}

class BlenderGraphNode {
  const BlenderGraphNode({
    required this.id,
    required this.title,
    required this.position,
    this.size = const Size(150, 90),
    this.inputs = const <BlenderNodeSocketDefinition>[],
    this.outputs = const <BlenderNodeSocketDefinition>[],
  });

  final String id;
  final String title;
  final Offset position;
  final Size size;
  final List<BlenderNodeSocketDefinition> inputs;
  final List<BlenderNodeSocketDefinition> outputs;
}

class BlenderGraphLink {
  const BlenderGraphLink({required this.from, required this.to});

  final String from;
  final String to;
}

class BlenderNodeGraphModel {
  const BlenderNodeGraphModel({
    this.nodes = const <BlenderGraphNode>[],
    this.links = const <BlenderGraphLink>[],
  });

  final List<BlenderGraphNode> nodes;
  final List<BlenderGraphLink> links;
}

/// Source-shaped 3D Viewport sidebar panels from `space_view3d.py`,
/// `space_view3d_sidebar.py`, and the viewport transform template.
///
/// View state, object transforms, collections, and animation operators remain
/// caller-owned; this widget mirrors the visible N-panel families.
class BlenderViewportSidebar extends StatelessWidget {
  const BlenderViewportSidebar({super.key});

  Widget _body(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );

  Widget _panel(String title, List<Widget> children, {bool expanded = false}) {
    return BlenderPanel(
      title: title,
      collapsible: true,
      initiallyExpanded: expanded,
      child: _body(children),
    );
  }

  Widget _check(String label, {bool value = true}) => BlenderPropertyRow(
    label: label,
    editor: BlenderCheckbox(value: value, onChanged: (_) {}),
  );

  Widget _number(String label, double value) => BlenderPropertyRow(
    label: label,
    editor: BlenderNumberField(
      value: value,
      decimalDigits: 2,
      onChanged: (_) {},
    ),
  );

  Widget _choice(String label, String value, List<String> values) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderDropdown<String>(
        value: value,
        items: <BlenderMenuItem<String>>[
          for (final item in values)
            BlenderMenuItem<String>(value: item, label: item),
        ],
        onChanged: _viewportNoopString,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(6),
      children: <Widget>[
        _panel('View', <Widget>[
          _number('Focal Length', 50),
          _number('Clip Start', .01),
          _number('Clip End', 1000),
          _check('Use Local Camera', value: false),
          _choice('Camera', 'Camera', <String>['Camera', 'None']),
          _check('Passepartout', value: false),
          _check('Render Region', value: false),
          _panel('View Lock', <Widget>[
            _choice('Lock Object', 'None', <String>['None', 'Cube', 'Camera']),
            _check('To 3D Cursor', value: false),
            _check('Camera to View', value: false),
            _check('Rotation', value: false),
          ]),
          _panel('3D Cursor', <Widget>[
            _number('Location X', 0),
            _number('Location Y', 0),
            _number('Location Z', 0),
            _number('Rotation X', 0),
            _number('Rotation Y', 0),
            _number('Rotation Z', 0),
            _choice('Rotation Mode', 'XYZ Euler', <String>[
              'XYZ Euler',
              'Quaternion',
              'Axis Angle',
            ]),
          ]),
          _panel('Collections', <Widget>[
            _check('Collection'),
            _check('Environment', value: false),
            _check('Characters', value: false),
          ]),
        ], expanded: true),
        _panel('Item', <Widget>[
          _panel('Transform', <Widget>[
            _number('Location X', 0),
            _number('Location Y', 0),
            _number('Location Z', 0),
            _number('Rotation X', 0),
            _number('Rotation Y', 0),
            _number('Rotation Z', 0),
            _number('Scale X', 1),
            _number('Scale Y', 1),
            _number('Scale Z', 1),
          ], expanded: true),
          _choice('Mode', 'Object', <String>['Object', 'Edit', 'Pose']),
        ], expanded: true),
        _panel('Global Transform', <Widget>[
          const BlenderButton(label: 'Copy', onPressed: _viewportNoop),
          const SizedBox(height: 4),
          const Row(
            children: <Widget>[
              Expanded(
                child: BlenderButton(label: 'Paste', onPressed: _viewportNoop),
              ),
              SizedBox(width: 4),
              Expanded(
                child: BlenderButton(
                  label: 'Mirrored',
                  onPressed: _viewportNoop,
                ),
              ),
            ],
          ),
          _panel('Fix to Camera', <Widget>[
            _check('Location'),
            _check('Rotation'),
            _check('Scale'),
          ]),
          _panel('Mirror', <Widget>[
            _choice('Object', 'Active Armature', <String>[
              'Active Armature',
              'None',
            ]),
            _choice('Bone', 'Bone', <String>['Bone', 'Root']),
          ]),
          _panel('Relative', <Widget>[
            _choice('Object', 'Active Camera', <String>[
              'Active Camera',
              'None',
            ]),
          ]),
        ]),
      ],
    );
  }
}

void _viewportNoop() {}

void _viewportNoopString(String? _) {}

class BlenderNodeEditor extends StatelessWidget {
  const BlenderNodeEditor({
    super.key,
    required this.model,
    this.onNodeSelected,
    this.onNodeMoved,
    this.sidebar,
    this.sidebarWidth = 230,
    this.title = 'Node Editor',
  });

  final BlenderNodeGraphModel model;
  final ValueChanged<BlenderGraphNode>? onNodeSelected;
  final void Function(BlenderGraphNode node, Offset position)? onNodeMoved;
  final Widget? sidebar;
  final double sidebarWidth;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: sidebar == null
          ? _buildCanvas(context, theme)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: _buildCanvas(context, theme)),
                SizedBox(
                  width: sidebarWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.surface,
                      border: Border(
                        left: BorderSide(color: theme.colors.editorBorder),
                      ),
                    ),
                    child: sidebar,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCanvas(BuildContext context, BlenderThemeData theme) {
    return InteractiveViewer(
      minScale: .25,
      maxScale: 3,
      boundaryMargin: const EdgeInsets.all(400),
      child: SizedBox(
        width: 2000,
        height: 1200,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: _BlenderGraphPainter(
                  model: model,
                  color: theme.colors.borderSubtle,
                ),
              ),
            ),
            for (final node in model.nodes)
              Positioned(
                left: node.position.dx,
                top: node.position.dy,
                width: node.size.width,
                height: node.size.height,
                child: GestureDetector(
                  onTap: () => onNodeSelected?.call(node),
                  onPanUpdate: onNodeMoved == null
                      ? null
                      : (details) =>
                            onNodeMoved!(node, node.position + details.delta),
                  child: BlenderPanel(
                    title: node.title,
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
                    child: _BlenderNodeBody(node: node),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Source-shaped sidebar panels for Blender's Node Editor.
///
/// Node selection, node-tree evaluation, and operator execution remain
/// caller-owned; this widget provides the Tool, Node, View, Options, and Group
/// panel composition from `space_node.py`.
class BlenderNodeEditorSidebar extends StatelessWidget {
  const BlenderNodeEditorSidebar({
    super.key,
    this.geometryNodeEditor = false,
    this.compositor = false,
  });

  final bool geometryNodeEditor;
  final bool compositor;

  Widget _body(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );

  Widget _panel(String title, List<Widget> children, {bool expanded = false}) {
    return BlenderPanel(
      title: title,
      collapsible: true,
      initiallyExpanded: expanded,
      child: _body(children),
    );
  }

  Widget _check(String label, {bool value = true}) => BlenderPropertyRow(
    label: label,
    editor: BlenderCheckbox(value: value, onChanged: (_) {}),
  );

  Widget _number(String label, double value) => BlenderPropertyRow(
    label: label,
    editor: BlenderNumberField(
      value: value,
      decimalDigits: 2,
      onChanged: (_) {},
    ),
  );

  Widget _choice(String label, String value, List<String> values) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderDropdown<String>(
        value: value,
        items: <BlenderMenuItem<String>>[
          for (final item in values)
            BlenderMenuItem<String>(value: item, label: item),
        ],
        onChanged: (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toolPanels = <Widget>[
      _panel('Tool', <Widget>[
        _check('Select'),
        _check('Tweak'),
        _choice('Node Tool', 'Select Box', <String>['Select Box', 'Tweak']),
      ], expanded: true),
      if (geometryNodeEditor) ...<Widget>[
        _panel('Object Types', <Widget>[
          _check('Mesh'),
          _check('Curve'),
          _check('Volume'),
        ]),
        _panel('Modes', <Widget>[_check('Object Mode'), _check('Edit Mode')]),
        _panel('Options', <Widget>[
          _check('Auto Offset'),
          _check('Transform Node Parents'),
        ]),
      ],
    ];
    final nodePanels = <Widget>[
      _panel('Node', <Widget>[
        _choice('Name', 'Node', <String>['Node', 'Active Node']),
        _choice('Label', 'Custom Label', <String>[
          'Custom Label',
          'Node Name',
          'Hidden',
        ]),
        _check('Use Custom Color'),
        _check('Show Options'),
        _check('Mute'),
        if (geometryNodeEditor || compositor) _check('Propagate Warnings'),
      ], expanded: true),
      _panel('Properties', <Widget>[
        _choice('Input', 'Value', <String>['Value', 'Default', 'Linked']),
        _check('Use Default'),
      ]),
      _panel('Custom Properties', <Widget>[_number('example_value', 1)]),
      _panel('Texture Mapping', <Widget>[
        _choice('Vector', 'Generated', <String>['Generated', 'Normal', 'UV']),
        _choice('Projection X', 'Flat', <String>['Flat', 'Box', 'Sphere']),
        _choice('Projection Y', 'Flat', <String>['Flat', 'Box', 'Sphere']),
        _choice('Projection Z', 'Flat', <String>['Flat', 'Box', 'Sphere']),
        _number('Scale', 1),
      ]),
    ];
    final viewPanels = <Widget>[
      if (compositor)
        _panel('Backdrop', <Widget>[
          _choice('Channels', 'Color', <String>[
            'Color',
            'Color and Alpha',
            'Alpha',
          ]),
          _number('Zoom', 1),
          _number('Offset X', 0),
          _number('Offset Y', 0),
          _check('Show Backdrop'),
          _check('Fit to Available Space'),
        ]),
      _panel('Annotation', <Widget>[
        _check('Use Annotation'),
        _choice('Layer', 'Main', <String>['Main', 'Notes']),
      ]),
    ];
    final optionPanels = <Widget>[
      if (compositor)
        _panel('Performance', <Widget>[
          _choice('Device', 'CPU', <String>['CPU', 'GPU']),
          _choice('Precision', 'Full', <String>['Full', 'Half']),
          _check('Cache Frames'),
        ], expanded: true),
    ];
    final groupPanels = <Widget>[
      _panel('Group', <Widget>[
        _choice('Name', 'Node Group', <String>['Node Group', 'Group']),
        _choice('Description', 'Node group description', <String>[
          'Node group description',
          'Empty',
        ]),
        _choice('Color Tag', 'None', <String>[
          'None',
          'Attribute',
          'Geometry',
          'Shader',
        ]),
        _number('Node Width', 140),
        if (geometryNodeEditor) _check('Modifier'),
        if (geometryNodeEditor) _check('Tool'),
        if (compositor) _check('Strip Modifier'),
      ], expanded: true),
      _panel('Animation', <Widget>[
        _choice('Action', 'NodeGroupAction', <String>[
          'NodeGroupAction',
          'None',
        ]),
        _choice('Slot', 'Node Group', <String>['Node Group', 'None']),
      ]),
    ];
    return ListView(
      padding: const EdgeInsets.all(4),
      children: <Widget>[
        ...toolPanels,
        ...nodePanels,
        _panel('View', viewPanels),
        ...optionPanels,
        ...groupPanels,
      ],
    );
  }
}

class _BlenderNodeBody extends StatelessWidget {
  const _BlenderNodeBody({required this.node});

  final BlenderGraphNode node;

  @override
  Widget build(BuildContext context) {
    if (node.inputs.isEmpty && node.outputs.isEmpty) {
      return const Align(
        alignment: Alignment.topLeft,
        child: BlenderIcon(BlenderGlyph.cube, size: 18),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final socket in node.inputs)
                BlenderNodeSocket(
                  label: socket.label,
                  color: socket.color,
                  detail: socket.detail,
                ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final socket in node.outputs)
                BlenderNodeSocket(
                  label: socket.label,
                  color: socket.color,
                  detail: socket.detail,
                  output: true,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlenderGraphPainter extends CustomPainter {
  _BlenderGraphPainter({required this.model, required this.color});

  final BlenderNodeGraphModel model;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = <String, BlenderGraphNode>{
      for (final node in model.nodes) node.id: node,
    };
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final link in model.links) {
      final from = nodes[link.from];
      final to = nodes[link.to];
      if (from == null || to == null) continue;
      final start =
          from.position + Offset(from.size.width, from.size.height / 2);
      final end = to.position + Offset(0, to.size.height / 2);
      final curve = Path()..moveTo(start.dx, start.dy);
      final midpoint = (start.dx + end.dx) / 2;
      curve.cubicTo(midpoint, start.dy, midpoint, end.dy, end.dx, end.dy);
      canvas.drawPath(curve, paint);
    }
  }

  @override
  bool shouldRepaint(_BlenderGraphPainter oldDelegate) {
    return model != oldDelegate.model || color != oldDelegate.color;
  }
}
