part of '../non3d_editors.dart';

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
    this.history = const <String>[],
    this.prompt = '>>>',
    this.title = 'Console',
  });

  final List<BlenderConsoleLine> lines;
  final ValueChanged<String>? onCommand;
  final List<String> history;
  final String prompt;
  final String? title;

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
    this.selectedIds = const <String>{},
    this.onSelectionChanged,
    this.visibleLevels,
    this.title = 'Info',
  });

  final List<BlenderInfoReport> reports;
  final ValueChanged<BlenderInfoReport>? onDismiss;
  final Set<String> selectedIds;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final Set<BlenderNoticeLevel>? visibleLevels;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final visibleReports = visibleLevels == null
        ? reports
        : reports
              .where((report) => visibleLevels!.contains(report.level))
              .toList(growable: false);
    final body = visibleReports.isEmpty
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
            itemCount: visibleReports.length,
            separatorBuilder: (context, index) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final report = visibleReports[index];
              final selected = selectedIds.contains(report.id);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onSelectionChanged == null
                    ? null
                    : () => onSelectionChanged!(<String>{report.id}),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected ? theme.colors.selection : null,
                  ),
                  child: Row(
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
                  ),
                ),
              );
            },
          );
    if (title == null) return body;
    return BlenderPanel(title: title!, padding: EdgeInsets.zero, child: body);
  }
}

class _BlenderConsoleEditorState extends State<BlenderConsoleEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  int? _historyIndex;

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
    _historyIndex = null;
  }

  KeyEventResult _handleHistoryKey(KeyEvent event) {
    if (event is! KeyDownEvent || widget.history.isEmpty) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey != LogicalKeyboardKey.arrowUp &&
        event.logicalKey != LogicalKeyboardKey.arrowDown) {
      return KeyEventResult.ignored;
    }
    final last = widget.history.length - 1;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _historyIndex = ((_historyIndex ?? widget.history.length) - 1).clamp(
        0,
        last,
      );
    } else if (_historyIndex != null) {
      _historyIndex = (_historyIndex! + 1).clamp(0, widget.history.length);
      if (_historyIndex == widget.history.length) _historyIndex = null;
    }
    final value = _historyIndex == null ? '' : widget.history[_historyIndex!];
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final body = Column(
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
                style: theme.textTheme.body.copyWith(color: theme.colors.info),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Focus(
                  onKeyEvent: (node, event) => _handleHistoryKey(event),
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
              ),
            ],
          ),
        ),
      ],
    );
    if (widget.title == null) return body;
    return BlenderPanel(
      title: widget.title!,
      padding: EdgeInsets.zero,
      child: body,
    );
  }
}
