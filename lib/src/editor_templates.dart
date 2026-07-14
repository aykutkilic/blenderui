import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'icons.dart';
import 'layout.dart';
import 'templates.dart';
import 'theme.dart';

/// A caller-owned modifier panel descriptor.
@immutable
class BlenderModifierDescriptor {
  const BlenderModifierDescriptor({
    required this.id,
    required this.name,
    required this.child,
    this.icon,
    this.enabled = true,
    this.showViewport = true,
    this.showRender = true,
    this.initiallyExpanded = true,
    this.onToggleEnabled,
    this.onToggleViewport,
    this.onToggleRender,
    this.onMoveUp,
    this.onMoveDown,
    this.onRemove,
  });

  final String id;
  final String name;
  final Widget child;
  final BlenderGlyph? icon;
  final bool enabled;
  final bool showViewport;
  final bool showRender;
  final bool initiallyExpanded;
  final VoidCallback? onToggleEnabled;
  final VoidCallback? onToggleViewport;
  final VoidCallback? onToggleRender;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onRemove;
}

/// A stack of collapsible modifier panels with viewport/render/reorder actions.
class BlenderModifierStack extends StatelessWidget {
  const BlenderModifierStack({
    super.key,
    required this.modifiers,
    this.title = 'Modifiers',
    this.emptyLabel = 'No modifiers',
  });

  final List<BlenderModifierDescriptor> modifiers;
  final String title;
  final String emptyLabel;

  List<Widget> _actions(BlenderModifierDescriptor modifier) {
    return <Widget>[
      if (modifier.icon != null)
        Padding(
          padding: const EdgeInsets.only(right: 2),
          child: BlenderIcon(modifier.icon!, size: 13),
        ),
      if (modifier.onToggleEnabled != null)
        BlenderIconButton(
          glyph: BlenderGlyph.checkCircle,
          selected: modifier.enabled,
          onPressed: modifier.onToggleEnabled,
          tooltip: 'Enable modifier',
          size: 21,
        ),
      if (modifier.onToggleViewport != null)
        BlenderIconButton(
          glyph: BlenderGlyph.eye,
          selected: modifier.showViewport,
          onPressed: modifier.onToggleViewport,
          tooltip: 'Show in viewport',
          size: 21,
        ),
      if (modifier.onToggleRender != null)
        BlenderIconButton(
          glyph: BlenderGlyph.render,
          selected: modifier.showRender,
          onPressed: modifier.onToggleRender,
          tooltip: 'Show in render',
          size: 21,
        ),
      if (modifier.onMoveUp != null)
        BlenderIconButton(
          glyph: BlenderGlyph.stepBack,
          onPressed: modifier.onMoveUp,
          tooltip: 'Move modifier up',
          size: 21,
        ),
      if (modifier.onMoveDown != null)
        BlenderIconButton(
          glyph: BlenderGlyph.stepForward,
          onPressed: modifier.onMoveDown,
          tooltip: 'Move modifier down',
          size: 21,
        ),
      if (modifier.onRemove != null)
        BlenderIconButton(
          glyph: BlenderGlyph.deleteIcon,
          onPressed: modifier.onRemove,
          tooltip: 'Remove modifier',
          size: 21,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      child: modifiers.isEmpty
          ? Text(
              emptyLabel,
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final modifier in modifiers)
                  BlenderPanel(
                    title: modifier.name,
                    collapsible: true,
                    initiallyExpanded: modifier.initiallyExpanded,
                    headerActions: _actions(modifier),
                    child: Opacity(
                      opacity: modifier.enabled ? 1 : .5,
                      child: modifier.child,
                    ),
                  ),
              ],
            ),
    );
  }
}

/// A socket input control descriptor for [BlenderNodeInputs].
@immutable
class BlenderNodeInputDescriptor {
  const BlenderNodeInputDescriptor({
    required this.id,
    required this.label,
    required this.editor,
    this.detail,
    this.linked = false,
    this.enabled = true,
  });

  final String id;
  final String label;
  final Widget editor;
  final String? detail;
  final bool linked;
  final bool enabled;
}

/// A declaration-like grouped node-input panel.
@immutable
class BlenderNodeInputGroup {
  const BlenderNodeInputGroup({
    required this.id,
    required this.title,
    required this.inputs,
    this.initiallyExpanded = true,
    this.active = true,
  });

  final String id;
  final String title;
  final List<BlenderNodeInputDescriptor> inputs;
  final bool initiallyExpanded;
  final bool active;
}

class BlenderNodeInputs extends StatelessWidget {
  const BlenderNodeInputs({
    super.key,
    required this.groups,
    this.title = 'Node Inputs',
  });

  final List<BlenderNodeInputGroup> groups;
  final String title;

  Widget _inputRow(BuildContext context, BlenderNodeInputDescriptor input) {
    final theme = BlenderTheme.of(context);
    if (input.linked) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: <Widget>[
            Expanded(child: Text(input.label, style: theme.textTheme.label)),
            const BlenderLinkLabel(label: 'Linked'),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              input.label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.label.copyWith(
                color: input.enabled
                    ? theme.colors.foreground
                    : theme.colors.foregroundDisabled,
              ),
            ),
          ),
          if (input.detail != null) ...<Widget>[
            Text(
              input.detail!,
              style: theme.textTheme.caption.copyWith(
                color: theme.colors.foregroundMuted,
              ),
            ),
            const SizedBox(width: 4),
          ],
          SizedBox(width: 120, child: input.editor),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final group in groups)
            BlenderPanel(
              title: group.title,
              collapsible: true,
              initiallyExpanded: group.initiallyExpanded,
              child: Opacity(
                opacity: group.active ? 1 : .5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final input in group.inputs) _inputRow(context, input),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
