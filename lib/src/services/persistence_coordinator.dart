part of '../services.dart';

enum BlenderPersistenceStatus { idle, restoring, saving, failed }

/// Shared host-storage identity for a persistable BlenderUI service.
///
/// Service-specific persistence declarations extend this type only when they
/// add stable domain data such as a workspace value codec. This keeps the
/// storage/key contract consistent without erasing useful public names.
class BlenderPersistenceConfiguration {
  const BlenderPersistenceConfiguration({
    required this.storage,
    required this.storageKey,
  }) : assert(storageKey != '');

  final BlenderPersistentStorage storage;
  final String storageKey;
}

/// Coordinates the mechanical lifecycle shared by persistent app services.
///
/// Services retain ownership of their schema, validation, and in-memory state.
/// This coordinator owns restore memoization, microtask write coalescing,
/// serialized writes, deletion, disposal flushing, and error capture.
class BlenderPersistenceCoordinator {
  BlenderPersistenceCoordinator({
    required this.storage,
    required this.storageKey,
    required this.serialize,
    this.canWrite,
  }) : assert(storageKey != '');

  final BlenderPersistentStorage storage;
  final String storageKey;
  final FutureOr<String> Function() serialize;
  final bool Function()? canWrite;

  Future<bool>? _restoreFuture;
  Future<void> _pendingWrite = Future<void>.value();
  bool _writeScheduled = false;
  bool _disposed = false;

  Object? lastError;
  final ValueNotifier<BlenderPersistenceStatus> status =
      ValueNotifier<BlenderPersistenceStatus>(BlenderPersistenceStatus.idle);

  Future<bool> restore(FutureOr<bool> Function(String raw) apply) =>
      _restoreFuture ??= _restore(apply);

  Future<bool> _restore(FutureOr<bool> Function(String raw) apply) async {
    status.value = BlenderPersistenceStatus.restoring;
    try {
      final raw = await storage.read(storageKey);
      if (raw == null || raw.isEmpty) {
        status.value = BlenderPersistenceStatus.idle;
        return false;
      }
      final restored = await apply(raw);
      if (restored) lastError = null;
      status.value = BlenderPersistenceStatus.idle;
      return restored;
    } catch (error) {
      lastError = error;
      status.value = BlenderPersistenceStatus.failed;
      return false;
    }
  }

  void scheduleWrite() {
    if (_disposed || _writeScheduled || !(canWrite?.call() ?? true)) return;
    _writeScheduled = true;
    scheduleMicrotask(() {
      if (_disposed || !_writeScheduled) return;
      unawaited(flush());
    });
  }

  Future<void> flush() {
    _writeScheduled = false;
    if (!(canWrite?.call() ?? true)) return _pendingWrite;
    _pendingWrite = _pendingWrite.then((_) async {
      status.value = BlenderPersistenceStatus.saving;
      try {
        await storage.write(storageKey, await serialize());
        lastError = null;
        status.value = BlenderPersistenceStatus.idle;
      } catch (error) {
        lastError = error;
        status.value = BlenderPersistenceStatus.failed;
      }
    });
    return _pendingWrite;
  }

  Future<void> clear() {
    _writeScheduled = false;
    _pendingWrite = _pendingWrite.then((_) async {
      status.value = BlenderPersistenceStatus.saving;
      try {
        await storage.remove(storageKey);
        lastError = null;
        status.value = BlenderPersistenceStatus.idle;
      } catch (error) {
        lastError = error;
        status.value = BlenderPersistenceStatus.failed;
      }
    });
    return _pendingWrite;
  }

  Future<void> dispose() {
    if (_disposed) return _pendingWrite;
    _disposed = true;
    return flush().whenComplete(status.dispose);
  }
}
