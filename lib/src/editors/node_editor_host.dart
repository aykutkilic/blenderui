part of '../editors.dart';

class BlenderNodeEditor extends StatelessWidget {
  const BlenderNodeEditor({
    super.key,
    required this.model,
    this.onNodeSelected,
    this.onNodeMoved,
    this.contextMenuItemsBuilder,
    this.onContextMenuSelected,
    this.sidebar,
    this.sidebarWidth = 230,
    this.title = 'Node Editor',
  });

  final BlenderNodeGraphModel model;
  final ValueChanged<BlenderGraphNode>? onNodeSelected;
  final void Function(BlenderGraphNode node, Offset position)? onNodeMoved;
  final List<BlenderMenuItem<String>> Function(BlenderGraphNode)?
  contextMenuItemsBuilder;
  final void Function(BlenderGraphNode, String)? onContextMenuSelected;
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
                child: _buildNode(node),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(BlenderGraphNode node) {
    Widget child = GestureDetector(
      onTap: () => onNodeSelected?.call(node),
      onPanUpdate: onNodeMoved == null
          ? null
          : (details) => onNodeMoved!(node, node.position + details.delta),
      child: BlenderPanel(
        title: node.title,
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
        child: _BlenderNodeBody(node: node),
      ),
    );
    final contextItems = contextMenuItemsBuilder?.call(node);
    if (contextItems != null && contextItems.isNotEmpty) {
      child = BlenderContextMenu<String>(
        title: node.title,
        items: contextItems,
        onContextRequested: (_) => onNodeSelected?.call(node),
        onSelected: (action) => onContextMenuSelected?.call(node, action),
        child: child,
      );
    }
    return child;
  }
}
