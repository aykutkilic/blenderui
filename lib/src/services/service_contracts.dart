part of '../services.dart';

typedef BlenderStateUpdater<T> = T Function(T current);
typedef BlenderStateEquality<T> = bool Function(T previous, T next);
typedef BlenderServiceFactory<T extends Object> =
    T Function(BlenderServiceContainer services);
typedef BlenderCommandCallback = FutureOr<void> Function();

/// Opt-in lifecycle contract for objects owned by a
/// [BlenderServiceContainer].
abstract interface class BlenderServiceDisposable {
  void dispose();
}

/// Minimal asynchronous key/value storage for framework-owned sessions.
///
/// BlenderUI deliberately leaves the backing store to the host application.
/// A file, SharedPreferences, browser storage, or a database adapter can all
/// implement this contract without becoming a package dependency.
abstract interface class BlenderPersistentStorage {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> remove(String key);
}
