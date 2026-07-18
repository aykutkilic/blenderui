part of '../services.dart';

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
