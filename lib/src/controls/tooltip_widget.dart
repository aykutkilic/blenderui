part of '../controls.dart';

class BlenderTooltip extends StatefulWidget {
  const BlenderTooltip({
    super.key,
    required this.message,
    required this.child,
    this.content,
    this.showDelay = const Duration(milliseconds: 500),
  });

  final String message;
  final Widget child;
  final Widget? content;

  /// Delay before the tooltip appears after the pointer enters the child.
  ///
  /// Blender uses a half-second UI tooltip delay. Keeping this configurable
  /// allows specialised surfaces to opt into a different interaction without
  /// making ordinary controls feel noisy.
  final Duration showDelay;

  @override
  State<BlenderTooltip> createState() => _BlenderTooltipState();
}
