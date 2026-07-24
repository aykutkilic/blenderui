import 'dart:async';
import 'dart:io';

import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter/services.dart';

/// Maintains the app-owned Python files used by the native editor and kernel.
///
/// A workbook cell's source of truth remains [WorkbookDocument]. These files
/// are an integration boundary: CodeForge and a local Jupyter process require
/// a path, while browser and test hosts can continue to use in-memory cells.
/// Synchronization is serialized, deduplicated by source, and never belongs in
/// a widget build callback.
final class WorkbookShadowFileManager {
  static const _helperAsset =
      'packages/blender_ui_workbook/python/blenderui_workbook.py';

  final Set<String> _preparedCellIds = <String>{};
  final Map<String, String> _preparedSources = <String, String>{};
  final Future<String> Function() _loadHelper;
  Future<void> _pendingWrite = Future<void>.value();
  String? _preparedHelperSource;
  String? _workspacePath;

  WorkbookShadowFileManager({Future<String> Function()? loadHelper})
    : _loadHelper = loadHelper ?? (() => rootBundle.loadString(_helperAsset));

  bool isPrepared(WorkbookCell cell) =>
      cell.kind == WorkbookCellKind.code && _preparedCellIds.contains(cell.id);

  String? pathFor(Directory? workspace, WorkbookCell cell) {
    if (workspace == null || !isPrepared(cell)) return null;
    return cellPath(workspace.path, cell.id);
  }

  /// Queues a source snapshot so older asynchronous work cannot overwrite the
  /// files prepared for a newer workbook state.
  Future<void> synchronize({
    required Directory workspace,
    required WorkbookDocument document,
  }) {
    final task = _pendingWrite.then<void>(
      (_) => _writeSnapshot(workspace: workspace, document: document),
    );
    _pendingWrite = task.catchError((Object error) {});
    return task;
  }

  Future<void> _writeSnapshot({
    required Directory workspace,
    required WorkbookDocument document,
  }) async {
    if (_workspacePath != workspace.path) {
      _workspacePath = workspace.path;
      _preparedHelperSource = null;
      _preparedSources.clear();
      _preparedCellIds.clear();
    }
    if (_preparedHelperSource == null) {
      final helper = await _loadHelper();
      await File(
        '${workspace.path}/blenderui_workbook.py',
      ).writeAsString(helper, flush: true);
      _preparedHelperSource = helper;
    }

    final activeIds = <String>{};
    for (final cell in document.cells) {
      if (cell.kind != WorkbookCellKind.code) continue;
      activeIds.add(cell.id);
      if (_preparedSources[cell.id] == cell.source) continue;
      await File(
        cellPath(workspace.path, cell.id),
      ).writeAsString(cell.source, flush: true);
      _preparedSources[cell.id] = cell.source;
    }

    final removedIds = _preparedSources.keys
        .where((id) => !activeIds.contains(id))
        .toList(growable: false);
    for (final id in removedIds) {
      try {
        await File(cellPath(workspace.path, id)).delete();
      } on FileSystemException {
        // It was already removed; the desired app-owned state is reached.
      }
      _preparedSources.remove(id);
    }

    _preparedCellIds
      ..clear()
      ..addAll(activeIds);
  }

  static String cellPath(String workspacePath, String cellId) =>
      '$workspacePath/${cellId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_')}.py';
}
