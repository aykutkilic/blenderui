part of '../non3d_editors.dart';

class BlenderTextEditor extends StatefulWidget {
  const BlenderTextEditor({
    super.key,
    this.text = '',
    this.controller,
    this.focusNode,
    this.onChanged,
    this.readOnly = false,
    this.sidebar,
    this.sidebarWidth = 240,
    this.footer,
    this.title = 'Text Editor',
  }) : assert(
         controller == null || text == '',
         'text only initializes an internally owned controller.',
       );

  final String text;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final bool readOnly;
  final Widget? sidebar;
  final double sidebarWidth;
  final Widget? footer;
  final String? title;

  @override
  State<BlenderTextEditor> createState() => _BlenderTextEditorState();
}

class _BlenderTextEditorState extends State<BlenderTextEditor> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  late bool _ownsController;
  late bool _ownsFocusNode;
  late int _lineCount;
  final ScrollController _editorScrollController = ScrollController();
  final ScrollController _gutterScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _attachController();
    _attachFocusNode();
    _editorScrollController.addListener(_synchronizeGutter);
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController(text: widget.text);
    _lineCount = _countLines(_controller.text);
    _controller.addListener(_handleControllerChanged);
  }

  void _detachController() {
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _attachFocusNode() {
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  void _detachFocusNode() {
    if (_ownsFocusNode) _focusNode.dispose();
  }

  void _handleControllerChanged() {
    final nextLineCount = _countLines(_controller.text);
    if (nextLineCount == _lineCount || !mounted) return;
    setState(() => _lineCount = nextLineCount);
  }

  int _countLines(String text) => '\n'.allMatches(text).length + 1;

  void _synchronizeGutter() {
    if (!_editorScrollController.hasClients ||
        !_gutterScrollController.hasClients) {
      return;
    }
    final target = _editorScrollController.offset
        .clamp(0.0, _gutterScrollController.position.maxScrollExtent)
        .toDouble();
    if ((_gutterScrollController.offset - target).abs() < .5) return;
    _gutterScrollController.jumpTo(target);
  }

  @override
  void didUpdateWidget(BlenderTextEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      _detachController();
      _attachController();
    }
    if (!identical(oldWidget.focusNode, widget.focusNode)) {
      _detachFocusNode();
      _attachFocusNode();
    }
    if (widget.controller == null &&
        !_focusNode.hasFocus &&
        oldWidget.text != widget.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _editorScrollController
      ..removeListener(_synchronizeGutter)
      ..dispose();
    _gutterScrollController.dispose();
    _detachController();
    _detachFocusNode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final editorStyle = theme.textTheme.body.copyWith(
      color: theme.colors.foreground,
      fontFamily: 'monospace',
    );
    final lineHeight =
        (editorStyle.fontSize ?? 13) * (editorStyle.height ?? 1.0);
    final body = Column(
      children: <Widget>[
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                width: 42,
                color: theme.colors.textField,
                child: DefaultTextStyle(
                  style: theme.textTheme.caption.copyWith(
                    color: theme.colors.foregroundMuted,
                  ),
                  child: ListView.builder(
                    controller: _gutterScrollController,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 8, right: 8),
                    itemCount: _lineCount,
                    itemExtent: lineHeight,
                    itemBuilder: (context, index) => Align(
                      alignment: Alignment.centerRight,
                      child: Text('${index + 1}'),
                    ),
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
                    scrollController: _editorScrollController,
                    style: editorStyle,
                    cursorColor: theme.colors.cursor,
                    backgroundCursorColor: theme.colors.foregroundMuted,
                    selectionColor: theme.colors.selection,
                    onChanged: widget.onChanged,
                    readOnly: widget.readOnly,
                    maxLines: null,
                    expands: true,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.footer != null) widget.footer!,
      ],
    );
    final editor = widget.title == null
        ? body
        : BlenderPanel(
            title: widget.title!,
            padding: EdgeInsets.zero,
            child: body,
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

/// Text Editor status region modeled after `space_text.py`.
class BlenderTextEditorFooter extends StatelessWidget {
  const BlenderTextEditorFooter({
    super.key,
    this.line = 1,
    this.column = 1,
    this.selectionCharacters = 0,
    this.syntax = 'Python',
    this.overwrite = false,
    this.onOverwriteChanged,
    this.height = 24,
  });

  final int line;
  final int column;
  final int selectionCharacters;
  final String syntax;
  final bool overwrite;
  final ValueChanged<bool>? onOverwriteChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.panelHeader,
        border: Border(top: BorderSide(color: theme.colors.editorBorder)),
      ),
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            children: <Widget>[
              Text('Ln $line, Col $column', style: theme.textTheme.caption),
              if (selectionCharacters > 0) ...<Widget>[
                const SizedBox(width: 10),
                Text(
                  '$selectionCharacters selected',
                  style: theme.textTheme.caption,
                ),
              ],
              const Spacer(),
              Text(syntax, style: theme.textTheme.caption),
              const SizedBox(width: 8),
              BlenderButton(
                label: overwrite ? 'OVR' : 'INS',
                variant: BlenderButtonVariant.toolbar,
                selected: overwrite,
                onPressed: onOverwriteChanged == null
                    ? null
                    : () => onOverwriteChanged!(!overwrite),
              ),
            ],
          ),
        ),
      ),
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
