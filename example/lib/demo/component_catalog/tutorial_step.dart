part of '../component_catalog.dart';

class _TutorialStep extends StatelessWidget {
  const _TutorialStep({
    required this.number,
    required this.title,
    required this.body,
  });

  final String number;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BlenderKeycap(number),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.heading),
                const SizedBox(height: 2),
                Text(body, style: theme.textTheme.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogEmptyState extends StatelessWidget {
  const _CatalogEmptyState();

  @override
  Widget build(BuildContext context) => const Center(
    child: BlenderNoticeBanner(
      message: 'No components match the current search.',
      level: BlenderNoticeLevel.info,
    ),
  );
}

/// Renders the real interactive widget used by each tutorial page.
class ComponentCatalogExample extends StatefulWidget {
  const ComponentCatalogExample({super.key, required this.componentId});

  final String componentId;

  @override
  State<ComponentCatalogExample> createState() =>
      _ComponentCatalogExampleState();
}

class _ComponentCatalogExampleState extends State<ComponentCatalogExample> {
  late final TextEditingController _text;
  late final TextEditingController _search;
  double _amount = .42;
  bool _enabled = true;
  bool _liveUpdate = false;
  bool _temporalReprojection = true;
  bool _jitteredShadows = false;
  bool _shadowsEnabled = true;
  bool _volumeShadowsEnabled = false;
  double _viewportSamples = 16;
  double _renderSamples = 64;
  double _shadowRays = 1;
  double _shadowSteps = 6;
  double _volumeShadowSteps = 16;
  double _shadowResolution = .749;
  double _lightThreshold = .1;
  String _mode = 'Object';
  String _multiColumnSelection = 'page';
  String _selectedListItem = 'scene';
  String _selectedTreeNode = 'cube';
  int _selectedTab = 0;
  double _currentFrame = 18;
  double _splitFraction = .62;
  String _selectedPath = '/project/assets/scene.blend';
  int _serviceInvocations = 0;
  String _status = 'Ready';

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: 'Editable text');
    _search = TextEditingController();
  }

  @override
  void dispose() {
    _text.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 480,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.canvas,
            border: Border.all(color: theme.colors.editorBorder),
            borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildPreview(context, theme, widget.componentId),
                const SizedBox(height: 10),
                Text(
                  'Event: $_status',
                  key: const ValueKey<String>('catalog-live-status'),
                  style: theme.textTheme.caption.copyWith(
                    color: theme.colors.foregroundMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setStatus(String status) {
    if (!mounted) return;
    setState(() => _status = status);
  }

  void _updatePreview(VoidCallback mutation) {
    if (!mounted) return;
    setState(mutation);
  }
}

class _ServicePreview extends StatelessWidget {
  const _ServicePreview({
    required this.title,
    required this.rows,
    required this.onInvoked,
  });

  final String title;
  final List<String> rows;
  final VoidCallback onInvoked;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: <Widget>[
                  BlenderIcon(
                    BlenderGlyph.check,
                    size: 14,
                    color: theme.colors.success,
                  ),
                  const SizedBox(width: 6),
                  Text(row, style: theme.textTheme.label),
                ],
              ),
            ),
          const SizedBox(height: 4),
          BlenderButton(label: 'Invoke', onPressed: onInvoked),
        ],
      ),
    );
  }
}

class _CatalogComponent {
  const _CatalogComponent({
    required this.id,
    required this.category,
    required this.label,
    required this.description,
    required this.glyph,
    required this.api,
    required this.tutorial,
    required this.compose,
    required this.state,
    required this.callback,
    required this.keywords,
  });

  final String id;
  final String category;
  final String label;
  final String description;
  final BlenderGlyph glyph;
  final String api;
  final String tutorial;
  final String compose;
  final String state;
  final String callback;
  final String keywords;
}

const List<String> _catalogCategories = <String>[
  'Inputs',
  'Data display',
  'Feedback',
  'Surfaces',
  'Navigation & layout',
  'Editors',
  'App services',
];

/// Stable IDs used by the catalog and external links.
const List<String> componentCatalogIds = <String>[
  'button',
  'checkbox',
  'slider',
  'text-field',
  'dropdown',
  'multi-column-menu',
  'search-field',
  'list-view',
  'tree',
  'properties-editor',
  'notice',
  'tooltip',
  'popover',
  'panel',
  'tabs',
  'breadcrumbs',
  'splitter',
  'toolbar',
  'timeline',
  'node-editor',
  'file-browser',
  'spreadsheet',
  'history-store',
  'command-registry',
];
