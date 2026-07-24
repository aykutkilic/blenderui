import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_markdown_plus_latex/flutter_markdown_plus_latex.dart';
import 'package:markdown/markdown.dart' as md;

import 'workbook_palette.dart';

/// Editable GitHub-flavored Markdown with inline and block LaTeX preview.
final class WorkbookMarkdownCell extends StatefulWidget {
  const WorkbookMarkdownCell({
    required this.source,
    required this.active,
    required this.onActivate,
    required this.onChanged,
    super.key,
  });

  final String source;
  final bool active;
  final VoidCallback onActivate;
  final ValueChanged<String> onChanged;

  @override
  State<WorkbookMarkdownCell> createState() => _WorkbookMarkdownCellState();
}

final class _WorkbookMarkdownCellState extends State<WorkbookMarkdownCell> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.source);
    _focusNode = FocusNode();
    if (widget.active) _requestFocus();
  }

  @override
  void didUpdateWidget(covariant WorkbookMarkdownCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.source != _controller.text) {
      final selection = _controller.selection;
      _controller.value = TextEditingValue(
        text: widget.source,
        selection: TextSelection.collapsed(
          offset: selection.extentOffset.clamp(0, widget.source.length),
        ),
      );
    }
    if (widget.active && !oldWidget.active) _requestFocus();
  }

  void _requestFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return InkWell(
        onTap: widget.onActivate,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: WorkbookMarkdownPreview(source: widget.source),
        ),
      );
    }
    final palette = WorkbookPalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: 150,
          child: ColoredBox(
            color: palette.canvas,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: EditableText(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                textDirection: TextDirection.ltr,
                style: TextStyle(
                  color: palette.foreground,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.35,
                ),
                cursorColor: palette.focus,
                backgroundCursorColor: palette.muted,
                selectionColor: palette.accent.withValues(alpha: 0.38),
                onChanged: widget.onChanged,
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: palette.outline)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: WorkbookMarkdownPreview(source: widget.source),
          ),
        ),
      ],
    );
  }
}

final class WorkbookMarkdownPreview extends StatelessWidget {
  const WorkbookMarkdownPreview({required this.source, super.key});

  final String source;

  @override
  Widget build(BuildContext context) {
    final palette = WorkbookPalette.of(context);
    if (source.trim().isEmpty) {
      return Text(
        'Empty Markdown cell',
        style: TextStyle(color: palette.muted, fontStyle: FontStyle.italic),
      );
    }
    final body = TextStyle(
      color: palette.foreground,
      fontSize: 13,
      height: 1.45,
    );
    return MarkdownBody(
      data: source,
      selectable: false,
      extensionSet: md.ExtensionSet(
        <md.BlockSyntax>[
          LatexBlockSyntax(),
          ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        ],
        <md.InlineSyntax>[
          LatexInlineSyntax(),
          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
        ],
      ),
      builders: <String, MarkdownElementBuilder>{
        'latex': LatexElementBuilder(textStyle: body),
      },
      styleSheet: MarkdownStyleSheet(
        p: body,
        a: body.copyWith(color: palette.focus),
        code: body.copyWith(
          fontFamily: 'monospace',
          backgroundColor: palette.raised,
        ),
        h1: body.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
        h2: body.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
        h3: body.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
        h4: body.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        h5: body.copyWith(fontWeight: FontWeight.w600),
        h6: body.copyWith(fontWeight: FontWeight.w600),
        em: const TextStyle(fontStyle: FontStyle.italic),
        strong: const TextStyle(fontWeight: FontWeight.bold),
        del: const TextStyle(decoration: TextDecoration.lineThrough),
        blockquote: body,
        blockquotePadding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
        blockquoteDecoration: BoxDecoration(
          color: palette.raised,
          border: Border(left: BorderSide(color: palette.focus, width: 3)),
        ),
        codeblockPadding: const EdgeInsets.all(10),
        codeblockDecoration: BoxDecoration(
          color: palette.canvas,
          borderRadius: BorderRadius.circular(3),
        ),
        listBullet: body,
        tableHead: body.copyWith(fontWeight: FontWeight.w600),
        tableBody: body,
        tableBorder: TableBorder.all(color: palette.outline),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(top: BorderSide(color: palette.outline)),
        ),
        blockSpacing: 8,
      ),
    );
  }
}
