part of '../specialized_templates.dart';

/// A socket declaration in a node-tree interface pane.
@immutable
class BlenderNodeInterfaceSocket {
  const BlenderNodeInterfaceSocket({
    required this.id,
    required this.label,
    this.color = const Color(0xFF8BC34A),
    this.input = true,
    this.output = false,
    this.detail,
    this.active = false,
    this.enabled = true,
    this.onActivate,
    this.onRemove,
  });

  final String id;
  final String label;
  final Color color;
  final bool input;
  final bool output;
  final String? detail;
  final bool active;
  final bool enabled;
  final VoidCallback? onActivate;
  final VoidCallback? onRemove;
}

/// A panel declaration in a node-tree interface pane.
@immutable
class BlenderNodeInterfacePanel {
  const BlenderNodeInterfacePanel({
    required this.id,
    required this.name,
    this.children = const <BlenderNodeInterfaceItem>[],
    this.active = false,
    this.initiallyExpanded = true,
    this.enabled = true,
    this.onActivate,
    this.onRemove,
  });

  final String id;
  final String name;
  final List<BlenderNodeInterfaceItem> children;
  final bool active;
  final bool initiallyExpanded;
  final bool enabled;
  final VoidCallback? onActivate;
  final VoidCallback? onRemove;
}

/// A typed socket-or-panel item used by [BlenderNodeTreeInterface].
@immutable
class BlenderNodeInterfaceItem {
  const BlenderNodeInterfaceItem.socket(BlenderNodeInterfaceSocket value)
    : socket = value,
      panel = null;

  const BlenderNodeInterfaceItem.panel(BlenderNodeInterfacePanel value)
    : socket = null,
      panel = value;

  final BlenderNodeInterfaceSocket? socket;
  final BlenderNodeInterfacePanel? panel;

  bool get isPanel => panel != null;
}

/// The nested declaration tree used by Blender's node-tree interface template.
class BlenderNodeTreeInterface extends StatefulWidget {
  const BlenderNodeTreeInterface({
    super.key,
    required this.items,
    this.title = 'Node Tree Interface',
    this.emptyLabel = 'No interface items',
  });

  final List<BlenderNodeInterfaceItem> items;
  final String title;
  final String emptyLabel;

  @override
  State<BlenderNodeTreeInterface> createState() =>
      _BlenderNodeTreeInterfaceState();
}

class _BlenderNodeTreeInterfaceState extends State<BlenderNodeTreeInterface> {
  late final Set<String> _expanded = _initialExpanded(widget.items);

  static Set<String> _initialExpanded(List<BlenderNodeInterfaceItem> items) =>
      BlenderTreeState.initialExpanded<BlenderNodeInterfaceItem>(
        items,
        idOf: (item) => item.panel?.id ?? 'socket:${item.socket!.id}',
        childrenOf: (item) =>
            item.panel?.children ?? const <BlenderNodeInterfaceItem>[],
        initiallyExpanded: (item) => item.panel?.initiallyExpanded ?? false,
      );

  Widget _socketDot(Color color, {required bool output}) {
    return SizedBox(
      width: 18,
      child: Align(
        alignment: output ? Alignment.centerRight : Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: BlenderTheme.of(context).colors.border),
          ),
          child: const SizedBox.square(dimension: 10),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    BlenderTreeEntry<BlenderNodeInterfaceItem> visible,
  ) {
    final theme = BlenderTheme.of(context);
    final panel = visible.value.panel;
    final socket = visible.value.socket;
    final indent = 8.0 + visible.depth * 14;
    if (panel != null) {
      final expandable = panel.children.isNotEmpty;
      return SizedBox(
        height: theme.density.rowHeight,
        child: Row(
          children: <Widget>[
            SizedBox(width: indent),
            if (expandable)
              BlenderDisclosureButton(
                expanded: _expanded.contains(panel.id),
                onPressed: () => setState(() {
                  if (_expanded.contains(panel.id)) {
                    _expanded.remove(panel.id);
                  } else {
                    _expanded.add(panel.id);
                  }
                }),
                size: 18,
              )
            else
              const SizedBox(width: 18),
            const BlenderIcon(BlenderGlyph.node, size: 15),
            const SizedBox(width: 5),
            Expanded(
              child: GestureDetector(
                onTap: panel.enabled ? panel.onActivate : null,
                child: Text(
                  panel.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.label.copyWith(
                    color: panel.enabled
                        ? theme.colors.foreground
                        : theme.colors.foregroundDisabled,
                  ),
                ),
              ),
            ),
            if (panel.onRemove != null)
              BlenderIconButton(
                glyph: BlenderGlyph.close,
                onPressed: panel.onRemove,
                tooltip: 'Remove interface panel',
                size: 21,
              ),
          ],
        ),
      );
    }
    if (socket == null) return const SizedBox.shrink();
    return SizedBox(
      height: theme.density.rowHeight,
      child: Row(
        children: <Widget>[
          SizedBox(width: indent + 18),
          if (socket.input)
            _socketDot(socket.color, output: false)
          else
            const SizedBox(width: 18),
          Expanded(
            child: GestureDetector(
              onTap: socket.enabled ? socket.onActivate : null,
              child: Text(
                socket.label,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.label.copyWith(
                  color: socket.enabled
                      ? (socket.active
                            ? theme.colors.accentHover
                            : theme.colors.foreground)
                      : theme.colors.foregroundDisabled,
                ),
              ),
            ),
          ),
          if (socket.detail != null)
            Text(
              socket.detail!,
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            ),
          if (socket.output)
            _socketDot(socket.color, output: true)
          else
            const SizedBox(width: 18),
          if (socket.onRemove != null)
            BlenderIconButton(
              glyph: BlenderGlyph.close,
              onPressed: socket.onRemove,
              tooltip: 'Remove interface socket',
              size: 21,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = BlenderTreeState.flatten<BlenderNodeInterfaceItem>(
      widget.items,
      idOf: (item) => item.panel?.id ?? 'socket:${item.socket!.id}',
      childrenOf: (item) =>
          item.panel?.children ?? const <BlenderNodeInterfaceItem>[],
      expanded: _expanded,
    );
    return BlenderPanel(
      title: widget.title,
      child: rows.isEmpty
          ? Text(
              widget.emptyLabel,
              style: BlenderTheme.of(context).textTheme.caption,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[for (final row in rows) _row(context, row)],
            ),
    );
  }
}
