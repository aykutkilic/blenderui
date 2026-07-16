import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'docking.dart';
import 'docking_model.dart';
import 'layout.dart';
import 'services.dart';

/// Immutable definition of one named Blender-style workspace.
///
/// A workspace is a composition of editor areas, not an editor itself. Its
/// [layout] describes the default docking tree while a
/// [BlenderWorkspaceService] retains the user's live layout independently.
class BlenderWorkspaceDefinition<T> {
  const BlenderWorkspaceDefinition({
    required this.id,
    required this.layout,
    this.sessionState,
  });

  /// Stable application-owned identifier, such as `folders` or `authoring`.
  final String id;

  /// The immutable layout used for a new workspace and for reset.
  final BlenderDockNode<T> layout;

  /// Optional application-owned state that belongs to this perspective.
  ///
  /// Use this for durable workspace context such as an Outliner selection or
  /// the currently inspected record. Editor data itself remains in the
  /// application's domain store.
  final BlenderWorkspaceSessionState? sessionState;
}

/// Minimal asynchronous key/value storage used for workspace sessions.
///
/// BlenderUI deliberately does not choose a storage package. Applications may
/// adapt SharedPreferences, a file, browser storage, or their own settings
/// service without making that dependency part of the widget library.
abstract interface class BlenderWorkspaceStorage {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> remove(String key);
}

/// Encodes the application-owned editor identifier hosted by a dock area.
///
/// A workspace tree is structural framework state, but an area value belongs
/// to the application (for example, `pageEditor` or `properties`). Supplying
/// this codec keeps the persisted session type-safe and avoids runtime type
/// names or enum indexes becoming an accidental file format.
class BlenderWorkspaceValueCodec<T> {
  const BlenderWorkspaceValueCodec({
    required this.toJson,
    required this.fromJson,
  });

  final Object? Function(T value) toJson;
  final T Function(Object? value) fromJson;
}

/// Application-owned state that participates in a workspace session.
///
/// It is intentionally separate from [BlenderDockNode]: dock nodes describe
/// editor geometry and type, whereas a selected folder, active asset, or
/// similar context belongs to the editor application.
abstract interface class BlenderWorkspaceSessionState implements Listenable {
  Object? save();

  void restore(Object? value);
}

/// A notifier-backed [BlenderWorkspaceSessionState] for one typed value.
///
/// Update [value] whenever the application selection changes. The surrounding
/// [BlenderWorkspaceService] observes it and coalesces the resulting session
/// write alongside docking changes.
class BlenderWorkspaceState<T> extends ChangeNotifier
    implements BlenderWorkspaceSessionState {
  BlenderWorkspaceState({required T value, required this.codec})
    : _value = value;

  final BlenderWorkspaceValueCodec<T> codec;
  T _value;

  T get value => _value;

  set value(T next) {
    if (_value == next) return;
    _value = next;
    notifyListeners();
  }

  @override
  Object? save() => codec.toJson(_value);

  @override
  void restore(Object? value) {
    this.value = codec.fromJson(value);
  }
}

/// Configuration for durable workspace sessions.
///
/// Use a stable, application-specific [storageKey]. The session is versioned
/// and invalid or obsolete data is ignored, leaving declared workspace
/// defaults intact.
class BlenderWorkspacePersistence<T> {
  const BlenderWorkspacePersistence({
    required this.storage,
    required this.valueCodec,
    required this.storageKey,
  }) : assert(storageKey != '');

  final BlenderWorkspaceStorage storage;
  final BlenderWorkspaceValueCodec<T> valueCodec;
  final String storageKey;
}

/// Owns the dock layouts for an application's named workspaces.
///
/// Applications keep their workspace switcher and editor builders, while this
/// service owns the reusable lifecycle: each workspace gets a controller,
/// changing workspace retains its layout, and a reset restores only that
/// workspace's declared default. Register the service in an application's
/// service container when editor code needs to select a workspace.
class BlenderWorkspaceService<T> extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderWorkspaceService({
    required Iterable<BlenderWorkspaceDefinition<T>> workspaces,
    String? initialWorkspaceId,
    this.persistence,
  }) {
    for (final definition in workspaces) {
      if (definition.id.isEmpty) {
        throw ArgumentError.value(
          definition.id,
          'workspaces.id',
          'Workspace ids must not be empty.',
        );
      }
      if (_definitions.containsKey(definition.id)) {
        throw ArgumentError.value(
          definition.id,
          'workspaces.id',
          'Workspace ids must be unique.',
        );
      }
      _definitions[definition.id] = definition;
      final controller = BlenderDockingController<T>(root: definition.layout);
      controller.addListener(_handleLayoutChanged);
      _controllers[definition.id] = controller;
      definition.sessionState?.addListener(_handleLayoutChanged);
    }
    if (_definitions.isEmpty) {
      throw ArgumentError.value(
        workspaces,
        'workspaces',
        'At least one workspace is required.',
      );
    }
    final initial = initialWorkspaceId ?? _definitions.keys.first;
    if (!_definitions.containsKey(initial)) {
      throw ArgumentError.value(
        initial,
        'initialWorkspaceId',
        'The initial workspace must be declared.',
      );
    }
    _activeWorkspaceId = initial;
  }

  final Map<String, BlenderWorkspaceDefinition<T>> _definitions =
      <String, BlenderWorkspaceDefinition<T>>{};
  final Map<String, BlenderDockingController<T>> _controllers =
      <String, BlenderDockingController<T>>{};
  final BlenderWorkspacePersistence<T>? persistence;
  late String _activeWorkspaceId;
  bool _disposed = false;
  bool _restoring = false;
  Future<bool>? _restoreFuture;
  Future<void> _pendingWrite = Future<void>.value();
  bool _writeScheduled = false;
  bool _sessionCleared = false;

  /// The most recent persistence failure, if any.
  ///
  /// Session failures are non-fatal: default layouts remain usable. Hosts can
  /// expose this value in diagnostics or clear the session explicitly.
  Object? lastPersistenceError;

  /// The declared workspace definitions in their application-defined order.
  List<BlenderWorkspaceDefinition<T>> get workspaces =>
      List<BlenderWorkspaceDefinition<T>>.unmodifiable(_definitions.values);

  String get activeWorkspaceId => _activeWorkspaceId;

  BlenderWorkspaceDefinition<T> get activeWorkspace =>
      _definitions[_activeWorkspaceId]!;

  BlenderDockingController<T> get activeController =>
      _controllers[_activeWorkspaceId]!;

  BlenderDockingController<T> controllerFor(String workspaceId) {
    final controller = _controllers[workspaceId];
    if (controller == null) {
      throw ArgumentError.value(
        workspaceId,
        'workspaceId',
        'No workspace with this id is registered.',
      );
    }
    return controller;
  }

  /// Selects a workspace, retaining the other workspaces' live layouts.
  bool selectWorkspace(String workspaceId) {
    if (!_controllers.containsKey(workspaceId)) {
      throw ArgumentError.value(
        workspaceId,
        'workspaceId',
        'No workspace with this id is registered.',
      );
    }
    if (_activeWorkspaceId == workspaceId) return false;
    _activeWorkspaceId = workspaceId;
    _sessionCleared = false;
    _schedulePersist();
    notifyListeners();
    return true;
  }

  /// Restores a workspace to its declared default layout.
  void resetWorkspace(String workspaceId) {
    final definition = _definitions[workspaceId];
    if (definition == null) {
      throw ArgumentError.value(
        workspaceId,
        'workspaceId',
        'No workspace with this id is registered.',
      );
    }
    controllerFor(workspaceId).replaceRoot(definition.layout);
  }

  /// Restores the active workspace and every persisted dock layout.
  ///
  /// This is safe to call more than once; concurrent callers receive the same
  /// operation. Unknown workspaces and malformed layouts are discarded as a
  /// whole, so an application update can safely change its default views.
  Future<bool> restore() => _restoreFuture ??= _restore();

  Future<bool> _restore() async {
    final persistence = this.persistence;
    if (persistence == null) return false;
    try {
      final raw = await persistence.storage.read(persistence.storageKey);
      if (raw == null || raw.isEmpty) return false;
      final decoded = _decodeSession(raw, persistence.valueCodec);
      if (decoded == null) return false;

      _restoring = true;
      try {
        for (final entry in decoded.layouts.entries) {
          final controller = _controllers[entry.key];
          if (controller != null) controller.replaceRoot(entry.value);
        }
        for (final entry in decoded.states.entries) {
          _definitions[entry.key]?.sessionState?.restore(entry.value);
        }
        if (_controllers.containsKey(decoded.activeWorkspaceId)) {
          _activeWorkspaceId = decoded.activeWorkspaceId;
        }
      } finally {
        _restoring = false;
      }
      notifyListeners();
      return true;
    } catch (error) {
      lastPersistenceError = error;
      return false;
    }
  }

  /// Writes the current workspace selection and dock trees immediately.
  ///
  /// Automatic writes are coalesced after layout gestures. Call this before a
  /// host-controlled shutdown when it needs to await the final disk write.
  Future<void> flush() {
    final persistence = this.persistence;
    if (persistence == null || _restoring || _sessionCleared) {
      return Future<void>.value();
    }
    _writeScheduled = false;
    _pendingWrite = _pendingWrite.then((_) async {
      final session = <String, Object?>{
        'version': 1,
        'activeWorkspaceId': _activeWorkspaceId,
        'layouts': <String, Object?>{
          for (final entry in _controllers.entries)
            entry.key: _encodeNode(entry.value.root, persistence.valueCodec),
        },
        'states': <String, Object?>{
          for (final entry in _definitions.entries)
            if (entry.value.sessionState != null)
              entry.key: entry.value.sessionState!.save(),
        },
      };
      try {
        await persistence.storage.write(
          persistence.storageKey,
          jsonEncode(session),
        );
        lastPersistenceError = null;
      } catch (error) {
        lastPersistenceError = error;
      }
    });
    return _pendingWrite;
  }

  /// Deletes the saved session. Declared default layouts remain untouched.
  Future<void> clearPersistedSession() {
    final persistence = this.persistence;
    if (persistence == null) return Future<void>.value();
    _writeScheduled = false;
    _sessionCleared = true;
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await persistence.storage.remove(persistence.storageKey);
        lastPersistenceError = null;
      } catch (error) {
        lastPersistenceError = error;
      }
    });
    return _pendingWrite;
  }

  void _handleLayoutChanged() {
    _sessionCleared = false;
    _schedulePersist();
  }

  void _schedulePersist() {
    if (persistence == null || _restoring || _writeScheduled || _disposed) {
      return;
    }
    _writeScheduled = true;
    scheduleMicrotask(() {
      if (_disposed || !_writeScheduled) return;
      unawaited(flush());
    });
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final controller in _controllers.values) {
      controller.removeListener(_handleLayoutChanged);
      controller.dispose();
    }
    for (final definition in _definitions.values) {
      definition.sessionState?.removeListener(_handleLayoutChanged);
    }
    unawaited(flush());
    super.dispose();
  }
}

class _BlenderWorkspaceSession<T> {
  const _BlenderWorkspaceSession({
    required this.activeWorkspaceId,
    required this.layouts,
    required this.states,
  });

  final String activeWorkspaceId;
  final Map<String, BlenderDockNode<T>> layouts;
  final Map<String, Object?> states;
}

Object? _encodeNode<T>(
  BlenderDockNode<T> node,
  BlenderWorkspaceValueCodec<T> valueCodec,
) {
  if (node is BlenderDockAreaNode<T>) {
    return <String, Object?>{
      'type': 'area',
      'id': node.id,
      'value': valueCodec.toJson(node.value),
    };
  }
  final split = node as BlenderDockSplitNode<T>;
  return <String, Object?>{
    'type': 'split',
    'id': split.id,
    'direction': split.direction.name,
    'fraction': split.fraction,
    'first': _encodeNode(split.first, valueCodec),
    'second': _encodeNode(split.second, valueCodec),
  };
}

_BlenderWorkspaceSession<T>? _decodeSession<T>(
  String raw,
  BlenderWorkspaceValueCodec<T> valueCodec,
) {
  final root = jsonDecode(raw);
  if (root is! Map<Object?, Object?> || root['version'] != 1) return null;
  final activeWorkspaceId = root['activeWorkspaceId'];
  final layouts = root['layouts'];
  final states = root['states'];
  if (activeWorkspaceId is! String || layouts is! Map<Object?, Object?>) {
    return null;
  }
  final decodedLayouts = <String, BlenderDockNode<T>>{};
  for (final entry in layouts.entries) {
    if (entry.key is! String) return null;
    final node = _decodeNode(entry.value, valueCodec, <String>{});
    if (node == null) return null;
    decodedLayouts[entry.key as String] = node;
  }
  final decodedStates = <String, Object?>{};
  if (states != null) {
    if (states is! Map<Object?, Object?>) return null;
    for (final entry in states.entries) {
      if (entry.key is! String) return null;
      decodedStates[entry.key as String] = entry.value;
    }
  }
  return _BlenderWorkspaceSession<T>(
    activeWorkspaceId: activeWorkspaceId,
    layouts: decodedLayouts,
    states: decodedStates,
  );
}

BlenderDockNode<T>? _decodeNode<T>(
  Object? encoded,
  BlenderWorkspaceValueCodec<T> valueCodec,
  Set<String> ids,
) {
  if (encoded is! Map<Object?, Object?>) return null;
  final type = encoded['type'];
  final id = encoded['id'];
  if (id is! String || id.isEmpty || !ids.add(id)) return null;
  if (type == 'area') {
    return BlenderDockAreaNode<T>(
      id: id,
      value: valueCodec.fromJson(encoded['value']),
    );
  }
  if (type != 'split') return null;
  final direction = encoded['direction'];
  final fraction = encoded['fraction'];
  if (direction is! String ||
      fraction is! num ||
      fraction <= 0 ||
      fraction >= 1) {
    return null;
  }
  final splitDirection = switch (direction) {
    'horizontal' => BlenderSplitDirection.horizontal,
    'vertical' => BlenderSplitDirection.vertical,
    _ => null,
  };
  if (splitDirection == null) return null;
  final first = _decodeNode(encoded['first'], valueCodec, ids);
  final second = _decodeNode(encoded['second'], valueCodec, ids);
  if (first == null || second == null) return null;
  return BlenderDockSplitNode<T>(
    id: id,
    direction: splitDirection,
    fraction: fraction.toDouble(),
    first: first,
    second: second,
  );
}

/// Renders the active layout from a [BlenderWorkspaceService].
///
/// The host is the reusable bridge between an application workspace switcher
/// and the lower-level [BlenderDockingWorkspace]. The application still owns
/// its editor-area composition; the service supplies the persistent layout.
class BlenderWorkspaceHost<T> extends StatelessWidget {
  const BlenderWorkspaceHost({
    super.key,
    required this.service,
    required this.areaBuilder,
    this.cloneArea,
    this.minimumAreaExtent = 52,
    this.cornerExtent = 14,
  });

  final BlenderWorkspaceService<T> service;
  final BlenderDockAreaBuilder<T> areaBuilder;
  final T Function(T value)? cloneArea;
  final double minimumAreaExtent;
  final double cornerExtent;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) => BlenderDockingWorkspace<T>(
        controller: service.activeController,
        areaBuilder: areaBuilder,
        cloneValue: cloneArea,
        minimumAreaExtent: minimumAreaExtent,
        cornerExtent: cornerExtent,
      ),
    );
  }
}

/// A named, stateful screen owned by an application workspace.
///
/// This is the Flutter equivalent of Blender associating a persistent
/// `bScreen` with a `WorkSpaceLayout`: the widget returned by [builder] is
/// created once per workspace and remains mounted while another workspace is
/// visible.
class BlenderWorkspaceScreen<T> {
  const BlenderWorkspaceScreen({required this.id, required this.builder});

  /// Stable application-owned workspace identifier.
  final T id;

  /// Builds this workspace's screen on its first activation.
  final WidgetBuilder builder;
}

/// Keeps one mounted screen instance for every visited workspace.
///
/// Ordinary conditional widget branches dispose the inactive workspace, which
/// restarts local editor state, scroll positions, pending forms, and provider
/// subscriptions whenever the user returns. This host instead offstages the
/// inactive screen and disables its tickers, matching Blender's retained
/// workspace-screen switching model. Screen widgets are lazy: an unvisited
/// workspace is not initialized until the user selects it.
class BlenderWorkspaceScreenHost<T> extends StatefulWidget {
  const BlenderWorkspaceScreenHost({
    super.key,
    required this.screens,
    required this.activeWorkspaceId,
  });

  final List<BlenderWorkspaceScreen<T>> screens;
  final T activeWorkspaceId;

  @override
  State<BlenderWorkspaceScreenHost<T>> createState() =>
      _BlenderWorkspaceScreenHostState<T>();
}

class _BlenderWorkspaceScreenHostState<T>
    extends State<BlenderWorkspaceScreenHost<T>> {
  final Map<T, Widget> _screens = <T, Widget>{};

  @override
  void didUpdateWidget(covariant BlenderWorkspaceScreenHost<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final activeIds = widget.screens.map((screen) => screen.id).toSet();
    _screens.removeWhere((id, _) => !activeIds.contains(id));
  }

  @override
  Widget build(BuildContext context) {
    final definitions = widget.screens;
    if (definitions.isEmpty) {
      throw ArgumentError.value(
        definitions,
        'screens',
        'At least one workspace screen is required.',
      );
    }
    if (!definitions.any((screen) => screen.id == widget.activeWorkspaceId)) {
      throw ArgumentError.value(
        widget.activeWorkspaceId,
        'activeWorkspaceId',
        'The active workspace must have a declared screen.',
      );
    }
    final seen = <T>{};
    for (final screen in definitions) {
      if (!seen.add(screen.id)) {
        throw ArgumentError.value(
          screen.id,
          'screens',
          'Workspace screen ids must be unique.',
        );
      }
    }

    // Build only the active screen on first visit. Once inserted in this Stack,
    // an inactive screen remains mounted behind Offstage and preserves its
    // State object until the workspace is actually removed from [screens].
    final activeDefinition = definitions.firstWhere(
      (screen) => screen.id == widget.activeWorkspaceId,
    );
    _screens.putIfAbsent(
      activeDefinition.id,
      () => KeyedSubtree(
        key: ValueKey<T>(activeDefinition.id),
        child: Builder(builder: activeDefinition.builder),
      ),
    );

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        for (final screen in definitions)
          if (_screens.containsKey(screen.id))
            Offstage(
              offstage: screen.id != widget.activeWorkspaceId,
              child: TickerMode(
                enabled: screen.id == widget.activeWorkspaceId,
                child: _screens[screen.id]!,
              ),
            ),
      ],
    );
  }
}
