import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/widgets.dart';

import 'advanced_controls.dart';
import 'controls.dart';
import 'icons.dart';
import 'layout.dart';
import 'services.dart';
import 'theme.dart';

/// A compact row of Blender-style numeric vector components.
class BlenderVectorField extends StatelessWidget {
  const BlenderVectorField({
    super.key,
    required this.values,
    required this.onChanged,
    this.labels = const <String>['X', 'Y', 'Z'],
    this.min,
    this.max,
    this.step = 0.1,
    this.decimalDigits = 3,
  });

  final List<double> values;
  final ValueChanged<List<double>> onChanged;
  final List<String> labels;
  final double? min;
  final double? max;
  final double step;
  final int decimalDigits;

  @override
  Widget build(BuildContext context) {
    final count = math.min(values.length, labels.length);
    return Row(
      children: <Widget>[
        for (var index = 0; index < count; index++) ...<Widget>[
          if (index > 0) const SizedBox(width: 4),
          Expanded(
            child: BlenderNumberField(
              value: values[index],
              label: labels[index],
              min: min,
              max: max,
              step: step,
              decimalDigits: decimalDigits,
              fieldWidth: 64,
              onChanged: (value) {
                final next = values.toList();
                next[index] = value;
                onChanged(next);
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// A dense row-and-column matrix editor used by Blender transform and shader
/// templates.
class BlenderMatrixField extends StatelessWidget {
  const BlenderMatrixField({
    super.key,
    required this.values,
    required this.onChanged,
    this.rowLabels = const <String>[],
    this.columnLabels = const <String>[],
    this.min,
    this.max,
    this.step = 0.1,
    this.decimalDigits = 3,
  });

  final List<List<double>> values;
  final ValueChanged<List<List<double>>> onChanged;
  final List<String> rowLabels;
  final List<String> columnLabels;
  final double? min;
  final double? max;
  final double step;
  final int decimalDigits;

  void _update(int row, int column, double value) {
    final next = <List<double>>[
      for (final sourceRow in values) sourceRow.toList(),
    ];
    if (row >= next.length || column >= next[row].length) return;
    next[row][column] = value;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final columns = values.fold<int>(
      0,
      (maximum, row) => math.max(maximum, row.length),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (columnLabels.isNotEmpty)
          Row(
            children: <Widget>[
              if (rowLabels.isNotEmpty) const SizedBox(width: 24),
              for (var column = 0; column < columns; column++)
                Expanded(
                  child: Text(
                    column < columnLabels.length ? columnLabels[column] : '',
                    textAlign: TextAlign.center,
                    style: BlenderTheme.of(context).textTheme.caption,
                  ),
                ),
            ],
          ),
        for (var row = 0; row < values.length; row++)
          Row(
            children: <Widget>[
              if (rowLabels.isNotEmpty)
                SizedBox(
                  width: 24,
                  child: Text(
                    row < rowLabels.length ? rowLabels[row] : '',
                    style: BlenderTheme.of(context).textTheme.caption,
                  ),
                ),
              for (var column = 0; column < values[row].length; column++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 3, bottom: 3),
                    child: BlenderNumberField(
                      value: values[row][column],
                      min: min,
                      max: max,
                      step: step,
                      decimalDigits: decimalDigits,
                      fieldWidth: 64,
                      onChanged: (value) => _update(row, column, value),
                    ),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// The read-only transform decomposition rendered by Blender's
/// `template_matrix()` UI template.
@immutable
class BlenderMatrixTransformValues {
  const BlenderMatrixTransformValues({
    required this.location,
    required this.rotation,
    required this.scale,
    this.rotationMode = 'XYZ Euler',
    this.hasShear = false,
  });

  final List<double> location;
  final List<double> rotation;
  final List<double> scale;
  final String rotationMode;
  final bool hasShear;
}

class BlenderMatrixTransformPanel extends StatelessWidget {
  const BlenderMatrixTransformPanel({
    super.key,
    required this.values,
    this.onRotationModeChanged,
    this.rotationModes = const <String>[
      'Quaternion',
      'XYZ Euler',
      'XZY Euler',
      'YXZ Euler',
      'YZX Euler',
      'ZXY Euler',
      'ZYX Euler',
      'Axis Angle',
    ],
    this.decimalDigits = 3,
  });

  final BlenderMatrixTransformValues values;
  final ValueChanged<String>? onRotationModeChanged;
  final List<String> rotationModes;
  final int decimalDigits;

  String _format(double value) {
    if (value == 0) {
      return '0.${List<String>.filled(decimalDigits, '0').join()}';
    }
    return value.toStringAsFixed(decimalDigits);
  }

  Widget _valueRow(BuildContext context, String label, double value) {
    final theme = BlenderTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.label,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(_format(value), style: theme.textTheme.label),
          ),
        ],
      ),
    );
  }

  Widget _rotationModeRow(BuildContext context) {
    final items = <BlenderMenuItem<String>>[
      for (final mode in rotationModes)
        BlenderMenuItem<String>(value: mode, label: mode),
    ];
    final mode = items.any((item) => item.value == values.rotationMode)
        ? values.rotationMode
        : items.first.value;
    final theme = BlenderTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              'Mode',
              textAlign: TextAlign.right,
              style: theme.textTheme.label,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: BlenderDropdown<String>(
              value: mode,
              items: items,
              onChanged: onRotationModeChanged,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final rotationLabels =
        values.rotationMode == 'Quaternion' ||
            values.rotationMode == 'Axis Angle'
        ? const <String>['Rotation W', 'X', 'Y', 'Z']
        : const <String>['Rotation X', 'Y', 'Z'];
    return BlenderBox(
      padding: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (values.hasShear)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: <Widget>[
                  const BlenderIcon(BlenderGlyph.warningFilled, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Matrix has a shear',
                    style: theme.textTheme.label.copyWith(
                      color: theme.colors.warning,
                    ),
                  ),
                ],
              ),
            ),
          for (var index = 0; index < 3; index++)
            _valueRow(
              context,
              index == 0 ? 'Location X' : const <String>['Y', 'Z'][index - 1],
              values.location.length > index ? values.location[index] : 0,
            ),
          for (var index = 0; index < rotationLabels.length; index++)
            _valueRow(
              context,
              rotationLabels[index],
              values.rotation.length > index ? values.rotation[index] : 0,
            ),
          _rotationModeRow(context),
          for (var index = 0; index < 3; index++)
            _valueRow(
              context,
              index == 0 ? 'Scale X' : const <String>['Y', 'Z'][index - 1],
              values.scale.length > index ? values.scale[index] : 0,
            ),
        ],
      ),
    );
  }
}

class BlenderIconLabel extends StatelessWidget {
  const BlenderIconLabel({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  final String label;
  final BlenderGlyph? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          BlenderIcon(icon!, size: 14, color: color),
          const SizedBox(width: 4),
        ],
        Text(label, style: theme.textTheme.label),
      ],
    );
  }
}

class BlenderLinkLabel extends StatelessWidget {
  const BlenderLinkLabel({
    super.key,
    required this.label,
    this.onPressed,
    this.pointer = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool pointer;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BlenderIcon(
          pointer ? BlenderGlyph.pointer : BlenderGlyph.link,
          size: 13,
          color: theme.colors.link,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.label.copyWith(color: theme.colors.link),
        ),
      ],
    );
    return onPressed == null
        ? child
        : GestureDetector(onTap: onPressed, child: child);
  }
}

class BlenderOperatorButton extends StatelessWidget {
  const BlenderOperatorButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.enabled = true,
    this.variant = BlenderButtonVariant.regular,
  });

  final String label;
  final BlenderGlyph? icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final BlenderButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return BlenderButton(
      label: label,
      leading: icon == null ? null : BlenderIcon(icon!, size: 14),
      onPressed: onPressed,
      enabled: enabled,
      variant: variant,
    );
  }
}

class BlenderUnitVector extends StatefulWidget {
  const BlenderUnitVector({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 72,
  });

  final Offset value;
  final ValueChanged<Offset> onChanged;
  final double size;

  @override
  State<BlenderUnitVector> createState() => _BlenderUnitVectorState();
}

class _BlenderUnitVectorState extends State<BlenderUnitVector> {
  void _update(Offset local) {
    final x = (local.dx / widget.size * 2 - 1).clamp(-1, 1).toDouble();
    final y = (1 - local.dy / widget.size * 2).clamp(-1, 1).toDouble();
    widget.onChanged(Offset(x, y));
  }

  @override
  Widget build(BuildContext context) {
    final colors = BlenderTheme.of(context).colors;
    return GestureDetector(
      onTapDown: (details) => _update(details.localPosition),
      onPanUpdate: (details) => _update(details.localPosition),
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _BlenderUnitVectorPainter(value: widget.value, colors: colors),
      ),
    );
  }
}

class _BlenderUnitVectorPainter extends CustomPainter {
  _BlenderUnitVectorPainter({required this.value, required this.colors});

  final Offset value;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 3;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = colors.textField
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = colors.borderSubtle
        ..style = PaintingStyle.stroke,
    );
    final axis = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      axis,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      axis,
    );
    final point = Offset(
      center.dx + value.dx.clamp(-1, 1) * radius,
      center.dy - value.dy.clamp(-1, 1) * radius,
    );
    canvas.drawCircle(point, 5, Paint()..color = colors.accent);
    canvas.drawCircle(
      point,
      5,
      Paint()
        ..color = colors.foreground
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_BlenderUnitVectorPainter oldDelegate) {
    return value != oldDelegate.value || colors != oldDelegate.colors;
  }
}

enum BlenderNoticeLevel { info, success, warning, error }

class BlenderNoticeBanner extends StatelessWidget {
  const BlenderNoticeBanner({
    super.key,
    required this.message,
    this.level = BlenderNoticeLevel.info,
    this.onDismiss,
  });

  final String message;
  final BlenderNoticeLevel level;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final color = switch (level) {
      BlenderNoticeLevel.info => theme.colors.info,
      BlenderNoticeLevel.success => theme.colors.success,
      BlenderNoticeLevel.warning => theme.colors.warning,
      BlenderNoticeLevel.error => theme.colors.error,
    };
    final glyph = switch (level) {
      BlenderNoticeLevel.info => BlenderGlyph.info,
      BlenderNoticeLevel.success => BlenderGlyph.checkCircle,
      BlenderNoticeLevel.warning => BlenderGlyph.warning,
      BlenderNoticeLevel.error => BlenderGlyph.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .24),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: <Widget>[
          BlenderIcon(glyph, size: 14, color: color),
          const SizedBox(width: 5),
          Expanded(child: Text(message, style: theme.textTheme.caption)),
          if (onDismiss != null)
            BlenderIconButton(
              glyph: BlenderGlyph.close,
              onPressed: onDismiss,
              size: 20,
              tooltip: 'Dismiss',
            ),
        ],
      ),
    );
  }
}

/// A path/name field with Blender's trailing browse affordance.
class BlenderPathField extends StatelessWidget {
  const BlenderPathField({
    super.key,
    required this.controller,
    this.onBrowse,
    this.placeholder = 'Path',
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback? onBrowse;
  final String placeholder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: BlenderTextField(
            controller: controller,
            placeholder: placeholder,
            enabled: enabled,
          ),
        ),
        const SizedBox(width: 4),
        BlenderIconButton(
          glyph: BlenderGlyph.folder,
          onPressed: enabled ? onBrowse : null,
          tooltip: 'Browse',
          size: 22,
        ),
      ],
    );
  }
}

class BlenderPreviewTile extends StatelessWidget {
  const BlenderPreviewTile({
    super.key,
    required this.label,
    this.preview,
    this.selected = false,
    this.onPressed,
    this.width = 96,
    this.height = 84,
  });

  final String label;
  final Widget? preview;
  final bool selected;
  final VoidCallback? onPressed;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final child = Semantics(
      label: label,
      selected: selected,
      button: onPressed != null,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? theme.colors.selection : theme.colors.surface,
          border: Border.all(
            color: selected
                ? theme.colors.editorOutlineActive
                : theme.colors.editorBorder,
          ),
          borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: <Widget>[
              Expanded(
                child:
                    preview ??
                    ColoredBox(
                      color: theme.colors.buttonPressed,
                      child: Center(
                        child: BlenderIcon(
                          BlenderGlyph.image,
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 3, 4, 3),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return onPressed == null
        ? child
        : GestureDetector(onTap: onPressed, child: child);
  }
}

enum BlenderScopeType { histogram, waveform, vectorscope }

class BlenderScopeSeries {
  const BlenderScopeSeries({required this.color, required this.points});

  final Color color;

  /// Normalized samples in the [0, 1] range.
  ///
  /// Histogram samples use `x` as the bin position and `y` as the bin height.
  /// Waveform samples use `x` as time and `y` as signal level. Vectorscope
  /// samples use `x` and `y` as coordinates around the center of the scope.
  final List<Offset> points;
}

/// A compact waveform, histogram, or vectorscope template for image-oriented
/// editor panels.
class BlenderScopeView extends StatefulWidget {
  const BlenderScopeView({
    super.key,
    required this.type,
    required this.series,
    this.title = 'Scope',
    this.height = 150,
    this.minHeight = 20,
    this.maxHeight = 400,
  });

  final BlenderScopeType type;
  final List<BlenderScopeSeries> series;
  final String title;
  final double height;
  final double minHeight;
  final double maxHeight;

  @override
  State<BlenderScopeView> createState() => _BlenderScopeViewState();
}

class _BlenderScopeViewState extends State<BlenderScopeView> {
  late double _height;

  @override
  void initState() {
    super.initState();
    _height = widget.height.clamp(widget.minHeight, widget.maxHeight);
  }

  @override
  void didUpdateWidget(BlenderScopeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.height != widget.height ||
        oldWidget.minHeight != widget.minHeight ||
        oldWidget.maxHeight != widget.maxHeight) {
      _height = widget.height.clamp(widget.minHeight, widget.maxHeight);
    }
  }

  void _resize(double delta) {
    setState(() {
      _height = (_height + delta).clamp(widget.minHeight, widget.maxHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: widget.title,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: _height,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CustomPaint(
              painter: _BlenderScopePainter(
                type: widget.type,
                series: widget.series,
                colors: theme.colors,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: (details) => _resize(details.delta.dy),
                child: SizedBox(
                  height: 10,
                  child: Center(
                    child: BlenderIcon(
                      BlenderGlyph.grip,
                      size: 10,
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlenderScopePainter extends CustomPainter {
  _BlenderScopePainter({
    required this.type,
    required this.series,
    required this.colors,
  });

  final BlenderScopeType type;
  final List<BlenderScopeSeries> series;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = colors.textField);
    final grid = Paint()
      ..color = colors.borderSubtle.withValues(alpha: .65)
      ..strokeWidth = 1;
    if (type == BlenderScopeType.vectorscope) {
      _paintVectorscope(canvas, size, grid);
    } else {
      _paintRectilinearGrid(canvas, size, grid);
      for (final data in series) {
        final paint = Paint()
          ..color = data.color.withValues(alpha: .7)
          ..strokeWidth = type == BlenderScopeType.histogram ? 2 : 1.5
          ..strokeCap = StrokeCap.round;
        if (type == BlenderScopeType.histogram) {
          for (final point in data.points) {
            final x = point.dx.clamp(0, 1).toDouble() * size.width;
            final height = point.dy.clamp(0, 1).toDouble() * size.height;
            canvas.drawLine(
              Offset(x, size.height),
              Offset(x, size.height - height),
              paint,
            );
          }
        } else {
          canvas.drawPoints(PointMode.points, [
            for (final point in data.points)
              Offset(
                point.dx.clamp(0, 1).toDouble() * size.width,
                (1 - point.dy.clamp(0, 1).toDouble()) * size.height,
              ),
          ], paint);
        }
      }
    }
  }

  void _paintRectilinearGrid(Canvas canvas, Size size, Paint paint) {
    for (var index = 1; index < 4; index++) {
      final x = size.width * index / 4;
      final y = size.height * index / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintVectorscope(Canvas canvas, Size size, Paint grid) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 8;
    canvas.drawCircle(center, radius, grid);
    canvas.drawCircle(center, radius * .5, grid);
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      grid,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      grid,
    );
    for (final data in series) {
      final paint = Paint()
        ..color = data.color.withValues(alpha: .75)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(PointMode.points, [
        for (final point in data.points)
          Offset(
            center.dx + (point.dx.clamp(0, 1).toDouble() * 2 - 1) * radius,
            center.dy + (1 - point.dy.clamp(0, 1).toDouble() * 2) * radius,
          ),
      ], paint);
    }
  }

  @override
  bool shouldRepaint(_BlenderScopePainter oldDelegate) {
    return type != oldDelegate.type ||
        series != oldDelegate.series ||
        colors != oldDelegate.colors;
  }
}

class BlenderRecentFile {
  const BlenderRecentFile({
    required this.id,
    required this.name,
    required this.path,
    this.detail,
    this.isBackup = false,
  });

  final String id;
  final String name;
  final String path;
  final String? detail;
  final bool isBackup;
}

/// A compact recent-file template used by Blender's file and splash menus.
class BlenderRecentFiles extends StatelessWidget {
  const BlenderRecentFiles({
    super.key,
    required this.files,
    this.onSelected,
    this.onClear,
    this.title = 'Recent Files',
  });

  final List<BlenderRecentFile> files;
  final ValueChanged<BlenderRecentFile>? onSelected;
  final VoidCallback? onClear;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      headerActions: onClear == null
          ? null
          : <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.deleteIcon,
                onPressed: onClear,
                tooltip: 'Clear recent files',
                size: 22,
              ),
            ],
      padding: EdgeInsets.zero,
      child: files.isEmpty
          ? Center(
              child: Text(
                'No recent files',
                style: theme.textTheme.caption.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final isBackup =
                    file.isBackup ||
                    RegExp(r'\.blend\d+$').hasMatch(file.path.toLowerCase());
                final row = GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSelected == null ? null : () => onSelected!(file),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: <Widget>[
                        BlenderIcon(
                          isBackup
                              ? BlenderGlyph.fileBackup
                              : BlenderGlyph.fileBlend,
                          size: 16,
                          color: theme.colors.iconFolder,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            file.name,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                final tooltip = file.detail == null
                    ? file.path
                    : '${file.path}\n${file.detail}';
                return BlenderTooltip(message: tooltip, child: row);
              },
            ),
    );
  }
}

/// A compact running-job row matching Blender's status and progress template.
class BlenderJobProgress extends StatelessWidget {
  const BlenderJobProgress({
    super.key,
    required this.name,
    required this.progress,
    this.icon = BlenderGlyph.refresh,
    this.onCancel,
    this.cancelLabel = 'Stop this job',
    this.active = true,
    this.onIconPressed,
    this.iconTooltip,
    this.remainingTime,
    this.elapsedTime,
    this.statusLabel,
  });

  final String name;
  final double progress;
  final BlenderGlyph icon;
  final VoidCallback? onCancel;
  final String cancelLabel;
  final bool active;
  final VoidCallback? onIconPressed;
  final String? iconTooltip;
  final String? remainingTime;
  final String? elapsedTime;
  final String? statusLabel;

  String? get _progressTooltip {
    if (remainingTime == null && elapsedTime == null) return null;
    return 'Time Remaining: ${remainingTime ?? 'Unknown'}\n'
        'Time Elapsed: ${elapsedTime ?? 'Unknown'}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final clampedProgress = progress.clamp(0, 1).toDouble();
    final status =
        statusLabel ??
        (active ? '${(clampedProgress * 100).round()}%' : 'Canceling...');
    Widget jobIcon = BlenderIcon(
      icon,
      size: 14,
      color: theme.colors.foregroundMuted,
    );
    if (onIconPressed != null) {
      jobIcon = BlenderIconButton(
        glyph: icon,
        onPressed: onIconPressed,
        tooltip: iconTooltip,
        size: 22,
        iconSize: 14,
      );
    }
    Widget progressBar = SizedBox(
      width: 92,
      child: BlenderProgressBar(
        value: clampedProgress,
        label: status,
        height: 16,
      ),
    );
    final tooltip = _progressTooltip;
    if (tooltip != null) {
      progressBar = BlenderTooltip(message: tooltip, child: progressBar);
    }
    return Semantics(
      label: name,
      value: status,
      child: Row(
        children: <Widget>[
          jobIcon,
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              active ? name : statusLabel ?? 'Canceling...',
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.label,
            ),
          ),
          const SizedBox(width: 6),
          progressBar,
          if (onCancel != null) ...<Widget>[
            const SizedBox(width: 2),
            BlenderIconButton(
              glyph: BlenderGlyph.close,
              onPressed: active ? onCancel : null,
              tooltip: cancelLabel,
              size: 22,
            ),
          ],
        ],
      ),
    );
  }
}

/// The complete running-jobs strip used by Blender headers and status areas.
///
/// Blender's native template can also expose animation playback and remote
/// asset downloads next to the ordinary job row. [service] binds the panel to
/// the reusable job model while [jobs] remains available for custom visual
/// compositions and backwards compatibility.
class BlenderRunningJobsPanel extends StatelessWidget {
  const BlenderRunningJobsPanel({
    super.key,
    this.jobs = const <BlenderJobProgress>[],
    this.service,
    this.onStopAnimation,
    this.animationLabel = 'Anim Player',
    this.assetDownloadProgress,
    this.onCancelAssetDownloads,
    this.assetDownloadsLabel = 'Downloading Assets',
  });

  final List<BlenderJobProgress> jobs;
  final BlenderJobService? service;
  final VoidCallback? onStopAnimation;
  final String animationLabel;
  final double? assetDownloadProgress;
  final VoidCallback? onCancelAssetDownloads;
  final String assetDownloadsLabel;

  @override
  Widget build(BuildContext context) {
    final service = this.service;
    if (service != null) {
      return AnimatedBuilder(
        animation: service,
        builder: (context, _) => _build(context, <BlenderJobProgress>[
          for (final job in service.jobs) _jobProgress(service, job),
        ]),
      );
    }
    return _build(context, jobs);
  }

  BlenderJobProgress _jobProgress(BlenderJobService service, BlenderJob job) {
    final (active, status) = switch (job.state) {
      BlenderJobState.running => (true, null),
      BlenderJobState.cancelRequested => (false, 'Canceling...'),
      BlenderJobState.completed => (true, '100%'),
      BlenderJobState.failed => (false, 'Failed'),
    };
    return BlenderJobProgress(
      name: job.name,
      progress: job.progress,
      active: active,
      statusLabel: status,
      remainingTime: job.remainingTime,
      elapsedTime: job.elapsedTime,
      onCancel: job.canCancel ? () => unawaited(service.cancel(job.id)) : null,
    );
  }

  Widget _build(BuildContext context, List<BlenderJobProgress> visibleJobs) {
    final theme = BlenderTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < visibleJobs.length; index++) ...<Widget>[
          if (index > 0) const SizedBox(height: 2),
          visibleJobs[index],
        ],
        if (onStopAnimation != null) ...<Widget>[
          if (visibleJobs.isNotEmpty) const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: BlenderButton(
              label: animationLabel,
              onPressed: onStopAnimation,
              leading: BlenderIcon(
                BlenderGlyph.errorFilled,
                size: 14,
                color: theme.colors.foregroundMuted,
              ),
              width: 92,
            ),
          ),
        ],
        if (assetDownloadProgress != null) ...<Widget>[
          if (visibleJobs.isNotEmpty || onStopAnimation != null)
            const SizedBox(height: 4),
          Text(assetDownloadsLabel, style: theme.textTheme.label),
          const SizedBox(height: 2),
          Row(
            children: <Widget>[
              BlenderIcon(
                BlenderGlyph.assetManager,
                size: 14,
                color: theme.colors.foregroundMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: BlenderProgressBar(
                  value: assetDownloadProgress!,
                  label:
                      '${(assetDownloadProgress!.clamp(0, 1) * 100).round()}%',
                  height: 16,
                ),
              ),
              if (onCancelAssetDownloads != null) ...<Widget>[
                const SizedBox(width: 2),
                BlenderIconButton(
                  glyph: BlenderGlyph.close,
                  onPressed: onCancelAssetDownloads,
                  tooltip: 'Cancel all asset downloads',
                  size: 22,
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class BlenderColorRampStop {
  const BlenderColorRampStop({required this.position, required this.color});

  final double position;
  final Color color;

  BlenderColorRampStop copyWith({double? position, Color? color}) {
    return BlenderColorRampStop(
      position: position ?? this.position,
      color: color ?? this.color,
    );
  }
}

/// A compact interactive gradient strip used by color-ramp properties.
class BlenderColorRamp extends StatefulWidget {
  const BlenderColorRamp({
    super.key,
    required this.stops,
    required this.onChanged,
    this.height = 48,
    this.onAdd,
    this.onRemove,
    this.showControls = true,
  });

  final List<BlenderColorRampStop> stops;
  final ValueChanged<List<BlenderColorRampStop>> onChanged;
  final double height;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;
  final bool showControls;

  @override
  State<BlenderColorRamp> createState() => _BlenderColorRampState();
}

class _BlenderColorRampState extends State<BlenderColorRamp> {
  int _selected = 0;

  int get _selectedIndex {
    if (widget.stops.isEmpty) return 0;
    return _selected.clamp(0, widget.stops.length - 1);
  }

  int _nearest(double position) {
    var index = 0;
    var distance = double.infinity;
    for (var i = 0; i < widget.stops.length; i++) {
      final next = (widget.stops[i].position - position).abs();
      if (next < distance) {
        distance = next;
        index = i;
      }
    }
    return index;
  }

  void _selectAt(Offset local, double width) {
    if (widget.stops.isEmpty) return;
    setState(() => _selected = _nearest((local.dx / width).clamp(0, 1)));
  }

  void _updateSelected(double position) {
    if (widget.stops.isEmpty) return;
    final next = widget.stops.toList();
    next[_selectedIndex] = next[_selectedIndex].copyWith(
      position: position.clamp(0, 1),
    );
    widget.onChanged(next);
  }

  @override
  void didUpdateWidget(covariant BlenderColorRamp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stops.isEmpty) {
      _selected = 0;
    } else {
      _selected = _selected.clamp(0, widget.stops.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LayoutBuilder(
          builder: (context, constraints) {
            final width = math.max(1.0, constraints.maxWidth);
            return GestureDetector(
              onTapDown: (details) => _selectAt(details.localPosition, width),
              onPanStart: (details) => _selectAt(details.localPosition, width),
              onPanUpdate: (details) =>
                  _updateSelected(details.localPosition.dx / width),
              child: SizedBox(
                height: widget.height,
                child: CustomPaint(
                  painter: _BlenderColorRampPainter(
                    stops: widget.stops,
                    selected: _selectedIndex,
                    colors: theme.colors,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.stops.isNotEmpty)
          Row(
            children: <Widget>[
              Expanded(
                child: BlenderNumberField(
                  value: widget.stops[_selectedIndex].position,
                  min: 0,
                  max: 1,
                  step: .01,
                  decimalDigits: 2,
                  onChanged: _updateSelected,
                ),
              ),
              const SizedBox(width: 4),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.stops[_selectedIndex].color,
                  border: Border.all(color: theme.colors.borderSubtle),
                  borderRadius: BorderRadius.circular(
                    theme.shapes.controlRadius,
                  ),
                ),
                child: const SizedBox(width: 28, height: 22),
              ),
            ],
          ),
        if (widget.showControls)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.plus,
                onPressed: widget.onAdd,
                tooltip: 'Add color stop',
                size: 22,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.minus,
                onPressed: widget.onRemove,
                tooltip: 'Remove color stop',
                size: 22,
              ),
            ],
          ),
      ],
    );
  }
}

class _BlenderColorRampPainter extends CustomPainter {
  _BlenderColorRampPainter({
    required this.stops,
    required this.selected,
    required this.colors,
  });

  final List<BlenderColorRampStop> stops;
  final int selected;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (stops.isEmpty) return;
    final ordered = stops.toList()
      ..sort((a, b) => a.position.compareTo(b.position));
    final rect = Rect.fromLTWH(0, 4, size.width, 24);
    final gradient = LinearGradient(
      colors: [for (final stop in ordered) stop.color],
      stops: [for (final stop in ordered) stop.position.clamp(0, 1)],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
    canvas.drawRect(
      rect,
      Paint()
        ..color = colors.borderSubtle
        ..style = PaintingStyle.stroke,
    );
    for (var index = 0; index < stops.length; index++) {
      final stop = stops[index];
      final x = stop.position.clamp(0, 1) * size.width;
      final path = Path()
        ..moveTo(x - 5, 32)
        ..lineTo(x + 5, 32)
        ..lineTo(x, 25)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = index == selected ? colors.foreground : colors.borderSubtle,
      );
      canvas.drawCircle(
        Offset(x, 36),
        4,
        Paint()
          ..color = stop.color
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderColorRampPainter oldDelegate) {
    return stops != oldDelegate.stops ||
        selected != oldDelegate.selected ||
        colors != oldDelegate.colors;
  }
}

/// A normalized curve editor for falloff, animation, and mapping properties.
class BlenderCurveMapping extends StatefulWidget {
  const BlenderCurveMapping({
    super.key,
    required this.points,
    required this.onChanged,
    this.height = 160,
  });

  final List<Offset> points;
  final ValueChanged<List<Offset>> onChanged;
  final double height;

  @override
  State<BlenderCurveMapping> createState() => _BlenderCurveMappingState();
}

class _BlenderCurveMappingState extends State<BlenderCurveMapping> {
  int _selected = 0;

  int _nearest(Offset point) {
    var index = 0;
    var distance = double.infinity;
    for (var i = 0; i < widget.points.length; i++) {
      final next = (widget.points[i] - point).distance;
      if (next < distance) {
        index = i;
        distance = next;
      }
    }
    return index;
  }

  Offset _normalize(Offset point, Size size) {
    return Offset(
      (point.dx / math.max(1, size.width)).clamp(0, 1),
      (1 - point.dy / math.max(1, size.height)).clamp(0, 1),
    );
  }

  void _move(Offset local, Size size) {
    if (widget.points.isEmpty) return;
    final next = widget.points.toList();
    next[_selected] = _normalize(local, size);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = BlenderTheme.of(context).colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, widget.height);
        return GestureDetector(
          onTapDown: (details) {
            final normalized = _normalize(details.localPosition, size);
            if (widget.points.isNotEmpty) {
              setState(() => _selected = _nearest(normalized));
            }
          },
          onPanUpdate: (details) => _move(details.localPosition, size),
          child: SizedBox(
            height: widget.height,
            child: CustomPaint(
              painter: _BlenderCurveMappingPainter(
                points: widget.points,
                selected: _selected,
                colors: colors,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BlenderCurveMappingPainter extends CustomPainter {
  _BlenderCurveMappingPainter({
    required this.points,
    required this.selected,
    required this.colors,
  });

  final List<Offset> points;
  final int selected;
  final BlenderColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = colors.textField;
    canvas.drawRect(Offset.zero & size, background);
    final grid = Paint()
      ..color = colors.borderSubtle
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    final normalized = [
      for (final point in points)
        Offset(
          point.dx.clamp(0, 1) * size.width,
          (1 - point.dy.clamp(0, 1)) * size.height,
        ),
    ];
    if (normalized.length > 1) {
      final path = Path()..moveTo(normalized.first.dx, normalized.first.dy);
      for (var i = 1; i < normalized.length; i++) {
        path.lineTo(normalized[i].dx, normalized[i].dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = colors.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    for (var i = 0; i < normalized.length; i++) {
      canvas.drawCircle(
        normalized[i],
        i == selected ? 5 : 4,
        Paint()..color = i == selected ? colors.focus : colors.foreground,
      );
    }
  }

  @override
  bool shouldRepaint(_BlenderCurveMappingPainter oldDelegate) {
    return points != oldDelegate.points ||
        selected != oldDelegate.selected ||
        colors != oldDelegate.colors;
  }
}

/// A lightweight scrollbar matching Blender's narrow editor scroll thumb.
class BlenderScrollBar extends StatelessWidget {
  const BlenderScrollBar({
    super.key,
    required this.value,
    required this.viewportFraction,
    required this.onChanged,
    this.vertical = true,
    this.thickness = 10,
  });

  final double value;
  final double viewportFraction;
  final ValueChanged<double> onChanged;
  final bool vertical;
  final double thickness;

  void _setFromOffset(Offset offset, Size size) {
    final extent = vertical ? size.height : size.width;
    final thumb = extent * viewportFraction.clamp(.05, 1);
    final position = vertical ? offset.dy : offset.dx;
    final next = ((position - thumb / 2) / math.max(1, extent - thumb)).clamp(
      0,
      1,
    );
    onChanged(next.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(
          constraints.maxWidth.isFinite ? constraints.maxWidth : thickness,
          constraints.maxHeight.isFinite ? constraints.maxHeight : thickness,
        );
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => _setFromOffset(details.localPosition, size),
          onVerticalDragUpdate: vertical
              ? (details) => _setFromOffset(details.localPosition, size)
              : null,
          onHorizontalDragUpdate: vertical
              ? null
              : (details) => _setFromOffset(details.localPosition, size),
          child: CustomPaint(
            painter: _BlenderScrollBarPainter(
              value: value,
              viewportFraction: viewportFraction,
              vertical: vertical,
              colors: theme.colors,
              thickness: thickness,
            ),
          ),
        );
      },
    );
  }
}

class _BlenderScrollBarPainter extends CustomPainter {
  _BlenderScrollBarPainter({
    required this.value,
    required this.viewportFraction,
    required this.vertical,
    required this.colors,
    required this.thickness,
  });

  final double value;
  final double viewportFraction;
  final bool vertical;
  final BlenderColorScheme colors;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final extent = vertical ? size.height : size.width;
    final thumbExtent = extent * viewportFraction.clamp(.05, 1);
    final offset = (extent - thumbExtent) * value.clamp(0, 1);
    final rect = vertical
        ? Rect.fromLTWH(
            1,
            offset + 1,
            math.max(2, thickness - 2),
            math.max(8, thumbExtent - 2),
          )
        : Rect.fromLTWH(
            offset + 1,
            1,
            math.max(8, thumbExtent - 2),
            math.max(2, thickness - 2),
          );
    canvas.drawRect(
      rect,
      Paint()
        ..color = colors.button
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_BlenderScrollBarPainter oldDelegate) {
    return value != oldDelegate.value ||
        viewportFraction != oldDelegate.viewportFraction ||
        vertical != oldDelegate.vertical ||
        colors != oldDelegate.colors;
  }
}

/// A searchable menu surface for operator, enum, and command pickers.
class BlenderSearchMenu<T> extends StatelessWidget {
  const BlenderSearchMenu({
    super.key,
    required this.controller,
    required this.items,
    required this.onSelected,
    this.title = 'Search',
    this.previewRows = 0,
    this.previewColumns = 0,
    this.previewTileHeight = 84,
  });

  final TextEditingController controller;
  final List<BlenderMenuItem<T>> items;
  final ValueChanged<BlenderMenuItem<T>> onSelected;
  final String title;
  final int previewRows;
  final int previewColumns;
  final double previewTileHeight;

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) {
          final query = value.text.trim().toLowerCase();
          final visible = items
              .where((item) => item.label.toLowerCase().contains(query))
              .toList(growable: false);
          final usePreviewGrid = previewRows > 0 && previewColumns > 0;
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4),
                child: BlenderSearchField(
                  controller: controller,
                  placeholder: 'Search operators',
                ),
              ),
              Expanded(
                child: usePreviewGrid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(5),
                        itemCount: visible.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: previewColumns,
                          mainAxisExtent: previewTileHeight,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          return BlenderPreviewTile(
                            label: item.label,
                            preview: item.icon == null
                                ? null
                                : Center(child: item.icon),
                            width: double.infinity,
                            height: previewTileHeight,
                            onPressed: item.enabled
                                ? () => onSelected(item)
                                : null,
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          return BlenderButton(
                            label: item.label,
                            variant: BlenderButtonVariant.menu,
                            leading: item.icon,
                            trailing: item.shortcut == null
                                ? null
                                : Text(item.shortcut!),
                            enabled: item.enabled,
                            onPressed: item.enabled
                                ? () => onSelected(item)
                                : null,
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class BlenderPieMenuItem<T> {
  const BlenderPieMenuItem({
    required this.value,
    required this.label,
    this.icon,
    this.enabled = true,
  });

  final T value;
  final String label;
  final Widget? icon;
  final bool enabled;
}

/// A reusable radial menu surface for Blender-style pie commands.
class BlenderPieMenu<T> extends StatelessWidget {
  const BlenderPieMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.size = 280,
    this.radius = 92,
  });

  final List<BlenderPieMenuItem<T>> items;
  final ValueChanged<BlenderPieMenuItem<T>> onSelected;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final center = size / 2;
    final angleStep = items.isEmpty ? 0.0 : math.pi * 2 / items.length;
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground.withValues(alpha: .96),
          shape: BoxShape.circle,
          border: Border.all(color: theme.colors.borderSubtle),
        ),
        child: Stack(
          children: <Widget>[
            for (var index = 0; index < items.length; index++)
              Positioned(
                left:
                    center +
                    math.cos(angleStep * index - math.pi / 2) * radius -
                    42,
                top:
                    center +
                    math.sin(angleStep * index - math.pi / 2) * radius -
                    28,
                width: 84,
                height: 56,
                child: _BlenderPieItem<T>(
                  item: items[index],
                  onSelected: onSelected,
                ),
              ),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colors.borderSubtle),
                ),
                child: const SizedBox(width: 44, height: 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlenderPieItem<T> extends StatelessWidget {
  const _BlenderPieItem({required this.item, required this.onSelected});

  final BlenderPieMenuItem<T> item;
  final ValueChanged<BlenderPieMenuItem<T>> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final child = DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.button,
        border: Border.all(color: theme.colors.borderSubtle),
        borderRadius: BorderRadius.circular(theme.shapes.controlRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (item.icon != null) item.icon!,
          Text(
            item.label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.caption.copyWith(
              color: item.enabled
                  ? theme.colors.foreground
                  : theme.colors.foregroundDisabled,
            ),
          ),
        ],
      ),
    );
    return GestureDetector(
      onTap: item.enabled ? () => onSelected(item) : null,
      child: child,
    );
  }
}
