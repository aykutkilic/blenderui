import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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

/// Built-in color presets carried from blenderapp's interface-theme presets.
///
/// Applications can still provide a custom [BlenderThemeData] as their base
/// theme. This preference only selects the portable Blender Dark or Blender
/// Light palette layered over that base theme.
enum BlenderThemePreset { dark, light }

/// Blender-style outline thickness preference.
///
/// Blender stores this as an offset from the DPI-derived line width. Flutter
/// does not expose that runtime pixel size, so BlenderUI applies the same
/// intent as a multiplier to its outline widths.
enum BlenderInterfaceLineWidth { thin, automatic, thick }

/// Portable color-picker presentations shared by editor applications.
enum BlenderColorPickerType {
  circleHsv,
  circleHsl,
  squareSv,
  squareHs,
  squareHv,
}

/// How normalized factor values should be presented to people.
enum BlenderFactorDisplayType { factor, percentage }

/// Immutable, app-wide interface preferences inspired by blenderapp's
/// `PreferencesView` settings.
///
/// This intentionally contains only settings that can be meaningful to a
/// broad editor application. Domain concerns such as 3D viewport overlays,
/// scene memory statistics, and add-on discovery remain app-owned.
@immutable
class BlenderInterfacePreferences {
  const BlenderInterfacePreferences({
    this.theme = BlenderThemePreset.dark,
    this.uiScale = 1,
    this.lineWidth = BlenderInterfaceLineWidth.automatic,
    this.showSplash = true,
    this.showTooltips = true,
    this.showDeveloperExtras = false,
    this.useRegionOverlap = true,
    this.showCornerHandles = false,
    this.showNumericInputArrows = false,
    this.showNavigationControls = true,
    this.borderWidth = 2,
    this.colorPickerType = BlenderColorPickerType.circleHsv,
    this.factorDisplayType = BlenderFactorDisplayType.factor,
  }) : assert(uiScale >= .5 && uiScale <= 6),
       assert(borderWidth >= 1 && borderWidth <= 10);

  final BlenderThemePreset theme;
  final double uiScale;
  final BlenderInterfaceLineWidth lineWidth;
  final bool showSplash;
  final bool showTooltips;
  final bool showDeveloperExtras;
  final bool useRegionOverlap;
  final bool showCornerHandles;
  final bool showNumericInputArrows;
  final bool showNavigationControls;
  final double borderWidth;
  final BlenderColorPickerType colorPickerType;
  final BlenderFactorDisplayType factorDisplayType;

  BlenderInterfacePreferences copyWith({
    BlenderThemePreset? theme,
    double? uiScale,
    BlenderInterfaceLineWidth? lineWidth,
    bool? showSplash,
    bool? showTooltips,
    bool? showDeveloperExtras,
    bool? useRegionOverlap,
    bool? showCornerHandles,
    bool? showNumericInputArrows,
    bool? showNavigationControls,
    double? borderWidth,
    BlenderColorPickerType? colorPickerType,
    BlenderFactorDisplayType? factorDisplayType,
  }) {
    return BlenderInterfacePreferences(
      theme: theme ?? this.theme,
      uiScale: (uiScale ?? this.uiScale).clamp(.5, 6).toDouble(),
      lineWidth: lineWidth ?? this.lineWidth,
      showSplash: showSplash ?? this.showSplash,
      showTooltips: showTooltips ?? this.showTooltips,
      showDeveloperExtras: showDeveloperExtras ?? this.showDeveloperExtras,
      useRegionOverlap: useRegionOverlap ?? this.useRegionOverlap,
      showCornerHandles: showCornerHandles ?? this.showCornerHandles,
      showNumericInputArrows:
          showNumericInputArrows ?? this.showNumericInputArrows,
      showNavigationControls:
          showNavigationControls ?? this.showNavigationControls,
      borderWidth: (borderWidth ?? this.borderWidth).clamp(1, 10).toDouble(),
      colorPickerType: colorPickerType ?? this.colorPickerType,
      factorDisplayType: factorDisplayType ?? this.factorDisplayType,
    );
  }

  Map<String, Object> toJson() => <String, Object>{
    'version': 1,
    'theme': theme.name,
    'uiScale': uiScale,
    'lineWidth': lineWidth.name,
    'showSplash': showSplash,
    'showTooltips': showTooltips,
    'showDeveloperExtras': showDeveloperExtras,
    'useRegionOverlap': useRegionOverlap,
    'showCornerHandles': showCornerHandles,
    'showNumericInputArrows': showNumericInputArrows,
    'showNavigationControls': showNavigationControls,
    'borderWidth': borderWidth,
    'colorPickerType': colorPickerType.name,
    'factorDisplayType': factorDisplayType.name,
  };

  static BlenderInterfacePreferences? fromJson(Object? value) {
    if (value is! Map<Object?, Object?> || value['version'] != 1) return null;
    final theme = _enumByName(BlenderThemePreset.values, value['theme']);
    final lineWidth = _enumByName(
      BlenderInterfaceLineWidth.values,
      value['lineWidth'],
    );
    final picker = _enumByName(
      BlenderColorPickerType.values,
      value['colorPickerType'],
    );
    final factor = _enumByName(
      BlenderFactorDisplayType.values,
      value['factorDisplayType'],
    );
    final uiScale = value['uiScale'];
    final borderWidth = value['borderWidth'];
    if (theme == null ||
        lineWidth == null ||
        picker == null ||
        factor == null ||
        uiScale is! num ||
        borderWidth is! num) {
      return null;
    }
    bool readBool(String key, bool fallback) =>
        value[key] is bool ? value[key]! as bool : fallback;
    return BlenderInterfacePreferences(
      theme: theme,
      uiScale: uiScale.toDouble().clamp(.5, 6).toDouble(),
      lineWidth: lineWidth,
      showSplash: readBool('showSplash', true),
      showTooltips: readBool('showTooltips', true),
      showDeveloperExtras: readBool('showDeveloperExtras', false),
      useRegionOverlap: readBool('useRegionOverlap', true),
      showCornerHandles: readBool('showCornerHandles', false),
      showNumericInputArrows: readBool('showNumericInputArrows', false),
      showNavigationControls: readBool('showNavigationControls', true),
      borderWidth: borderWidth.toDouble().clamp(1, 10).toDouble(),
      colorPickerType: picker,
      factorDisplayType: factor,
    );
  }

  static T? _enumByName<T extends Enum>(Iterable<T> values, Object? value) {
    if (value is! String) return null;
    for (final candidate in values) {
      if (candidate.name == value) return candidate;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is BlenderInterfacePreferences &&
      other.theme == theme &&
      other.uiScale == uiScale &&
      other.lineWidth == lineWidth &&
      other.showSplash == showSplash &&
      other.showTooltips == showTooltips &&
      other.showDeveloperExtras == showDeveloperExtras &&
      other.useRegionOverlap == useRegionOverlap &&
      other.showCornerHandles == showCornerHandles &&
      other.showNumericInputArrows == showNumericInputArrows &&
      other.showNavigationControls == showNavigationControls &&
      other.borderWidth == borderWidth &&
      other.colorPickerType == colorPickerType &&
      other.factorDisplayType == factorDisplayType;

  @override
  int get hashCode => Object.hash(
    theme,
    uiScale,
    lineWidth,
    showSplash,
    showTooltips,
    showDeveloperExtras,
    useRegionOverlap,
    showCornerHandles,
    showNumericInputArrows,
    showNavigationControls,
    borderWidth,
    colorPickerType,
    factorDisplayType,
  );
}

/// Optional storage adapter for [BlenderInterfacePreferencesService].
class BlenderInterfacePreferencesPersistence {
  const BlenderInterfacePreferencesPersistence({
    required this.storage,
    this.storageKey = 'blenderui.interface-preferences',
  });

  final BlenderPersistentStorage storage;
  final String storageKey;
}

/// Observable, persistable interface preferences shared across an app.
///
/// The service is intentionally app-scoped rather than global. Hosts choose
/// their own storage implementation and may register the service in a
/// [BlenderApplicationController] or use it around a smaller window subtree.
class BlenderInterfacePreferencesService extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderInterfacePreferencesService({
    BlenderInterfacePreferences initial = const BlenderInterfacePreferences(),
    this.persistence,
  }) : _value = initial;

  final BlenderInterfacePreferencesPersistence? persistence;
  BlenderInterfacePreferences _value;
  Future<bool>? _restoreFuture;
  Future<void> _pendingWrite = Future<void>.value();
  bool _writeScheduled = false;
  bool _disposed = false;

  BlenderInterfacePreferences get value => _value;
  Object? lastPersistenceError;

  bool replace(BlenderInterfacePreferences next) {
    if (_value == next) return false;
    _value = next;
    notifyListeners();
    _scheduleWrite();
    return true;
  }

  bool update(
    BlenderInterfacePreferences Function(BlenderInterfacePreferences value)
    change,
  ) => replace(change(_value));

  Future<bool> restore() => _restoreFuture ??= _restore();

  Future<bool> _restore() async {
    final persistence = this.persistence;
    if (persistence == null) return false;
    try {
      final raw = await persistence.storage.read(persistence.storageKey);
      if (raw == null || raw.isEmpty) return false;
      final restored = BlenderInterfacePreferences.fromJson(jsonDecode(raw));
      if (restored == null) return false;
      _value = restored;
      lastPersistenceError = null;
      notifyListeners();
      return true;
    } catch (error) {
      lastPersistenceError = error;
      return false;
    }
  }

  Future<void> flush() {
    final persistence = this.persistence;
    if (persistence == null) return Future<void>.value();
    _writeScheduled = false;
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await persistence.storage.write(
          persistence.storageKey,
          jsonEncode(_value.toJson()),
        );
        lastPersistenceError = null;
      } catch (error) {
        lastPersistenceError = error;
      }
    });
    return _pendingWrite;
  }

  Future<void> clearPersistedPreferences() async {
    final persistence = this.persistence;
    if (persistence == null) return;
    _writeScheduled = false;
    try {
      await persistence.storage.remove(persistence.storageKey);
      lastPersistenceError = null;
    } catch (error) {
      lastPersistenceError = error;
    }
  }

  void _scheduleWrite() {
    if (_disposed || persistence == null || _writeScheduled) return;
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
    unawaited(flush());
    super.dispose();
  }
}

/// The severity associated with the current application status message.
enum BlenderStatusLevel { info, success, warning, error }

/// Immutable status-bar message managed by [BlenderStatusService].
class BlenderStatusMessage {
  const BlenderStatusMessage({
    required this.text,
    this.level = BlenderStatusLevel.info,
  });

  final String text;
  final BlenderStatusLevel level;
}

/// Application-wide status reporting service.
///
/// Commands and editor views can report progress or failures without knowing
/// which status-bar widget a host application has chosen to render.
class BlenderStatusService extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderStatusMessage? _message;

  BlenderStatusMessage? get message => _message;

  void report(
    String text, {
    BlenderStatusLevel level = BlenderStatusLevel.info,
  }) {
    final next = text.isEmpty
        ? null
        : BlenderStatusMessage(text: text, level: level);
    if (_message?.text == next?.text && _message?.level == next?.level) return;
    _message = next;
    notifyListeners();
  }

  void clear() {
    if (_message == null) return;
    _message = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _message = null;
    super.dispose();
  }
}

/// A small observable state holder for desktop applications that do not need
/// a third-party state-management dependency.
///
/// State stays caller-defined and immutable. Widgets can listen with
/// [ValueListenableBuilder], or retrieve a scoped store through
/// [BlenderStateScope].
class BlenderStateStore<T> extends ChangeNotifier
    implements ValueListenable<T>, BlenderServiceDisposable {
  BlenderStateStore(T initialValue, {BlenderStateEquality<T>? equals})
    : _initialValue = initialValue,
      _value = initialValue,
      _equals = equals ?? _defaultEquals;

  final T _initialValue;
  final BlenderStateEquality<T> _equals;
  T _value;

  static bool _defaultEquals<T>(T previous, T next) => previous == next;

  T get initialValue => _initialValue;

  @override
  T get value => _value;

  /// Replaces the current state and returns whether listeners were notified.
  @mustCallSuper
  bool replace(T next) {
    if (_equals(_value, next)) return false;
    _value = next;
    notifyListeners();
    return true;
  }

  bool update(BlenderStateUpdater<T> update) => replace(update(_value));

  bool reset() => replace(_initialValue);

  @protected
  bool valuesEqual(T previous, T next) => _equals(previous, next);
}

/// Observable state with bounded undo and redo history.
class BlenderHistoryStore<T> extends BlenderStateStore<T> {
  BlenderHistoryStore(
    super.initialValue, {
    super.equals,
    this.historyLimit = 50,
  }) : assert(historyLimit > 0);

  final int historyLimit;
  final List<T> _undo = <T>[];
  final List<T> _redo = <T>[];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;
  List<T> get undoHistory => List<T>.unmodifiable(_undo);
  List<T> get redoHistory => List<T>.unmodifiable(_redo);

  @override
  bool replace(T next) {
    if (valuesEqual(value, next)) return false;
    _undo.add(value);
    if (_undo.length > historyLimit) _undo.removeAt(0);
    _redo.clear();
    return super.replace(next);
  }

  bool undo() {
    if (!canUndo) return false;
    final previous = _undo.removeLast();
    _redo.add(value);
    return super.replace(previous);
  }

  bool redo() {
    if (!canRedo) return false;
    final next = _redo.removeLast();
    _undo.add(value);
    return super.replace(next);
  }

  void clearHistory() {
    if (!canUndo && !canRedo) return;
    _undo.clear();
    _redo.clear();
    notifyListeners();
  }
}

/// Durable editor context that is shared by editor views, an Outliner, and a
/// Properties surface.
///
/// Values are stable application identifiers rather than domain objects. This
/// keeps persistence generic: applications can resolve an object identifier to
/// their own model after startup.
class BlenderEditorSessionService extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderEditorSessionService({this.persistence});

  final BlenderEditorSessionPersistence? persistence;
  final Map<String, String> _viewsByArea = <String, String>{};
  final Map<String, String> _outlinerSelectionByWorkspace = <String, String>{};
  final Map<String, String> _propertiesTargetByWorkspace = <String, String>{};
  Future<bool>? _restoreFuture;
  Future<void> _pendingWrite = Future<void>.value();
  bool _writeScheduled = false;
  bool _disposed = false;

  /// The last persistence error. Editor state remains available in memory when
  /// persistence fails.
  Object? lastPersistenceError;

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

  Future<bool> restore() => _restoreFuture ??= _restore();

  Future<bool> _restore() async {
    final persistence = this.persistence;
    if (persistence == null) return false;
    try {
      final raw = await persistence.storage.read(persistence.storageKey);
      if (raw == null || raw.isEmpty) return false;
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
      lastPersistenceError = null;
      notifyListeners();
      return true;
    } catch (error) {
      lastPersistenceError = error;
      return false;
    }
  }

  Future<void> flush() {
    final persistence = this.persistence;
    if (persistence == null) return Future<void>.value();
    _writeScheduled = false;
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await persistence.storage.write(
          persistence.storageKey,
          jsonEncode(<String, Object?>{
            'version': 1,
            'viewsByArea': _viewsByArea,
            'outlinerSelectionByWorkspace': _outlinerSelectionByWorkspace,
            'propertiesTargetByWorkspace': _propertiesTargetByWorkspace,
          }),
        );
        lastPersistenceError = null;
      } catch (error) {
        lastPersistenceError = error;
      }
    });
    return _pendingWrite;
  }

  Future<void> clearPersistedSession() async {
    final persistence = this.persistence;
    if (persistence == null) return;
    _writeScheduled = false;
    try {
      await persistence.storage.remove(persistence.storageKey);
      lastPersistenceError = null;
    } catch (error) {
      lastPersistenceError = error;
    }
  }

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
    final persistence = this.persistence;
    if (persistence == null || _writeScheduled) return;
    _writeScheduled = true;
    scheduleMicrotask(() {
      if (_disposed || !_writeScheduled) return;
      unawaited(flush());
    });
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
    unawaited(flush());
    super.dispose();
  }
}

/// Storage configuration for [BlenderEditorSessionService].
class BlenderEditorSessionPersistence {
  const BlenderEditorSessionPersistence({
    required this.storage,
    required this.storageKey,
  }) : assert(storageKey != '');

  final BlenderPersistentStorage storage;
  final String storageKey;
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

/// Provides a typed state store to a widget subtree.
class BlenderStateScope<T> extends InheritedNotifier<BlenderStateStore<T>> {
  const BlenderStateScope({
    super.key,
    required BlenderStateStore<T> store,
    required super.child,
  }) : super(notifier: store);

  static BlenderStateStore<T> watch<T>(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<BlenderStateScope<T>>();
    if (scope == null) {
      throw FlutterError('No BlenderStateScope<$T> found in this context.');
    }
    return scope.notifier!;
  }

  static BlenderStateStore<T> read<T>(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<BlenderStateScope<T>>();
    final scope = element?.widget as BlenderStateScope<T>?;
    if (scope == null) {
      throw FlutterError('No BlenderStateScope<$T> found in this context.');
    }
    return scope.notifier!;
  }
}

class _BlenderServiceBinding {
  _BlenderServiceBinding({
    required this.factory,
    required this.singleton,
    this.instance,
  });

  final Object Function(BlenderServiceContainer services) factory;
  final bool singleton;
  Object? instance;
  bool resolving = false;
}

/// A scoped dependency container with singleton, lazy-singleton, and factory
/// registrations.
///
/// Containers are explicit objects rather than process-wide globals. A child
/// can inherit application services from [parent] and override only what its
/// editor or window needs.
class BlenderServiceContainer implements BlenderServiceDisposable {
  BlenderServiceContainer({this.parent});

  final BlenderServiceContainer? parent;
  final Map<Type, _BlenderServiceBinding> _bindings =
      <Type, _BlenderServiceBinding>{};
  bool _disposed = false;

  bool get isDisposed => _disposed;

  void registerSingleton<T extends Object>(T service) {
    _register<T>(
      _BlenderServiceBinding(
        factory: (_) => service,
        singleton: true,
        instance: service,
      ),
    );
  }

  void registerLazySingleton<T extends Object>(
    BlenderServiceFactory<T> factory,
  ) {
    _register<T>(_BlenderServiceBinding(factory: factory, singleton: true));
  }

  void registerFactory<T extends Object>(BlenderServiceFactory<T> factory) {
    _register<T>(_BlenderServiceBinding(factory: factory, singleton: false));
  }

  void _register<T extends Object>(_BlenderServiceBinding binding) {
    _ensureActive();
    if (_bindings.containsKey(T)) {
      throw StateError('A service for $T is already registered.');
    }
    _bindings[T] = binding;
  }

  bool contains<T extends Object>() =>
      _bindings.containsKey(T) || (parent?.contains<T>() ?? false);

  T get<T extends Object>() {
    _ensureActive();
    final binding = _bindings[T];
    if (binding == null) {
      final ancestor = parent;
      if (ancestor != null) return ancestor.get<T>();
      throw StateError('No service for $T is registered.');
    }
    final cached = binding.instance;
    if (cached != null) return cached as T;
    if (binding.resolving) {
      throw StateError('Circular dependency while resolving $T.');
    }
    binding.resolving = true;
    try {
      final service = binding.factory(this) as T;
      if (binding.singleton) binding.instance = service;
      return service;
    } finally {
      binding.resolving = false;
    }
  }

  T? maybeGet<T extends Object>() => contains<T>() ? get<T>() : null;

  BlenderServiceContainer createChild() =>
      BlenderServiceContainer(parent: this);

  void _ensureActive() {
    if (_disposed) throw StateError('The service container is disposed.');
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final binding in _bindings.values.toList().reversed) {
      final instance = binding.instance;
      if (instance is BlenderServiceDisposable) instance.dispose();
    }
    _bindings.clear();
  }
}

/// Provides a [BlenderServiceContainer] to a widget subtree.
class BlenderServiceScope extends InheritedWidget {
  const BlenderServiceScope({
    super.key,
    required this.services,
    required super.child,
  });

  final BlenderServiceContainer services;

  static BlenderServiceContainer containerOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<BlenderServiceScope>();
    if (scope == null) {
      throw FlutterError('No BlenderServiceScope found in this context.');
    }
    return scope.services;
  }

  static T read<T extends Object>(BuildContext context) =>
      containerOf(context).get<T>();

  static T? maybeRead<T extends Object>(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<BlenderServiceScope>()
      ?.services
      .maybeGet<T>();

  @override
  bool updateShouldNotify(BlenderServiceScope oldWidget) =>
      !identical(services, oldWidget.services);
}

/// Metadata and executable behavior for menus, toolbars, shortcuts, and
/// command search surfaces.
class BlenderCommand {
  const BlenderCommand({
    required this.id,
    required this.label,
    required this.execute,
    this.description,
    this.shortcut,
    this.enabled,
  });

  final String id;
  final String label;
  final String? description;
  final String? shortcut;
  final BlenderCommandCallback execute;
  final bool Function()? enabled;

  bool get isEnabled => enabled?.call() ?? true;
}

/// Application-level command catalog that can back buttons, menus, keymaps,
/// and operator search without coupling those surfaces to domain objects.
class BlenderCommandRegistry extends ChangeNotifier
    implements BlenderServiceDisposable {
  final LinkedHashMap<String, BlenderCommand> _commands =
      LinkedHashMap<String, BlenderCommand>();

  List<BlenderCommand> get commands =>
      List<BlenderCommand>.unmodifiable(_commands.values);

  void register(BlenderCommand command) {
    if (_commands.containsKey(command.id)) {
      throw StateError('A command with id "${command.id}" already exists.');
    }
    _commands[command.id] = command;
    notifyListeners();
  }

  bool unregister(String id) {
    final removed = _commands.remove(id) != null;
    if (removed) notifyListeners();
    return removed;
  }

  BlenderCommand? operator [](String id) => _commands[id];

  Future<bool> execute(String id) async {
    final command = _commands[id];
    if (command == null || !command.isEnabled) return false;
    await command.execute();
    notifyListeners();
    return true;
  }

  /// Re-evaluates command enablement after external state changes.
  void refresh() => notifyListeners();
}

/// Intent emitted by [BlenderCommandBindingScope] for a registered command.
class BlenderCommandIntent extends Intent {
  const BlenderCommandIntent(this.commandId);

  final String commandId;
}

/// One keyboard binding from a Flutter shortcut activator to a command id.
class BlenderCommandBinding {
  const BlenderCommandBinding({
    required this.commandId,
    required this.activator,
  });

  final String commandId;
  final ShortcutActivator activator;
}

/// Command-keymap service analogous to blenderapp's operator keymaps.
///
/// It intentionally binds stable command ids rather than widget callbacks, so
/// menus, keyboard shortcuts, and command search execute the same operation.
class BlenderCommandBindings extends ChangeNotifier
    implements BlenderServiceDisposable {
  final LinkedHashMap<ShortcutActivator, String> _bindings =
      LinkedHashMap<ShortcutActivator, String>();

  List<BlenderCommandBinding> get bindings =>
      List<BlenderCommandBinding>.unmodifiable(
        _bindings.entries.map(
          (entry) => BlenderCommandBinding(
            commandId: entry.value,
            activator: entry.key,
          ),
        ),
      );

  Map<ShortcutActivator, Intent> get shortcuts => <ShortcutActivator, Intent>{
    for (final entry in _bindings.entries)
      entry.key: BlenderCommandIntent(entry.value),
  };

  /// Returns the command currently assigned to [activator], if any.
  ///
  /// Hosts use this to retain application-specific overrides when installing
  /// their default keymap.
  String? commandFor(ShortcutActivator activator) => _bindings[activator];

  void register(BlenderCommandBinding binding) {
    if (_bindings.containsKey(binding.activator)) {
      throw StateError(
        'A command binding already exists for ${binding.activator}.',
      );
    }
    _bindings[binding.activator] = binding.commandId;
    notifyListeners();
  }

  bool unregister(ShortcutActivator activator) {
    final removed = _bindings.remove(activator) != null;
    if (removed) notifyListeners();
    return removed;
  }

  @override
  void dispose() {
    _bindings.clear();
    super.dispose();
  }
}

/// Installs [BlenderCommandBindings] for one app or window subtree.
class BlenderCommandBindingScope extends StatelessWidget {
  const BlenderCommandBindingScope({
    super.key,
    required this.commands,
    required this.bindings,
    required this.child,
  });

  final BlenderCommandRegistry commands;
  final BlenderCommandBindings bindings;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: bindings,
      builder: (context, _) => Shortcuts(
        shortcuts: bindings.shortcuts,
        child: Actions(
          actions: <Type, Action<Intent>>{
            BlenderCommandIntent: CallbackAction<BlenderCommandIntent>(
              onInvoke: (intent) {
                unawaited(commands.execute(intent.commandId));
                return null;
              },
            ),
          },
          child: child,
        ),
      ),
    );
  }
}
