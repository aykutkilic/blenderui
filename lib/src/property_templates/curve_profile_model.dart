part of '../property_templates.dart';

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
