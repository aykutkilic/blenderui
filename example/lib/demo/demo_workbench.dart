import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

class DemoWorkbench extends StatefulWidget {
  const DemoWorkbench({super.key, this.onStatus});

  final ValueChanged<String>? onStatus;

  @override
  State<DemoWorkbench> createState() => _DemoWorkbenchState();
}

class _DemoWorkbenchState extends State<DemoWorkbench> {
  late final BlenderHistoryStore<DemoState> _state;
  late final BlenderCommandRegistry _commands;
  late final BlenderServiceContainer _services;
  final TextEditingController _search = TextEditingController();
  final TextEditingController _text = TextEditingController(
    text: 'Editable text',
  );
  final TextEditingController _fileSearch = TextEditingController();
  String _pageId = 'overview';
  String _query = '';

  static const List<_DemoPage> _pages = <_DemoPage>[
    _DemoPage(
      id: 'overview',
      label: 'Overview',
      description: 'Library map and live application state',
      glyph: BlenderGlyph.home,
      keywords: 'features theme desktop state commands',
    ),
    _DemoPage(
      id: 'controls',
      label: 'Controls',
      description: 'Buttons, fields, selection, and feedback',
      glyph: BlenderGlyph.settings,
      keywords: 'button checkbox toggle radio slider input dropdown',
    ),
    _DemoPage(
      id: 'layout',
      label: 'Layout',
      description: 'Panels, grids, tabs, and split regions',
      glyph: BlenderGlyph.grid,
      keywords: 'panel flow grid splitter toolbar tabs',
    ),
    _DemoPage(
      id: 'data',
      label: 'Data & Properties',
      description: 'Descriptors, vectors, lists, and trees',
      glyph: BlenderGlyph.outliner,
      keywords: 'property vector matrix list tree hierarchy',
    ),
    _DemoPage(
      id: 'editors',
      label: 'Editors',
      description: 'Timeline, console, spreadsheet, and files',
      glyph: BlenderGlyph.timeline,
      keywords: 'timeline console spreadsheet file browser animation',
    ),
    _DemoPage(
      id: 'services',
      label: 'App Services',
      description: 'State, history, dependency scopes, and commands',
      glyph: BlenderGlyph.modifier,
      keywords: 'state management undo redo dependency injection command bus',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _state = BlenderHistoryStore<DemoState>(const DemoState());
    _commands = BlenderCommandRegistry();
    _services = BlenderServiceContainer()
      ..registerSingleton<BlenderHistoryStore<DemoState>>(_state)
      ..registerSingleton<BlenderCommandRegistry>(_commands);
    _commands.register(
      BlenderCommand(
        id: 'increment',
        label: 'Increment Counter',
        shortcut: 'Ctrl I',
        execute: () => _change(
          (state) => state.copyWith(counter: state.counter + 1),
          'Counter incremented through command registry',
        ),
      ),
    );
    _commands.register(
      BlenderCommand(
        id: 'reset-demo',
        label: 'Reset Demo State',
        shortcut: 'Ctrl Shift R',
        enabled: () => _state.value != const DemoState(),
        execute: () {
          _state.reset();
          _status('Demo state reset');
        },
      ),
    );
    _state.addListener(_commands.refresh);
  }

  @override
  void dispose() {
    _state.removeListener(_commands.refresh);
    _search.dispose();
    _text.dispose();
    _fileSearch.dispose();
    _services.dispose();
    super.dispose();
  }

  void _status(String message) => widget.onStatus?.call(message);

  void _change(DemoState Function(DemoState) update, String message) {
    _state.update(update);
    _status(message);
  }

  List<_DemoPage> get _visiblePages {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return _pages;
    return _pages
        .where(
          (page) =>
              page.label.toLowerCase().contains(query) ||
              page.description.toLowerCase().contains(query) ||
              page.keywords.contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlenderServiceScope(
      services: _services,
      child: BlenderStateScope<DemoState>(
        store: _state,
        child: ValueListenableBuilder<DemoState>(
          valueListenable: _state,
          builder: (context, state, child) {
            final pages = _visiblePages;
            final activePage = pages.any((page) => page.id == _pageId)
                ? pages.firstWhere((page) => page.id == _pageId)
                : pages.firstOrNull;
            return ColoredBox(
              color: BlenderTheme.of(context).colors.propertiesBackground,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _DemoNavigation(
                    pages: pages,
                    selectedId: activePage?.id,
                    searchController: _search,
                    onSearch: (value) => setState(() => _query = value),
                    onSelected: (page) => setState(() => _pageId = page.id),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _DemoPageHeader(
                          page: activePage,
                          canUndo: _state.canUndo,
                          canRedo: _state.canRedo,
                          onUndo: () {
                            _state.undo();
                            _status('Undo');
                          },
                          onRedo: () {
                            _state.redo();
                            _status('Redo');
                          },
                          onReset: () => _commands.execute('reset-demo'),
                        ),
                        Expanded(
                          child: activePage == null
                              ? const _DemoEmptySearch()
                              : _buildPage(activePage.id, state),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPage(String id, DemoState state) {
    final update = (DemoState next, String message) {
      _state.replace(next);
      _status(message);
    };
    return switch (id) {
      'controls' => _ControlsDemoPage(
        state: state,
        textController: _text,
        onChanged: update,
        onStatus: _status,
      ),
      'layout' => _LayoutDemoPage(state: state, onChanged: update),
      'data' => _DataDemoPage(state: state, onChanged: update),
      'editors' => _EditorsDemoPage(
        state: state,
        fileSearchController: _fileSearch,
        onChanged: update,
        onStatus: _status,
      ),
      'services' => _ServicesDemoPage(state: state, onStatus: _status),
      _ => _OverviewDemoPage(state: state, onStatus: _status),
    };
  }
}

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

class _DemoPageHeader extends StatelessWidget {
  const _DemoPageHeader({
    required this.page,
    required this.canUndo,
    required this.canRedo,
    required this.onUndo,
    required this.onRedo,
    required this.onReset,
  });

  final _DemoPage? page;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colors.surface,
        border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: Row(
        children: <Widget>[
          if (page != null) ...<Widget>[
            BlenderIcon(page!.glyph, size: 20),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(page!.label, style: theme.textTheme.heading),
                  Text(page!.description, style: theme.textTheme.caption),
                ],
              ),
            ),
          ] else
            const Spacer(),
          BlenderIconButton(
            glyph: BlenderGlyph.stepBack,
            enabled: canUndo,
            onPressed: onUndo,
            tooltip: 'Undo demo state',
          ),
          BlenderIconButton(
            glyph: BlenderGlyph.stepForward,
            enabled: canRedo,
            onPressed: onRedo,
            tooltip: 'Redo demo state',
          ),
          BlenderButton(label: 'Reset', enabled: canUndo, onPressed: onReset),
        ],
      ),
    );
  }
}

class _DemoEmptySearch extends StatelessWidget {
  const _DemoEmptySearch();

  @override
  Widget build(BuildContext context) => const Center(
    child: BlenderNoticeBanner(
      message: 'No demo categories match this search.',
      level: BlenderNoticeLevel.info,
    ),
  );
}

class _DemoPageScroll extends StatelessWidget {
  const _DemoPageScroll({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return BlenderScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _DemoSection extends StatelessWidget {
  const _DemoSection({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BlenderPanel(
        title: title,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                description,
                style: theme.textTheme.caption.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewDemoPage extends StatelessWidget {
  const _OverviewDemoPage({required this.state, required this.onStatus});

  final DemoState state;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    return _DemoPageScroll(
      children: <Widget>[
        const BlenderNoticeBanner(
          message:
              'This workbench is interactive. Changes are stored in a scoped '
              'BlenderHistoryStore and can be undone from the page header.',
          level: BlenderNoticeLevel.info,
        ),
        const SizedBox(height: 10),
        const _DemoSection(
          title: 'Feature map',
          description:
              'The package ranges from atomic controls to complete desktop editor surfaces.',
          child: SizedBox(
            height: 204,
            child: BlenderGrid(
              minItemWidth: 180,
              itemHeight: 100,
              children: const <Widget>[
                _FeatureCard(
                  glyph: BlenderGlyph.settings,
                  title: 'Dense controls',
                  detail: 'Buttons, fields, menus, feedback',
                ),
                _FeatureCard(
                  glyph: BlenderGlyph.grid,
                  title: 'Desktop layout',
                  detail: 'Panels, splitters, docking, regions',
                ),
                _FeatureCard(
                  glyph: BlenderGlyph.timeline,
                  title: 'Editor surfaces',
                  detail: 'Timeline, nodes, files, outliner',
                ),
                _FeatureCard(
                  glyph: BlenderGlyph.modifier,
                  title: 'App services',
                  detail: 'State, history, DI, commands',
                ),
              ],
            ),
          ),
        ),
        _DemoSection(
          title: 'Live application snapshot',
          description: 'Every category edits the same immutable demo state.',
          child: BlenderFlow(
            children: <Widget>[
              BlenderKeycap('Counter ${state.counter}'),
              BlenderKeycap('Mode ${state.mode}'),
              BlenderKeycap('Value ${state.amount.toStringAsFixed(2)}'),
              BlenderButton(
                label: 'Run Increment Command',
                onPressed: () async {
                  final registry =
                      BlenderServiceScope.read<BlenderCommandRegistry>(context);
                  await registry.execute('increment');
                  onStatus('Increment command executed');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.glyph,
    required this.title,
    required this.detail,
  });

  final BlenderGlyph glyph;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.surface,
        border: Border.all(color: theme.colors.panelOutline),
        borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(9),
        child: Row(
          children: <Widget>[
            BlenderIcon(glyph, size: 24, color: theme.colors.accentHover),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: theme.textTheme.heading),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlsDemoPage extends StatelessWidget {
  const _ControlsDemoPage({
    required this.state,
    required this.textController,
    required this.onChanged,
    required this.onStatus,
  });

  final DemoState state;
  final TextEditingController textController;
  final void Function(DemoState state, String message) onChanged;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    return _DemoPageScroll(
      children: <Widget>[
        _DemoSection(
          title: 'Buttons and actions',
          description: 'Standard, toolbar, tab, menu, and selected states.',
          child: BlenderFlow(
            children: <Widget>[
              for (final variant in BlenderButtonVariant.values)
                BlenderButton(
                  label: variant.name,
                  variant: variant,
                  onPressed: () => onStatus('${variant.name} button pressed'),
                ),
              BlenderIconButton(
                glyph: BlenderGlyph.settings,
                selected: state.enabled,
                onPressed: () => onChanged(
                  state.copyWith(enabled: !state.enabled),
                  'Icon button toggled',
                ),
                tooltip: 'Toggle enabled state',
              ),
              BlenderButton(
                label: 'Disabled',
                enabled: false,
                onPressed: () {},
              ),
            ],
          ),
        ),
        _DemoSection(
          title: 'Selection controls',
          description: 'Checkbox, toggle, radio, and segmented selection.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlenderFlow(
                children: <Widget>[
                  BlenderCheckbox(
                    value: state.enabled,
                    label: 'Enabled',
                    onChanged: (value) => onChanged(
                      state.copyWith(enabled: value),
                      'Checkbox changed',
                    ),
                  ),
                  BlenderToggle(
                    value: state.toggle,
                    label: 'Toggle',
                    onChanged: (value) => onChanged(
                      state.copyWith(toggle: value),
                      'Toggle changed',
                    ),
                  ),
                  BlenderRadio<String>(
                    value: 'Object',
                    groupValue: state.mode,
                    label: 'Object mode',
                    onChanged: (value) =>
                        onChanged(state.copyWith(mode: value), 'Radio changed'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderSegmentedControl<String>(
                value: state.mode,
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Object', label: 'Object'),
                  BlenderMenuItem<String>(value: 'Edit', label: 'Edit'),
                  BlenderMenuItem<String>(value: 'Sculpt', label: 'Sculpt'),
                ],
                onChanged: (value) =>
                    onChanged(state.copyWith(mode: value), 'Segment changed'),
              ),
            ],
          ),
        ),
        _DemoSection(
          title: 'Numeric and text input',
          description: 'Drag, edit, constrain, and combine compact fields.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: BlenderSlider(
                      value: state.amount,
                      onChanged: (value) => onChanged(
                        state.copyWith(amount: value),
                        'Slider changed',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 130,
                    child: BlenderNumberField(
                      value: state.amount,
                      min: 0,
                      max: 1,
                      step: .01,
                      onChanged: (value) => onChanged(
                        state.copyWith(amount: value),
                        'Number changed',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(child: BlenderTextField(controller: textController)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BlenderDropdown<String>(
                      value: state.mode,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(
                          value: 'Object',
                          label: 'Object',
                        ),
                        BlenderMenuItem<String>(value: 'Edit', label: 'Edit'),
                        BlenderMenuItem<String>(
                          value: 'Sculpt',
                          label: 'Sculpt',
                        ),
                      ],
                      onChanged: (value) => onChanged(
                        state.copyWith(mode: value),
                        'Dropdown changed',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _DemoSection(
          title: 'Feedback surfaces',
          description: 'Notices, progress, tooltips, and shortcut hints.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const BlenderNoticeBanner(
                message: 'Settings were applied successfully.',
                level: BlenderNoticeLevel.success,
              ),
              const SizedBox(height: 6),
              BlenderProgressBar(
                value: state.amount,
                label: 'Building preview',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LayoutDemoPage extends StatelessWidget {
  const _LayoutDemoPage({required this.state, required this.onChanged});

  final DemoState state;
  final void Function(DemoState state, String message) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return _DemoPageScroll(
      children: <Widget>[
        _DemoSection(
          title: 'Flow and grid',
          description: 'Responsive primitives retain Blender desktop density.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlenderFlow(
                children: <Widget>[
                  for (final label in <String>[
                    'Move',
                    'Rotate',
                    'Scale',
                    'Transform',
                  ])
                    BlenderButton(label: label, onPressed: () {}),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 116,
                child: BlenderGrid(
                  minItemWidth: 130,
                  itemHeight: 54,
                  children: <Widget>[
                    for (final glyph in <BlenderGlyph>[
                      BlenderGlyph.object,
                      BlenderGlyph.collection,
                      BlenderGlyph.material,
                      BlenderGlyph.world,
                    ])
                      ColoredBox(
                        color: theme.colors.surface,
                        child: Center(child: BlenderIcon(glyph, size: 24)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _DemoSection(
          title: 'Tabs and breadcrumbs',
          description: 'Header navigation and path presentation.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BlenderTabBar(
                tabs: const <String>['Layout', 'Modeling', 'Sculpting'],
                selectedIndex: state.mode == 'Edit'
                    ? 1
                    : state.mode == 'Sculpt'
                    ? 2
                    : 0,
                onChanged: (index) => onChanged(
                  state.copyWith(
                    mode: const <String>['Object', 'Edit', 'Sculpt'][index],
                  ),
                  'Tab changed',
                ),
              ),
              const SizedBox(height: 8),
              BlenderBreadcrumbs(
                items: const <String>['Scene', 'Collection', 'Cube'],
                onSelected: (_) {},
              ),
            ],
          ),
        ),
        _DemoSection(
          title: 'Resizable regions',
          description:
              'The splitter stabilizes its resize cursor while dragging.',
          child: SizedBox(
            height: 150,
            child: BlenderSplitter(
              first: BlenderRegion(
                title: 'Primary',
                child: ColoredBox(color: theme.colors.surface),
              ),
              second: BlenderRegion(
                title: 'Inspector',
                child: ColoredBox(color: theme.colors.textField),
              ),
              initialFraction: .65,
            ),
          ),
        ),
        const _DemoSection(
          title: 'Nested panels',
          description:
              'Panels can be collapsed, nested, reordered, and searched.',
          child: BlenderPanel(
            title: 'Transform',
            child: Padding(
              padding: EdgeInsets.all(6),
              child: BlenderPanel(
                title: 'Delta Transform',
                initiallyExpanded: false,
                child: SizedBox(height: 28),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DataDemoPage extends StatelessWidget {
  const _DataDemoPage({required this.state, required this.onChanged});

  final DemoState state;
  final void Function(DemoState state, String message) onChanged;

  @override
  Widget build(BuildContext context) {
    return _DemoPageScroll(
      children: <Widget>[
        _DemoSection(
          title: 'Vector template',
          description: 'Compact axis fields remain caller-owned.',
          child: BlenderVectorField(
            values: state.vector,
            onChanged: (value) =>
                onChanged(state.copyWith(vector: value), 'Vector changed'),
          ),
        ),
        _DemoSection(
          title: 'Descriptor-driven Properties',
          description:
              'Property metadata is independent from domain models and can be searched or reordered.',
          child: SizedBox(
            height: 270,
            child: BlenderPropertiesEditor(
              title: 'Object',
              headerLeading: const BlenderIcon(BlenderGlyph.object, size: 18),
              groups: <BlenderPropertyGroup>[
                BlenderPropertyGroup(
                  id: 'demo-transform',
                  title: 'Transform',
                  properties: <BlenderPropertyDescriptor<dynamic>>[
                    BlenderPropertyDescriptor<double>(
                      id: 'amount',
                      label: 'Influence',
                      value: state.amount,
                      editorBuilder: (context, value, changed) =>
                          BlenderNumberField(
                            value: value,
                            min: 0,
                            max: 1,
                            step: .01,
                            onChanged: changed,
                          ),
                      onChanged: (value) => onChanged(
                        state.copyWith(amount: value),
                        'Property changed',
                      ),
                    ),
                    BlenderPropertyDescriptor<bool>(
                      id: 'enabled',
                      label: 'Enabled',
                      value: state.enabled,
                      editorBuilder: (context, value, changed) =>
                          BlenderCheckbox(value: value, onChanged: changed),
                      onChanged: (value) => onChanged(
                        state.copyWith(enabled: value),
                        'Property changed',
                      ),
                    ),
                  ],
                  children: const <BlenderPropertyGroup>[
                    BlenderPropertyGroup(
                      id: 'demo-delta',
                      title: 'Advanced',
                      initiallyExpanded: false,
                      properties: <BlenderPropertyDescriptor<dynamic>>[],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _DemoSection(
          title: 'Lists and trees',
          description: 'Selection, hierarchy guides, and restriction controls.',
          child: SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: BlenderListView<String>(
                    selectedId: state.mode.toLowerCase(),
                    items: const <BlenderListItem<String>>[
                      BlenderListItem<String>(
                        id: 'object',
                        label: 'Object',
                        value: 'Object',
                        icon: BlenderGlyph.object,
                      ),
                      BlenderListItem<String>(
                        id: 'edit',
                        label: 'Edit',
                        value: 'Edit',
                        icon: BlenderGlyph.transform,
                      ),
                      BlenderListItem<String>(
                        id: 'sculpt',
                        label: 'Sculpt',
                        value: 'Sculpt',
                        icon: BlenderGlyph.modifier,
                      ),
                    ],
                    onSelected: (item) => onChanged(
                      state.copyWith(mode: item.value),
                      'List selection changed',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BlenderTree<String>(
                    selectedId: 'cube',
                    showVisibility: true,
                    showLock: true,
                    roots: const <BlenderTreeNode<String>>[
                      BlenderTreeNode<String>(
                        id: 'collection',
                        label: 'Collection',
                        icon: BlenderGlyph.collection,
                        initiallyExpanded: true,
                        children: <BlenderTreeNode<String>>[
                          BlenderTreeNode<String>(
                            id: 'cube',
                            label: 'Cube',
                            value: 'Cube',
                            icon: BlenderGlyph.object,
                          ),
                          BlenderTreeNode<String>(
                            id: 'light',
                            label: 'Light',
                            value: 'Light',
                            icon: BlenderGlyph.light,
                          ),
                        ],
                      ),
                    ],
                    onSelected: (_) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _EditorsDemoPage extends StatelessWidget {
  const _EditorsDemoPage({
    required this.state,
    required this.fileSearchController,
    required this.onChanged,
    required this.onStatus,
  });

  final DemoState state;
  final TextEditingController fileSearchController;
  final void Function(DemoState state, String message) onChanged;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    return _DemoPageScroll(
      children: <Widget>[
        _DemoSection(
          title: 'Timeline',
          description: 'Generic tracks and keyframes with pointer scrubbing.',
          child: BlenderTimeline(
            model: BlenderTimelineModel(
              start: 1,
              end: 120,
              currentFrame: state.frame,
              tracks: const <BlenderTimelineTrack>[
                BlenderTimelineTrack(
                  id: 'cube',
                  label: 'Cube',
                  keyframes: <BlenderTimelineKeyframe>[
                    BlenderTimelineKeyframe(1),
                    BlenderTimelineKeyframe(42),
                    BlenderTimelineKeyframe(96),
                  ],
                ),
                BlenderTimelineTrack(
                  id: 'camera',
                  label: 'Camera',
                  keyframes: <BlenderTimelineKeyframe>[
                    BlenderTimelineKeyframe(20),
                    BlenderTimelineKeyframe(84),
                  ],
                ),
              ],
            ),
            onCurrentFrameChanged: (frame) =>
                onChanged(state.copyWith(frame: frame), 'Timeline scrubbed'),
          ),
        ),
        _DemoSection(
          title: 'Console and spreadsheet',
          description: 'Complete non-3D editor surfaces compose like controls.',
          child: SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: BlenderConsoleEditor(
                    lines: const <BlenderConsoleLine>[
                      BlenderConsoleLine(
                        'Blender UI component workbench',
                        kind: BlenderConsoleLineKind.info,
                      ),
                      BlenderConsoleLine('>>> scene.objects.length'),
                      BlenderConsoleLine('3'),
                    ],
                    onCommand: (value) => onStatus('Console: $value'),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: BlenderSpreadsheetEditor(
                    columns: <BlenderSpreadsheetColumn>[
                      BlenderSpreadsheetColumn(id: 'name', label: 'Name'),
                      BlenderSpreadsheetColumn(id: 'type', label: 'Type'),
                    ],
                    rows: <BlenderSpreadsheetRow>[
                      BlenderSpreadsheetRow(
                        id: 'cube',
                        values: <String>['Cube', 'Mesh'],
                      ),
                      BlenderSpreadsheetRow(
                        id: 'light',
                        values: <String>['Light', 'Point'],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _DemoSection(
          title: 'File browser',
          description: 'Searchable caller-owned entries with list/grid modes.',
          child: SizedBox(
            height: 210,
            child: BlenderFileBrowser(
              searchController: fileSearchController,
              pathSegments: const <String>['/', 'demo', 'assets'],
              entries: const <BlenderFileEntry>[
                BlenderFileEntry(
                  path: '/demo/assets/materials.blend',
                  name: 'materials.blend',
                  detail: '1.2 MB',
                ),
                BlenderFileEntry(
                  path: '/demo/assets/textures',
                  name: 'textures',
                  isDirectory: true,
                  detail: 'Folder',
                ),
              ],
              onSelected: (entry) => onStatus('Selected ${entry.name}'),
              onOpen: (entry) => onStatus('Opened ${entry.name}'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServicesDemoPage extends StatelessWidget {
  const _ServicesDemoPage({required this.state, required this.onStatus});

  final DemoState state;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    final store = BlenderServiceScope.read<BlenderHistoryStore<DemoState>>(
      context,
    );
    final commands = BlenderServiceScope.read<BlenderCommandRegistry>(context);
    return _DemoPageScroll(
      children: <Widget>[
        _DemoSection(
          title: 'Observable state',
          description:
              'BlenderStateStore holds immutable application state and works with ValueListenableBuilder or BlenderStateScope.',
          child: BlenderFlow(
            children: <Widget>[
              BlenderKeycap('Counter ${state.counter}'),
              BlenderButton(
                label: 'Increment directly',
                onPressed: () {
                  store.update(
                    (value) => value.copyWith(counter: value.counter + 1),
                  );
                  onStatus('State store updated');
                },
              ),
              BlenderButton(
                label: 'Increment command',
                onPressed: () => commands.execute('increment'),
              ),
            ],
          ),
        ),
        _DemoSection(
          title: 'Undo and redo history',
          description:
              'BlenderHistoryStore bounds snapshots and invalidates redo after a new edit.',
          child: Row(
            children: <Widget>[
              BlenderButton(
                label: 'Undo (${store.undoHistory.length})',
                enabled: store.canUndo,
                onPressed: store.undo,
              ),
              const SizedBox(width: 6),
              BlenderButton(
                label: 'Redo (${store.redoHistory.length})',
                enabled: store.canRedo,
                onPressed: store.redo,
              ),
              const SizedBox(width: 6),
              BlenderButton(
                label: 'Clear history',
                enabled: store.canUndo || store.canRedo,
                onPressed: store.clearHistory,
              ),
            ],
          ),
        ),
        const _DemoSection(
          title: 'Scoped dependencies',
          description:
              'BlenderServiceContainer supports explicit singleton, lazy-singleton, factory, and child scopes without global state.',
          child: BlenderNoticeBanner(
            message:
                'This page resolved its history store and command registry from BlenderServiceScope.',
            level: BlenderNoticeLevel.success,
          ),
        ),
        _DemoSection(
          title: 'Command registry',
          description:
              'One command definition can drive menus, toolbars, shortcuts, and operator search.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final command in commands.commands)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: <Widget>[
                      Expanded(child: Text(command.label)),
                      if (command.shortcut != null)
                        BlenderKeycap(command.shortcut!),
                      const SizedBox(width: 6),
                      BlenderButton(
                        label: 'Run',
                        enabled: command.isEnabled,
                        onPressed: () => commands.execute(command.id),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
