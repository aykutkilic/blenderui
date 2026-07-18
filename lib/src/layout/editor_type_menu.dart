part of '../layout.dart';

extension BlenderEditorTypePresentation on BlenderEditorType {
  String get label => switch (this) {
    BlenderEditorType.view3d => '3D Viewport',
    BlenderEditorType.imageEditor => 'Image Editor',
    BlenderEditorType.uvEditor => 'UV Editor',
    BlenderEditorType.compositor => 'Compositor',
    BlenderEditorType.textureNodeEditor => 'Texture Node Editor',
    BlenderEditorType.shaderEditor => 'Shader Editor',
    BlenderEditorType.geometryNodeEditor => 'Geometry Node Editor',
    BlenderEditorType.timeline => 'Timeline',
    BlenderEditorType.dopeSheet => 'Dope Sheet',
    BlenderEditorType.graphEditor => 'Graph Editor',
    BlenderEditorType.nlaEditor => 'Nonlinear Animation',
    BlenderEditorType.sequencer => 'Video Sequencer',
    BlenderEditorType.clipEditor => 'Movie Clip Editor',
    BlenderEditorType.videoEditing => 'Video Editing',
    BlenderEditorType.drivers => 'Drivers',
    BlenderEditorType.textEditor => 'Text Editor',
    BlenderEditorType.pythonConsole => 'Python Console',
    BlenderEditorType.infoEditor => 'Info',
    BlenderEditorType.outliner => 'Outliner',
    BlenderEditorType.properties => 'Properties',
    BlenderEditorType.preferences => 'Preferences',
    BlenderEditorType.fileBrowser => 'File Browser',
    BlenderEditorType.assetBrowser => 'Asset Browser',
    BlenderEditorType.spreadsheet => 'Spreadsheet',
    BlenderEditorType.project => 'Project',
  };

  BlenderGlyph get glyph => switch (this) {
    BlenderEditorType.view3d => BlenderGlyph.cube,
    BlenderEditorType.imageEditor => BlenderGlyph.image,
    BlenderEditorType.uvEditor => BlenderGlyph.uv,
    BlenderEditorType.compositor ||
    BlenderEditorType.textureNodeEditor ||
    BlenderEditorType.shaderEditor ||
    BlenderEditorType.geometryNodeEditor => BlenderGlyph.node,
    BlenderEditorType.timeline ||
    BlenderEditorType.dopeSheet ||
    BlenderEditorType.graphEditor ||
    BlenderEditorType.nlaEditor => BlenderGlyph.timeline,
    BlenderEditorType.sequencer ||
    BlenderEditorType.videoEditing => BlenderGlyph.sequence,
    BlenderEditorType.clipEditor => BlenderGlyph.movie,
    BlenderEditorType.drivers => BlenderGlyph.timeline,
    BlenderEditorType.textEditor => BlenderGlyph.text,
    BlenderEditorType.pythonConsole => BlenderGlyph.console,
    BlenderEditorType.infoEditor => BlenderGlyph.info,
    BlenderEditorType.outliner => BlenderGlyph.outliner,
    BlenderEditorType.properties => BlenderGlyph.properties,
    BlenderEditorType.preferences => BlenderGlyph.settings,
    BlenderEditorType.fileBrowser => BlenderGlyph.folder,
    BlenderEditorType.assetBrowser => BlenderGlyph.folder,
    BlenderEditorType.spreadsheet => BlenderGlyph.spreadsheet,
    BlenderEditorType.project => BlenderGlyph.folder,
  };

  String get description => switch (this) {
    BlenderEditorType.view3d => 'Manipulate objects in a 3D environment',
    BlenderEditorType.imageEditor => 'View and edit image data',
    BlenderEditorType.uvEditor => 'Unwrap and edit UV coordinates',
    BlenderEditorType.compositor => 'Compose rendered image data',
    BlenderEditorType.textureNodeEditor => 'Build texture node graphs',
    BlenderEditorType.shaderEditor => 'Build shader node graphs',
    BlenderEditorType.geometryNodeEditor => 'Build geometry node graphs',
    BlenderEditorType.timeline => 'Control playback and frame range',
    BlenderEditorType.dopeSheet => 'Edit animation keys and channels',
    BlenderEditorType.graphEditor => 'Edit animation curves',
    BlenderEditorType.nlaEditor => 'Arrange non-linear animation strips',
    BlenderEditorType.drivers => 'Edit animation drivers',
    BlenderEditorType.sequencer => 'Arrange video and audio strips',
    BlenderEditorType.videoEditing => 'Arrange video editing strips',
    BlenderEditorType.clipEditor => 'Track and edit movie clips',
    BlenderEditorType.textEditor => 'Edit text data and scripts',
    BlenderEditorType.pythonConsole => 'Run Python commands',
    BlenderEditorType.infoEditor => 'Review application reports',
    BlenderEditorType.outliner => 'Browse scene data hierarchies',
    BlenderEditorType.properties => 'Edit context-sensitive properties',
    BlenderEditorType.preferences => 'Configure Blender preferences',
    BlenderEditorType.fileBrowser => 'Browse files and directories',
    BlenderEditorType.assetBrowser => 'Browse reusable assets',
    BlenderEditorType.spreadsheet => 'Inspect tabular data',
    BlenderEditorType.project => 'Manage project settings and files',
  };

  String? get shortcut => switch (this) {
    BlenderEditorType.view3d => '⇧ F5',
    BlenderEditorType.imageEditor || BlenderEditorType.uvEditor => '⇧ F10',
    BlenderEditorType.dopeSheet || BlenderEditorType.timeline => '⇧ F12',
    BlenderEditorType.graphEditor || BlenderEditorType.drivers => '⇧ F6',
    BlenderEditorType.textEditor => '⇧ F11',
    BlenderEditorType.pythonConsole => '⇧ F4',
    BlenderEditorType.infoEditor => null,
    BlenderEditorType.project => null,
    BlenderEditorType.geometryNodeEditor ||
    BlenderEditorType.compositor ||
    BlenderEditorType.shaderEditor ||
    BlenderEditorType.textureNodeEditor => '⇧ F3',
    BlenderEditorType.sequencer || BlenderEditorType.videoEditing => '⇧ F8',
    BlenderEditorType.clipEditor => '⇧ F2',
    _ => '⇧ F1',
  };
}

class BlenderEditorTypeSelector extends StatefulWidget {
  const BlenderEditorTypeSelector({
    super.key,
    required this.value,
    this.onChanged,
    this.width,
    this.compact = false,
  });

  final BlenderEditorType value;
  final ValueChanged<BlenderEditorType>? onChanged;
  final double? width;
  final bool compact;

  @override
  State<BlenderEditorTypeSelector> createState() =>
      _BlenderEditorTypeSelectorState();
}

class _BlenderEditorTypeSelectorState extends State<BlenderEditorTypeSelector> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final button = BlenderButton(
      label: widget.compact ? '' : widget.value.label,
      leading: BlenderIcon(widget.value.glyph, size: widget.compact ? 17 : 14),
      trailing: const BlenderIcon(BlenderGlyph.panelDisclosureDown, size: 9),
      padding: widget.compact ? EdgeInsets.zero : null,
      selected: _open,
      variant: BlenderButtonVariant.menuTrigger,
      onPressed: widget.onChanged == null ? null : () {},
    );
    return SizedBox(
      width: widget.width ?? (widget.compact ? 76 : 132),
      child: BlenderPopover(
        onOpenChanged: (open) {
          if (mounted) setState(() => _open = open);
        },
        child: BlenderTooltip(
          message: widget.value.label,
          content: _BlenderEditorTypeTooltip(value: widget.value),
          child: IgnorePointer(child: button),
        ),
        popover: (context, close) => _BlenderEditorTypeMenu(
          selected: widget.value,
          onSelected: (next) {
            widget.onChanged?.call(next);
            close();
          },
        ),
      ),
    );
  }
}

class _BlenderEditorTypeTooltip extends StatelessWidget {
  const _BlenderEditorTypeTooltip({required this.value});

  final BlenderEditorType value;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return SizedBox(
      width: 360,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(text: 'Editor Type: ', style: theme.textTheme.body),
                TextSpan(
                  text: value.label,
                  style: theme.textTheme.body.copyWith(
                    color: theme.colors.link,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(value.description, style: theme.textTheme.body),
          if (value.shortcut != null) ...<Widget>[
            const SizedBox(height: 4),
            Text('Shortcut: ${value.shortcut}', style: theme.textTheme.body),
          ],
        ],
      ),
    );
  }
}

class _BlenderEditorTypeMenu extends StatelessWidget {
  const _BlenderEditorTypeMenu({
    required this.selected,
    required this.onSelected,
  });

  final BlenderEditorType selected;
  final ValueChanged<BlenderEditorType> onSelected;

  static const _categories = <({String title, List<BlenderEditorType> items})>[
    (
      title: 'General',
      items: <BlenderEditorType>[
        BlenderEditorType.view3d,
        BlenderEditorType.imageEditor,
        BlenderEditorType.uvEditor,
        BlenderEditorType.geometryNodeEditor,
        BlenderEditorType.compositor,
        BlenderEditorType.shaderEditor,
        BlenderEditorType.textureNodeEditor,
        BlenderEditorType.sequencer,
        BlenderEditorType.clipEditor,
      ],
    ),
    (
      title: 'Animation',
      items: <BlenderEditorType>[
        BlenderEditorType.dopeSheet,
        BlenderEditorType.timeline,
        BlenderEditorType.graphEditor,
        BlenderEditorType.drivers,
        BlenderEditorType.nlaEditor,
      ],
    ),
    (
      title: 'Scripting',
      items: <BlenderEditorType>[
        BlenderEditorType.textEditor,
        BlenderEditorType.pythonConsole,
        BlenderEditorType.infoEditor,
      ],
    ),
    (
      title: 'Data',
      items: <BlenderEditorType>[
        BlenderEditorType.outliner,
        BlenderEditorType.properties,
        BlenderEditorType.fileBrowser,
        BlenderEditorType.assetBrowser,
        BlenderEditorType.spreadsheet,
        BlenderEditorType.preferences,
        BlenderEditorType.project,
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: BlenderMultiColumnMenu<BlenderEditorType>(
        groups: <BlenderMultiColumnMenuGroup<BlenderEditorType>>[
          for (final category in _categories)
            BlenderMultiColumnMenuGroup<BlenderEditorType>(
              id: category.title,
              title: category.title,
              items: <BlenderMultiColumnMenuItem<BlenderEditorType>>[
                for (final item in category.items)
                  BlenderMultiColumnMenuItem<BlenderEditorType>(
                    id: item.name,
                    value: item,
                    label: item.label,
                    glyph: item.glyph,
                    trailingLabel: item.shortcut,
                  ),
              ],
            ),
        ],
        selected: selected,
        onSelected: onSelected,
      ),
    );
  }
}
