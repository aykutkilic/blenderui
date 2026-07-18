part of '../services.dart';

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

  /// Registers and adopts [service].
  ///
  /// If it implements [BlenderServiceDisposable], this container disposes it
  /// exactly once when the container is disposed. Parent-owned services are
  /// never disposed by a child container.
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
