import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'advanced_controls.dart';
import 'collections.dart';
import 'controls.dart';
import 'icons.dart';
import 'editors.dart';
import 'layout.dart';
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
    this.title = 'Text Editor',
  });

  final String text;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
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
    return BlenderPanel(
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
  }
}

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
    this.title = 'Spreadsheet',
  });

  final List<BlenderSpreadsheetColumn> columns;
  final List<BlenderSpreadsheetRow> rows;
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

    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
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
      ),
    );
  }
}

class BlenderImageEditor extends StatefulWidget {
  const BlenderImageEditor({
    super.key,
    this.image,
    this.label = 'No Image',
    this.title = 'Image Editor',
  });

  final Widget? image;
  final String label;
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
      child: LayoutBuilder(
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
    this.initiallyExpanded = true,
  });

  final String id;
  final String category;
  final String title;
  final Widget child;
  final bool initiallyExpanded;
}

class BlenderPreferencesEditor extends StatelessWidget {
  const BlenderPreferencesEditor({
    super.key,
    required this.categories,
    required this.sections,
    this.selectedCategory,
    this.onCategoryChanged,
    this.title = 'Preferences',
  });

  final List<String> categories;
  final List<BlenderPreferenceSection> sections;
  final String? selectedCategory;
  final ValueChanged<String>? onCategoryChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    final category =
        selectedCategory ?? (categories.isEmpty ? null : categories.first);
    final visibleSections = category == null
        ? sections
        : sections.where((section) => section.category == category).toList();
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 148,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: BlenderTheme.of(context).colors.surface,
                border: Border(
                  right: BorderSide(
                    color: BlenderTheme.of(context).colors.editorBorder,
                  ),
                ),
              ),
              child: BlenderListView<String>(
                items: [
                  for (final item in categories)
                    BlenderListItem<String>(id: item, label: item, value: item),
                ],
                selectedId: category,
                onSelected: onCategoryChanged == null
                    ? null
                    : (item) => onCategoryChanged!(item.value!),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(6),
              children: [
                for (final section in visibleSections)
                  BlenderPanel(
                    title: section.title,
                    collapsible: true,
                    initiallyExpanded: section.initiallyExpanded,
                    child: section.child,
                  ),
              ],
            ),
          ),
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
    this.title = 'Dope Sheet',
  });

  final BlenderTimelineModel model;
  final ValueChanged<double> onCurrentFrameChanged;
  final String title;

  @override
  Widget build(BuildContext context) {
    return BlenderTimeline(
      model: model,
      onCurrentFrameChanged: onCurrentFrameChanged,
      title: title,
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

class BlenderSequencerEditor extends StatelessWidget {
  const BlenderSequencerEditor({
    super.key,
    required this.strips,
    required this.start,
    required this.end,
    this.currentFrame,
    this.onCurrentFrameChanged,
    this.selectedId,
    this.onSelected,
    this.title = 'Video Sequencer',
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final ValueChanged<double>? onCurrentFrameChanged;
  final String? selectedId;
  final ValueChanged<BlenderSequencerStrip>? onSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
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
    this.onSelected,
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final ValueChanged<double>? onCurrentFrameChanged;
  final String? selectedId;
  final ValueChanged<BlenderSequencerStrip>? onSelected;

  @override
  Widget build(BuildContext context) {
    return BlenderSequencerEditor(
      strips: strips,
      start: start,
      end: end,
      currentFrame: currentFrame,
      onCurrentFrameChanged: onCurrentFrameChanged,
      selectedId: selectedId,
      onSelected: onSelected,
      title: 'NLA Editor',
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
    this.onSelected,
    this.title = 'Video Sequencer',
  });

  final List<BlenderSequencerStrip> strips;
  final double start;
  final double end;
  final double? currentFrame;
  final ValueChanged<double>? onCurrentFrameChanged;
  final String? selectedId;
  final ValueChanged<BlenderSequencerStrip>? onSelected;
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
      onSelected: onSelected,
      title: title,
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
    this.title = 'UV Editor',
  });

  final List<BlenderUVPoint> points;
  final List<BlenderUVEdge> edges;
  final String? selectedId;
  final ValueChanged<BlenderUVPoint>? onSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: LayoutBuilder(
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
      ),
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

class BlenderClipEditor extends StatelessWidget {
  const BlenderClipEditor({
    super.key,
    this.image,
    this.markers = const <BlenderClipMarker>[],
    this.selectedId,
    this.onSelected,
    this.title = 'Movie Clip Editor',
  });

  final Widget? image;
  final List<BlenderClipMarker> markers;
  final String? selectedId;
  final ValueChanged<BlenderClipMarker>? onSelected;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
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
        ],
      ),
    );
  }
}
