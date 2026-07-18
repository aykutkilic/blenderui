part of '../layout.dart';

class BlenderScrollView extends StatefulWidget {
  const BlenderScrollView({
    super.key,
    required this.child,
    this.controller,
    this.axis = Axis.vertical,
  });

  final Widget child;
  final ScrollController? controller;
  final Axis axis;

  @override
  State<BlenderScrollView> createState() => _BlenderScrollViewState();
}

class _BlenderScrollViewState extends State<BlenderScrollView> {
  ScrollController? _internalController;

  ScrollController get _controller =>
      widget.controller ?? (_internalController ??= ScrollController());

  @override
  void didUpdateWidget(covariant BlenderScrollView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller &&
        widget.controller != null) {
      _internalController?.dispose();
      _internalController = null;
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlenderScrollbar(
      controller: _controller,
      child: SingleChildScrollView(
        controller: _controller,
        primary: false,
        scrollDirection: widget.axis,
        child: widget.child,
      ),
    );
  }
}

/// A Blender-style narrow scrollbar with a comfortable invisible drag target.
class BlenderScrollbar extends StatelessWidget {
  const BlenderScrollbar({
    super.key,
    required this.controller,
    required this.child,
    this.thickness = 3,
    this.thumbColor,
  });

  final ScrollController controller;
  final Widget child;
  final double thickness;
  final Color? thumbColor;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return RawScrollbar(
      controller: controller,
      thumbVisibility: true,
      interactive: true,
      thickness: thickness,
      radius: Radius.circular(thickness),
      crossAxisMargin: 1,
      mainAxisMargin: 2,
      minThumbLength: 20,
      thumbColor: thumbColor ?? theme.colors.borderSubtle,
      notificationPredicate: (notification) => notification.depth == 0,
      child: child,
    );
  }
}
