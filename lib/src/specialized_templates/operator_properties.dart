part of '../specialized_templates.dart';

/// Blender's operator property rows are shared by redo popups and
/// confirmation dialogs. Keeping the input as the package's property
/// descriptor means operator/RNA state remains caller-owned.
Widget _buildOperatorProperties(
  BuildContext context,
  List<BlenderPropertyDescriptor<dynamic>> properties,
) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      for (final property in properties)
        BlenderPropertyRow(
          label: property.label,
          tooltip: property.tooltip,
          state: property.state,
          labelPlacement: property.effectiveLabelPlacement,
          onKeyframe: property.onKeyframe,
          onReset: property.onReset,
          editor: property.buildEditor(context),
        ),
    ],
  );
}

/// The regular popup used by Blender for the last operator's redo settings.
///
/// Blender presents the operator name, a thin separator, and a compact
/// property column inside a small anchored popup. The popup positioning and
/// undo/repeat behavior belong to the host application; this widget owns the
/// visual anatomy and its disabled state.
class BlenderOperatorRedoPopup extends StatelessWidget {
  const BlenderOperatorRedoPopup({
    super.key,
    required this.title,
    required this.properties,
    this.enabled = true,
    this.width = 240,
  });

  final String title;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final bool enabled;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 180, maxWidth: width),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.menuBackground,
          border: Border.all(color: theme.colors.borderSubtle),
          borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x88000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Opacity(
            opacity: enabled ? 1 : .5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(title, style: theme.textTheme.heading),
                const SizedBox(height: 5),
                SizedBox(
                  height: 1,
                  child: ColoredBox(color: theme.colors.borderSubtle),
                ),
                const SizedBox(height: 6),
                _buildOperatorProperties(context, properties),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The centered operator-properties dialog used when Blender requires an
/// explicit confirmation before execution.
class BlenderOperatorPropertiesDialog extends StatelessWidget {
  const BlenderOperatorPropertiesDialog({
    super.key,
    required this.title,
    required this.properties,
    this.message,
    this.confirmLabel = 'OK',
    this.cancelLabel = 'Cancel',
    this.onConfirm,
    this.onCancel,
    this.showIcon = false,
    this.width = 420,
  });

  final String title;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final String? message;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showIcon;
  final double width;

  void _close(BuildContext context, VoidCallback? callback, bool result) {
    callback?.call();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderDialog(
      title: title,
      message: message,
      icon: showIcon
          ? BlenderIcon(BlenderGlyph.info, size: 34, color: theme.colors.info)
          : null,
      width: width,
      content: _buildOperatorProperties(context, properties),
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

/// Opens [BlenderOperatorPropertiesDialog] with Blender's popup route.
Future<bool?> showBlenderOperatorPropertiesDialog({
  required BuildContext context,
  required String title,
  required List<BlenderPropertyDescriptor<dynamic>> properties,
  String? message,
  String confirmLabel = 'OK',
  String cancelLabel = 'Cancel',
  VoidCallback? onConfirm,
  VoidCallback? onCancel,
  bool showIcon = false,
  double width = 420,
  bool barrierDismissible = true,
}) {
  return showBlenderDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogContext) => BlenderOperatorPropertiesDialog(
      title: title,
      properties: properties,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      onConfirm: onConfirm,
      onCancel: onCancel,
      showIcon: showIcon,
      width: width,
    ),
  );
}
