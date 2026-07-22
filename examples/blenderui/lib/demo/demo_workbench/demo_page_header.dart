part of '../demo_workbench.dart';

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
