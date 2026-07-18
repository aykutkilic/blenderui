part of '../specialized_templates.dart';

/// A caller-owned input/status item matching Blender's inline event-and-label
/// rows used for area actions, headers, modal operators, and viewport warnings.
@immutable
class BlenderInputStatusItem {
  const BlenderInputStatusItem({
    required this.label,
    this.event,
    this.events = const <String>[],
    this.eventGlyphs = const <BlenderGlyph>[],
    this.dragEvent,
    this.modifiers = const <String>[],
    this.dragModifiers = const <String>[],
    this.modifierGlyphs = const <BlenderGlyph>[],
    this.dragModifierGlyphs = const <BlenderGlyph>[],
    this.dragEventGlyph,
    this.icon,
    this.warning = false,
    this.enabled = true,
  });

  final String label;
  final String? event;
  final List<String> events;
  final List<BlenderGlyph> eventGlyphs;
  final String? dragEvent;
  final List<String> modifiers;
  final List<String> dragModifiers;
  final List<BlenderGlyph> modifierGlyphs;
  final List<BlenderGlyph> dragModifierGlyphs;
  final BlenderGlyph? dragEventGlyph;
  final BlenderGlyph? icon;
  final bool warning;
  final bool enabled;
}

/// Runtime contexts selected by Blender's `uiTemplateInputStatus()` source.
enum BlenderStatusContextKind {
  workspace,
  modal,
  splitDock,
  resizeQuadrants,
  resizeRegion,
  editorBorder,
  header,
  viewportWarning,
  cursor,
}

/// The source-derived status-bar composition around [BlenderInputStatus].
///
/// Blender chooses this context from the active area, region, action zone, and
/// modal keymap. The host supplies those runtime decisions; this widget keeps
/// the visible labels, mouse glyphs, modifiers, and warning treatment in one
/// reusable surface.
class BlenderStatusContextBar extends StatelessWidget {
  const BlenderStatusContextBar({
    super.key,
    required this.kind,
    this.items = const <BlenderInputStatusItem>[],
    this.warningText,
    this.regionVisible = true,
    this.backgroundColor,
    this.showBorder = true,
  });

  final BlenderStatusContextKind kind;
  final List<BlenderInputStatusItem> items;
  final String? warningText;
  final bool regionVisible;
  final Color? backgroundColor;
  final bool showBorder;

  List<BlenderInputStatusItem> _defaultItems() {
    switch (kind) {
      case BlenderStatusContextKind.splitDock:
        return const <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: 'Split/Dock',
            icon: BlenderGlyph.mouseLeftDrag,
          ),
          BlenderInputStatusItem(
            label: 'Duplicate into Window',
            modifierGlyphs: <BlenderGlyph>[BlenderGlyph.keyShift],
            icon: BlenderGlyph.mouseLeftDrag,
          ),
          BlenderInputStatusItem(
            label: 'Swap Areas',
            modifierGlyphs: <BlenderGlyph>[BlenderGlyph.keyControl],
            icon: BlenderGlyph.mouseLeftDrag,
          ),
        ];
      case BlenderStatusContextKind.resizeQuadrants:
        return const <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: 'Resize Quadrants',
            icon: BlenderGlyph.mouseLeftDrag,
          ),
        ];
      case BlenderStatusContextKind.resizeRegion:
        return <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: regionVisible ? 'Resize Region' : 'Show Hidden Region',
            icon: BlenderGlyph.mouseLeftDrag,
          ),
        ];
      case BlenderStatusContextKind.editorBorder:
        return const <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: 'Resize',
            icon: BlenderGlyph.mouseLeftDrag,
          ),
          BlenderInputStatusItem(
            label: 'Options',
            icon: BlenderGlyph.mouseRight,
          ),
        ];
      case BlenderStatusContextKind.header:
        return const <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: 'Pan',
            icon: BlenderGlyph.mouseMiddleDrag,
          ),
          BlenderInputStatusItem(
            label: 'Options',
            icon: BlenderGlyph.mouseRight,
          ),
        ];
      case BlenderStatusContextKind.viewportWarning:
        return <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: warningText ?? 'Active object has negative scale',
            icon: BlenderGlyph.warningFilled,
            warning: true,
          ),
        ];
      case BlenderStatusContextKind.workspace:
      case BlenderStatusContextKind.modal:
      case BlenderStatusContextKind.cursor:
        return items;
    }
  }

  Widget _workspace(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colors.canvas,
        border: showBorder
            ? Border.all(color: theme.colors.editorBorder)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: <Widget>[
            for (final item in items)
              Semantics(
                label: item.label,
                enabled: item.enabled,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (item.icon != null)
                      BlenderIcon(
                        item.icon!,
                        size: 14,
                        color: item.warning ? theme.colors.warning : null,
                      ),
                    if (item.icon != null) const SizedBox(width: 4),
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kind == BlenderStatusContextKind.workspace) return _workspace(context);
    return BlenderInputStatus(
      items: _defaultItems(),
      backgroundColor: backgroundColor,
      showBorder: showBorder,
    );
  }
}
