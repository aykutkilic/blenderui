import 'dart:async';

import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';

import '../controllers/workbook_session_controller.dart';
import '../model/workbook_cell.dart';
import '../model/workbook_plot_cell.dart';
import '../services/ai_completion.dart';
import 'workbook_code_editor.dart';
import 'workbook_markdown.dart';
import 'workbook_output_view.dart';
import 'workbook_palette.dart';
import 'workbook_plot_cell.dart';

typedef WorkbookCellFilePath = String? Function(WorkbookCell cell);

final class WorkbookView extends StatelessWidget {
  const WorkbookView({
    required this.controller,
    this.lspConfig,
    this.aiCompletionProvider,
    this.filePathForCell,
    this.persistFileChanges = true,
    super.key,
  });

  final WorkbookSessionController controller;
  final LspConfig? lspConfig;
  final WorkbookAiCompletionProvider? aiCompletionProvider;
  final WorkbookCellFilePath? filePathForCell;
  final bool persistFileChanges;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final document = controller.document;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _WorkbookToolbar(controller: controller),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(32, 18, 32, 80),
              itemCount: document.cells.length,
              itemBuilder: (context, index) {
                final cell = document.cells[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _WorkbookCellCard(
                    key: ValueKey(cell.id),
                    cell: cell,
                    active: cell.id == controller.selectedCellId,
                    lspConfig: lspConfig,
                    aiCompletionProvider: aiCompletionProvider,
                    persistFileChanges: persistFileChanges,
                    filePath: filePathForCell?.call(cell),
                    onActivate: () => controller.selectCell(cell.id),
                    onChanged: (source) =>
                        controller.updateCellSource(cell.id, source),
                    availableVariables: controller.availableVariables,
                    onPlotChanged: (configuration) => controller
                        .updatePlotConfiguration(cell.id, configuration),
                    onRun:
                        controller.hasKernel &&
                            cell.kind != WorkbookCellKind.markdown
                        ? () => unawaited(controller.runCell(cell.id))
                        : null,
                    onRemove: () => controller.removeCell(cell.id),
                  ),
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

final class _WorkbookToolbar extends StatelessWidget {
  const _WorkbookToolbar({required this.controller});

  final WorkbookSessionController controller;

  @override
  Widget build(BuildContext context) {
    final palette = WorkbookPalette.of(context);
    return Material(
      color: palette.elevated,
      child: SizedBox(
        height: 38,
        child: DefaultTextStyle(
          style: TextStyle(color: palette.foreground, fontSize: 12),
          child: IconTheme(
            data: IconThemeData(color: palette.foreground, size: 14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 700;
                return Row(
                  children: <Widget>[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.document.title,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _ToolbarAction(
                      icon: Icons.add,
                      label: 'Code',
                      compact: compact,
                      onPressed: () => controller.addCell(),
                    ),
                    _ToolbarAction(
                      icon: Icons.notes,
                      label: 'Markdown',
                      compact: compact,
                      onPressed: () => controller.addCell(
                        kind: WorkbookCellKind.markdown,
                        source: r'''## Markdown

Write text and LaTeX such as $E = mc^2$ here.''',
                      ),
                    ),
                    _ToolbarAction(
                      icon: Icons.show_chart,
                      label: 'Plot',
                      compact: compact,
                      onPressed: controller.addPlotCell,
                    ),
                    _ToolbarAction(
                      icon: Icons.playlist_play,
                      label: 'Run All',
                      compact: compact,
                      onPressed: controller.hasKernel
                          ? () => unawaited(controller.runAll())
                          : null,
                    ),
                    _ToolbarAction(
                      icon: Icons.stop,
                      label: 'Interrupt',
                      compact: compact,
                      onPressed: controller.hasKernel
                          ? () => unawaited(controller.interrupt())
                          : null,
                    ),
                    _ToolbarAction(
                      icon: Icons.restart_alt,
                      label: 'Restart',
                      compact: compact,
                      onPressed: controller.hasKernel
                          ? () => unawaited(controller.restart())
                          : null,
                    ),
                    const SizedBox(width: 8),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

final class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = WorkbookPalette.of(context);
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14),
      label: compact
          ? const SizedBox.shrink()
          : Text(label, style: const TextStyle(fontSize: 10)),
      style: TextButton.styleFrom(
        foregroundColor: palette.foreground,
        padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 7),
        minimumSize: const Size(0, 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

final class _WorkbookCellCard extends StatelessWidget {
  const _WorkbookCellCard({
    required this.cell,
    required this.active,
    required this.onActivate,
    required this.onChanged,
    required this.availableVariables,
    required this.onPlotChanged,
    required this.onRun,
    required this.onRemove,
    this.lspConfig,
    this.aiCompletionProvider,
    this.filePath,
    required this.persistFileChanges,
    super.key,
  });

  final WorkbookCell cell;
  final bool active;
  final VoidCallback onActivate;
  final ValueChanged<String> onChanged;
  final List<String> availableVariables;
  final ValueChanged<WorkbookPlotCellConfiguration> onPlotChanged;
  final VoidCallback? onRun;
  final VoidCallback onRemove;
  final LspConfig? lspConfig;
  final WorkbookAiCompletionProvider? aiCompletionProvider;
  final String? filePath;
  final bool persistFileChanges;

  @override
  Widget build(BuildContext context) {
    final palette = WorkbookPalette.of(context);
    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: active ? palette.focus : palette.outline,
          width: active ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: DefaultTextStyle(
        style: TextStyle(color: palette.foreground),
        child: IconTheme(
          data: IconThemeData(color: palette.foreground),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 30,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      tooltip: cell.kind == WorkbookCellKind.markdown
                          ? 'Markdown cells do not execute'
                          : 'Run cell',
                      onPressed: onRun,
                      icon: const Icon(Icons.play_arrow, size: 15),
                      padding: const EdgeInsets.all(5),
                    ),
                    SizedBox(
                      width: 52,
                      child: Text(
                        cell.kind == WorkbookCellKind.markdown
                            ? '[M]'
                            : cell.kind == WorkbookCellKind.plot
                            ? '[P]'
                            : cell.executionCount == null
                            ? '[ ]'
                            : '[${cell.executionCount}]',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10,
                        ),
                      ),
                    ),
                    Text(cell.state.name, style: const TextStyle(fontSize: 10)),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Delete cell',
                      onPressed: onRemove,
                      icon: const Icon(Icons.close, size: 13),
                      padding: const EdgeInsets.all(5),
                    ),
                  ],
                ),
              ),
              switch (cell.kind) {
                WorkbookCellKind.code => Listener(
                  onPointerDown: (_) => onActivate(),
                  child: SizedBox(
                    height: _codeEditorHeight(cell.source),
                    child: WorkbookCodeEditor(
                      key: ValueKey('${cell.id}:$filePath'),
                      lspConfig: lspConfig,
                      filePath: filePath,
                      initialText: filePath == null ? cell.source : null,
                      aiCompletionProvider: aiCompletionProvider,
                      persistFileChanges: persistFileChanges,
                      onChanged: onChanged,
                      autoFocus: active,
                    ),
                  ),
                ),
                WorkbookCellKind.markdown => WorkbookMarkdownCell(
                  source: cell.source,
                  active: active,
                  onActivate: onActivate,
                  onChanged: onChanged,
                ),
                WorkbookCellKind.plot => WorkbookPlotCellEditor(
                  configuration:
                      cell.plotConfiguration ?? WorkbookPlotCellConfiguration(),
                  availableVariables: availableVariables,
                  active: active,
                  onActivate: onActivate,
                  onChanged: onPlotChanged,
                ),
              },
              if (cell.outputs.isNotEmpty)
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: palette.outline)),
                  ),
                  child: WorkbookOutputList(outputs: cell.outputs),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static double _codeEditorHeight(String source) =>
      (source.split('\n').length * 20.0 + 54).clamp(120, 340).toDouble();
}
