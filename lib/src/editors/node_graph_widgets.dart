part of '../editors.dart';

Color _nodeSocketColor(
  BlenderNodeSocketDefinition socket,
  BlenderThemeData theme,
) {
  if (socket.color != null) return socket.color!;
  return switch (socket.dataType) {
    BlenderNodeSocketDataType.geometry => const Color(0xFF00D6A3),
    BlenderNodeSocketDataType.floatingPoint => const Color(0xFFB4B4B4),
    BlenderNodeSocketDataType.integer => const Color(0xFF7A9BCB),
    BlenderNodeSocketDataType.boolean => const Color(0xFFD9577E),
    BlenderNodeSocketDataType.vector => const Color(0xFF6363C7),
    BlenderNodeSocketDataType.rotation => const Color(0xFF8C6BC8),
    BlenderNodeSocketDataType.color => const Color(0xFFE7D346),
    BlenderNodeSocketDataType.string => const Color(0xFF17A697),
    BlenderNodeSocketDataType.object => const Color(0xFFFF8B34),
    BlenderNodeSocketDataType.collection => const Color(0xFF33A8B8),
    BlenderNodeSocketDataType.texture => const Color(0xFFEA4C88),
    BlenderNodeSocketDataType.material => const Color(0xFFD94F5C),
    BlenderNodeSocketDataType.matrix => const Color(0xFF6A79D7),
    BlenderNodeSocketDataType.custom => theme.colors.panelHeader,
  };
}

typedef _BlenderNodeSocketDragStart =
    void Function(
      BlenderGraphNode node,
      BlenderNodeSocketDefinition socket,
      bool output,
      DragStartDetails details,
    );
typedef _BlenderNodeSocketDragUpdate = void Function(DragUpdateDetails details);
typedef _BlenderNodeSocketDragEnd = void Function(DragEndDetails details);

/// Compact typed port used by [BlenderNodeEditor] and custom node layouts.
class BlenderNodeSocket extends StatelessWidget {
  const BlenderNodeSocket({
    super.key,
    required this.label,
    this.color,
    this.detail,
    this.output = false,
    this.dataType = BlenderNodeSocketDataType.custom,
    this.shape = BlenderNodeSocketShape.circle,
    this.connected = false,
    this.enabled = true,
    this.multiInput = false,
    this.description,
    this.onPressed,
    this.onDragStart,
    this.onDragUpdate,
    this.onDragEnd,
    this.highlighted = false,
  });

  final String label;
  final Color? color;
  final String? detail;
  final bool output;
  final BlenderNodeSocketDataType dataType;
  final BlenderNodeSocketShape shape;
  final bool connected;
  final bool enabled;
  final bool multiInput;
  final String? description;
  final VoidCallback? onPressed;
  final GestureDragStartCallback? onDragStart;
  final GestureDragUpdateCallback? onDragUpdate;
  final GestureDragEndCallback? onDragEnd;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final definition = BlenderNodeSocketDefinition(
      id: '',
      label: label,
      color: color,
      dataType: dataType,
    );
    final resolvedColor = _nodeSocketColor(definition, theme);
    Widget socket = _BlenderSocketMarker(
      color: resolvedColor,
      shape: multiInput ? BlenderNodeSocketShape.diamond : shape,
      connected: connected,
      enabled: enabled,
      highlighted: highlighted,
    );
    socket = SizedBox(width: 16, height: 16, child: Center(child: socket));
    if (onPressed != null || onDragStart != null) {
      socket = GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onTap: enabled ? onPressed : null,
        onPanStart: enabled ? onDragStart : null,
        onPanUpdate: enabled ? onDragUpdate : null,
        onPanEnd: enabled ? onDragEnd : null,
        child: socket,
      );
    }
    final labelWidget = Flexible(
      child: Text(
        label,
        overflow: TextOverflow.ellipsis,
        textAlign: output ? TextAlign.right : TextAlign.left,
        style: theme.textTheme.caption.copyWith(
          color: enabled
              ? theme.colors.foreground
              : theme.colors.foregroundDisabled,
        ),
      ),
    );
    final detailWidget = detail == null
        ? const SizedBox.shrink()
        : Text(
            detail!,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.caption.copyWith(
              color: enabled
                  ? theme.colors.foregroundMuted
                  : theme.colors.foregroundDisabled,
            ),
          );
    Widget row = SizedBox(
      height: _BlenderNodeGeometry.socketRowHeight,
      child: Row(
        mainAxisAlignment: output
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: output
            ? <Widget>[
                detailWidget,
                const SizedBox(width: 3),
                labelWidget,
                const SizedBox(width: 3),
                socket,
              ]
            : <Widget>[
                socket,
                const SizedBox(width: 3),
                labelWidget,
                const SizedBox(width: 3),
                detailWidget,
              ],
      ),
    );
    if (description != null) {
      row = BlenderTooltip(message: description!, child: row);
    }
    return row;
  }
}

class _BlenderSocketMarker extends StatelessWidget {
  const _BlenderSocketMarker({
    required this.color,
    required this.shape,
    required this.connected,
    required this.enabled,
    this.highlighted = false,
  });

  final Color color;
  final BlenderNodeSocketShape shape;
  final bool connected;
  final bool enabled;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final fill = enabled ? color : theme.colors.foregroundDisabled;
    final marker = Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: connected ? fill : theme.colors.canvas,
        shape: shape == BlenderNodeSocketShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        border: Border.all(color: fill, width: highlighted ? 2.4 : 1.4),
        boxShadow: highlighted
            ? <BoxShadow>[BoxShadow(color: fill.withAlpha(150), blurRadius: 5)]
            : null,
      ),
    );
    return shape == BlenderNodeSocketShape.diamond
        ? Transform.rotate(angle: math.pi / 4, child: marker)
        : marker;
  }
}

class _BlenderNodeBody extends StatelessWidget {
  const _BlenderNodeBody({
    required this.node,
    required this.model,
    this.onSocketPressed,
    this.onSocketDragStart,
    this.onSocketDragUpdate,
    this.onSocketDragEnd,
    this.highlightedSocket,
  });

  final BlenderGraphNode node;
  final BlenderNodeGraphModel model;
  final void Function(
    BlenderGraphNode node,
    BlenderNodeSocketDefinition socket,
    bool output,
  )?
  onSocketPressed;
  final _BlenderNodeSocketDragStart? onSocketDragStart;
  final _BlenderNodeSocketDragUpdate? onSocketDragUpdate;
  final _BlenderNodeSocketDragEnd? onSocketDragEnd;
  final BlenderNodeSocketReference? highlightedSocket;

  @override
  Widget build(BuildContext context) {
    if (node.inputs.isEmpty && node.outputs.isEmpty) {
      return const Align(
        alignment: Alignment.topLeft,
        child: BlenderIcon(BlenderGlyph.cube, size: 18),
      );
    }
    final rows = math.max(node.inputs.length, node.outputs.length);
    return Column(
      children: <Widget>[
        for (var index = 0; index < rows; index++)
          SizedBox(
            height: _BlenderNodeGeometry.socketRowHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: index >= node.inputs.length
                      ? const SizedBox.shrink()
                      : _socket(node.inputs[index], output: false),
                ),
                Expanded(
                  child: index >= node.outputs.length
                      ? const SizedBox.shrink()
                      : _socket(node.outputs[index], output: true),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _socket(BlenderNodeSocketDefinition socket, {required bool output}) {
    return BlenderNodeSocket(
      key: ValueKey<String>('node-socket-${node.id}-${socket.id}-$output'),
      label: socket.label,
      color: socket.color,
      detail: socket.detail,
      output: output,
      dataType: socket.dataType,
      shape: socket.shape,
      connected:
          socket.connected ||
          model.isSocketConnected(
            BlenderNodeSocketReference(
              nodeId: node.id,
              socketId: socket.id,
              output: output,
            ),
          ),
      enabled: socket.enabled && !node.muted,
      multiInput: socket.multiInput,
      description: socket.description,
      onPressed: onSocketPressed == null
          ? null
          : () => onSocketPressed!(node, socket, output),
      onDragStart: onSocketDragStart == null
          ? null
          : (details) => onSocketDragStart!(node, socket, output, details),
      onDragUpdate: onSocketDragUpdate,
      onDragEnd: onSocketDragEnd,
      highlighted:
          highlightedSocket?.nodeId == node.id &&
          highlightedSocket?.socketId == socket.id &&
          highlightedSocket?.output == output,
    );
  }
}
