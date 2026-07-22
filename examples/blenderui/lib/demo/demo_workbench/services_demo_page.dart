part of '../demo_workbench.dart';

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
