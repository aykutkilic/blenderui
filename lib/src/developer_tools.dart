import 'package:flutter/widgets.dart';

import 'theme.dart';

typedef BlenderCodeHighlighter =
    List<InlineSpan> Function(
      String code,
      TextStyle baseStyle,
      BlenderThemeData theme,
    );

/// Selectable fixed-font source display for BlenderUI developer surfaces.
class BlenderCodeBlock extends StatelessWidget {
  const BlenderCodeBlock({
    super.key,
    required this.code,
    this.highlighter,
    this.padding = const EdgeInsets.all(12),
    this.fontSize = 12,
  });

  final String code;
  final BlenderCodeHighlighter? highlighter;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final baseStyle = TextStyle(
      color: theme.colors.foreground,
      fontFamily: 'monospace',
      fontSize: fontSize,
      height: 1.45,
    );
    final spans =
        highlighter?.call(code, baseStyle, theme) ??
        <InlineSpan>[TextSpan(text: code)];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.menuBackground,
        border: Border.all(color: theme.colors.borderSubtle),
        borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: SelectableRegion(
          selectionControls: emptyTextSelectionControls,
          child: RichText(
            text: TextSpan(style: baseStyle, children: spans),
          ),
        ),
      ),
    );
  }
}

/// Lightweight Dart token coloring used by the package component catalog.
List<InlineSpan> blenderDartCodeHighlighter(
  String code,
  TextStyle baseStyle,
  BlenderThemeData theme,
) {
  final tokenPattern = RegExp(
    r'''("(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'|//[^\n]*|\b(?:const|final|var|return|void|true|false|null|class|extends|required)\b|\b[A-Z][A-Za-z0-9_]*\b|[{}()\[\],:.=<>]|\b[A-Za-z_][A-Za-z0-9_]*\b)''',
  );
  final spans = <InlineSpan>[];
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
            'class',
            'extends',
            'required',
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
