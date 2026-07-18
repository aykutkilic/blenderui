part of '../demo_workbench.dart';

class DemoState {
  const DemoState({
    this.enabled = true,
    this.toggle = true,
    this.amount = .42,
    this.mode = 'Object',
    this.counter = 0,
    this.frame = 24,
    this.vector = const <double>[1, 0, 2],
  });

  final bool enabled;
  final bool toggle;
  final double amount;
  final String mode;
  final int counter;
  final double frame;
  final List<double> vector;

  DemoState copyWith({
    bool? enabled,
    bool? toggle,
    double? amount,
    String? mode,
    int? counter,
    double? frame,
    List<double>? vector,
  }) {
    return DemoState(
      enabled: enabled ?? this.enabled,
      toggle: toggle ?? this.toggle,
      amount: amount ?? this.amount,
      mode: mode ?? this.mode,
      counter: counter ?? this.counter,
      frame: frame ?? this.frame,
      vector: vector ?? this.vector,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DemoState &&
      enabled == other.enabled &&
      toggle == other.toggle &&
      amount == other.amount &&
      mode == other.mode &&
      counter == other.counter &&
      frame == other.frame &&
      _listEquals(vector, other.vector);

  @override
  int get hashCode => Object.hash(
    enabled,
    toggle,
    amount,
    mode,
    counter,
    frame,
    Object.hashAll(vector),
  );
}

bool _listEquals(List<double> first, List<double> second) {
  if (first.length != second.length) return false;
  for (var index = 0; index < first.length; index++) {
    if (first[index] != second[index]) return false;
  }
  return true;
}

class _DemoPage {
  const _DemoPage({
    required this.id,
    required this.label,
    required this.description,
    required this.glyph,
    required this.keywords,
  });

  final String id;
  final String label;
  final String description;
  final BlenderGlyph glyph;
  final String keywords;
}

class _DemoNavigation extends StatelessWidget {
  const _DemoNavigation({
    required this.pages,
    required this.selectedId,
    required this.searchController,
    required this.onSearch,
    required this.onSelected,
  });

  final List<_DemoPage> pages;
  final String? selectedId;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final ValueChanged<_DemoPage> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: theme.colors.textField,
        border: Border(right: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8),
            child: BlenderSearchField(
              key: const ValueKey<String>('demo-search'),
              controller: searchController,
              placeholder: 'Find a feature',
              onChanged: onSearch,
            ),
          ),
          Expanded(
            child: BlenderListView<_DemoPage>(
              items: <BlenderListItem<_DemoPage>>[
                for (final page in pages)
                  BlenderListItem<_DemoPage>(
                    id: page.id,
                    label: page.label,
                    detail: page.id == 'services' ? 'NEW' : null,
                    icon: page.glyph,
                    value: page,
                  ),
              ],
              selectedId: selectedId,
              emptyLabel: 'No matching features',
              onSelected: (item) => onSelected(item.value!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${pages.length} categories',
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
