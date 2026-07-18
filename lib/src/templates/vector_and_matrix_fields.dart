part of '../templates.dart';

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
