part of '../property_templates.dart';

/// A compact, grouped layer selector used by Blender's layer templates.
@immutable
class BlenderLayerItem {
  const BlenderLayerItem({
    required this.id,
    required this.label,
    this.active = false,
    this.used = false,
    this.enabled = true,
  });

  final String id;
  final String label;
  final bool active;
  final bool used;
  final bool enabled;
}

class BlenderLayerSelector extends StatelessWidget {
  const BlenderLayerSelector({
    super.key,
    required this.layers,
    required this.onChanged,
    this.columnsPerGroup = 5,
  });

  final List<BlenderLayerItem> layers;
  final ValueChanged<List<String>> onChanged;
  final int columnsPerGroup;

  void _select(BlenderLayerItem layer) {
    if (!layer.enabled) return;
    final selected = <String>[
      for (final item in layers)
        if (item.active) item.id,
    ];
    final shiftPressed = HardwareKeyboard.instance.logicalKeysPressed.any(
      (key) =>
          key == LogicalKeyboardKey.shiftLeft ||
          key == LogicalKeyboardKey.shiftRight,
    );
    if (shiftPressed) {
      if (selected.contains(layer.id)) {
        selected.remove(layer.id);
      } else {
        selected.add(layer.id);
      }
    } else {
      selected
        ..clear()
        ..add(layer.id);
    }
    onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final groupSize = math.max(1, columnsPerGroup * 2);
    final groups = <List<BlenderLayerItem>>[];
    for (var start = 0; start < layers.length; start += groupSize) {
      groups.add(
        layers.sublist(start, math.min(start + groupSize, layers.length)),
      );
    }
    if (groups.isEmpty) {
      return Text(
        'No layers',
        style: theme.textTheme.caption.copyWith(
          color: theme.colors.foregroundMuted,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var group = 0; group < groups.length; group++) ...<Widget>[
          if (group > 0) const SizedBox(height: 3),
          GridView.count(
            crossAxisCount: math.max(1, columnsPerGroup),
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: <Widget>[
              for (final layer in groups[group])
                BlenderButton(
                  label: layer.label,
                  enabled: layer.enabled,
                  selected: layer.active,
                  variant: BlenderButtonVariant.toolbar,
                  padding: EdgeInsets.zero,
                  trailing: layer.used
                      ? Text(
                          '•',
                          style: theme.textTheme.caption.copyWith(
                            color: theme.colors.accentHover,
                          ),
                        )
                      : null,
                  onPressed: () => _select(layer),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
