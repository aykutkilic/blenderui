part of '../non3d_editors.dart';

class BlenderAssetTile {
  const BlenderAssetTile({
    required this.id,
    required this.label,
    this.preview,
    this.color,
  });

  final String id;
  final String label;
  final Widget? preview;
  final Color? color;
}

class BlenderAssetShelf extends StatelessWidget {
  const BlenderAssetShelf({
    super.key,
    required this.assets,
    this.selectedId,
    this.onSelected,
    this.title = 'Asset Shelf',
  });

  final List<BlenderAssetTile> assets;
  final String? selectedId;
  final ValueChanged<BlenderAssetTile>? onSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 120,
          mainAxisExtent: 92,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          final selected = asset.id == selectedId;
          return GestureDetector(
            onTap: onSelected == null ? null : () => onSelected!(asset),
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
              child: Column(
                children: <Widget>[
                  Expanded(
                    child:
                        asset.preview ??
                        ColoredBox(
                          color: asset.color ?? theme.colors.buttonPressed,
                          child: Center(
                            child: BlenderIcon(
                              BlenderGlyph.cube,
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    child: Text(
                      asset.label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.caption,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
