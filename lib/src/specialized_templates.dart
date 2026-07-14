import 'package:flutter/widgets.dart';

import 'advanced_controls.dart';
import 'collections.dart';
import 'controls.dart';
import 'editors.dart';
import 'icons.dart';
import 'layout.dart';
import 'templates.dart';
import 'theme.dart';

/// Blender's operator property rows are shared by redo popups and
/// confirmation dialogs. Keeping the input as the package's property
/// descriptor means operator/RNA state remains caller-owned.
Widget _buildOperatorProperties(
  BuildContext context,
  List<BlenderPropertyDescriptor<dynamic>> properties,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      for (final property in properties)
        BlenderPropertyRow(
          label: property.label,
          tooltip: property.tooltip,
          state: property.state,
          labelPlacement: property.effectiveLabelPlacement,
          onKeyframe: property.onKeyframe,
          onReset: property.onReset,
          editor: property.buildEditor(context),
        ),
    ],
  );
}

/// The regular popup used by Blender for the last operator's redo settings.
///
/// Blender presents the operator name, a thin separator, and a compact
/// property column inside a small anchored popup. The popup positioning and
/// undo/repeat behavior belong to the host application; this widget owns the
/// visual anatomy and its disabled state.
class BlenderOperatorRedoPopup extends StatelessWidget {
  const BlenderOperatorRedoPopup({
    super.key,
    required this.title,
    required this.properties,
    this.enabled = true,
    this.width = 240,
  });

  final String title;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final bool enabled;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 180, maxWidth: width),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x88000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Opacity(
            opacity: enabled ? 1 : .5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(title, style: theme.textTheme.heading),
                const SizedBox(height: 5),
                SizedBox(
                  height: 1,
                  child: ColoredBox(color: theme.colors.borderSubtle),
                ),
                const SizedBox(height: 6),
                _buildOperatorProperties(context, properties),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The centered operator-properties dialog used when Blender requires an
/// explicit confirmation before execution.
class BlenderOperatorPropertiesDialog extends StatelessWidget {
  const BlenderOperatorPropertiesDialog({
    super.key,
    required this.title,
    required this.properties,
    this.message,
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.showIcon = false,
    this.width = 420,
  });

  final String title;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showIcon;
  final double width;

  void _close(BuildContext context, VoidCallback? callback, bool result) {
    callback?.call();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderDialog(
      title: title,
      message: message,
      icon: showIcon
          ? BlenderIcon(BlenderGlyph.info, size: 34, color: theme.colors.info)
          : null,
      width: width,
      content: _buildOperatorProperties(context, properties),
      actions: <BlenderDialogAction>[
        BlenderDialogAction(
          label: cancelLabel,
          onPressed: () => _close(context, onCancel, false),
        ),
        BlenderDialogAction(
          label: confirmLabel,
          primary: true,
          onPressed: () => _close(context, onConfirm, true),
        ),
      ],
    );
  }
}

/// Opens [BlenderOperatorPropertiesDialog] with Blender's popup route.
Future<bool?> showBlenderOperatorPropertiesDialog({
  required BuildContext context,
  required String title,
  required List<BlenderPropertyDescriptor<dynamic>> properties,
  String? message,
  String confirmLabel = 'OK',
  String cancelLabel = 'Cancel',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool showIcon = false,
  double width = 420,
  bool barrierDismissible = true,
}) {
  return showBlenderDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => BlenderOperatorPropertiesDialog(
      title: title,
      properties: properties,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      showIcon: showIcon,
      width: width,
    ),
  );
}

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

/// Blender's palette template: management controls followed by a responsive
/// grid of selectable color swatches.
class BlenderColorPalette extends StatelessWidget {
  const BlenderColorPalette({
    super.key,
    required this.colors,
    this.selectedIndex,
    this.onSelected,
    this.onAdd,
    this.onRemove,
    this.onMoveUp,
    this.onMoveDown,
    this.sortItems = const <BlenderMenuItem<String>>[],
    this.onSort,
    this.title,
    this.swatchSize = 26,
  });

  final List<Color> colors;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final List<BlenderMenuItem<String>> sortItems;
  final ValueChanged<String>? onSort;
  final String? title;
  final double swatchSize;

  Widget _swatch(BuildContext context, Color color, int index) {
    final theme = BlenderTheme.of(context);
    final selected = selectedIndex == index;
    final swatch = DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(
          color: selected ? theme.colors.accent : theme.colors.borderSubtle,
          width: selected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: BlenderColorSwatch(color: color, size: swatchSize - 6),
      ),
    );
    return Semantics(
      container: true,
      button: onSelected != null,
      selected: selected,
      label: 'Palette color ${index + 1}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onSelected == null ? null : () => onSelected!(index),
        child: swatch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controls = <Widget>[
      BlenderIconButton(
        glyph: BlenderGlyph.plus,
        onPressed: onAdd,
        tooltip: 'Add palette color',
        size: 23,
      ),
      BlenderIconButton(
        glyph: BlenderGlyph.minus,
        onPressed: onRemove,
        tooltip: 'Remove palette color',
        size: 23,
      ),
      if (colors.isNotEmpty) ...<Widget>[
        BlenderIconButton(
          glyph: BlenderGlyph.chevronUp,
          onPressed: onMoveUp,
          tooltip: 'Move palette color up',
          size: 23,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.chevronDown,
          onPressed: onMoveDown,
          tooltip: 'Move palette color down',
          size: 23,
        ),
        if (sortItems.isNotEmpty)
          BlenderMenuButton<String>(
            label: 'Sort',
            items: sortItems,
            onSelected: onSort,
          ),
      ],
    ];
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(children: controls),
        const SizedBox(height: 5),
        if (colors.isEmpty)
          Text(
            'No palette colors',
            style: BlenderTheme.of(context).textTheme.caption.copyWith(
              color: BlenderTheme.of(context).colors.foregroundMuted,
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 4.0;
              final columns = (constraints.maxWidth / (swatchSize + spacing))
                  .floor()
                  .clamp(1, 32)
                  .toInt();
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: <Widget>[
                  for (var index = 0; index < colors.length; index++)
                    SizedBox(
                      width:
                          (constraints.maxWidth - spacing * (columns - 1)) /
                          columns,
                      height: swatchSize,
                      child: _swatch(context, colors[index], index),
                    ),
                ],
              );
            },
          ),
      ],
    );
    return title == null ? body : BlenderPanel(title: title!, child: body);
  }
}

/// A caller-owned constraint panel descriptor.
@immutable
class BlenderConstraintDescriptor {
  const BlenderConstraintDescriptor({
    required this.id,
    required this.name,
    required this.child,
    this.icon = BlenderGlyph.link,
    this.enabled = true,
    this.initiallyExpanded = true,
    this.onToggleEnabled,
    this.onMoveUp,
    this.onMoveDown,
    this.onRemove,
    this.onMenu,
  });

  final String id;
  final String name;
  final Widget child;
  final BlenderGlyph icon;
  final bool enabled;
  final bool initiallyExpanded;
  final VoidCallback? onToggleEnabled;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRemove;
  final VoidCallback? onMenu;
}

/// Blender's instanced constraint-panel stack.
class BlenderConstraintStack extends StatelessWidget {
  const BlenderConstraintStack({
    super.key,
    required this.constraints,
    this.title = 'Constraints',
    this.emptyLabel = 'No constraints',
  });

  final List<BlenderConstraintDescriptor> constraints;
  final String title;
  final String emptyLabel;

  List<Widget> _actions(BlenderConstraintDescriptor constraint) {
    return <Widget>[
      if (constraint.onToggleEnabled != null)
        BlenderIconButton(
          glyph: BlenderGlyph.eye,
          selected: constraint.enabled,
          onPressed: constraint.onToggleEnabled,
          tooltip: 'Enable constraint',
          size: 21,
        ),
      if (constraint.onMenu != null)
        BlenderIconButton(
          glyph: BlenderGlyph.more,
          onPressed: constraint.onMenu,
          tooltip: 'Constraint options',
          size: 21,
        ),
      if (constraint.onMoveUp != null)
        BlenderIconButton(
          glyph: BlenderGlyph.stepBack,
          onPressed: constraint.onMoveUp,
          tooltip: 'Move constraint up',
          size: 21,
        ),
      if (constraint.onMoveDown != null)
        BlenderIconButton(
          glyph: BlenderGlyph.stepForward,
          onPressed: constraint.onMoveDown,
          tooltip: 'Move constraint down',
          size: 21,
        ),
      if (constraint.onRemove != null)
        BlenderIconButton(
          glyph: BlenderGlyph.close,
          onPressed: constraint.onRemove,
          tooltip: 'Remove constraint',
          size: 21,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      child: constraints.isEmpty
          ? Text(
              emptyLabel,
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final constraint in constraints)
                  BlenderPanel(
                    title: constraint.name,
                    headerLeading: BlenderIcon(constraint.icon, size: 14),
                    collapsible: true,
                    initiallyExpanded: constraint.initiallyExpanded,
                    headerActions: _actions(constraint),
                    child: Opacity(
                      opacity: constraint.enabled ? 1 : .5,
                      child: constraint.child,
                    ),
                  ),
              ],
            ),
    );
  }
}

/// A caller-owned Grease Pencil shader-effect panel descriptor.
@immutable
class BlenderShaderEffectDescriptor {
  const BlenderShaderEffectDescriptor({
    required this.id,
    required this.name,
    required this.child,
    this.icon = BlenderGlyph.color,
    this.enabled = true,
    this.initiallyExpanded = true,
    this.onToggleEnabled,
    this.onMoveUp,
    this.onMoveDown,
    this.onRemove,
  });

  final String id;
  final String name;
  final Widget child;
  final BlenderGlyph icon;
  final bool enabled;
  final bool initiallyExpanded;
  final VoidCallback? onToggleEnabled;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRemove;
}

/// Blender's instanced shader-effect panel stack.
class BlenderShaderEffectStack extends StatelessWidget {
  const BlenderShaderEffectStack({
    super.key,
    required this.effects,
    this.title = 'Shader Effects',
    this.emptyLabel = 'No shader effects',
  });

  final List<BlenderShaderEffectDescriptor> effects;
  final String title;
  final String emptyLabel;

  List<Widget> _actions(BlenderShaderEffectDescriptor effect) {
    return <Widget>[
      BlenderIconButton(
        glyph: BlenderGlyph.eye,
        selected: effect.enabled,
        onPressed: effect.onToggleEnabled,
        tooltip: 'Enable shader effect',
        size: 21,
      ),
      if (effect.onMoveUp != null)
        BlenderIconButton(
          glyph: BlenderGlyph.stepBack,
          onPressed: effect.onMoveUp,
          tooltip: 'Move shader effect up',
          size: 21,
        ),
      if (effect.onMoveDown != null)
        BlenderIconButton(
          glyph: BlenderGlyph.stepForward,
          onPressed: effect.onMoveDown,
          tooltip: 'Move shader effect down',
          size: 21,
        ),
      if (effect.onRemove != null)
        BlenderIconButton(
          glyph: BlenderGlyph.close,
          onPressed: effect.onRemove,
          tooltip: 'Remove shader effect',
          size: 21,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      child: effects.isEmpty
          ? Text(
              emptyLabel,
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final effect in effects)
                  BlenderPanel(
                    title: effect.name,
                    headerLeading: BlenderIcon(effect.icon, size: 14),
                    collapsible: true,
                    initiallyExpanded: effect.initiallyExpanded,
                    headerActions: _actions(effect),
                    child: Opacity(
                      opacity: effect.enabled ? 1 : .5,
                      child: effect.child,
                    ),
                  ),
              ],
            ),
    );
  }
}

/// A socket declaration in a node-tree interface pane.
@immutable
class BlenderNodeInterfaceSocket {
  const BlenderNodeInterfaceSocket({
    required this.id,
    required this.label,
    this.color = const Color(0xFF8BC34A),
    this.input = true,
    this.output = false,
    this.detail,
    this.active = false,
    this.enabled = true,
    this.onActivate,
    this.onRemove,
  });

  final String id;
  final String label;
  final Color color;
  final bool input;
  final bool output;
  final String? detail;
  final bool active;
  final bool enabled;
  final VoidCallback? onActivate;
  final VoidCallback? onRemove;
}

/// A panel declaration in a node-tree interface pane.
@immutable
class BlenderNodeInterfacePanel {
  const BlenderNodeInterfacePanel({
    required this.id,
    required this.name,
    this.children = const <BlenderNodeInterfaceItem>[],
    this.active = false,
    this.initiallyExpanded = true,
    this.enabled = true,
    this.onActivate,
    this.onRemove,
  });

  final String id;
  final String name;
  final List<BlenderNodeInterfaceItem> children;
  final bool active;
  final bool initiallyExpanded;
  final bool enabled;
  final VoidCallback? onActivate;
  final VoidCallback? onRemove;
}

/// A typed socket-or-panel item used by [BlenderNodeTreeInterface].
@immutable
class BlenderNodeInterfaceItem {
  const BlenderNodeInterfaceItem.socket(BlenderNodeInterfaceSocket value)
    : socket = value,
      panel = null;

  const BlenderNodeInterfaceItem.panel(BlenderNodeInterfacePanel value)
    : socket = null,
      panel = value;

  final BlenderNodeInterfaceSocket? socket;
  final BlenderNodeInterfacePanel? panel;

  bool get isPanel => panel != null;
}

/// The nested declaration tree used by Blender's node-tree interface template.
class BlenderNodeTreeInterface extends StatefulWidget {
  const BlenderNodeTreeInterface({
    super.key,
    required this.items,
    this.title = 'Node Tree Interface',
    this.emptyLabel = 'No interface items',
  });

  final List<BlenderNodeInterfaceItem> items;
  final String title;
  final String emptyLabel;

  @override
  State<BlenderNodeTreeInterface> createState() =>
      _BlenderNodeTreeInterfaceState();
}

class _BlenderNodeTreeInterfaceState extends State<BlenderNodeTreeInterface> {
  late final Set<String> _expanded = _initialExpanded(widget.items);

  static Set<String> _initialExpanded(List<BlenderNodeInterfaceItem> items) {
    final expanded = <String>{};
    void visit(BlenderNodeInterfaceItem item) {
      final panel = item.panel;
      if (panel == null) return;
      if (panel.initiallyExpanded) expanded.add(panel.id);
      for (final child in panel.children) {
        visit(child);
      }
    }

    for (final item in items) {
      visit(item);
    }
    return expanded;
  }

  List<_NodeInterfaceVisibleItem> _flatten(
    List<BlenderNodeInterfaceItem> items,
    int depth,
  ) {
    final result = <_NodeInterfaceVisibleItem>[];
    for (final item in items) {
      result.add(_NodeInterfaceVisibleItem(item, depth));
      final panel = item.panel;
      if (panel != null && _expanded.contains(panel.id)) {
        result.addAll(_flatten(panel.children, depth + 1));
      }
    }
    return result;
  }

  Widget _socketDot(Color color, {required bool output}) {
    return SizedBox(
      width: 18,
      child: Align(
        alignment: output ? Alignment.centerRight : Alignment.centerLeft,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: BlenderTheme.of(context).colors.border),
          ),
          child: const SizedBox.square(dimension: 10),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, _NodeInterfaceVisibleItem visible) {
    final theme = BlenderTheme.of(context);
    final panel = visible.item.panel;
    final socket = visible.item.socket;
    final indent = 8.0 + visible.depth * 14;
    if (panel != null) {
      final expandable = panel.children.isNotEmpty;
      return SizedBox(
        height: theme.density.rowHeight,
        child: Row(
          children: <Widget>[
            SizedBox(width: indent),
            if (expandable)
              BlenderDisclosureButton(
                expanded: _expanded.contains(panel.id),
                onPressed: () => setState(() {
                  if (_expanded.contains(panel.id)) {
                    _expanded.remove(panel.id);
                  } else {
                    _expanded.add(panel.id);
                  }
                }),
                size: 18,
              )
            else
              const SizedBox(width: 18),
            const BlenderIcon(BlenderGlyph.node, size: 15),
            const SizedBox(width: 5),
            Expanded(
              child: GestureDetector(
                onTap: panel.enabled ? panel.onActivate : null,
                child: Text(
                  panel.name,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.label.copyWith(
                    color: panel.enabled
                        ? theme.colors.foreground
                        : theme.colors.foregroundDisabled,
                  ),
                ),
              ),
            ),
            if (panel.onRemove != null)
              BlenderIconButton(
                glyph: BlenderGlyph.close,
                onPressed: panel.onRemove,
                tooltip: 'Remove interface panel',
                size: 21,
              ),
          ],
        ),
      );
    }
    if (socket == null) return const SizedBox.shrink();
    return SizedBox(
      height: theme.density.rowHeight,
      child: Row(
        children: <Widget>[
          SizedBox(width: indent + 18),
          if (socket.input)
            _socketDot(socket.color, output: false)
          else
            const SizedBox(width: 18),
          Expanded(
            child: GestureDetector(
              onTap: socket.enabled ? socket.onActivate : null,
              child: Text(
                socket.label,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.label.copyWith(
                  color: socket.enabled
                      ? (socket.active
                            ? theme.colors.accentHover
                            : theme.colors.foreground)
                      : theme.colors.foregroundDisabled,
                ),
              ),
            ),
          ),
          if (socket.detail != null)
            Text(
              socket.detail!,
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            ),
          if (socket.output)
            _socketDot(socket.color, output: true)
          else
            const SizedBox(width: 18),
          if (socket.onRemove != null)
            BlenderIconButton(
              glyph: BlenderGlyph.close,
              onPressed: socket.onRemove,
              tooltip: 'Remove interface socket',
              size: 21,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _flatten(widget.items, 0);
    return BlenderPanel(
      title: widget.title,
      child: rows.isEmpty
          ? Text(
              widget.emptyLabel,
              style: BlenderTheme.of(context).textTheme.caption,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[for (final row in rows) _row(context, row)],
            ),
    );
  }
}

class _NodeInterfaceVisibleItem {
  const _NodeInterfaceVisibleItem(this.item, this.depth);

  final BlenderNodeInterfaceItem item;
  final int depth;
}

/// A nested armature bone-collection descriptor.
@immutable
class BlenderBoneCollection {
  const BlenderBoneCollection({
    required this.id,
    required this.name,
    this.children = const <BlenderBoneCollection>[],
    this.active = false,
    this.hasSelectedBones = false,
    this.visible = true,
    this.solo = false,
    this.initiallyExpanded = true,
    this.enabled = true,
    this.onActivate,
    this.onVisibilityChanged,
    this.onSoloChanged,
    this.onRemove,
  });

  final String id;
  final String name;
  final List<BlenderBoneCollection> children;
  final bool active;
  final bool hasSelectedBones;
  final bool visible;
  final bool solo;
  final bool initiallyExpanded;
  final bool enabled;
  final VoidCallback? onActivate;
  final ValueChanged<bool>? onVisibilityChanged;
  final ValueChanged<bool>? onSoloChanged;
  final VoidCallback? onRemove;
}

/// Blender's nested bone-collection tree with active/used, visibility, and
/// solo columns.
class BlenderBoneCollectionTree extends StatefulWidget {
  const BlenderBoneCollectionTree({
    super.key,
    required this.collections,
    this.title = 'Bone Collections',
    this.emptyLabel = 'No bone collections',
  });

  final List<BlenderBoneCollection> collections;
  final String title;
  final String emptyLabel;

  @override
  State<BlenderBoneCollectionTree> createState() =>
      _BlenderBoneCollectionTreeState();
}

class _BlenderBoneCollectionTreeState extends State<BlenderBoneCollectionTree> {
  late final Set<String> _expanded = _initialExpanded(widget.collections);

  static Set<String> _initialExpanded(List<BlenderBoneCollection> items) {
    final expanded = <String>{};
    void visit(BlenderBoneCollection item) {
      if (item.initiallyExpanded) expanded.add(item.id);
      for (final child in item.children) {
        visit(child);
      }
    }

    for (final item in items) {
      visit(item);
    }
    return expanded;
  }

  List<_BoneCollectionVisibleItem> _flatten(
    List<BlenderBoneCollection> items,
    int depth,
  ) {
    final result = <_BoneCollectionVisibleItem>[];
    for (final item in items) {
      result.add(_BoneCollectionVisibleItem(item, depth));
      if (_expanded.contains(item.id)) {
        result.addAll(_flatten(item.children, depth + 1));
      }
    }
    return result;
  }

  Widget _row(BuildContext context, _BoneCollectionVisibleItem visible) {
    final theme = BlenderTheme.of(context);
    final collection = visible.collection;
    final expandable = collection.children.isNotEmpty;
    return SizedBox(
      height: theme.density.rowHeight,
      child: Row(
        children: <Widget>[
          SizedBox(width: 8 + visible.depth * 14),
          if (expandable)
            BlenderDisclosureButton(
              expanded: _expanded.contains(collection.id),
              onPressed: () => setState(() {
                if (_expanded.contains(collection.id)) {
                  _expanded.remove(collection.id);
                } else {
                  _expanded.add(collection.id);
                }
              }),
              size: 18,
            )
          else
            const SizedBox(width: 18),
          Expanded(
            child: GestureDetector(
              onTap: collection.enabled ? collection.onActivate : null,
              child: Text(
                collection.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.label.copyWith(
                  color: collection.enabled
                      ? (collection.active
                            ? theme.colors.accentHover
                            : theme.colors.foreground)
                      : theme.colors.foregroundDisabled,
                ),
              ),
            ),
          ),
          BlenderIcon(
            collection.active
                ? BlenderGlyph.checkCircle
                : collection.hasSelectedBones
                ? BlenderGlyph.radio
                : BlenderGlyph.minus,
            size: 15,
            color: collection.hasSelectedBones || collection.active
                ? theme.colors.accentHover
                : theme.colors.foregroundMuted,
          ),
          BlenderIconButton(
            glyph: BlenderGlyph.eye,
            selected: collection.visible,
            enabled: collection.enabled,
            onPressed: collection.onVisibilityChanged == null
                ? null
                : () => collection.onVisibilityChanged!(!collection.visible),
            tooltip: 'Show bone collection',
            size: 21,
          ),
          BlenderIconButton(
            glyph: BlenderGlyph.radio,
            selected: collection.solo,
            enabled: collection.enabled,
            onPressed: collection.onSoloChanged == null
                ? null
                : () => collection.onSoloChanged!(!collection.solo),
            tooltip: 'Solo bone collection',
            size: 21,
          ),
          if (collection.onRemove != null)
            BlenderIconButton(
              glyph: BlenderGlyph.close,
              onPressed: collection.onRemove,
              tooltip: 'Remove bone collection',
              size: 21,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rows = _flatten(widget.collections, 0);
    return BlenderPanel(
      title: widget.title,
      child: rows.isEmpty
          ? Text(
              widget.emptyLabel,
              style: BlenderTheme.of(context).textTheme.caption,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[for (final row in rows) _row(context, row)],
            ),
    );
  }
}

class _BoneCollectionVisibleItem {
  const _BoneCollectionVisibleItem(this.collection, this.depth);

  final BlenderBoneCollection collection;
  final int depth;
}

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

/// An expanded enum row matching Blender's component-menu template.
class BlenderComponentMenu<T> extends StatelessWidget {
  const BlenderComponentMenu({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.expanded = true,
  });

  final T value;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return BlenderSegmentedControl<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      expanded: expanded,
    );
  }
}

/// The compact one-item/list-count variant of Blender's UI list template.
class BlenderCompactList<T> extends StatelessWidget {
  const BlenderCompactList({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.emptyLabel = 'No items',
  });

  final List<BlenderListItem<T>> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    if (items.isEmpty) {
      return BlenderBox(
        child: Text(
          emptyLabel,
          style: theme.textTheme.caption.copyWith(
            color: theme.colors.foregroundMuted,
          ),
        ),
      );
    }
    final index = selectedIndex.clamp(0, items.length - 1).toInt();
    final item = items[index];
    return Row(
      children: <Widget>[
        Semantics(
          button: true,
          label: 'Previous list item',
          enabled: index > 0,
          child: ExcludeSemantics(
            child: BlenderIconButton(
              glyph: BlenderGlyph.chevronRight,
              enabled: index > 0,
              onPressed: index > 0 ? () => onChanged(index - 1) : null,
              tooltip: 'Previous list item',
              size: 22,
            ),
          ),
        ),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.textField,
              border: Border.all(color: theme.colors.borderSubtle),
              borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
            ),
            child: SizedBox(
              height: theme.density.controlHeight,
              child: Row(
                children: <Widget>[
                  if (item.icon != null) ...<Widget>[
                    const SizedBox(width: 5),
                    BlenderIcon(item.icon!, color: item.iconColor, size: 14),
                  ],
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.label,
                    ),
                  ),
                  if (item.detail != null)
                    Text(
                      item.detail!,
                      style: theme.textTheme.caption.copyWith(
                        color: theme.colors.foregroundMuted,
                      ),
                    ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: 'Next list item',
          enabled: index < items.length - 1,
          child: ExcludeSemantics(
            child: BlenderIconButton(
              glyph: BlenderGlyph.chevronRight,
              enabled: index < items.length - 1,
              onPressed: index < items.length - 1
                  ? () => onChanged(index + 1)
                  : null,
              tooltip: 'Next list item',
              size: 22,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            '${index + 1} : ${items.length}',
            textAlign: TextAlign.center,
            style: theme.textTheme.caption,
          ),
        ),
      ],
    );
  }
}

/// A descriptor-driven version of Blender's full `template_ID()` property
/// control.  The compact [BlenderDataBlockGroup] remains useful for headers;
/// this field covers the wider Properties-panel anatomy with a browse/search
/// surface and data-block lifecycle affordances.
class BlenderDataBlockField<T> extends StatelessWidget {
  const BlenderDataBlockField({
    super.key,
    required this.value,
    required this.items,
    this.label,
    this.placeholder = 'None',
    this.icon = BlenderGlyph.object,
    this.onChanged,
    this.onNew,
    this.onOpen,
    this.onMakeSingleUser,
    this.onMakeLocal,
    this.onToggleFakeUser,
    this.onUnlink,
    this.fakeUser = false,
    this.userCount = 0,
    this.linked = false,
    this.libraryOverride = false,
    this.showPreviews = false,
    this.enabled = true,
    this.fieldWidth,
  });

  final T? value;
  final List<BlenderMenuItem<T>> items;
  final String? label;
  final String placeholder;
  final BlenderGlyph icon;
  final ValueChanged<T>? onChanged;
  final VoidCallback? onNew;
  final VoidCallback? onOpen;
  final VoidCallback? onMakeSingleUser;
  final VoidCallback? onMakeLocal;
  final ValueChanged<bool>? onToggleFakeUser;
  final VoidCallback? onUnlink;
  final bool fakeUser;
  final int userCount;
  final bool linked;
  final bool libraryOverride;
  final bool showPreviews;
  final bool enabled;
  final double? fieldWidth;

  BlenderMenuItem<T>? _selectedItem() {
    for (final item in items) {
      if (item.value == value) return item;
    }
    return null;
  }

  Widget _browseField(BuildContext context, BlenderMenuItem<T>? selected) {
    final theme = BlenderTheme.of(context);
    final hasValue = value != null;
    final field = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.textField,
        border: Border.all(color: theme.colors.borderSubtle),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: SizedBox(
        height: theme.density.controlHeight,
        child: Row(
          children: <Widget>[
            const SizedBox(width: 5),
            selected?.icon ?? BlenderIcon(icon, size: 14),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                selected?.label ?? placeholder,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.label.copyWith(
                  color: hasValue
                      ? theme.colors.foreground
                      : theme.colors.foregroundMuted,
                ),
              ),
            ),
            BlenderIcon(
              BlenderGlyph.chevronDown,
              size: 12,
              color: theme.colors.foregroundMuted,
            ),
            const SizedBox(width: 5),
          ],
        ),
      ),
    );
    return BlenderPopover(
      child: Semantics(
        container: true,
        button: true,
        enabled: enabled && onChanged != null,
        label: 'Browse ${label ?? 'data-block'}',
        child: IgnorePointer(child: field),
      ),
      popover: (context, close) => _BlenderDataBlockBrowser<T>(
        items: items,
        selectedValue: value,
        showPreviews: showPreviews,
        onSelected: onChanged == null
            ? null
            : (item) {
                onChanged!(item.value);
                close();
              },
      ),
    );
  }

  Widget _action({
    required BlenderGlyph glyph,
    required String tooltip,
    required VoidCallback? onPressed,
    bool selected = false,
  }) {
    return BlenderIconButton(
      glyph: glyph,
      selected: selected,
      enabled: enabled,
      onPressed: enabled ? onPressed : null,
      tooltip: tooltip,
      size: 22,
    );
  }

  Widget _content(BuildContext context) {
    final selected = _selectedItem();
    final actions = <Widget>[
      if (onNew != null)
        value == null
            ? BlenderButton(
                label: 'New',
                leading: const BlenderIcon(BlenderGlyph.plus, size: 13),
                enabled: enabled,
                onPressed: enabled ? onNew : null,
                padding: const EdgeInsets.symmetric(horizontal: 7),
              )
            : _action(
                glyph: BlenderGlyph.duplicate,
                tooltip: 'Make new data-block',
                onPressed: onNew,
              ),
      if (userCount > 1 && onMakeSingleUser != null)
        BlenderButton(
          label: '$userCount',
          enabled: enabled,
          onPressed: enabled ? onMakeSingleUser : null,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          variant: BlenderButtonVariant.toolbar,
        ),
      if (linked)
        _action(
          glyph: BlenderGlyph.link,
          tooltip: 'Make local',
          onPressed: onMakeLocal,
        ),
      if (libraryOverride)
        _action(
          glyph: BlenderGlyph.linkBroken,
          tooltip: 'Library override',
          onPressed: onMakeLocal,
        ),
      if (onToggleFakeUser != null && value != null)
        _action(
          glyph: BlenderGlyph.pin,
          tooltip: 'Keep data-block',
          selected: fakeUser,
          onPressed: () => onToggleFakeUser!(!fakeUser),
        ),
      if (onOpen != null)
        value == null
            ? BlenderButton(
                label: 'Open',
                leading: const BlenderIcon(BlenderGlyph.open, size: 13),
                enabled: enabled,
                onPressed: enabled ? onOpen : null,
                padding: const EdgeInsets.symmetric(horizontal: 7),
              )
            : _action(
                glyph: BlenderGlyph.open,
                tooltip: 'Open data-block',
                onPressed: onOpen,
              ),
      if (onUnlink != null && value != null)
        _action(
          glyph: BlenderGlyph.close,
          tooltip: 'Unlink data-block',
          onPressed: onUnlink,
        ),
    ];
    final field = Row(
      children: <Widget>[
        Expanded(child: _browseField(context, selected)),
        if (actions.isNotEmpty) ...<Widget>[
          const SizedBox(width: 3),
          ...actions,
        ],
      ],
    );
    if (label == null) return field;
    return Row(
      children: <Widget>[
        SizedBox(
          width: 88,
          child: Text(label!, style: BlenderTheme.of(context).textTheme.label),
        ),
        Expanded(child: field),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _content(context);
    return fieldWidth == null
        ? content
        : SizedBox(width: fieldWidth, child: content);
  }
}

class _BlenderDataBlockBrowser<T> extends StatefulWidget {
  const _BlenderDataBlockBrowser({
    required this.items,
    required this.selectedValue,
    required this.showPreviews,
    required this.onSelected,
  });

  final List<BlenderMenuItem<T>> items;
  final T? selectedValue;
  final bool showPreviews;
  final ValueChanged<BlenderMenuItem<T>>? onSelected;

  @override
  State<_BlenderDataBlockBrowser<T>> createState() =>
      _BlenderDataBlockBrowserState<T>();
}

class _BlenderDataBlockBrowserState<T>
    extends State<_BlenderDataBlockBrowser<T>> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 280,
        maxWidth: 360,
        minHeight: 250,
        maxHeight: 420,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (context, value, child) {
            final query = value.text.trim().toLowerCase();
            final visible = widget.items
                .where((item) => item.label.toLowerCase().contains(query))
                .toList(growable: false);
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: BlenderSearchField(
                    controller: _searchController,
                    placeholder: 'Search data-blocks',
                  ),
                ),
                Expanded(
                  child: visible.isEmpty
                      ? Center(
                          child: Text(
                            'No data-blocks',
                            style: theme.textTheme.caption.copyWith(
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        )
                      : widget.showPreviews
                      ? GridView.builder(
                          padding: const EdgeInsets.all(5),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 112,
                                mainAxisExtent: 92,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final item = visible[index];
                            return BlenderPreviewTile(
                              label: item.label,
                              selected: item.value == widget.selectedValue,
                              preview: item.icon == null
                                  ? null
                                  : Center(child: item.icon),
                              onPressed:
                                  item.enabled && widget.onSelected != null
                                  ? () => widget.onSelected!(item)
                                  : null,
                              width: 100,
                              height: 88,
                            );
                          },
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          itemCount: visible.length,
                          itemBuilder: (context, index) {
                            final item = visible[index];
                            return BlenderButton(
                              label: item.label,
                              leading: item.icon,
                              selected: item.value == widget.selectedValue,
                              enabled: item.enabled,
                              variant: BlenderButtonVariant.menu,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              onPressed:
                                  item.enabled && widget.onSelected != null
                                  ? () => widget.onSelected!(item)
                                  : null,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

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

/// An enum/icon choice used by Blender's icon-view template.
@immutable
class BlenderIconViewItem<T> {
  const BlenderIconViewItem({
    required this.value,
    required this.label,
    required this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget icon;
  final bool enabled;
}

/// A selected icon that opens Blender's eight-column icon-view popup.
///
/// The descriptor is intentionally independent of enum/RNA values.  It keeps
/// the popup geometry and selected-state treatment reusable for render modes,
/// brush presets, editor choices, and other icon-backed enumerations.
class BlenderIconView<T> extends StatelessWidget {
  const BlenderIconView({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.showLabels = true,
    this.iconScale = 28,
    this.iconScalePopup = 46,
    this.enabled = true,
  });

  final List<BlenderIconViewItem<T>> items;
  final T value;
  final ValueChanged<T>? onChanged;
  final bool showLabels;
  final double iconScale;
  final double iconScalePopup;
  final bool enabled;

  BlenderIconViewItem<T>? get _selected {
    for (final item in items) {
      if (item.value == value) return item;
    }
    return null;
  }

  Widget _tile(
    BuildContext context,
    BlenderIconViewItem<T> item,
    VoidCallback close,
  ) {
    final theme = BlenderTheme.of(context);
    final selected = item.value == value;
    final active = enabled && item.enabled && onChanged != null;
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: selected ? theme.colors.menuSelection : null,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: iconScalePopup,
              child: Center(child: item.icon),
            ),
            if (showLabels) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.caption.copyWith(
                  color: active
                      ? theme.colors.foreground
                      : theme.colors.foregroundDisabled,
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: active,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: active
            ? () {
                onChanged!(item.value);
                close();
              }
            : null,
        child: content,
      ),
    );
  }

  Widget _popup(BuildContext context, VoidCallback close) {
    final theme = BlenderTheme.of(context);
    final tileHeight = showLabels ? iconScalePopup + 22 : iconScalePopup + 8;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
        ),
        child: SizedBox(
          width: 8 * (showLabels ? 64.0 : 52.0) + 10,
          child: GridView.builder(
            padding: const EdgeInsets.all(5),
            shrinkWrap: true,
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisExtent: tileHeight,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemBuilder: (context, index) =>
                _tile(context, items[index], close),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final trigger = BlenderButton(
      label: '',
      leading: selected?.icon ?? const BlenderIcon(BlenderGlyph.grid, size: 16),
      enabled: enabled && items.isNotEmpty && onChanged != null,
      onPressed: () {},
      variant: BlenderButtonVariant.toolbar,
      width: iconScale,
      padding: EdgeInsets.zero,
    );
    final semanticTrigger = Semantics(
      button: true,
      enabled: enabled && items.isNotEmpty && onChanged != null,
      label: selected?.label ?? 'Icon view',
      child: trigger,
    );
    if (!enabled || items.isEmpty || onChanged == null) return semanticTrigger;
    return BlenderPopover(
      child: IgnorePointer(child: semanticTrigger),
      popover: (context, close) => _popup(context, close),
    );
  }
}

/// A single operator-property box used by Blender's keymap-item template.
@immutable
class BlenderKeymapProperty {
  const BlenderKeymapProperty({
    required this.id,
    required this.label,
    required this.editor,
    this.isSet = true,
    this.enabled = true,
    this.onUnset,
  });

  final String id;
  final String label;
  final Widget editor;
  final bool isSet;
  final bool enabled;
  final VoidCallback? onUnset;
}

/// The two-column boxed operator-property anatomy from Blender's keymap
/// editor.  The widget deliberately accepts editor widgets rather than RNA
/// pointers so it can also represent custom keymap/operator data.
class BlenderKeymapItemProperties extends StatelessWidget {
  const BlenderKeymapItemProperties({
    super.key,
    required this.properties,
    this.title,
    this.columns = 2,
  });

  final List<BlenderKeymapProperty> properties;
  final String? title;
  final int columns;

  Widget _propertyBox(BuildContext context, BlenderKeymapProperty property) {
    final theme = BlenderTheme.of(context);
    final editor = Opacity(
      opacity: property.enabled && property.isSet ? 1 : .55,
      child: property.editor,
    );
    return BlenderBox(
      padding: const EdgeInsets.fromLTRB(6, 5, 4, 5),
      color: property.isSet
          ? theme.colors.panelSubSurface
          : theme.colors.panelSubSurface.withValues(alpha: .65),
      child: Row(
        children: <Widget>[
          Expanded(child: editor),
          if (property.isSet && property.onUnset != null)
            BlenderIconButton(
              glyph: BlenderGlyph.close,
              enabled: property.enabled,
              onPressed: property.enabled ? property.onUnset : null,
              tooltip: 'Unset ${property.label}',
              size: 21,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flow = LayoutBuilder(
      builder: (context, constraints) {
        const gap = 4.0;
        final effectiveColumns = columns.clamp(1, 4).toInt();
        final width = constraints.hasBoundedWidth
            ? ((constraints.maxWidth - gap * (effectiveColumns - 1)) /
                      effectiveColumns)
                  .clamp(180, 420)
                  .toDouble()
            : 220.0;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final property in properties)
              SizedBox(width: width, child: _propertyBox(context, property)),
          ],
        );
      },
    );
    final body = properties.isEmpty
        ? Text(
            'No operator properties',
            style: BlenderTheme.of(context).textTheme.caption.copyWith(
              color: BlenderTheme.of(context).colors.foregroundMuted,
            ),
          )
        : flow;
    return title == null ? body : BlenderPanel(title: title, child: body);
  }
}

/// A resizable material/texture preview property pane matching Blender's
/// `template_preview()` composition.
class BlenderPreviewPanel extends StatefulWidget {
  const BlenderPreviewPanel({
    super.key,
    required this.preview,
    this.title = 'Preview',
    this.height = 150,
    this.minHeight = 72,
    this.maxHeight = 360,
    this.previewModes = const <BlenderMenuItem<String>>[],
    this.previewMode,
    this.onPreviewModeChanged,
    this.usePreviewWorld = false,
    this.onUsePreviewWorldChanged,
    this.textureModes = const <BlenderMenuItem<String>>[],
    this.textureMode,
    this.onTextureModeChanged,
    this.usePreviewAlpha = false,
    this.onUsePreviewAlphaChanged,
  });

  final Widget preview;
  final String title;
  final double height;
  final double minHeight;
  final double maxHeight;
  final List<BlenderMenuItem<String>> previewModes;
  final String? previewMode;
  final ValueChanged<String>? onPreviewModeChanged;
  final bool usePreviewWorld;
  final ValueChanged<bool>? onUsePreviewWorldChanged;
  final List<BlenderMenuItem<String>> textureModes;
  final String? textureMode;
  final ValueChanged<String>? onTextureModeChanged;
  final bool usePreviewAlpha;
  final ValueChanged<bool>? onUsePreviewAlphaChanged;

  @override
  State<BlenderPreviewPanel> createState() => _BlenderPreviewPanelState();
}

class _BlenderPreviewPanelState extends State<BlenderPreviewPanel> {
  late double _height;

  @override
  void initState() {
    super.initState();
    _height = widget.height.clamp(widget.minHeight, widget.maxHeight);
  }

  @override
  void didUpdateWidget(BlenderPreviewPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.height != widget.height ||
        oldWidget.minHeight != widget.minHeight ||
        oldWidget.maxHeight != widget.maxHeight) {
      _height = widget.height.clamp(widget.minHeight, widget.maxHeight);
    }
  }

  void _resize(double delta) {
    setState(() {
      _height = (_height + delta).clamp(widget.minHeight, widget.maxHeight);
    });
  }

  Widget _previewSurface(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.textField,
        border: Border.all(color: theme.colors.editorBorder),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: SizedBox(
        height: _height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Center(child: widget.preview),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) => _resize(details.delta.dy),
                child: SizedBox(
                  height: 10,
                  child: Center(
                    child: BlenderIcon(
                      BlenderGlyph.dragHandle,
                      size: 14,
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls(BuildContext context) {
    final children = <Widget>[
      if (widget.previewModes.isNotEmpty && widget.previewMode != null)
        BlenderSegmentedControl<String>(
          value: widget.previewMode!,
          items: widget.previewModes,
          expanded: true,
          onChanged: widget.onPreviewModeChanged ?? (_) {},
        ),
      if (widget.onUsePreviewWorldChanged != null)
        BlenderCheckbox(
          value: widget.usePreviewWorld,
          label: 'Use Preview World',
          onChanged: widget.onUsePreviewWorldChanged,
        ),
      if (widget.textureModes.isNotEmpty && widget.textureMode != null)
        BlenderSegmentedControl<String>(
          value: widget.textureMode!,
          items: widget.textureModes,
          expanded: true,
          onChanged: widget.onTextureModeChanged ?? (_) {},
        ),
      if (widget.onUsePreviewAlphaChanged != null)
        BlenderCheckbox(
          value: widget.usePreviewAlpha,
          label: 'Use Preview Alpha',
          onChanged: widget.onUsePreviewAlphaChanged,
        ),
    ];
    return SizedBox(
      width: 230,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (var index = 0; index < children.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(height: 5),
            children[index],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: widget.title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: _previewSurface(context)),
          if (widget.previewModes.isNotEmpty ||
              widget.textureModes.isNotEmpty ||
              widget.onUsePreviewWorldChanged != null ||
              widget.onUsePreviewAlphaChanged != null) ...<Widget>[
            const SizedBox(width: 6),
            _controls(context),
          ],
        ],
      ),
    );
  }
}

/// Blender's transient report banner: a severity-colored icon segment joined
/// to a muted message segment that can open the Info editor.
class BlenderReportBanner extends StatelessWidget {
  const BlenderReportBanner({
    super.key,
    required this.message,
    this.level = BlenderNoticeLevel.info,
    this.onPressed,
    this.maxWidth = 800,
  });

  final String message;
  final BlenderNoticeLevel level;
  final VoidCallback? onPressed;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final color = switch (level) {
      BlenderNoticeLevel.info => theme.colors.info,
      BlenderNoticeLevel.success => theme.colors.success,
      BlenderNoticeLevel.warning => theme.colors.warning,
      BlenderNoticeLevel.error => theme.colors.error,
    };
    final glyph = switch (level) {
      BlenderNoticeLevel.info => BlenderGlyph.info,
      BlenderNoticeLevel.success => BlenderGlyph.checkCircle,
      BlenderNoticeLevel.warning => BlenderGlyph.warning,
      BlenderNoticeLevel.error => BlenderGlyph.error,
    };
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ColoredBox(
            color: color,
            child: SizedBox(
              width: 30,
              height: 26,
              child: Center(
                child: BlenderIcon(
                  glyph,
                  size: 16,
                  color: theme.colors.foreground,
                ),
              ),
            ),
          ),
          Flexible(
            child: ColoredBox(
              color: color.withValues(alpha: .22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  message,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.caption.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    final semantic = Semantics(
      container: true,
      button: onPressed != null,
      label: message,
      child: content,
    );
    return onPressed == null
        ? semantic
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: semantic,
          );
  }
}

/// The extension/update portion of Blender's status-info template.
enum BlenderExtensionStatus { hidden, offline, checking, updates }

/// A compact status-info strip matching `uiTemplateStatusInfo`.
///
/// Blender derives the text from the current file, scene, view layer, and
/// extension manager. This widget keeps those values as plain descriptors so
/// callers can reproduce the visual states without coupling the package to
/// Blender's runtime context.
class BlenderStatusInfo extends StatelessWidget {
  const BlenderStatusInfo({
    super.key,
    this.statusText,
    this.versionText,
    this.showVersion = true,
    this.extensionStatus = BlenderExtensionStatus.hidden,
    this.extensionCount = 0,
    this.onExtensionPressed,
    this.warningMessage,
    this.warningTooltip,
    this.onWarningPressed,
  });

  final String? statusText;
  final String? versionText;
  final bool showVersion;
  final BlenderExtensionStatus extensionStatus;
  final int extensionCount;
  final VoidCallback? onExtensionPressed;
  final String? warningMessage;
  final String? warningTooltip;
  final VoidCallback? onWarningPressed;

  Widget _separator(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('|', style: theme.textTheme.caption),
    );
  }

  Widget _extension(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final glyph = switch (extensionStatus) {
      BlenderExtensionStatus.offline => BlenderGlyph.linkBroken,
      BlenderExtensionStatus.checking => BlenderGlyph.refresh,
      BlenderExtensionStatus.updates => BlenderGlyph.info,
      BlenderExtensionStatus.hidden => BlenderGlyph.info,
    };
    final label = switch (extensionStatus) {
      BlenderExtensionStatus.offline => 'Extensions offline',
      BlenderExtensionStatus.checking => 'Checking extensions',
      BlenderExtensionStatus.updates => 'Extension updates',
      BlenderExtensionStatus.hidden => 'Extensions',
    };
    final icon = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        BlenderIcon(glyph, size: 15),
        if (extensionCount > 0)
          Positioned(
            right: -7,
            top: -6,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.accent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  '$extensionCount',
                  style: theme.textTheme.caption.copyWith(
                    color: theme.colors.foreground,
                    fontSize: 9,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    final button = Semantics(
      container: true,
      button: onExtensionPressed != null,
      label: label,
      child: BlenderButton(
        label: '',
        leading: icon,
        width: 24,
        enabled: onExtensionPressed != null,
        onPressed: onExtensionPressed,
        variant: BlenderButtonVariant.toolbar,
        padding: EdgeInsets.zero,
        showBorder: false,
      ),
    );
    return onExtensionPressed == null
        ? button
        : BlenderTooltip(message: label, child: button);
  }

  Widget _warning(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ColoredBox(
          color: theme.colors.warning,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: BlenderIcon(
              BlenderGlyph.warning,
              size: 14,
              color: theme.colors.foreground,
            ),
          ),
        ),
        Flexible(
          child: ColoredBox(
            color: theme.colors.warning.withValues(alpha: .22),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              child: Text(
                warningMessage!,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.caption.copyWith(
                  color: theme.colors.foreground,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    final semantic = Semantics(
      container: true,
      button: onWarningPressed != null,
      label: warningMessage,
      child: content,
    );
    final interactive = onWarningPressed == null
        ? semantic
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onWarningPressed,
            child: semantic,
          );
    final bounded = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160),
      child: interactive,
    );
    return warningTooltip == null
        ? bounded
        : BlenderTooltip(message: warningTooltip!, child: bounded);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (statusText != null && statusText!.isNotEmpty) {
      children.add(
        SizedBox(
          width: 200,
          child: Text(statusText!, overflow: TextOverflow.ellipsis),
        ),
      );
    }
    if (extensionStatus != BlenderExtensionStatus.hidden) {
      if (children.isNotEmpty) children.add(_separator(context));
      children.add(_extension(context));
    }
    if (showVersion && versionText != null && versionText!.isNotEmpty) {
      if (children.isNotEmpty) children.add(_separator(context));
      children.add(Text(versionText!));
    }
    if (warningMessage != null && warningMessage!.isNotEmpty) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 8));
      children.add(_warning(context));
    }
    return DefaultTextStyle(
      style: BlenderTheme.of(context).textTheme.caption,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}

/// The filename and execute/cancel side panel used by Blender's file
/// selector operator region.
class BlenderFileExecutionPanel extends StatelessWidget {
  const BlenderFileExecutionPanel({
    super.key,
    required this.filenameController,
    required this.onExecute,
    required this.onCancel,
    this.title = 'File Operation',
    this.executeLabel = 'Execute',
    this.overwriteAlert = false,
    this.onDecrement,
    this.onIncrement,
  });

  final TextEditingController filenameController;
  final VoidCallback? onExecute;
  final VoidCallback? onCancel;
  final String title;
  final String executeLabel;
  final bool overwriteAlert;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: BlenderTextField(
                  controller: filenameController,
                  placeholder: 'File name',
                  backgroundColor: overwriteAlert
                      ? theme.colors.warning.withValues(alpha: .16)
                      : null,
                ),
              ),
              if (onDecrement != null)
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  onPressed: onDecrement,
                  tooltip: 'Previous file name',
                  size: 24,
                ),
              if (onIncrement != null)
                BlenderIconButton(
                  glyph: BlenderGlyph.plus,
                  onPressed: onIncrement,
                  tooltip: 'Next file name',
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              BlenderButton(
                label: 'Cancel',
                onPressed: onCancel,
                enabled: onCancel != null,
                variant: BlenderButtonVariant.regular,
              ),
              const SizedBox(width: 6),
              BlenderButton(
                label: overwriteAlert ? 'Overwrite' : executeLabel,
                onPressed: onExecute,
                enabled: onExecute != null,
                selected: overwriteAlert,
                variant: BlenderButtonVariant.regular,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The active operator-property pane shown beside Blender's file selector.
/// File-path, directory, filename, and file-list RNA fields are intentionally
/// omitted by the caller because Blender owns those in the execution pane.
class BlenderFileOperatorPanel extends StatelessWidget {
  const BlenderFileOperatorPanel({
    super.key,
    required this.operatorName,
    required this.properties,
    this.enabled = true,
    this.initiallyExpanded = true,
  });

  final String operatorName;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final bool enabled;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: operatorName,
      collapsible: true,
      initiallyExpanded: initiallyExpanded,
      child: Opacity(
        opacity: enabled ? 1 : .5,
        child: _buildOperatorProperties(context, properties),
      ),
    );
  }
}

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

/// A user-preference asset-library descriptor.
@immutable
class BlenderAssetLibraryPreference {
  const BlenderAssetLibraryPreference({
    required this.id,
    required this.name,
    this.path = '',
    this.remoteUrl = '',
    this.isRemote = false,
    this.isEssentials = false,
    this.builtIn = false,
    this.enabled = true,
    this.invalid = false,
    this.importMethod = 'Link',
    this.useRelativePath = false,
    this.includeOnlineEssentials = false,
  });

  final String id;
  final String name;
  final String path;
  final String remoteUrl;
  final bool isRemote;
  final bool isEssentials;
  final bool builtIn;
  final bool enabled;
  final bool invalid;
  final String importMethod;
  final bool useRelativePath;
  final bool includeOnlineEssentials;
}

/// Blender Preferences' Asset Libraries panel.
class BlenderAssetLibrariesPreferencesPanel extends StatefulWidget {
  const BlenderAssetLibrariesPreferencesPanel({
    super.key,
    required this.libraries,
    this.selectedId,
    this.onSelected,
    this.onEnabledChanged,
    this.onPathChanged,
    this.onImportMethodChanged,
    this.onRelativePathChanged,
    this.onIncludeOnlineEssentialsChanged,
    this.onAdd,
    this.onRemove,
    this.libraryListHeight = 140,
    this.title = 'Asset Libraries',
  });

  final List<BlenderAssetLibraryPreference> libraries;
  final String? selectedId;
  final ValueChanged<BlenderAssetLibraryPreference>? onSelected;
  final void Function(BlenderAssetLibraryPreference, bool)? onEnabledChanged;
  final void Function(BlenderAssetLibraryPreference, String)? onPathChanged;
  final void Function(BlenderAssetLibraryPreference, String)?
  onImportMethodChanged;
  final void Function(BlenderAssetLibraryPreference, bool)?
  onRelativePathChanged;
  final ValueChanged<bool>? onIncludeOnlineEssentialsChanged;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final double libraryListHeight;
  final String title;

  @override
  State<BlenderAssetLibrariesPreferencesPanel> createState() =>
      _BlenderAssetLibrariesPreferencesPanelState();
}

class _BlenderAssetLibrariesPreferencesPanelState
    extends State<BlenderAssetLibrariesPreferencesPanel> {
  final Map<String, TextEditingController> _pathControllers =
      <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(BlenderAssetLibrariesPreferencesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  void _syncControllers() {
    final ids = widget.libraries.map((library) => library.id).toSet();
    for (final id in _pathControllers.keys.toList()) {
      if (!ids.contains(id)) _pathControllers.remove(id)?.dispose();
    }
    for (final library in widget.libraries) {
      final controller = _pathControllers.putIfAbsent(
        library.id,
        () => TextEditingController(),
      );
      final text = library.isRemote ? library.remoteUrl : library.path;
      if (controller.text != text) controller.text = text;
    }
  }

  @override
  void dispose() {
    for (final controller in _pathControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  BlenderAssetLibraryPreference? get _selected {
    for (final library in widget.libraries) {
      if (library.id == widget.selectedId) return library;
    }
    return widget.libraries.isEmpty ? null : widget.libraries.first;
  }

  Widget _libraryRow(
    BuildContext context,
    BlenderAssetLibraryPreference library,
  ) {
    final theme = BlenderTheme.of(context);
    final selected = library.id == (_selected?.id ?? widget.selectedId);
    final icon = library.isRemote
        ? BlenderGlyph.internet
        : BlenderGlyph.diskDrive;
    return Semantics(
      selected: selected,
      button: widget.onSelected != null,
      label: library.name,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onSelected == null
            ? null
            : () => widget.onSelected!(library),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? theme.colors.selection : null,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: Row(
              children: <Widget>[
                BlenderIcon(
                  icon,
                  size: 14,
                  color: library.isRemote
                      ? theme.colors.accentHover
                      : theme.colors.iconFolder,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    library.name,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.label.copyWith(
                      color: library.builtIn
                          ? theme.colors.foregroundMuted
                          : theme.colors.foreground,
                    ),
                  ),
                ),
                if (library.builtIn)
                  Text(
                    'Built-In',
                    style: theme.textTheme.caption.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                if (library.invalid)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: BlenderIcon(
                      BlenderGlyph.error,
                      size: 14,
                      color: theme.colors.error,
                    ),
                  ),
                if (!library.builtIn && widget.onEnabledChanged != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: BlenderCheckbox(
                      value: library.enabled,
                      onChanged: (value) =>
                          widget.onEnabledChanged!(library, value),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _settings(
    BuildContext context,
    BlenderAssetLibraryPreference library,
  ) {
    final controller = _pathControllers[library.id];
    final pathLabel = library.isRemote ? 'URL' : 'Path';
    final importItems = <BlenderMenuItem<String>>[
      if (!library.isRemote)
        const BlenderMenuItem<String>(value: 'Link', label: 'Link'),
      const BlenderMenuItem<String>(value: 'Append', label: 'Append'),
      const BlenderMenuItem<String>(
        value: 'Append (Reuse Data)',
        label: 'Append (Reuse Data)',
      ),
      const BlenderMenuItem<String>(value: 'Pack', label: 'Pack'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (library.isEssentials)
          BlenderCheckbox(
            value: library.includeOnlineEssentials,
            label: 'Include Online Essentials',
            onChanged: widget.onIncludeOnlineEssentialsChanged,
          ),
        if (controller != null && !library.builtIn)
          BlenderTextField(
            controller: controller,
            label: pathLabel,
            onChanged: (value) => widget.onPathChanged?.call(library, value),
            trailing: library.invalid
                ? BlenderIcon(
                    BlenderGlyph.error,
                    size: 14,
                    color: BlenderTheme.of(context).colors.error,
                  )
                : null,
            backgroundColor: library.invalid
                ? BlenderTheme.of(context).colors.warning.withValues(alpha: .16)
                : null,
          ),
        if (!library.builtIn) ...<Widget>[
          const SizedBox(height: 5),
          BlenderPropertyRow(
            label: 'Default Import Method',
            editor: BlenderDropdown<String>(
              value:
                  importItems.any((item) => item.value == library.importMethod)
                  ? library.importMethod
                  : importItems.first.value,
              items: importItems,
              onChanged: widget.onImportMethodChanged == null
                  ? null
                  : (value) => widget.onImportMethodChanged!(library, value),
            ),
          ),
          if (!library.isRemote)
            BlenderPropertyRow(
              label: 'Relative Path',
              editor: BlenderCheckbox(
                value: library.useRelativePath,
                label: '',
                onChanged: widget.onRelativePathChanged == null
                    ? null
                    : (value) => widget.onRelativePathChanged!(library, value),
              ),
            ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return BlenderPanel(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: widget.libraryListHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: BlenderBox(
                    padding: EdgeInsets.zero,
                    child: ListView.builder(
                      itemCount: widget.libraries.length,
                      itemExtent: 28,
                      itemBuilder: (context, index) =>
                          _libraryRow(context, widget.libraries[index]),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    BlenderIconButton(
                      glyph: BlenderGlyph.plus,
                      onPressed: widget.onAdd,
                      tooltip: 'Add asset library',
                      size: 24,
                    ),
                    BlenderIconButton(
                      glyph: BlenderGlyph.minus,
                      onPressed: widget.onRemove,
                      tooltip: 'Remove asset library',
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (selected != null) ...<Widget>[
            const SizedBox(height: 8),
            _settings(context, selected),
          ],
        ],
      ),
    );
  }
}

/// A texture source shown by Blender's Properties texture-user template.
@immutable
class BlenderTextureUser {
  const BlenderTextureUser({
    required this.id,
    required this.name,
    this.textureName,
    this.category,
    this.icon = BlenderGlyph.texture,
    this.enabled = true,
  });

  final String id;
  final String name;
  final String? textureName;
  final String? category;
  final BlenderGlyph icon;
  final bool enabled;
}

/// Blender's texture-user menu plus the adjacent Properties-tab jump button.
class BlenderTextureUserSelector extends StatelessWidget {
  const BlenderTextureUserSelector({
    super.key,
    required this.users,
    this.selectedId,
    this.onChanged,
    this.onShowTexture,
    this.showTextureEnabled = true,
    this.noUsersLabel = 'No textures in context',
  });

  final List<BlenderTextureUser> users;
  final String? selectedId;
  final ValueChanged<BlenderTextureUser>? onChanged;
  final VoidCallback? onShowTexture;
  final bool showTextureEnabled;
  final String noUsersLabel;

  List<BlenderMenuItem<String>> _menuItems() {
    final items = <BlenderMenuItem<String>>[];
    String? lastCategory;
    for (final user in users) {
      final category = user.category;
      if (category != null && category != lastCategory) {
        items.add(
          BlenderMenuItem<String>(
            value: '__texture_category_$category',
            label: category,
            enabled: false,
          ),
        );
        lastCategory = category;
      }
      items.add(
        BlenderMenuItem<String>(
          value: user.id,
          label: user.textureName == null
              ? user.name
              : '${user.name} - ${user.textureName}',
          icon: BlenderIcon(user.icon, size: 14),
          enabled: user.enabled,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Text(
        noUsersLabel,
        style: BlenderTheme.of(context).textTheme.caption.copyWith(
          color: BlenderTheme.of(context).colors.foregroundMuted,
        ),
      );
    }

    return Row(
      children: <Widget>[
        Expanded(
          child: BlenderDropdown<String>(
            value: selectedId ?? users.first.id,
            items: _menuItems(),
            onChanged: onChanged == null
                ? null
                : (id) {
                    for (final user in users) {
                      if (user.id == id) {
                        onChanged!(user);
                        return;
                      }
                    }
                  },
          ),
        ),
        if (onShowTexture != null) ...<Widget>[
          const SizedBox(width: 4),
          BlenderIconButton(
            glyph: BlenderGlyph.properties,
            onPressed: showTextureEnabled ? onShowTexture : null,
            enabled: showTextureEnabled,
            tooltip: showTextureEnabled
                ? 'Show texture in Texture tab'
                : 'No texture user available',
            size: 24,
          ),
        ],
      ],
    );
  }
}

/// A caller-owned input/status item matching Blender's inline event-and-label
/// rows used for area actions, headers, modal operators, and viewport warnings.
@immutable
class BlenderInputStatusItem {
  const BlenderInputStatusItem({
    required this.label,
    this.event,
    this.events = const <String>[],
    this.dragEvent,
    this.modifiers = const <String>[],
    this.dragModifiers = const <String>[],
    this.icon,
    this.warning = false,
    this.enabled = true,
  });

  final String label;
  final String? event;
  final List<String> events;
  final String? dragEvent;
  final List<String> modifiers;
  final List<String> dragModifiers;
  final BlenderGlyph? icon;
  final bool warning;
  final bool enabled;
}

/// Runtime contexts selected by Blender's `uiTemplateInputStatus()` source.
enum BlenderStatusContextKind {
  workspace,
  modal,
  splitDock,
  resizeQuadrants,
  resizeRegion,
  editorBorder,
  header,
  viewportWarning,
  cursor,
}

/// The source-derived status-bar composition around [BlenderInputStatus].
///
/// Blender chooses this context from the active area, region, action zone, and
/// modal keymap. The host supplies those runtime decisions; this widget keeps
/// the visible labels, mouse glyphs, modifiers, and warning treatment in one
/// reusable surface.
class BlenderStatusContextBar extends StatelessWidget {
  const BlenderStatusContextBar({
    super.key,
    required this.kind,
    this.items = const <BlenderInputStatusItem>[],
    this.warningText,
    this.regionVisible = true,
    this.backgroundColor,
    this.showBorder = true,
  });

  final BlenderStatusContextKind kind;
  final List<BlenderInputStatusItem> items;
  final String? warningText;
  final bool regionVisible;
  final Color? backgroundColor;
  final bool showBorder;

  List<BlenderInputStatusItem> _defaultItems() {
    switch (kind) {
      case BlenderStatusContextKind.splitDock:
        return const <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: 'Split/Dock',
            icon: BlenderGlyph.mouseLeftDrag,
          ),
          BlenderInputStatusItem(
            label: 'Duplicate into Window',
            modifiers: <String>['Shift'],
            icon: BlenderGlyph.mouseLeftDrag,
          ),
          BlenderInputStatusItem(
            label: 'Swap Areas',
            modifiers: <String>['Ctrl'],
            icon: BlenderGlyph.mouseLeftDrag,
          ),
        ];
      case BlenderStatusContextKind.resizeQuadrants:
        return const <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: 'Resize Quadrants',
            icon: BlenderGlyph.mouseLeftDrag,
          ),
        ];
      case BlenderStatusContextKind.resizeRegion:
        return <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: regionVisible ? 'Resize Region' : 'Show Hidden Region',
            icon: BlenderGlyph.mouseLeftDrag,
          ),
        ];
      case BlenderStatusContextKind.editorBorder:
        return const <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: 'Resize',
            icon: BlenderGlyph.mouseLeftDrag,
          ),
          BlenderInputStatusItem(
            label: 'Options',
            icon: BlenderGlyph.mouseRight,
          ),
        ];
      case BlenderStatusContextKind.header:
        return const <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: 'Pan',
            icon: BlenderGlyph.mouseMiddleDrag,
          ),
          BlenderInputStatusItem(
            label: 'Options',
            icon: BlenderGlyph.mouseRight,
          ),
        ];
      case BlenderStatusContextKind.viewportWarning:
        return <BlenderInputStatusItem>[
          BlenderInputStatusItem(
            label: warningText ?? 'Active object has negative scale',
            icon: BlenderGlyph.warning,
            warning: true,
          ),
        ];
      case BlenderStatusContextKind.workspace:
      case BlenderStatusContextKind.modal:
      case BlenderStatusContextKind.cursor:
        return items;
    }
  }

  Widget _workspace(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colors.canvas,
        border: showBorder
            ? Border.all(color: theme.colors.editorBorder)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: <Widget>[
            for (final item in items)
              Semantics(
                label: item.label,
                enabled: item.enabled,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (item.icon != null)
                      BlenderIcon(
                        item.icon!,
                        size: 14,
                        color: item.warning ? theme.colors.warning : null,
                      ),
                    if (item.icon != null) const SizedBox(width: 4),
                    Text(
                      item.label,
                      style: theme.textTheme.caption.copyWith(
                        color: item.warning
                            ? theme.colors.warning
                            : item.enabled
                            ? theme.colors.foregroundMuted
                            : theme.colors.foregroundDisabled,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kind == BlenderStatusContextKind.workspace) return _workspace(context);
    return BlenderInputStatus(
      items: _defaultItems(),
      backgroundColor: backgroundColor,
      showBorder: showBorder,
    );
  }
}

/// Blender's compact context-sensitive input-status row. The widget is
/// intentionally data-driven because Blender chooses its items from the
/// active area, region, action zone, and modal keymap.
class BlenderInputStatus extends StatelessWidget {
  const BlenderInputStatus({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    this.backgroundColor,
    this.showBorder = true,
  });

  final List<BlenderInputStatusItem> items;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final bool showBorder;

  Widget _token(BuildContext context, String label, bool enabled) {
    return Opacity(opacity: enabled ? 1 : .5, child: BlenderKeycap(label));
  }

  Widget _item(BuildContext context, BlenderInputStatusItem item) {
    final theme = BlenderTheme.of(context);
    final tokens = <Widget>[
      for (final modifier in item.modifiers)
        _token(context, modifier, item.enabled),
      if (item.events.isNotEmpty)
        for (final event in item.events) _token(context, event, item.enabled)
      else if (item.event != null)
        _token(context, item.event!, item.enabled),
      if (item.icon != null)
        BlenderIcon(
          item.icon!,
          size: 14,
          color: item.warning ? theme.colors.warning : null,
        ),
      Text(
        item.label,
        style: theme.textTheme.caption.copyWith(
          color: item.warning
              ? theme.colors.warning
              : item.enabled
              ? theme.colors.foregroundMuted
              : theme.colors.foregroundDisabled,
        ),
      ),
      if (item.dragEvent != null) ...<Widget>[
        const SizedBox(width: 3),
        for (final modifier in item.dragModifiers)
          _token(context, modifier, item.enabled),
        _token(context, item.dragEvent!, item.enabled),
      ],
    ];
    return Semantics(
      label: item.label,
      enabled: item.enabled,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (var index = 0; index < tokens.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(width: 3),
            tokens[index],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colors.canvas,
        border: showBorder
            ? Border.all(color: theme.colors.editorBorder)
            : null,
      ),
      child: Padding(
        padding: padding,
        child: Wrap(
          spacing: 10,
          runSpacing: 4,
          children: <Widget>[for (final item in items) _item(context, item)],
        ),
      ),
    );
  }
}

/// Data for Blender's cache-file template and its compact time settings.
@immutable
class BlenderCacheFileSettings {
  const BlenderCacheFileSettings({
    this.path = '',
    this.manualScale = 1,
    this.showManualScale = true,
    this.isSequence = false,
    this.overrideFrame = false,
    this.frame = 1,
    this.frameOffset = 0,
    this.velocityName = '',
    this.velocityUnit = 'Frame',
  });

  final String path;
  final double manualScale;
  final bool showManualScale;
  final bool isSequence;
  final bool overrideFrame;
  final double frame;
  final double frameOffset;
  final String velocityName;
  final String velocityUnit;

  BlenderCacheFileSettings copyWith({
    String? path,
    double? manualScale,
    bool? showManualScale,
    bool? isSequence,
    bool? overrideFrame,
    double? frame,
    double? frameOffset,
    String? velocityName,
    String? velocityUnit,
  }) {
    return BlenderCacheFileSettings(
      path: path ?? this.path,
      manualScale: manualScale ?? this.manualScale,
      showManualScale: showManualScale ?? this.showManualScale,
      isSequence: isSequence ?? this.isSequence,
      overrideFrame: overrideFrame ?? this.overrideFrame,
      frame: frame ?? this.frame,
      frameOffset: frameOffset ?? this.frameOffset,
      velocityName: velocityName ?? this.velocityName,
      velocityUnit: velocityUnit ?? this.velocityUnit,
    );
  }
}

/// Cache-file path, reload, scale, time, and velocity property panels.
class BlenderCacheFilePanel extends StatefulWidget {
  const BlenderCacheFilePanel({
    super.key,
    required this.settings,
    required this.onChanged,
    this.onBrowse,
    this.onReload,
    this.title = 'Cache File',
  });

  final BlenderCacheFileSettings settings;
  final ValueChanged<BlenderCacheFileSettings> onChanged;
  final VoidCallback? onBrowse;
  final VoidCallback? onReload;
  final String title;

  @override
  State<BlenderCacheFilePanel> createState() => _BlenderCacheFilePanelState();
}

class _BlenderCacheFilePanelState extends State<BlenderCacheFilePanel> {
  late final TextEditingController _pathController;
  late final TextEditingController _velocityController;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(text: widget.settings.path);
    _velocityController = TextEditingController(
      text: widget.settings.velocityName,
    );
  }

  @override
  void didUpdateWidget(BlenderCacheFilePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.path != widget.settings.path &&
        _pathController.text != widget.settings.path) {
      _pathController.value = TextEditingValue(
        text: widget.settings.path,
        selection: TextSelection.collapsed(offset: widget.settings.path.length),
      );
    }
    if (oldWidget.settings.velocityName != widget.settings.velocityName &&
        _velocityController.text != widget.settings.velocityName) {
      _velocityController.value = TextEditingValue(
        text: widget.settings.velocityName,
        selection: TextSelection.collapsed(
          offset: widget.settings.velocityName.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    _velocityController.dispose();
    super.dispose();
  }

  void _change(BlenderCacheFileSettings next) => widget.onChanged(next);

  Widget _propertyRow(String label, Widget child) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: Text(label)),
        const SizedBox(width: 8),
        Expanded(flex: 2, child: child),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    return BlenderPanel(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: BlenderTextField(
                  controller: _pathController,
                  placeholder: 'Cache file path',
                  onChanged: (value) => _change(settings.copyWith(path: value)),
                ),
              ),
              const SizedBox(width: 4),
              BlenderIconButton(
                glyph: BlenderGlyph.refresh,
                onPressed: widget.onReload,
                tooltip: 'Reload cache file',
                size: 24,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.folder,
                onPressed: widget.onBrowse,
                tooltip: 'Browse cache file',
                size: 24,
              ),
            ],
          ),
          if (settings.showManualScale) ...<Widget>[
            const SizedBox(height: 6),
            _propertyRow(
              'Manual Scale',
              BlenderNumberField(
                value: settings.manualScale,
                min: 0,
                step: .01,
                onChanged: (value) =>
                    _change(settings.copyWith(manualScale: value)),
              ),
            ),
          ],
          const SizedBox(height: 8),
          BlenderPanel(
            title: 'Time Settings',
            collapsible: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                BlenderCheckbox(
                  value: settings.isSequence,
                  label: 'Sequence',
                  onChanged: (value) =>
                      _change(settings.copyWith(isSequence: value)),
                ),
                const SizedBox(height: 5),
                BlenderCheckbox(
                  value: settings.overrideFrame,
                  label: 'Override Frame',
                  onChanged: (value) =>
                      _change(settings.copyWith(overrideFrame: value)),
                ),
                const SizedBox(height: 5),
                _propertyRow(
                  'Frame',
                  BlenderNumberField(
                    value: settings.frame,
                    decimalDigits: 0,
                    enabled: settings.overrideFrame,
                    onChanged: (value) =>
                        _change(settings.copyWith(frame: value)),
                  ),
                ),
                const SizedBox(height: 5),
                _propertyRow(
                  'Frame Offset',
                  BlenderNumberField(
                    value: settings.frameOffset,
                    decimalDigits: 0,
                    onChanged: (value) =>
                        _change(settings.copyWith(frameOffset: value)),
                  ),
                ),
              ],
            ),
          ),
          if (settings.velocityName.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            BlenderPanel(
              title: 'Velocity',
              collapsible: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _propertyRow(
                    'Name',
                    BlenderTextField(
                      controller: _velocityController,
                      onChanged: (value) =>
                          _change(settings.copyWith(velocityName: value)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _propertyRow(
                    'Unit',
                    BlenderDropdown<String>(
                      value: settings.velocityUnit,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
                        BlenderMenuItem<String>(
                          value: 'Second',
                          label: 'Second',
                        ),
                      ],
                      onChanged: (value) =>
                          _change(settings.copyWith(velocityUnit: value)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

enum BlenderLightLinkingState { include, exclude }

/// A row in Blender's light-linking collection tree.
@immutable
class BlenderLightLinkingItem {
  const BlenderLightLinkingItem({
    required this.id,
    required this.label,
    this.icon = BlenderGlyph.object,
    this.state = BlenderLightLinkingState.include,
    this.enabled = true,
    this.onStateChanged,
  });

  final String id;
  final String label;
  final BlenderGlyph icon;
  final BlenderLightLinkingState state;
  final bool enabled;
  final ValueChanged<BlenderLightLinkingState>? onStateChanged;
}

/// A compact collection tree with include/exclude state buttons.
class BlenderLightLinkingCollection extends StatefulWidget {
  const BlenderLightLinkingCollection({
    super.key,
    required this.items,
    this.title = 'Light Linking',
    this.collectionLabel = 'Linking Collection',
    this.emptyLabel = 'No linked objects or collections',
  });

  final List<BlenderLightLinkingItem> items;
  final String title;
  final String collectionLabel;
  final String emptyLabel;

  @override
  State<BlenderLightLinkingCollection> createState() =>
      _BlenderLightLinkingCollectionState();
}

class _BlenderLightLinkingCollectionState
    extends State<BlenderLightLinkingCollection> {
  late final TextEditingController _collectionController;

  @override
  void initState() {
    super.initState();
    _collectionController = TextEditingController(text: widget.collectionLabel);
  }

  @override
  void didUpdateWidget(BlenderLightLinkingCollection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collectionLabel != widget.collectionLabel &&
        _collectionController.text != widget.collectionLabel) {
      _collectionController.text = widget.collectionLabel;
    }
  }

  @override
  void dispose() {
    _collectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          BlenderTextField(
            controller: _collectionController,
            readOnly: true,
            leading: const BlenderIcon(BlenderGlyph.collection, size: 14),
          ),
          const SizedBox(height: 5),
          if (widget.items.isEmpty)
            Text(
              widget.emptyLabel,
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            )
          else
            for (final item in widget.items)
              SizedBox(
                height: theme.density.rowHeight,
                child: Row(
                  children: <Widget>[
                    BlenderIcon(item.icon, size: 15),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.label.copyWith(
                          color: item.enabled
                              ? theme.colors.foreground
                              : theme.colors.foregroundDisabled,
                        ),
                      ),
                    ),
                    BlenderCheckbox(
                      value: item.state == BlenderLightLinkingState.include,
                      enabled: item.enabled,
                      onChanged: item.onStateChanged == null
                          ? null
                          : (include) => item.onStateChanged!(
                              include
                                  ? BlenderLightLinkingState.include
                                  : BlenderLightLinkingState.exclude,
                            ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// A nested Grease Pencil layer/group descriptor.
@immutable
class BlenderGreasePencilLayer {
  const BlenderGreasePencilLayer({
    required this.id,
    required this.name,
    this.children = const <BlenderGreasePencilLayer>[],
    this.isGroup = false,
    this.active = false,
    this.initiallyExpanded = true,
    this.useMasks = false,
    this.useOnionSkinning = false,
    this.hidden = false,
    this.locked = false,
    this.enabled = true,
    this.onActivate,
    this.onMasksChanged,
    this.onOnionSkinningChanged,
    this.onHiddenChanged,
    this.onLockedChanged,
  });

  final String id;
  final String name;
  final List<BlenderGreasePencilLayer> children;
  final bool isGroup;
  final bool active;
  final bool initiallyExpanded;
  final bool useMasks;
  final bool useOnionSkinning;
  final bool hidden;
  final bool locked;
  final bool enabled;
  final VoidCallback? onActivate;
  final ValueChanged<bool>? onMasksChanged;
  final ValueChanged<bool>? onOnionSkinningChanged;
  final ValueChanged<bool>? onHiddenChanged;
  final ValueChanged<bool>? onLockedChanged;
}

class BlenderGreasePencilLayerTree extends StatefulWidget {
  const BlenderGreasePencilLayerTree({
    super.key,
    required this.layers,
    this.searchController,
    this.title = 'Grease Pencil Layers',
    this.emptyLabel = 'No layers',
  });

  final List<BlenderGreasePencilLayer> layers;
  final TextEditingController? searchController;
  final String title;
  final String emptyLabel;

  @override
  State<BlenderGreasePencilLayerTree> createState() =>
      _BlenderGreasePencilLayerTreeState();
}

class _BlenderGreasePencilLayerTreeState
    extends State<BlenderGreasePencilLayerTree> {
  late Set<String> _expanded = _initialExpanded(widget.layers);
  late final TextEditingController _emptySearchController;

  @override
  void initState() {
    super.initState();
    _emptySearchController = TextEditingController();
  }

  static Set<String> _initialExpanded(List<BlenderGreasePencilLayer> layers) {
    final expanded = <String>{};
    void visit(BlenderGreasePencilLayer layer) {
      if (layer.isGroup && layer.initiallyExpanded) expanded.add(layer.id);
      for (final child in layer.children) {
        visit(child);
      }
    }

    for (final layer in layers) {
      visit(layer);
    }
    return expanded;
  }

  @override
  void didUpdateWidget(BlenderGreasePencilLayerTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    _expanded = <String>{..._expanded, ..._initialExpanded(widget.layers)};
  }

  @override
  void dispose() {
    _emptySearchController.dispose();
    super.dispose();
  }

  List<_GreasePencilVisibleLayer> _flatten(
    List<BlenderGreasePencilLayer> layers,
    String query,
  ) {
    final result = <_GreasePencilVisibleLayer>[];
    void visit(BlenderGreasePencilLayer layer, int depth) {
      final matches =
          query.isEmpty ||
          layer.name.toLowerCase().contains(query.toLowerCase());
      if (matches) result.add(_GreasePencilVisibleLayer(layer, depth));
      if (query.isEmpty || _expanded.contains(layer.id)) {
        for (final child in layer.children) {
          visit(child, depth + 1);
        }
      }
    }

    for (final layer in layers) {
      visit(layer, 0);
    }
    return result;
  }

  Widget _restrictionButton({
    required BlenderGlyph glyph,
    required bool selected,
    required bool enabled,
    required ValueChanged<bool>? onChanged,
    required String tooltip,
  }) {
    return BlenderIconButton(
      glyph: glyph,
      selected: selected,
      enabled: enabled,
      onPressed: onChanged == null ? null : () => onChanged(!selected),
      tooltip: tooltip,
      size: 21,
    );
  }

  Widget _row(BuildContext context, _GreasePencilVisibleLayer visible) {
    final theme = BlenderTheme.of(context);
    final layer = visible.layer;
    final expandable = layer.isGroup && layer.children.isNotEmpty;
    final indent = 8.0 + visible.depth * 14;
    return SizedBox(
      height: theme.density.rowHeight,
      child: Row(
        children: <Widget>[
          SizedBox(width: indent),
          if (expandable)
            BlenderDisclosureButton(
              expanded: _expanded.contains(layer.id),
              onPressed: () => setState(() {
                if (_expanded.contains(layer.id)) {
                  _expanded.remove(layer.id);
                } else {
                  _expanded.add(layer.id);
                }
              }),
              size: 18,
              tooltip: 'Expand ${layer.name}',
            )
          else
            const SizedBox(width: 18),
          GestureDetector(
            onTap: layer.enabled ? layer.onActivate : null,
            child: Row(
              children: <Widget>[
                BlenderIcon(
                  layer.isGroup ? BlenderGlyph.collection : BlenderGlyph.object,
                  size: 15,
                  color: layer.active ? theme.colors.accentHover : null,
                ),
                const SizedBox(width: 5),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: layer.enabled ? layer.onActivate : null,
              child: Text(
                layer.name,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.label.copyWith(
                  color: layer.enabled
                      ? theme.colors.foreground
                      : theme.colors.foregroundDisabled,
                ),
              ),
            ),
          ),
          _restrictionButton(
            glyph: BlenderGlyph.link,
            selected: layer.useMasks,
            enabled: layer.enabled,
            onChanged: layer.onMasksChanged,
            tooltip: 'Use masks',
          ),
          _restrictionButton(
            glyph: BlenderGlyph.color,
            selected: layer.useOnionSkinning,
            enabled: layer.enabled,
            onChanged: layer.onOnionSkinningChanged,
            tooltip: 'Use onion skinning',
          ),
          _restrictionButton(
            glyph: BlenderGlyph.eye,
            selected: !layer.hidden,
            enabled: layer.enabled,
            onChanged: layer.onHiddenChanged == null
                ? null
                : (visible) => layer.onHiddenChanged!(!visible),
            tooltip: 'Show layer',
          ),
          _restrictionButton(
            glyph: BlenderGlyph.lock,
            selected: !layer.locked,
            enabled: layer.enabled,
            onChanged: layer.onLockedChanged == null
                ? null
                : (visible) => layer.onLockedChanged!(!visible),
            tooltip: 'Unlock layer',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final search = widget.searchController;
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (search != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
              child: BlenderSearchField(
                controller: search,
                placeholder: 'Search layers',
              ),
            ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: search ?? _emptySearchController,
            builder: (context, value, child) {
              final rows = _flatten(widget.layers, value.text.trim());
              if (rows.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    widget.emptyLabel,
                    style: BlenderTheme.of(context).textTheme.caption,
                  ),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[for (final row in rows) _row(context, row)],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _GreasePencilVisibleLayer {
  const _GreasePencilVisibleLayer(this.layer, this.depth);

  final BlenderGreasePencilLayer layer;
  final int depth;
}
