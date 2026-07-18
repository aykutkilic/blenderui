part of '../templates.dart';

class _BlenderPieItem<T> extends StatelessWidget {
  const _BlenderPieItem({required this.item, required this.onSelected});

  final BlenderPieMenuItem<T> item;
  final ValueChanged<BlenderPieMenuItem<T>> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final child = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.button,
        border: Border.all(color: theme.colors.borderSubtle),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (item.icon != null) item.icon!,
          Text(
            item.label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.caption.copyWith(
              color: item.enabled
                  ? theme.colors.foreground
                  : theme.colors.foregroundDisabled,
            ),
          ),
        ],
      ),
    );
    return GestureDetector(
      onTap: item.enabled ? () => onSelected(item) : null,
      child: child,
    );
  }
}
