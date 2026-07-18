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
