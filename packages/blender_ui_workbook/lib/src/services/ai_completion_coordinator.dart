import 'dart:async';

import 'ai_completion.dart';

typedef WorkbookCompletionConsumer =
    void Function(WorkbookCompletionRequest request, String completion);

/// Debounces provider requests and guarantees that stale responses never
/// replace a completion for newer source or cursor state.
final class WorkbookAiCompletionCoordinator {
  WorkbookAiCompletionCoordinator({
    required this.provider,
    required this.onCompletion,
    this.onClear,
    this.debounce = const Duration(milliseconds: 550),
  });

  final WorkbookAiCompletionProvider provider;
  final WorkbookCompletionConsumer onCompletion;
  final void Function()? onClear;
  final Duration debounce;

  Timer? _timer;
  var _serial = 0;
  var _disposed = false;

  void request(WorkbookCompletionRequest request) {
    if (_disposed) return;
    _serial += 1;
    final serial = _serial;
    _timer?.cancel();
    onClear?.call();
    _timer = Timer(debounce, () async {
      try {
        final completion = await provider.complete(request);
        if (_disposed || serial != _serial || completion == null) return;
        if (completion.isNotEmpty) onCompletion(request, completion);
      } on Object {
        if (!_disposed && serial == _serial) onClear?.call();
      }
    });
  }

  void invalidate() {
    if (_disposed) return;
    _serial += 1;
    _timer?.cancel();
    onClear?.call();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _serial += 1;
    _timer?.cancel();
  }
}
