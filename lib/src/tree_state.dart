/// A flattened entry in a nested Blender data tree.
class BlenderTreeEntry<T> {
  const BlenderTreeEntry(this.value, this.depth);

  final T value;
  final int depth;
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
    void visit(T value, int depth) {
      if (include?.call(value) ?? true) {
        result.add(BlenderTreeEntry<T>(value, depth));
      }
      if (expandWhen?.call(value) ?? expanded.contains(idOf(value))) {
        for (final child in childrenOf(value)) {
          visit(child, depth + 1);
        }
      }
    }

    for (final root in roots) {
      visit(root, 0);
    }
    return result;
  }
}
