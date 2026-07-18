part of '../services.dart';

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
