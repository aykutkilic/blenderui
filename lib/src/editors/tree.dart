part of '../editors.dart';

/// The explicit target position for a hierarchical tree drag.
enum BlenderTreeDropPlacement { before, inside, after }

class BlenderTreeNode<T> {
  const BlenderTreeNode({
    required this.id,
    required this.label,
    this.value,
    this.children = const [],
    this.hasChildren = false,
    this.icon,
    this.iconColor,
    this.thumbnail,
    this.tagColor,
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
    this.canAcceptDropAt,
    this.onAcceptDropAt,
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

  /// Optional compact visual representation displayed before the type icon.
  /// Kept at the shared-tree boundary so document, asset, and node editors
  /// can all use thumbnails without rebuilding row geometry.
  final Widget? thumbnail;

  /// A non-semantic row-edge color, useful for layer tags and review states.
  final Color? tagColor;
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

  /// Placement-aware counterparts for trees whose reordering must distinguish
  /// sibling insertion from nesting. Existing consumers can keep using the
  /// simpler whole-row callbacks above.
  final bool Function(Object data, BlenderTreeDropPlacement placement)?
  canAcceptDropAt;
  final FutureOr<void> Function(
    Object data,
    BlenderTreeDropPlacement placement,
  )?
  onAcceptDropAt;
  final ValueChanged<Object>? onDragEntered;
  final VoidCallback? onDragExited;
  final ValueChanged<Offset>? onContextMenuRequested;
}

class BlenderTree<T> extends StatefulWidget {
  const BlenderTree({
    super.key,
    required this.roots,
    this.selectedId,
    this.selectedIds,
    this.onSelected,
    this.onSelectionChanged,
    this.onActivated,
    this.onHovered,
    this.contextMenuTitleBuilder,
    this.rowHeight,
    this.indent = 16,
    this.showVisibility = false,
    this.showLock = false,
    this.onVisibilityChanged,
    this.onLockChanged,
    this.contextMenuItemsBuilder,
    this.onContextMenuSelected,
    this.contextMenuFooterBuilder,
    this.expandedIds,
    this.onExpandedChanged,
    this.revealedIds = const <String>{},
    this.highlightedIds = const <String>{},
  });

  final List<BlenderTreeNode<T>> roots;
  final String? selectedId;
  final Set<String>? selectedIds;
  final ValueChanged<BlenderTreeNode<T>>? onSelected;

  /// Reports Blender-style range and toggle selection as a complete set.
  /// [onSelected] still reports the active row for backwards compatibility.
  final ValueChanged<Set<String>>? onSelectionChanged;

  /// Called when a selectable row is double-clicked.
  final ValueChanged<BlenderTreeNode<T>>? onActivated;

  /// Reports the row under the pointer, or null when the pointer leaves it.
  ///
  /// Hosts use this for transient cross-editor highlighting such as Blender's
  /// object eyedropper without conflating hover with durable selection.
  final ValueChanged<BlenderTreeNode<T>?>? onHovered;
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
  final Widget? Function(BlenderTreeNode<T>, VoidCallback close)?
  contextMenuFooterBuilder;

  /// Optional externally-owned expansion state. Supplying this lets an
  /// application restore a data tree lazily without treating its visual
  /// expansion as transient widget state.
  final Set<String>? expandedIds;

  /// Called after the user expands or collapses a node. The full set is
  /// provided so callers can persist it directly.
  final ValueChanged<Set<String>>? onExpandedChanged;

  /// Rows that should be brought into view after the tree has rebuilt.
  ///
  /// The owner remains responsible for expanding any ancestors through
  /// [expandedIds]; this hook only scrolls an already-visible target into the
  /// viewport. It makes cross-editor selection synchronization possible
  /// without exposing this widget's private scroll controller.
  final Set<String> revealedIds;

  /// Rows emphasized by an external transient interaction.
  ///
  /// This is separate from [selectedIds]: highlighting an eyedropper candidate
  /// must not mutate the application's ordinary selection.
  final Set<String> highlightedIds;

  @override
  State<BlenderTree<T>> createState() => _BlenderTreeState<T>();
}

class _BlenderTreeState<T> extends State<BlenderTree<T>> {
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;
  late final Set<String> _expanded;
  String? _hoveredNodeId;
  String? _selectionAnchorId;
  String? _keyboardNodeId;
  String? _lastTappedNodeId;
  Duration? _lastTapTime;
  final Map<String, BlenderTreeDropPlacement> _dropPlacementByNodeId = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _focusNode = FocusNode(debugLabel: 'BlenderTree');
    _expanded = widget.expandedIds == null
        ? BlenderTreeState.initialExpanded<BlenderTreeNode<T>>(
            widget.roots,
            idOf: (node) => node.id,
            childrenOf: (node) => node.children,
            initiallyExpanded: (node) => node.initiallyExpanded,
          )
        : <String>{...widget.expandedIds!};
  }

  void _scrollToRevealedRow({bool retryWhenHidden = true}) {
    if (!_scrollController.hasClients || widget.revealedIds.isEmpty) return;
    final visible = BlenderTreeState.flatten<BlenderTreeNode<T>>(
      widget.roots,
      idOf: (node) => node.id,
      childrenOf: (node) => node.children,
      expanded: _expanded,
    );
    final index = visible.indexWhere(
      (entry) => widget.revealedIds.contains(entry.value.id),
    );
    if (index < 0) {
      if (retryWhenHidden) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToRevealedRow(retryWhenHidden: false);
        });
      }
      return;
    }
    final rowHeight =
        widget.rowHeight ?? BlenderTheme.of(context).density.rowHeight;
    final rowStart = index * rowHeight;
    final rowEnd = rowStart + rowHeight;
    final viewportStart = _scrollController.position.pixels;
    final viewportEnd =
        viewportStart + _scrollController.position.viewportDimension;
    if (rowStart >= viewportStart && rowEnd <= viewportEnd) return;
    _scrollController.animateTo(
      rowStart.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
    );
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
    int index,
    List<BlenderTreeEntry<BlenderTreeNode<T>>> visible,
    PointerDownEvent event,
  ) {
    if (event.kind != PointerDeviceKind.touch &&
        event.buttons != kPrimaryMouseButton) {
      return;
    }
    _focusNode.requestFocus();
    final pressed = HardwareKeyboard.instance.logicalKeysPressed;
    _selectNode(
      node,
      index,
      visible,
      extend:
          pressed.contains(LogicalKeyboardKey.shiftLeft) ||
          pressed.contains(LogicalKeyboardKey.shiftRight),
      toggle:
          pressed.contains(LogicalKeyboardKey.controlLeft) ||
          pressed.contains(LogicalKeyboardKey.controlRight) ||
          pressed.contains(LogicalKeyboardKey.metaLeft) ||
          pressed.contains(LogicalKeyboardKey.metaRight),
    );
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

  Set<String> get _selectedIds =>
      widget.selectedIds ??
      (widget.selectedId == null
          ? const <String>{}
          : <String>{widget.selectedId!});

  void _selectNode(
    BlenderTreeNode<T> node,
    int index,
    List<BlenderTreeEntry<BlenderTreeNode<T>>> visible, {
    bool extend = false,
    bool toggle = false,
  }) {
    if (!node.selectable) return;
    final next = <String>{..._selectedIds};
    if (extend && _selectionAnchorId != null) {
      final anchorIndex = visible.indexWhere(
        (entry) => entry.value.id == _selectionAnchorId,
      );
      if (anchorIndex >= 0) {
        if (!toggle) next.clear();
        final start = math.min(anchorIndex, index);
        final end = math.max(anchorIndex, index);
        for (var candidate = start; candidate <= end; candidate++) {
          if (visible[candidate].value.selectable) {
            next.add(visible[candidate].value.id);
          }
        }
      }
    } else if (toggle) {
      if (!next.remove(node.id)) next.add(node.id);
      _selectionAnchorId = node.id;
    } else {
      next
        ..clear()
        ..add(node.id);
      _selectionAnchorId = node.id;
    }
    _keyboardNodeId = node.id;
    widget.onSelected?.call(node);
    widget.onSelectionChanged?.call(Set<String>.unmodifiable(next));
  }

  KeyEventResult _handleKeyEvent(
    KeyEvent event,
    List<BlenderTreeEntry<BlenderTreeNode<T>>> visible,
    double rowHeight,
  ) {
    if (event is! KeyDownEvent || visible.isEmpty) {
      return KeyEventResult.ignored;
    }
    final currentId =
        _keyboardNodeId ??
        widget.selectedId ??
        (widget.selectedIds?.isNotEmpty ?? false
            ? widget.selectedIds!.last
            : null);
    var index = visible.indexWhere((entry) => entry.value.id == currentId);
    if (index < 0) index = 0;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      final direction = key == LogicalKeyboardKey.arrowDown ? 1 : -1;
      var candidate = index;
      do {
        candidate = (candidate + direction).clamp(0, visible.length - 1);
        if (visible[candidate].value.selectable || candidate == index) break;
      } while (candidate > 0 && candidate < visible.length - 1);
      final pressed = HardwareKeyboard.instance.logicalKeysPressed;
      _selectNode(
        visible[candidate].value,
        candidate,
        visible,
        extend:
            pressed.contains(LogicalKeyboardKey.shiftLeft) ||
            pressed.contains(LogicalKeyboardKey.shiftRight),
      );
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          (candidate * rowHeight).clamp(
            0,
            _scrollController.position.maxScrollExtent,
          ),
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
        );
      }
      return KeyEventResult.handled;
    }
    final node = visible[index].value;
    if (key == LogicalKeyboardKey.arrowRight) {
      if ((node.children.isNotEmpty || node.hasChildren) &&
          !_expanded.contains(node.id)) {
        _toggleExpanded(node.id);
      }
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      if (_expanded.contains(node.id)) _toggleExpanded(node.id);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      widget.onActivated?.call(node);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
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
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) => _handleKeyEvent(event, visible, rowHeight),
      child: BlenderScrollbar(
        controller: _scrollController,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            IgnorePointer(
              child: CustomPaint(
                painter: _BlenderTreeAlternatingRowsPainter(
                  rowHeight: rowHeight,
                ),
              ),
            ),
            Padding(
              // Blender reserves the right-side restriction column and clips
              // tree content before it. RawScrollbar paints over Flutter's
              // viewport, so keep the same clear strip for trailing tree
              // summaries and row actions instead of letting them sit under
              // the scrollbar thumb.
              padding: EdgeInsets.only(right: 8 * theme.density.interfaceScale),
              child: ListView.builder(
                controller: _scrollController,
                itemCount: visible.length,
                itemExtent: rowHeight,
                itemBuilder: (context, index) {
                  final entry = visible[index];
                  final node = entry.value;
                  final hasChildren =
                      node.children.isNotEmpty || node.hasChildren;
                  final selected = _selectedIds.contains(node.id);
                  final hovered = _hoveredNodeId == node.id;
                  final highlighted = widget.highlightedIds.contains(node.id);
                  final alternate = index.isOdd;
                  final contextMenuItems =
                      widget.contextMenuItemsBuilder?.call(node) ??
                      const <BlenderMenuItem<String>>[];
                  Widget row = GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onSecondaryTapDown: node.onContextMenuRequested == null
                        ? null
                        : (details) => node.onContextMenuRequested!(
                            details.globalPosition,
                          ),
                    onLongPressStart: node.onContextMenuRequested == null
                        ? null
                        : (details) => node.onContextMenuRequested!(
                            details.globalPosition,
                          ),
                    child: DecoratedBox(
                      key: ValueKey<String>('tree-row-${node.id}'),
                      decoration: BoxDecoration(
                        color: selected
                            ? theme.colors.selection
                            : highlighted
                            ? theme.colors.accent.withValues(alpha: 0.32)
                            : hovered
                            ? theme.colors.buttonHover
                            : alternate
                            ? const Color(0x04FFFFFF)
                            : null,
                        border: highlighted
                            ? Border.all(color: theme.colors.accent)
                            : node.dropTarget
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
                                    color: theme.colors.foregroundMuted
                                        .withAlpha(62),
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: entry.depth * widget.indent,
                              ),
                              child: LayoutBuilder(
                                builder: (context, rowConstraints) {
                                  final showNodeIcon =
                                      rowConstraints.maxWidth >= 44;
                                  final showTrailing =
                                      rowConstraints.maxWidth >= 112;
                                  final showDisclosure =
                                      rowConstraints.maxWidth >= widget.indent;
                                  return Row(
                                    children: <Widget>[
                                      if (showDisclosure)
                                        SizedBox(
                                          width: widget.indent,
                                          child: hasChildren
                                              ? GestureDetector(
                                                  behavior:
                                                      HitTestBehavior.opaque,
                                                  onTap: () =>
                                                      _toggleExpanded(node.id),
                                                  child: Center(
                                                    child: BlenderTooltip(
                                                      message:
                                                          _expanded.contains(
                                                            node.id,
                                                          )
                                                          ? 'Collapse'
                                                          : 'Expand',
                                                      child: BlenderIcon(
                                                        key: ValueKey<String>(
                                                          'tree-disclosure-${node.id}',
                                                        ),
                                                        _expanded.contains(
                                                              node.id,
                                                            )
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
                                      if (showNodeIcon &&
                                          node.thumbnail != null) ...<Widget>[
                                        SizedBox(
                                          width: 22,
                                          height: 18,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                            child: node.thumbnail!,
                                          ),
                                        ),
                                        SizedBox(width: theme.density.spacing),
                                      ],
                                      if (showNodeIcon &&
                                          node.icon != null) ...<Widget>[
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
                                                style: theme.textTheme.label
                                                    .copyWith(
                                                      color: node.selectable
                                                          ? theme
                                                                .colors
                                                                .foreground
                                                          : theme
                                                                .colors
                                                                .foregroundMuted,
                                                    ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (node.dropHint != null)
                                              Flexible(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 4,
                                                      ),
                                                  child: Text(
                                                    node.dropHint!,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: theme
                                                        .textTheme
                                                        .caption
                                                        .copyWith(
                                                          color: theme
                                                              .colors
                                                              .accent,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (showTrailing &&
                                          hasChildren &&
                                          !_expanded.contains(node.id))
                                        _BlenderCollapsedTreeSummary(
                                          key: ValueKey<String>(
                                            'tree-collapsed-summary-${node.id}',
                                          ),
                                          children: node.children,
                                        ),
                                      if (showTrailing && widget.showVisibility)
                                        BlenderIconButton(
                                          glyph: BlenderGlyph.eye,
                                          selected: node.visible,
                                          onPressed:
                                              widget.onVisibilityChanged == null
                                              ? null
                                              : () =>
                                                    widget.onVisibilityChanged!(
                                                      node,
                                                    ),
                                          tooltip: node.visible
                                              ? 'Hide'
                                              : 'Show',
                                          size: 20,
                                        ),
                                      if (showTrailing && widget.showLock)
                                        BlenderIconButton(
                                          glyph: BlenderGlyph.lock,
                                          selected: node.locked,
                                          onPressed:
                                              widget.onLockChanged == null
                                              ? null
                                              : () =>
                                                    widget.onLockChanged!(node),
                                          tooltip: node.locked
                                              ? 'Unlock'
                                              : 'Lock',
                                          size: 20,
                                        ),
                                      if (showTrailing &&
                                          node.actionIcon != null &&
                                          (_hoveredNodeId == node.id ||
                                              node.dropTarget))
                                        BlenderIconButton(
                                          glyph: node.actionIcon!,
                                          onPressed: node.onAction,
                                          tooltip: node.actionTooltip,
                                          size: 20,
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          if (node.tagColor != null)
                            Positioned(
                              top: 0,
                              bottom: 0,
                              right: 0,
                              width: 3,
                              child: IgnorePointer(
                                child: ColoredBox(color: node.tagColor!),
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
                      onPointerDown: (event) => _handleSelectablePointerDown(
                        node,
                        index,
                        visible,
                        event,
                      ),
                      child: row,
                    );
                  }
                  row = MouseRegion(
                    onEnter: (_) {
                      setState(() => _hoveredNodeId = node.id);
                      widget.onHovered?.call(node);
                    },
                    onExit: (_) {
                      if (_hoveredNodeId == node.id) {
                        setState(() => _hoveredNodeId = null);
                        widget.onHovered?.call(null);
                      }
                    },
                    child: row,
                  );
                  if ((node.canAcceptDrop != null &&
                          node.onAcceptDrop != null) ||
                      (node.canAcceptDropAt != null &&
                          node.onAcceptDropAt != null)) {
                    final dragTargetChild = row;
                    RenderBox? dragTargetBox;
                    row = DragTarget<Object>(
                      onWillAcceptWithDetails: (details) {
                        final accepted =
                            node.canAcceptDropAt?.call(
                              details.data,
                              BlenderTreeDropPlacement.inside,
                            ) ??
                            node.canAcceptDrop!(details.data);
                        if (accepted) node.onDragEntered?.call(details.data);
                        return accepted;
                      },
                      onMove: (details) {
                        if (node.onAcceptDropAt == null) return;
                        final box = dragTargetBox;
                        if (box == null || !box.hasSize) return;
                        final y = box.globalToLocal(details.offset).dy;
                        final placement = y < box.size.height * .25
                            ? BlenderTreeDropPlacement.before
                            : y > box.size.height * .75
                            ? BlenderTreeDropPlacement.after
                            : BlenderTreeDropPlacement.inside;
                        if (_dropPlacementByNodeId[node.id] != placement) {
                          setState(
                            () => _dropPlacementByNodeId[node.id] = placement,
                          );
                        }
                      },
                      onLeave: (_) {
                        _dropPlacementByNodeId.remove(node.id);
                        node.onDragExited?.call();
                      },
                      onAcceptWithDetails: (details) {
                        final placement =
                            _dropPlacementByNodeId.remove(node.id) ??
                            BlenderTreeDropPlacement.inside;
                        node.onDragExited?.call();
                        unawaited(
                          Future<void>.sync(() {
                            if (node.onAcceptDropAt != null) {
                              return node.onAcceptDropAt!(
                                details.data,
                                placement,
                              );
                            }
                            return node.onAcceptDrop!(details.data);
                          }),
                        );
                      },
                      builder: (context, candidates, rejected) {
                        final renderObject = context.findRenderObject();
                        if (renderObject is RenderBox) {
                          dragTargetBox = renderObject;
                        }
                        return DecoratedBox(
                          decoration: candidates.isEmpty
                              ? const BoxDecoration()
                              : _dropDecoration(
                                  _dropPlacementByNodeId[node.id] ??
                                      BlenderTreeDropPlacement.inside,
                                  theme.colors.accent,
                                ),
                          child: dragTargetChild,
                        );
                      },
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
                      footerBuilder: widget.contextMenuFooterBuilder == null
                          ? null
                          : (context, close) =>
                                widget.contextMenuFooterBuilder!(node, close),
                      child: row,
                    );
                  }
                  return row;
                },
              ),
            ),
          ],
        ),
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
    if (!setEquals(widget.revealedIds, oldWidget.revealedIds)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToRevealedRow();
      });
    }
  }
}

BoxDecoration _dropDecoration(
  BlenderTreeDropPlacement placement,
  Color accent,
) {
  const width = 2.0;
  final side = BorderSide(color: accent, width: width);
  return BoxDecoration(
    border: switch (placement) {
      BlenderTreeDropPlacement.before => Border(top: side),
      BlenderTreeDropPlacement.after => Border(bottom: side),
      BlenderTreeDropPlacement.inside => Border.all(
        color: accent,
        width: width,
      ),
    },
  );
}

class _BlenderCollapsedTreeSummary extends StatelessWidget {
  const _BlenderCollapsedTreeSummary({super.key, required this.children});

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
