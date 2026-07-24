import 'dart:convert';

import '../plot/plot_model.dart';

/// Persistent authoring choices for a plot cell.
///
/// Variable names refer to values in the active Python kernel. Keeping the
/// configuration in the document lets the UI remain editable offline while
/// generated execution code stays an implementation detail.
final class WorkbookPlotCellConfiguration {
  WorkbookPlotCellConfiguration({
    this.title = 'Variable plot',
    this.kind = WorkbookPlotKind.line,
    this.xVariable,
    List<String> yVariables = const <String>[],
  }) : yVariables = List<String>.unmodifiable(yVariables);

  final String title;
  final WorkbookPlotKind kind;
  final String? xVariable;
  final List<String> yVariables;

  WorkbookPlotCellConfiguration copyWith({
    String? title,
    WorkbookPlotKind? kind,
    String? xVariable,
    bool clearXVariable = false,
    List<String>? yVariables,
  }) => WorkbookPlotCellConfiguration(
    title: title ?? this.title,
    kind: kind ?? this.kind,
    xVariable: clearXVariable ? null : (xVariable ?? this.xVariable),
    yVariables: yVariables ?? this.yVariables,
  );

  String toPythonSource() {
    if (yVariables.isEmpty) {
      throw const FormatException('Choose at least one Y variable to plot.');
    }
    for (final variable in <String>[
      if (xVariable case final value?) value,
      ...yVariables,
    ]) {
      if (!isPythonIdentifier(variable)) {
        throw FormatException('Invalid Python variable name: $variable');
      }
    }
    final xExpression = xVariable == null
        ? 'list(range(len(_blenderui_y)))'
        : 'list($xVariable)';
    final series = <String>[];
    for (var index = 0; index < yVariables.length; index++) {
      final variable = yVariables[index];
      series.add('''
_blenderui_y = list($variable)
_blenderui_x = $xExpression
_blenderui_series.append({
    "id": ${jsonEncode(variable)},
    "label": ${jsonEncode(variable)},
    "points": [[float(x), float(y)] for x, y in zip(_blenderui_x, _blenderui_y)],
})''');
    }
    return '''from blenderui_workbook import plot as _blenderui_plot
_blenderui_series = []
${series.join('\n')}
_blenderui_plot(
    _blenderui_series,
    title=${jsonEncode(title.trim().isEmpty ? 'Variable plot' : title.trim())},
    plot_type=${jsonEncode(_pythonPlotKind(kind))},
)''';
  }

  static bool isPythonIdentifier(String value) =>
      RegExp(r'^[A-Za-z_]\w*$').hasMatch(value);

  static String _pythonPlotKind(WorkbookPlotKind kind) => switch (kind) {
    WorkbookPlotKind.stackedArea => 'stackedArea',
    WorkbookPlotKind.threeDimensional => '3d',
    WorkbookPlotKind.xyMap => 'xyMap',
    _ => kind.name,
  };
}

const workbookVariablePlotKinds = <WorkbookPlotKind>[
  WorkbookPlotKind.line,
  WorkbookPlotKind.scatter,
  WorkbookPlotKind.bar,
  WorkbookPlotKind.histogram,
  WorkbookPlotKind.oscilloscope,
  WorkbookPlotKind.stackedArea,
  WorkbookPlotKind.waveform,
];
