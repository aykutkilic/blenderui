import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/material.dart';

import '../model/workbook_plot_cell.dart';
import '../plot/plot_model.dart';
import 'workbook_palette.dart';

/// Document editor for a variable-backed interactive plot cell.
final class WorkbookPlotCellEditor extends StatefulWidget {
  const WorkbookPlotCellEditor({
    required this.configuration,
    required this.availableVariables,
    required this.active,
    required this.onActivate,
    required this.onChanged,
    super.key,
  });

  final WorkbookPlotCellConfiguration configuration;
  final List<String> availableVariables;
  final bool active;
  final VoidCallback onActivate;
  final ValueChanged<WorkbookPlotCellConfiguration> onChanged;

  @override
  State<WorkbookPlotCellEditor> createState() => _WorkbookPlotCellEditorState();
}

final class _WorkbookPlotCellEditorState extends State<WorkbookPlotCellEditor> {
  static const _implicitIndex = '__blenderui_index__';
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.configuration.title);
  }

  @override
  void didUpdateWidget(covariant WorkbookPlotCellEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.configuration.title != _titleController.text) {
      _titleController.text = widget.configuration.title;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = WorkbookPalette.of(context);
    if (!widget.active) {
      final x = widget.configuration.xVariable ?? 'sample index';
      final y = widget.configuration.yVariables.isEmpty
          ? 'no Y variable selected'
          : widget.configuration.yVariables.join(', ');
      return InkWell(
        onTap: widget.onActivate,
        child: SizedBox(
          height: 76,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.configuration.title,
                  style: TextStyle(
                    color: palette.foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${_kindLabel(widget.configuration.kind)} · X: $x · Y: $y',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: palette.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return ColoredBox(
      color: palette.elevated,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: BlenderTextField(
                    controller: _titleController,
                    label: 'Plot title',
                    placeholder: 'Variable plot',
                    onChanged: (value) => widget.onChanged(
                      widget.configuration.copyWith(title: value),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BlenderDropdown<WorkbookPlotKind>(
                    value: widget.configuration.kind,
                    selectedLabel: _kindLabel(widget.configuration.kind),
                    items: <BlenderMenuItem<WorkbookPlotKind>>[
                      for (final kind in workbookVariablePlotKinds)
                        BlenderMenuItem<WorkbookPlotKind>(
                          value: kind,
                          label: _kindLabel(kind),
                        ),
                    ],
                    onChanged: (kind) => widget.onChanged(
                      widget.configuration.copyWith(kind: kind),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BlenderDropdown<String>(
                    value: widget.configuration.xVariable ?? _implicitIndex,
                    selectedLabel: widget.configuration.xVariable == null
                        ? 'X: sample index'
                        : 'X: ${widget.configuration.xVariable}',
                    items: <BlenderMenuItem<String>>[
                      const BlenderMenuItem<String>(
                        value: _implicitIndex,
                        label: 'X: sample index',
                      ),
                      for (final variable in widget.availableVariables)
                        BlenderMenuItem<String>(
                          value: variable,
                          label: 'X: $variable',
                        ),
                    ],
                    onChanged: (variable) => widget.onChanged(
                      variable == _implicitIndex
                          ? widget.configuration.copyWith(clearXVariable: true)
                          : widget.configuration.copyWith(xVariable: variable),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Y series',
              style: TextStyle(color: palette.foreground, fontSize: 11),
            ),
            const SizedBox(height: 6),
            if (widget.availableVariables.isEmpty)
              Text(
                'Create variables in a code cell to make them available here.',
                style: TextStyle(color: palette.muted, fontSize: 11),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 7,
                children: <Widget>[
                  for (final variable in widget.availableVariables)
                    BlenderCheckbox(
                      value: widget.configuration.yVariables.contains(variable),
                      label: variable,
                      onChanged: (selected) {
                        final values = <String>[
                          ...widget.configuration.yVariables,
                        ];
                        if (selected) {
                          if (!values.contains(variable)) values.add(variable);
                        } else {
                          values.remove(variable);
                        }
                        widget.onChanged(
                          widget.configuration.copyWith(
                            yVariables: List<String>.unmodifiable(values),
                          ),
                        );
                      },
                    ),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              'Run this cell after the selected variables exist in the Python kernel.',
              style: TextStyle(color: palette.muted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  static String _kindLabel(WorkbookPlotKind kind) => switch (kind) {
    WorkbookPlotKind.stackedArea => 'Stacked area',
    WorkbookPlotKind.oscilloscope => 'Oscilloscope',
    _ => '${kind.name[0].toUpperCase()}${kind.name.substring(1)}',
  };
}
