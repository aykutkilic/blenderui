import 'dart:async';
import 'dart:collection';

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
