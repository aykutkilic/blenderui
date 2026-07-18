part of '../controls.dart';

/// Shows a centered Blender-style modal surface.
///
/// Blender uses the same popup theme for operator dialogs, confirmation
/// prompts, and property dialogs. Keeping the route creation here means
/// callers do not accidentally fall back to a Material dialog when the
/// package is hosted below a plain [WidgetsApp].
Future<T?> showBlenderDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  String barrierLabel = 'Dismiss dialog',
  BlenderThemeController? themeController,
}) {
  final liveTheme = themeController ?? BlenderThemeScope.maybeOf(context);
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: barrierLabel,
    barrierColor: const Color(0x99000000),
    transitionDuration: const Duration(milliseconds: 120),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      final dialog = SafeArea(child: Center(child: builder(dialogContext)));
      // captureAll preserves other inherited themes and the initial Blender
      // palette. The live scope is applied inside it, where it can repaint a
      // route while Preferences changes the selected theme.
      final liveDialog = liveTheme == null
          ? dialog
          : AnimatedBuilder(
              animation: liveTheme,
              builder: (context, child) {
                final theme = liveTheme.data;
                return BlenderTheme(
                  data: theme,
                  child: DefaultTextStyle(
                    style: theme.textTheme.body.copyWith(
                      color: theme.colors.foreground,
                    ),
                    child: child!,
                  ),
                );
              },
              child: dialog,
            );
      return InheritedTheme.captureAll(context, liveDialog);
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: .96, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// A compact action descriptor for [BlenderDialog].
class BlenderDialogAction {
  const BlenderDialogAction({
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final bool enabled;
}

/// The shared visual shell for centered Blender operator and alert dialogs.
class BlenderDialog extends StatelessWidget {
  const BlenderDialog({
    super.key,
    this.title,
    this.message,
    this.icon,
    this.content,
    this.actions = const <BlenderDialogAction>[],
    this.width = 420,
    this.small = false,
  });

  final String? title;
  final String? message;
  final Widget? icon;
  final Widget? content;
  final List<BlenderDialogAction> actions;
  final double width;
  final bool small;

  Widget _buildActions(BuildContext context, BlenderThemeData theme) {
    Widget buildAction(BlenderDialogAction action) {
      return BlenderButton(
        label: action.label,
        selected: action.primary,
        enabled: action.enabled,
        onPressed: action.enabled ? action.onPressed : null,
      );
    }

    // wm_block_dialog_create() uses a split layout for its Cancel/Confirm
    // pair. Equal columns keep the buttons anchored to both sides of the
    // dialog instead of collapsing them into two small right-aligned pills.
    if (actions.length == 2) {
      return Row(
        children: <Widget>[
          Expanded(child: buildAction(actions[0])),
          SizedBox(width: theme.density.spacing),
          Expanded(child: buildAction(actions[1])),
        ],
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: 6,
        runSpacing: 6,
        children: <Widget>[
          for (final action in actions)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 88),
              child: buildAction(action),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final padding = small ? 7.0 : 14.0;
    final messageLines = message
        ?.trim()
        .split('\n')
        .where((line) => line.isNotEmpty)
        .toList(growable: false);
    final body = <Widget>[
      if (title != null && title!.isNotEmpty)
        Text(title!, style: theme.textTheme.heading),
      if (messageLines != null && messageLines.isNotEmpty) ...<Widget>[
        if (title != null && title!.isNotEmpty) const SizedBox(height: 10),
        for (var index = 0; index < messageLines.length; index++) ...<Widget>[
          if (index > 0) const SizedBox(height: 2),
          Text(
            messageLines[index],
            style: theme.textTheme.body.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ],
      ],
      if (content != null) ...<Widget>[
        if (title != null || (messageLines?.isNotEmpty ?? false))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SizedBox(
              height: 1,
              child: ColoredBox(color: theme.colors.borderSubtle),
            ),
          ),
        content!,
      ],
      if (actions.isNotEmpty) ...<Widget>[
        SizedBox(height: small ? 8 : 14),
        _buildActions(context, theme),
      ],
    ];
    final dialogBody = icon == null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: body,
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 1),
                child: icon,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: body,
                ),
              ),
            ],
          );
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: small ? 280 : 320,
        maxWidth: width,
        maxHeight: MediaQuery.sizeOf(context).height - 28,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x99000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(padding),
          child: dialogBody,
        ),
      ),
    );
  }
}

/// Convenience implementation of Blender's confirmation/alert dialog.
class BlenderAlertDialog extends StatelessWidget {
  const BlenderAlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon = BlenderGlyph.warning,
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.content,
    this.width = 420,
  });

  final String title;
  final String message;
  final BlenderGlyph? icon;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? content;
  final double width;

  void _close(BuildContext context, VoidCallback? callback, bool result) {
    callback?.call();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final iconWidget = icon == null
        ? null
        : BlenderIcon(
            icon!,
            size: 34,
            color: icon == BlenderGlyph.error
                ? theme.colors.error
                : icon == BlenderGlyph.warning
                ? theme.colors.warning
                : theme.colors.info,
          );
    return BlenderDialog(
      title: title,
      message: message,
      icon: iconWidget,
      content: content,
      width: width,
      actions: <BlenderDialogAction>[
        BlenderDialogAction(
          label: cancelLabel,
          onPressed: () => _close(context, onCancel, false),
        ),
        BlenderDialogAction(
          label: confirmLabel,
          primary: true,
          onPressed: () => _close(context, onConfirm, true),
        ),
      ],
    );
  }
}

/// Opens [BlenderAlertDialog] using the package's modal route and theme.
Future<bool?> showBlenderAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  BlenderGlyph? icon = BlenderGlyph.warning,
  String confirmLabel = 'OK',
  String cancelLabel = 'Cancel',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  Widget? content,
  double width = 420,
  bool barrierDismissible = true,
}) {
  return showBlenderDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => BlenderAlertDialog(
      title: title,
      message: message,
      icon: icon,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      content: content,
      width: width,
    ),
  );
}

/// An interactive anchored overlay for Blender-style popovers and inspectors.
class BlenderPopover extends StatefulWidget {
  const BlenderPopover({
    super.key,
    required this.child,
    required this.popover,
    this.offset = const Offset(0, 4),
    this.targetAnchor = Alignment.bottomLeft,
    this.followerAnchor = Alignment.topLeft,
    this.onOpenChanged,
    this.openOnHover = false,
    this.hoverDelay = const Duration(milliseconds: 200),
  });

  final Widget child;
  final Widget Function(BuildContext context, VoidCallback close) popover;
  final Offset offset;
  final Alignment targetAnchor;
  final Alignment followerAnchor;
  final ValueChanged<bool>? onOpenChanged;
  final bool openOnHover;
  final Duration hoverDelay;

  @override
  State<BlenderPopover> createState() => _BlenderPopoverState();
}

class _BlenderPopoverState extends State<BlenderPopover> {
  RenderBox? _targetRenderObject;
  Timer? _hoverTimer;
  bool _open = false;

  Future<void> _show() async {
    if (_open) return;
    _hoverTimer?.cancel();
    final renderObject = _targetRenderObject;
    if (renderObject is! RenderBox) return;
    final origin = renderObject.localToGlobal(Offset.zero);
    setState(() => _open = true);
    widget.onOpenChanged?.call(true);
    await showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss popover',
      barrierColor: const Color(0x00000000),
      transitionDuration: const Duration(milliseconds: 80),
      pageBuilder: (dialogContext, animation, secondaryAnimation) =>
          InheritedTheme.captureAll(
            context,
            Stack(
              children: <Widget>[
                CustomSingleChildLayout(
                  delegate: _BlenderPopoverPositionDelegate(
                    target: Rect.fromLTWH(
                      origin.dx,
                      origin.dy,
                      renderObject.size.width,
                      renderObject.size.height,
                    ),
                    offset: widget.offset,
                    targetAnchor: widget.targetAnchor,
                    followerAnchor: widget.followerAnchor,
                  ),
                  child: widget.popover(
                    dialogContext,
                    () => Navigator.of(dialogContext).pop(),
                  ),
                ),
              ],
            ),
          ),
    );
    if (mounted) {
      setState(() => _open = false);
      widget.onOpenChanged?.call(false);
    }
  }

  void _hide() {
    if (_open) Navigator.of(context).pop();
  }

  void _scheduleHoverShow() {
    if (!widget.openOnHover || _open) return;
    _hoverTimer?.cancel();
    _hoverTimer = Timer(widget.hoverDelay, _show);
  }

  void _cancelHoverShow() {
    _hoverTimer?.cancel();
    _hoverTimer = null;
  }

  @override
  void dispose() {
    _cancelHoverShow();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _BlenderPopoverAnchor(
      onLaidOut: (renderObject) => _targetRenderObject = renderObject,
      child: MouseRegion(
        onEnter: (_) => _scheduleHoverShow(),
        onExit: (_) => _cancelHoverShow(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _open ? _hide : _show,
          child: widget.child,
        ),
      ),
    );
  }
}

class _BlenderPopoverPositionDelegate extends SingleChildLayoutDelegate {
  const _BlenderPopoverPositionDelegate({
    required this.target,
    required this.offset,
    required this.targetAnchor,
    required this.followerAnchor,
  });

  final Rect target;
  final Offset offset;
  final Alignment targetAnchor;
  final Alignment followerAnchor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return constraints.loosen().copyWith(
      maxWidth: math.max(0, constraints.maxWidth - 8),
      maxHeight: math.max(0, constraints.maxHeight - 8),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final targetPoint = Offset(
      target.left + target.width * (targetAnchor.x + 1) / 2,
      target.top + target.height * (targetAnchor.y + 1) / 2,
    );
    final followerOffset = Offset(
      childSize.width * (followerAnchor.x + 1) / 2,
      childSize.height * (followerAnchor.y + 1) / 2,
    );
    final desired = targetPoint + offset - followerOffset;
    return Offset(
      desired.dx.clamp(4, math.max(4, size.width - childSize.width - 4)),
      desired.dy.clamp(4, math.max(4, size.height - childSize.height - 4)),
    );
  }

  @override
  bool shouldRelayout(_BlenderPopoverPositionDelegate oldDelegate) {
    return target != oldDelegate.target ||
        offset != oldDelegate.offset ||
        targetAnchor != oldDelegate.targetAnchor ||
        followerAnchor != oldDelegate.followerAnchor;
  }
}

class _BlenderPopoverAnchor extends SingleChildRenderObjectWidget {
  const _BlenderPopoverAnchor({required this.onLaidOut, required super.child});

  final ValueChanged<RenderBox> onLaidOut;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _BlenderPopoverAnchorRenderObject(onLaidOut);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _BlenderPopoverAnchorRenderObject renderObject,
  ) {
    renderObject.onLaidOut = onLaidOut;
  }
}

class _BlenderPopoverAnchorRenderObject extends RenderProxyBox {
  _BlenderPopoverAnchorRenderObject(this.onLaidOut);

  ValueChanged<RenderBox> onLaidOut;

  @override
  void performLayout() {
    if (child == null) {
      size = constraints.smallest;
      onLaidOut(this);
      return;
    }
    child!.layout(constraints.loosen(), parentUsesSize: true);
    size = constraints.constrain(child!.size);
    onLaidOut(child!);
  }
}
