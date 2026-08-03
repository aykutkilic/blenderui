part of '../layout.dart';

class BlenderToolShelf extends StatelessWidget {
  const BlenderToolShelf({
    super.key,
    required this.tools,
    required this.selectedIndex,
    required this.onChanged,
    this.onOptionSelected,
    // blenderapp: UI_TOOLBAR_WIDTH = 16 px margin + 40 px column.
    this.width = 56,
    // A 40 px source column plus the row seam keeps 42 px tool rows.
    this.buttonExtent = 42,
    // blenderapp: ICON_DEFAULT_HEIGHT_TOOLBAR.
    this.iconSize = 32,
    this.floating = false,
    this.buttonSpacing = 0,
    this.contextMenuItemsBuilder,
    this.onContextMenuSelected,
  });

  final List<BlenderToolDefinition> tools;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ValueChanged<BlenderToolOption>? onOptionSelected;
  final double width;
  final double buttonExtent;
  final double iconSize;

  /// Uses Blender's viewport-overlay treatment instead of consuming an opaque
  /// editor region. Group breaks remain encoded by each tool definition.
  final bool floating;
  final double buttonSpacing;
  final List<BlenderMenuItem<String>> Function(
    BlenderToolDefinition tool,
    int index,
  )?
  contextMenuItemsBuilder;
  final void Function(BlenderToolDefinition tool, int index, String action)?
  onContextMenuSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    // blenderapp divides toolbar geometry by the region View2D aspect. That
    // partially compensates high-DPI interface scaling; cap the portable
    // equivalent so toolbar icons do not grow with ordinary header text.
    final densityScale = math.min(theme.density.controlHeight / 20, 1.25);
    Widget buildTool(int index) {
      final tool = tools[index];
      final button = Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          BlenderIconButton(
            glyph: tool.glyph,
            icon: tool.assetName == null
                ? null
                : BlenderGeneratedIcon(
                    tool.assetName!,
                    size:
                        math.max(iconSize, buttonExtent * 0.82) * densityScale,
                  ),
            selected: index == selectedIndex,
            enabled: tool.enabled,
            onPressed: () => onChanged(index),
            tooltip: tool.options.isEmpty ? tool.tooltip : null,
            size: buttonExtent * densityScale,
            height: buttonExtent * densityScale,
            iconSize: math.max(iconSize, buttonExtent * 0.82) * densityScale,
            scaleWithDensity: false,
            showBorder: false,
            borderRadius: 0,
          ),
          if (tool.options.isNotEmpty)
            Positioned(
              right: 2 * densityScale,
              bottom: 2 * densityScale,
              child: IgnorePointer(
                child: BlenderIcon(
                  BlenderGlyph.chevronDown,
                  size: 8 * densityScale,
                ),
              ),
            ),
        ],
      );
      Widget interactive = tool.options.isEmpty
          ? button
          : BlenderTooltip(
              message: tool.tooltip,
              child: BlenderPopover(
                targetAnchor: Alignment.centerRight,
                followerAnchor: Alignment.centerLeft,
                offset: const Offset(4, 0),
                // Blender tool groups activate the primary tool on a normal
                // click and reveal their related tools on press-and-hold.
                // Keep both paths on the shared shelf so editor integrations
                // do not each invent a different flyout gesture.
                openOnTap: false,
                openOnLongPress: tool.enabled,
                child: button,
                popover: (context, close) => _BlenderToolOptionMenu(
                  options: tool.options,
                  selectedIndex: tool.selectedOption,
                  onSelected: (option) {
                    onChanged(index);
                    onOptionSelected?.call(option);
                    close();
                  },
                ),
              ),
            );
      final contextItems = contextMenuItemsBuilder?.call(tool, index);
      if (contextItems != null && contextItems.isNotEmpty) {
        interactive = BlenderContextMenu<String>(
          title: tool.tooltip,
          items: contextItems,
          onSelected: (action) =>
              onContextMenuSelected?.call(tool, index, action),
          child: interactive,
        );
      }
      return SizedBox(height: buttonExtent * densityScale, child: interactive);
    }

    final groups = <List<Widget>>[];
    for (var index = 0; index < tools.length; index++) {
      if (index == 0 || tools[index].groupBreakBefore) {
        groups.add(<Widget>[]);
      }
      groups.last.add(buildTool(index));
    }

    // Floating shelves are normally tall enough to show their complete tool
    // taxonomy, but docked areas can become shorter than that during window or
    // pane resizing. Keep the same compact appearance while allowing the shelf
    // itself to scroll instead of overflowing its editor.
    final shelf = SizedBox(
      width: width * densityScale,
      child: LayoutBuilder(
        builder: (context, constraints) {
          Widget group(List<Widget> children) => DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.surface.withAlpha(244),
              borderRadius: BorderRadius.circular(6 * densityScale),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
            ),
          );
          final grouped = <Widget>[
            for (var index = 0; index < groups.length; index++) ...[
              if (index > 0) SizedBox(height: 6 * densityScale),
              group(groups[index]),
            ],
          ];
          if (!constraints.hasBoundedHeight) {
            return Column(mainAxisSize: MainAxisSize.min, children: grouped);
          }
          return ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: false),
            child: ListView.builder(
              primary: false,
              padding: EdgeInsets.symmetric(
                vertical: floating ? 0 : 4 * densityScale,
              ),
              itemCount: grouped.length,
              itemBuilder: (context, index) => grouped[index],
            ),
          );
        },
      ),
    );
    return shelf;
  }
}

/// Blender's standard Object Mode tool ordering for a 3D viewport.
///
/// Applications own selection and command handling; BlenderUI owns the stable
/// tool taxonomy, grouping, glyphs, and compact/floating presentation.
class BlenderView3dToolShelf extends StatelessWidget {
  const BlenderView3dToolShelf({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.onOptionSelected,
    this.width = 56,
    this.floating = true,
    this.onContextMenuSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ValueChanged<BlenderToolOption>? onOptionSelected;
  final double width;
  final bool floating;
  final void Function(BlenderToolDefinition tool, int index, String action)?
  onContextMenuSelected;

  static const List<BlenderToolDefinition> tools = <BlenderToolDefinition>[
    BlenderToolDefinition(
      glyph: BlenderGlyph.pointer,
      tooltip: 'Select tool',
      assetName: 'select_tweak',
      options: <BlenderToolOption>[
        BlenderToolOption(
          label: 'Tweak',
          glyph: BlenderGlyph.pointer,
          shortcut: 'Space Bar',
          description: 'Select and transform elements directly.',
        ),
        BlenderToolOption(
          label: 'Select Box',
          glyph: BlenderGlyph.selectBox,
          shortcut: 'W',
          description: 'Select elements inside a rectangular region.',
        ),
        BlenderToolOption(
          label: 'Select Circle',
          glyph: BlenderGlyph.radio,
          shortcut: 'C',
          description: 'Select elements inside a circular region.',
        ),
        BlenderToolOption(
          label: 'Select Lasso',
          glyph: BlenderGlyph.pointer,
          shortcut: 'Ctrl Space',
          description: 'Select elements inside a freeform region.',
        ),
      ],
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.radio,
      tooltip: '3D Cursor',
      assetName: 'cursor_3d',
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.transform,
      tooltip: 'Move tool',
      assetName: 'move',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.rotate,
      tooltip: 'Rotate tool',
      assetName: 'rotate',
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.scale,
      tooltip: 'Scale tool',
      assetName: 'scale',
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.tool,
      tooltip: 'Annotate',
      assetName: 'annotate',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.grid,
      tooltip: 'Measure',
      assetName: 'measure',
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.plus,
      tooltip: 'Add Cube',
      assetName: 'add_cube',
      groupBreakBefore: true,
    ),
  ];

  @override
  Widget build(BuildContext context) => BlenderToolShelf(
    tools: tools,
    selectedIndex: selectedIndex,
    onChanged: onChanged,
    onOptionSelected: onOptionSelected,
    width: width,
    buttonExtent: 42,
    iconSize: 32,
    floating: floating,
    contextMenuItemsBuilder: (_, _) => BlenderContextMenuCatalog.tool(),
    onContextMenuSelected: onContextMenuSelected,
  );
}

class BlenderToolOption {
  const BlenderToolOption({
    required this.label,
    required this.glyph,
    this.shortcut,
    this.description,
    this.enabled = true,
    this.value,
  });

  final String label;
  final BlenderGlyph glyph;
  final String? shortcut;
  final String? description;
  final bool enabled;

  /// Optional application-owned identity returned with the selected option.
  final Object? value;
}

class BlenderToolDefinition {
  const BlenderToolDefinition({
    required this.glyph,
    required this.tooltip,
    this.assetName,
    this.enabled = true,
    this.options = const <BlenderToolOption>[],
    this.selectedOption = 0,
    this.groupBreakBefore = false,
  });

  final BlenderGlyph glyph;
  final String tooltip;
  final String? assetName;
  final bool enabled;
  final List<BlenderToolOption> options;
  final int selectedOption;
  final bool groupBreakBefore;
}

class _BlenderToolOptionMenu extends StatelessWidget {
  const _BlenderToolOptionMenu({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<BlenderToolOption> options;
  final int selectedIndex;
  final ValueChanged<BlenderToolOption> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 680),
      child: SizedBox(
        width: 260,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.menuBackground,
            border: Border.all(color: theme.colors.borderSubtle),
            borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) => _BlenderToolOptionRow(
                option: options[index],
                selected: index == selectedIndex,
                onSelected: () => onSelected(options[index]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BlenderToolOptionRow extends StatefulWidget {
  const _BlenderToolOptionRow({
    required this.option,
    required this.selected,
    required this.onSelected,
  });

  final BlenderToolOption option;
  final bool selected;
  final VoidCallback onSelected;

  @override
  State<_BlenderToolOptionRow> createState() => _BlenderToolOptionRowState();
}

class _BlenderToolOptionRowState extends State<_BlenderToolOptionRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final highlighted = widget.selected || _hovered;
    final content = Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: highlighted ? theme.colors.menuSelection : null,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: <Widget>[
          BlenderIcon(widget.option.glyph, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.option.label,
              style: theme.textTheme.body.copyWith(fontSize: 14),
            ),
          ),
          if (widget.option.shortcut != null)
            Text(
              widget.option.shortcut!,
              style: theme.textTheme.caption.copyWith(fontSize: 10),
            ),
        ],
      ),
    );
    final row = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.option.enabled ? widget.onSelected : null,
        child: content,
      ),
    );
    if (widget.option.description == null) return row;
    return BlenderTooltip(
      message: widget.option.label,
      content: SizedBox(
        width: 300,
        child: Text(
          '${widget.option.description}\n'
          '${widget.option.shortcut == null ? '' : 'Shortcut: ${widget.option.shortcut}'}',
          style: theme.textTheme.body,
        ),
      ),
      child: row,
    );
  }
}
