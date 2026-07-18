part of '../specialized_templates.dart';

/// Blender's palette template: management controls followed by a responsive
/// grid of selectable color swatches.
class BlenderColorPalette extends StatelessWidget {
  const BlenderColorPalette({
    super.key,
    required this.colors,
    this.selectedIndex,
    this.onSelected,
    this.onAdd,
    this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
    this.sortItems = const <BlenderMenuItem<String>>[],
    this.onSort,
    this.title,
    this.swatchSize = 26,
  });

  final List<Color> colors;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final List<BlenderMenuItem<String>> sortItems;
  final ValueChanged<String>? onSort;
  final String? title;
  final double swatchSize;

  Widget _swatch(BuildContext context, Color color, int index) {
    final theme = BlenderTheme.of(context);
    final selected = selectedIndex == index;
    final swatch = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? theme.colors.accent : theme.colors.borderSubtle,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: BlenderColorSwatch(color: color, size: swatchSize - 6),
      ),
    );
    return Semantics(
      container: true,
      button: onSelected != null,
      selected: selected,
      label: 'Palette color ${index + 1}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelected == null ? null : () => onSelected!(index),
        child: swatch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      BlenderIconButton(
        glyph: BlenderGlyph.plus,
        onPressed: onAdd,
        tooltip: 'Add palette color',
        size: 23,
      ),
      BlenderIconButton(
        glyph: BlenderGlyph.minus,
        onPressed: onRemove,
        tooltip: 'Remove palette color',
        size: 23,
      ),
      if (colors.isNotEmpty) ...<Widget>[
        BlenderIconButton(
          glyph: BlenderGlyph.chevronUp,
          onPressed: onMoveUp,
          tooltip: 'Move palette color up',
          size: 23,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.chevronDown,
          onPressed: onMoveDown,
          tooltip: 'Move palette color down',
          size: 23,
        ),
        if (sortItems.isNotEmpty)
          BlenderMenuButton<String>(
            label: 'Sort',
            items: sortItems,
            onSelected: onSort,
          ),
      ],
    ];
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(children: controls),
        const SizedBox(height: 5),
        if (colors.isEmpty)
          Text(
            'No palette colors',
            style: BlenderTheme.of(context).textTheme.caption.copyWith(
              color: BlenderTheme.of(context).colors.foregroundMuted,
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 4.0;
              final columns = (constraints.maxWidth / (swatchSize + spacing))
                  .floor()
                  .clamp(1, 32)
                  .toInt();
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: <Widget>[
                  for (var index = 0; index < colors.length; index++)
                    SizedBox(
                      width:
                          (constraints.maxWidth - spacing * (columns - 1)) /
                          columns,
                      height: swatchSize,
                      child: _swatch(context, colors[index], index),
                    ),
                ],
              );
            },
          ),
      ],
    );
    return title == null ? body : BlenderPanel(title: title!, child: body);
  }
}
