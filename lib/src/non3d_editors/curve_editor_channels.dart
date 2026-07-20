part of '../non3d_editors.dart';

/// Blender-style hierarchy and restriction controls for Graph Editor curves.
class BlenderGraphChannelsRegion extends StatefulWidget {
  const BlenderGraphChannelsRegion({
    super.key,
    required this.channels,
    this.roots = const <BlenderGraphChannelNode>[],
    this.activeChannelId,
    this.onChannelSelected,
    this.onAction,
  });

  final List<BlenderCurveChannel> channels;
  final List<BlenderGraphChannelNode> roots;
  final String? activeChannelId;
  final ValueChanged<String>? onChannelSelected;
  final ValueChanged<BlenderGraphChannelAction>? onAction;

  @override
  State<BlenderGraphChannelsRegion> createState() =>
      _BlenderGraphChannelsRegionState();
}

class _BlenderGraphChannelsRegionState
    extends State<BlenderGraphChannelsRegion> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<({BlenderGraphChannelNode node, int depth})> _flatten() {
    final roots = widget.roots.isEmpty
        ? <BlenderGraphChannelNode>[
            for (final curve in widget.channels)
              BlenderGraphChannelNode(
                id: curve.id,
                label: curve.label,
                kind: BlenderGraphChannelKind.curve,
                curveId: curve.id,
                color: curve.color,
                selected: curve.selected,
                visible: curve.visible,
                muted: curve.muted,
                locked: curve.locked,
              ),
          ]
        : widget.roots;
    final result = <({BlenderGraphChannelNode node, int depth})>[];
    void visit(BlenderGraphChannelNode node, int depth) {
      final matches =
          _query.isEmpty ||
          node.label.toLowerCase().contains(_query.toLowerCase());
      if (matches || node.children.isNotEmpty) {
        result.add((node: node, depth: depth));
      }
      if (node.expanded) {
        for (final child in node.children) {
          visit(child, depth + 1);
        }
      }
    }

    for (final root in roots) {
      visit(root, 0);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final rows = _flatten();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.canvas,
        border: Border(right: BorderSide(color: theme.colors.border)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            key: const ValueKey<String>('graph-channel-search'),
            height: 28,
            padding: const EdgeInsets.fromLTRB(4, 3, 4, 3),
            color: theme.colors.surface,
            child: BlenderSearchField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemExtent: 24,
              itemCount: rows.length,
              itemBuilder: (context, index) {
                final entry = rows[index];
                return _BlenderGraphChannelRow(
                  node: entry.node,
                  depth: entry.depth,
                  active:
                      widget.activeChannelId ==
                      (entry.node.curveId ?? entry.node.id),
                  onSelected: widget.onChannelSelected,
                  onAction: widget.onAction,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BlenderGraphChannelRow extends StatelessWidget {
  const _BlenderGraphChannelRow({
    required this.node,
    required this.depth,
    required this.active,
    required this.onSelected,
    required this.onAction,
  });

  final BlenderGraphChannelNode node;
  final int depth;
  final bool active;
  final ValueChanged<String>? onSelected;
  final ValueChanged<BlenderGraphChannelAction>? onAction;

  Color _background(BlenderThemeData theme) {
    if (active || node.selected) return theme.colors.selection;
    return switch (node.kind) {
      BlenderGraphChannelKind.object => theme.colors.surfaceRaised,
      BlenderGraphChannelKind.action => Color.alphaBlend(
        theme.colors.accent.withValues(alpha: .20),
        theme.colors.canvas,
      ),
      BlenderGraphChannelKind.group => Color.alphaBlend(
        (node.color ?? theme.colors.success).withValues(alpha: .20),
        theme.colors.canvas,
      ),
      BlenderGraphChannelKind.curve => theme.colors.canvas,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final curveColor = node.color ?? theme.colors.accent;
    return GestureDetector(
      key: ValueKey<String>('graph-channel-${node.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelected?.call(node.curveId ?? node.id),
      child: Container(
        padding: EdgeInsets.only(left: 5 + depth * 14, right: 3),
        decoration: BoxDecoration(
          color: _background(theme),
          border: Border(bottom: BorderSide(color: theme.colors.borderSubtle)),
        ),
        child: Row(
          children: <Widget>[
            if (node.children.isNotEmpty)
              _channelAction(
                node.expanded
                    ? BlenderGlyph.panelDisclosureDown
                    : BlenderGlyph.panelDisclosureRight,
                BlenderGraphChannelActionType.toggleExpanded,
              )
            else
              const SizedBox(width: 14),
            if (node.kind == BlenderGraphChannelKind.curve)
              Container(width: 14, height: 14, color: curveColor)
            else
              BlenderIcon(_kindGlyph(node.kind), size: 14),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                node.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.body.copyWith(
                  color: node.muted
                      ? theme.colors.foregroundMuted
                      : theme.colors.foreground,
                ),
              ),
            ),
            _channelAction(
              node.visible ? BlenderGlyph.eye : BlenderGlyph.xray,
              BlenderGraphChannelActionType.toggleVisible,
            ),
            _channelAction(
              node.muted ? BlenderGlyph.close : BlenderGlyph.check,
              BlenderGraphChannelActionType.toggleMuted,
            ),
            _channelAction(
              node.locked ? BlenderGlyph.lock : BlenderGlyph.unlock,
              BlenderGraphChannelActionType.toggleLocked,
            ),
          ],
        ),
      ),
    );
  }

  Widget _channelAction(
    BlenderGlyph glyph,
    BlenderGraphChannelActionType type,
  ) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onAction == null
        ? null
        : () => onAction!(BlenderGraphChannelAction(node.id, type)),
    child: SizedBox(
      width: 18,
      height: 22,
      child: Center(child: BlenderIcon(glyph, size: 12)),
    ),
  );

  BlenderGlyph _kindGlyph(BlenderGraphChannelKind kind) => switch (kind) {
    BlenderGraphChannelKind.object => BlenderGlyph.object,
    BlenderGraphChannelKind.action => BlenderGlyph.action,
    BlenderGraphChannelKind.group => BlenderGlyph.collection,
    BlenderGraphChannelKind.curve => BlenderGlyph.curve,
  };
}
