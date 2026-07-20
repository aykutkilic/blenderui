part of '../non3d_editors.dart';

/// Shared region geometry for Image and UV editor canvases.
///
/// The toolbar and sidebar consume fixed Blender-like regions. The optional
/// asset shelf is attached below the canvas, matching Image Paint mode rather
/// than becoming an application-level dock.
class BlenderImageEditorLayout extends StatelessWidget {
  const BlenderImageEditorLayout({
    super.key,
    required this.canvas,
    this.toolShelf,
    this.sidebar,
    this.assetShelf,
    this.toolShelfWidth = 42,
    this.sidebarWidth = 240,
    this.assetShelfHeight = 144,
  });

  final Widget canvas;
  final Widget? toolShelf;
  final Widget? sidebar;
  final Widget? assetShelf;
  final double toolShelfWidth;
  final double sidebarWidth;
  final double assetShelfHeight;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    Widget borderedRegion(Widget child, {bool left = false, bool top = false}) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.surface,
          border: Border(
            left: left
                ? BorderSide(color: theme.colors.editorBorder)
                : BorderSide.none,
            top: top
                ? BorderSide(color: theme.colors.editorBorder)
                : BorderSide.none,
          ),
        ),
        child: child,
      );
    }

    final center = assetShelf == null
        ? canvas
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: canvas),
              SizedBox(
                height: assetShelfHeight,
                child: borderedRegion(assetShelf!, top: true),
              ),
            ],
          );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (toolShelf != null)
          SizedBox(width: toolShelfWidth, child: toolShelf),
        Expanded(child: center),
        if (sidebar != null)
          SizedBox(
            width: sidebarWidth,
            child: borderedRegion(sidebar!, left: true),
          ),
      ],
    );
  }
}

/// Blender's standard tool ordering for Image View/Paint/Mask and UV modes.
class BlenderImageEditorToolShelf extends StatelessWidget {
  const BlenderImageEditorToolShelf({
    super.key,
    required this.mode,
    required this.selectedIndex,
    required this.onChanged,
    this.onOptionSelected,
    this.onContextMenuSelected,
    this.width = 42,
  });

  final BlenderImageEditorMode mode;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ValueChanged<BlenderToolOption>? onOptionSelected;
  final void Function(BlenderToolDefinition tool, int index, String action)?
  onContextMenuSelected;
  final double width;

  static const List<BlenderToolDefinition> viewTools = <BlenderToolDefinition>[
    BlenderToolDefinition(glyph: BlenderGlyph.eyedropper, tooltip: 'Sample'),
    BlenderToolDefinition(
      glyph: BlenderGlyph.tool,
      tooltip: 'Annotate',
      groupBreakBefore: true,
    ),
  ];

  static const List<BlenderToolDefinition> uvTools = <BlenderToolDefinition>[
    BlenderToolDefinition(
      glyph: BlenderGlyph.pointer,
      tooltip: 'Select',
      options: <BlenderToolOption>[
        BlenderToolOption(label: 'Tweak', glyph: BlenderGlyph.pointer),
        BlenderToolOption(label: 'Select Box', glyph: BlenderGlyph.selectBox),
        BlenderToolOption(label: 'Select Circle', glyph: BlenderGlyph.radio),
        BlenderToolOption(label: 'Select Lasso', glyph: BlenderGlyph.pointer),
      ],
    ),
    BlenderToolDefinition(glyph: BlenderGlyph.radio, tooltip: 'Cursor'),
    BlenderToolDefinition(
      glyph: BlenderGlyph.transform,
      tooltip: 'Move',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(glyph: BlenderGlyph.rotate, tooltip: 'Rotate'),
    BlenderToolDefinition(glyph: BlenderGlyph.scale, tooltip: 'Scale'),
    BlenderToolDefinition(glyph: BlenderGlyph.gizmo, tooltip: 'Transform'),
    BlenderToolDefinition(
      glyph: BlenderGlyph.tool,
      tooltip: 'Annotate',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.split,
      tooltip: 'Rip Region',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.pointer,
      tooltip: 'Grab',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(glyph: BlenderGlyph.transform, tooltip: 'Relax'),
    BlenderToolDefinition(glyph: BlenderGlyph.scale, tooltip: 'Pinch'),
  ];

  static const List<BlenderToolDefinition> maskTools = <BlenderToolDefinition>[
    BlenderToolDefinition(
      glyph: BlenderGlyph.pointer,
      tooltip: 'Select',
      options: <BlenderToolOption>[
        BlenderToolOption(label: 'Tweak', glyph: BlenderGlyph.pointer),
        BlenderToolOption(label: 'Select Box', glyph: BlenderGlyph.selectBox),
        BlenderToolOption(label: 'Select Circle', glyph: BlenderGlyph.radio),
        BlenderToolOption(label: 'Select Lasso', glyph: BlenderGlyph.pointer),
      ],
    ),
    BlenderToolDefinition(glyph: BlenderGlyph.radio, tooltip: 'Cursor'),
    BlenderToolDefinition(
      glyph: BlenderGlyph.transform,
      tooltip: 'Move',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(glyph: BlenderGlyph.rotate, tooltip: 'Rotate'),
    BlenderToolDefinition(glyph: BlenderGlyph.scale, tooltip: 'Scale'),
    BlenderToolDefinition(glyph: BlenderGlyph.gizmo, tooltip: 'Transform'),
    BlenderToolDefinition(
      glyph: BlenderGlyph.tool,
      tooltip: 'Annotate',
      groupBreakBefore: true,
    ),
  ];

  static const List<BlenderToolDefinition> paintTools = <BlenderToolDefinition>[
    BlenderToolDefinition(glyph: BlenderGlyph.tool, tooltip: 'Brush'),
    BlenderToolDefinition(glyph: BlenderGlyph.filter, tooltip: 'Blur'),
    BlenderToolDefinition(glyph: BlenderGlyph.transform, tooltip: 'Smear'),
    BlenderToolDefinition(glyph: BlenderGlyph.duplicate, tooltip: 'Clone'),
  ];

  List<BlenderToolDefinition> get _tools => switch (mode) {
    BlenderImageEditorMode.view => viewTools,
    BlenderImageEditorMode.paint => paintTools,
    BlenderImageEditorMode.mask => maskTools,
    BlenderImageEditorMode.uv => uvTools,
  };

  @override
  Widget build(BuildContext context) {
    final tools = _tools;
    final effectiveIndex = tools.isEmpty
        ? 0
        : selectedIndex.clamp(0, tools.length - 1);
    return BlenderToolShelf(
      tools: tools,
      selectedIndex: effectiveIndex,
      onChanged: onChanged,
      onOptionSelected: onOptionSelected,
      width: width,
      contextMenuItemsBuilder: (_, _) => BlenderContextMenuCatalog.tool(),
      onContextMenuSelected: onContextMenuSelected,
    );
  }
}
