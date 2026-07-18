part of '../templates.dart';

enum BlenderNoticeLevel { info, success, warning, error }

class BlenderNoticeBanner extends StatelessWidget {
  const BlenderNoticeBanner({
    super.key,
    required this.message,
    this.level = BlenderNoticeLevel.info,
    this.onDismiss,
  });

  final String message;
  final BlenderNoticeLevel level;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final color = switch (level) {
      BlenderNoticeLevel.info => theme.colors.info,
      BlenderNoticeLevel.success => theme.colors.success,
      BlenderNoticeLevel.warning => theme.colors.warning,
      BlenderNoticeLevel.error => theme.colors.error,
    };
    final glyph = switch (level) {
      BlenderNoticeLevel.info => BlenderGlyph.info,
      BlenderNoticeLevel.success => BlenderGlyph.checkCircle,
      BlenderNoticeLevel.warning => BlenderGlyph.warning,
      BlenderNoticeLevel.error => BlenderGlyph.error,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .24),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: <Widget>[
          BlenderIcon(glyph, size: 14, color: color),
          const SizedBox(width: 5),
          Expanded(child: Text(message, style: theme.textTheme.caption)),
          if (onDismiss != null)
            BlenderIconButton(
              glyph: BlenderGlyph.close,
              onPressed: onDismiss,
              size: 20,
              tooltip: 'Dismiss',
            ),
        ],
      ),
    );
  }
}

/// A path/name field with Blender's trailing browse affordance.
class BlenderPathField extends StatelessWidget {
  const BlenderPathField({
    super.key,
    required this.controller,
    this.onBrowse,
    this.placeholder = 'Path',
    this.enabled = true,
  });

  final TextEditingController controller;
  final VoidCallback? onBrowse;
  final String placeholder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: BlenderTextField(
            controller: controller,
            placeholder: placeholder,
            enabled: enabled,
          ),
        ),
        const SizedBox(width: 4),
        BlenderIconButton(
          glyph: BlenderGlyph.folder,
          onPressed: enabled ? onBrowse : null,
          tooltip: 'Browse',
          size: 22,
        ),
      ],
    );
  }
}
