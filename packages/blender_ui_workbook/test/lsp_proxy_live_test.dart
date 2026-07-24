import 'dart:async';
import 'dart:io';

import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final serverUrl = Platform.environment['WORKBOOK_LIVE_LSP_URL'];

  test(
    'WebSocket companion provides Python completion with every capability on',
    () async {
      final workspace = await Directory.systemTemp.createTemp(
        'blenderui-workbook-lsp-',
      );
      final source = File('${workspace.path}/completion.py');
      await source.writeAsString('import math\nmath.');
      final lsp = LspSocketConfig(
        workspacePath: workspace.path,
        languageId: 'python',
        serverUrl: serverUrl!,
        capabilities: const LspClientCapabilities(),
      );
      StreamSubscription<Map<String, dynamic>>? serverRequests;
      try {
        await lsp.connect();
        serverRequests = lsp.responses.listen((message) async {
          if (message['method'] == 'workspace/configuration') {
            await lsp.sendResponse(message['id'] as int, <dynamic>[
              lsp.workspaceConfiguration,
            ]);
          }
        });
        await lsp.initialize();
        await lsp.openDocument(source.path);
        final completions = await lsp.getCompletions(source.path, 1, 5);
        expect(completions.map((item) => item.label), contains('sin'));
        expect(lsp.capabilities.semanticHighlighting, isTrue);
        expect(lsp.capabilities.codeAction, isTrue);
        expect(lsp.capabilities.signatureHelp, isTrue);
        expect(lsp.capabilities.hoverInfo, isTrue);
        expect(lsp.capabilities.documentHighlight, isTrue);
        expect(lsp.capabilities.codeFolding, isTrue);
        expect(lsp.capabilities.inlayHint, isTrue);
        expect(lsp.capabilities.goToDefinition, isTrue);
        expect(lsp.capabilities.rename, isTrue);
      } finally {
        await serverRequests?.cancel();
        lsp.dispose();
        await workspace.delete(recursive: true);
      }
    },
    skip: serverUrl == null
        ? 'Set WORKBOOK_LIVE_LSP_URL to the companion WebSocket URL.'
        : false,
  );
}
