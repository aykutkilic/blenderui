import 'package:flutter/foundation.dart';

import 'layout.dart';

/// A node in a Blender-style editor-area layout tree.
abstract class BlenderDockNode<T> {
  const BlenderDockNode({required this.id});

  final String id;
}

/// A leaf editor area.
class BlenderDockAreaNode<T> extends BlenderDockNode<T> {
  const BlenderDockAreaNode({required super.id, required this.value});

  final T value;
}

/// Two editor areas separated by a draggable divider.
class BlenderDockSplitNode<T> extends BlenderDockNode<T> {
  const BlenderDockSplitNode({
    required super.id,
    required this.direction,
    required this.fraction,
    required this.first,
    required this.second,
  });

  final BlenderSplitDirection direction;
  final double fraction;
  final BlenderDockNode<T> first;
  final BlenderDockNode<T> second;
}

enum BlenderDockTarget { none, left, right, top, bottom, center }

enum BlenderDockCorner { topLeft, topRight, bottomLeft, bottomRight }

/// Owns and mutates an immutable editor-area split tree.
class BlenderDockingController<T> extends ChangeNotifier {
  BlenderDockingController({required BlenderDockNode<T> root}) : _root = root;

  BlenderDockNode<T> _root;
  int _nextSerial = 1;

  BlenderDockNode<T> get root => _root;

  void setSplitFraction(String splitId, double fraction) {
    final next = _updateSplitFraction(
      _root,
      splitId,
      fraction.clamp(.05, .95).toDouble(),
    );
    if (identical(next, _root)) return;
    _root = next;
    notifyListeners();
  }

  String? splitArea({
    required String areaId,
    required BlenderSplitDirection direction,
    required double fraction,
    required T newValue,
    required bool newAreaFirst,
  }) {
    final existing = _findArea(_root, areaId);
    if (existing == null) return null;
    final newArea = BlenderDockAreaNode<T>(id: _newId('area'), value: newValue);
    final split = BlenderDockSplitNode<T>(
      id: _newId('split'),
      direction: direction,
      fraction: fraction.clamp(.05, .95).toDouble(),
      first: newAreaFirst ? newArea : existing,
      second: newAreaFirst ? existing : newArea,
    );
    _root = _replaceNode(_root, areaId, split);
    notifyListeners();
    return newArea.id;
  }

  bool dockArea({
    required String sourceAreaId,
    required String targetAreaId,
    required BlenderDockTarget target,
    double factor = .5,
  }) {
    if (sourceAreaId == targetAreaId || target == BlenderDockTarget.none) {
      return false;
    }
    final source = _findArea(_root, sourceAreaId);
    final destination = _findArea(_root, targetAreaId);
    if (source == null || destination == null) return false;

    final withoutSource = _removeArea(_root, sourceAreaId);
    if (withoutSource == null ||
        _findArea(withoutSource, targetAreaId) == null) {
      return false;
    }

    final replacement = target == BlenderDockTarget.center
        ? BlenderDockAreaNode<T>(id: destination.id, value: source.value)
        : _buildDockSplit(source, destination, target, factor);
    _root = _replaceNode(withoutSource, targetAreaId, replacement);
    notifyListeners();
    return true;
  }

  BlenderDockSplitNode<T> _buildDockSplit(
    BlenderDockAreaNode<T> source,
    BlenderDockAreaNode<T> destination,
    BlenderDockTarget target,
    double factor,
  ) {
    final sourceFirst =
        target == BlenderDockTarget.left || target == BlenderDockTarget.top;
    final direction =
        target == BlenderDockTarget.left || target == BlenderDockTarget.right
        ? BlenderSplitDirection.horizontal
        : BlenderSplitDirection.vertical;
    final sourceFraction = factor.clamp(.05, .95).toDouble();
    return BlenderDockSplitNode<T>(
      id: _newId('split'),
      direction: direction,
      fraction: sourceFirst ? sourceFraction : 1 - sourceFraction,
      first: sourceFirst ? source : destination,
      second: sourceFirst ? destination : source,
    );
  }

  BlenderDockAreaNode<T>? _findArea(BlenderDockNode<T> node, String id) {
    if (node is BlenderDockAreaNode<T>) return node.id == id ? node : null;
    final split = node as BlenderDockSplitNode<T>;
    return _findArea(split.first, id) ?? _findArea(split.second, id);
  }

  BlenderDockNode<T> _replaceNode(
    BlenderDockNode<T> node,
    String id,
    BlenderDockNode<T> replacement,
  ) {
    if (node.id == id) return replacement;
    if (node is BlenderDockAreaNode<T>) return node;
    final split = node as BlenderDockSplitNode<T>;
    final first = _replaceNode(split.first, id, replacement);
    final second = _replaceNode(split.second, id, replacement);
    if (identical(first, split.first) && identical(second, split.second)) {
      return node;
    }
    return BlenderDockSplitNode<T>(
      id: split.id,
      direction: split.direction,
      fraction: split.fraction,
      first: first,
      second: second,
    );
  }

  BlenderDockNode<T> _updateSplitFraction(
    BlenderDockNode<T> node,
    String id,
    double fraction,
  ) {
    if (node is BlenderDockAreaNode<T>) return node;
    final split = node as BlenderDockSplitNode<T>;
    if (split.id == id) {
      return BlenderDockSplitNode<T>(
        id: split.id,
        direction: split.direction,
        fraction: fraction,
        first: split.first,
        second: split.second,
      );
    }
    final first = _updateSplitFraction(split.first, id, fraction);
    final second = _updateSplitFraction(split.second, id, fraction);
    if (identical(first, split.first) && identical(second, split.second)) {
      return node;
    }
    return BlenderDockSplitNode<T>(
      id: split.id,
      direction: split.direction,
      fraction: split.fraction,
      first: first,
      second: second,
    );
  }

  BlenderDockNode<T>? _removeArea(BlenderDockNode<T> node, String id) {
    if (node is BlenderDockAreaNode<T>) return node.id == id ? null : node;
    final split = node as BlenderDockSplitNode<T>;
    final first = _removeArea(split.first, id);
    final second = _removeArea(split.second, id);
    if (first == null) return second;
    if (second == null) return first;
    if (identical(first, split.first) && identical(second, split.second)) {
      return node;
    }
    return BlenderDockSplitNode<T>(
      id: split.id,
      direction: split.direction,
      fraction: split.fraction,
      first: first,
      second: second,
    );
  }

  bool _containsId(BlenderDockNode<T> node, String id) {
    if (node.id == id) return true;
    if (node is BlenderDockAreaNode<T>) return false;
    final split = node as BlenderDockSplitNode<T>;
    return _containsId(split.first, id) || _containsId(split.second, id);
  }

  String _newId(String prefix) {
    String candidate;
    do {
      candidate = 'dock-$prefix-${_nextSerial++}';
    } while (_containsId(_root, candidate));
    return candidate;
  }
}
