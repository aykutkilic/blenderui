import 'dart:async';

import 'services.dart';
import 'theme.dart';

enum BlenderWindowAppearance { light, dark }

/// Host-supplied bridge from a portable theme request to native window chrome.
abstract interface class BlenderWindowAppearanceAdapter {
  Future<void> apply(BlenderWindowAppearance appearance);
}

class BlenderNoopWindowAppearanceAdapter
    implements BlenderWindowAppearanceAdapter {
  const BlenderNoopWindowAppearanceAdapter();

  @override
  Future<void> apply(BlenderWindowAppearance appearance) async {}
}

/// Synchronizes a live Blender theme with an injected platform adapter.
class BlenderWindowAppearanceController implements BlenderServiceDisposable {
  BlenderWindowAppearanceController({
    required this.theme,
    required this.adapter,
  }) {
    theme.addListener(_scheduleSync);
    _scheduleSync();
  }

  final BlenderThemeController theme;
  final BlenderWindowAppearanceAdapter adapter;
  BlenderWindowAppearance? _lastApplied;
  bool _scheduled = false;
  bool _disposed = false;

  Object? lastError;

  BlenderWindowAppearance get desiredAppearance =>
      theme.data.colors.canvas.computeLuminance() > .5
      ? BlenderWindowAppearance.light
      : BlenderWindowAppearance.dark;

  void _scheduleSync() {
    if (_disposed || _scheduled) return;
    _scheduled = true;
    scheduleMicrotask(sync);
  }

  Future<void> sync() async {
    if (_disposed) return;
    _scheduled = false;
    final next = desiredAppearance;
    if (_lastApplied == next && lastError == null) return;
    try {
      await adapter.apply(next);
      if (_disposed) return;
      _lastApplied = next;
      lastError = null;
    } catch (error) {
      if (_disposed) return;
      lastError = error;
    }
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    theme.removeListener(_scheduleSync);
  }
}
