part of '../component_catalog.dart';

/// A searchable catalog of the public BlenderUI building blocks. The catalog
/// is intentionally independent from the larger showcase workbench so it can
/// also be used as a documentation entry point.
class ComponentCatalogPage extends StatefulWidget {
  const ComponentCatalogPage({super.key, this.initialComponent = 'button'});

  final String initialComponent;

  @override
  State<ComponentCatalogPage> createState() => _ComponentCatalogPageState();
}

class _ComponentCatalogPageState extends State<ComponentCatalogPage> {
  late final TextEditingController _search;
  late String _selectedId;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController();
    _selectedId = _catalog.any((item) => item.id == widget.initialComponent)
        ? widget.initialComponent
        : _catalog.first.id;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<BlenderCategoryGroup<String>> get _groups =>
      <BlenderCategoryGroup<String>>[
        for (final category in _catalogCategories)
          BlenderCategoryGroup<String>(
            id: category,
            label: category,
            items: <BlenderCategoryItem<String>>[
              for (final item in _catalog.where(
                (item) => item.category == category,
              ))
                BlenderCategoryItem<String>(
                  value: item.id,
                  label: item.label,
                  keywords:
                      '${item.category} ${item.description} ${item.keywords}',
                  glyph: item.glyph,
                ),
            ],
          ),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return ColoredBox(
      color: theme.colors.propertiesBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _CatalogTopBar(componentCount: _catalog.length),
          Expanded(
            child: BlenderCategoryBrowser<String>(
              groups: _groups,
              selected: _selectedId,
              searchController: _search,
              navigationWidth: 250,
              onSelected: (id) => setState(() => _selectedId = id),
              detailBuilder: (context, id) {
                final component = _catalog.where((item) => item.id == id);
                return component.isEmpty
                    ? const _CatalogEmptyState()
                    : _CatalogDetail(component: component.first);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogTopBar extends StatelessWidget {
  const _CatalogTopBar({required this.componentCount});

  final int componentCount;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colors.topBar,
        border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: Row(
        children: <Widget>[
          const BlenderIcon(BlenderGlyph.cube, size: 24),
          const SizedBox(width: 10),
          Text('BlenderUI Components', style: theme.textTheme.heading),
          const SizedBox(width: 10),
          BlenderKeycap('$componentCount components'),
          const Spacer(),
          Flexible(
            child: Text(
              'Interactive tutorials and source-shaped examples',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
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

class _CatalogDetail extends StatelessWidget {
  const _CatalogDetail({required this.component});

  final _CatalogComponent component;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Components / ${component.category}',
                style: theme.textTheme.caption.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BlenderIcon(component.glyph, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(component.label, style: theme.textTheme.heading),
                        const SizedBox(height: 4),
                        Text(
                          component.description,
                          style: theme.textTheme.body,
                        ),
                      ],
                    ),
                  ),
                  const BlenderKeycap('API below'),
                ],
              ),
              const SizedBox(height: 14),
              _CatalogCard(
                title: 'Live example',
                description:
                    'This is the real widget. Interact with it to understand its state and callback boundary.',
                child: ComponentCatalogExample(
                  key: ValueKey<String>(component.id),
                  componentId: component.id,
                ),
              ),
              _CatalogCard(
                title: 'Tutorial',
                description: component.tutorial,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _TutorialStep(
                      number: '01',
                      title: 'Compose the widget',
                      body: component.compose,
                    ),
                    _TutorialStep(
                      number: '02',
                      title: 'Own the state',
                      body: component.state,
                    ),
                    _TutorialStep(
                      number: '03',
                      title: 'Connect the callback',
                      body: component.callback,
                    ),
                  ],
                ),
              ),
              _CatalogCard(
                title: 'Code example',
                description:
                    'A minimal construction snippet for the live example above.',
                child: BlenderCodeBlock(
                  key: const ValueKey<String>('catalog-code-example'),
                  code: component.api,
                  highlighter: blenderDartCodeHighlighter,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
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
      padding: const EdgeInsets.only(top: 12),
      child: BlenderPanel(
        title: title,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                description,
                style: theme.textTheme.caption.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
              ),
              const SizedBox(height: 10),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
