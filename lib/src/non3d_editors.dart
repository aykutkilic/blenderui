import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'advanced_controls.dart';
import 'collections.dart';
import 'controls.dart';
import 'icons.dart';
import 'editors.dart';
import 'layout.dart';
import 'overlay_host.dart';
import 'property_forms.dart';
import 'templates.dart';
import 'theme.dart';

enum BlenderConsoleLineKind { output, input, error, info }

class BlenderConsoleLine {
  const BlenderConsoleLine(
    this.text, {
    this.kind = BlenderConsoleLineKind.output,
  });

  final String text;
  final BlenderConsoleLineKind kind;
}

class BlenderConsoleEditor extends StatefulWidget {
  const BlenderConsoleEditor({
    super.key,
    this.lines = const <BlenderConsoleLine>[],
    this.onCommand,
    this.prompt = '>>>',
    this.title = 'Console',
  });

  final List<BlenderConsoleLine> lines;
  final ValueChanged<String>? onCommand;
  final String prompt;
  final String title;

  @override
  State<BlenderConsoleEditor> createState() => _BlenderConsoleEditorState();
}

class BlenderInfoReport {
  const BlenderInfoReport({
    required this.id,
    required this.message,
    this.level = BlenderNoticeLevel.info,
    this.timestamp,
  });

  final String id;
  final String message;
  final BlenderNoticeLevel level;
  final String? timestamp;
}

class BlenderInfoEditor extends StatelessWidget {
  const BlenderInfoEditor({
    super.key,
    required this.reports,
    this.onDismiss,
    this.title = 'Info',
  });

  final List<BlenderInfoReport> reports;
  final ValueChanged<BlenderInfoReport>? onDismiss;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: reports.isEmpty
          ? Center(
              child: Text(
                'No reports',
                style: theme.textTheme.caption.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(6),
              itemCount: reports.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final report = reports[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: BlenderNoticeBanner(
                        message: report.message,
                        level: report.level,
                      ),
                    ),
                    if (report.timestamp != null) ...<Widget>[
                      const SizedBox(width: 6),
                      Text(
                        report.timestamp!,
                        style: theme.textTheme.caption.copyWith(
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ],
                    if (onDismiss != null)
                      BlenderIconButton(
                        glyph: BlenderGlyph.close,
                        onPressed: () => onDismiss!(report),
                        tooltip: 'Dismiss report',
                        size: 20,
                      ),
                  ],
                );
              },
            ),
    );
  }
}

class _BlenderConsoleEditorState extends State<BlenderConsoleEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String command) {
    if (command.trim().isEmpty) return;
    widget.onCommand?.call(command);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: widget.lines.length,
              itemBuilder: (context, index) {
                final line = widget.lines[index];
                final color = switch (line.kind) {
                  BlenderConsoleLineKind.output => theme.colors.foreground,
                  BlenderConsoleLineKind.input => theme.colors.info,
                  BlenderConsoleLineKind.error => theme.colors.error,
                  BlenderConsoleLineKind.info => theme.colors.foregroundMuted,
                };
                return Text(
                  line.text,
                  style: theme.textTheme.body.copyWith(color: color),
                );
              },
            ),
          ),
          Container(
            height: theme.density.controlHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: theme.colors.textField,
              border: Border(top: BorderSide(color: theme.colors.editorBorder)),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  widget.prompt,
                  style: theme.textTheme.body.copyWith(
                    color: theme.colors.info,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: EditableText(
                    controller: _controller,
                    focusNode: _focusNode,
                    style: theme.textTheme.body.copyWith(
                      color: theme.colors.foreground,
                    ),
                    cursorColor: theme.colors.cursor,
                    backgroundCursorColor: theme.colors.foregroundMuted,
                    selectionColor: theme.colors.selection,
                    onSubmitted: _submit,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlenderTextEditor extends StatefulWidget {
  const BlenderTextEditor({
    super.key,
    this.text = '',
    this.onChanged,
    this.readOnly = false,
    this.sidebar,
    this.sidebarWidth = 240,
    this.title = 'Text Editor',
  });

  final String text;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final Widget? sidebar;
  final double sidebarWidth;
  final String title;

  @override
  State<BlenderTextEditor> createState() => _BlenderTextEditorState();
}

class _BlenderTextEditorState extends State<BlenderTextEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(BlenderTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focusNode.hasFocus && oldWidget.text != widget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final lineCount = '\n'.allMatches(_controller.text).length + 1;
    final editor = BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            width: 42,
            padding: const EdgeInsets.only(top: 8, right: 8),
            color: theme.colors.textField,
            child: DefaultTextStyle(
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  for (var line = 1; line <= lineCount; line++)
                    SizedBox(height: 18, child: Text('$line')),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: theme.colors.textField,
              padding: const EdgeInsets.all(8),
              child: EditableText(
                controller: _controller,
                focusNode: _focusNode,
                style: theme.textTheme.body.copyWith(
                  color: theme.colors.foreground,
                  fontFamily: 'monospace',
                ),
                cursorColor: theme.colors.cursor,
                backgroundCursorColor: theme.colors.foregroundMuted,
                selectionColor: theme.colors.selection,
                onChanged: (value) {
                  setState(() {});
                  widget.onChanged?.call(value);
                },
                readOnly: widget.readOnly,
                maxLines: null,
                expands: true,
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.sidebar == null) return editor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: editor),
        SizedBox(width: widget.sidebarWidth, child: widget.sidebar),
      ],
    );
  }
}

/// Source-shaped Text Editor sidebar panels from `space_text.py`.
///
/// Text datablock selection, search execution, and editor preferences remain
/// caller-owned; this widget supplies the visual Properties and Find & Replace
/// panel hierarchy.
class BlenderTextEditorSidebar extends StatelessWidget {
  const BlenderTextEditorSidebar({super.key});

  Widget _body(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );

  Widget _panel(String title, List<Widget> children, {bool expanded = false}) {
    return BlenderPanel(
      title: title,
      collapsible: true,
      initiallyExpanded: expanded,
      child: _body(children),
    );
  }

  Widget _check(String label, {bool value = true}) => BlenderPropertyRow(
    label: label,
    editor: BlenderCheckbox(value: value, onChanged: (_) {}),
  );

  Widget _number(String label, double value, {int decimalDigits = 0}) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderNumberField(
        value: value,
        decimalDigits: decimalDigits,
        onChanged: (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(6),
      children: <Widget>[
        _panel('Properties', <Widget>[
          _check('Show Margin'),
          _number('Margin Column', 80),
          _number('Font Size', 12),
          _number('Tab Width', 4),
          _panel('Indentation', <Widget>[
            const BlenderPropertyRow(
              label: 'Mode',
              editor: BlenderDropdown<String>(
                value: 'Spaces',
                items: <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Spaces', label: 'Spaces'),
                  BlenderMenuItem<String>(value: 'Tabs', label: 'Tabs'),
                ],
                onChanged: _noopString,
              ),
            ),
            _check('Use Tabs', value: false),
          ]),
        ], expanded: true),
        _panel('Find & Replace', <Widget>[
          const BlenderPropertyRow(
            label: 'Find',
            editor: BlenderDropdown<String>(
              value: 'search text',
              items: <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'search text',
                  label: 'search text',
                ),
                BlenderMenuItem<String>(
                  value: 'another search text',
                  label: 'another search text',
                ),
              ],
              onChanged: _noopString,
            ),
          ),
          const SizedBox(height: 4),
          const BlenderButton(label: 'Find', onPressed: _noop),
          const SizedBox(height: 6),
          const BlenderPropertyRow(
            label: 'Replace',
            editor: BlenderDropdown<String>(
              value: 'replacement',
              items: <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'replacement',
                  label: 'replacement',
                ),
                BlenderMenuItem<String>(value: 'value', label: 'value'),
              ],
              onChanged: _noopString,
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            children: <Widget>[
              const Expanded(
                child: BlenderButton(label: 'Replace', onPressed: _noop),
              ),
              const SizedBox(width: 4),
              const Expanded(
                child: BlenderButton(label: 'Replace All', onPressed: _noop),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _check('Match Case', value: false),
          _check('Wrap Around'),
          _check('All Data-Blocks', value: false),
        ], expanded: true),
      ],
    );
  }
}

void _noopString(String? _) {}

class BlenderSpreadsheetColumn {
  const BlenderSpreadsheetColumn({
    required this.id,
    required this.label,
    this.width = 120,
  });

  final String id;
  final String label;
  final double width;
}

class BlenderSpreadsheetRow {
  const BlenderSpreadsheetRow({required this.id, required this.values});

  final String id;
  final List<String> values;
}

class BlenderSpreadsheetEditor extends StatelessWidget {
  const BlenderSpreadsheetEditor({
    super.key,
    required this.columns,
    required this.rows,
    this.showOnlySelected = false,
    this.useFilter = false,
    this.title = 'Spreadsheet',
  });

  final List<BlenderSpreadsheetColumn> columns;
  final List<BlenderSpreadsheetRow> rows;
  final bool showOnlySelected;
  final bool useFilter;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    Widget row(List<Widget> cells, {Color? color}) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
        ),
        child: Row(children: cells),
      );
    }

    Widget cell(String text, double width, {bool header = false}) {
      return SizedBox(
        width: width,
        height: theme.density.rowHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: (header ? theme.textTheme.heading : theme.textTheme.label)
                  .copyWith(
                    color: header
                        ? theme.colors.foreground
                        : theme.colors.foregroundMuted,
                  ),
            ),
          ),
        ),
      );
    }

    final grid = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: columns.fold<double>(0, (sum, column) => sum + column.width),
        child: Column(
          children: <Widget>[
            row([
              for (final column in columns)
                cell(column.label, column.width, header: true),
            ], color: theme.colors.panelHeader),
            Expanded(
              child: ListView.builder(
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final data = rows[index];
                  return row([
                    for (
                      var columnIndex = 0;
                      columnIndex < columns.length;
                      columnIndex++
                    )
                      cell(
                        columnIndex < data.values.length
                            ? data.values[columnIndex]
                            : '',
                        columns[columnIndex].width,
                      ),
                  ], color: index.isEven ? theme.colors.surface : null);
                },
              ),
            ),
          ],
        ),
      ),
    );
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 30,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.panelHeader,
                border: Border(
                  bottom: BorderSide(color: theme.colors.editorBorder),
                ),
              ),
              child: Row(
                children: <Widget>[
                  BlenderIconButton(
                    glyph: BlenderGlyph.filter,
                    selected: useFilter,
                    tooltip: 'Use Filter',
                    onPressed: _spreadsheetNoop,
                    size: 26,
                  ),
                  BlenderCheckbox(
                    value: showOnlySelected,
                    label: 'Only Selected',
                    onChanged: _spreadsheetNoopBool,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Internal Attributes: hidden',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.caption.copyWith(
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
          ),
          Expanded(child: grid),
        ],
      ),
    );
  }
}

void _spreadsheetNoop() {}

void _spreadsheetNoopBool(bool _) {}

class BlenderImageEditor extends StatefulWidget {
  const BlenderImageEditor({
    super.key,
    this.image,
    this.label = 'No Image',
    this.sidebar,
    this.sidebarWidth = 240,
    this.title = 'Image Editor',
  });

  final Widget? image;
  final String label;
  final Widget? sidebar;
  final double sidebarWidth;
  final String title;

  @override
  State<BlenderImageEditor> createState() => _BlenderImageEditorState();
}

class _BlenderImageEditorState extends State<BlenderImageEditor> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _resetView() {
    _transformationController.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      headerActions: <Widget>[
        BlenderIconButton(
          glyph: BlenderGlyph.refresh,
          onPressed: _resetView,
          tooltip: 'Reset view',
          size: 22,
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.maximize,
          tooltip: 'Fit image',
          size: 22,
        ),
      ],
      child: widget.sidebar == null
          ? _buildCanvas(theme)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: _buildCanvas(theme)),
                SizedBox(
                  width: widget.sidebarWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.surface,
                      border: Border(
                        left: BorderSide(color: theme.colors.editorBorder),
                      ),
                    ),
                    child: widget.sidebar,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCanvas(BlenderThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) => InteractiveViewer(
        transformationController: _transformationController,
        minScale: .1,
        maxScale: 8,
        boundaryMargin: const EdgeInsets.all(240),
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              const CustomPaint(painter: _BlenderCheckerPainter()),
              if (widget.image != null)
                Center(child: widget.image)
              else
                Center(
                  child: Text(
                    widget.label,
                    style: theme.textTheme.body.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlenderCheckerPainter extends CustomPainter {
  const _BlenderCheckerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const tile = 12.0;
    final light = Paint()..color = const Color(0xFF303030);
    final dark = Paint()..color = const Color(0xFF242424);
    for (var y = 0.0; y < size.height; y += tile) {
      for (var x = 0.0; x < size.width; x += tile) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, tile, tile),
          ((x / tile).floor() + (y / tile).floor()).isEven ? light : dark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BlenderCheckerPainter oldDelegate) => false;
}

class BlenderAssetTile {
  const BlenderAssetTile({
    required this.id,
    required this.label,
    this.preview,
    this.color,
  });

  final String id;
  final String label;
  final Widget? preview;
  final Color? color;
}

class BlenderAssetShelf extends StatelessWidget {
  const BlenderAssetShelf({
    super.key,
    required this.assets,
    this.selectedId,
    this.onSelected,
    this.title = 'Asset Shelf',
  });

  final List<BlenderAssetTile> assets;
  final String? selectedId;
  final ValueChanged<BlenderAssetTile>? onSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 120,
          mainAxisExtent: 92,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          final selected = asset.id == selectedId;
          return GestureDetector(
            onTap: onSelected == null ? null : () => onSelected!(asset),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: selected ? theme.colors.selection : theme.colors.surface,
                border: Border.all(
                  color: selected
                      ? theme.colors.editorOutlineActive
                      : theme.colors.editorBorder,
                ),
                borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
              ),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child:
                        asset.preview ??
                        ColoredBox(
                          color: asset.color ?? theme.colors.buttonPressed,
                          child: Center(
                            child: BlenderIcon(
                              BlenderGlyph.cube,
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    child: Text(
                      asset.label,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.caption,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class BlenderKeymapEntry {
  const BlenderKeymapEntry({
    required this.id,
    required this.action,
    required this.shortcut,
    this.category = 'General',
    this.detail,
    this.enabled = true,
  });

  final String id;
  final String action;
  final String shortcut;
  final String category;
  final String? detail;
  final bool enabled;
}

class BlenderKeymapEditor extends StatelessWidget {
  const BlenderKeymapEditor({
    super.key,
    required this.entries,
    required this.searchController,
    this.selectedId,
    this.onSelected,
    this.title = 'Keymap',
  });

  final List<BlenderKeymapEntry> entries;
  final TextEditingController searchController;
  final String? selectedId;
  final ValueChanged<BlenderKeymapEntry>? onSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: searchController,
        builder: (context, value, child) {
          final query = value.text.trim().toLowerCase();
          final visible = entries
              .where(
                (entry) =>
                    query.isEmpty ||
                    entry.action.toLowerCase().contains(query) ||
                    entry.shortcut.toLowerCase().contains(query) ||
                    entry.category.toLowerCase().contains(query) ||
                    (entry.detail?.toLowerCase().contains(query) ?? false),
              )
              .toList(growable: false);
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
                child: BlenderFilterBar(
                  controller: searchController,
                  placeholder: 'Search keymap',
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('No shortcuts'))
                    : ListView.builder(
                        itemCount: visible.length,
                        itemExtent: BlenderTheme.of(context).density.rowHeight,
                        itemBuilder: (context, index) {
                          final entry = visible[index];
                          final selected = entry.id == selectedId;
                          final active = entry.enabled && onSelected != null;
                          return Semantics(
                            selected: selected,
                            enabled: entry.enabled,
                            button: active,
                            label: '${entry.category}: ${entry.action}',
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: active ? () => onSelected!(entry) : null,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: selected
                                      ? BlenderTheme.of(
                                          context,
                                        ).colors.selection
                                      : null,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              entry.action,
                                              overflow: TextOverflow.ellipsis,
                                              style: BlenderTheme.of(
                                                context,
                                              ).textTheme.label,
                                            ),
                                            Text(
                                              entry.category,
                                              overflow: TextOverflow.ellipsis,
                                              style: BlenderTheme.of(context)
                                                  .textTheme
                                                  .caption
                                                  .copyWith(
                                                    color: BlenderTheme.of(
                                                      context,
                                                    ).colors.foregroundMuted,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      BlenderKeycap(entry.shortcut),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BlenderPreferenceSection {
  const BlenderPreferenceSection({
    required this.id,
    required this.category,
    required this.title,
    required this.child,
    this.searchTerms = const <String>[],
    this.initiallyExpanded = true,
  });

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

  Widget _buildCategoryNavigation(String? category, BlenderThemeData theme) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        children: <Widget>[
          for (final group in _categoryGroups)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                children: <Widget>[
                  for (final item in group.categories)
                    if (widget.categories.contains(item))
                      _PreferencesCategoryButton(
                        label: item,
                        selected: item == category,
                        onPressed: widget.onCategoryChanged == null
                            ? () {}
                            : () => widget.onCategoryChanged!(item),
                      ),
                ],
              ),
            ),
        ],
      ),
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
    final visibleSections = _visibleSections(category);
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 148,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.surface,
                border: Border(
                  right: BorderSide(color: theme.colors.editorBorder),
                ),
              ),
              child: _buildCategoryNavigation(category, theme),
            ),
          ),
          Expanded(child: _buildSections(context, visibleSections)),
        ],
      ),
    );
  }
}

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
  });

  final List<String> categories;
  final List<BlenderPreferenceSection> sections;
  final List<BlenderPreferenceCategoryGroup> categoryGroups;
  final String? initialCategory;
  final String title;
  final double width;
  final double height;
  final ValueChanged<String>? onCategoryChanged;

  @override
  State<BlenderPreferencesWindow> createState() =>
      _BlenderPreferencesWindowState();
}

class _BlenderPreferencesWindowState extends State<BlenderPreferencesWindow> {
  late String _category;
  late double _width;
  late double _height;
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

  void _resize(DragUpdateDetails details) {
    final viewport = MediaQuery.sizeOf(context);
    setState(() {
      _width = (_width + details.delta.dx)
          .clamp(520, viewport.width - 28)
          .toDouble();
      _height = (_height + details.delta.dy)
          .clamp(360, viewport.height - 28)
          .toDouble();
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
    final width = math
        .min(_width, math.max(520, viewport.width - 28))
        .toDouble();
    final height = math
        .min(_height, math.max(360, viewport.height - 28))
        .toDouble();
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.canvas,
              border: Border.all(color: theme.colors.editorBorder),
              borderRadius: BorderRadius.circular(18),
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
                _PreferencesWindowTitleBar(title: widget.title),
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
                                child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(
                                    context,
                                  ).copyWith(scrollbars: false),
                                  child: ListView(
                                    padding: const EdgeInsets.fromLTRB(
                                      14,
                                      0,
                                      14,
                                      14,
                                    ),
                                    children: <Widget>[
                                      for (final group in _categoryGroups)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 6,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              if (group.label case final label?)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        10,
                                                        10,
                                                        10,
                                                        4,
                                                      ),
                                                  child: Text(
                                                    label,
                                                    style: theme
                                                        .textTheme
                                                        .caption
                                                        .copyWith(
                                                          color: theme
                                                              .colors
                                                              .foregroundMuted,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ),
                                              for (final category
                                                  in group.categories)
                                                if (widget.categories.contains(
                                                  category,
                                                ))
                                                  _PreferencesCategoryButton(
                                                    label: category,
                                                    selected:
                                                        category == _category,
                                                    onPressed: () =>
                                                        _selectCategory(
                                                          category,
                                                        ),
                                                  ),
                                            ],
                                          ),
                                        ),
                                    ],
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
                                    popover: (context, close) =>
                                        BlenderMenu<String>(
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
          Positioned(
            right: 0,
            bottom: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeDownRight,
              child: GestureDetector(
                key: const ValueKey<String>('preferences-window-resize-handle'),
                behavior: HitTestBehavior.opaque,
                onPanUpdate: _resize,
                child: const SizedBox(width: 18, height: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferencesWindowTitleBar extends StatelessWidget {
  const _PreferencesWindowTitleBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    Widget dot(Color color) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: theme.colors.canvas,
        border: Border(bottom: BorderSide(color: theme.colors.editorBorder)),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Row(
        children: <Widget>[
          dot(const Color(0xFFFF5F57)),
          const SizedBox(width: 12),
          dot(const Color(0xFFFFBD2E)),
          const SizedBox(width: 12),
          dot(const Color(0xFF28C840)),
          const SizedBox(width: 24),
          Text(title, style: theme.textTheme.heading),
        ],
      ),
    );
  }
}

class _PreferencesCategoryButton extends StatelessWidget {
  const _PreferencesCategoryButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? theme.colors.menuSelection : theme.colors.button,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: theme.textTheme.body.copyWith(
            color: selected ? theme.colors.foreground : theme.colors.foreground,
          ),
        ),
      ),
    );
  }
}

/// Source-shaped Project editor from `space_project.py`.
///
/// Project discovery, saving, and filesystem operations remain caller-owned;
/// this widget mirrors Blender's Navigation, General, Project, and Save
/// Project surfaces.
class BlenderProjectEditor extends StatelessWidget {
  const BlenderProjectEditor({
    super.key,
    this.projectName = 'Showcase Project',
    this.rootPath = '/showcase',
    this.hasProject = true,
    this.title = 'Project',
  });

  final String projectName;
  final String rootPath;
  final bool hasProject;
  final String title;

  Widget _field(String label, String value) => BlenderPropertyRow(
    label: label,
    editor: BlenderDropdown<String>(
      value: value,
      items: <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: value, label: value),
      ],
      onChanged: _noopString,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final content = hasProject
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlenderPanel(
                title: 'Project',
                collapsible: false,
                initiallyExpanded: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _field('Name', projectName),
                    _field('Root Path', rootPath),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              BlenderPanel(
                title: 'Save Project',
                collapsible: false,
                initiallyExpanded: true,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Project changes are saved with the current file.',
                        style: theme.textTheme.caption.copyWith(
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const BlenderButton(
                      label: 'Save Project',
                      onPressed: _noop,
                    ),
                  ],
                ),
              ),
            ],
          )
        : BlenderPanel(
            title: 'No Project',
            collapsible: false,
            initiallyExpanded: true,
            child: Column(
              children: <Widget>[
                Text(
                  'No active project.',
                  style: theme.textTheme.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Save the current file or open a file inside a project directory.',
                  style: theme.textTheme.caption.copyWith(
                    color: theme.colors.foregroundMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const BlenderButton(
                      label: 'Save File...',
                      onPressed: _noop,
                    ),
                    const SizedBox(width: 6),
                    const BlenderButton(
                      label: 'Open in Project',
                      onPressed: _noop,
                    ),
                  ],
                ),
              ],
            ),
          );
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 150,
            child: BlenderPanel(
              title: 'Navigation',
              collapsible: false,
              initiallyExpanded: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const BlenderButton(
                    label: 'General',
                    variant: BlenderButtonVariant.tab,
                    onPressed: _noop,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Project',
                    style: theme.textTheme.caption.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: SingleChildScrollView(child: content)),
        ],
      ),
    );
  }
}

class BlenderCurveChannel {
  const BlenderCurveChannel({
    required this.id,
    required this.label,
    required this.points,
    this.color,
  });

  final String id;
  final String label;
  final List<Offset> points;
  final Color? color;
}

/// A 2D Graph Editor surface with channels, grid, and normalized curves.
class BlenderCurveEditor extends StatelessWidget {
  const BlenderCurveEditor({
    super.key,
    required this.channels,
    this.title = 'Graph Editor',
  });

  final List<BlenderCurveChannel> channels;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: CustomPaint(
        painter: _BlenderCurveEditorPainter(
          channels: channels,
          colors: theme.colors,
          textTheme: theme.textTheme,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BlenderCurveEditorPainter extends CustomPainter {
  _BlenderCurveEditorPainter({
    required this.channels,
    required this.colors,
    required this.textTheme,
  });

  final List<BlenderCurveChannel> channels;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;

  @override
  void paint(Canvas canvas, Size size) {
    final gutter = math.min(126, size.width * .25).toDouble();
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.canvas);
    final grid = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    for (var i = 1; i < 10; i++) {
      final x = gutter + (size.width - gutter) * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var i = 1; i < 8; i++) {
      final y = (size.height * i / 8).toDouble();
      canvas.drawLine(Offset(gutter, y), Offset(size.width, y), grid);
    }
    canvas.drawRect(
      Rect.fromLTWH(0, 0, gutter, size.height),
      Paint()..color = colors.surface,
    );
    final rowHeight = channels.isEmpty
        ? size.height
        : math.max(22, size.height / channels.length).toDouble();
    for (var index = 0; index < channels.length; index++) {
      final channel = channels[index];
      final y = index * rowHeight;
      final label = TextPainter(
        text: TextSpan(
          text: channel.label,
          style: textTheme.caption.copyWith(color: colors.foreground),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: gutter - 10);
      label.paint(canvas, Offset(6, y + 5));
      if (channel.points.length < 2) continue;
      final path = Path();
      for (
        var pointIndex = 0;
        pointIndex < channel.points.length;
        pointIndex++
      ) {
        final point = channel.points[pointIndex];
        final x =
            gutter + point.dx.clamp(0, 1).toDouble() * (size.width - gutter);
        final pointY = y + (1 - point.dy.clamp(0, 1).toDouble()) * rowHeight;
        if (pointIndex == 0) {
          path.moveTo(x, pointY);
        } else {
          path.lineTo(x, pointY);
        }
        canvas.drawCircle(
          Offset(x, pointY),
          3,
          Paint()..color = channel.color ?? colors.accent,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = channel.color ?? colors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderCurveEditorPainter oldDelegate) {
    return channels != oldDelegate.channels || colors != oldDelegate.colors;
  }
}

/// A Dope Sheet surface using the timeline model but with an editor-specific
/// title and dense channel layout.
class BlenderDopeSheetEditor extends StatelessWidget {
  const BlenderDopeSheetEditor({
    super.key,
    required this.model,
    required this.onCurrentFrameChanged,
    this.sidebar,
    this.sidebarWidth = 240,
    this.title = 'Dope Sheet',
  });

  final BlenderTimelineModel model;
  final ValueChanged<double> onCurrentFrameChanged;
  final Widget? sidebar;
  final double sidebarWidth;
  final String title;

  @override
  Widget build(BuildContext context) {
    final timeline = BlenderTimeline(
      model: model,
      onCurrentFrameChanged: onCurrentFrameChanged,
      title: title,
    );
    final resolvedSidebar = sidebar ?? const BlenderDopeSheetSidebar();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: timeline),
        SizedBox(width: sidebarWidth, child: resolvedSidebar),
      ],
    );
  }
}

/// Source-shaped Dope Sheet/Action sidebar panels from `space_dopesheet.py`.
///
/// Action datablocks, slots, keyframe operations, and shape-key state remain
/// caller-owned; this widget provides the visual panel hierarchy only.
class BlenderDopeSheetSidebar extends StatelessWidget {
  const BlenderDopeSheetSidebar({super.key, this.shapeKeyMode = false});

  final bool shapeKeyMode;

  Widget _body(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );

  Widget _panel(String title, List<Widget> children, {bool expanded = false}) {
    return BlenderPanel(
      title: title,
      collapsible: true,
      initiallyExpanded: expanded,
      child: _body(children),
    );
  }

  Widget _check(String label, {bool value = true}) => BlenderPropertyRow(
    label: label,
    editor: BlenderCheckbox(value: value, onChanged: (_) {}),
  );

  Widget _number(String label, double value) => BlenderPropertyRow(
    label: label,
    editor: BlenderNumberField(
      value: value,
      decimalDigits: 2,
      onChanged: (_) {},
    ),
  );

  Widget _choice(String label, String value, List<String> values) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderDropdown<String>(
        value: value,
        items: <BlenderMenuItem<String>>[
          for (final item in values)
            BlenderMenuItem<String>(value: item, label: item),
        ],
        onChanged: (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(6),
      children: <Widget>[
        _panel('Action', <Widget>[
          _choice('Active Action', 'CubeAction', <String>[
            'CubeAction',
            'IdleAction',
          ]),
          _check('Use Frame Range', value: false),
          _number('Start', 1),
          _number('End', 120),
          _check('Cyclic', value: false),
          _panel('Slot', <Widget>[
            _choice('Name', 'Object', <String>['Object', 'Camera']),
            _choice('Type', 'Object', <String>['Object', 'Armature']),
          ]),
          _panel('Custom Properties', <Widget>[_number('example_value', 1)]),
        ], expanded: true),
        _panel('View', <Widget>[
          _check('Scene Range'),
          _check('Markers'),
          _check('Seconds'),
          _check('Show Region', value: false),
        ], expanded: true),
        if (shapeKeyMode)
          _panel('Shape Key', <Widget>[
            _number('Value', .5),
            _number('Frame', 1),
          ], expanded: true),
      ],
    );
  }
}

class BlenderSequencerStrip {
  const BlenderSequencerStrip({
    required this.id,
    required this.label,
    required this.start,
    required this.end,
    this.channel = 0,
    this.color,
    this.muted = false,
  });

  final String id;
  final String label;
  final double start;
  final double end;
  final int channel;
  final Color? color;
  final bool muted;
}

/// Source-shaped strip Properties context for the Video Sequencer.
///
/// The panel tree follows `properties_strip.py`; it is intentionally a
/// descriptor-only surface so strip evaluation, media loading, and sequencer
/// operators remain owned by the embedding application.
class BlenderStripProperties extends StatelessWidget {
  const BlenderStripProperties({super.key, this.title = 'Strip'});

  final String title;

  List<BlenderPropertyGroup> _groups() {
    const blendModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Replace', label: 'Replace'),
      BlenderMenuItem<String>(value: 'Alpha Over', label: 'Alpha Over'),
      BlenderMenuItem<String>(value: 'Add', label: 'Add'),
    ];
    const stripTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Movie', label: 'Movie'),
      BlenderMenuItem<String>(value: 'Image', label: 'Image'),
      BlenderMenuItem<String>(value: 'Text', label: 'Text'),
      BlenderMenuItem<String>(value: 'Color', label: 'Color'),
      BlenderMenuItem<String>(value: 'Sound', label: 'Sound'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyFactory.boolean(id, label, value);
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyFactory.number(
        id,
        label,
        value,
        min: min,
        max: max,
        decimalDigits: decimalDigits,
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyFactory.menu(id, label, value, items);
    }

    BlenderPropertyGroup panel(
      String id,
      String panelTitle, {
      bool expanded = false,
      List<BlenderPropertyDescriptor<dynamic>> properties =
          const <BlenderPropertyDescriptor<dynamic>>[],
      List<BlenderPropertyGroup> children = const <BlenderPropertyGroup>[],
    }) {
      return BlenderPropertyFactory.panel(
        id,
        panelTitle,
        initiallyExpanded: expanded,
        properties: properties,
        children: children,
      );
    }

    return <BlenderPropertyGroup>[
      panel(
        'strip-crop',
        'Crop',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'strip-crop-min-x',
            'Min X',
            0,
            min: -10000,
            max: 10000,
          ),
          numberProperty(
            'strip-crop-max-x',
            'Max X',
            1920,
            min: -10000,
            max: 10000,
          ),
          numberProperty(
            'strip-crop-max-y',
            'Max Y',
            1080,
            min: -10000,
            max: 10000,
          ),
          numberProperty(
            'strip-crop-min-y',
            'Min Y',
            0,
            min: -10000,
            max: 10000,
          ),
        ],
      ),
      panel(
        'strip-effect',
        'Effect Strip',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('strip-effect-type', 'Type', 'Color', stripTypes),
          booleanProperty('strip-default-fade', 'Default Fade', true),
          numberProperty(
            'strip-effect-fader',
            'Effect Fader',
            1,
            min: 0,
            max: 1,
          ),
          enumProperty('strip-blend-mode', 'Blend Mode', 'Replace', blendModes),
          numberProperty('strip-factor', 'Factor', 1, min: 0, max: 1),
        ],
        children: <BlenderPropertyGroup>[
          panel(
            'strip-effect-layout',
            'Layout',
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty('strip-text-location-x', 'Location X', 0),
              numberProperty('strip-text-location-y', 'Location Y', 0),
              enumProperty(
                'strip-text-alignment',
                'Alignment',
                'Center',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Left', label: 'Left'),
                  BlenderMenuItem<String>(value: 'Center', label: 'Center'),
                  BlenderMenuItem<String>(value: 'Right', label: 'Right'),
                ],
              ),
              numberProperty(
                'strip-text-anchor-x',
                'Anchor X',
                .5,
                min: 0,
                max: 1,
              ),
              numberProperty(
                'strip-text-anchor-y',
                'Anchor Y',
                .5,
                min: 0,
                max: 1,
              ),
            ],
          ),
          panel(
            'strip-effect-style',
            'Style',
            expanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              numberProperty(
                'strip-font-size',
                'Font Size',
                48,
                min: 1,
                max: 512,
                decimalDigits: 0,
              ),
              booleanProperty('strip-bold', 'Bold', false),
              booleanProperty('strip-italic', 'Italic', false),
              numberProperty('strip-line-spacing', 'Line Spacing', 1, min: 0),
            ],
            children: <BlenderPropertyGroup>[
              panel(
                'strip-effect-outline',
                'Outline',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty('strip-outline-enabled', 'Enabled', false),
                  numberProperty('strip-outline-width', 'Width', 1, min: 0),
                ],
              ),
              panel(
                'strip-effect-shadow',
                'Shadow',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty('strip-shadow-enabled', 'Enabled', false),
                  numberProperty(
                    'strip-shadow-angle',
                    'Angle',
                    45,
                    min: -180,
                    max: 180,
                  ),
                  numberProperty('strip-shadow-offset', 'Offset', 2, min: 0),
                  numberProperty('strip-shadow-blur', 'Blur', 0, min: 0),
                ],
              ),
              panel(
                'strip-effect-box',
                'Box',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  booleanProperty('strip-box-enabled', 'Enabled', false),
                  numberProperty(
                    'strip-box-margin',
                    'Margin',
                    .05,
                    min: 0,
                    max: 1,
                  ),
                  numberProperty(
                    'strip-box-roundness',
                    'Roundness',
                    .1,
                    min: 0,
                    max: 1,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      panel(
        'strip-source',
        'Source',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty('strip-source-type', 'Type', 'Movie', stripTypes),
          booleanProperty('strip-use-memory-cache', 'Memory Cache', true),
          enumProperty(
            'strip-alpha-mode',
            'Alpha',
            'Straight',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Straight', label: 'Straight'),
              BlenderMenuItem<String>(
                value: 'Premultiplied',
                label: 'Premultiplied',
              ),
            ],
          ),
          numberProperty(
            'strip-stream-index',
            'Stream Index',
            0,
            min: 0,
            decimalDigits: 0,
          ),
          booleanProperty('strip-deinterlace', 'Deinterlace', false),
          booleanProperty('strip-multiview', 'Multiview', false),
        ],
      ),
      panel(
        'strip-movie-clip',
        'Movie Clip',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'strip-movie-clip-id',
            'Clip',
            'Tracking Clip',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Tracking Clip',
                label: 'Tracking Clip',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          booleanProperty('strip-stabilize', '2D Stabilized Clip', false),
          booleanProperty('strip-undistort', 'Undistorted Clip', false),
        ],
      ),
      panel(
        'strip-scene',
        'Scene',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'strip-scene-id',
            'Scene',
            'Scene',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
              BlenderMenuItem<String>(value: 'Scene.001', label: 'Scene.001'),
            ],
          ),
          enumProperty(
            'strip-scene-input',
            'Input',
            'Camera',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
              BlenderMenuItem<String>(value: 'Sequencer', label: 'Sequencer'),
            ],
          ),
          booleanProperty('strip-scene-annotations', 'Annotations', false),
        ],
      ),
      panel(
        'strip-sound',
        'Sound',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('strip-volume', 'Volume', 1, min: 0, max: 2),
          numberProperty('strip-pan', 'Pan', 0, min: -1, max: 1),
          booleanProperty('strip-pitch-correction', 'Pitch Correction', false),
          booleanProperty('strip-waveform', 'Waveform', true),
        ],
      ),
      panel(
        'strip-mask',
        'Mask',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'strip-mask-id',
            'Mask',
            'Roto Mask',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Roto Mask', label: 'Roto Mask'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          booleanProperty('strip-mask-use', 'Use Mask', true),
        ],
      ),
      panel(
        'strip-time',
        'Time',
        expanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'strip-channel',
            'Channel',
            1,
            min: 1,
            max: 128,
            decimalDigits: 0,
          ),
          numberProperty(
            'strip-left-handle',
            'Left Handle',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          numberProperty(
            'strip-right-handle',
            'Right Handle',
            48,
            min: 1,
            decimalDigits: 0,
          ),
          numberProperty(
            'strip-content-start',
            'Content Start',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          numberProperty(
            'strip-content-duration',
            'Content Duration',
            48,
            min: 1,
            decimalDigits: 0,
          ),
          numberProperty(
            'strip-playhead-offset',
            'Playhead Offset',
            0,
            decimalDigits: 0,
          ),
          booleanProperty('strip-lock', 'Lock', false),
          booleanProperty('strip-show-retiming-keys', 'Retiming Keys', true),
        ],
      ),
      panel(
        'strip-adjust-sound',
        'Sound Adjustment',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('strip-adjust-volume', 'Volume', 1, min: 0, max: 2),
          numberProperty('strip-adjust-pan', 'Pan', 0, min: -1, max: 1),
        ],
      ),
      panel(
        'strip-compositing',
        'Compositing',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'strip-compositing-blend',
            'Blend',
            'Replace',
            blendModes,
          ),
          numberProperty(
            'strip-compositing-opacity',
            'Opacity',
            1,
            min: 0,
            max: 1,
          ),
        ],
      ),
      panel(
        'strip-transform',
        'Transform',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'strip-transform-filter',
            'Filter',
            'Bilinear',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Nearest', label: 'Nearest'),
              BlenderMenuItem<String>(value: 'Bilinear', label: 'Bilinear'),
            ],
          ),
          numberProperty('strip-transform-position-x', 'Position X', 0),
          numberProperty('strip-transform-position-y', 'Position Y', 0),
          numberProperty('strip-transform-scale-x', 'Scale X', 1, min: 0),
          numberProperty('strip-transform-scale-y', 'Scale Y', 1, min: 0),
          numberProperty(
            'strip-transform-rotation',
            'Rotation',
            0,
            min: -360,
            max: 360,
          ),
          booleanProperty('strip-flip-x', 'Flip X', false),
          booleanProperty('strip-flip-y', 'Flip Y', false),
        ],
      ),
      panel(
        'strip-video',
        'Video',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('strip-strobe', 'Strobe', 1, min: 1, decimalDigits: 0),
          booleanProperty('strip-reverse-frames', 'Reverse Frames', false),
        ],
      ),
      panel(
        'strip-color',
        'Color',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('strip-saturation', 'Saturation', 1, min: 0, max: 2),
          numberProperty('strip-multiply', 'Multiply', 1, min: 0, max: 2),
          booleanProperty('strip-multiply-alpha', 'Multiply Alpha', false),
          booleanProperty('strip-use-float', 'Convert to Float', false),
        ],
      ),
      panel(
        'strip-custom-properties',
        'Custom Properties',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('strip-custom-value', 'example_value', 1),
        ],
      ),
      const BlenderPropertyGroup(
        id: 'strip-modifiers',
        title: 'Modifiers',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderButton(label: 'Add Modifier', onPressed: _noop),
            const SizedBox(height: 6),
            BlenderPanel(
              title: 'Color Balance',
              initiallyExpanded: true,
              child: const BlenderPropertyRow(
                label: 'Lift',
                editor: BlenderNumberField(value: 1, onChanged: _noopDouble),
              ),
            ),
            const SizedBox(height: 4),
            BlenderPanel(
              title: 'Transform',
              initiallyExpanded: false,
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPropertiesEditor(title: title, groups: _groups());
  }
}

void _noop() {}

void _noopDouble(double _) {}

class BlenderSequencerEditor extends StatelessWidget {
  const BlenderSequencerEditor({
    super.key,
    required this.strips,
    required this.start,
    required this.end,
    this.currentFrame,
    this.onCurrentFrameChanged,
    this.selectedId,
    this.footer,
    this.sidebar,
    this.sidebarWidth = 240,
    this.title = 'Video Sequencer',
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final ValueChanged<double>? onCurrentFrameChanged;
  final String? selectedId;
  final Widget? footer;
  final Widget? sidebar;
  final double sidebarWidth;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final canvas = _buildCanvas(theme);
    final content = sidebar == null
        ? canvas
        : Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: canvas),
              SizedBox(width: sidebarWidth, child: sidebar),
            ],
          );
    if (footer == null) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: content),
        footer!,
      ],
    );
  }

  Widget _buildCanvas(BlenderThemeData theme) {
    final maxChannel = strips.fold<int>(
      0,
      (value, strip) => math.max(value, strip.channel),
    );
    final height = math.max(96, (maxChannel + 1) * 28 + 30).toDouble();
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = math.max(1, constraints.maxWidth);
          double frameAt(Offset position) {
            return start + (end - start) * (position.dx / width).clamp(0, 1);
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: onCurrentFrameChanged == null
                ? null
                : (details) =>
                      onCurrentFrameChanged!(frameAt(details.localPosition)),
            child: SizedBox(
              height: height,
              child: CustomPaint(
                painter: _BlenderSequencerPainter(
                  strips: strips,
                  start: start,
                  end: end,
                  currentFrame: currentFrame,
                  selectedId: selectedId,
                  colors: theme.colors,
                  textTheme: theme.textTheme,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Source-shaped Sequencer and NLA sidebar panels from `space_sequencer.py`
/// and `space_nla.py`.
///
/// This is a visual hierarchy only. Media caching, proxy generation, strip
/// evaluation, and animation data remain owned by the embedding application.
class BlenderSequencerSidebar extends StatelessWidget {
  const BlenderSequencerSidebar({super.key, this.nlaEditor = false});

  final bool nlaEditor;

  Widget _body(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );

  Widget _panel(String title, List<Widget> children, {bool expanded = false}) {
    return BlenderPanel(
      title: title,
      collapsible: true,
      initiallyExpanded: expanded,
      child: _body(children),
    );
  }

  Widget _check(String label, {bool value = true}) => BlenderPropertyRow(
    label: label,
    editor: BlenderCheckbox(value: value, onChanged: (_) {}),
  );

  Widget _number(String label, double value) => BlenderPropertyRow(
    label: label,
    editor: BlenderNumberField(
      value: value,
      decimalDigits: 2,
      onChanged: (_) {},
    ),
  );

  Widget _choice(String label, String value, List<String> values) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderDropdown<String>(
        value: value,
        items: <BlenderMenuItem<String>>[
          for (final item in values)
            BlenderMenuItem<String>(value: item, label: item),
        ],
        onChanged: (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final panels = nlaEditor
        ? <Widget>[
            _panel('Strip', <Widget>[
              _panel('Action', <Widget>[
                _choice('Action', 'Walk Cycle', <String>[
                  'Walk Cycle',
                  'Idle',
                  'None',
                ]),
                _number('Frame Start', 1),
                _number('Frame End', 120),
                _check('Use Frame Range'),
                _check('Cyclic'),
              ], expanded: true),
              _panel('Slot', <Widget>[
                _choice('Name', 'Walk Cycle', <String>['Walk Cycle', 'None']),
                _choice('Type', 'Object', <String>['Object', 'World', 'Scene']),
              ]),
            ], expanded: true),
          ]
        : <Widget>[
            _panel('Active Tool', <Widget>[
              _choice('Tool', 'Select', <String>['Select', 'Move', 'Trim']),
              _check('Transform Gizmo'),
            ], expanded: true),
            _panel('Cache Settings', <Widget>[
              _check('Prefetch'),
              _check('Raw'),
              _check('Final'),
              _panel('Display', <Widget>[
                _check('Raw', value: false),
                _check('Final', value: true),
                _number('Current Cache Size', 128),
              ]),
            ], expanded: true),
            _panel('Proxy Settings', <Widget>[
              _choice('Storage', 'Project', <String>['Project', 'Per Strip']),
              _choice('Directory', '/project/proxy', <String>[
                '/project/proxy',
                '/tmp/proxy',
              ]),
              const BlenderButton(label: 'Enable Proxies', onPressed: _noop),
              const SizedBox(height: 4),
              const BlenderButton(label: 'Rebuild Proxy', onPressed: _noop),
              _panel('Strip Proxy', <Widget>[
                _check('Use Proxy', value: false),
                _choice('Resolutions', '50%', <String>[
                  '25%',
                  '50%',
                  '75%',
                  '100%',
                ]),
                _number('Quality', 90),
              ]),
            ]),
            _panel('View', <Widget>[
              _panel('Scene Strip Display', <Widget>[
                _choice('Shading', 'Material Preview', <String>[
                  'Solid',
                  'Wireframe',
                  'Material Preview',
                ]),
              ]),
              _panel('View Settings', <Widget>[
                _choice('Proxy Render Size', 'Scene', <String>[
                  'None',
                  'Scene',
                  '25%',
                  '50%',
                ]),
                _check('Use Proxies', value: false),
                _number('Channel', 1),
                _check('Missing Media', value: false),
              ]),
              _panel('2D Cursor', <Widget>[_number('X', 0), _number('Y', 0)]),
              _panel('Frame Overlay', <Widget>[
                _check('Show Overlay Frame', value: false),
                _number('Frame Offset', 0),
                _check('Lock Overlay', value: false),
              ]),
              _panel('Safe Areas', <Widget>[
                _check('Show Safe Areas', value: false),
                _number('Title', .8),
                _number('Action', .9),
                _panel('Center-Cut Safe Areas', <Widget>[
                  _check('Show Center-Cut', value: false),
                  _number('Title Center', .8),
                  _number('Action Center', .9),
                ]),
              ]),
              _panel('Composition Guides', <Widget>[
                _check('Thirds', value: false),
                _check('Center', value: false),
                _check('Diagonal', value: false),
              ]),
              _panel('Annotation', <Widget>[
                _check('Show Annotation', value: false),
                _panel('Onion Skin', <Widget>[
                  _check('Use Onion Skin', value: false),
                  _number('Opacity', .5),
                ]),
              ]),
            ], expanded: true),
            _panel('Strip', <Widget>[
              _panel('Custom Properties', <Widget>[
                _number('example_value', 1),
              ], expanded: true),
            ]),
          ];
    return ListView(padding: const EdgeInsets.all(6), children: panels);
  }
}

class _BlenderSequencerPainter extends CustomPainter {
  _BlenderSequencerPainter({
    required this.strips,
    required this.start,
    required this.end,
    required this.currentFrame,
    required this.selectedId,
    required this.colors,
    required this.textTheme,
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final String? selectedId;
  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;

  @override
  void paint(Canvas canvas, Size size) {
    final range = math.max(.0001, end - start).toDouble();
    const header = 28.0;
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.canvas);
    final grid = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    for (var frame = start.ceilToDouble(); frame <= end; frame += 10) {
      final x = (frame - start) / range * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      final text = TextPainter(
        text: TextSpan(
          text: frame.toStringAsFixed(0),
          style: textTheme.caption.copyWith(color: colors.foregroundMuted),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(x + 2, 5));
    }
    canvas.drawLine(const Offset(0, header), Offset(size.width, header), grid);
    for (final strip in strips) {
      final y = header + strip.channel * 28.0 + 3;
      final left = ((strip.start - start) / range * size.width)
          .clamp(0, size.width)
          .toDouble();
      final right = ((strip.end - start) / range * size.width)
          .clamp(0, size.width)
          .toDouble();
      final rect = Rect.fromLTRB(
        left,
        y,
        math.max(left + 4, right).toDouble(),
        y + 21,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(3)),
        Paint()
          ..color = strip.muted
              ? colors.foregroundDisabled
              : strip.color ?? colors.accent,
      );
      final text = TextPainter(
        text: TextSpan(
          text: strip.label,
          style: textTheme.caption.copyWith(color: colors.foreground),
        ),
        textDirection: TextDirection.ltr,
        ellipsis: '…',
      )..layout(maxWidth: math.max(0, rect.width - 8));
      text.paint(canvas, Offset(rect.left + 4, rect.top + 4));
      if (strip.id == selectedId) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(3)),
          Paint()
            ..color = colors.focus
            ..style = PaintingStyle.stroke,
        );
      }
    }
    if (currentFrame != null) {
      final x = (currentFrame! - start) / range * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = colors.focus
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderSequencerPainter oldDelegate) {
    return strips != oldDelegate.strips ||
        start != oldDelegate.start ||
        end != oldDelegate.end ||
        currentFrame != oldDelegate.currentFrame ||
        selectedId != oldDelegate.selectedId ||
        colors != oldDelegate.colors;
  }
}

class BlenderNLAEditor extends StatelessWidget {
  const BlenderNLAEditor({
    super.key,
    required this.strips,
    required this.start,
    required this.end,
    this.currentFrame,
    this.onCurrentFrameChanged,
    this.selectedId,
    this.footer,
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final ValueChanged<double>? onCurrentFrameChanged;
  final String? selectedId;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return BlenderSequencerEditor(
      strips: strips,
      start: start,
      end: end,
      currentFrame: currentFrame,
      onCurrentFrameChanged: onCurrentFrameChanged,
      selectedId: selectedId,
      title: 'NLA Editor',
      sidebar: const BlenderSequencerSidebar(nlaEditor: true),
      footer: footer,
    );
  }
}

class BlenderVideoSequencerEditor extends StatelessWidget {
  const BlenderVideoSequencerEditor({
    super.key,
    required this.strips,
    required this.start,
    required this.end,
    this.currentFrame,
    this.onCurrentFrameChanged,
    this.selectedId,
    this.title = 'Video Sequencer',
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final ValueChanged<double>? onCurrentFrameChanged;
  final String? selectedId;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlenderSequencerEditor(
      strips: strips,
      start: start,
      end: end,
      currentFrame: currentFrame,
      onCurrentFrameChanged: onCurrentFrameChanged,
      selectedId: selectedId,
      title: title,
      sidebar: const BlenderSequencerSidebar(),
    );
  }
}

class BlenderUVPoint {
  const BlenderUVPoint({required this.id, required this.position, this.color});

  final String id;
  final Offset position;
  final Color? color;
}

class BlenderUVEdge {
  const BlenderUVEdge({required this.from, required this.to});

  final int from;
  final int to;
}

/// A 2D UV editor surface; it deliberately contains no 3D rendering.
class BlenderUVEditor extends StatelessWidget {
  const BlenderUVEditor({
    super.key,
    required this.points,
    this.edges = const <BlenderUVEdge>[],
    this.selectedId,
    this.onSelected,
    this.sidebar,
    this.sidebarWidth = 240,
    this.title = 'UV Editor',
  });

  final List<BlenderUVPoint> points;
  final List<BlenderUVEdge> edges;
  final String? selectedId;
  final ValueChanged<BlenderUVPoint>? onSelected;
  final Widget? sidebar;
  final double sidebarWidth;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: sidebar == null
          ? _buildCanvas(theme)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(child: _buildCanvas(theme)),
                SizedBox(
                  width: sidebarWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.colors.surface,
                      border: Border(
                        left: BorderSide(color: theme.colors.editorBorder),
                      ),
                    ),
                    child: sidebar,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCanvas(BlenderThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        Offset toLocal(Offset point) =>
            Offset(point.dx * size.width, (1 - point.dy) * size.height);
        return GestureDetector(
          onTapDown: onSelected == null
              ? null
              : (details) {
                  if (points.isEmpty) return;
                  var nearest = points.first;
                  var distance = double.infinity;
                  for (final point in points) {
                    final next =
                        (toLocal(point.position) - details.localPosition)
                            .distance;
                    if (next < distance) {
                      distance = next;
                      nearest = point;
                    }
                  }
                  onSelected!(nearest);
                },
          child: CustomPaint(
            painter: _BlenderUVPainter(
              points: points,
              edges: edges,
              selectedId: selectedId,
              colors: theme.colors,
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

class _BlenderUVPainter extends CustomPainter {
  _BlenderUVPainter({
    required this.points,
    required this.edges,
    required this.selectedId,
    required this.colors,
  });

  final List<BlenderUVPoint> points;
  final List<BlenderUVEdge> edges;
  final String? selectedId;
  final BlenderColorScheme colors;

  Offset _local(Offset point, Size size) =>
      Offset(point.dx * size.width, (1 - point.dy) * size.height);

  @override
  void paint(Canvas canvas, Size size) {
    const tile = 16.0;
    final light = Paint()..color = colors.surface;
    final dark = Paint()..color = colors.panelSubSurface;
    for (var y = 0.0; y < size.height; y += tile) {
      for (var x = 0.0; x < size.width; x += tile) {
        canvas.drawRect(
          Rect.fromLTWH(x, y, tile, tile),
          ((x / tile).floor() + (y / tile).floor()).isEven ? light : dark,
        );
      }
    }
    final grid = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    for (var i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      final y = size.height * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final edgePaint = Paint()
      ..color = colors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final edge in edges) {
      if (edge.from < 0 ||
          edge.to < 0 ||
          edge.from >= points.length ||
          edge.to >= points.length) {
        continue;
      }
      canvas.drawLine(
        _local(points[edge.from].position, size),
        _local(points[edge.to].position, size),
        edgePaint,
      );
    }
    for (final point in points) {
      canvas.drawCircle(
        _local(point.position, size),
        point.id == selectedId ? 5 : 3,
        Paint()..color = point.color ?? colors.foreground,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderUVPainter oldDelegate) {
    return points != oldDelegate.points ||
        edges != oldDelegate.edges ||
        selectedId != oldDelegate.selectedId ||
        colors != oldDelegate.colors;
  }
}

/// Source-shaped Image/UV Editor sidebar panels from `space_image.py`.
///
/// Image loading, paint tools, UV editing, scopes, and mask operators remain
/// caller-owned; this widget supplies the visual panel hierarchy and density.
class BlenderImageEditorSidebar extends StatelessWidget {
  const BlenderImageEditorSidebar({super.key, this.uvEditor = false});

  final bool uvEditor;

  Widget _body(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );

  Widget _panel(String title, List<Widget> children, {bool expanded = false}) {
    return BlenderPanel(
      title: title,
      collapsible: true,
      initiallyExpanded: expanded,
      child: _body(children),
    );
  }

  Widget _check(String label, {bool value = true}) => BlenderPropertyRow(
    label: label,
    editor: BlenderCheckbox(value: value, onChanged: (_) {}),
  );

  Widget _number(String label, double value) => BlenderPropertyRow(
    label: label,
    editor: BlenderNumberField(
      value: value,
      decimalDigits: 2,
      onChanged: (_) {},
    ),
  );

  Widget _choice(String label, String value, List<String> values) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderDropdown<String>(
        value: value,
        items: <BlenderMenuItem<String>>[
          for (final item in values)
            BlenderMenuItem<String>(value: item, label: item),
        ],
        onChanged: (_) {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final toolPanels = <Widget>[
      _panel('Brush Asset', <Widget>[
        _choice('Asset', 'Basic Brush', <String>[
          'Basic Brush',
          'Draw',
          'Erase',
        ]),
      ], expanded: true),
      _panel('Brush Settings', <Widget>[
        _number('Radius', 50),
        _number('Strength', .5),
        _panel('Advanced', <Widget>[
          _check('Pressure Size'),
          _check('Pressure Strength'),
          _number('Jitter', 0),
        ]),
        _panel('Color Picker', <Widget>[
          _choice('Mode', 'Mix', <String>['Mix', 'Add', 'Subtract']),
          _check('Use Unified Color'),
        ]),
        _panel('Color Palette', <Widget>[
          _check('Show Palette'),
          _number('Color Saturation', 1),
        ]),
        _panel('Clone from Image/UV Map', <Widget>[
          _choice('Clone Mode', 'Material', <String>[
            'Material',
            'Image/UV Map',
          ]),
          _number('Alpha', 1),
        ]),
        _panel('Cursor', <Widget>[
          _check('Show Cursor'),
          _check('Show Outline'),
        ]),
        _panel('Texture', <Widget>[
          _choice('Texture', 'None', <String>['None', 'Noise', 'Image']),
          _number('Angle', 0),
          _number('Scale', 1),
        ]),
        _panel('Texture Mask', <Widget>[
          _choice('Mask', 'None', <String>['None', 'Noise', 'Voronoi']),
          _number('Mask Angle', 0),
        ]),
        _panel('Stroke', <Widget>[
          _choice('Method', 'Space', <String>['Space', 'Airbrush', 'Dots']),
          _number('Spacing', 10),
          _panel('Stabilize Stroke', <Widget>[
            _check('Smooth Stroke'),
            _number('Radius', .5),
          ]),
        ]),
        _panel('Falloff', <Widget>[
          _choice('Shape', 'Smooth', <String>[
            'Smooth',
            'Sphere',
            'Root',
            'Sharp',
          ]),
          _number('Radius', .5),
        ]),
      ]),
      _panel('Tiling', <Widget>[
        _check('X'),
        _check('Y', value: false),
        _check('Z', value: false),
      ]),
    ];

    final imagePanels = <Widget>[
      _panel('Image', <Widget>[
        _choice('Source', 'Generated', <String>[
          'Generated',
          'Viewer Node',
          'Sequence',
        ]),
        _number('Resolution X', 2048),
        _number('Resolution Y', 2048),
        _check('Half Float'),
      ], expanded: true),
      _panel('Render Slots', <Widget>[
        _choice('Slot', 'Slot 1', <String>['Slot 1', 'Slot 2', 'Slot 3']),
      ]),
      _panel('UDIM Tiles', <Widget>[
        _choice('Tile', '1001', <String>['1001', '1002', '1011']),
        _number('Tile Count', 1),
      ]),
    ];

    final viewPanels = <Widget>[
      _panel('Display', <Widget>[
        _choice('Aspect Ratio', '1:1', <String>['1:1', '2:1', 'Custom']),
        _check('Repeat Image'),
        if (uvEditor) _check('Pixel Coordinates'),
      ], expanded: true),
      _panel('2D Cursor', <Widget>[
        _number('Location X', .5),
        _number('Location Y', .5),
      ]),
      _panel('Histogram', <Widget>[
        _check('Full Resolution'),
        _choice('Accuracy', '1.0', <String>['1.0', '0.5', '0.25']),
      ]),
      _panel('Waveform', <Widget>[
        _check('Full Resolution'),
        _choice('Channels', 'Luma', <String>[
          'Luma',
          'RGB',
          'Red',
          'Green',
          'Blue',
        ]),
      ]),
      _panel('Vectorscope', <Widget>[
        _check('Full Resolution'),
        _choice('Channels', 'Saturation', <String>['Saturation', 'Color']),
      ]),
      _panel('Sample Line', <Widget>[
        _check('Show Sample Line'),
        _number('Position', .5),
      ]),
      _panel('Samples', <Widget>[
        _number('Sample Count', 8),
        _check('Full Resolution'),
      ]),
    ];

    final maskPanels = <Widget>[
      _panel('Mask', <Widget>[
        _check('Show Mask'),
        _choice('Mode', 'Combined', <String>['Combined', 'Alpha', 'Outline']),
      ]),
      _panel('Mask Layers', <Widget>[
        _choice('Active Layer', 'Mask Layer', <String>[
          'Mask Layer',
          'Layer 2',
        ]),
      ]),
      _panel('Active Spline', <Widget>[
        _number('Feather', .5),
        _check('Cyclic'),
      ]),
      _panel('Active Point', <Widget>[
        _number('Weight', 1),
        _number('Radius', 1),
      ]),
      _panel('Animation', <Widget>[_check('Animated'), _number('Frame', 1)]),
    ];

    return ListView(
      padding: const EdgeInsets.all(4),
      children: <Widget>[
        ...toolPanels,
        ...imagePanels,
        ...viewPanels,
        ...maskPanels,
      ],
    );
  }
}

class BlenderClipMarker {
  const BlenderClipMarker({
    required this.id,
    required this.position,
    this.color,
  });

  final String id;
  final Offset position;
  final Color? color;
}

/// Source-shaped mask controls used by the Movie Clip Editor sidebar.
///
/// Blender's `properties_mask_common.py` supplies these panels to both the
/// image and clip editors. The widget deliberately owns only the visual
/// descriptors; mask evaluation, spline editing, tracking, and operators stay
/// with the host application.
class BlenderMaskProperties extends StatelessWidget {
  const BlenderMaskProperties({super.key, this.title = 'Mask'});

  final String title;

  List<BlenderPropertyGroup> _groups() {
    const blendModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Merge Add', label: 'Merge Add'),
      BlenderMenuItem<String>(value: 'Merge Subtract', label: 'Merge Subtract'),
      BlenderMenuItem<String>(value: 'Replace', label: 'Replace'),
    ];
    const fillSolvers = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Sweep Line', label: 'Sweep Line'),
      BlenderMenuItem<String>(value: 'Fast', label: 'Fast'),
    ];

    BlenderPropertyDescriptor<bool> booleanProperty(
      String id,
      String label,
      bool value,
    ) {
      return BlenderPropertyFactory.boolean(id, label, value);
    }

    BlenderPropertyDescriptor<double> numberProperty(
      String id,
      String label,
      double value, {
      double? min,
      double? max,
      int decimalDigits = 2,
    }) {
      return BlenderPropertyFactory.number(
        id,
        label,
        value,
        min: min,
        max: max,
        decimalDigits: decimalDigits,
      );
    }

    BlenderPropertyDescriptor<String> enumProperty(
      String id,
      String label,
      String value,
      List<BlenderMenuItem<String>> items,
    ) {
      return BlenderPropertyFactory.menu(id, label, value, items);
    }

    Widget layerList() {
      return SizedBox(
        height: 92,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Expanded(
              child: BlenderBox(
                padding: EdgeInsets.zero,
                child: BlenderListView<String>(
                  items: const <BlenderListItem<String>>[
                    BlenderListItem<String>(
                      id: 'mask-layer-main',
                      label: 'Mask Layer',
                      detail: 'Visible',
                      icon: BlenderGlyph.mesh,
                    ),
                    BlenderListItem<String>(
                      id: 'mask-layer-secondary',
                      label: 'Roto Details',
                      detail: 'Overlay',
                      icon: BlenderGlyph.mesh,
                    ),
                  ],
                  selectedId: 'mask-layer-main',
                ),
              ),
            ),
            const SizedBox(width: 4),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BlenderIconButton(
                  glyph: BlenderGlyph.plus,
                  onPressed: () {},
                  tooltip: 'Add mask layer',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  onPressed: () {},
                  tooltip: 'Remove mask layer',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.stepBack,
                  onPressed: () {},
                  tooltip: 'Move mask layer up',
                  size: 22,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.stepForward,
                  onPressed: () {},
                  tooltip: 'Move mask layer down',
                  size: 22,
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget toolButtons(List<String> labels) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final label in labels)
            BlenderButton(label: label, onPressed: () {}),
        ],
      );
    }

    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'mask-settings',
        title: 'Mask Settings',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty(
            'mask-frame-start',
            'Frame Start',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          numberProperty(
            'mask-frame-end',
            'Frame End',
            250,
            min: 1,
            decimalDigits: 0,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-layers',
        title: 'Mask Layers',
        content: layerList(),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          numberProperty('mask-layer-alpha', 'Alpha', .85, min: 0, max: 1),
          booleanProperty('mask-layer-invert', 'Invert', false),
          enumProperty('mask-layer-blend', 'Blend', 'Merge Add', blendModes),
          enumProperty(
            'mask-layer-falloff',
            'Falloff',
            'Smooth',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Smooth', label: 'Smooth'),
              BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
            ],
          ),
          enumProperty(
            'mask-layer-fill-solver',
            'Fill Solver',
            'Sweep Line',
            fillSolvers,
          ),
          booleanProperty('mask-layer-overlap', 'Overlap', true),
          booleanProperty('mask-layer-holes', 'Holes', true),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-active-spline',
        title: 'Active Spline',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'mask-spline-offset-mode',
            'Offset',
            'Absolute',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Absolute', label: 'Absolute'),
              BlenderMenuItem<String>(value: 'Relative', label: 'Relative'),
            ],
          ),
          enumProperty(
            'mask-spline-interpolation',
            'Interpolation',
            'Linear',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Linear', label: 'Linear'),
              BlenderMenuItem<String>(value: 'Cardinal', label: 'Cardinal'),
            ],
          ),
          booleanProperty('mask-spline-cyclic', 'Cyclic', true),
          booleanProperty('mask-spline-fill', 'Fill', true),
          booleanProperty(
            'mask-spline-self-intersection',
            'Self Intersection Check',
            true,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-active-point',
        title: 'Active Point',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'mask-point-parent',
            'Parent',
            'Movie Clip',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Movie Clip', label: 'Movie Clip'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          enumProperty('mask-point-parent-type', 'Type', 'Point Track', const <
            BlenderMenuItem<String>
          >[
            BlenderMenuItem<String>(value: 'Point Track', label: 'Point Track'),
            BlenderMenuItem<String>(value: 'Plane Track', label: 'Plane Track'),
          ]),
          enumProperty(
            'mask-point-object',
            'Object',
            'Camera',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
              BlenderMenuItem<String>(value: 'Object', label: 'Object'),
            ],
          ),
          enumProperty(
            'mask-point-track',
            'Track',
            'Track',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Track', label: 'Track'),
              BlenderMenuItem<String>(value: 'Plane', label: 'Plane'),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-animation',
        title: 'Animation',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          enumProperty(
            'mask-action',
            'Action',
            'MaskAction',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'MaskAction', label: 'MaskAction'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-display',
        title: 'Mask Display',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          booleanProperty('mask-show-spline', 'Spline', true),
          enumProperty(
            'mask-display-type',
            'Display Type',
            'Outline',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Outline', label: 'Outline'),
              BlenderMenuItem<String>(value: 'Overlay', label: 'Overlay'),
            ],
          ),
          booleanProperty('mask-show-overlay', 'Overlay', true),
          enumProperty(
            'mask-overlay-mode',
            'Overlay Mode',
            'Combined',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Combined', label: 'Combined'),
              BlenderMenuItem<String>(value: 'Replace', label: 'Replace'),
            ],
          ),
          numberProperty(
            'mask-blend-factor',
            'Blending Factor',
            .5,
            min: 0,
            max: 1,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'mask-transforms',
        title: 'Transforms',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: toolButtons(<String>[
          'Translate',
          'Rotate',
          'Scale',
          'Scale Feather',
        ]),
      ),
      BlenderPropertyGroup(
        id: 'mask-tools',
        title: 'Mask Tools',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: toolButtons(<String>[
          'Delete',
          'Cyclic Toggle',
          'Switch Direction',
          'Set Vector Handle',
          'Clear Feather Weight',
          'Parent',
          'Clear Parent',
          'Insert Key',
          'Clear Key',
          'Reset Feather Animation',
          'Re-Key Shape Points',
        ]),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPropertiesEditor(title: title, groups: _groups());
  }
}

/// Source-shaped Clip Editor sidebar panels from `space_clip.py`.
///
/// Tracking, solving, stabilization, footage, and mask data remain
/// caller-owned; this widget mirrors the visible panel families and density.
class BlenderClipEditorSidebar extends StatelessWidget {
  const BlenderClipEditorSidebar({super.key});

  Widget _body(List<Widget> children) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );

  Widget _panel(String title, List<Widget> children, {bool expanded = false}) {
    return BlenderPanel(
      title: title,
      collapsible: true,
      initiallyExpanded: expanded,
      child: _body(children),
    );
  }

  Widget _check(String label, {bool value = true}) => BlenderPropertyRow(
    label: label,
    editor: BlenderCheckbox(value: value, onChanged: (_) {}),
  );

  Widget _number(String label, double value) => BlenderPropertyRow(
    label: label,
    editor: BlenderNumberField(
      value: value,
      decimalDigits: 2,
      onChanged: (_) {},
    ),
  );

  Widget _choice(String label, String value, List<String> values) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderDropdown<String>(
        value: value,
        items: <BlenderMenuItem<String>>[
          for (final item in values)
            BlenderMenuItem<String>(value: item, label: item),
        ],
        onChanged: _noopString,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(6),
      children: <Widget>[
        _panel('Track', <Widget>[
          _choice('Active Track', 'Track', <String>[
            'Track',
            'No active track',
          ]),
          _check('Lock Track', value: false),
          _check('Red Channel'),
          _check('Green Channel'),
          _check('Blue Channel'),
          _check('Grayscale Preview', value: false),
          _check('Alpha Preview', value: false),
          _number('Weight', 1),
          _number('Stabilization Weight', 1),
          _panel('Objects', <Widget>[
            _choice('Object', 'Camera', <String>['Camera', 'Object']),
            const BlenderButton(label: 'Add Object', onPressed: _noop),
          ]),
          _panel('Plane Track', <Widget>[
            _choice('Plane', 'Plane Track', <String>['Plane Track', 'None']),
            _check('Auto Keying', value: false),
            _number('Opacity', .8),
          ]),
          _panel('Tracking Settings', <Widget>[
            _choice('Motion Model', 'Perspective', <String>[
              'Translation',
              'Affine',
              'Perspective',
            ]),
            _choice('Match', 'Previous Frame', <String>[
              'Previous Frame',
              'Keyframe',
            ]),
            _check('Brute', value: false),
            _check('Normalization'),
            _panel('Tracking Settings Extras', <Widget>[
              _number('Correlation Min', .75),
              _number('Margin', 5),
              _number('Frames Limit', 0),
              _number('Speed', 1),
            ]),
          ]),
          _panel('Camera', <Widget>[
            _number('Sensor Width', 36),
            _number('Pixel Aspect', 1),
            _panel('Lens', <Widget>[
              _number('Focal Length', 50),
              _choice('Units', 'Millimeters', <String>[
                'Millimeters',
                'Pixels',
              ]),
              _number('Optical Center', 0),
              _choice('Lens Distortion', 'Polynomial', <String>[
                'Polynomial',
                'Division',
              ]),
            ]),
          ]),
          _panel('Marker', <Widget>[
            _number('Pattern Size', 11),
            _number('Search Size', 21),
          ]),
        ], expanded: true),
        _panel('Solve', <Widget>[
          _number('Frames', 8),
          _number('Error', .5),
          _check('Refine Focal Length'),
          _check('Refine Optical Center', value: false),
          _panel('Cleanup', <Widget>[
            _number('Frames', 10),
            _number('Error Threshold', 1),
          ]),
          _panel('Geometry', <Widget>[
            _choice('Geometry', 'Tracks', <String>['Tracks', 'Plane']),
            _check('Use Keyframe', value: false),
          ]),
        ]),
        _panel('2D Stabilization', <Widget>[
          _check('Use 2D Stabilization'),
          _number('Anchor Frame', 1),
          _check('Stabilize Rotation', value: false),
          _check('Stabilize Scale', value: false),
          _check('Auto Scale'),
          _number('Influence Location', 1),
          _number('Influence Rotation', 1),
          _number('Influence Scale', 1),
        ]),
        _panel('View', <Widget>[
          _number('Cursor X', 0),
          _number('Cursor Y', 0),
          _check('Show Annotation', value: false),
        ]),
        _panel('Footage', <Widget>[
          _choice('Clip', 'Footage.mov', <String>[
            'Footage.mov',
            'No active movie clip',
          ]),
          _choice('Proxy Size', 'Scene', <String>['None', 'Scene', '50%']),
          _check('Use Proxy', value: false),
          _panel('Proxy', <Widget>[
            _check('Build Original', value: false),
            _check('Build Undistorted', value: false),
            _number('Quality', 90),
            const BlenderButton(label: 'Build Proxy', onPressed: _noop),
          ]),
          _panel('Animation', <Widget>[
            _choice('Action', 'ClipAction', <String>['ClipAction', 'None']),
          ]),
        ]),
        _panel('Mask', <Widget>[
          _check('Use Mask', value: false),
          _choice('Active Mask', 'Roto Mask', <String>['Roto Mask', 'None']),
          _check('Invert', value: false),
          _number('Feather', 1),
        ]),
      ],
    );
  }
}

class BlenderClipEditor extends StatelessWidget {
  const BlenderClipEditor({
    super.key,
    this.image,
    this.markers = const <BlenderClipMarker>[],
    this.selectedId,
    this.onSelected,
    this.maskSidebar,
    this.sidebar,
    this.sidebarWidth = 280,
    this.title = 'Movie Clip Editor',
  });

  final Widget? image;
  final List<BlenderClipMarker> markers;
  final String? selectedId;
  final ValueChanged<BlenderClipMarker>? onSelected;
  final Widget? maskSidebar;
  final Widget? sidebar;
  final double sidebarWidth;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final editor = BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          image ??
              ColoredBox(
                color: theme.colors.canvas,
                child: Center(
                  child: Text(
                    'No Clip',
                    style: theme.textTheme.body.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ),
              ),
          for (final marker in markers)
            Positioned(
              left: marker.position.dx,
              top: marker.position.dy,
              child: GestureDetector(
                onTap: onSelected == null ? null : () => onSelected!(marker),
                child: Container(
                  width: marker.id == selectedId ? 14 : 10,
                  height: marker.id == selectedId ? 14 : 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: marker.color ?? theme.colors.accent,
                    border: Border.all(color: theme.colors.foreground),
                  ),
                ),
              ),
            ),
          if (maskSidebar case final sidebar?)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              width: sidebarWidth,
              child: sidebar,
            ),
        ],
      ),
    );
    if (sidebar == null) return editor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: editor),
        SizedBox(width: sidebarWidth, child: sidebar),
      ],
    );
  }
}
