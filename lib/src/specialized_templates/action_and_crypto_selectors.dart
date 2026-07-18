part of '../specialized_templates.dart';

/// The animation Action-specific variant of Blender's ID template.
/// It intentionally delegates the common browse, rename, unlink, and New
/// affordances to [BlenderDataBlockField] while supplying the Action anatomy.
class BlenderActionSelector<T> extends StatelessWidget {
  const BlenderActionSelector({
    super.key,
    required this.value,
    required this.items,
    this.label = 'Action',
    this.onChanged,
    this.onNew,
    this.onUnlink,
    this.userCount = 0,
    this.linked = false,
    this.showPreviews = false,
  });

  final T? value;
  final List<BlenderMenuItem<T>> items;
  final String label;
  final ValueChanged<T>? onChanged;
  final VoidCallback? onNew;
  final VoidCallback? onUnlink;
  final int userCount;
  final bool linked;
  final bool showPreviews;

  @override
  Widget build(BuildContext context) {
    return BlenderDataBlockField<T>(
      label: label,
      value: value,
      items: items,
      icon: BlenderGlyph.action,
      onChanged: onChanged,
      onNew: onNew,
      onUnlink: onUnlink,
      userCount: userCount,
      linked: linked,
      showPreviews: showPreviews,
    );
  }
}

/// Blender's cryptomatte picker is a compact eyedropper operator button.
class BlenderCryptoPicker extends StatelessWidget {
  const BlenderCryptoPicker({
    super.key,
    this.label,
    this.onPressed,
    this.enabled = true,
    this.tooltip = 'Pick Cryptomatte color',
  });

  final String? label;
  final VoidCallback? onPressed;
  final bool enabled;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final button = BlenderIconButton(
      glyph: BlenderGlyph.eyedropper,
      enabled: enabled,
      onPressed: onPressed,
      tooltip: tooltip,
      size: 24,
    );
    if (label == null) return button;
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label!,
            overflow: TextOverflow.ellipsis,
            style: BlenderTheme.of(context).textTheme.label,
          ),
        ),
        button,
      ],
    );
  }
}
