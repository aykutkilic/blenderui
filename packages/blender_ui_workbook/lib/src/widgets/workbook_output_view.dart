import 'dart:convert';

import 'package:flutter/material.dart';

import '../model/workbook_output.dart';
import '../plot/plot_model.dart';
import 'workbook_plot.dart';
import 'workbook_palette.dart';

final class WorkbookOutputList extends StatelessWidget {
  const WorkbookOutputList({required this.outputs, super.key});

  final List<WorkbookOutput> outputs;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      for (final output in outputs) WorkbookOutputView(output: output),
    ],
  );
}

final class WorkbookOutputView extends StatelessWidget {
  const WorkbookOutputView({required this.output, super.key});

  final WorkbookOutput output;

  @override
  Widget build(BuildContext context) => switch (output) {
    WorkbookClearOutput() => const SizedBox.shrink(),
    WorkbookStreamOutput(:final stream, :final text) => _OutputText(
      text: text,
      color: stream == WorkbookStream.stderr
          ? WorkbookPalette.of(context).error
          : WorkbookPalette.of(context).foreground,
    ),
    WorkbookErrorOutput(:final name, :final message, :final traceback) =>
      _ErrorOutput(name: name, message: message, traceback: traceback),
    WorkbookDisplayOutput() => _DisplayOutput(
      output: output as WorkbookDisplayOutput,
    ),
  };
}

final class _DisplayOutput extends StatelessWidget {
  const _DisplayOutput({required this.output});

  final WorkbookDisplayOutput output;

  @override
  Widget build(BuildContext context) {
    final plot = _plotSpec();
    if (plot != null) return WorkbookPlot(spec: plot);
    final png = output.bytes('image/png');
    if (png != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Align(alignment: Alignment.centerLeft, child: Image.memory(png)),
      );
    }
    final markdown = output.text('text/markdown');
    if (markdown != null) return _OutputText(text: markdown);
    final plain = output.text('text/plain');
    if (plain != null) return _OutputText(text: plain);
    final html = output.text('text/html');
    if (html != null) return _OutputText(text: _withoutHtmlTags(html));
    return _OutputText(
      text: const JsonEncoder.withIndent('  ').convert(output.data),
    );
  }

  WorkbookPlotSpec? _plotSpec() {
    final raw = output.data[WorkbookPlotSpec.mimeType];
    if (raw == null) return null;
    try {
      return WorkbookPlotSpec.fromJson(raw is String ? jsonDecode(raw) : raw);
    } on Object {
      return null;
    }
  }

  static String _withoutHtmlTags(String value) => value
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');
}

final class _ErrorOutput extends StatelessWidget {
  const _ErrorOutput({
    required this.name,
    required this.message,
    required this.traceback,
  });

  final String name;
  final String message;
  final List<String> traceback;

  @override
  Widget build(BuildContext context) {
    final color = WorkbookPalette.of(context).error;
    return ColoredBox(
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: SelectableText(
          <String>[
            '$name: $message',
            if (traceback.isNotEmpty) ...traceback.map(_stripAnsi),
          ].join('\n'),
          style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }

  static String _stripAnsi(String value) =>
      value.replaceAll(RegExp(r'\x1B\[[0-?]*[ -/]*[@-~]'), '');
}

final class _OutputText extends StatelessWidget {
  const _OutputText({required this.text, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    child: SelectableText(
      text,
      style: TextStyle(
        color: color ?? WorkbookPalette.of(context).foreground,
        fontFamily: 'monospace',
        fontSize: 12,
        height: 1.35,
      ),
    ),
  );
}
