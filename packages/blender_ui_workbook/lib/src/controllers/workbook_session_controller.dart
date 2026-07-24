import 'dart:async';

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/foundation.dart';

import '../model/workbook_cell.dart';
import '../model/workbook_document.dart';
import '../model/workbook_output.dart';
import '../model/workbook_plot_cell.dart';
import '../services/workbook_kernel.dart';

final class WorkbookSessionController extends ChangeNotifier {
  WorkbookSessionController({
    required WorkbookDocument document,
    WorkbookKernel? kernel,
    BlenderHistoryStore<WorkbookDocument>? history,
  }) : _document = history?.value ?? document,
       _history = history,
       _kernel = kernel {
    _selectedCellId = _document.cells.firstOrNull?.id;
    if (kernel != null) _listenToKernel(kernel);
    history?.addListener(_historyChanged);
  }

  WorkbookDocument _document;
  final BlenderHistoryStore<WorkbookDocument>? _history;
  WorkbookKernel? _kernel;
  StreamSubscription<WorkbookKernelState>? _kernelStateSubscription;
  var _cellSequence = 0;
  bool _disposed = false;
  String? _selectedCellId;

  WorkbookDocument get document => _document;
  WorkbookKernelState get kernelState =>
      _kernel?.state ?? WorkbookKernelState.disconnected;
  WorkbookKernel? get kernel => _kernel;
  bool get hasKernel => _kernel != null;
  String? get selectedCellId => _selectedCellId;
  List<String> get availableVariables {
    final variables = <String>{};
    final assignment = RegExp(
      r'^\s*([A-Za-z_]\w*)\s*(?::[^=]+)?=(?!=)',
      multiLine: true,
    );
    for (final cell in _document.cells) {
      if (cell.kind != WorkbookCellKind.code) continue;
      for (final match in assignment.allMatches(cell.source)) {
        variables.add(match.group(1)!);
      }
    }
    return List<String>.unmodifiable(variables.toList()..sort());
  }

  void replaceDocument(WorkbookDocument document) {
    _commitAuthoring(document);
  }

  void selectCell(String? cellId) {
    if (cellId != null && !_document.cells.any((cell) => cell.id == cellId)) {
      throw ArgumentError.value(cellId, 'cellId', 'Unknown cell');
    }
    if (_selectedCellId == cellId) return;
    _selectedCellId = cellId;
    notifyListeners();
  }

  Future<void> connect() async {
    final kernel = _kernel;
    if (kernel == null) throw const WorkbookKernelUnavailableException();
    await kernel.connect();
  }

  Future<void> attachKernel(
    WorkbookKernel kernel, {
    bool connect = true,
  }) async {
    final previous = _kernel;
    await _kernelStateSubscription?.cancel();
    _kernel = kernel;
    _listenToKernel(kernel);
    notifyListeners();
    if (previous != null && !identical(previous, kernel)) {
      await previous.dispose();
    }
    if (connect) await kernel.connect();
  }

  Future<void> detachKernel() async {
    final previous = _kernel;
    await _kernelStateSubscription?.cancel();
    _kernelStateSubscription = null;
    _kernel = null;
    notifyListeners();
    await previous?.dispose();
  }

  void updateCellSource(String cellId, String source) {
    _replaceCell(
      cellId,
      (cell) => cell.copyWith(source: source),
      recordHistory: true,
    );
  }

  String addCell({
    String source = '',
    WorkbookCellKind kind = WorkbookCellKind.code,
    WorkbookPlotCellConfiguration? plotConfiguration,
    int? afterIndex,
  }) {
    final id = _nextCellId();
    final cells = <WorkbookCell>[..._document.cells];
    final index = afterIndex == null
        ? cells.length
        : (afterIndex + 1).clamp(0, cells.length);
    cells.insert(
      index,
      WorkbookCell(
        id: id,
        source: source,
        kind: kind,
        plotConfiguration: plotConfiguration,
      ),
    );
    _commitAuthoring(
      _document.copyWith(cells: List<WorkbookCell>.unmodifiable(cells)),
    );
    selectCell(id);
    return id;
  }

  String addPlotCell({int? afterIndex}) {
    final variables = availableVariables;
    return addCell(
      kind: WorkbookCellKind.plot,
      afterIndex: afterIndex,
      plotConfiguration: WorkbookPlotCellConfiguration(
        xVariable: variables.firstOrNull,
        yVariables: variables.length > 1
            ? <String>[variables[1]]
            : const <String>[],
      ),
    );
  }

  void updatePlotConfiguration(
    String cellId,
    WorkbookPlotCellConfiguration configuration,
  ) {
    _replaceCell(
      cellId,
      (cell) => cell.copyWith(plotConfiguration: configuration),
      recordHistory: true,
    );
  }

  void removeCell(String cellId) {
    _commitAuthoring(
      _document.copyWith(
        cells: List<WorkbookCell>.unmodifiable(
          _document.cells.where((cell) => cell.id != cellId),
        ),
      ),
    );
    if (_selectedCellId == cellId) {
      selectCell(_document.cells.firstOrNull?.id);
    }
  }

  Future<WorkbookExecutionResult?> runCell(String cellId) async {
    final initial = _cell(cellId);
    if (initial.kind == WorkbookCellKind.markdown) return null;
    late final String executionSource;
    try {
      executionSource = switch (initial.kind) {
        WorkbookCellKind.code => initial.source,
        WorkbookCellKind.plot =>
          (initial.plotConfiguration ?? WorkbookPlotCellConfiguration())
              .toPythonSource(),
        WorkbookCellKind.markdown => throw StateError('unreachable'),
      };
    } on FormatException catch (error) {
      final output = WorkbookErrorOutput(
        name: 'Plot configuration',
        message: error.message,
      );
      _replaceCell(
        cellId,
        (cell) => cell.copyWith(
          state: WorkbookCellState.failed,
          outputs: <WorkbookOutput>[output],
        ),
      );
      return WorkbookExecutionResult(
        messageId: 'plot-configuration',
        outputs: <WorkbookOutput>[output],
        succeeded: false,
      );
    }
    final kernel = _kernel;
    if (kernel == null) {
      _replaceCell(
        cellId,
        (cell) => cell.copyWith(
          state: WorkbookCellState.failed,
          outputs: <WorkbookOutput>[
            WorkbookErrorOutput(
              name: 'Kernel unavailable',
              message: 'Connect a Python runtime from Preferences to run code.',
            ),
          ],
        ),
      );
      return WorkbookExecutionResult(
        messageId: 'offline',
        outputs: <WorkbookOutput>[
          WorkbookErrorOutput(
            name: 'Kernel unavailable',
            message: 'Connect a Python runtime from Preferences to run code.',
          ),
        ],
        succeeded: false,
      );
    }
    _replaceCell(
      cellId,
      (cell) => cell.copyWith(
        state: WorkbookCellState.queued,
        outputs: <WorkbookOutput>[],
        clearExecutionCount: true,
      ),
    );
    try {
      _replaceCell(
        cellId,
        (cell) => cell.copyWith(state: WorkbookCellState.running),
      );
      final result = await kernel.execute(
        executionSource,
        onOutput: (output) => _appendOutput(cellId, output),
      );
      _replaceCell(
        cellId,
        (cell) => cell.copyWith(
          state: result.succeeded
              ? WorkbookCellState.succeeded
              : WorkbookCellState.failed,
          executionCount: result.executionCount,
        ),
      );
      return result;
    } on Object catch (error) {
      final output = WorkbookErrorOutput(
        name: error.runtimeType.toString(),
        message: '$error',
      );
      _replaceCell(
        cellId,
        (cell) => cell.copyWith(
          state: WorkbookCellState.failed,
          outputs: <WorkbookOutput>[...cell.outputs, output],
        ),
      );
      return WorkbookExecutionResult(
        messageId: 'execution-error',
        outputs: <WorkbookOutput>[output],
        succeeded: false,
      );
    }
  }

  Future<void> runAll() async {
    for (final cell in List<WorkbookCell>.of(_document.cells)) {
      if (cell.kind != WorkbookCellKind.markdown) await runCell(cell.id);
    }
  }

  Future<void> interrupt() async {
    final kernel = _kernel;
    if (kernel == null) return;
    await kernel.interrupt();
    final cells = <WorkbookCell>[
      for (final cell in _document.cells)
        if (cell.state == WorkbookCellState.running ||
            cell.state == WorkbookCellState.queued)
          cell.copyWith(state: WorkbookCellState.interrupted)
        else
          cell,
    ];
    _document = _document.copyWith(
      cells: List<WorkbookCell>.unmodifiable(cells),
    );
    notifyListeners();
  }

  Future<void> restart() async {
    final kernel = _kernel;
    if (kernel == null) return;
    await kernel.restart();
    final cells = <WorkbookCell>[
      for (final cell in _document.cells)
        cell.copyWith(state: WorkbookCellState.idle),
    ];
    _document = _document.copyWith(
      cells: List<WorkbookCell>.unmodifiable(cells),
    );
    notifyListeners();
  }

  void _appendOutput(String cellId, WorkbookOutput output) {
    _replaceCell(cellId, (cell) {
      if (output case WorkbookClearOutput(wait: false)) {
        return cell.copyWith(outputs: <WorkbookOutput>[]);
      }
      if (output is WorkbookClearOutput) return cell;
      return cell.copyWith(outputs: <WorkbookOutput>[...cell.outputs, output]);
    });
  }

  WorkbookCell _cell(String cellId) =>
      _document.cells.firstWhere((cell) => cell.id == cellId);

  void _replaceCell(
    String cellId,
    WorkbookCell Function(WorkbookCell cell) replace, {
    bool recordHistory = false,
  }) {
    final index = _document.cells.indexWhere((cell) => cell.id == cellId);
    if (index < 0) throw ArgumentError.value(cellId, 'cellId', 'Unknown cell');
    final cells = <WorkbookCell>[..._document.cells];
    cells[index] = replace(cells[index]);
    final next = _document.copyWith(
      cells: List<WorkbookCell>.unmodifiable(cells),
    );
    if (recordHistory) {
      _commitAuthoring(next);
    } else {
      _document = next;
      notifyListeners();
    }
  }

  void _commitAuthoring(WorkbookDocument document) {
    final history = _history;
    if (history != null) {
      history.replace(document);
      return;
    }
    _document = document;
    _validateSelection();
    notifyListeners();
  }

  void _historyChanged() {
    final history = _history;
    if (history == null || identical(_document, history.value)) return;
    _document = history.value;
    _validateSelection();
    notifyListeners();
  }

  void _validateSelection() {
    if (_selectedCellId != null &&
        !_document.cells.any((cell) => cell.id == _selectedCellId)) {
      _selectedCellId = _document.cells.firstOrNull?.id;
    }
  }

  String _nextCellId() {
    _cellSequence += 1;
    return 'cell-${DateTime.now().microsecondsSinceEpoch}-$_cellSequence';
  }

  void _listenToKernel(WorkbookKernel kernel) {
    _kernelStateSubscription = kernel.states.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _history?.removeListener(_historyChanged);
    unawaited(_kernelStateSubscription?.cancel());
    unawaited(_kernel?.dispose());
    super.dispose();
  }
}

final class WorkbookKernelUnavailableException implements Exception {
  const WorkbookKernelUnavailableException();

  @override
  String toString() =>
      'No Python kernel is connected. Configure one in Preferences.';
}
