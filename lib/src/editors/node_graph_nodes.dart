part of '../editors.dart';

class _BlenderStandardNode extends StatelessWidget {
  const _BlenderStandardNode({
    required this.node,
    required this.body,
    required this.onSocketPressed,
    required this.model,
    required this.onSocketDragStart,
    required this.onSocketDragUpdate,
    required this.onSocketDragEnd,
    required this.highlightedSocket,
    required this.onCollapseChanged,
  });

  final BlenderGraphNode node;
  final Widget? body;
  final BlenderNodeSocketCallback? onSocketPressed;
  final BlenderNodeGraphModel model;
  final _BlenderNodeSocketDragStart? onSocketDragStart;
  final _BlenderNodeSocketDragUpdate? onSocketDragUpdate;
  final _BlenderNodeSocketDragEnd? onSocketDragEnd;
  final BlenderNodeSocketReference? highlightedSocket;
  final void Function(BlenderGraphNode, bool)? onCollapseChanged;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final outline = node.active
        ? theme.colors.foreground
        : node.selected
        ? theme.colors.selection
        : theme.colors.editorBorder;
    final headerColor = node.headerColor ?? theme.colors.panelHeader;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: node.muted
            ? theme.colors.surface.withAlpha(190)
            : theme.colors.surface,
        border: Border.all(color: outline, width: node.selected ? 2 : 1),
        borderRadius: BorderRadius.circular(7),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xAA000000),
            blurRadius: node.selected ? 6 : 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              height: _BlenderNodeGeometry.headerHeight,
              color: node.muted ? headerColor.withAlpha(125) : headerColor,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: onCollapseChanged == null
                        ? null
                        : () => onCollapseChanged!(node, !node.collapsed),
                    child: BlenderIcon(
                      node.collapsed
                          ? BlenderGlyph.panelDisclosureRight
                          : BlenderGlyph.panelDisclosureDown,
                      size: 9,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      node.title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.panelTitle,
                    ),
                  ),
                  if (node.warning != null)
                    BlenderTooltip(
                      message: node.warning!,
                      child: BlenderIcon(
                        BlenderGlyph.warning,
                        size: 13,
                        color: theme.colors.warning,
                      ),
                    ),
                ],
              ),
            ),
            if (!node.collapsed)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 4, 0, 3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (node.label != null)
                        SizedBox(
                          height: _BlenderNodeGeometry.labeledNodeInset,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                node.label!,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.caption.copyWith(
                                  color: theme.colors.foregroundMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      _BlenderNodeBody(
                        node: node,
                        model: model,
                        onSocketPressed: onSocketPressed,
                        onSocketDragStart: onSocketDragStart,
                        onSocketDragUpdate: onSocketDragUpdate,
                        onSocketDragEnd: onSocketDragEnd,
                        highlightedSocket: highlightedSocket,
                      ),
                      if (body != null) Expanded(child: body!),
                      if (node.executionTime != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 6, top: 2),
                          child: Text(
                            node.executionTime!,
                            textAlign: TextAlign.right,
                            style: theme.textTheme.caption.copyWith(
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BlenderFrameNode extends StatelessWidget {
  const _BlenderFrameNode({required this.node});

  final BlenderGraphNode node;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final color = node.headerColor ?? theme.colors.panelHeader;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        border: Border.all(
          color: node.selected ? theme.colors.selection : color.withAlpha(180),
          width: node.selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(node.title, style: theme.textTheme.panelTitle),
        ),
      ),
    );
  }
}

class _BlenderRerouteNode extends StatelessWidget {
  const _BlenderRerouteNode({
    required this.node,
    required this.onSocketPressed,
    required this.onSocketDragStart,
    required this.onSocketDragUpdate,
    required this.onSocketDragEnd,
    required this.highlightedSocket,
  });

  final BlenderGraphNode node;
  final BlenderNodeSocketCallback? onSocketPressed;
  final _BlenderNodeSocketDragStart? onSocketDragStart;
  final _BlenderNodeSocketDragUpdate? onSocketDragUpdate;
  final _BlenderNodeSocketDragEnd? onSocketDragEnd;
  final BlenderNodeSocketReference? highlightedSocket;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final socket = node.outputs.isNotEmpty
        ? node.outputs.first
        : node.inputs.isNotEmpty
        ? node.inputs.first
        : const BlenderNodeSocketDefinition(id: 'reroute', label: '');
    Widget marker = _BlenderSocketMarker(
      color: _nodeSocketColor(socket, theme),
      shape: socket.shape,
      connected: true,
      enabled: socket.enabled,
      highlighted: highlightedSocket?.nodeId == node.id,
    );
    if (onSocketPressed != null || onSocketDragStart != null) {
      marker = GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onTap: onSocketPressed == null
            ? null
            : () => onSocketPressed!(node, socket, true),
        onPanStart: onSocketDragStart == null
            ? null
            : (details) => onSocketDragStart!(node, socket, true, details),
        onPanUpdate: onSocketDragUpdate,
        onPanEnd: onSocketDragEnd,
        child: Padding(padding: const EdgeInsets.all(4), child: marker),
      );
    }
    return Center(
      child: SizedBox(
        width: node.visibleSize.width,
        height: node.visibleSize.height,
        child: Center(child: marker),
      ),
    );
  }
}
