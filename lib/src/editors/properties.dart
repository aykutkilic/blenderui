part of '../editors.dart';

typedef BlenderPropertyEditorBuilder<T> =
    Widget Function(BuildContext context, T value, ValueChanged<T> onChanged);

/// Controls where a property name is drawn in Blender's split property layout.
///
/// Most properties place their name in the 40% label column. Boolean
/// properties are the notable exception: Blender keeps the checkbox and its
/// name together in the 60% value column.
enum BlenderPropertyLabelPlacement { splitColumn, valueColumn }

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
    this.enabled = true,
    this.headerLeading,
    this.headerActions,
    this.content,
    this.children = const <BlenderPropertyGroup>[],
  });

  final String id;
  final String title;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final bool initiallyExpanded;

  /// Whether the panel body is active. The header remains interactive so a
  /// caller can expose Blender-style enable checkboxes in [headerLeading].
  final bool enabled;

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
    final groupContent = _buildGroupContents(context, view, searchActive);
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
      child: group.enabled
          ? groupContent
          : IgnorePointer(child: Opacity(opacity: .5, child: groupContent)),
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
          // Keep the package's Flutter 3.41 compatibility floor.
          // ignore: deprecated_member_use
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
