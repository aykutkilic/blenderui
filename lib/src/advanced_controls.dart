import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'icons.dart';
import 'theme.dart';

/// A compact mutually-exclusive group used for Blender mode and view choices.
class BlenderSegmentedControl<T> extends StatelessWidget {
  const BlenderSegmentedControl({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.expanded = false,
  });

  final T value;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<T> onChanged;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Properties rows often give this control only the remaining narrow
        // editor slot. In that case each segment must share the available
        // width; intrinsic button widths are allowed only when the parent is
        // horizontally unconstrained.
        final useExpanded = constraints.hasBoundedWidth;
        final children = <Widget>[
          for (var index = 0; index < items.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(width: 1),
            if (useExpanded || expanded)
              Expanded(child: _buildItem(items[index]))
            else
              _buildItem(items[index]),
          ],
        ];
        return Row(
          mainAxisSize: useExpanded ? MainAxisSize.max : MainAxisSize.min,
          children: children,
        );
      },
    );
  }

  Widget _buildItem(BlenderMenuItem<T> item) {
    return BlenderButton(
      label: item.label,
      leading: item.icon,
      selected: item.value == value,
      enabled: item.enabled,
      onPressed: item.enabled ? () => onChanged(item.value) : null,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      showBorder: false,
    );
  }
}

class BlenderDisclosureButton extends StatelessWidget {
  const BlenderDisclosureButton({
    super.key,
    required this.expanded,
    required this.onPressed,
    this.size = 20,
    this.tooltip,
  });

  final bool expanded;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return BlenderIconButton(
      glyph: expanded ? BlenderGlyph.chevronDown : BlenderGlyph.chevronRight,
      onPressed: onPressed,
      tooltip: tooltip,
      size: size,
    );
  }
}

class BlenderColorSwatch extends StatelessWidget {
  const BlenderColorSwatch({
    super.key,
    required this.color,
    this.onPressed,
    this.size = 22,
    this.tooltip,
  });

  final Color color;
  final VoidCallback? onPressed;
  final double size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    Widget child = Semantics(
      label: tooltip,
      button: onPressed != null,
      enabled: onPressed != null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
        ),
      ),
    );
    if (onPressed != null) {
      child = GestureDetector(onTap: onPressed, child: child);
    }
    if (tooltip != null) {
      child = BlenderTooltip(message: tooltip!, child: child);
    }
    return child;
  }
}

class BlenderColorField extends StatelessWidget {
  const BlenderColorField({
    super.key,
    required this.color,
    this.label,
    this.onPressed,
    this.enabled = true,
  });

  final Color color;
  final String? label;
  final VoidCallback? onPressed;
  final bool enabled;

  String get _hex =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final content = GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        height: theme.density.controlHeight,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: theme.colors.textField,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              BlenderColorSwatch(color: color, size: 14),
              const SizedBox(width: 5),
              Text(
                _hex,
                style: theme.textTheme.caption.copyWith(
                  color: enabled
                      ? theme.colors.foreground
                      : theme.colors.foregroundDisabled,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return label == null
        ? content
        : Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label!,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.label,
                ),
              ),
              Flexible(child: content),
            ],
          );
  }
}

class BlenderColorPicker extends StatefulWidget {
  const BlenderColorPicker({
    super.key,
    required this.color,
    required this.onChanged,
    this.showFields = true,
    this.showAlpha = true,
  });

  final Color color;
  final ValueChanged<Color> onChanged;
  final bool showFields;
  final bool showAlpha;

  @override
  State<BlenderColorPicker> createState() => _BlenderColorPickerState();
}

class _BlenderColorPickerState extends State<BlenderColorPicker> {
  late HSVColor _hsv = HSVColor.fromColor(widget.color);

  @override
  void didUpdateWidget(BlenderColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _hsv = HSVColor.fromColor(widget.color);
    }
  }

  void _setColor(HSVColor value) {
    setState(() => _hsv = value);
    widget.onChanged(value.toColor());
  }

  void _updateSaturationValue(Offset localPosition, Size size) {
    final saturation = (localPosition.dx / size.width).clamp(0, 1).toDouble();
    final value = (1 - localPosition.dy / size.height).clamp(0, 1).toDouble();
    _setColor(_hsv.withSaturation(saturation).withValue(value));
  }

  void _updateHue(Offset localPosition, Size size) {
    final hue = (localPosition.dx / size.width * 360).clamp(0, 360).toDouble();
    _setColor(_hsv.withHue(hue));
  }

  void _updateChannel(int channel, double value) {
    final current = _hsv.toColor();
    final red = channel == 0 ? value : current.r;
    final green = channel == 1 ? value : current.g;
    final blue = channel == 2 ? value : current.b;
    final alpha = channel == 3 ? value : current.a;
    _setColor(
      HSVColor.fromColor(
        Color.fromARGB(
          (alpha * 255).round(),
          (red * 255).round(),
          (green * 255).round(),
          (blue * 255).round(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final currentColor = _hsv.toColor();
    final channels = <double>[
      currentColor.r,
      currentColor.g,
      currentColor.b,
      if (widget.showAlpha) currentColor.a,
    ];
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.panelSubSurface,
        border: Border.all(color: theme.colors.editorBorder),
        borderRadius: BorderRadius.circular(theme.shapes.panelRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 150,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) => _updateSaturationValue(
                      details.localPosition,
                      constraints.biggest,
                    ),
                    onPanUpdate: (details) => _updateSaturationValue(
                      details.localPosition,
                      constraints.biggest,
                    ),
                    child: CustomPaint(
                      painter: _BlenderColorPickerPainter(hsv: _hsv),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 18,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) =>
                        _updateHue(details.localPosition, constraints.biggest),
                    onHorizontalDragUpdate: (details) =>
                        _updateHue(details.localPosition, constraints.biggest),
                    child: const CustomPaint(painter: _BlenderHuePainter()),
                  );
                },
              ),
            ),
            if (widget.showFields) ...<Widget>[
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: <Widget>[
                  for (var channel = 0; channel < channels.length; channel++)
                    SizedBox(
                      width: 100,
                      child: BlenderNumberField(
                        label: const <String>['R', 'G', 'B', 'A'][channel],
                        value: channels[channel],
                        min: 0,
                        max: 1,
                        step: .01,
                        decimalDigits: 2,
                        onChanged: (value) => _updateChannel(channel, value),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: <Widget>[
                BlenderColorSwatch(color: currentColor, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '#${currentColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.caption,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BlenderColorPickerPainter extends CustomPainter {
  const _BlenderColorPickerPainter({required this.hsv});

  final HSVColor hsv;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final hueColor = hsv.withSaturation(1).withValue(1).toColor();
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: <Color>[const Color(0xFFFFFFFF), hueColor],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0x00000000), Color(0xFF000000)],
        ).createShader(rect),
    );
    final cursor = Offset(
      hsv.saturation * size.width,
      (1 - hsv.value) * size.height,
    );
    canvas.drawCircle(
      cursor,
      6,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_BlenderColorPickerPainter oldDelegate) =>
      hsv != oldDelegate.hsv;
}

class _BlenderHuePainter extends CustomPainter {
  const _BlenderHuePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final colors = <Color>[
      for (var i = 0; i <= 6; i++)
        HSVColor.fromAHSV(1, i * 60.0 % 360, 1, 1).toColor(),
    ];
    canvas.drawRect(
      rect,
      Paint()..shader = LinearGradient(colors: colors).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_BlenderHuePainter oldDelegate) => false;
}

class BlenderProgressBar extends StatelessWidget {
  const BlenderProgressBar({
    super.key,
    required this.value,
    this.label,
    this.height = 16,
  });

  final double value;
  final String? label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final progress = value.clamp(0, 1).toDouble();
    return Semantics(
      value: label ?? '${(progress * 100).round()}%',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: theme.colors.textField,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: ColoredBox(color: theme.colors.buttonSelected),
            ),
            if (label != null)
              Center(
                child: Text(
                  label!,
                  style: theme.textTheme.caption.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BlenderSeparator extends StatelessWidget {
  const BlenderSeparator({super.key, this.axis = Axis.horizontal});

  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return axis == Axis.horizontal
        ? SizedBox(
            height: 1,
            child: ColoredBox(color: theme.colors.borderSubtle),
          )
        : SizedBox(
            width: 1,
            child: ColoredBox(color: theme.colors.borderSubtle),
          );
  }
}

class BlenderKeycap extends StatelessWidget {
  const BlenderKeycap(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.buttonPressed,
        border: Border.all(color: theme.colors.borderSubtle),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(label, style: theme.textTheme.caption),
      ),
    );
  }
}

enum BlenderPropertyState {
  normal,
  animated,
  keyed,
  driven,
  overridden,
  changed,
}

class BlenderPropertyIndicator extends StatelessWidget {
  const BlenderPropertyIndicator({
    super.key,
    required this.state,
    this.size = 6,
  });

  final BlenderPropertyState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = BlenderTheme.of(context).colors;
    final color = switch (state) {
      BlenderPropertyState.normal => colors.foregroundDisabled,
      BlenderPropertyState.animated => const Color(0xFF53992E),
      BlenderPropertyState.keyed => const Color(0xFFB3AE36),
      BlenderPropertyState.driven => const Color(0xFF9000CC),
      BlenderPropertyState.overridden => const Color(0xFF00C3C3),
      BlenderPropertyState.changed => const Color(0xFFCC7529),
    };
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class BlenderPropertyTab {
  const BlenderPropertyTab({
    required this.id,
    required this.label,
    required this.glyph,
    this.group = 0,
  });

  final String id;
  final String label;
  final BlenderGlyph glyph;

  /// Consecutive groups are separated by Blender-style breathing room.
  final int group;
}

Color _propertyTabIconColor(BlenderColorScheme colors, BlenderGlyph glyph) {
  switch (glyph) {
    case BlenderGlyph.tool:
    case BlenderGlyph.modifier:
      return colors.iconModifier;
    case BlenderGlyph.object:
      return colors.iconObject;
    case BlenderGlyph.material:
      return colors.iconShading;
    case BlenderGlyph.render:
    case BlenderGlyph.output:
    case BlenderGlyph.scene:
    case BlenderGlyph.world:
      return colors.iconScene;
    default:
      return colors.foregroundMuted;
  }
}

/// The compact menu used by Properties headers to choose which context tabs
/// are visible. It opens on hover like Blender and remains usable by click.
class BlenderPropertyTabVisibilityMenu extends StatelessWidget {
  const BlenderPropertyTabVisibilityMenu({
    super.key,
    required this.tabs,
    required this.visibleTabIds,
    required this.onVisibilityChanged,
    this.size = 28,
  });

  final List<BlenderPropertyTab> tabs;
  final Set<String> visibleTabIds;
  final ValueChanged<Set<String>> onVisibilityChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPopover(
      openOnHover: true,
      targetAnchor: Alignment.bottomRight,
      followerAnchor: Alignment.topRight,
      child: BlenderIconButton(
        glyph: BlenderGlyph.panelDisclosureDown,
        size: size,
        iconSize: 9,
        tooltip: 'Show visible Properties tabs',
      ),
      popover: (context, close) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 238, maxHeight: 540),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.menuBackground,
            border: Border.all(color: theme.colors.borderSubtle),
            borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x99000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Visible Tabs',
                  style: theme.textTheme.body.copyWith(
                    color: theme.colors.foregroundMuted,
                  ),
                ),
                const SizedBox(height: 6),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 475),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        for (final tab in tabs)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 26,
                                  child: BlenderIcon(
                                    tab.glyph,
                                    size: 16,
                                    color: _propertyTabIconColor(
                                      theme.colors,
                                      tab.glyph,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    tab.label,
                                    style: theme.textTheme.body.copyWith(
                                      color: theme.colors.foregroundMuted,
                                    ),
                                  ),
                                ),
                                BlenderCheckbox(
                                  value: visibleTabIds.contains(tab.id),
                                  onChanged: (visible) {
                                    final updated = Set<String>.of(
                                      visibleTabIds,
                                    );
                                    if (visible) {
                                      updated.add(tab.id);
                                    } else if (updated.length > 1) {
                                      updated.remove(tab.id);
                                    }
                                    onVisibilityChanged(updated);
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
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

class BlenderPropertyTabs extends StatelessWidget {
  const BlenderPropertyTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.width = 36,
    // Context tiles occupy the rail instead of leaving a second dark gutter
    // between the tab and the Properties content. Callers can still opt into
    // a smaller tile when building a deliberately padded custom rail.
    this.tileSize = 36,
    this.visibleTabIds,
    this.onVisibilityChanged,
  });

  final List<BlenderPropertyTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double width;
  final double tileSize;
  final Set<String>? visibleTabIds;
  final ValueChanged<Set<String>>? onVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final visibleEntries = <MapEntry<int, List<int>>>[];
    for (var index = 0; index < tabs.length; index++) {
      if (visibleTabIds != null && !visibleTabIds!.contains(tabs[index].id)) {
        continue;
      }
      final existing = visibleEntries.indexWhere(
        (entry) => entry.key == tabs[index].group,
      );
      if (existing == -1) {
        visibleEntries.add(
          MapEntry<int, List<int>>(tabs[index].group, <int>[index]),
        );
      } else {
        visibleEntries[existing].value.add(index);
      }
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        // Blender's context tabs sit on one uninterrupted, near-black strip.
        // Their groups are defined by small vertical breathing room, not by
        // individual rounded containers or outlines.
        color: theme.colors.tab,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x66000000),
            offset: Offset(1, 0),
            blurRadius: 1,
          ),
        ],
      ),
      child: SizedBox(
        width: width,
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                // An attached Properties rail shares the editor's top edge.
                // Keep a one-pixel seam on the outer edge, while the content
                // edge stays flush so the selected tile attaches to the pane.
                padding: const EdgeInsets.fromLTRB(1, 0, 0, 5),
                children: <Widget>[
                  for (
                    var groupIndex = 0;
                    groupIndex < visibleEntries.length;
                    groupIndex++
                  ) ...<Widget>[
                    if (groupIndex > 0) const SizedBox(height: 4),
                    DecoratedBox(
                      decoration: const BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Color(0x38000000),
                            offset: Offset(0, 1),
                            blurRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          for (final index in visibleEntries[groupIndex].value)
                            _BlenderPropertyTabButton(
                              tab: tabs[index],
                              selected: index == selectedIndex,
                              size: tileSize.clamp(1, width - 1).toDouble(),
                              onPressed: () => onChanged(index),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (visibleTabIds != null &&
                      onVisibilityChanged != null) ...<Widget>[
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: BlenderPropertyTabVisibilityMenu(
                        tabs: tabs,
                        visibleTabIds: visibleTabIds!,
                        onVisibilityChanged: onVisibilityChanged!,
                        size: tileSize.clamp(1, width - 1).toDouble(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlenderPropertyTabButton extends StatefulWidget {
  const _BlenderPropertyTabButton({
    required this.tab,
    required this.selected,
    required this.size,
    required this.onPressed,
  });

  final BlenderPropertyTab tab;
  final bool selected;
  final double size;
  final VoidCallback onPressed;

  @override
  State<_BlenderPropertyTabButton> createState() =>
      _BlenderPropertyTabButtonState();
}

class _BlenderPropertyTabButtonState extends State<_BlenderPropertyTabButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    // `wcol_tab` in Blender keeps the outline and unselected fill identical.
    // Inset the outer edge, but let the content edge meet the neighboring
    // editor so the selected tab reads as an attached surface.
    final background = widget.selected || _hovered
        ? theme.colors.tabSelected
        : theme.colors.tab;
    return BlenderTooltip(
      message: widget.tab.label,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onPressed,
          child: SizedBox(
            key: ValueKey<String>('property-tab-${widget.tab.id}'),
            width: widget.size,
            height: widget.size,
            child: Padding(
              padding: widget.selected || _hovered
                  ? const EdgeInsets.only(left: 1, top: 1, bottom: 1)
                  : EdgeInsets.zero,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    bottomLeft: Radius.circular(3),
                  ),
                ),
                child: Center(
                  child: BlenderIcon(
                    widget.tab.glyph,
                    size: 15,
                    color: _propertyTabIconColor(
                      theme.colors,
                      widget.tab.glyph,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BlenderPlaybackControls extends StatelessWidget {
  const BlenderPlaybackControls({
    super.key,
    this.onFirst,
    this.onPrevious,
    this.onPlay,
    this.onNext,
    this.onLast,
    this.onRecord,
    this.playing = false,
    this.recording = false,
  });

  final VoidCallback? onFirst;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlay;
  final VoidCallback? onNext;
  final VoidCallback? onLast;
  final VoidCallback? onRecord;
  final bool playing;
  final bool recording;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BlenderIconButton(
          glyph: BlenderGlyph.stepBack,
          onPressed: onFirst,
          tooltip: 'Jump to first frame',
          size: 22,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.stepBack,
          onPressed: onPrevious,
          tooltip: 'Previous frame',
          size: 22,
        ),
        BlenderIconButton(
          glyph: playing ? BlenderGlyph.pause : BlenderGlyph.play,
          onPressed: onPlay,
          selected: playing,
          tooltip: playing ? 'Pause' : 'Play',
          size: 22,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.stepForward,
          onPressed: onNext,
          tooltip: 'Next frame',
          size: 22,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.stepForward,
          onPressed: onLast,
          tooltip: 'Jump to last frame',
          size: 22,
        ),
        BlenderIconButton(
          glyph: BlenderGlyph.record,
          onPressed: onRecord,
          selected: recording,
          tooltip: 'Record animation',
          size: 22,
        ),
      ],
    );
  }
}
