part of '../layout.dart';

/// A compact Blender ID-template control.
///
/// Blender uses this composition for the Scene and View Layer controls in the
/// top header: a browse selector, a rename field, and compact data-block
/// actions. The optional pin is intentionally part of the rename field rather
/// than a separate toolbar button (matching `template_ID()` in Blender).
class BlenderDataBlockGroup<T> extends StatelessWidget {
  const BlenderDataBlockGroup({
    super.key,
    required this.value,
    required this.items,
    this.onChanged,
    this.onNamePressed,
    this.onPin,
    this.onDuplicate,
    this.onClose,
    this.tooltip,
    this.nameWidth = 96,
    this.selectorWidth = 30,
  });

  final T value;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T>? onChanged;
  final VoidCallback? onNamePressed;
  final VoidCallback? onPin;
  final VoidCallback? onDuplicate;
  final VoidCallback? onClose;
  final String? tooltip;
  final double nameWidth;
  final double selectorWidth;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    BlenderMenuItem<T>? selectedItem;
    for (final item in items) {
      if (item.value == value) {
        selectedItem = item;
        break;
      }
    }
    Widget divider() => SizedBox(
      width: 1,
      height: 22,
      child: ColoredBox(color: theme.colors.editorOutline),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 22,
        decoration: BoxDecoration(
          color: theme.colors.textField,
          border: Border.all(color: theme.colors.editorOutline),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BlenderPopover(
              offset: const Offset(0, 2),
              child: SizedBox(
                width: selectorWidth - 2,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (selectedItem?.icon != null) selectedItem!.icon!,
                      const SizedBox(width: 2),
                      BlenderIcon(
                        key: ValueKey<String>(
                          'data-block-selector-disclosure-$value',
                        ),
                        BlenderGlyph.panelDisclosureDown,
                        size: 9,
                        color: theme.colors.foregroundMuted,
                      ),
                    ],
                  ),
                ),
              ),
              popover: (context, close) => BlenderMenu<T>(
                items: <BlenderMenuItem<T>>[
                  for (final item in items)
                    item.copyWith(selected: item.value == value),
                ],
                onSelected: (item) {
                  onChanged?.call(item.value);
                  close();
                },
              ),
            ),
            divider(),
            SizedBox(
              width: nameWidth,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onNamePressed,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 6, right: 2),
                        child: Text(
                          '$value',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.body.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (onPin != null)
                    _BlenderDataBlockFlatAction(
                      glyph: BlenderGlyph.pin,
                      onTap: onPin,
                      tooltip: 'Pin ${tooltip ?? value}',
                    ),
                ],
              ),
            ),
            if (onDuplicate != null) ...<Widget>[
              divider(),
              _BlenderDataBlockFlatAction(
                glyph: BlenderGlyph.duplicate,
                onTap: onDuplicate,
                tooltip: 'Duplicate ${tooltip ?? value}',
              ),
            ],
            if (onClose != null) ...<Widget>[
              divider(),
              _BlenderDataBlockFlatAction(
                glyph: BlenderGlyph.close,
                onTap: onClose,
                tooltip: 'Close ${tooltip ?? value}',
                muted: true,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BlenderDataBlockFlatAction extends StatelessWidget {
  const _BlenderDataBlockFlatAction({
    required this.glyph,
    required this.onTap,
    required this.tooltip,
    this.muted = false,
  });

  final BlenderGlyph glyph;
  final VoidCallback? onTap;
  final String tooltip;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderTooltip(
      message: tooltip,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: 22,
          height: 22,
          child: Center(
            child: BlenderIcon(
              glyph,
              size: 13,
              color: muted
                  ? theme.colors.foregroundDisabled
                  : theme.colors.foregroundMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class BlenderBreadcrumbs extends StatelessWidget {
  const BlenderBreadcrumbs({super.key, required this.items, this.onSelected});

  final List<String> items;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var index = 0; index < items.length; index++) ...<Widget>[
          if (index > 0)
            BlenderIcon(
              BlenderGlyph.chevronRight,
              size: 12,
              color: theme.colors.foregroundMuted,
            ),
          GestureDetector(
            onTap: onSelected == null ? null : () => onSelected!(index),
            child: Text(
              items[index],
              style: theme.textTheme.caption.copyWith(
                color: index == items.length - 1
                    ? theme.colors.foreground
                    : theme.colors.foregroundMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
