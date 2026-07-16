import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

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

  List<_CatalogComponent> _filteredCatalog(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return _catalog;
    return _catalog
        .where(
          (item) =>
              item.label.toLowerCase().contains(normalized) ||
              item.category.toLowerCase().contains(normalized) ||
              item.description.toLowerCase().contains(normalized) ||
              item.keywords.contains(normalized),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _search,
      builder: (context, value, child) {
        final visible = _filteredCatalog(value.text);
        final selected = visible.where((item) => item.id == _selectedId);
        final component = selected.isEmpty
            ? (visible.isEmpty ? null : visible.first)
            : selected.first;
        return ColoredBox(
          color: theme.colors.propertiesBackground,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _CatalogTopBar(componentCount: _catalog.length),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _CatalogSidebar(
                      search: _search,
                      components: visible,
                      selectedId: component?.id,
                      onSelected: (item) =>
                          setState(() => _selectedId = item.id),
                    ),
                    Expanded(
                      child: component == null
                          ? const _CatalogEmptyState()
                          : _CatalogDetail(component: component),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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

class _CatalogSidebar extends StatelessWidget {
  const _CatalogSidebar({
    required this.search,
    required this.components,
    required this.selectedId,
    required this.onSelected,
  });

  final TextEditingController search;
  final List<_CatalogComponent> components;
  final String? selectedId;
  final ValueChanged<_CatalogComponent> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final grouped = <String, List<_CatalogComponent>>{};
    for (final item in components) {
      grouped.putIfAbsent(item.category, () => <_CatalogComponent>[]).add(item);
    }
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: theme.colors.textField,
        border: Border(right: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: BlenderSearchField(
              controller: search,
              placeholder: 'Find a component',
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: <Widget>[
                for (final category in _catalogCategories)
                  if (grouped[category]?.isNotEmpty ?? false) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                      child: Text(
                        category,
                        style: theme.textTheme.caption.copyWith(
                          color: theme.colors.foregroundMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final item in grouped[category]!)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: BlenderButton(
                          label: item.label,
                          leading: BlenderIcon(item.glyph, size: 15),
                          selected: item.id == selectedId,
                          variant: BlenderButtonVariant.topBar,
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          onPressed: () => onSelected(item),
                        ),
                      ),
                  ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
            child: Text(
              '${components.length} matching components',
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
                child: _CatalogCodeBlock(code: component.api),
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

class _CatalogCodeBlock extends StatelessWidget {
  const _CatalogCodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final baseStyle = TextStyle(
      color: theme.colors.foreground,
      fontFamily: 'monospace',
      fontSize: 12,
      height: 1.45,
    );
    return DecoratedBox(
      key: const ValueKey<String>('catalog-code-example'),
      decoration: BoxDecoration(
        color: theme.colors.menuBackground,
        border: Border.all(color: theme.colors.borderSubtle),
        borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        child: RichText(
          text: TextSpan(
            style: baseStyle,
            children: _highlightCode(code, baseStyle, theme),
          ),
        ),
      ),
    );
  }
}

List<TextSpan> _highlightCode(
  String code,
  TextStyle baseStyle,
  BlenderThemeData theme,
) {
  final tokenPattern = RegExp(
    r'''("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|//[^\n]*|\b(?:const|final|var|return|void|true|false|null)\b|\b[A-Z][A-Za-z0-9_]*\b|[{}()\[\],:.=<>]|\b[A-Za-z_][A-Za-z0-9_]*\b)''',
  );
  final spans = <TextSpan>[];
  var cursor = 0;
  for (final match in tokenPattern.allMatches(code)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: code.substring(cursor, match.start)));
    }
    final token = match.group(0)!;
    final color = token.startsWith('//')
        ? const Color(0xFF7FA77F)
        : token.startsWith('"') || token.startsWith("'")
        ? const Color(0xFFA8D47A)
        : <String>{
            'const',
            'final',
            'var',
            'return',
            'void',
            'true',
            'false',
            'null',
          }.contains(token)
        ? const Color(0xFFE3A7FF)
        : RegExp(r'^[A-Z]').hasMatch(token)
        ? theme.colors.focus
        : RegExp(r'^[{}()\[\],:.=<>]$').hasMatch(token)
        ? theme.colors.foregroundMuted
        : baseStyle.color;
    spans.add(
      TextSpan(
        text: token,
        style: baseStyle.copyWith(color: color),
      ),
    );
    cursor = match.end;
  }
  if (cursor < code.length) {
    spans.add(TextSpan(text: code.substring(cursor)));
  }
  return spans;
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

  Widget _buildPreview(
    BuildContext context,
    BlenderThemeData theme,
    String id,
  ) {
    return switch (id) {
      'button' => BlenderFlow(
        children: <Widget>[
          BlenderButton(
            label: 'Apply',
            onPressed: () => _setStatus('Apply pressed'),
          ),
          BlenderButton(
            label: 'Selected',
            selected: true,
            onPressed: () => _setStatus('Selected pressed'),
          ),
          BlenderButton(
            label: 'Toolbar',
            variant: BlenderButtonVariant.toolbar,
            onPressed: () => _setStatus('Toolbar pressed'),
          ),
        ],
      ),
      'checkbox' => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BlenderCheckbox(
            value: _enabled,
            label: 'Enabled',
            onChanged: (value) => setState(() {
              _enabled = value;
              _status = 'Enabled: $value';
            }),
          ),
          BlenderToggle(
            value: _liveUpdate,
            label: 'Live update',
            onChanged: (value) => setState(() {
              _liveUpdate = value;
              _status = 'Live update: $value';
            }),
          ),
          BlenderRadio<String>(
            value: 'Object',
            groupValue: _mode,
            label: 'Object mode',
            onChanged: (value) => setState(() {
              _mode = value;
              _status = 'Mode: $_mode';
            }),
          ),
        ],
      ),
      'slider' => Row(
        children: <Widget>[
          Expanded(
            child: BlenderSlider(
              value: _amount,
              onChanged: (value) => setState(() {
                _amount = value;
                _status = 'Value: ${value.toStringAsFixed(3)}';
              }),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: BlenderNumberField(
              value: _amount,
              min: 0,
              max: 1,
              step: .01,
              onChanged: (value) => setState(() {
                _amount = value;
                _status = 'Value: ${value.toStringAsFixed(3)}';
              }),
            ),
          ),
        ],
      ),
      'text-field' => Row(
        children: <Widget>[
          Expanded(
            child: BlenderTextField(
              controller: _text,
              onChanged: (value) => _setStatus('Editing: $value'),
              onSubmitted: (value) => _setStatus('Submitted: $value'),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: BlenderButton(
              label: 'Submit',
              onPressed: () => _setStatus('Submitted: ${_text.text}'),
            ),
          ),
        ],
      ),
      'dropdown' => SizedBox(
        width: 250,
        child: BlenderDropdown<String>(
          value: _mode,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem(value: 'Object', label: 'Object'),
            BlenderMenuItem(value: 'Edit', label: 'Edit'),
            BlenderMenuItem(value: 'Sculpt', label: 'Sculpt'),
          ],
          onChanged: (value) => setState(() {
            _mode = value;
            _status = 'Mode: $_mode';
          }),
        ),
      ),
      'multi-column-menu' => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BlenderPopover(
            onOpenChanged: (open) {
              if (open) _setStatus('Multi-column menu opened');
            },
            child: IgnorePointer(
              child: BlenderButton(
                label: switch (_multiColumnSelection) {
                  'page' => 'Page Editor',
                  'level' => 'Level Editor',
                  'timeline' => 'Timeline',
                  'dopesheet' => 'Dope Sheet',
                  'text' => 'Text Editor',
                  'console' => 'Python Console',
                  'properties' => 'Properties',
                  'outliner' => 'Outliner',
                  _ => 'Choose Editor',
                },
                trailing: const BlenderIcon(
                  BlenderGlyph.panelDisclosureDown,
                  size: 9,
                ),
                selected: true,
                variant: BlenderButtonVariant.menuTrigger,
              ),
            ),
            popover: (context, close) => BlenderMultiColumnMenu<String>(
              key: const ValueKey<String>('catalog-multicolumn-menu'),
              menuId: 'catalog-multicolumn-menu',
              semanticLabel: 'Editor type menu',
              groups: const <BlenderMultiColumnMenuGroup<String>>[
                BlenderMultiColumnMenuGroup<String>(
                  id: 'general',
                  title: 'General',
                  items: <BlenderMultiColumnMenuItem<String>>[
                    BlenderMultiColumnMenuItem<String>(
                      id: 'page',
                      value: 'page',
                      label: 'Page Editor',
                      glyph: BlenderGlyph.file,
                    ),
                    BlenderMultiColumnMenuItem<String>(
                      id: 'level',
                      value: 'level',
                      label: 'Level Editor',
                      glyph: BlenderGlyph.grid,
                    ),
                  ],
                ),
                BlenderMultiColumnMenuGroup<String>(
                  id: 'animation',
                  title: 'Animation',
                  items: <BlenderMultiColumnMenuItem<String>>[
                    BlenderMultiColumnMenuItem<String>(
                      id: 'timeline',
                      value: 'timeline',
                      label: 'Timeline',
                      glyph: BlenderGlyph.timeline,
                    ),
                    BlenderMultiColumnMenuItem<String>(
                      id: 'dopesheet',
                      value: 'dopesheet',
                      label: 'Dope Sheet',
                      glyph: BlenderGlyph.action,
                    ),
                  ],
                ),
                BlenderMultiColumnMenuGroup<String>(
                  id: 'scripting',
                  title: 'Scripting',
                  items: <BlenderMultiColumnMenuItem<String>>[
                    BlenderMultiColumnMenuItem<String>(
                      id: 'text',
                      value: 'text',
                      label: 'Text Editor',
                      glyph: BlenderGlyph.text,
                    ),
                    BlenderMultiColumnMenuItem<String>(
                      id: 'console',
                      value: 'console',
                      label: 'Python Console',
                      glyph: BlenderGlyph.console,
                    ),
                  ],
                ),
                BlenderMultiColumnMenuGroup<String>(
                  id: 'data',
                  title: 'Data',
                  items: <BlenderMultiColumnMenuItem<String>>[
                    BlenderMultiColumnMenuItem<String>(
                      id: 'properties',
                      value: 'properties',
                      label: 'Properties',
                      glyph: BlenderGlyph.settings,
                    ),
                    BlenderMultiColumnMenuItem<String>(
                      id: 'outliner',
                      value: 'outliner',
                      label: 'Outliner',
                      glyph: BlenderGlyph.collection,
                    ),
                  ],
                ),
              ],
              selected: _multiColumnSelection,
              onSelected: (value) {
                setState(() {
                  _multiColumnSelection = value;
                  _status = 'Editor: $value';
                });
                close();
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resize the window to switch between columns and a vertical menu.',
            style: theme.textTheme.caption.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ],
      ),
      'search-field' => SizedBox(
        width: 280,
        child: BlenderSearchField(
          controller: _search,
          placeholder: 'Search components',
          onChanged: (value) => _setStatus(
            value.isEmpty ? 'Search cleared' : 'Filtering: $value',
          ),
        ),
      ),
      'list-view' => SizedBox(
        height: 132,
        child: BlenderListView<String>(
          selectedId: _selectedListItem,
          items: const <BlenderListItem<String>>[
            BlenderListItem(
              id: 'scene',
              label: 'Scene Collection',
              detail: '12 objects',
              icon: BlenderGlyph.collection,
            ),
            BlenderListItem(
              id: 'camera',
              label: 'Camera',
              detail: 'Perspective',
              icon: BlenderGlyph.camera,
            ),
            BlenderListItem(
              id: 'light',
              label: 'Key Light',
              detail: 'Area',
              icon: BlenderGlyph.light,
            ),
          ],
          onSelected: (item) => setState(() {
            _selectedListItem = item.id;
            _status = 'Selected: ${item.label}';
          }),
        ),
      ),
      'tree' => SizedBox(
        height: 140,
        child: BlenderTree<String>(
          selectedId: _selectedTreeNode,
          roots: const <BlenderTreeNode<String>>[
            BlenderTreeNode(
              id: 'collection',
              label: 'Collection',
              icon: BlenderGlyph.collection,
              initiallyExpanded: true,
              children: <BlenderTreeNode<String>>[
                BlenderTreeNode(
                  id: 'cube',
                  label: 'Cube',
                  value: 'Cube',
                  icon: BlenderGlyph.object,
                ),
                BlenderTreeNode(
                  id: 'camera',
                  label: 'Camera',
                  value: 'Camera',
                  icon: BlenderGlyph.camera,
                ),
              ],
            ),
          ],
          onSelected: (node) => setState(() {
            _selectedTreeNode = node.id;
            _status = 'Selected: ${node.label}';
          }),
        ),
      ),
      'properties-editor' => _buildRenderPropertiesPreview(),
      'notice' => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const BlenderNoticeBanner(
            message: 'Changes saved successfully.',
            level: BlenderNoticeLevel.success,
          ),
          const SizedBox(height: 8),
          BlenderProgressBar(value: _amount, label: 'Building preview'),
          const SizedBox(height: 8),
          BlenderButton(
            label: 'Advance',
            onPressed: () => setState(() {
              _amount = (_amount + .1).clamp(0, 1);
              _status = 'Progress advanced';
            }),
          ),
        ],
      ),
      'tooltip' => BlenderTooltip(
        message: 'Tooltips wait 500ms before appearing',
        child: BlenderButton(
          label: 'Hover for help',
          onPressed: () => _setStatus('Help action pressed'),
        ),
      ),
      'popover' => BlenderPopover(
        child: BlenderButton(
          label: 'Open popover',
          onPressed: () => _setStatus('Popover opened'),
        ),
        popover: (context, close) => BlenderPanel(
          title: 'Popover',
          child: BlenderButton(
            label: 'Close',
            onPressed: () {
              close();
              _setStatus('Popover closed');
            },
          ),
        ),
      ),
      'panel' => BlenderPanel(
        title: 'Transform',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderButton(
              label: 'Primary action',
              onPressed: () => _setStatus('Primary action pressed'),
            ),
            const SizedBox(height: 6),
            const BlenderPanel(
              title: 'Advanced',
              initiallyExpanded: false,
              child: const SizedBox(height: 24),
            ),
          ],
        ),
      ),
      'tabs' => BlenderTabBar(
        tabs: const <String>['Layout', 'Modeling', 'Sculpting'],
        selectedIndex: _selectedTab,
        onChanged: (index) => setState(() {
          _selectedTab = index;
          _status = 'Tab: ${['Layout', 'Modeling', 'Sculpting'][index]}';
        }),
      ),
      'breadcrumbs' => BlenderBreadcrumbs(
        items: const <String>['Scene', 'Collection', 'Cube'],
        onSelected: (index) => _setStatus('Breadcrumb $index selected'),
      ),
      'splitter' => SizedBox(
        height: 130,
        child: BlenderSplitter(
          initialFraction: _splitFraction,
          onFractionChanged: (value) => setState(() {
            _splitFraction = value;
            _status = 'Split: ${(value * 100).round()}%';
          }),
          first: ColoredBox(
            color: theme.colors.surface,
            child: const Center(child: Text('Editor')),
          ),
          second: ColoredBox(
            color: theme.colors.textField,
            child: const Center(child: Text('Inspector')),
          ),
        ),
      ),
      'toolbar' => BlenderToolbar(
        children: <Widget>[
          BlenderIconButton(
            glyph: BlenderGlyph.plus,
            onPressed: () => _setStatus('Add pressed'),
          ),
          BlenderButton(
            label: 'Layout',
            variant: BlenderButtonVariant.topBar,
            onPressed: () => _setStatus('Layout pressed'),
          ),
          BlenderIconButton(
            glyph: BlenderGlyph.settings,
            onPressed: () => _setStatus('Settings pressed'),
          ),
        ],
      ),
      'timeline' => BlenderTimeline(
        model: BlenderTimelineModel(
          start: 1,
          end: 48,
          currentFrame: _currentFrame,
          tracks: const <BlenderTimelineTrack>[
            BlenderTimelineTrack(
              id: 'cube',
              label: 'Cube',
              keyframes: <BlenderTimelineKeyframe>[
                BlenderTimelineKeyframe(1),
                BlenderTimelineKeyframe(18),
                BlenderTimelineKeyframe(42),
              ],
            ),
          ],
        ),
        onCurrentFrameChanged: (frame) => setState(() {
          _currentFrame = frame;
          _status = 'Frame: ${frame.round()}';
        }),
      ),
      'node-editor' => SizedBox(
        height: 180,
        child: BlenderNodeEditor(
          model: const BlenderNodeGraphModel(
            nodes: const <BlenderGraphNode>[
              BlenderGraphNode(
                id: 'input',
                title: 'Input',
                position: Offset(16, 30),
                outputs: <BlenderNodeSocketDefinition>[
                  BlenderNodeSocketDefinition(id: 'value', label: 'Value'),
                ],
              ),
              BlenderGraphNode(
                id: 'output',
                title: 'Output',
                position: Offset(250, 70),
                inputs: <BlenderNodeSocketDefinition>[
                  BlenderNodeSocketDefinition(id: 'value', label: 'Value'),
                ],
              ),
            ],
            links: <BlenderGraphLink>[
              BlenderGraphLink(from: 'input.value', to: 'output.value'),
            ],
          ),
          onNodeSelected: (node) => _setStatus('Selected node: ${node.title}'),
          onNodeMoved: (node, position) => _setStatus('Moved ${node.title}'),
        ),
      ),
      'file-browser' => SizedBox(
        height: 190,
        child: BlenderFileBrowser(
          selectedPath: _selectedPath,
          entries: const <BlenderFileEntry>[
            BlenderFileEntry(
              path: '/project/assets/scene.blend',
              name: 'scene.blend',
              detail: '2.4 MB',
            ),
            BlenderFileEntry(
              path: '/project/assets/props',
              name: 'props',
              isDirectory: true,
              detail: 'Folder',
            ),
          ],
          onSelected: (entry) => setState(() {
            _selectedPath = entry.path;
            _status = 'Selected: ${entry.name}';
          }),
          onOpen: (entry) => _setStatus('Opened: ${entry.name}'),
          pathSegments: const <String>['project', 'assets'],
          onPathSelected: (index) => _setStatus('Path segment $index'),
        ),
      ),
      'spreadsheet' => SizedBox(
        height: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Expanded(
              child: const BlenderSpreadsheetEditor(
                columns: const <BlenderSpreadsheetColumn>[
                  BlenderSpreadsheetColumn(
                    id: 'name',
                    label: 'Name',
                    width: 170,
                  ),
                  BlenderSpreadsheetColumn(
                    id: 'type',
                    label: 'Type',
                    width: 110,
                  ),
                  BlenderSpreadsheetColumn(
                    id: 'value',
                    label: 'Value',
                    width: 110,
                  ),
                ],
                rows: const <BlenderSpreadsheetRow>[
                  BlenderSpreadsheetRow(
                    id: 'one',
                    values: <String>['Cube', 'Mesh', '1.00'],
                  ),
                  BlenderSpreadsheetRow(
                    id: 'two',
                    values: <String>['Camera', 'Object', '50mm'],
                  ),
                ],
              ),
            ),
            BlenderButton(
              label: 'Refresh data',
              onPressed: () => _setStatus('Spreadsheet refreshed'),
            ),
          ],
        ),
      ),
      'history-store' => _ServicePreview(
        title: 'HistoryStore<AppState>',
        rows: const <String>['Undo stack: 3 changes', 'Redo stack: empty'],
        onInvoked: () => setState(() {
          _serviceInvocations++;
          _status = 'History command $_serviceInvocations invoked';
        }),
      ),
      'command-registry' => _ServicePreview(
        title: 'CommandRegistry',
        rows: const <String>['Ctrl I  Increment Counter', 'Ctrl R  Reset Demo'],
        onInvoked: () => setState(() {
          _serviceInvocations++;
          _status = 'Command $_serviceInvocations invoked';
        }),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildRenderPropertiesPreview() {
    return SizedBox(
      height: 430,
      child: BlenderPropertiesEditor(
        title: 'Render Engine',
        groups: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'sampling',
            title: 'Sampling',
            properties: const <BlenderPropertyDescriptor<dynamic>>[],
            children: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'viewport',
                title: 'Viewport',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<double>(
                    id: 'viewport-samples',
                    label: 'Samples',
                    value: _viewportSamples,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 1,
                          max: 128,
                          decimalDigits: 0,
                          onChanged: changed,
                        ),
                    onChanged: (value) => setState(() {
                      _viewportSamples = value;
                      _status = 'Viewport samples: ${value.round()}';
                    }),
                  ),
                  BlenderPropertyDescriptor<bool>(
                    id: 'temporal-reprojection',
                    label: 'Temporal Reprojection',
                    value: _temporalReprojection,
                    editorBuilder: (context, value, changed) =>
                        BlenderCheckbox(value: value, onChanged: changed),
                    onChanged: (value) => setState(() {
                      _temporalReprojection = value;
                      _status = 'Temporal reprojection: $value';
                    }),
                  ),
                  BlenderPropertyDescriptor<bool>(
                    id: 'jittered-shadows',
                    label: 'Jittered Shadows',
                    value: _jitteredShadows,
                    editorBuilder: (context, value, changed) =>
                        BlenderCheckbox(value: value, onChanged: changed),
                    onChanged: (value) => setState(() {
                      _jitteredShadows = value;
                      _status = 'Jittered shadows: $value';
                    }),
                  ),
                ],
              ),
              BlenderPropertyGroup(
                id: 'render',
                title: 'Render',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<double>(
                    id: 'render-samples',
                    label: 'Samples',
                    value: _renderSamples,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 1,
                          max: 256,
                          decimalDigits: 0,
                          onChanged: changed,
                        ),
                    onChanged: (value) => setState(() {
                      _renderSamples = value;
                      _status = 'Render samples: ${value.round()}';
                    }),
                  ),
                ],
              ),
              BlenderPropertyGroup(
                id: 'shadows',
                title: 'Shadows',
                enabled: _shadowsEnabled,
                headerLeading: BlenderCheckbox(
                  value: _shadowsEnabled,
                  onChanged: (value) => setState(() {
                    _shadowsEnabled = value;
                    _status = 'Shadows: ${value ? 'enabled' : 'disabled'}';
                  }),
                ),
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<double>(
                    id: 'shadow-rays',
                    label: 'Rays',
                    value: _shadowRays,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 1,
                          max: 16,
                          decimalDigits: 0,
                          onChanged: changed,
                        ),
                    onChanged: (value) => setState(() {
                      _shadowRays = value;
                      _status = 'Shadow rays: ${value.round()}';
                    }),
                  ),
                  BlenderPropertyDescriptor<double>(
                    id: 'shadow-steps',
                    label: 'Steps',
                    value: _shadowSteps,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 1,
                          max: 16,
                          decimalDigits: 0,
                          onChanged: changed,
                        ),
                    onChanged: (value) => setState(() {
                      _shadowSteps = value;
                      _status = 'Shadow steps: ${value.round()}';
                    }),
                  ),
                  BlenderPropertyDescriptor<double>(
                    id: 'shadow-resolution',
                    label: 'Resolution',
                    value: _shadowResolution,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 0,
                          max: 1,
                          step: .01,
                          showSteppers: false,
                          onChanged: changed,
                        ),
                    onChanged: (value) => setState(() {
                      _shadowResolution = value;
                      _status = 'Resolution: ${(value * 100).round()}%';
                    }),
                  ),
                ],
                children: <BlenderPropertyGroup>[
                  BlenderPropertyGroup(
                    id: 'volume-shadows',
                    title: 'Volume Shadows',
                    enabled: _volumeShadowsEnabled,
                    headerLeading: BlenderCheckbox(
                      value: _volumeShadowsEnabled,
                      onChanged: _shadowsEnabled
                          ? (value) => setState(() {
                              _volumeShadowsEnabled = value;
                              _status =
                                  'Volume Shadows: ${value ? 'enabled' : 'disabled'}';
                            })
                          : null,
                    ),
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      BlenderPropertyDescriptor<double>(
                        id: 'volume-shadow-steps',
                        label: 'Steps',
                        value: _volumeShadowSteps,
                        editorBuilder: (context, value, changed) =>
                            BlenderNumberField(
                              value: value,
                              min: 1,
                              max: 64,
                              decimalDigits: 0,
                              onChanged: changed,
                            ),
                        onChanged: (value) => setState(() {
                          _volumeShadowSteps = value;
                          _status = 'Volume shadow steps: ${value.round()}';
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              BlenderPropertyGroup(
                id: 'advanced',
                title: 'Advanced',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<double>(
                    id: 'light-threshold',
                    label: 'Light Threshold',
                    value: _lightThreshold,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 0,
                          max: 1,
                          step: .01,
                          onChanged: changed,
                        ),
                    onChanged: (value) => setState(() {
                      _lightThreshold = value;
                      _status = 'Light threshold: ${value.toStringAsFixed(2)}';
                    }),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
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

const List<_CatalogComponent> _catalog = <_CatalogComponent>[
  _CatalogComponent(
    id: 'button',
    category: 'Inputs',
    label: 'Button',
    description:
        'Compact action control with Blender toolbar and tab variants.',
    glyph: BlenderGlyph.pointer,
    api: 'BlenderButton(label: "Apply", onPressed: applyChanges)',
    tutorial:
        'Use buttons for explicit user actions. Keep domain work in the callback.',
    compose:
        'Choose a label and a BlenderButtonVariant for the visual context.',
    state: 'Use selected and enabled to reflect caller-owned state.',
    callback:
        'Call a command, update a store, or open a dialog from onPressed.',
    keywords: 'action control click toolbar tab',
  ),
  _CatalogComponent(
    id: 'checkbox',
    category: 'Inputs',
    label: 'Checkbox & Toggle',
    description:
        'Boolean controls for persistent settings and immediate switches.',
    glyph: BlenderGlyph.check,
    api: 'BlenderCheckbox(value: enabled, onChanged: setEnabled)',
    tutorial:
        'Use a checkbox for a property and a toggle when the change is immediate.',
    compose: 'Provide the current boolean value and an optional label.',
    state: 'Keep the boolean in the feature or form state, not in the control.',
    callback: 'Persist the new value in onChanged and rebuild the caller.',
    keywords: 'boolean toggle switch selection',
  ),
  _CatalogComponent(
    id: 'slider',
    category: 'Inputs',
    label: 'Slider & Number Field',
    description:
        'Dense numeric input that supports direct editing and dragging.',
    glyph: BlenderGlyph.transform,
    api: 'BlenderSlider(value: amount, onChanged: updateAmount)',
    tutorial:
        'Pair a slider with a bounded number field when precision matters.',
    compose: 'Set value, min, max, and a step that matches the domain.',
    state: 'The caller owns the numeric value and validation policy.',
    callback: 'Clamp or persist the value in the onChanged callback.',
    keywords: 'number range drag precision input',
  ),
  _CatalogComponent(
    id: 'text-field',
    category: 'Inputs',
    label: 'Text Field',
    description:
        'Single-line dense editor for names, paths, and free-form values.',
    glyph: BlenderGlyph.text,
    api: 'BlenderTextField(controller: controller)',
    tutorial: 'Use a controller when the field is part of a longer-lived form.',
    compose:
        'Pass a TextEditingController or use the field as a small form row.',
    state: 'Dispose controllers in the owning State object.',
    callback: 'Read the committed text when the surrounding action executes.',
    keywords: 'text input field form edit',
  ),
  _CatalogComponent(
    id: 'dropdown',
    category: 'Inputs',
    label: 'Dropdown',
    description: 'Anchored choice menu for compact enum and mode selection.',
    glyph: BlenderGlyph.panelDisclosureDown,
    api: 'BlenderDropdown(value: mode, items: modes, onChanged: selectMode)',
    tutorial:
        'Use a dropdown when the available values are known and mutually exclusive.',
    compose: 'Map domain values to BlenderMenuItem descriptors.',
    state: 'Store the selected value in the caller and derive the label.',
    callback: 'Switch the active mode or update a property from onChanged.',
    keywords: 'select enum menu choice',
  ),
  _CatalogComponent(
    id: 'multi-column-menu',
    category: 'Inputs',
    label: 'Multi-column Dropdown',
    description:
        'Responsive Blender-style grouped dropdown that becomes vertical when space is tight.',
    glyph: BlenderGlyph.menu,
    api:
        'BlenderMultiColumnMenu<String>(groups: groups, selected: selected, onSelected: select)',
    tutorial:
        'Use grouped choices for editor types; the menu automatically becomes vertical when its available width is too narrow for all columns.',
    compose:
        'Group related choices and place the menu inside BlenderPopover for an anchored dropdown.',
    state: 'Store the selected domain value and pass it back as selected.',
    callback: 'Close the popover and update the active editor from onSelected.',
    keywords: 'multi column dropdown editor type grouped menu picker',
  ),
  _CatalogComponent(
    id: 'search-field',
    category: 'Inputs',
    label: 'Search Field',
    description:
        'Compact filter input for catalogs, outliners, and property lists.',
    glyph: BlenderGlyph.search,
    api: 'BlenderSearchField(controller: search, onChanged: filter)',
    tutorial:
        'Keep search local to the list it filters so the UI remains explainable.',
    compose: 'Give the field a controller and a useful placeholder.',
    state: 'Normalize the query before filtering caller-owned items.',
    callback: 'Rebuild the visible list from the query in onChanged.',
    keywords: 'find filter query catalog',
  ),
  _CatalogComponent(
    id: 'list-view',
    category: 'Data display',
    label: 'List View',
    description:
        'Dense selectable rows with icons, detail text, and activation.',
    glyph: BlenderGlyph.grid,
    api: 'BlenderListView(items: entries, selectedId: selected)',
    tutorial:
        'Use lists for flat collections where row density matters more than hierarchy.',
    compose: 'Describe each row with a BlenderListItem.',
    state: 'Keep selectedId and activation state in the parent model.',
    callback:
        'Use onSelected for focus and onActivated for double-click behavior.',
    keywords: 'rows collection selection list data',
  ),
  _CatalogComponent(
    id: 'tree',
    category: 'Data display',
    label: 'Tree',
    description:
        'Hierarchical rows with disclosure, selection, visibility, and lock affordances.',
    glyph: BlenderGlyph.outliner,
    api: 'BlenderTree(roots: nodes, selectedId: selected)',
    tutorial:
        'Use a tree when the relationship between items is part of the task.',
    compose: 'Build recursive BlenderTreeNode values with stable IDs.',
    state:
        'Own expansion and selection in the domain model or tree state service.',
    callback:
        'React to node selection without coupling the tree to your model.',
    keywords: 'hierarchy outliner disclosure collection',
  ),
  _CatalogComponent(
    id: 'properties-editor',
    category: 'Data display',
    label: 'Properties Editor',
    description:
        'Nested Blender-style property panels with header enable controls and bounded range fields.',
    glyph: BlenderGlyph.properties,
    api: 'BlenderPropertiesEditor(groups: propertyGroups)',
    tutorial:
        'Use child groups for Blender-style subsections such as Viewport, Render, Shadows, and Advanced.',
    compose:
        'Create groups with children, headerLeading checkboxes, and bounded BlenderNumberField editors.',
    state:
        'Keep expansion, enable flags, and range values in the caller-owned state.',
    callback:
        'Route header and property callbacks to state updates; disabled bodies stay visible but inert.',
    keywords:
        'property form groups inspector settings nested sections checkbox range',
  ),
  _CatalogComponent(
    id: 'notice',
    category: 'Feedback',
    label: 'Notice & Progress',
    description: 'Transient status messaging and compact progress feedback.',
    glyph: BlenderGlyph.info,
    api: 'BlenderNoticeBanner(message: message, level: level)',
    tutorial:
        'Use notices for user-visible status and progress for work with a measurable range.',
    compose: 'Choose the notice level that matches the severity.',
    state: 'Keep asynchronous job state outside the presentation widget.',
    callback: 'Update the banner or progress value as work reports status.',
    keywords: 'alert feedback status progress success warning',
  ),
  _CatalogComponent(
    id: 'tooltip',
    category: 'Feedback',
    label: 'Tooltip',
    description:
        'Delayed contextual help for dense controls and unfamiliar icons.',
    glyph: BlenderGlyph.info,
    api: 'BlenderTooltip(message: help, child: control)',
    tutorial:
        'Tooltips use Blender’s 500ms hover delay so pointer movement stays calm.',
    compose: 'Wrap the control with a concise message.',
    state: 'The tooltip owns only its delayed overlay lifecycle.',
    callback: 'Keep the actionable behavior on the wrapped child.',
    keywords: 'help hover hint delay',
  ),
  _CatalogComponent(
    id: 'popover',
    category: 'Feedback',
    label: 'Popover',
    description:
        'Anchored contextual surface for settings, menus, and compact inspectors.',
    glyph: BlenderGlyph.more,
    api: 'BlenderPopover(child: trigger, popover: buildPopover)',
    tutorial: 'Use a popover when the interaction belongs next to its trigger.',
    compose:
        'Return the surface from the popover builder and close it explicitly.',
    state: 'Keep open state and domain edits in the caller when they matter.',
    callback: 'Use the provided close callback after an action completes.',
    keywords: 'overlay anchored menu inspector contextual',
  ),
  _CatalogComponent(
    id: 'panel',
    category: 'Surfaces',
    label: 'Panel',
    description: 'Collapsible Blender surface for grouping related controls.',
    glyph: BlenderGlyph.panelDisclosureDown,
    api: 'BlenderPanel(title: "Transform", child: content)',
    tutorial:
        'Panels establish the visual and information hierarchy of dense pages.',
    compose: 'Give each panel one clear responsibility and a compact child.',
    state: 'Let the caller decide initial expansion and persist it if needed.',
    callback:
        'Place control callbacks in the child content, not in the panel shell.',
    keywords: 'surface group collapse section card',
  ),
  _CatalogComponent(
    id: 'tabs',
    category: 'Navigation & layout',
    label: 'Tabs',
    description:
        'Blender workspace-style navigation with selected and overflow states.',
    glyph: BlenderGlyph.grid,
    api: 'BlenderTabBar(tabs: labels, selectedIndex: index)',
    tutorial:
        'Use tabs when each destination is a sibling view of the same task.',
    compose: 'Provide ordered labels and the active index.',
    state: 'Persist the active index in the owning workspace or route.',
    callback:
        'Switch content from onChanged without coupling the tab row to it.',
    keywords: 'workspace navigation selected overflow',
  ),
  _CatalogComponent(
    id: 'breadcrumbs',
    category: 'Navigation & layout',
    label: 'Breadcrumbs',
    description: 'Compact path navigation for nested data and editor context.',
    glyph: BlenderGlyph.chevronRight,
    api: 'BlenderBreadcrumbs(items: path, onSelected: navigate)',
    tutorial:
        'Use breadcrumbs to make the current nesting and escape route visible.',
    compose: 'Pass the current path in display order.',
    state: 'Derive the path from the active document or selection.',
    callback: 'Navigate to the selected ancestor in onSelected.',
    keywords: 'path navigation hierarchy location',
  ),
  _CatalogComponent(
    id: 'splitter',
    category: 'Navigation & layout',
    label: 'Splitter',
    description:
        'Resizable two-region layout primitive for desktop workspaces.',
    glyph: BlenderGlyph.split,
    api: 'BlenderSplitter(first: main, second: inspector)',
    tutorial:
        'Use a splitter when both regions are first-class and need independent space.',
    compose: 'Provide two region widgets and an initial fraction.',
    state:
        'Persist the fraction in the workspace layout when the split is durable.',
    callback:
        'Listen to onFractionChanged to save or coordinate adjacent regions.',
    keywords: 'resize divider pane docking layout',
  ),
  _CatalogComponent(
    id: 'toolbar',
    category: 'Navigation & layout',
    label: 'Toolbar',
    description:
        'Scrollable dense row for editor actions and workspace chrome.',
    glyph: BlenderGlyph.menu,
    api: 'BlenderToolbar(children: actions, background: color)',
    tutorial:
        'Use a toolbar to group immediate editor actions without adding panel weight.',
    compose:
        'Order controls from global to local and supply tooltips for icons.',
    state: 'Let each action read the active editor or workspace state.',
    callback: 'Connect buttons to commands or local state transitions.',
    keywords: 'header actions editor chrome row',
  ),
  _CatalogComponent(
    id: 'timeline',
    category: 'Editors',
    label: 'Timeline',
    description:
        'Compact frame range and keyframe surface for animation workflows.',
    glyph: BlenderGlyph.timeline,
    api: 'BlenderTimeline(model: timeline, onCurrentFrameChanged: seek)',
    tutorial:
        'Use a timeline model to keep frame semantics separate from painting.',
    compose: 'Describe tracks and keyframes with BlenderTimelineModel.',
    state: 'Own currentFrame and playback state in the application.',
    callback: 'Seek or update the active frame from onCurrentFrameChanged.',
    keywords: 'animation frames keyframes playback editor',
  ),
  _CatalogComponent(
    id: 'node-editor',
    category: 'Editors',
    label: 'Node Editor',
    description:
        'Pan-and-zoom graph surface with typed input and output sockets.',
    glyph: BlenderGlyph.node,
    api: 'BlenderNodeEditor(model: BlenderNodeGraphModel)',
    tutorial:
        'Use a graph model so node identity and links remain application-owned.',
    compose: 'Define node positions, sockets, and links in the model.',
    state: 'Persist positions and selection in your graph document.',
    callback: 'Use node selection and movement callbacks to mutate the graph.',
    keywords: 'nodes graph links sockets editor',
  ),
  _CatalogComponent(
    id: 'file-browser',
    category: 'Editors',
    label: 'File Browser',
    description:
        'Dense path, search, list, and selection surface for files and assets.',
    glyph: BlenderGlyph.folder,
    api: 'BlenderFileBrowser(entries: files, selectedPath: path)',
    tutorial:
        'Use the file browser as a presentation layer over your storage adapter.',
    compose: 'Describe entries with stable paths and optional details.',
    state: 'Keep filesystem permissions and persistence outside the widget.',
    callback: 'Open or select entries through the supplied callbacks.',
    keywords: 'files folders assets path browser search',
  ),
  _CatalogComponent(
    id: 'spreadsheet',
    category: 'Editors',
    label: 'Spreadsheet Editor',
    description:
        'Scrollable columnar data surface for inspecting generated values.',
    glyph: BlenderGlyph.spreadsheet,
    api: 'BlenderSpreadsheetEditor(columns: columns, rows: rows)',
    tutorial:
        'Use a spreadsheet for inspection and filtering, not as your source of truth.',
    compose: 'Map data fields to columns and stable row IDs.',
    state: 'Generate rows from the active object or computation.',
    callback: 'Coordinate filters and selection from the containing editor.',
    keywords: 'table rows columns data inspect editor',
  ),
  _CatalogComponent(
    id: 'history-store',
    category: 'App services',
    label: 'History Store',
    description:
        'Scoped immutable state with undo and redo for editor workflows.',
    glyph: BlenderGlyph.undo,
    api: 'BlenderHistoryStore<AppState>(initialState)',
    tutorial:
        'Use a history store when edits should be reversible without global state.',
    compose: 'Create the store at the application or workspace boundary.',
    state: 'Expose the current value through BlenderStateScope.',
    callback: 'Call update, undo, and redo from normal UI actions.',
    keywords: 'state undo redo immutable store',
  ),
  _CatalogComponent(
    id: 'command-registry',
    category: 'App services',
    label: 'Command Registry',
    description:
        'Shared command descriptors for menus, shortcuts, and buttons.',
    glyph: BlenderGlyph.modifier,
    api: 'BlenderCommandRegistry()..register(command)',
    tutorial:
        'Use commands to keep execution semantics shared across multiple surfaces.',
    compose:
        'Register a label, shortcut, enabled predicate, and execute callback.',
    state:
        'Let commands read scoped services rather than process-wide singletons.',
    callback: 'Invoke the same command from buttons, menus, and keymaps.',
    keywords: 'commands menu shortcuts registry actions',
  ),
];
