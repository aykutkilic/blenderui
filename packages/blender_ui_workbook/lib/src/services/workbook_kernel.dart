import '../model/workbook_output.dart';

enum WorkbookKernelState {
  disconnected,
  connecting,
  idle,
  busy,
  restarting,
  failed,
  disposed,
}

final class WorkbookExecutionResult {
  const WorkbookExecutionResult({
    required this.messageId,
    required this.outputs,
    required this.succeeded,
    this.executionCount,
  });

  final String messageId;
  final List<WorkbookOutput> outputs;
  final bool succeeded;
  final int? executionCount;
}

abstract interface class WorkbookKernel {
  WorkbookKernelState get state;

  Stream<WorkbookKernelState> get states;

  Future<void> connect();

  Future<WorkbookExecutionResult> execute(
    String code, {
    void Function(WorkbookOutput output)? onOutput,
  });

  Future<void> interrupt();

  Future<void> restart();

  Future<void> dispose();
}
