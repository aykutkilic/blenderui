part of '../editors.dart';

class _PropertiesGroupView {
  const _PropertiesGroupView({
    required this.group,
    required this.properties,
    this.children = const <_PropertiesGroupView>[],
  });

  _PropertiesGroupView.fromGroup(BlenderPropertyGroup group)
    : this(
        group: group,
        properties: group.properties,
        children: <_PropertiesGroupView>[
          for (final child in group.children)
            _PropertiesGroupView.fromGroup(child),
        ],
      );

  final BlenderPropertyGroup group;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final List<_PropertiesGroupView> children;
}

class _PropertiesContextCaption extends StatelessWidget {
  const _PropertiesContextCaption({
    required this.title,
    this.leading,
    this.actions,
    this.titleStyle,
    required this.horizontalPadding,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final TextStyle? titleStyle;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return SizedBox(
      height: 38,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 80;
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact
                  ? math.min(horizontalPadding, constraints.maxWidth / 4)
                  : horizontalPadding,
            ),
            child: Row(
              children: <Widget>[
                if (!compact && leading != null) ...<Widget>[
                  leading!,
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle ?? theme.textTheme.body,
                  ),
                ),
                if (!compact) ...?actions,
              ],
            ),
          );
        },
      ),
    );
  }
}
