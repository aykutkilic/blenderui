import 'package:flutter/foundation.dart';

import 'command_widgets.dart';
import 'layout.dart';
import 'services.dart';

@immutable
class BlenderEditorOverlaySettings {
  const BlenderEditorOverlaySettings({
    this.enabled = true,
    this.grid = true,
    this.axes = true,
    this.outlineSelected = true,
  });

  final bool enabled;
  final bool grid;
  final bool axes;
  final bool outlineSelected;
}

@immutable
class BlenderEditorSnappingSettings {
  const BlenderEditorSnappingSettings({
    this.enabled = false,
    this.increment = true,
    this.vertex = false,
    this.edge = false,
    this.face = false,
  });

  final bool enabled;
  final bool increment;
  final bool vertex;
  final bool edge;
  final bool face;
}

@immutable
class BlenderEditorGizmoSettings {
  const BlenderEditorGizmoSettings({
    this.enabled = true,
    this.navigate = true,
    this.move = true,
    this.rotate = true,
    this.scale = true,
  });

  final bool enabled;
  final bool navigate;
  final bool move;
  final bool rotate;
  final bool scale;
}

@immutable
class BlenderEditorFilterSettings {
  const BlenderEditorFilterSettings({
    this.onlySelected = false,
    this.showHidden = false,
    this.search = '',
  });

  final bool onlySelected;
  final bool showHidden;
  final String search;
}

@immutable
class BlenderEditorPlaybackSettings {
  const BlenderEditorPlaybackSettings({
    this.sync = false,
    this.audio = true,
    this.loop = true,
  });

  final bool sync;
  final bool audio;
  final bool loop;
}

@immutable
class BlenderEditorChromeState {
  const BlenderEditorChromeState({
    this.overlay = const BlenderEditorOverlaySettings(),
    this.snapping = const BlenderEditorSnappingSettings(),
    this.gizmo = const BlenderEditorGizmoSettings(),
    this.filter = const BlenderEditorFilterSettings(),
    this.playback = const BlenderEditorPlaybackSettings(),
  });

  final BlenderEditorOverlaySettings overlay;
  final BlenderEditorSnappingSettings snapping;
  final BlenderEditorGizmoSettings gizmo;
  final BlenderEditorFilterSettings filter;
  final BlenderEditorPlaybackSettings playback;
}

@immutable
class BlenderEditorChromeCommand {
  const BlenderEditorChromeCommand(this.id, this.label, {this.shortcut});

  final String id;
  final String label;
  final String? shortcut;
}

@immutable
class BlenderEditorHeaderPreset {
  const BlenderEditorHeaderPreset({
    required this.editorType,
    required this.menus,
  });

  factory BlenderEditorHeaderPreset.forType(BlenderEditorType type) {
    List<String> labels;
    switch (type) {
      case BlenderEditorType.view3d:
        labels = const <String>['View', 'Select', 'Add', 'Object'];
      case BlenderEditorType.imageEditor:
      case BlenderEditorType.uvEditor:
        labels = const <String>['View', 'Select', 'Image', 'UV'];
      case BlenderEditorType.timeline:
      case BlenderEditorType.dopeSheet:
        labels = const <String>['View', 'Select', 'Marker', 'Key'];
      case BlenderEditorType.graphEditor:
      case BlenderEditorType.drivers:
        labels = const <String>['View', 'Select', 'Marker', 'Channel', 'Key'];
      case BlenderEditorType.nlaEditor:
        labels = const <String>['View', 'Select', 'Marker', 'Add', 'Strip'];
      case BlenderEditorType.sequencer:
      case BlenderEditorType.videoEditing:
        labels = const <String>['View', 'Select', 'Marker', 'Add', 'Strip'];
      case BlenderEditorType.geometryNodeEditor:
      case BlenderEditorType.compositor:
      case BlenderEditorType.shaderEditor:
      case BlenderEditorType.textureNodeEditor:
        labels = const <String>['View', 'Select', 'Add', 'Node'];
      case BlenderEditorType.clipEditor:
        labels = const <String>['View', 'Select', 'Clip', 'Track', 'Solve'];
      default:
        labels = const <String>['View'];
    }
    return BlenderEditorHeaderPreset(
      editorType: type,
      menus: <BlenderEditorHeaderMenu>[
        for (final label in labels)
          BlenderEditorHeaderMenu(
            label: label,
            commands: <BlenderEditorChromeCommand>[
              BlenderEditorChromeCommand(
                '${type.name}.${label.toLowerCase()}.open',
                'Open $label',
              ),
            ],
          ),
      ],
    );
  }

  final BlenderEditorType editorType;
  final List<BlenderEditorHeaderMenu> menus;

  void registerCommands(
    BlenderCommandRegistry registry,
    void Function(String commandId) execute,
  ) {
    for (final menu in menus) {
      for (final command in menu.commands) {
        if (registry[command.id] != null) continue;
        registry.register(
          BlenderCommand(
            id: command.id,
            label: command.label,
            shortcut: command.shortcut,
            execute: () => execute(command.id),
          ),
        );
      }
    }
  }

  List<BlenderCommandMenuDescriptor> menuDescriptors(
    BlenderCommandRegistry registry,
  ) => <BlenderCommandMenuDescriptor>[
    for (final menu in menus)
      BlenderCommandMenuDescriptor(
        label: menu.label,
        commands: registry,
        entries: <BlenderCommandMenuEntry>[
          for (final command in menu.commands)
            BlenderCommandMenuEntry.command(command.id),
        ],
      ),
  ];
}

@immutable
class BlenderEditorHeaderMenu {
  const BlenderEditorHeaderMenu({required this.label, required this.commands});

  final String label;
  final List<BlenderEditorChromeCommand> commands;
}
