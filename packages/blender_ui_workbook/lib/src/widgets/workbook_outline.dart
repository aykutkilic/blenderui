import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/workbook_session_controller.dart';
import '../model/workbook_cell.dart';

/// Reusable document outline synchronized with a [WorkbookSessionController].
///
/// Hosts can place this in another dock area without creating a second
/// selection model. Selection remains stable across workspace switches.
final class WorkbookOutline extends StatelessWidget {
  const WorkbookOutline({required this.controller, super.key});

  final WorkbookSessionController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final cells = controller.document.cells;
      return BlenderListView<WorkbookCell>(
        emptyLabel: 'No cells',
        selectedId: controller.selectedCellId,
        items: <BlenderListItem<WorkbookCell>>[
          for (var index = 0; index < cells.length; index++)
            BlenderListItem<WorkbookCell>(
              id: cells[index].id,
              label: '${index + 1}. ${_label(cells[index])}',
              detail: cells[index].state.name,
              icon: switch (cells[index].kind) {
                WorkbookCellKind.code => BlenderGlyph.console,
                WorkbookCellKind.markdown => BlenderGlyph.text,
                WorkbookCellKind.plot => BlenderGlyph.curve,
              },
              value: cells[index],
            ),
        ],
        onSelected: (item) => controller.selectCell(item.id),
      );
    },
  );

  static String _label(WorkbookCell cell) {
    final firstLine = cell.source.split('\n').first.trim();
    if (firstLine.isEmpty) return cell.kind.name;
    return firstLine.length > 46 ? '${firstLine.substring(0, 43)}…' : firstLine;
  }
}
