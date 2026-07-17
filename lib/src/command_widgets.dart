import 'dart:async';

import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'icons.dart';
import 'services.dart';

/// A command-backed menu entry whose visible metadata comes from the registry.
class BlenderCommandMenuEntry {
  const BlenderCommandMenuEntry.command(
    this.commandId, {
    this.icon,
    this.selected = false,
    this.checked = false,
  }) : label = null,
       children = null,
       separator = false;

  const BlenderCommandMenuEntry.submenu({
    required this.label,
    required this.children,
    this.icon,
  }) : commandId = null,
       selected = false,
       checked = false,
       separator = false;

  const BlenderCommandMenuEntry.separator()
    : commandId = null,
      label = null,
      icon = null,
      children = null,
      selected = false,
      checked = false,
      separator = true;

  final String? commandId;
  final String? label;
  final Widget? icon;
  final List<BlenderCommandMenuEntry>? children;
  final bool selected;
  final bool checked;
  final bool separator;
}

BlenderCommandRegistry _commandRegistry(
  BuildContext context,
  BlenderCommandRegistry? provided,
) => provided ?? BlenderServiceScope.read<BlenderCommandRegistry>(context);

BlenderCommand? _resolveCommand(BlenderCommandRegistry registry, String id) {
  final command = registry[id];
  assert(() {
    if (command == null) {
      throw FlutterError(
        'No BlenderCommand with id "$id" is registered. Register commands '
        'before building command-backed controls.',
      );
    }
    return true;
  }());
  return command;
}

/// A button whose label, enabled state, and activation come from one command.
class BlenderCommandButton extends StatelessWidget {
  const BlenderCommandButton({
    super.key,
    required this.commandId,
    this.commands,
    this.glyph,
    this.variant = BlenderButtonVariant.toolbar,
    this.iconSize,
    this.size,
    this.tooltip,
  });

  final String commandId;
  final BlenderCommandRegistry? commands;
  final BlenderGlyph? glyph;
  final BlenderButtonVariant variant;
  final double? iconSize;
  final double? size;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final registry = _commandRegistry(context, commands);
    return AnimatedBuilder(
      animation: registry,
      builder: (context, _) {
        final command = _resolveCommand(registry, commandId);
        final enabled = command?.isEnabled ?? false;
        final onPressed = enabled
            ? () => unawaited(registry.execute(commandId))
            : null;
        if (glyph != null) {
          return BlenderIconButton(
            glyph: glyph!,
            onPressed: onPressed,
            tooltip: tooltip ?? command?.description ?? command?.label,
            iconSize: iconSize ?? 15,
            size: size ?? 28,
          );
        }
        Widget button = BlenderButton(
          label: command?.label ?? commandId,
          onPressed: onPressed,
          enabled: enabled,
          variant: variant,
        );
        final message = tooltip ?? command?.description;
        if (message != null) {
          button = BlenderTooltip(message: message, child: button);
        }
        return button;
      },
    );
  }
}

/// A pulldown whose entries resolve command metadata and execute by command ID.
class BlenderCommandMenuButton extends StatelessWidget {
  const BlenderCommandMenuButton({
    super.key,
    required this.label,
    required this.entries,
    this.commands,
    this.enabled = true,
    this.variant = BlenderButtonVariant.topBar,
  });

  final String label;
  final List<BlenderCommandMenuEntry> entries;
  final BlenderCommandRegistry? commands;
  final bool enabled;
  final BlenderButtonVariant variant;

  List<BlenderMenuItem<String>> _items(
    BlenderCommandRegistry registry,
    List<BlenderCommandMenuEntry> entries,
    String path,
  ) {
    return <BlenderMenuItem<String>>[
      for (var index = 0; index < entries.length; index++)
        _item(registry, entries[index], '$path.$index'),
    ];
  }

  BlenderMenuItem<String> _item(
    BlenderCommandRegistry registry,
    BlenderCommandMenuEntry entry,
    String path,
  ) {
    if (entry.separator) {
      return BlenderMenuItem<String>(
        value: 'separator:$path',
        label: '',
        separator: true,
      );
    }
    final commandId = entry.commandId;
    if (commandId != null) {
      final command = _resolveCommand(registry, commandId);
      return BlenderMenuItem<String>(
        value: commandId,
        label: command?.label ?? commandId,
        icon: entry.icon,
        enabled: command?.isEnabled ?? false,
        selected: entry.selected,
        checked: entry.checked,
        shortcut: command?.shortcut,
      );
    }
    final children = entry.children ?? const <BlenderCommandMenuEntry>[];
    return BlenderMenuItem<String>(
      value: 'submenu:$path',
      label: entry.label ?? '',
      icon: entry.icon,
      enabled: children.isNotEmpty,
      submenu: _items(registry, children, path),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registry = _commandRegistry(context, commands);
    return AnimatedBuilder(
      animation: registry,
      builder: (context, _) => BlenderMenuButton<String>(
        label: label,
        items: _items(registry, entries, label),
        enabled: enabled,
        variant: variant,
        onSelected: (commandId) => unawaited(registry.execute(commandId)),
      ),
    );
  }
}

/// Menu descriptor that stays live against a command registry.
class BlenderCommandMenuDescriptor extends BlenderMenuDescriptor<String> {
  const BlenderCommandMenuDescriptor({
    required super.label,
    required this.entries,
    this.commands,
    super.enabled,
    super.variant,
  }) : super(items: const <BlenderMenuItem<String>>[]);

  final List<BlenderCommandMenuEntry> entries;
  final BlenderCommandRegistry? commands;

  @override
  Widget build() => BlenderCommandMenuButton(
    label: label,
    entries: entries,
    commands: commands,
    enabled: enabled,
    variant: variant,
  );
}
