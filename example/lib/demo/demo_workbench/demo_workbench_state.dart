part of '../demo_workbench.dart';

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
