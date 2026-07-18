part of '../templates.dart';

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
