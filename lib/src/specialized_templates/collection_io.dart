part of '../specialized_templates.dart';

/// Descriptor for Blender's collection-importer template.
@immutable
class BlenderCollectionImporter {
  const BlenderCollectionImporter({
    required this.label,
    this.filepathController,
    this.properties = const <BlenderPropertyDescriptor<dynamic>>[],
    this.configured = true,
    this.valid = true,
    this.initiallyExpanded = true,
    this.onAdd,
    this.onRemove,
    this.onBrowse,
  });

  final String label;
  final TextEditingController? filepathController;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final bool configured;
  final bool valid;
  final bool initiallyExpanded;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onBrowse;
}

/// Collection importer settings as drawn in Blender's collection properties.
class BlenderCollectionImporterPanel extends StatelessWidget {
  const BlenderCollectionImporterPanel({
    super.key,
    required this.importer,
    this.title = 'Collection Importer',
  });

  final BlenderCollectionImporter? importer;
  final String title;

  @override
  Widget build(BuildContext context) {
    final current = importer;
    if (current == null || !current.configured) {
      return BlenderPanel(
        title: title,
        child: Align(
          alignment: Alignment.centerLeft,
          child: BlenderButton(
            label: 'Add Importer',
            leading: const BlenderIcon(BlenderGlyph.plus, size: 13),
            onPressed: current?.onAdd,
          ),
        ),
      );
    }

    return BlenderPanel(
      title: title,
      child: BlenderPanel(
        title: current.label,
        collapsible: true,
        initiallyExpanded: current.initiallyExpanded,
        headerActions: <Widget>[
          if (current.onRemove != null)
            BlenderIconButton(
              glyph: BlenderGlyph.minus,
              onPressed: current.onRemove,
              tooltip: 'Remove importer',
              size: 21,
            ),
        ],
        child: current.valid
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (current.filepathController != null)
                    BlenderPathField(
                      controller: current.filepathController!,
                      onBrowse: current.onBrowse,
                      placeholder: 'File Path',
                    ),
                  if (current.properties.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 6),
                    _buildOperatorProperties(context, current.properties),
                  ],
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

/// Descriptor for one collection-exporter entry and its active settings.
@immutable
class BlenderCollectionExporter {
  const BlenderCollectionExporter({
    required this.id,
    required this.label,
    this.filepathController,
    this.properties = const <BlenderPropertyDescriptor<dynamic>>[],
    this.valid = true,
    this.initiallyExpanded = true,
  });

  final String id;
  final String label;
  final TextEditingController? filepathController;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final bool valid;
  final bool initiallyExpanded;
}

/// Collection exporter list, reorder controls, and active exporter settings.
class BlenderCollectionExportersPanel extends StatelessWidget {
  const BlenderCollectionExportersPanel({
    super.key,
    required this.exporters,
    this.selectedId,
    this.title = 'Collection Exporters',
    this.onSelected,
    this.onAdd,
    this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
    this.onExportAll,
    this.onExport,
    this.onPresets,
    this.onBrowse,
    this.listHeight = 96,
  });

  final List<BlenderCollectionExporter> exporters;
  final String? selectedId;
  final String title;
  final ValueChanged<BlenderCollectionExporter>? onSelected;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onExportAll;
  final VoidCallback? onExport;
  final VoidCallback? onPresets;
  final VoidCallback? onBrowse;
  final double listHeight;

  BlenderCollectionExporter? get _active {
    if (exporters.isEmpty) return null;
    BlenderCollectionExporter? selected;
    if (selectedId != null) {
      for (final exporter in exporters) {
        if (exporter.id == selectedId) {
          selected = exporter;
          break;
        }
      }
    }
    return selected ?? exporters.first;
  }

  @override
  Widget build(BuildContext context) {
    final active = _active;
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: SizedBox(
                  height: listHeight,
                  child: BlenderListView<BlenderCollectionExporter>(
                    items: <BlenderListItem<BlenderCollectionExporter>>[
                      for (final exporter in exporters)
                        BlenderListItem<BlenderCollectionExporter>(
                          id: exporter.id,
                          label: exporter.label,
                          value: exporter,
                          enabled: true,
                        ),
                    ],
                    selectedId: selectedId,
                    onSelected: onSelected == null
                        ? null
                        : (item) => onSelected!(item.value!),
                    emptyLabel: 'No exporters',
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BlenderIconButton(
                    glyph: BlenderGlyph.plus,
                    onPressed: onAdd,
                    tooltip: 'Add exporter',
                    size: 22,
                  ),
                  BlenderIconButton(
                    glyph: BlenderGlyph.minus,
                    onPressed: exporters.isEmpty ? null : onRemove,
                    tooltip: 'Remove exporter',
                    size: 22,
                  ),
                  SizedBox(
                    width: 22,
                    child: ColoredBox(
                      color: theme.colors.borderSubtle,
                      child: const SizedBox(height: 1),
                    ),
                  ),
                  BlenderIconButton(
                    glyph: BlenderGlyph.chevronUp,
                    onPressed: onMoveUp,
                    tooltip: 'Move exporter up',
                    size: 22,
                  ),
                  BlenderIconButton(
                    glyph: BlenderGlyph.chevronDown,
                    onPressed: onMoveDown,
                    tooltip: 'Move exporter down',
                    size: 22,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          BlenderButton(
            label: 'Export All',
            leading: const BlenderIcon(BlenderGlyph.export, size: 14),
            enabled: exporters.isNotEmpty,
            onPressed: onExportAll,
          ),
          if (active != null) ...<Widget>[
            const SizedBox(height: 8),
            BlenderPanel(
              title: active.label,
              collapsible: true,
              initiallyExpanded: active.initiallyExpanded,
              headerActions: <Widget>[
                if (onPresets != null)
                  BlenderIconButton(
                    glyph: BlenderGlyph.preset,
                    onPressed: onPresets,
                    tooltip: 'Exporter presets',
                    size: 21,
                  ),
                if (onExport != null)
                  BlenderIconButton(
                    glyph: BlenderGlyph.export,
                    onPressed: active.valid ? onExport : null,
                    tooltip: 'Export collection',
                    size: 21,
                  ),
              ],
              child: active.valid
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (active.filepathController != null)
                          BlenderPathField(
                            controller: active.filepathController!,
                            onBrowse: onBrowse,
                            placeholder: '//' + active.label,
                          ),
                        if (active.properties.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 6),
                          _buildOperatorProperties(context, active.properties),
                        ],
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ],
      ),
    );
  }
}
