part of '../specialized_templates.dart';

/// The asset-library selector and catalog tree in Blender's file tools pane.
class BlenderFileAssetCatalogPanel extends StatelessWidget {
  const BlenderFileAssetCatalogPanel({
    super.key,
    required this.libraryItems,
    required this.catalogRoots,
    this.libraryValue,
    this.onLibraryChanged,
    this.selectedId,
    this.onSelected,
    this.onRefresh,
    this.onBundleInstall,
    this.showAllItem = true,
    this.showUnassignedItem = true,
    this.allItemId = '__asset_catalog_all__',
    this.unassignedItemId = '__asset_catalog_unassigned__',
    this.onNewCatalog,
    this.catalogContextMenuItems = const <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'new', label: 'New Catalog'),
      BlenderMenuItem<String>(value: 'delete', label: 'Delete Catalog'),
      BlenderMenuItem<String>(value: 'rename', label: 'Rename'),
    ],
    this.onCatalogContextMenuSelected,
    this.title = 'Asset Catalogs',
  });

  final List<BlenderMenuItem<String>> libraryItems;
  final List<BlenderTreeNode<String>> catalogRoots;
  final String? libraryValue;
  final ValueChanged<String>? onLibraryChanged;
  final String? selectedId;
  final ValueChanged<BlenderTreeNode<String>>? onSelected;
  final VoidCallback? onRefresh;
  final VoidCallback? onBundleInstall;
  final bool showAllItem;
  final bool showUnassignedItem;
  final String allItemId;
  final String unassignedItemId;
  final ValueChanged<BlenderTreeNode<String>>? onNewCatalog;
  final List<BlenderMenuItem<String>> catalogContextMenuItems;
  final void Function(BlenderTreeNode<String>, String)?
  onCatalogContextMenuSelected;
  final String title;

  BlenderTreeNode<String> _decorateCatalogNode(BlenderTreeNode<String> node) {
    return BlenderTreeNode<String>(
      id: node.id,
      label: node.label,
      value: node.value,
      children: node.children.map(_decorateCatalogNode).toList(),
      icon: node.icon,
      iconColor: node.iconColor,
      initiallyExpanded: node.initiallyExpanded,
      selectable: node.selectable,
      visible: node.visible,
      locked: node.locked,
      actionIcon: onNewCatalog == null ? node.actionIcon : BlenderGlyph.plus,
      actionTooltip: onNewCatalog == null ? node.actionTooltip : 'New Catalog',
      onAction: onNewCatalog == null
          ? node.onAction
          : () => onNewCatalog!(node),
      dropTarget: node.dropTarget,
      dropHint: node.dropHint,
    );
  }

  List<BlenderTreeNode<String>> _buildCatalogRoots() {
    final roots = <BlenderTreeNode<String>>[];
    if (showAllItem) {
      roots.add(
        BlenderTreeNode<String>(
          id: allItemId,
          label: 'All',
          initiallyExpanded: true,
          children: catalogRoots.map(_decorateCatalogNode).toList(),
        ),
      );
    } else {
      roots.addAll(catalogRoots.map(_decorateCatalogNode));
    }
    if (showUnassignedItem) {
      roots.add(
        BlenderTreeNode<String>(
          id: unassignedItemId,
          label: 'Unassigned',
          icon: BlenderGlyph.file,
        ),
      );
    }
    return roots;
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: BlenderDropdown<String>(
                  value: libraryValue,
                  items: libraryItems,
                  onChanged: onLibraryChanged,
                ),
              ),
              if (onRefresh != null) ...<Widget>[
                const SizedBox(width: 4),
                BlenderIconButton(
                  glyph: BlenderGlyph.refresh,
                  onPressed: onRefresh,
                  tooltip: 'Refresh asset library',
                  size: 24,
                ),
              ],
            ],
          ),
          if (onBundleInstall != null) ...<Widget>[
            const SizedBox(height: 5),
            BlenderButton(
              label: 'Copy Bundle to Asset Library...',
              leading: const BlenderIcon(BlenderGlyph.open, size: 14),
              onPressed: onBundleInstall,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6),
            ),
          ],
          const SizedBox(height: 5),
          Expanded(
            child: BlenderTree<String>(
              roots: _buildCatalogRoots(),
              selectedId: selectedId ?? (showAllItem ? allItemId : null),
              onSelected: onSelected,
              contextMenuItemsBuilder: (node) {
                if (node.id == allItemId || node.id == unassignedItemId) {
                  return const <BlenderMenuItem<String>>[];
                }
                return catalogContextMenuItems;
              },
              onContextMenuSelected: onCatalogContextMenuSelected,
            ),
          ),
        ],
      ),
    );
  }
}
