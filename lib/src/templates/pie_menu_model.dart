part of '../templates.dart';

class BlenderPieMenuItem<T> {
  const BlenderPieMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget? icon;
  final bool enabled;
}

/// A reusable radial menu surface for Blender-style pie commands.
class BlenderPieMenu<T> extends StatelessWidget {
  const BlenderPieMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.size = 280,
    this.radius = 92,
  });

  final List<BlenderPieMenuItem<T>> items;
  final ValueChanged<BlenderPieMenuItem<T>> onSelected;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final center = size / 2;
    final angleStep = items.isEmpty ? 0.0 : math.pi * 2 / items.length;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground.withValues(alpha: .96),
          shape: BoxShape.circle,
          border: Border.all(color: theme.colors.borderSubtle),
        ),
        child: Stack(
          children: <Widget>[
            for (var index = 0; index < items.length; index++)
              Positioned(
                left:
                    center +
                    math.cos(angleStep * index - math.pi / 2) * radius -
                    42,
                top:
                    center +
                    math.sin(angleStep * index - math.pi / 2) * radius -
                    28,
                width: 84,
                height: 56,
                child: _BlenderPieItem<T>(
                  item: items[index],
                  onSelected: onSelected,
                ),
              ),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colors.borderSubtle),
                ),
                child: const SizedBox(width: 44, height: 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
