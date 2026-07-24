import 'dart:async';

import 'package:flutter/foundation.dart';

import '../model/project.dart';
import 'project_codec.dart';

/// Host-provided durable text storage for DAW projects.
abstract interface class DawProjectStore {
  Future<String?> read(String location);
  Future<void> write(String location, String contents);
}

/// Deterministic store for examples, tests, and embedding applications.
class DawMemoryProjectStore implements DawProjectStore {
  final Map<String, String> _documents = <String, String>{};

  Map<String, String> get documents => Map.unmodifiable(_documents);

  @override
  Future<String?> read(String location) async => _documents[location];

  @override
  Future<void> write(String location, String contents) async {
    _documents[location] = contents;
  }
}

enum DawProjectPersistenceState { idle, loading, saving, saved, failed }

/// Coordinates project save/load without coupling the package to dart:io.
class DawProjectPersistenceController extends ChangeNotifier {
  DawProjectPersistenceController({
    required this.store,
    this.codec = const DawProjectCodec(),
    this.autosaveDelay = const Duration(seconds: 2),
  });

  final DawProjectStore store;
  final DawProjectCodec codec;
  final Duration autosaveDelay;
  DawProjectPersistenceState _state = DawProjectPersistenceState.idle;
  String? _location;
  Object? _lastError;
  Timer? _autosaveTimer;
  bool _dirty = false;

  DawProjectPersistenceState get state => _state;
  String? get location => _location;
  Object? get lastError => _lastError;
  bool get dirty => _dirty;

  Future<void> save(DawProject project, {String? location}) async {
    final target = location ?? _location;
    if (target == null || target.isEmpty) {
      throw const DawProjectFormatException('A project location is required');
    }
    _autosaveTimer?.cancel();
    _setState(DawProjectPersistenceState.saving);
    try {
      await store.write(target, codec.encode(project));
      _location = target;
      _lastError = null;
      _dirty = false;
      _setState(DawProjectPersistenceState.saved);
    } catch (error) {
      _lastError = error;
      _setState(DawProjectPersistenceState.failed);
      rethrow;
    }
  }

  Future<DawProject> load(String location) async {
    _autosaveTimer?.cancel();
    _setState(DawProjectPersistenceState.loading);
    try {
      final contents = await store.read(location);
      if (contents == null) {
        throw DawProjectFormatException('Project not found: $location');
      }
      final project = codec.decode(contents);
      _location = location;
      _lastError = null;
      _dirty = false;
      _setState(DawProjectPersistenceState.idle);
      return project;
    } catch (error) {
      _lastError = error;
      _setState(DawProjectPersistenceState.failed);
      rethrow;
    }
  }

  void scheduleAutosave(DawProject project) {
    _dirty = true;
    if (_location == null) return;
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(autosaveDelay, () => unawaited(_autosave(project)));
  }

  /// Flushes a dirty document before a host permits application shutdown.
  Future<void> flush(DawProject project) async {
    _autosaveTimer?.cancel();
    if (!_dirty || _location == null) return;
    await save(project);
  }

  Future<void> _autosave(DawProject project) async {
    try {
      await save(project);
    } on Object {
      // [save] already records the error and exposes the failed state to the
      // host. A timer callback has no caller that can await this failure.
    }
  }

  void _setState(DawProjectPersistenceState value) {
    _state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    super.dispose();
  }
}
