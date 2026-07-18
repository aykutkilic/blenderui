part of '../non3d_editors.dart';

/// A standalone Preferences surface modelled after Blender's temporary
/// Preferences window.
///
/// It keeps navigation and filtering local to the window, allowing callers to
/// open Preferences from a menu without coupling that transient state to the
/// surrounding editor layout. The same [BlenderPreferenceSection] descriptors
/// are shared with [BlenderPreferencesEditor], so an application can expose
/// Preferences both as an editor and as a temporary window without duplicating
/// its settings UI.
class BlenderPreferencesWindow extends StatefulWidget {
  const BlenderPreferencesWindow({
    super.key,
    required this.categories,
    required this.sections,
    this.categoryGroups = const <BlenderPreferenceCategoryGroup>[],
    this.initialCategory,
    this.title = 'Preferences',
    this.width = 1040,
    this.height = 700,
    this.onCategoryChanged,
    this.onClose,
    this.onMinimize,
    this.onMaximize,
  });

  final List<String> categories;
  final List<BlenderPreferenceSection> sections;
  final List<BlenderPreferenceCategoryGroup> categoryGroups;
  final String? initialCategory;
  final String title;
  final double width;
  final double height;
  final ValueChanged<String>? onCategoryChanged;

  /// Lets a native window host close its temporary Preferences window.
  ///
  /// When omitted, the standard route presenter dismisses the window.
  final VoidCallback? onClose;

  /// Lets a desktop host minimize a native Preferences window.
  ///
  /// The built-in in-app presenter falls back to a collapsed title bar.
  final VoidCallback? onMinimize;

  /// Lets a desktop host toggle a native Preferences window's maximized state.
  ///
  /// The built-in in-app presenter fills its safe viewport instead.
  final VoidCallback? onMaximize;

  @override
  State<BlenderPreferencesWindow> createState() =>
      _BlenderPreferencesWindowState();
}

class _BlenderPreferencesWindowState extends State<BlenderPreferencesWindow> {
  late String _category;
  late double _width;
  late double _height;
  Offset _position = Offset.zero;
  bool _minimized = false;
  bool _maximized = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _category =
        widget.initialCategory ??
        (widget.categories.isEmpty ? '' : widget.categories.first);
    _width = widget.width;
    _height = widget.height;
  }

  @override
  void didUpdateWidget(BlenderPreferencesWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.categories.contains(_category)) {
      _category =
          widget.initialCategory ??
          (widget.categories.isEmpty ? '' : widget.categories.first);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    setState(() => _category = category);
    widget.onCategoryChanged?.call(category);
  }

  List<BlenderPreferenceCategoryGroup> get _categoryGroups {
    if (widget.categoryGroups.isNotEmpty) return widget.categoryGroups;
    return <BlenderPreferenceCategoryGroup>[
      for (final category in widget.categories)
        BlenderPreferenceCategoryGroup(
          id: category,
          categories: <String>[category],
        ),
    ];
  }

  void _resize(
    DragUpdateDetails details, {
    bool horizontal = true,
    bool vertical = true,
  }) {
    if (_maximized || _minimized) return;
    final viewport = MediaQuery.sizeOf(context);
    setState(() {
      if (horizontal) {
        _width = (_width + details.delta.dx)
            .clamp(520, viewport.width - 28)
            .toDouble();
      }
      if (vertical) {
        _height = (_height + details.delta.dy)
            .clamp(360, viewport.height - 28)
            .toDouble();
      }
    });
  }

  void _move(DragUpdateDetails details, Size windowSize) {
    if (_maximized) return;
    final viewport = MediaQuery.sizeOf(context);
    final horizontalLimit = math.max(
      0,
      (viewport.width - windowSize.width) / 2,
    );
    final verticalLimit = math.max(
      0,
      (viewport.height - windowSize.height) / 2,
    );
    setState(() {
      _position = Offset(
        (_position.dx + details.delta.dx)
            .clamp(-horizontalLimit, horizontalLimit)
            .toDouble(),
        (_position.dy + details.delta.dy)
            .clamp(-verticalLimit, verticalLimit)
            .toDouble(),
      );
    });
  }

  void _minimize() {
    if (widget.onMinimize != null) {
      widget.onMinimize!();
      return;
    }
    setState(() => _minimized = !_minimized);
  }

  void _maximize() {
    if (widget.onMaximize != null) {
      widget.onMaximize!();
      return;
    }
    setState(() {
      _maximized = !_maximized;
      if (_maximized) _position = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final visibleSections = widget.sections
        .where((section) {
          // A query is a global preference lookup. Restricting it to the
          // selected category makes a valid result appear broken whenever the
          // user starts from a different category.
          if (query.isEmpty && section.category != _category) return false;
          return query.isEmpty ||
              section.title.toLowerCase().contains(query) ||
              section.category.toLowerCase().contains(query) ||
              section.searchTerms.any(
                (term) => term.toLowerCase().contains(query),
              );
        })
        .toList(growable: false);

    final viewport = MediaQuery.sizeOf(context);
    final width = _maximized
        ? math.max(520, viewport.width - 28).toDouble()
        : math.min(_width, math.max(520, viewport.width - 28)).toDouble();
    final fullHeight = _maximized
        ? math.max(360, viewport.height - 28).toDouble()
        : math.min(_height, math.max(360, viewport.height - 28)).toDouble();
    final height = _minimized ? 48.0 : fullHeight;
    final windowSize = Size(width, fullHeight);
    return Transform.translate(
      offset: _position,
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: <Widget>[
            DecoratedBox(
              key: const ValueKey<String>('preferences-window-surface'),
              decoration: BoxDecoration(
                color: theme.colors.canvas,
                border: Border.all(color: theme.colors.editorBorder),
                borderRadius: BorderRadius.circular(_maximized ? 0 : 18),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0xAA000000),
                    blurRadius: 28,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: <Widget>[
                  _PreferencesWindowTitleBar(
                    title: widget.title,
                    minimized: _minimized,
                    maximized: _maximized,
                    onClose:
                        widget.onClose ??
                        () => Navigator.maybeOf(context)?.maybePop(),
                    onMinimize: _minimize,
                    onMaximize: _maximize,
                    onMove: (details) => _move(details, windowSize),
                  ),
                  if (!_minimized)
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          SizedBox(
                            width: 250,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.colors.surface,
                                border: Border(
                                  right: BorderSide(
                                    color: theme.colors.editorBorder,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      10,
                                      14,
                                      8,
                                    ),
                                    child: BlenderSearchField(
                                      controller: _searchController,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  Expanded(
                                    child: BlenderCategoryNavigation<String>(
                                      groups: <BlenderCategoryGroup<String>>[
                                        for (final group in _categoryGroups)
                                          BlenderCategoryGroup<String>(
                                            id: group.id,
                                            label: group.label,
                                            items:
                                                <BlenderCategoryItem<String>>[
                                                  for (final category
                                                      in group.categories)
                                                    if (widget.categories
                                                        .contains(category))
                                                      BlenderCategoryItem<
                                                        String
                                                      >(
                                                        value: category,
                                                        label: category,
                                                      ),
                                                ],
                                          ),
                                      ],
                                      selected: _category,
                                      onSelected: _selectCategory,
                                      padding: const EdgeInsets.fromLTRB(
                                        14,
                                        0,
                                        14,
                                        14,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      0,
                                      14,
                                      10,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: BlenderPopover(
                                        targetAnchor: Alignment.topLeft,
                                        followerAnchor: Alignment.bottomLeft,
                                        offset: const Offset(0, -4),
                                        child: const BlenderIconButton(
                                          key: ValueKey<String>(
                                            'preferences-window-menu-button',
                                          ),
                                          glyph: BlenderGlyph.menu,
                                          tooltip: 'Preferences menu',
                                          size: 28,
                                        ),
                                        popover: (context, close) => BlenderMenu<String>(
                                          items: const <BlenderMenuItem<String>>[
                                            BlenderMenuItem<String>(
                                              value: 'auto-save',
                                              label: 'Auto-Save Preferences',
                                              checked: true,
                                            ),
                                            BlenderMenuItem<String>(
                                              value: 'separator',
                                              label: '',
                                              separator: true,
                                            ),
                                            BlenderMenuItem<String>(
                                              value: 'save',
                                              label: 'Save Preferences',
                                            ),
                                            BlenderMenuItem<String>(
                                              value: 'revert',
                                              label:
                                                  'Revert to Saved Preferences',
                                            ),
                                            BlenderMenuItem<String>(
                                              value: 'factory',
                                              label: 'Load Factory Preferences',
                                            ),
                                          ],
                                          onSelected: (_) => close(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: visibleSections.isEmpty
                                ? Center(
                                    child: Text(
                                      query.isEmpty
                                          ? 'No preferences in this category'
                                          : 'No preferences match "$query"',
                                      style: theme.textTheme.body.copyWith(
                                        color: theme.colors.foregroundMuted,
                                      ),
                                    ),
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.all(14),
                                    itemCount: visibleSections.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 6),
                                    itemBuilder: (context, index) {
                                      final section = visibleSections[index];
                                      return BlenderPanel(
                                        title: section.title,
                                        collapsible: true,
                                        initiallyExpanded:
                                            section.initiallyExpanded,
                                        child: section.child,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (!_minimized && !_maximized) ...<Widget>[
              Positioned(
                right: 0,
                top: 48,
                bottom: 24,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) => _resize(details, vertical: false),
                    child: const SizedBox(width: 10),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 24,
                bottom: 0,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeRow,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: (details) =>
                        _resize(details, horizontal: false),
                    child: const SizedBox(height: 10),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeDownRight,
                  child: GestureDetector(
                    key: const ValueKey<String>(
                      'preferences-window-resize-handle',
                    ),
                    behavior: HitTestBehavior.opaque,
                    onPanUpdate: _resize,
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CustomPaint(
                        painter: _PreferencesResizeGripPainter(
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PreferencesWindowTitleBar extends StatelessWidget {
  const _PreferencesWindowTitleBar({
    required this.title,
    required this.minimized,
    required this.maximized,
    required this.onClose,
    required this.onMinimize,
    required this.onMaximize,
    required this.onMove,
  });

  final String title;
  final bool minimized;
  final bool maximized;
  final VoidCallback? onClose;
  final VoidCallback onMinimize;
  final VoidCallback onMaximize;
  final ValueChanged<DragUpdateDetails> onMove;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return GestureDetector(
      key: const ValueKey<String>('preferences-window-title-bar'),
      behavior: HitTestBehavior.opaque,
      onPanUpdate: onMove,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: theme.colors.canvas,
          border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: Row(
          children: <Widget>[
            _PreferencesWindowControl(
              key: const ValueKey<String>('preferences-window-close'),
              color: const Color(0xFFFF5F57),
              tooltip: 'Close Preferences',
              onPressed: onClose,
            ),
            const SizedBox(width: 12),
            _PreferencesWindowControl(
              key: const ValueKey<String>('preferences-window-minimize'),
              color: const Color(0xFFFFBD2E),
              tooltip: minimized
                  ? 'Restore Preferences'
                  : 'Minimize Preferences',
              onPressed: onMinimize,
            ),
            const SizedBox(width: 12),
            _PreferencesWindowControl(
              key: const ValueKey<String>('preferences-window-maximize'),
              color: const Color(0xFF28C840),
              tooltip: maximized
                  ? 'Restore Preferences size'
                  : 'Maximize Preferences',
              onPressed: onMaximize,
            ),
            const SizedBox(width: 24),
            Text(title, style: theme.textTheme.heading),
          ],
        ),
      ),
    );
  }
}

class _PreferencesResizeGripPainter extends CustomPainter {
  const _PreferencesResizeGripPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: .75)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (var inset = 7.0; inset <= 15; inset += 4) {
      canvas.drawLine(
        Offset(size.width - inset, size.height - 3),
        Offset(size.width - 3, size.height - inset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PreferencesResizeGripPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PreferencesWindowControl extends StatelessWidget {
  const _PreferencesWindowControl({
    super.key,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return BlenderTooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: MouseRegion(
          cursor: onPressed == null
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: SizedBox(
              width: 18,
              height: 18,
              child: Center(
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
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
