part of '../property_templates.dart';

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
