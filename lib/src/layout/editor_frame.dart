part of '../layout.dart';

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
    return BlenderPanel(
      title: title,
      headerActions: actions,
      // An untitled region is an editor canvas, not panel content. Blender
      // draws it flush to the area boundary; panel padding introduced a false
      // gutter between the header and View3D in every host application.
      padding: title == null ? EdgeInsets.zero : null,
      child: child,
    );
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
