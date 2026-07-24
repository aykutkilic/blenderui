import 'workbook_output.dart';
import 'workbook_plot_cell.dart';

enum WorkbookCellKind { code, markdown, plot }

enum WorkbookCellState { idle, queued, running, succeeded, failed, interrupted }

final class WorkbookCell {
  WorkbookCell({
    required this.id,
    required this.source,
    this.kind = WorkbookCellKind.code,
    this.state = WorkbookCellState.idle,
    this.executionCount,
    List<WorkbookOutput> outputs = const <WorkbookOutput>[],
    this.plotConfiguration,
  }) : outputs = List<WorkbookOutput>.unmodifiable(outputs);

  final String id;
  final String source;
  final WorkbookCellKind kind;
  final WorkbookCellState state;
  final int? executionCount;
  final List<WorkbookOutput> outputs;
  final WorkbookPlotCellConfiguration? plotConfiguration;

  WorkbookCell copyWith({
    String? source,
    WorkbookCellKind? kind,
    WorkbookCellState? state,
    int? executionCount,
    bool clearExecutionCount = false,
    List<WorkbookOutput>? outputs,
    WorkbookPlotCellConfiguration? plotConfiguration,
    bool clearPlotConfiguration = false,
  }) {
    return WorkbookCell(
      id: id,
      source: source ?? this.source,
      kind: kind ?? this.kind,
      state: state ?? this.state,
      executionCount: clearExecutionCount
          ? null
          : (executionCount ?? this.executionCount),
      outputs: outputs ?? this.outputs,
      plotConfiguration: clearPlotConfiguration
          ? null
          : (plotConfiguration ?? this.plotConfiguration),
    );
  }
}
