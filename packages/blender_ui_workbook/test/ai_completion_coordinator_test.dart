import 'dart:async';

import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('only the newest AI response reaches CodeForge ghost text', () async {
    final provider = _ControlledCompletionProvider();
    final completions = <String>[];
    final coordinator = WorkbookAiCompletionCoordinator(
      provider: provider,
      debounce: Duration.zero,
      onCompletion: (_, completion) => completions.add(completion),
    );

    const first = WorkbookCompletionRequest(
      source: 'first',
      cursorOffset: 5,
      language: 'python',
    );
    const second = WorkbookCompletionRequest(
      source: 'second',
      cursorOffset: 6,
      language: 'python',
    );
    coordinator.request(first);
    await Future<void>.delayed(Duration.zero);
    coordinator.request(second);
    await Future<void>.delayed(Duration.zero);

    provider.requests[0].complete('stale');
    provider.requests[1].complete('current');
    await Future<void>.delayed(Duration.zero);

    expect(completions, <String>['current']);
    coordinator.dispose();
  });

  test('provider errors clear a current ghost suggestion', () async {
    var clears = 0;
    final coordinator = WorkbookAiCompletionCoordinator(
      provider: _ThrowingCompletionProvider(),
      debounce: Duration.zero,
      onCompletion: (_, _) {},
      onClear: () => clears += 1,
    );
    coordinator.request(
      const WorkbookCompletionRequest(
        source: 'value',
        cursorOffset: 5,
        language: 'python',
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(clears, 2);
    coordinator.dispose();
  });
}

final class _ControlledCompletionProvider
    implements WorkbookAiCompletionProvider {
  final List<Completer<String?>> requests = <Completer<String?>>[];

  @override
  Future<String?> complete(WorkbookCompletionRequest request) {
    final completer = Completer<String?>();
    requests.add(completer);
    return completer.future;
  }
}

final class _ThrowingCompletionProvider
    implements WorkbookAiCompletionProvider {
  @override
  Future<String?> complete(WorkbookCompletionRequest request) async {
    throw StateError('provider unavailable');
  }
}
