part of '../advanced_controls.dart';

/// A compact mutually-exclusive group used for Blender mode and view choices.
class BlenderSegmentedControl<T> extends StatelessWidget {
  const BlenderSegmentedControl({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.expanded = false,
  });

  final T value;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Properties rows often give this control only the remaining narrow
        // editor slot. In that case each segment must share the available
        // width; intrinsic button widths are allowed only when the parent is
        // horizontally unconstrained.
        final useExpanded = constraints.hasBoundedWidth;
        final children = <Widget>[
          for (var index = 0; index < items.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(width: 1),
            if (useExpanded || expanded)
              Expanded(child: _buildItem(items[index]))
            else
              _buildItem(items[index]),
          ],
        ];
        return Row(
          mainAxisSize: useExpanded ? MainAxisSize.max : MainAxisSize.min,
          children: children,
        );
      },
    );
  }

  Widget _buildItem(BlenderMenuItem<T> item) {
    return BlenderButton(
      label: item.label,
      leading: item.icon,
      selected: item.value == value,
      enabled: item.enabled,
      onPressed: item.enabled ? () => onChanged(item.value) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      showBorder: false,
    );
  }
}

class BlenderDisclosureButton extends StatelessWidget {
  const BlenderDisclosureButton({
    super.key,
    required this.expanded,
    required this.onPressed,
    this.size = 20,
    this.tooltip,
  });

  final bool expanded;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return BlenderIconButton(
      glyph: expanded ? BlenderGlyph.chevronDown : BlenderGlyph.chevronRight,
      onPressed: onPressed,
      tooltip: tooltip,
      size: size,
    );
  }
}
