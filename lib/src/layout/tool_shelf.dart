part of '../layout.dart';

class BlenderToolShelf extends StatelessWidget {
  const BlenderToolShelf({
    super.key,
    required this.tools,
    required this.selectedIndex,
    required this.onChanged,
    this.onOptionSelected,
    this.width = 32,
    this.floating = false,
    this.buttonSpacing = 0,
  });

  final List<BlenderToolDefinition> tools;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ValueChanged<BlenderToolOption>? onOptionSelected;
  final double width;

  /// Uses Blender's viewport-overlay treatment instead of consuming an opaque
  /// editor region. Group breaks remain encoded by each tool definition.
  final bool floating;
  final double buttonSpacing;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    Widget buildTool(int index) {
      final tool = tools[index];
      final button = BlenderIconButton(
        glyph: tool.glyph,
        selected: index == selectedIndex,
        enabled: tool.enabled,
        onPressed: tool.options.isEmpty ? () => onChanged(index) : null,
        tooltip: tool.options.isEmpty ? tool.tooltip : null,
        size: width - 2,
      );
      final interactive = tool.options.isEmpty
          ? button
          : BlenderTooltip(
              message: tool.tooltip,
              child: BlenderPopover(
                targetAnchor: Alignment.centerRight,
                followerAnchor: Alignment.centerLeft,
                offset: const Offset(4, 0),
                child: IgnorePointer(child: button),
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
      return Padding(
        padding: EdgeInsets.only(
          top: tool.groupBreakBefore ? 6 : (index == 0 ? 0 : buttonSpacing),
        ),
        child: SizedBox(height: width, child: interactive),
      );
    }

    final contents = floating
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var index = 0; index < tools.length; index++)
                buildTool(index),
            ],
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: tools.length,
            itemBuilder: (context, index) => buildTool(index),
          );
    final shelf = DecoratedBox(
      decoration: BoxDecoration(
        color: floating
            ? theme.colors.surface.withAlpha(244)
            : theme.colors.surface,
        border: Border.all(color: theme.colors.editorBorder),
        borderRadius: floating ? BorderRadius.circular(5) : BorderRadius.zero,
      ),
      child: SizedBox(
        width: width,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: floating ? 2 : 0),
          child: contents,
        ),
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
    this.width = 42,
    this.floating = true,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ValueChanged<BlenderToolOption>? onOptionSelected;
  final double width;
  final bool floating;

  static const List<BlenderToolDefinition> tools = <BlenderToolDefinition>[
    BlenderToolDefinition(
      glyph: BlenderGlyph.pointer,
      tooltip: 'Select tool',
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
    BlenderToolDefinition(glyph: BlenderGlyph.radio, tooltip: '3D Cursor'),
    BlenderToolDefinition(
      glyph: BlenderGlyph.transform,
      tooltip: 'Move tool',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(glyph: BlenderGlyph.rotate, tooltip: 'Rotate tool'),
    BlenderToolDefinition(glyph: BlenderGlyph.scale, tooltip: 'Scale tool'),
    BlenderToolDefinition(
      glyph: BlenderGlyph.tool,
      tooltip: 'Annotate',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(glyph: BlenderGlyph.grid, tooltip: 'Measure'),
    BlenderToolDefinition(
      glyph: BlenderGlyph.plus,
      tooltip: 'Add Cube',
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
    floating: floating,
  );
}

class BlenderToolOption {
  const BlenderToolOption({
    required this.label,
    required this.glyph,
    this.shortcut,
    this.description,
    this.enabled = true,
  });

  final String label;
  final BlenderGlyph glyph;
  final String? shortcut;
  final String? description;
  final bool enabled;
}

class BlenderToolDefinition {
  const BlenderToolDefinition({
    required this.glyph,
    required this.tooltip,
    this.enabled = true,
    this.options = const <BlenderToolOption>[],
    this.selectedOption = 0,
    this.groupBreakBefore = false,
  });

  final BlenderGlyph glyph;
  final String tooltip;
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
    return SizedBox(
      width: 260,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var index = 0; index < options.length; index++)
                _BlenderToolOptionRow(
                  option: options[index],
                  selected: index == selectedIndex,
                  onSelected: () => onSelected(options[index]),
                ),
            ],
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
