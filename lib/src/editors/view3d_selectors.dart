part of '../editors.dart';

const List<(String, BlenderGlyph)> _view3dModes = <(String, BlenderGlyph)>[
  ('Object Mode', BlenderGlyph.object),
  ('Edit Mode', BlenderGlyph.mesh),
  ('Sculpt Mode', BlenderGlyph.eyedropper),
  ('Draw Mode', BlenderGlyph.greasepencil),
  ('Weight Paint', BlenderGlyph.tool),
  ('Vertex Paint', BlenderGlyph.color),
];

const List<(String, BlenderGlyph)> _transformOrientations =
    <(String, BlenderGlyph)>[
      ('Global', BlenderGlyph.transform),
      ('Local', BlenderGlyph.rotate),
      ('Normal', BlenderGlyph.gizmo),
      ('Gimbal', BlenderGlyph.rotate),
      ('View', BlenderGlyph.scale),
      ('Cursor', BlenderGlyph.snap),
      ('Parent', BlenderGlyph.object),
    ];

/// Blender's Object Mode `operator_menu_enum` header control.
///
/// Unlike a property dropdown, the mode menu uses large semantic icons and a
/// selected row without an additional checkmark column.
class BlenderView3dModeSelector extends StatefulWidget {
  const BlenderView3dModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<BlenderView3dModeSelector> createState() =>
      _BlenderView3dModeSelectorState();
}

class _BlenderView3dModeSelectorState extends State<BlenderView3dModeSelector> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final choice = _choiceFor(widget.value, _view3dModes);
    return BlenderPopover(
      onOpenChanged: (open) => setState(() => _open = open),
      child: IgnorePointer(
        child: BlenderButton(
          label: widget.value,
          leading: BlenderIcon(choice.$2, size: 16),
          trailing: const BlenderIcon(
            BlenderGlyph.panelDisclosureDown,
            size: 9,
          ),
          selected: _open,
          variant: BlenderButtonVariant.toolbar,
          onPressed: () {},
          padding: const EdgeInsets.symmetric(horizontal: 6),
        ),
      ),
      popover: (context, close) => _View3dModeMenu(
        value: widget.value,
        onChanged: (value) {
          widget.onChanged(value);
          close();
        },
      ),
    );
  }
}

class _View3dModeMenu extends StatelessWidget {
  const _View3dModeMenu({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Container(
      key: const ValueKey<String>('view3d-mode-menu'),
      width: 204,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.colors.menuBackground,
        border: Border.all(color: theme.colors.borderSubtle),
        borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final choice in _view3dModes)
            _View3dChoiceRow(
              key: ValueKey<String>('view3d-mode-${choice.$1}'),
              label: choice.$1,
              glyph: choice.$2,
              selected: choice.$1 == value,
              height: 32,
              iconSize: 22,
              onPressed: () => onChanged(choice.$1),
            ),
        ],
      ),
    );
  }
}

/// Blender's Transform Orientations header popover.
class BlenderTransformOrientationSelector extends StatefulWidget {
  const BlenderTransformOrientationSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.onCreate,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCreate;

  @override
  State<BlenderTransformOrientationSelector> createState() =>
      _BlenderTransformOrientationSelectorState();
}

class _BlenderTransformOrientationSelectorState
    extends State<BlenderTransformOrientationSelector> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final choice = _choiceFor(widget.value, _transformOrientations);
    return BlenderPopover(
      offset: const Offset(0, 5),
      targetAnchor: Alignment.bottomCenter,
      followerAnchor: Alignment.topCenter,
      onOpenChanged: (open) => setState(() => _open = open),
      child: IgnorePointer(
        child: BlenderButton(
          label: widget.value,
          leading: BlenderIcon(choice.$2, size: 18),
          trailing: const BlenderIcon(
            BlenderGlyph.panelDisclosureDown,
            size: 9,
          ),
          selected: _open,
          variant: BlenderButtonVariant.toolbar,
          onPressed: () {},
          padding: const EdgeInsets.symmetric(horizontal: 7),
        ),
      ),
      popover: (context, close) => _TransformOrientationPanel(
        value: widget.value,
        onChanged: (value) {
          widget.onChanged(value);
          close();
        },
        onCreate: widget.onCreate,
      ),
    );
  }
}

class _TransformOrientationPanel extends StatelessWidget {
  const _TransformOrientationPanel({
    required this.value,
    required this.onChanged,
    required this.onCreate,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return SizedBox(
      key: const ValueKey<String>('transform-orientation-panel'),
      width: 224,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.menuBackground,
                border: Border.all(color: theme.colors.borderSubtle),
                borderRadius: BorderRadius.circular(5),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Transform Orientations',
                        style: theme.textTheme.body.copyWith(
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Column(
                              children: <Widget>[
                                for (final choice in _transformOrientations)
                                  _View3dChoiceRow(
                                    key: ValueKey<String>(
                                      'transform-orientation-${choice.$1}',
                                    ),
                                    label: choice.$1,
                                    glyph: choice.$2,
                                    selected: choice.$1 == value,
                                    height: 28,
                                    iconSize: 19,
                                    connected: true,
                                    onPressed: () => onChanged(choice.$1),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Semantics(
                          button: true,
                          label: 'Create Transform Orientation',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onCreate,
                            child: const SizedBox.square(
                              dimension: 30,
                              child: Center(
                                child: BlenderIcon(BlenderGlyph.plus, size: 20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          CustomPaint(
            size: const Size(18, 9),
            painter: _View3dPopoverArrowPainter(
              fill: theme.colors.menuBackground,
              border: theme.colors.borderSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _View3dChoiceRow extends StatefulWidget {
  const _View3dChoiceRow({
    super.key,
    required this.label,
    required this.glyph,
    required this.selected,
    required this.height,
    required this.iconSize,
    required this.onPressed,
    this.connected = false,
  });

  final String label;
  final BlenderGlyph glyph;
  final bool selected;
  final double height;
  final double iconSize;
  final VoidCallback onPressed;
  final bool connected;

  @override
  State<_View3dChoiceRow> createState() => _View3dChoiceRowState();
}

class _View3dChoiceRowState extends State<_View3dChoiceRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final highlighted = widget.selected || _hovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onPressed,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(
            color: highlighted
                ? theme.colors.menuSelection
                : widget.connected
                ? theme.colors.button
                : null,
            border: widget.connected && !highlighted
                ? Border(bottom: BorderSide(color: theme.colors.borderSubtle))
                : null,
            borderRadius: widget.connected ? null : BorderRadius.circular(3),
          ),
          child: Row(
            children: <Widget>[
              BlenderIcon(
                widget.glyph,
                size: widget.iconSize,
                color: highlighted
                    ? theme.colors.foreground
                    : theme.colors.foregroundMuted,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.body.copyWith(
                    color: theme.colors.foreground,
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

class _View3dPopoverArrowPainter extends CustomPainter {
  const _View3dPopoverArrowPainter({required this.fill, required this.border});

  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_View3dPopoverArrowPainter oldDelegate) =>
      fill != oldDelegate.fill || border != oldDelegate.border;
}

(String, BlenderGlyph) _choiceFor(
  String value,
  List<(String, BlenderGlyph)> choices,
) => choices.firstWhere(
  (choice) => choice.$1 == value,
  orElse: () => choices.first,
);
