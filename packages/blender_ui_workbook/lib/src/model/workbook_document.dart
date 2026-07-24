import 'workbook_cell.dart';

final class WorkbookDocument {
  WorkbookDocument({
    required this.id,
    required this.title,
    List<WorkbookCell> cells = const <WorkbookCell>[],
    this.kernelName = 'python3',
  }) : cells = List<WorkbookCell>.unmodifiable(cells);

  final String id;
  final String title;
  final String kernelName;
  final List<WorkbookCell> cells;

  WorkbookDocument copyWith({
    String? title,
    String? kernelName,
    List<WorkbookCell>? cells,
  }) {
    return WorkbookDocument(
      id: id,
      title: title ?? this.title,
      kernelName: kernelName ?? this.kernelName,
      cells: cells ?? this.cells,
    );
  }
}
