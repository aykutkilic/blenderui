import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'icons.dart';
import 'theme.dart';

@immutable
class BlenderAssetCatalog {
  const BlenderAssetCatalog({
    required this.id,
    required this.label,
    this.children = const <BlenderAssetCatalog>[],
    this.initiallyExpanded = true,
  });

  final String id;
  final String label;
  final List<BlenderAssetCatalog> children;
  final bool initiallyExpanded;
}

/// An asset entry used by [BlenderAssetShelfPopover].
@immutable
class BlenderAssetShelfPopoverItem {
  const BlenderAssetShelfPopoverItem({
    required this.id,
    required this.label,
    this.catalogId,
    this.preview,
    this.color,
    this.enabled = true,
  });

  final String id;
  final String label;
  final String? catalogId;
  final Widget? preview;
  final Color? color;
  final bool enabled;
}

/// Blender's asset-shelf popup: library/catalog column plus searchable grid.
///
/// This follows `asset_shelf_popover.cc` rather than presenting assets as a
/// conventional menu. Selection, search and catalog state remain host-owned
/// when their callbacks are supplied.
class BlenderAssetShelfPopover extends StatefulWidget {
  const BlenderAssetShelfPopover({
    super.key,
    required this.assets,
    this.catalogs = const <BlenderAssetCatalog>[],
    this.selectedId,
    this.selectedCatalogId = '__all__',
    this.onSelected,
    this.onCatalogSelected,
    this.label = 'Assets',
    this.icon = BlenderGlyph.folder,
    this.preview,
    this.child,
    this.big = false,
    this.width = 900,
    this.height = 260,
    this.libraryLabel = 'All Libraries',
    this.onRefresh,
  });

  final List<BlenderAssetShelfPopoverItem> assets;
  final List<BlenderAssetCatalog> catalogs;
  final String? selectedId;
  final String selectedCatalogId;
  final ValueChanged<BlenderAssetShelfPopoverItem>? onSelected;
  final ValueChanged<String>? onCatalogSelected;
  final String label;
  final BlenderGlyph icon;
  final Widget? preview;
  final Widget? child;
  final bool big;
  final double width;
  final double height;
  final String libraryLabel;
  final VoidCallback? onRefresh;

  @override
  State<BlenderAssetShelfPopover> createState() =>
      _BlenderAssetShelfPopoverState();
}

class _BlenderAssetShelfPopoverState extends State<BlenderAssetShelfPopover> {
  final TextEditingController _search = TextEditingController();
  late String _catalogId = widget.selectedCatalogId;

  @override
  void didUpdateWidget(covariant BlenderAssetShelfPopover oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCatalogId != widget.selectedCatalogId) {
      _catalogId = widget.selectedCatalogId;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _isInCatalog(BlenderAssetShelfPopoverItem asset) {
    if (_catalogId == '__all__') return true;
    return asset.catalogId == _catalogId;
  }

  void _selectCatalog(String id) {
    setState(() => _catalogId = id);
    widget.onCatalogSelected?.call(id);
  }

  @override
  Widget build(BuildContext context) {
    final trigger =
        widget.child ??
        (widget.big
            ? BlenderButton(
                label: widget.label,
                leading: widget.preview == null
                    ? BlenderIcon(widget.icon, size: 16)
                    : SizedBox(
                        width: 18,
                        height: 18,
                        child: ClipRect(child: widget.preview),
                      ),
                trailing: const BlenderIcon(BlenderGlyph.chevronDown, size: 12),
                onPressed: () {},
              )
            : BlenderIconButton(
                glyph: widget.icon,
                tooltip: widget.label,
                size: 28,
              ));
    return BlenderPopover(
      child: IgnorePointer(child: trigger),
      popover: (context, close) => _popup(context, close),
    );
  }

  Widget _popup(BuildContext context, VoidCallback close) {
    final theme = BlenderTheme.of(context);
    return ConstrainedBox(
      key: const ValueKey<String>('asset-shelf-popover'),
      constraints: BoxConstraints(
        maxWidth: widget.width,
        maxHeight: widget.height,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x66000000), blurRadius: 12),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(width: 200, child: _catalogColumn(context)),
              const SizedBox(width: 8),
              Expanded(child: _assetColumn(context, close)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _catalogColumn(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            child: BlenderButton(
              label: widget.libraryLabel,
              trailing: const BlenderIcon(BlenderGlyph.chevronDown, size: 11),
              onPressed: () {},
            ),
          ),
          BlenderIconButton(
            glyph: BlenderGlyph.refresh,
            onPressed: widget.onRefresh,
            tooltip: 'Refresh Asset Library',
          ),
        ],
      ),
      const SizedBox(height: 5),
      Expanded(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: BlenderTheme.of(context).colors.borderSubtle,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 4),
            children: <Widget>[
              _catalogRow(context, '__all__', 'All', 0, true),
              for (final catalog in widget.catalogs)
                ..._catalogRows(context, catalog, 1),
            ],
          ),
        ),
      ),
    ],
  );

  Iterable<Widget> _catalogRows(
    BuildContext context,
    BlenderAssetCatalog catalog,
    int depth,
  ) sync* {
    yield _catalogRow(
      context,
      catalog.id,
      catalog.label,
      depth,
      catalog.children.isNotEmpty,
    );
    if (catalog.initiallyExpanded) {
      for (final child in catalog.children) {
        yield* _catalogRows(context, child, depth + 1);
      }
    }
  }

  Widget _catalogRow(
    BuildContext context,
    String id,
    String label,
    int depth,
    bool expanded,
  ) {
    final theme = BlenderTheme.of(context);
    final selected = id == _catalogId;
    return GestureDetector(
      key: ValueKey<String>('asset-catalog-$id'),
      behavior: HitTestBehavior.opaque,
      onTap: () => _selectCatalog(id),
      child: Container(
        height: 25,
        padding: EdgeInsets.only(left: 6 + depth * 16.0, right: 5),
        color: selected ? theme.colors.selection : null,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 16,
              child: expanded
                  ? const BlenderIcon(BlenderGlyph.chevronDown, size: 11)
                  : null,
            ),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.body,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assetColumn(BuildContext context, VoidCallback close) {
    final query = _search.text.toLowerCase();
    final visible = widget.assets
        .where(_isInCatalog)
        .where((asset) => asset.label.toLowerCase().contains(query))
        .toList(growable: false);
    return Column(
      children: <Widget>[
        BlenderSearchField(
          controller: _search,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 7),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Text(
                    'No assets',
                    style: BlenderTheme.of(context).textTheme.caption,
                  ),
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 112,
                    mainAxisExtent: 92,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: visible.length,
                  itemBuilder: (context, index) =>
                      _tile(context, visible[index], close),
                ),
        ),
      ],
    );
  }

  Widget _tile(
    BuildContext context,
    BlenderAssetShelfPopoverItem asset,
    VoidCallback close,
  ) {
    final theme = BlenderTheme.of(context);
    final selected = asset.id == widget.selectedId;
    return GestureDetector(
      key: ValueKey<String>('asset-shelf-${asset.id}'),
      onTap: asset.enabled && widget.onSelected != null
          ? () {
              widget.onSelected!(asset);
              close();
            }
          : null,
      child: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: asset.color ?? theme.colors.surfaceRaised,
                border: Border.all(
                  width: selected ? 3 : 1,
                  color: selected ? theme.colors.focus : theme.colors.border,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child:
                  asset.preview ??
                  Center(
                    child: BlenderIcon(
                      BlenderGlyph.cube,
                      size: 28,
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            asset.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.caption.copyWith(
              color: asset.enabled
                  ? theme.colors.foreground
                  : theme.colors.foregroundDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

/// Multi-select catalog visibility popup used by Asset Shelf headers.
class BlenderAssetShelfCatalogSelector extends StatelessWidget {
  const BlenderAssetShelfCatalogSelector({
    super.key,
    required this.catalogs,
    required this.enabledIds,
    required this.onEnabledChanged,
    this.libraryLabel = 'All Libraries',
    this.onRefresh,
  });

  final List<BlenderAssetCatalog> catalogs;
  final Set<String> enabledIds;
  final void Function(String id, bool enabled) onEnabledChanged;
  final String libraryLabel;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) => BlenderPopover(
    child: const IgnorePointer(
      child: BlenderIconButton(
        glyph: BlenderGlyph.menu,
        tooltip: 'Asset Catalogs',
        size: 28,
      ),
    ),
    popover: (context, close) => SizedBox(
      key: const ValueKey<String>('asset-catalog-selector'),
      width: 280,
      height: 205,
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
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: BlenderButton(label: libraryLabel, onPressed: () {}),
                  ),
                  BlenderIconButton(
                    glyph: BlenderGlyph.refresh,
                    onPressed: onRefresh,
                    tooltip: 'Refresh Asset Library',
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: BlenderTheme.of(context).colors.borderSubtle,
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    children: <Widget>[
                      for (final catalog in catalogs)
                        ..._visibilityRows(catalog, 0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Iterable<Widget> _visibilityRows(
    BlenderAssetCatalog catalog,
    int depth,
  ) sync* {
    final enabled = enabledIds.contains(catalog.id);
    yield SizedBox(
      height: 27,
      child: Padding(
        padding: EdgeInsets.only(left: 7 + depth * 17.0, right: 5),
        child: Row(
          children: <Widget>[
            if (catalog.children.isNotEmpty)
              const BlenderIcon(BlenderGlyph.chevronDown, size: 12)
            else
              const SizedBox(width: 12),
            const SizedBox(width: 5),
            Expanded(
              child: Text(catalog.label, style: const TextStyle(fontSize: 13)),
            ),
            BlenderCheckbox(
              value: enabled,
              onChanged: (value) => onEnabledChanged(catalog.id, value),
            ),
          ],
        ),
      ),
    );
    for (final child in catalog.children) {
      yield* _visibilityRows(child, depth + 1);
    }
  }
}
