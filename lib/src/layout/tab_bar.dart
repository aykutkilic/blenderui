part of '../layout.dart';

class BlenderTabBar extends StatelessWidget {
  const BlenderTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.variant = BlenderButtonVariant.tab,
    this.scrollable = true,
    this.allowPointerScroll = true,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final BlenderButtonVariant variant;

  /// Whether the tab row can overflow horizontally.
  ///
  /// Keep this enabled when every tab cannot fit in the available width.
  final bool scrollable;

  /// Whether pointer scroll signals can move a horizontally scrolling row.
  final bool allowPointerScroll;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final entry in tabs.indexed)
          Padding(
            padding: variant == BlenderButtonVariant.tab
                ? EdgeInsets.zero
                : EdgeInsets.only(right: theme.density.spacing),
            child: BlenderTooltip(
              message: entry.$1 == selectedIndex
                  ? 'Active workspace showing in the window.'
                  : 'Switch to ${entry.$2} workspace.',
              child: BlenderButton(
                label: entry.$2,
                variant: variant,
                selected: entry.$1 == selectedIndex,
                onPressed: () => onChanged(entry.$1),
              ),
            ),
          ),
      ],
    );
    return SizedBox(
      height: theme.density.headerHeight,
      child: scrollable
          ? _blenderHeaderScrollSurface(
              context,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: allowPointerScroll
                    ? row
                    : Listener(
                        onPointerSignal: _ignorePointerScroll,
                        child: row,
                      ),
              ),
            )
          : row,
    );
  }

  void _ignorePointerScroll(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (_) {});
  }
}
