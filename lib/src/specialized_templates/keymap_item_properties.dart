part of '../specialized_templates.dart';

/// The two-column boxed operator-property anatomy from Blender's keymap
/// editor.  The widget deliberately accepts editor widgets rather than RNA
/// pointers so it can also represent custom keymap/operator data.
class BlenderKeymapItemProperties extends StatelessWidget {
  const BlenderKeymapItemProperties({
    super.key,
    required this.properties,
    this.title,
    this.columns = 2,
  });

  final List<BlenderKeymapProperty> properties;
  final String? title;
  final int columns;

  Widget _propertyBox(BuildContext context, BlenderKeymapProperty property) {
    final theme = BlenderTheme.of(context);
    final editor = Opacity(
      opacity: property.enabled && property.isSet ? 1 : .55,
      child: property.editor,
    );
    return BlenderBox(
      padding: const EdgeInsets.fromLTRB(6, 5, 4, 5),
      color: property.isSet
          ? theme.colors.panelSubSurface
          : theme.colors.panelSubSurface.withValues(alpha: .65),
      child: Row(
        children: <Widget>[
          Expanded(child: editor),
          if (property.isSet && property.onUnset != null)
            BlenderIconButton(
              glyph: BlenderGlyph.close,
              enabled: property.enabled,
              onPressed: property.enabled ? property.onUnset : null,
              tooltip: 'Unset ${property.label}',
              size: 21,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow = LayoutBuilder(
      builder: (context, constraints) {
        const gap = 4.0;
        final effectiveColumns = columns.clamp(1, 4).toInt();
        final width = constraints.hasBoundedWidth
            ? ((constraints.maxWidth - gap * (effectiveColumns - 1)) /
                      effectiveColumns)
                  .clamp(180, 420)
                  .toDouble()
            : 220.0;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final property in properties)
              SizedBox(width: width, child: _propertyBox(context, property)),
          ],
        );
      },
    );
    final body = properties.isEmpty
        ? Text(
            'No operator properties',
            style: BlenderTheme.of(context).textTheme.caption.copyWith(
              color: BlenderTheme.of(context).colors.foregroundMuted,
            ),
          )
        : flow;
    return title == null ? body : BlenderPanel(title: title, child: body);
  }
}
