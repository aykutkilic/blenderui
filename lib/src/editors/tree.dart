part of '../editors.dart';

class BlenderTreeNode<T> {
  const BlenderTreeNode({
    required this.id,
    required this.label,
    this.value,
    this.children = const [],
    this.hasChildren = false,
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
    this.dragData,
    this.canAcceptDrop,
    this.onAcceptDrop,
    this.onDragEntered,
    this.onDragExited,
    this.onContextMenuRequested,
  });

  final String id;
  final String label;
  final T? value;
  final List<BlenderTreeNode<T>> children;

  /// Indicates that child rows are loaded lazily. It keeps the disclosure
  /// affordance available before an application has fetched the branch.
  final bool hasChildren;
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

  /// Optional payload used to make this row draggable. The tree deliberately
  /// keeps the payload untyped so applications can move heterogeneous domain
  /// records through the same Outliner.
  final Object? dragData;
  final bool Function(Object data)? canAcceptDrop;
  final FutureOr<void> Function(Object data)? onAcceptDrop;
  final ValueChanged<Object>? onDragEntered;
  final VoidCallback? onDragExited;
  final ValueChanged<Offset>? onContextMenuRequested;
}

class BlenderTree<T> extends StatefulWidget {
  const BlenderTree({
    super.key,
    required this.roots,
    this.selectedId,
    this.onSelected,
    this.onActivated,
    this.contextMenuTitleBuilder,
    this.rowHeight,
    this.indent = 16,
    this.showVisibility = false,
    this.showLock = false,
    this.onVisibilityChanged,
    this.onLockChanged,
    this.contextMenuItemsBuilder,
    this.onContextMenuSelected,
    this.expandedIds,
    this.onExpandedChanged,
  });

  final List<BlenderTreeNode<T>> roots;
  final String? selectedId;
  final ValueChanged<BlenderTreeNode<T>>? onSelected;

  /// Called when a selectable row is double-clicked.
  final ValueChanged<BlenderTreeNode<T>>? onActivated;
  final String Function(BlenderTreeNode<T>)? contextMenuTitleBuilder;
  final double? rowHeight;
  final double indent;
  final bool showVisibility;
  final bool showLock;
  final ValueChanged<BlenderTreeNode<T>>? onVisibilityChanged;
  final ValueChanged<BlenderTreeNode<T>>? onLockChanged;
  final List<BlenderMenuItem<String>> Function(BlenderTreeNode<T>)?
  contextMenuItemsBuilder;
  final void Function(BlenderTreeNode<T>, String)? onContextMenuSelected;

  /// Optional externally-owned expansion state. Supplying this lets an
  /// application restore a data tree lazily without treating its visual
  /// expansion as transient widget state.
  final Set<String>? expandedIds;

  /// Called after the user expands or collapses a node. The full set is
  /// provided so callers can persist it directly.
  final ValueChanged<Set<String>>? onExpandedChanged;

  @override
  State<BlenderTree<T>> createState() => _BlenderTreeState<T>();
}

class _BlenderTreeState<T> extends State<BlenderTree<T>> {
  late final ScrollController _scrollController;
  late final Set<String> _expanded;
  String? _hoveredNodeId;
  String? _lastTappedNodeId;
  Duration? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _expanded = widget.expandedIds == null
        ? BlenderTreeState.initialExpanded<BlenderTreeNode<T>>(
            widget.roots,
            idOf: (node) => node.id,
            childrenOf: (node) => node.children,
            initiallyExpanded: (node) => node.initiallyExpanded,
          )
        : <String>{...widget.expandedIds!};
  }

  void _toggleExpanded(String id) {
    setState(() {
      if (_expanded.contains(id)) {
        _expanded.remove(id);
      } else {
        _expanded.add(id);
      }
    });
    widget.onExpandedChanged?.call(Set<String>.unmodifiable(_expanded));
  }

  void _handleSelectablePointerDown(
    BlenderTreeNode<T> node,
    PointerDownEvent event,
  ) {
    if (event.kind != PointerDeviceKind.touch &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    widget.onSelected?.call(node);
    final previousNodeId = _lastTappedNodeId;
    final previousTime = _lastTapTime;
    final isDoubleTap =
        previousNodeId == node.id &&
        previousTime != null &&
        event.timeStamp - previousTime <= const Duration(milliseconds: 300);
    if (isDoubleTap) {
      widget.onActivated?.call(node);
      _lastTappedNodeId = null;
      _lastTapTime = null;
    } else {
      _lastTappedNodeId = node.id;
      _lastTapTime = event.timeStamp;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final visible = BlenderTreeState.flatten<BlenderTreeNode<T>>(
      widget.roots,
      idOf: (node) => node.id,
      childrenOf: (node) => node.children,
      expanded: _expanded,
    );
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
              final node = entry.value;
              final hasChildren = node.children.isNotEmpty || node.hasChildren;
              final selected = node.id == widget.selectedId;
              final alternate = index.isOdd;
              final contextMenuItems =
                  widget.contextMenuItemsBuilder?.call(node) ??
                  const <BlenderMenuItem<String>>[];
              Widget row = GestureDetector(
                behavior: HitTestBehavior.opaque,
                onSecondaryTapDown: node.onContextMenuRequested == null
                    ? null
                    : (details) =>
                          node.onContextMenuRequested!(details.globalPosition),
                onLongPressStart: node.onContextMenuRequested == null
                    ? null
                    : (details) =>
                          node.onContextMenuRequested!(details.globalPosition),
                child: DecoratedBox(
                  key: ValueKey<String>('tree-row-${node.id}'),
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
                      // Flutter centers a text line box, while Blender aligns
                      // tree labels and icons to its optical row center. Keep
                      // the shared Tree (and therefore Outliner) one logical
                      // pixel below the geometric guide center so nested row
                      // content does not look vertically raised.
                      Transform.translate(
                        offset: const Offset(0, 1),
                        child: Padding(
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
                                        onTap: () => _toggleExpanded(node.id),
                                        child: Center(
                                          child: BlenderTooltip(
                                            message: _expanded.contains(node.id)
                                                ? 'Collapse'
                                                : 'Expand',
                                            child: BlenderIcon(
                                              key: ValueKey<String>(
                                                'tree-disclosure-${node.id}',
                                              ),
                                              _expanded.contains(node.id)
                                                  ? BlenderGlyph
                                                        .panelDisclosureDown
                                                  : BlenderGlyph
                                                        .panelDisclosureRight,
                                              size: 9,
                                            ),
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
                                        key: ValueKey<String>(
                                          'tree-label-${node.id}',
                                        ),
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
                                          padding: const EdgeInsets.only(
                                            left: 4,
                                          ),
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
                                  (_hoveredNodeId == node.id ||
                                      node.dropTarget))
                                BlenderIconButton(
                                  glyph: node.actionIcon!,
                                  onPressed: node.onAction,
                                  tooltip: node.actionTooltip,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              // Select on pointer-down so adding double-click activation does
              // not delay ordinary single-click selection until the double
              // tap recognizer times out.
              if (node.selectable) {
                row = Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (event) =>
                      _handleSelectablePointerDown(node, event),
                  child: row,
                );
              }
              row = MouseRegion(
                onEnter: (_) => setState(() => _hoveredNodeId = node.id),
                onExit: (_) {
                  if (_hoveredNodeId == node.id) {
                    setState(() => _hoveredNodeId = null);
                  }
                },
                child: row,
              );
              if (node.canAcceptDrop != null && node.onAcceptDrop != null) {
                final dragTargetChild = row;
                row = DragTarget<Object>(
                  onWillAcceptWithDetails: (details) {
                    final accepted = node.canAcceptDrop!(details.data);
                    if (accepted) node.onDragEntered?.call(details.data);
                    return accepted;
                  },
                  onLeave: (_) => node.onDragExited?.call(),
                  onAcceptWithDetails: (details) {
                    node.onDragExited?.call();
                    unawaited(
                      Future<void>.sync(() => node.onAcceptDrop!(details.data)),
                    );
                  },
                  builder: (context, candidates, rejected) => DecoratedBox(
                    decoration: candidates.isEmpty
                        ? const BoxDecoration()
                        : BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: theme.colors.accent,
                                width: 2,
                              ),
                            ),
                          ),
                    child: dragTargetChild,
                  ),
                );
              }
              if (node.dragData != null) {
                row = Draggable<Object>(
                  data: node.dragData!,
                  feedback: BlenderEditorFrame(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: row,
                    ),
                  ),
                  childWhenDragging: Opacity(opacity: .45, child: row),
                  child: row,
                );
              }
              if (contextMenuItems.isNotEmpty) {
                row = BlenderContextMenu<String>(
                  title: widget.contextMenuTitleBuilder?.call(node),
                  items: contextMenuItems,
                  // Blender activates the view item under the pointer before
                  // asking that item to build its context menu.
                  onContextRequested: (_) {
                    if (node.selectable) widget.onSelected?.call(node);
                  },
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
      if (node.children.isNotEmpty || node.hasChildren) ids.add(node.id);
      for (final child in node.children) {
        collectIds(child);
      }
    }

    for (final root in widget.roots) {
      collectIds(root);
    }
    _expanded.retainWhere(ids.contains);
    if (widget.expandedIds != null) {
      _expanded
        ..clear()
        ..addAll(widget.expandedIds!.where(ids.contains));
    }
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
