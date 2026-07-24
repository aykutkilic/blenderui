part of '../services.dart';

/// Durable editor context that is shared by editor views, an Outliner, and a
/// Properties surface.
///
/// Values are stable application identifiers rather than domain objects. This
/// keeps persistence generic: applications can resolve an object identifier to
/// their own model after startup.
class BlenderEditorSessionService extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderEditorSessionService({this.persistence}) {
    final persistence = this.persistence;
    if (persistence != null) {
      _persistenceCoordinator = BlenderPersistenceCoordinator(
        storage: persistence.storage,
        storageKey: persistence.storageKey,
        serialize: () => jsonEncode(<String, Object?>{
          'version': 1,
          'viewsByArea': _viewsByArea,
          'outlinerSelectionByWorkspace': _outlinerSelectionByWorkspace,
          'propertiesTargetByWorkspace': _propertiesTargetByWorkspace,
        }),
      );
    }
  }

  final BlenderEditorSessionPersistence? persistence;
  final Map<String, String> _viewsByArea = <String, String>{};
  final Map<String, String> _outlinerSelectionByWorkspace = <String, String>{};
  final Map<String, String> _propertiesTargetByWorkspace = <String, String>{};
  BlenderPersistenceCoordinator? _persistenceCoordinator;
  bool _disposed = false;

  /// The last persistence error. Editor state remains available in memory when
  /// persistence fails.
  Object? get lastPersistenceError => _persistenceCoordinator?.lastError;

  String? viewForArea({required String workspaceId, required String areaId}) =>
      _viewsByArea[_areaKey(workspaceId, areaId)];

  bool selectView({
    required String workspaceId,
    required String areaId,
    required String viewId,
  }) {
    final key = _areaKey(workspaceId, areaId);
    if (_viewsByArea[key] == viewId) return false;
    _viewsByArea[key] = viewId;
    _changed();
    return true;
  }

  String? outlinerSelectionFor(String workspaceId) =>
      _outlinerSelectionByWorkspace[workspaceId];

  bool selectOutlinerItem(String workspaceId, String? itemId) =>
      _replaceWorkspaceValue(
        _outlinerSelectionByWorkspace,
        workspaceId,
        itemId,
      );

  String? propertiesTargetFor(String workspaceId) =>
      _propertiesTargetByWorkspace[workspaceId];

  bool inspectPropertiesTarget(String workspaceId, String? targetId) =>
      _replaceWorkspaceValue(
        _propertiesTargetByWorkspace,
        workspaceId,
        targetId,
      );

  Future<bool> restore() {
    final coordinator = _persistenceCoordinator;
    if (coordinator == null) return Future<bool>.value(false);
    return coordinator.restore((raw) {
      final root = jsonDecode(raw);
      if (root is! Map<Object?, Object?> || root['version'] != 1) return false;
      final views = _stringMap(root['viewsByArea']);
      final outliner = _stringMap(root['outlinerSelectionByWorkspace']);
      final properties = _stringMap(root['propertiesTargetByWorkspace']);
      if (views == null || outliner == null || properties == null) return false;
      _viewsByArea
        ..clear()
        ..addAll(views);
      _outlinerSelectionByWorkspace
        ..clear()
        ..addAll(outliner);
      _propertiesTargetByWorkspace
        ..clear()
        ..addAll(properties);
      notifyListeners();
      return true;
    });
  }

  Future<void> flush() =>
      _persistenceCoordinator?.flush() ?? Future<void>.value();

  Future<void> clearPersistedSession() =>
      _persistenceCoordinator?.clear() ?? Future<void>.value();

  bool _replaceWorkspaceValue(
    Map<String, String> values,
    String workspaceId,
    String? next,
  ) {
    final current = values[workspaceId];
    if (current == next) return false;
    if (next == null || next.isEmpty) {
      values.remove(workspaceId);
    } else {
      values[workspaceId] = next;
    }
    _changed();
    return true;
  }

  void _changed() {
    if (_disposed) return;
    notifyListeners();
    _persistenceCoordinator?.scheduleWrite();
  }

  static String _areaKey(String workspaceId, String areaId) =>
      '$workspaceId::$areaId';

  static Map<String, String>? _stringMap(Object? value) {
    if (value is! Map<Object?, Object?>) return null;
    final result = <String, String>{};
    for (final entry in value.entries) {
      if (entry.key is! String || entry.value is! String) return null;
      result[entry.key as String] = entry.value as String;
    }
    return result;
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    final coordinator = _persistenceCoordinator;
    if (coordinator != null) unawaited(coordinator.dispose());
    super.dispose();
  }
}

/// Storage configuration for [BlenderEditorSessionService].
class BlenderEditorSessionPersistence extends BlenderPersistenceConfiguration {
  const BlenderEditorSessionPersistence({
    required super.storage,
    required super.storageKey,
  });
}

/// Provides observable editor-session context to an editor workspace subtree.
///
/// Use [watch] from an editor view that should rebuild as selection or active
/// view context changes. Use [read] from event handlers that only need to issue
/// a session update.
class BlenderEditorSessionScope
    extends InheritedNotifier<BlenderEditorSessionService> {
  const BlenderEditorSessionScope({
    super.key,
    required BlenderEditorSessionService session,
    required super.child,
  }) : super(notifier: session);

  static BlenderEditorSessionService watch(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<BlenderEditorSessionScope>();
    if (scope == null) {
      throw FlutterError('No BlenderEditorSessionScope found in this context.');
    }
    return scope.notifier!;
  }

  static BlenderEditorSessionService read(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<BlenderEditorSessionScope>();
    final scope = element?.widget as BlenderEditorSessionScope?;
    if (scope == null) {
      throw FlutterError('No BlenderEditorSessionScope found in this context.');
    }
    return scope.notifier!;
  }
}
