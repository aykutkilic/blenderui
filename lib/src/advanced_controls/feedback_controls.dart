part of '../advanced_controls.dart';

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
