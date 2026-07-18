part of '../specialized_templates.dart';

/// Blender's instanced constraint-panel stack.
class BlenderConstraintStack extends StatelessWidget {
  const BlenderConstraintStack({
    super.key,
    required this.constraints,
    this.title = 'Constraints',
    this.emptyLabel = 'No constraints',
    this.actionSize = 21,
  });

  final List<BlenderConstraintDescriptor> constraints;
  final String title;
  final String emptyLabel;
  final double actionSize;

  @override
  Widget build(BuildContext context) {
    return BlenderActionPanelStack(
      title: title,
      emptyLabel: emptyLabel,
      actionSize: actionSize,
      enableTooltip: 'Enable constraint',
      menuTooltip: 'Constraint options',
      items: <BlenderActionPanelItem>[
        for (final constraint in constraints)
          BlenderActionPanelItem(
            id: constraint.id,
            title: constraint.name,
            child: constraint.child,
            icon: constraint.icon,
            enabled: constraint.enabled,
            initiallyExpanded: constraint.initiallyExpanded,
            onToggleEnabled: constraint.onToggleEnabled,
            onMenu: constraint.onMenu,
            onMoveUp: constraint.onMoveUp,
            onMoveDown: constraint.onMoveDown,
            onRemove: constraint.onRemove,
          ),
      ],
    );
  }
}

/// A caller-owned Grease Pencil shader-effect panel descriptor.
@immutable
class BlenderShaderEffectDescriptor {
  const BlenderShaderEffectDescriptor({
    required this.id,
    required this.name,
    required this.child,
    this.icon = BlenderGlyph.color,
    this.enabled = true,
    this.initiallyExpanded = true,
    this.onToggleEnabled,
    this.onMoveUp,
    this.onMoveDown,
    this.onRemove,
  });

  final String id;
  final String name;
  final Widget child;
  final BlenderGlyph icon;
  final bool enabled;
  final bool initiallyExpanded;
  final VoidCallback? onToggleEnabled;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRemove;
}

/// Blender's instanced shader-effect panel stack.
class BlenderShaderEffectStack extends StatelessWidget {
  const BlenderShaderEffectStack({
    super.key,
    required this.effects,
    this.title = 'Shader Effects',
    this.emptyLabel = 'No shader effects',
  });

  final List<BlenderShaderEffectDescriptor> effects;
  final String title;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return BlenderActionPanelStack(
      title: title,
      emptyLabel: emptyLabel,
      enableTooltip: 'Enable shader effect',
      items: <BlenderActionPanelItem>[
        for (final effect in effects)
          BlenderActionPanelItem(
            id: effect.id,
            title: effect.name,
            child: effect.child,
            icon: effect.icon,
            enabled: effect.enabled,
            initiallyExpanded: effect.initiallyExpanded,
            onToggleEnabled: effect.onToggleEnabled,
            onMoveUp: effect.onMoveUp,
            onMoveDown: effect.onMoveDown,
            onRemove: effect.onRemove,
          ),
      ],
    );
  }
}

/// Common descriptor for Blender stacks whose entries are collapsible panels
/// with enable, menu, move, and remove affordances.
@immutable
class BlenderActionPanelItem {
  const BlenderActionPanelItem({
    required this.id,
    required this.title,
    required this.child,
    this.icon = BlenderGlyph.link,
    this.enabled = true,
    this.initiallyExpanded = true,
    this.onToggleEnabled,
    this.onMenu,
    this.onMoveUp,
    this.onMoveDown,
    this.onRemove,
  });

  final String id;
  final String title;
  final Widget child;
  final BlenderGlyph icon;
  final bool enabled;
  final bool initiallyExpanded;
  final VoidCallback? onToggleEnabled;
  final VoidCallback? onMenu;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRemove;
}

/// Shared rendering engine for constraint-, effect-, and modifier-like stacks.
class BlenderActionPanelStack extends StatelessWidget {
  const BlenderActionPanelStack({
    super.key,
    required this.items,
    this.title,
    this.emptyLabel = 'No items',
    this.actionSize = 21,
    this.enableTooltip = 'Enable item',
    this.menuTooltip = 'Item options',
  });

  final List<BlenderActionPanelItem> items;
  final String? title;
  final String emptyLabel;
  final double actionSize;
  final String enableTooltip;
  final String menuTooltip;

  List<Widget> _actions(BlenderActionPanelItem item) => <Widget>[
    if (item.onToggleEnabled != null)
      BlenderIconButton(
        glyph: BlenderGlyph.eye,
        selected: item.enabled,
        onPressed: item.onToggleEnabled,
        tooltip: enableTooltip,
        size: actionSize,
      ),
    if (item.onMenu != null)
      BlenderIconButton(
        glyph: BlenderGlyph.more,
        onPressed: item.onMenu,
        tooltip: menuTooltip,
        size: actionSize,
      ),
    if (item.onMoveUp != null)
      BlenderIconButton(
        glyph: BlenderGlyph.stepBack,
        onPressed: item.onMoveUp,
        tooltip: 'Move item up',
        size: actionSize,
      ),
    if (item.onMoveDown != null)
      BlenderIconButton(
        glyph: BlenderGlyph.stepForward,
        onPressed: item.onMoveDown,
        tooltip: 'Move item down',
        size: actionSize,
      ),
    if (item.onRemove != null)
      BlenderIconButton(
        glyph: BlenderGlyph.close,
        onPressed: item.onRemove,
        tooltip: 'Remove item',
        size: actionSize,
      ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final content = items.isEmpty
        ? Text(
            emptyLabel,
            style: theme.textTheme.caption.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final item in items)
                BlenderPanel(
                  title: item.title,
                  headerLeading: BlenderIcon(item.icon, size: 14),
                  collapsible: true,
                  initiallyExpanded: item.initiallyExpanded,
                  headerActions: _actions(item),
                  child: Opacity(
                    opacity: item.enabled ? 1 : .5,
                    child: item.child,
                  ),
                ),
            ],
          );
    return title == null
        ? content
        : BlenderPanel(title: title!, child: content);
  }
}
