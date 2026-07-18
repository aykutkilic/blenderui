part of '../specialized_templates.dart';

/// An asset entry used by [BlenderAssetShelfPopover].
@immutable
class BlenderAssetShelfPopoverItem {
  const BlenderAssetShelfPopoverItem({
    required this.id,
    required this.label,
    this.preview,
    this.color,
    this.enabled = true,
  });

  final String id;
  final String label;
  final Widget? preview;
  final Color? color;
  final bool enabled;
}

/// The asset-shelf trigger and scaled popover used by Blender headers and
/// non-header regions.
class BlenderAssetShelfPopover extends StatelessWidget {
  const BlenderAssetShelfPopover({
    super.key,
    required this.assets,
    this.selectedId,
    this.onSelected,
    this.label = 'Assets',
    this.icon = BlenderGlyph.folder,
    this.big = false,
    this.width = 360,
    this.height = 230,
  });

  final List<BlenderAssetShelfPopoverItem> assets;
  final String? selectedId;
  final ValueChanged<BlenderAssetShelfPopoverItem>? onSelected;
  final String label;
  final BlenderGlyph icon;
  final bool big;
  final double width;
  final double height;

  Widget _tile(
    BuildContext context,
    BlenderAssetShelfPopoverItem asset,
    VoidCallback close,
  ) {
    final theme = BlenderTheme.of(context);
    final selected = asset.id == selectedId;
    return GestureDetector(
      onTap: asset.enabled && onSelected != null
          ? () {
              onSelected!(asset);
              close();
            }
          : null,
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
                        size: big ? 28 : 18,
                        color: theme.colors.foregroundMuted,
                      ),
                    ),
                  ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
              child: Text(
                asset.label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.caption.copyWith(
                  color: asset.enabled
                      ? theme.colors.foreground
                      : theme.colors.foregroundDisabled,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trigger = big
        ? BlenderButton(
            label: label,
            leading: BlenderIcon(icon, size: 16),
            trailing: const BlenderIcon(BlenderGlyph.chevronDown, size: 12),
            onPressed: () {},
          )
        : BlenderIconButton(glyph: icon, tooltip: label, size: 28);
    return BlenderPopover(
      child: IgnorePointer(child: trigger),
      popover: (context, close) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: height),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: BlenderTheme.of(context).colors.menuBackground,
            border: Border.all(
              color: BlenderTheme.of(context).colors.borderSubtle,
            ),
            borderRadius: BorderRadius.circular(
              BlenderTheme.of(context).shapes.menuRadius,
            ),
          ),
          child: assets.isEmpty
              ? Center(
                  child: Text(
                    'No assets',
                    style: BlenderTheme.of(context).textTheme.caption,
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(6),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: big ? 110 : 86,
                    mainAxisExtent: big ? 92 : 70,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: assets.length,
                  itemBuilder: (context, index) =>
                      _tile(context, assets[index], close),
                ),
        ),
      ),
    );
  }
}
