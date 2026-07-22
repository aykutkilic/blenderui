part of '../demo_workbench.dart';

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
