part of '../non3d_editors.dart';

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

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(6),
      children: <Widget>[
        BlenderStaticPropertyField.panel('Properties', <Widget>[
          BlenderStaticPropertyField.checkbox('Show Margin'),
          BlenderStaticPropertyField.number('Margin Column', 80),
          BlenderStaticPropertyField.number('Font Size', 12),
          BlenderStaticPropertyField.number('Tab Width', 4),
          BlenderStaticPropertyField.panel('Indentation', <Widget>[
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
            BlenderStaticPropertyField.checkbox('Use Tabs', value: false),
          ]),
        ], expanded: true),
        BlenderStaticPropertyField.panel('Find & Replace', <Widget>[
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
          BlenderStaticPropertyField.checkbox('Match Case', value: false),
          BlenderStaticPropertyField.checkbox('Wrap Around'),
          BlenderStaticPropertyField.checkbox('All Data-Blocks', value: false),
        ], expanded: true),
      ],
    );
  }
}

void _noopString(String? _) {}
