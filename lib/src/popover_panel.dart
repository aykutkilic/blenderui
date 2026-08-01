import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'icons.dart';
import 'theme.dart';

/// Standard constrained panel content for use inside any popover trigger.
class BlenderPopoverPanel extends StatefulWidget {
  const BlenderPopoverPanel({
    super.key,
    required this.title,
    required this.child,
    this.width = 280,
    this.maxHeight = 520,
    this.padding = const EdgeInsets.all(8),
  });

  /// Standard vertical settings content used by editor-header popovers.
  factory BlenderPopoverPanel.settings(
    String title,
    List<Widget> children, {
    Key? key,
    double width = 280,
    double maxHeight = 520,
  }) => BlenderPopoverPanel(
    key: key,
    title: title,
    width: width,
    maxHeight: maxHeight,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );

  final String title;
  final Widget child;
  final double width;
  final double maxHeight;
  final EdgeInsets padding;

  @override
  State<BlenderPopoverPanel> createState() => _BlenderPopoverPanelState();
}

class _BlenderPopoverPanelState extends State<BlenderPopoverPanel> {
  static const double _pointerHeight = 8;
  final ScrollController _scrollController = ScrollController();
  bool _canScrollUp = false;
  bool _canScrollDown = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollIndicators);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollIndicators();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateScrollIndicators)
      ..dispose();
    super.dispose();
  }

  void _updateScrollIndicators() {
    if (!_scrollController.hasClients || !mounted) return;
    final position = _scrollController.position;
    final canScrollUp = position.pixels > position.minScrollExtent;
    final canScrollDown = position.pixels < position.maxScrollExtent;
    if (canScrollUp == _canScrollUp && canScrollDown == _canScrollDown) return;
    setState(() {
      _canScrollUp = canScrollUp;
      _canScrollDown = canScrollDown;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final maxBodyHeight = math
        .max(0, widget.maxHeight - 30 - widget.padding.vertical)
        .toDouble();
    return SizedBox(
      width: widget.width,
      child: Padding(
        padding: const EdgeInsets.only(top: _pointerHeight),
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            DecoratedBox(
              key: const ValueKey<String>('blender-popover-panel-surface'),
              decoration: BoxDecoration(
                color: theme.colors.menuBackground,
                borderRadius: BorderRadius.circular(5),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: widget.padding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        widget.title,
                        style: theme.textTheme.body.copyWith(
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxBodyHeight),
                      child: Stack(
                        children: <Widget>[
                          ListView(
                            controller: _scrollController,
                            primary: false,
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            children: <Widget>[widget.child],
                          ),
                          if (_canScrollUp)
                            const Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: Center(
                                  child: BlenderIcon(
                                    BlenderGlyph.chevronUp,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          if (_canScrollDown)
                            const Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: IgnorePointer(
                                child: Center(
                                  child: BlenderIcon(
                                    BlenderGlyph.chevronDown,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -_pointerHeight,
              left: (widget.width - 16) / 2,
              child: _PopoverPointer(
                color: theme.colors.menuBackground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopoverPointer extends StatelessWidget {
  const _PopoverPointer({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(16, 8),
    painter: _PopoverPointerPainter(color: color),
  );
}

class _PopoverPointerPainter extends CustomPainter {
  const _PopoverPointerPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(_PopoverPointerPainter oldDelegate) =>
      oldDelegate.color != color;
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
  Alignment targetAnchor = Alignment.bottomCenter,
  Alignment followerAnchor = Alignment.topCenter,
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
