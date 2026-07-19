part of '../controls.dart';

class _BlenderTooltipState extends State<BlenderTooltip> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;
  Timer? _showTimer;

  void _show() {
    if (_entry != null) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;
    final theme = BlenderTheme.of(context);
    _entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: IgnorePointer(
          child: CompositedTransformFollower(
            link: _link,
            targetAnchor: Alignment.bottomLeft,
            followerAnchor: Alignment.topLeft,
            // Keep the tooltip clear of the pointer resting on the control's
            // lower edge. This also matches the breathing room of Blender's
            // native tooltip placement.
            offset: const Offset(0, 10),
            showWhenUnlinked: false,
            child: Align(
              alignment: Alignment.topLeft,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.menuBackground,
                  border: Border.all(color: theme.colors.borderSubtle),
                  borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child:
                      widget.content ??
                      Text(
                        widget.message,
                        style: theme.textTheme.caption.copyWith(
                          color: theme.colors.foreground,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(_entry!);
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  void _scheduleShow() {
    if (_entry != null) return;
    _showTimer?.cancel();
    _showTimer = Timer(widget.showDelay, () {
      _showTimer = null;
      _show();
    });
  }

  void _cancelShow() {
    _showTimer?.cancel();
    _showTimer = null;
  }

  @override
  void dispose() {
    _cancelShow();
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences =
        BlenderServiceScope.maybeRead<BlenderInterfacePreferencesService>(
          context,
        );
    if (preferences == null) return _buildTarget();
    return AnimatedBuilder(
      animation: preferences,
      builder: (context, child) {
        if (!preferences.value.showTooltips) {
          _cancelShow();
          _hide();
          return widget.child;
        }
        return child!;
      },
      child: _buildTarget(),
    );
  }

  Widget _buildTarget() {
    return CompositedTransformTarget(
      link: _link,
      child: Semantics(
        label: widget.message,
        child: MouseRegion(
          onEnter: (_) => _scheduleShow(),
          onExit: (_) {
            _cancelShow();
            _hide();
          },
          child: widget.child,
        ),
      ),
    );
  }
}
