import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'editors.dart';
import 'icons.dart';
import 'layout.dart';
import 'templates.dart';
import 'theme.dart';

/// A data-only attribute entry for [BlenderAttributeSearch].
@immutable
class BlenderAttributeOption<T> {
  const BlenderAttributeOption({
    required this.name,
    required this.value,
    this.domain = 'Point',
    this.dataType = 'Float',
    this.enabled = true,
  });

  final String name;
  final T value;
  final String domain;
  final String dataType;
  final bool enabled;

  String get displayLabel => '$domain  →  $name  ·  $dataType';
}

/// A searchable attribute picker matching Blender's domain/name/type menu.
///
/// The widget intentionally does not assume a Blender data model. Callers
/// provide the available attributes and receive either an existing value or a
/// newly typed name through [onCreate].
class BlenderAttributeSearch<T> extends StatefulWidget {
  const BlenderAttributeSearch({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.onCreate,
    this.onClear,
    this.placeholder = 'Attribute',
    this.title = 'Search Attributes',
    this.allowCreate = true,
    this.popupWidth = 320,
    this.popupHeight = 280,
  });

  final List<BlenderAttributeOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final ValueChanged<String>? onCreate;
  final VoidCallback? onClear;
  final String placeholder;
  final String title;
  final bool allowCreate;
  final double popupWidth;
  final double popupHeight;

  @override
  State<BlenderAttributeSearch<T>> createState() =>
      _BlenderAttributeSearchState<T>();
}

class _BlenderAttributeSearchState<T> extends State<BlenderAttributeSearch<T>> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _selectedLabel {
    for (final option in widget.options) {
      if (option.value == widget.value) return option.name;
    }
    return widget.placeholder;
  }

  void _resetSearch(bool open) {
    if (open) _controller.clear();
  }

  Widget _buildPopup(BuildContext context, VoidCallback close) {
    final theme = BlenderTheme.of(context);
    return SizedBox(
      width: widget.popupWidth,
      height: widget.popupHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
        ),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, child) {
            final query = value.text.trim().toLowerCase();
            final visible = widget.options
                .where(
                  (option) =>
                      option.enabled &&
                      (query.isEmpty ||
                          option.name.toLowerCase().contains(query) ||
                          option.domain.toLowerCase().contains(query) ||
                          option.dataType.toLowerCase().contains(query)),
                )
                .toList(growable: false);
            final exact = widget.options.any(
              (option) => option.name.toLowerCase() == query,
            );
            final canCreate =
                widget.allowCreate &&
                widget.onCreate != null &&
                query.isNotEmpty &&
                !exact;
            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: BlenderSearchField(
                    controller: _controller,
                    placeholder: widget.title,
                  ),
                ),
                if (widget.onClear != null && widget.value != null)
                  BlenderButton(
                    label: 'Clear attribute',
                    variant: BlenderButtonVariant.menu,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () {
                      widget.onClear!();
                      close();
                    },
                  ),
                Expanded(
                  child: visible.isEmpty && !canCreate
                      ? Center(
                          child: Text(
                            'No matching attributes',
                            style: theme.textTheme.caption.copyWith(
                              color: theme.colors.foregroundMuted,
                            ),
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.only(bottom: 4),
                          children: <Widget>[
                            if (canCreate)
                              BlenderButton(
                                label: 'Create "$query"',
                                leading: const BlenderIcon(
                                  BlenderGlyph.plus,
                                  size: 13,
                                ),
                                variant: BlenderButtonVariant.menu,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                onPressed: () {
                                  widget.onCreate!(value.text.trim());
                                  close();
                                },
                              ),
                            for (final option in visible)
                              BlenderButton(
                                label: option.displayLabel,
                                variant: BlenderButtonVariant.menu,
                                selected: option.value == widget.value,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                onPressed: () {
                                  widget.onChanged?.call(option.value);
                                  close();
                                },
                              ),
                          ],
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPopover(
      onOpenChanged: _resetSearch,
      child: IgnorePointer(
        child: BlenderButton(
          label: _selectedLabel,
          trailing: const BlenderIcon(
            BlenderGlyph.panelDisclosureDown,
            size: 9,
          ),
          onPressed: () {},
          enabled: widget.onChanged != null || widget.onCreate != null,
        ),
      ),
      popover: _buildPopup,
    );
  }
}

/// A compact, grouped layer selector used by Blender's layer templates.
@immutable
class BlenderLayerItem {
  const BlenderLayerItem({
    required this.id,
    required this.label,
    this.active = false,
    this.used = false,
    this.enabled = true,
  });

  final String id;
  final String label;
  final bool active;
  final bool used;
  final bool enabled;
}

class BlenderLayerSelector extends StatelessWidget {
  const BlenderLayerSelector({
    super.key,
    required this.layers,
    required this.onChanged,
    this.columnsPerGroup = 5,
  });

  final List<BlenderLayerItem> layers;
  final ValueChanged<List<String>> onChanged;
  final int columnsPerGroup;

  void _select(BlenderLayerItem layer) {
    if (!layer.enabled) return;
    final selected = <String>[
      for (final item in layers)
        if (item.active) item.id,
    ];
    final shiftPressed = HardwareKeyboard.instance.logicalKeysPressed.any(
      (key) =>
          key == LogicalKeyboardKey.shiftLeft ||
          key == LogicalKeyboardKey.shiftRight,
    );
    if (shiftPressed) {
      if (selected.contains(layer.id)) {
        selected.remove(layer.id);
      } else {
        selected.add(layer.id);
      }
    } else {
      selected
        ..clear()
        ..add(layer.id);
    }
    onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final groupSize = math.max(1, columnsPerGroup * 2);
    final groups = <List<BlenderLayerItem>>[];
    for (var start = 0; start < layers.length; start += groupSize) {
      groups.add(
        layers.sublist(start, math.min(start + groupSize, layers.length)),
      );
    }
    if (groups.isEmpty) {
      return Text(
        'No layers',
        style: theme.textTheme.caption.copyWith(
          color: theme.colors.foregroundMuted,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var group = 0; group < groups.length; group++) ...<Widget>[
          if (group > 0) const SizedBox(height: 3),
          GridView.count(
            crossAxisCount: math.max(1, columnsPerGroup),
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            children: <Widget>[
              for (final layer in groups[group])
                BlenderButton(
                  label: layer.label,
                  enabled: layer.enabled,
                  selected: layer.active,
                  variant: BlenderButtonVariant.toolbar,
                  padding: EdgeInsets.zero,
                  trailing: layer.used
                      ? Text(
                          '•',
                          style: theme.textTheme.caption.copyWith(
                            color: theme.colors.accentHover,
                          ),
                        )
                      : null,
                  onPressed: () => _select(layer),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Immutable settings for the color-management template.
@immutable
class BlenderColorManagementSettings {
  const BlenderColorManagementSettings({
    this.colorSpace = 'sRGB',
    this.viewTransform = 'AgX',
    this.look = 'None',
    this.exposure = 0,
    this.gamma = 1,
    this.useCurveMapping = false,
    this.curvePoints = const <Offset>[Offset(0, 0), Offset(1, 1)],
    this.useWhiteBalance = false,
    this.whiteBalanceTemperature = 6500,
    this.whiteBalanceTint = 0,
  });

  final String colorSpace;
  final String viewTransform;
  final String look;
  final double exposure;
  final double gamma;
  final bool useCurveMapping;
  final List<Offset> curvePoints;
  final bool useWhiteBalance;
  final double whiteBalanceTemperature;
  final double whiteBalanceTint;

  BlenderColorManagementSettings copyWith({
    String? colorSpace,
    String? viewTransform,
    String? look,
    double? exposure,
    double? gamma,
    bool? useCurveMapping,
    List<Offset>? curvePoints,
    bool? useWhiteBalance,
    double? whiteBalanceTemperature,
    double? whiteBalanceTint,
  }) {
    return BlenderColorManagementSettings(
      colorSpace: colorSpace ?? this.colorSpace,
      viewTransform: viewTransform ?? this.viewTransform,
      look: look ?? this.look,
      exposure: exposure ?? this.exposure,
      gamma: gamma ?? this.gamma,
      useCurveMapping: useCurveMapping ?? this.useCurveMapping,
      curvePoints: curvePoints ?? this.curvePoints,
      useWhiteBalance: useWhiteBalance ?? this.useWhiteBalance,
      whiteBalanceTemperature:
          whiteBalanceTemperature ?? this.whiteBalanceTemperature,
      whiteBalanceTint: whiteBalanceTint ?? this.whiteBalanceTint,
    );
  }
}

/// Composable color-space, view, exposure, curve, and white-balance controls.
class BlenderColorManagement extends StatelessWidget {
  const BlenderColorManagement({
    super.key,
    required this.settings,
    required this.onChanged,
    this.colorSpaces = const <String>['sRGB', 'Linear', 'ACEScg'],
    this.viewTransforms = const <String>['AgX', 'Standard', 'Filmic'],
    this.looks = const <String>[
      'None',
      'Medium High Contrast',
      'Very High Contrast',
    ],
    this.title = 'Color Management',
  });

  final BlenderColorManagementSettings settings;
  final ValueChanged<BlenderColorManagementSettings> onChanged;
  final List<String> colorSpaces;
  final List<String> viewTransforms;
  final List<String> looks;
  final String title;

  Widget _dropdown(
    String label,
    String value,
    List<String> values,
    ValueChanged<String> onValueChanged,
  ) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderDropdown<String>(
        value: value,
        items: [
          for (final item in values)
            BlenderMenuItem<String>(value: item, label: item),
        ],
        onChanged: onValueChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _dropdown(
            'Color Space',
            settings.colorSpace,
            colorSpaces,
            (value) => onChanged(settings.copyWith(colorSpace: value)),
          ),
          const SizedBox(height: 4),
          _dropdown(
            'View',
            settings.viewTransform,
            viewTransforms,
            (value) => onChanged(settings.copyWith(viewTransform: value)),
          ),
          const SizedBox(height: 4),
          _dropdown(
            'Look',
            settings.look,
            looks,
            (value) => onChanged(settings.copyWith(look: value)),
          ),
          const SizedBox(height: 4),
          BlenderPropertyRow(
            label: 'Exposure',
            editor: BlenderNumberField(
              value: settings.exposure,
              step: .1,
              onChanged: (value) =>
                  onChanged(settings.copyWith(exposure: value)),
            ),
          ),
          BlenderPropertyRow(
            label: 'Gamma',
            editor: BlenderNumberField(
              value: settings.gamma,
              min: 0,
              step: .01,
              onChanged: (value) => onChanged(settings.copyWith(gamma: value)),
            ),
          ),
          const SizedBox(height: 4),
          BlenderPropertyRow(
            label: 'Use Curve Mapping',
            editor: BlenderCheckbox(
              value: settings.useCurveMapping,
              label: '',
              onChanged: (value) =>
                  onChanged(settings.copyWith(useCurveMapping: value)),
            ),
          ),
          if (settings.useCurveMapping) ...<Widget>[
            const SizedBox(height: 4),
            BlenderCurveMapping(
              points: settings.curvePoints,
              height: 100,
              onChanged: (points) =>
                  onChanged(settings.copyWith(curvePoints: points)),
            ),
          ],
          const SizedBox(height: 4),
          BlenderPropertyRow(
            label: 'Use White Balance',
            editor: BlenderCheckbox(
              value: settings.useWhiteBalance,
              label: '',
              onChanged: (value) =>
                  onChanged(settings.copyWith(useWhiteBalance: value)),
            ),
          ),
          if (settings.useWhiteBalance) ...<Widget>[
            const SizedBox(height: 4),
            BlenderPropertyRow(
              label: 'Temperature',
              editor: BlenderNumberField(
                value: settings.whiteBalanceTemperature,
                min: 1000,
                max: 20000,
                step: 10,
                decimalDigits: 0,
                onChanged: (value) => onChanged(
                  settings.copyWith(whiteBalanceTemperature: value),
                ),
              ),
            ),
            BlenderPropertyRow(
              label: 'Tint',
              editor: BlenderNumberField(
                value: settings.whiteBalanceTint,
                min: -1,
                max: 1,
                step: .01,
                onChanged: (value) =>
                    onChanged(settings.copyWith(whiteBalanceTint: value)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

@immutable
class BlenderCurveProfilePreset {
  const BlenderCurveProfilePreset({required this.name, required this.points});

  final String name;
  final List<Offset> points;
}

/// An editable curve profile with Blender-style presets and view controls.
class BlenderCurveProfile extends StatefulWidget {
  const BlenderCurveProfile({
    super.key,
    required this.points,
    required this.onChanged,
    this.presets = const <BlenderCurveProfilePreset>[],
    this.onReset,
    this.title = 'Curve Profile',
    this.height = 160,
  });

  final List<Offset> points;
  final ValueChanged<List<Offset>> onChanged;
  final List<BlenderCurveProfilePreset> presets;
  final VoidCallback? onReset;
  final String title;
  final double height;

  @override
  State<BlenderCurveProfile> createState() => _BlenderCurveProfileState();
}

class _BlenderCurveProfileState extends State<BlenderCurveProfile> {
  int _selected = 0;
  double _zoom = 1;

  @override
  void didUpdateWidget(BlenderCurveProfile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.points.isEmpty) {
      _selected = 0;
    } else {
      _selected = math.min(_selected, widget.points.length - 1);
    }
  }

  Offset _display(Offset point) {
    final normalized = Offset(
      point.dx.clamp(0, 1).toDouble(),
      point.dy.clamp(0, 1).toDouble(),
    );
    return Offset(
      (normalized.dx - .5) * _zoom + .5,
      (normalized.dy - .5) * _zoom + .5,
    );
  }

  Offset _normalize(Offset local, Size size) {
    final display = Offset(
      (local.dx / math.max(1, size.width) - .5) / _zoom + .5,
      (1 - local.dy / math.max(1, size.height) - .5) / _zoom + .5,
    );
    return Offset(display.dx.clamp(0, 1), display.dy.clamp(0, 1));
  }

  int _nearest(Offset normalized) {
    var nearest = 0;
    var distance = double.infinity;
    for (var index = 0; index < widget.points.length; index++) {
      final candidate = (_display(widget.points[index]) - normalized).distance;
      if (candidate < distance) {
        distance = candidate;
        nearest = index;
      }
    }
    return nearest;
  }

  void _select(Offset local, Size size) {
    if (widget.points.isEmpty) return;
    final normalized = _normalize(local, size);
    setState(() => _selected = _nearest(normalized));
  }

  void _move(Offset local, Size size) {
    if (widget.points.isEmpty) return;
    final next = widget.points.toList();
    next[_selected] = _normalize(local, size);
    widget.onChanged(next);
  }

  void _resetCurve() {
    widget.onReset?.call();
    if (widget.onReset == null) {
      widget.onChanged(const <Offset>[Offset(0, 0), Offset(1, 1)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: widget.title,
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Wrap(
            spacing: 2,
            children: <Widget>[
              if (widget.presets.isNotEmpty)
                BlenderMenuButton<String>(
                  label: 'Presets',
                  items: [
                    for (final preset in widget.presets)
                      BlenderMenuItem<String>(
                        value: preset.name,
                        label: preset.name,
                      ),
                  ],
                  onSelected: (name) {
                    for (final preset in widget.presets) {
                      if (preset.name == name) {
                        widget.onChanged(preset.points.toList());
                        break;
                      }
                    }
                  },
                ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: _zoom <= 1
                    ? null
                    : () => setState(() => _zoom = math.max(1, _zoom - .5)),
                tooltip: 'Zoom out',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.plus,
                onPressed: _zoom >= 4
                    ? null
                    : () => setState(() => _zoom = math.min(4, _zoom + .5)),
                tooltip: 'Zoom in',
                size: 22,
              ),
              BlenderButton(
                label: '${_zoom.toStringAsFixed(1)}x',
                variant: BlenderButtonVariant.toolbar,
                onPressed: () => setState(() => _zoom = 1),
              ),
              BlenderButton(
                label: 'Reset Curve',
                variant: BlenderButtonVariant.toolbar,
                onPressed: _resetCurve,
              ),
            ],
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: widget.height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(
                  constraints.maxWidth.isFinite ? constraints.maxWidth : 200,
                  widget.height,
                );
                return GestureDetector(
                  onTapDown: (details) => _select(details.localPosition, size),
                  onPanStart: (details) => _select(details.localPosition, size),
                  onPanUpdate: (details) => _move(details.localPosition, size),
                  child: CustomPaint(
                    painter: _BlenderCurveProfilePainter(
                      points: widget.points,
                      selected: _selected,
                      zoom: _zoom,
                      colors: theme.colors,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BlenderCurveProfilePainter extends CustomPainter {
  const _BlenderCurveProfilePainter({
    required this.points,
    required this.selected,
    required this.zoom,
    required this.colors,
  });

  final List<Offset> points;
  final int selected;
  final double zoom;
  final BlenderColorScheme colors;

  Offset _toCanvas(Offset point, Size size) {
    final x = (point.dx.clamp(0, 1).toDouble() - .5) * zoom + .5;
    final y = (point.dy.clamp(0, 1).toDouble() - .5) * zoom + .5;
    return Offset(x * size.width, (1 - y) * size.height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.textField);
    final grid = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    for (var index = 1; index < 4; index++) {
      final x = size.width * index / 4;
      final y = size.height * index / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final normalized = [for (final point in points) _toCanvas(point, size)];
    if (normalized.length > 1) {
      final path = Path()..moveTo(normalized.first.dx, normalized.first.dy);
      for (var index = 1; index < normalized.length; index++) {
        path.lineTo(normalized[index].dx, normalized[index].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    for (var index = 0; index < normalized.length; index++) {
      canvas.drawCircle(
        normalized[index],
        index == selected ? 5 : 4,
        Paint()..color = index == selected ? colors.focus : colors.foreground,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderCurveProfilePainter oldDelegate) {
    return points != oldDelegate.points ||
        selected != oldDelegate.selected ||
        zoom != oldDelegate.zoom ||
        colors != oldDelegate.colors;
  }
}
