import 'dart:convert';

import '../model/workbook_cell.dart';
import '../model/workbook_document.dart';
import '../model/workbook_output.dart';
import '../model/workbook_plot_cell.dart';
import '../plot/plot_model.dart';

/// Reads the source and common output types from a Jupyter `.ipynb` document.
///
/// Execution still requires a kernel, but decoding deliberately does not. This
/// keeps file viewing and editing available in offline-first hosts.
final class JupyterNotebookCodec {
  const JupyterNotebookCodec();

  WorkbookDocument decode(String contents, {required String fallbackTitle}) {
    final decoded = jsonDecode(contents);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Notebook root must be a JSON object.');
    }
    final rawCells = decoded['cells'];
    if (rawCells is! List<Object?>) {
      throw const FormatException('Notebook does not contain a cells list.');
    }
    final metadata = decoded['metadata'];
    final kernelName = metadata is Map<String, Object?>
        ? _kernelName(metadata)
        : 'python3';
    return WorkbookDocument(
      id: 'notebook-${DateTime.now().microsecondsSinceEpoch}',
      title: fallbackTitle,
      kernelName: kernelName,
      cells: <WorkbookCell>[
        for (var index = 0; index < rawCells.length; index++)
          if (rawCells[index] case final Map<String, Object?> cell)
            _decodeCell(cell, index),
      ],
    );
  }

  WorkbookCell _decodeCell(Map<String, Object?> value, int index) {
    final plotConfiguration = _plotConfiguration(value['metadata']);
    final kind = plotConfiguration != null
        ? WorkbookCellKind.plot
        : value['cell_type'] == 'code'
        ? WorkbookCellKind.code
        : WorkbookCellKind.markdown;
    final count = value['execution_count'];
    final rawOutputs = value['outputs'];
    return WorkbookCell(
      id: 'cell-${index + 1}',
      source: _text(value['source']),
      kind: kind,
      executionCount: count is int ? count : null,
      outputs: rawOutputs is List<Object?>
          ? <WorkbookOutput>[
              for (final output in rawOutputs)
                if (output case final Map<String, Object?> map)
                  if (_decodeOutput(map) case final decoded?) decoded,
            ]
          : const <WorkbookOutput>[],
      plotConfiguration: plotConfiguration,
    );
  }

  WorkbookPlotCellConfiguration? _plotConfiguration(Object? metadata) {
    if (metadata is! Map<String, Object?>) return null;
    final blenderui = metadata['blenderui'];
    if (blenderui is! Map<String, Object?>) return null;
    final plot = blenderui['plot'];
    if (plot is! Map<String, Object?>) return null;
    final kindName = plot['kind']?.toString();
    final yVariables = plot['yVariables'];
    return WorkbookPlotCellConfiguration(
      title: plot['title']?.toString() ?? 'Variable plot',
      kind: WorkbookPlotKind.values.firstWhere(
        (kind) => kind.name == kindName,
        orElse: () => WorkbookPlotKind.line,
      ),
      xVariable: plot['xVariable']?.toString(),
      yVariables: yVariables is List<Object?>
          ? <String>[for (final value in yVariables) '$value']
          : const <String>[],
    );
  }

  WorkbookOutput? _decodeOutput(Map<String, Object?> value) {
    switch (value['output_type']) {
      case 'stream':
        return WorkbookStreamOutput(
          stream: value['name'] == 'stderr'
              ? WorkbookStream.stderr
              : WorkbookStream.stdout,
          text: _text(value['text']),
        );
      case 'error':
        return WorkbookErrorOutput(
          name: '${value['ename'] ?? 'Error'}',
          message: '${value['evalue'] ?? ''}',
          traceback: _strings(value['traceback']),
        );
      case 'display_data':
      case 'execute_result':
        final data = value['data'];
        final metadata = value['metadata'];
        final count = value['execution_count'];
        return WorkbookDisplayOutput(
          data: data is Map<String, Object?> ? data : const <String, Object?>{},
          metadata: metadata is Map<String, Object?>
              ? metadata
              : const <String, Object?>{},
          executionCount: count is int ? count : null,
        );
    }
    return null;
  }

  String _kernelName(Map<String, Object?> metadata) {
    final kernelspec = metadata['kernelspec'];
    if (kernelspec is Map<String, Object?>) {
      final name = kernelspec['name'];
      if (name is String && name.isNotEmpty) return name;
    }
    return 'python3';
  }

  String _text(Object? value) => switch (value) {
    String text => text,
    List<Object?> parts => parts.map((part) => '$part').join(),
    _ => '',
  };

  List<String> _strings(Object? value) => value is List<Object?>
      ? value.map((item) => '$item').toList(growable: false)
      : const <String>[];
}
