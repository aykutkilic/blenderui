part of '../non3d_editors.dart';

class BlenderPreferenceSection {
  const BlenderPreferenceSection({
    required this.id,
    required this.category,
    required this.title,
    required this.child,
    this.searchTerms = const <String>[],
    this.initiallyExpanded = true,
  });

  /// Creates a section from a compact static property-form catalog.
  ///
  /// This keeps section identity and layout consistent while applications
  /// retain ownership of the settings and callbacks placed in [children].
  factory BlenderPreferenceSection.form(
    String category,
    String id,
    String title,
    List<Widget> children, {
    bool expanded = false,
    String idPrefix = 'preferences',
    List<String> searchTerms = const <String>[],
  }) {
    return BlenderPreferenceSection(
      id: '$idPrefix-$category-$id',
      category: category,
      title: title,
      searchTerms: searchTerms,
      initiallyExpanded: expanded,
      child: blenderFormColumn(children),
    );
  }

  final String id;
  final String category;
  final String title;
  final Widget child;

  /// Application-owned names of the settings rendered by [child].
  ///
  /// A preferences window cannot reliably inspect arbitrary widget trees, so
  /// callers provide the labels that should participate in its search.
  final List<String> searchTerms;
  final bool initiallyExpanded;
}

class BlenderPreferenceCategoryGroup {
  const BlenderPreferenceCategoryGroup({
    required this.id,
    required this.categories,
    this.label,
  });

  final String id;
  final List<String> categories;
  final String? label;
}

class BlenderPreferencesEditor extends StatefulWidget {
  const BlenderPreferencesEditor({
    super.key,
    required this.categories,
    required this.sections,
    this.categoryGroups = const <BlenderPreferenceCategoryGroup>[],
    this.selectedCategory,
    this.onCategoryChanged,
    this.onSectionOrderChanged,
    this.title = 'Preferences',
  });

  final List<String> categories;
  final List<BlenderPreferenceSection> sections;
  final List<BlenderPreferenceCategoryGroup> categoryGroups;
  final String? selectedCategory;
  final ValueChanged<String>? onCategoryChanged;
  final ValueChanged<List<String>>? onSectionOrderChanged;
  final String title;

  @override
  State<BlenderPreferencesEditor> createState() =>
      _BlenderPreferencesEditorState();
}

class _BlenderPreferencesEditorState extends State<BlenderPreferencesEditor> {
  late final ScrollController _scrollController;
  late List<String> _sectionOrder = _sectionIds(widget.sections);

  List<String> _sectionIds(Iterable<BlenderPreferenceSection> sections) =>
      sections.map((section) => section.id).toList();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(BlenderPreferencesEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ids = _sectionIds(widget.sections).toSet();
    _sectionOrder = <String>[
      for (final id in _sectionOrder)
        if (ids.contains(id)) id,
      for (final id in _sectionIds(widget.sections))
        if (!_sectionOrder.contains(id)) id,
    ];
    if (oldWidget.selectedCategory != widget.selectedCategory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  List<BlenderPreferenceSection> _visibleSections(String? category) {
    final byId = <String, BlenderPreferenceSection>{
      for (final section in widget.sections) section.id: section,
    };
    return <BlenderPreferenceSection>[
      for (final id in _sectionOrder)
        if (byId[id] case final section?)
          if (category == null || section.category == category) section,
    ];
  }

  void _reorderSections(
    List<BlenderPreferenceSection> visibleSections,
    int oldIndex,
    int newIndex,
  ) {
    final visibleIds = visibleSections.map((section) => section.id).toList();
    final id = visibleIds.removeAt(oldIndex);
    visibleIds.insert(newIndex.clamp(0, visibleIds.length), id);
    final visibleIdSet = visibleIds.toSet()
      ..addAll(visibleSections.map((section) => section.id));
    final insertionIndex = _sectionOrder.indexWhere(visibleIdSet.contains);
    final reordered = List<String>.from(_sectionOrder)
      ..removeWhere(visibleIdSet.contains);
    final safeInsertionIndex = insertionIndex < 0
        ? reordered.length
        : insertionIndex.clamp(0, reordered.length);
    reordered.insertAll(safeInsertionIndex, visibleIds);
    setState(() => _sectionOrder = reordered);
    widget.onSectionOrderChanged?.call(List<String>.unmodifiable(reordered));
  }

  Widget _buildCategoryNavigation(String? category) {
    return BlenderCategoryNavigation<String>(
      groups: <BlenderCategoryGroup<String>>[
        for (final group in _categoryGroups)
          BlenderCategoryGroup<String>(
            id: group.id,
            label: group.label,
            items: <BlenderCategoryItem<String>>[
              for (final item in group.categories)
                if (widget.categories.contains(item))
                  BlenderCategoryItem<String>(value: item, label: item),
            ],
          ),
      ],
      selected: category,
      onSelected: widget.onCategoryChanged ?? (_) {},
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
    );
  }

  Widget _buildSections(
    BuildContext context,
    List<BlenderPreferenceSection> visibleSections,
  ) {
    final theme = BlenderTheme.of(context);
    return BlenderEnsureOverlay(
      child: BlenderScrollbar(
        controller: _scrollController,
        child: ReorderableList(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          itemCount: visibleSections.length,
          // Keep the package's Flutter 3.41 compatibility floor.
          // ignore: deprecated_member_use
          onReorder: (oldIndex, newIndex) {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            _reorderSections(visibleSections, oldIndex, newIndex);
          },
          itemBuilder: (context, index) {
            final section = visibleSections[index];
            return KeyedSubtree(
              key: ValueKey<String>('preference-section-${section.id}'),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: index == visibleSections.length - 1 ? 0 : 6,
                ),
                child: BlenderPanel(
                  title: section.title,
                  collapsible: true,
                  initiallyExpanded: section.initiallyExpanded,
                  headerHandle: ReorderableDragStartListener(
                    index: index,
                    child: MouseRegion(
                      key: ValueKey<String>(
                        'preference-section-handle-${section.id}',
                      ),
                      cursor: SystemMouseCursors.grab,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: theme.density.spacing / 2,
                        ),
                        child: BlenderIcon(
                          BlenderGlyph.dragHandle,
                          size: 7,
                          color: theme.colors.foreground.withAlpha(128),
                        ),
                      ),
                    ),
                  ),
                  child: section.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category =
        widget.selectedCategory ??
        (widget.categories.isEmpty ? null : widget.categories.first);
    final theme = BlenderTheme.of(context);
    final scale = theme.density.interfaceScale;
    final visibleSections = _visibleSections(category);
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 148 * scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.surface,
                border: Border(
                  right: BorderSide(color: theme.colors.editorBorder),
                ),
              ),
              child: _buildCategoryNavigation(category),
            ),
          ),
          Expanded(child: _buildSections(context, visibleSections)),
        ],
      ),
    );
  }
}
