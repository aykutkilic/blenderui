import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'layout.dart';

/// Standard constrained panel content for use inside any popover trigger.
class BlenderPopoverPanel extends StatelessWidget {
  const BlenderPopoverPanel({
    super.key,
    required this.title,
    required this.child,
    this.width = 280,
    this.maxHeight = 520,
    this.padding = const EdgeInsets.all(8),
  });

  final String title;
  final Widget child;
  final double width;
  final double maxHeight;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: BlenderPanel(
        title: title,
        initiallyExpanded: true,
        padding: padding,
        child: SingleChildScrollView(child: child),
      ),
    ),
  );
}

/// Composes the existing popover and panel primitives with safe constraints.
BlenderPopover blenderPanelPopover({
  Key? key,
  required Widget child,
  required String title,
  required Widget content,
  double width = 280,
  double maxHeight = 520,
  EdgeInsets padding = const EdgeInsets.all(8),
  Offset offset = const Offset(0, 4),
  Alignment targetAnchor = Alignment.bottomLeft,
  Alignment followerAnchor = Alignment.topLeft,
  ValueChanged<bool>? onOpenChanged,
}) {
  return BlenderPopover(
    key: key,
    child: child,
    offset: offset,
    targetAnchor: targetAnchor,
    followerAnchor: followerAnchor,
    onOpenChanged: onOpenChanged,
    popover: (context, close) => BlenderPopoverPanel(
      title: title,
      width: width,
      maxHeight: maxHeight,
      padding: padding,
      child: content,
    ),
  );
}
