part of '../templates.dart';

class BlenderIconLabel extends StatelessWidget {
  const BlenderIconLabel({
    super.key,
    required this.label,
    this.icon,
    this.color,
  });

  final String label;
  final BlenderGlyph? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          BlenderIcon(icon!, size: 14, color: color),
          const SizedBox(width: 4),
        ],
        Text(label, style: theme.textTheme.label),
      ],
    );
  }
}

class BlenderLinkLabel extends StatelessWidget {
  const BlenderLinkLabel({
    super.key,
    required this.label,
    this.onPressed,
    this.pointer = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool pointer;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        BlenderIcon(
          pointer ? BlenderGlyph.pointer : BlenderGlyph.link,
          size: 13,
          color: theme.colors.link,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.label.copyWith(color: theme.colors.link),
        ),
      ],
    );
    return onPressed == null
        ? child
        : GestureDetector(onTap: onPressed, child: child);
  }
}

class BlenderOperatorButton extends StatelessWidget {
  const BlenderOperatorButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.enabled = true,
    this.variant = BlenderButtonVariant.regular,
  });

  final String label;
  final BlenderGlyph? icon;
  final VoidCallback? onPressed;
  final bool enabled;
  final BlenderButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    return BlenderButton(
      label: label,
      leading: icon == null ? null : BlenderIcon(icon!, size: 14),
      onPressed: onPressed,
      enabled: enabled,
      variant: variant,
    );
  }
}
