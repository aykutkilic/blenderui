part of '../advanced_controls.dart';

/// The compact menu used by Properties headers to choose which context tabs
/// are visible. It opens on hover like Blender and remains usable by click.
class BlenderPropertyTabVisibilityMenu extends StatelessWidget {
  const BlenderPropertyTabVisibilityMenu({
    super.key,
    required this.tabs,
    required this.visibleTabIds,
    required this.onVisibilityChanged,
    this.size = 28,
  });

  final List<BlenderPropertyTab> tabs;
  final Set<String> visibleTabIds;
  final ValueChanged<Set<String>> onVisibilityChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPopover(
      openOnHover: true,
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      child: BlenderIconButton(
        glyph: BlenderGlyph.panelDisclosureDown,
        size: size,
        iconSize: 9,
        tooltip: 'Show visible Properties tabs',
      ),
      popover: (context, close) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 238, maxHeight: 540),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.menuBackground,
            border: Border.all(color: theme.colors.borderSubtle),
            borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Visible Tabs',
                  style: theme.textTheme.body.copyWith(
                    color: theme.colors.foregroundMuted,
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 475),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        for (final tab in tabs)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 26,
                                  child: BlenderIcon(
                                    tab.glyph,
                                    size: 16,
                                    color: _propertyTabIconColor(
                                      theme.colors,
                                      tab.glyph,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    tab.label,
                                    style: theme.textTheme.body.copyWith(
                                      color: theme.colors.foregroundMuted,
                                    ),
                                  ),
                                ),
                                BlenderCheckbox(
                                  value: visibleTabIds.contains(tab.id),
                                  onChanged: (visible) {
                                    final updated = Set<String>.of(
                                      visibleTabIds,
                                    );
                                    if (visible) {
                                      updated.add(tab.id);
                                    } else if (updated.length > 1) {
                                      updated.remove(tab.id);
                                    }
                                    onVisibilityChanged(updated);
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BlenderPropertyTabs extends StatefulWidget {
  const BlenderPropertyTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.width = 36,
    // Context tiles occupy the rail instead of leaving a second dark gutter
    // between the tab and the Properties content. Callers can still opt into
    // a smaller tile when building a deliberately padded custom rail.
    this.tileSize = 36,
    this.visibleTabIds,
    this.onVisibilityChanged,
  });

  final List<BlenderPropertyTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double width;
  final double tileSize;
  final Set<String>? visibleTabIds;
  final ValueChanged<Set<String>>? onVisibilityChanged;

  @override
  State<BlenderPropertyTabs> createState() => _BlenderPropertyTabsState();
}

class _BlenderPropertyTabsState extends State<BlenderPropertyTabs> {
  late final ScrollController _scrollController;
  bool _showTopFade = false;
  bool _showBottomFade = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_syncFadeState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFadeState());
  }

  void _syncFadeState() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final showTop = position.pixels > 1;
    final showBottom = position.pixels < position.maxScrollExtent - 1;
    if (showTop == _showTopFade && showBottom == _showBottomFade) return;
    if (!mounted) return;
    setState(() {
      _showTopFade = showTop;
      _showBottomFade = showBottom;
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_syncFadeState)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = widget.tabs;
    final selectedIndex = widget.selectedIndex;
    final width = widget.width;
    final tileSize = widget.tileSize;
    final visibleTabIds = widget.visibleTabIds;
    final onVisibilityChanged = widget.onVisibilityChanged;
    final theme = BlenderTheme.of(context);
    final visibleEntries = <MapEntry<int, List<int>>>[];
    for (var index = 0; index < tabs.length; index++) {
      if (visibleTabIds != null && !visibleTabIds.contains(tabs[index].id)) {
        continue;
      }
      final existing = visibleEntries.indexWhere(
        (entry) => entry.key == tabs[index].group,
      );
      if (existing == -1) {
        visibleEntries.add(
          MapEntry<int, List<int>>(tabs[index].group, <int>[index]),
        );
      } else {
        visibleEntries[existing].value.add(index);
      }
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        // Blender's context tabs sit on one uninterrupted, near-black strip.
        // Their groups are defined by small vertical breathing room, not by
        // individual rounded containers or outlines.
        color: theme.colors.tab,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(1, 0),
            blurRadius: 1,
          ),
        ],
      ),
      child: SizedBox(
        width: width,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: <Widget>[
                  ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: false),
                    child: ListView(
                      key: const ValueKey<String>('property-tabs-scroll'),
                      controller: _scrollController,
                      // An attached Properties rail shares the editor's top
                      // edge. Keep a one-pixel seam on the outer edge, while
                      // the content edge stays flush with the pane.
                      padding: const EdgeInsets.fromLTRB(1, 0, 0, 5),
                      children: <Widget>[
                        for (
                          var groupIndex = 0;
                          groupIndex < visibleEntries.length;
                          groupIndex++
                        ) ...<Widget>[
                          if (groupIndex > 0) const SizedBox(height: 4),
                          DecoratedBox(
                            decoration: const BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  color: Color(0x38000000),
                                  offset: Offset(0, 1),
                                  blurRadius: 1,
                                ),
                              ],
                            ),
                            child: Column(
                              children: <Widget>[
                                for (final index
                                    in visibleEntries[groupIndex].value)
                                  _BlenderPropertyTabButton(
                                    tab: tabs[index],
                                    selected: index == selectedIndex,
                                    size: tileSize
                                        .clamp(1, width - 1)
                                        .toDouble(),
                                    onPressed: () => widget.onChanged(index),
                                  ),
                              ],
                            ),
                          ),
                        ],
                        if (visibleTabIds != null &&
                            onVisibilityChanged != null) ...<Widget>[
                          const SizedBox(height: 3),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: BlenderPropertyTabVisibilityMenu(
                              tabs: tabs,
                              visibleTabIds: visibleTabIds,
                              onVisibilityChanged: onVisibilityChanged,
                              size: tileSize.clamp(1, width - 1).toDouble(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_showTopFade)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      height: 18,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                theme.colors.tab,
                                theme.colors.tab.withAlpha(0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_showBottomFade)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 18,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: <Color>[
                                theme.colors.tab,
                                theme.colors.tab.withAlpha(0),
                              ],
                            ),
                          ),
                        ),
                      ),
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

class _BlenderPropertyTabButton extends StatefulWidget {
  const _BlenderPropertyTabButton({
    required this.tab,
    required this.selected,
    required this.size,
    required this.onPressed,
  });

  final BlenderPropertyTab tab;
  final bool selected;
  final double size;
  final VoidCallback onPressed;

  @override
  State<_BlenderPropertyTabButton> createState() =>
      _BlenderPropertyTabButtonState();
}

class _BlenderPropertyTabButtonState extends State<_BlenderPropertyTabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    // `wcol_tab` in Blender keeps the outline and unselected fill identical.
    // Inset the outer edge, but let the content edge meet the neighboring
    // editor so the selected tab reads as an attached surface.
    final background = widget.selected || _hovered
        ? theme.colors.tabSelected
        : theme.colors.tab;
    return BlenderTooltip(
      message: widget.tab.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: SizedBox(
            key: ValueKey<String>('property-tab-${widget.tab.id}'),
            width: widget.size,
            height: widget.size,
            child: Padding(
              padding: widget.selected || _hovered
                  ? const EdgeInsets.only(left: 1, top: 1, bottom: 1)
                  : EdgeInsets.zero,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    bottomLeft: Radius.circular(3),
                  ),
                ),
                child: Center(
                  child: BlenderIcon(
                    widget.tab.glyph,
                    size: 15,
                    color: _propertyTabIconColor(
                      theme.colors,
                      widget.tab.glyph,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
