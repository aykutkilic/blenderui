part of '../specialized_templates.dart';

/// Blender's compact context-sensitive input-status row. The widget is
/// intentionally data-driven because Blender chooses its items from the
/// active area, region, action zone, and modal keymap.
class BlenderInputStatus extends StatelessWidget {
  const BlenderInputStatus({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    this.backgroundColor,
    this.showBorder = true,
  });

  final List<BlenderInputStatusItem> items;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool showBorder;

  Widget _token(BuildContext context, String label, bool enabled) {
    return Opacity(opacity: enabled ? 1 : .5, child: BlenderKeycap(label));
  }

  Widget _glyphToken(BlenderGlyph glyph, bool enabled, {Color? color}) {
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: BlenderIcon(glyph, size: 16, color: color),
    );
  }

  Widget _item(BuildContext context, BlenderInputStatusItem item) {
    final theme = BlenderTheme.of(context);
    final tokens = <Widget>[
      for (final modifier in item.modifierGlyphs)
        _glyphToken(modifier, item.enabled),
      for (final modifier in item.modifiers)
        _token(context, modifier, item.enabled),
      if (item.eventGlyphs.isNotEmpty)
        for (final event in item.eventGlyphs)
          _glyphToken(
            event,
            item.enabled,
            color: item.warning ? theme.colors.warning : null,
          )
      else if (item.events.isNotEmpty)
        for (final event in item.events) _token(context, event, item.enabled)
      else if (item.event != null)
        _token(context, item.event!, item.enabled),
      if (item.icon != null)
        BlenderIcon(
          item.icon!,
          size: 14,
          color: item.warning ? theme.colors.warning : null,
        ),
      Text(
        item.label,
        style: theme.textTheme.caption.copyWith(
          color: item.warning
              ? theme.colors.warning
              : item.enabled
              ? theme.colors.foregroundMuted
              : theme.colors.foregroundDisabled,
        ),
      ),
      if (item.dragEvent != null) ...<Widget>[
        const SizedBox(width: 3),
        for (final modifier in item.dragModifierGlyphs)
          _glyphToken(modifier, item.enabled),
        for (final modifier in item.dragModifiers)
          _token(context, modifier, item.enabled),
        if (item.dragEventGlyph != null)
          _glyphToken(
            item.dragEventGlyph!,
            item.enabled,
            color: item.warning ? theme.colors.warning : null,
          )
        else
          _token(context, item.dragEvent!, item.enabled),
      ],
    ];
    return Semantics(
      label: item.label,
      enabled: item.enabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var index = 0; index < tokens.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(width: 3),
            tokens[index],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colors.canvas,
        border: showBorder
            ? Border.all(color: theme.colors.editorBorder)
            : null,
      ),
      child: Padding(
        padding: padding,
        child: Wrap(
          spacing: 10,
          runSpacing: 4,
          children: <Widget>[for (final item in items) _item(context, item)],
        ),
      ),
    );
  }
}
