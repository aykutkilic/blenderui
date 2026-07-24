import 'dart:async';

import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('workbook models isolate mutable source collections', () {
    final cells = <WorkbookCell>[WorkbookCell(id: 'cell', source: 'value')];
    final document = WorkbookDocument(
      id: 'document',
      title: 'Document',
      cells: cells,
    );
    final data = <String, Object?>{
      'application/json': <Object?>[
        <String, Object?>{'value': 1},
      ],
    };
    final output = WorkbookDisplayOutput(data: data);

    cells.clear();
    (data['application/json']! as List<Object?>).clear();

    expect(document.cells, hasLength(1));
    expect(output.data['application/json'], hasLength(1));
    expect(() => document.cells.clear(), throwsUnsupportedError);
  });

  test('routes authoring changes through application history', () {
    final document = WorkbookDocument(
      id: 'history',
      title: 'History',
      cells: <WorkbookCell>[WorkbookCell(id: 'cell', source: 'before')],
    );
    final history = BlenderHistoryStore<WorkbookDocument>(document);
    final controller = WorkbookSessionController(
      document: document,
      history: history,
    );

    controller.updateCellSource('cell', 'after');
    expect(history.canUndo, isTrue);
    expect(history.value.cells.single.source, 'after');

    history.undo();
    expect(controller.document.cells.single.source, 'before');
    history.redo();
    expect(controller.document.cells.single.source, 'after');

    controller.dispose();
    history.dispose();
  });

  test('starts offline and can attach a kernel later', () async {
    final controller = WorkbookSessionController(
      document: WorkbookDocument(
        id: 'offline',
        title: 'Offline',
        cells: <WorkbookCell>[WorkbookCell(id: 'cell', source: '1 + 1')],
      ),
    );

    expect(controller.kernelState, WorkbookKernelState.disconnected);
    final offline = await controller.runCell('cell');
    expect(offline?.succeeded, isFalse);
    expect(controller.document.cells.single.state, WorkbookCellState.failed);

    final kernel = _FakeKernel();
    await controller.attachKernel(kernel);
    expect(controller.kernelState, WorkbookKernelState.idle);
    final online = await controller.runCell('cell');
    expect(online?.succeeded, isTrue);
    controller.dispose();
  });

  test(
    'streams kernel outputs into the matching cell and retains state',
    () async {
      final kernel = _FakeKernel();
      final controller = WorkbookSessionController(
        document: WorkbookDocument(
          id: 'document',
          title: 'Test',
          cells: <WorkbookCell>[WorkbookCell(id: 'cell', source: 'print(42)')],
        ),
        kernel: kernel,
      );

      final result = await controller.runCell('cell');

      expect(result?.succeeded, isTrue);
      expect(kernel.executed, <String>['print(42)']);
      final cell = controller.document.cells.single;
      expect(cell.state, WorkbookCellState.succeeded);
      expect(cell.executionCount, 7);
      expect(cell.outputs, hasLength(2));
      expect(cell.outputs.first, isA<WorkbookStreamOutput>());
      expect(cell.outputs.last, isA<WorkbookDisplayOutput>());
      controller.dispose();
    },
  );

  test('clear_output removes already streamed values', () async {
    final kernel = _FakeKernel(clearBeforeResult: true);
    final controller = WorkbookSessionController(
      document: WorkbookDocument(
        id: 'document',
        title: 'Test',
        cells: <WorkbookCell>[WorkbookCell(id: 'cell', source: 'value')],
      ),
      kernel: kernel,
    );

    await controller.runCell('cell');

    expect(controller.document.cells.single.outputs, hasLength(1));
    expect(
      controller.document.cells.single.outputs.single,
      isA<WorkbookDisplayOutput>(),
    );
    controller.dispose();
  });

  test('turns kernel failures into a failed cell result', () async {
    final controller = WorkbookSessionController(
      document: WorkbookDocument(
        id: 'failure',
        title: 'Failure',
        cells: <WorkbookCell>[WorkbookCell(id: 'cell', source: 'raise')],
      ),
      kernel: _FakeKernel(failExecution: true),
    );

    final result = await controller.runCell('cell');

    expect(result?.succeeded, isFalse);
    expect(result?.messageId, 'execution-error');
    expect(controller.document.cells.single.state, WorkbookCellState.failed);
    expect(
      controller.document.cells.single.outputs.last,
      isA<WorkbookErrorOutput>(),
    );
    controller.dispose();
  });

  test('discovers code variables without requiring a kernel', () {
    final controller = WorkbookSessionController(
      document: WorkbookDocument(
        id: 'variables',
        title: 'Variables',
        cells: <WorkbookCell>[
          WorkbookCell(
            id: 'code',
            source: '''z = [3, 4]
x: list[float] = [1, 2]
if x == z:
    ignored_comparison == True''',
          ),
          WorkbookCell(
            id: 'notes',
            kind: WorkbookCellKind.markdown,
            source: 'not_a_variable = 1',
          ),
        ],
      ),
    );

    expect(controller.availableVariables, <String>['x', 'z']);
    controller.dispose();
  });

  test(
    'plot configuration participates in history and kernel execution',
    () async {
      final document = WorkbookDocument(
        id: 'plot',
        title: 'Plot',
        cells: <WorkbookCell>[
          WorkbookCell(id: 'code', source: 'x = [0, 1]\ny = [2, 3]'),
          WorkbookCell(
            id: 'plot-cell',
            source: '',
            kind: WorkbookCellKind.plot,
            plotConfiguration: WorkbookPlotCellConfiguration(
              xVariable: 'x',
              yVariables: <String>['y'],
            ),
          ),
        ],
      );
      final history = BlenderHistoryStore<WorkbookDocument>(document);
      final kernel = _FakeKernel();
      final controller = WorkbookSessionController(
        document: document,
        history: history,
        kernel: kernel,
      );

      expect(controller.availableVariables, <String>['x', 'y']);
      controller.updatePlotConfiguration(
        'plot-cell',
        WorkbookPlotCellConfiguration(
          title: 'Chosen values',
          kind: WorkbookPlotKind.scatter,
          xVariable: 'x',
          yVariables: <String>['y'],
        ),
      );
      expect(history.canUndo, isTrue);

      final result = await controller.runCell('plot-cell');

      expect(result?.succeeded, isTrue);
      expect(kernel.executed.single, contains('list(x)'));
      expect(kernel.executed.single, contains('list(y)'));
      expect(kernel.executed.single, contains('title="Chosen values"'));
      expect(kernel.executed.single, contains('plot_type="scatter"'));
      controller.dispose();
      history.dispose();
    },
  );

  test('reports an incomplete plot without invoking the kernel', () async {
    final kernel = _FakeKernel();
    final controller = WorkbookSessionController(
      document: WorkbookDocument(
        id: 'invalid-plot',
        title: 'Invalid plot',
        cells: <WorkbookCell>[
          WorkbookCell(
            id: 'plot',
            source: '',
            kind: WorkbookCellKind.plot,
            plotConfiguration: WorkbookPlotCellConfiguration(),
          ),
        ],
      ),
      kernel: kernel,
    );

    final result = await controller.runCell('plot');

    expect(result?.succeeded, isFalse);
    expect(kernel.executed, isEmpty);
    expect(controller.document.cells.single.state, WorkbookCellState.failed);
    expect(
      controller.document.cells.single.outputs.single,
      isA<WorkbookErrorOutput>(),
    );
    controller.dispose();
  });
}

final class _FakeKernel implements WorkbookKernel {
  _FakeKernel({this.clearBeforeResult = false, this.failExecution = false});

  final bool clearBeforeResult;
  final bool failExecution;
  final List<String> executed = <String>[];
  final StreamController<WorkbookKernelState> _states =
      StreamController<WorkbookKernelState>.broadcast();

  @override
  WorkbookKernelState state = WorkbookKernelState.idle;

  @override
  Stream<WorkbookKernelState> get states => _states.stream;

  @override
  Future<void> connect() async {}

  @override
  Future<WorkbookExecutionResult> execute(
    String code, {
    void Function(WorkbookOutput output)? onOutput,
  }) async {
    executed.add(code);
    if (failExecution) throw StateError('kernel execution failed');
    onOutput?.call(
      const WorkbookStreamOutput(stream: WorkbookStream.stdout, text: 'old'),
    );
    if (clearBeforeResult) onOutput?.call(const WorkbookClearOutput());
    final display = WorkbookDisplayOutput(
      data: <String, Object?>{'text/plain': '42'},
      executionCount: 7,
    );
    onOutput?.call(display);
    return WorkbookExecutionResult(
      messageId: 'message',
      outputs: <WorkbookOutput>[display],
      succeeded: true,
      executionCount: 7,
    );
  }

  @override
  Future<void> interrupt() async {}

  @override
  Future<void> restart() async {}

  @override
  Future<void> dispose() => _states.close();
}
