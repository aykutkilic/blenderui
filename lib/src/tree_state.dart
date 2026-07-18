/// A flattened entry in a nested Blender data tree.
class BlenderTreeEntry<T> {
  const BlenderTreeEntry(
    this.value,
    this.depth, {
    this.ancestorHasNext = const <bool>[],
    this.isLast = true,
  });

  final T value;
  final int depth;

  /// Whether each ancestor has a following sibling.
  ///
  /// Tree renderers use this topology to draw continuation guides without
  /// reimplementing traversal.
  final List<bool> ancestorHasNext;
  final bool isLast;
}

/// Pure expansion and flattening operations shared by nested editor trees.
///
/// Widgets retain their domain-specific row rendering while this utility owns
/// the otherwise duplicated recursive traversal rules used by node interface,
/// bone collection, and Grease Pencil layer trees.
abstract final class BlenderTreeState {
  static Set<String> initialExpanded<T>(
    Iterable<T> roots, {
    required String Function(T value) idOf,
    required Iterable<T> Function(T value) childrenOf,
    required bool Function(T value) initiallyExpanded,
  }) {
    final expanded = <String>{};
    void visit(T value) {
      if (initiallyExpanded(value)) expanded.add(idOf(value));
      for (final child in childrenOf(value)) {
        visit(child);
      }
    }

    for (final root in roots) {
      visit(root);
    }
    return expanded;
  }

  static List<BlenderTreeEntry<T>> flatten<T>(
    Iterable<T> roots, {
    required String Function(T value) idOf,
    required Iterable<T> Function(T value) childrenOf,
    required Set<String> expanded,
    bool Function(T value)? include,
    bool Function(T value)? expandWhen,
  }) {
    final result = <BlenderTreeEntry<T>>[];
    void visit(T value, int depth, List<bool> ancestorHasNext, bool isLast) {
      if (include?.call(value) ?? true) {
        result.add(
          BlenderTreeEntry<T>(
            value,
            depth,
            ancestorHasNext: List<bool>.unmodifiable(ancestorHasNext),
            isLast: isLast,
          ),
        );
      }
      if (expandWhen?.call(value) ?? expanded.contains(idOf(value))) {
        final children = childrenOf(value).toList(growable: false);
        for (var index = 0; index < children.length; index++) {
          visit(children[index], depth + 1, <bool>[
            ...ancestorHasNext,
            !isLast,
          ], index == children.length - 1);
        }
      }
    }

    final rootList = roots.toList(growable: false);
    for (var index = 0; index < rootList.length; index++) {
      visit(rootList[index], 0, const <bool>[], index == rootList.length - 1);
    }
    return result;
  }
}
