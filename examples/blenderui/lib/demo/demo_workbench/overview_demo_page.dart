part of '../demo_workbench.dart';

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
