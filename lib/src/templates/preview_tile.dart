part of '../templates.dart';

class BlenderPreviewTile extends StatelessWidget {
  const BlenderPreviewTile({
    super.key,
    required this.label,
    this.preview,
    this.selected = false,
    this.onPressed,
    this.width = 96,
    this.height = 84,
  });

  final String label;
  final Widget? preview;
  final bool selected;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final child = Semantics(
      label: label,
      selected: selected,
      button: onPressed != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? theme.colors.selection : theme.colors.surface,
          border: Border.all(
            color: selected
                ? theme.colors.editorOutlineActive
                : theme.colors.editorBorder,
          ),
          borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: <Widget>[
              Expanded(
                child:
                    preview ??
                    ColoredBox(
                      color: theme.colors.buttonPressed,
                      child: Center(
                        child: BlenderIcon(
                          BlenderGlyph.image,
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 3, 4, 3),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return onPressed == null
        ? child
        : GestureDetector(onTap: onPressed, child: child);
  }
}
