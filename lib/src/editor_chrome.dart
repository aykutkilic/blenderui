import 'package:flutter/widgets.dart';

import 'command_widgets.dart';
import 'controls.dart';
import 'icons.dart';
import 'layout.dart';
import 'services.dart';

@immutable
class BlenderAnnotationSettings {
  const BlenderAnnotationSettings({
    this.visible = true,
    this.layer = 'Main',
    this.onionSkin = false,
    this.opacity = .5,
  });

  final bool visible;
  final String layer;
  final bool onionSkin;
  final double opacity;

  BlenderAnnotationSettings copyWith({
    bool? visible,
    String? layer,
    bool? onionSkin,
    double? opacity,
  }) => BlenderAnnotationSettings(
    visible: visible ?? this.visible,
    layer: layer ?? this.layer,
    onionSkin: onionSkin ?? this.onionSkin,
    opacity: opacity ?? this.opacity,
  );
}

/// Shared source-shaped Annotation region used by editor sidebars.
class BlenderAnnotationSettingsPanel extends StatelessWidget {
  const BlenderAnnotationSettingsPanel({
    super.key,
    this.state = const BlenderAnnotationSettings(),
    this.layers = const <String>['Main', 'Notes'],
    this.onChanged,
    this.title = 'Annotation',
    this.expanded = false,
  });

  final BlenderAnnotationSettings state;
  final List<String> layers;
  final ValueChanged<BlenderAnnotationSettings>? onChanged;
  final String title;
  final bool expanded;

  void _update(BlenderAnnotationSettings value) => onChanged?.call(value);

  @override
  Widget build(BuildContext context) => BlenderPanel(
    title: title,
    collapsible: true,
    initiallyExpanded: expanded,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        BlenderCheckbox(
          value: state.visible,
          label: 'Show Annotation',
          onChanged: (value) => _update(state.copyWith(visible: value)),
        ),
        const SizedBox(height: 4),
        BlenderDropdown<String>(
          value: state.layer,
          items: <BlenderMenuItem<String>>[
            for (final layer in layers)
              BlenderMenuItem<String>(value: layer, label: layer),
          ],
          onChanged: (value) => _update(state.copyWith(layer: value)),
        ),
        const SizedBox(height: 4),
        BlenderCheckbox(
          value: state.onionSkin,
          label: 'Onion Skin',
          onChanged: (value) => _update(state.copyWith(onionSkin: value)),
        ),
        if (state.onionSkin) ...<Widget>[
          const SizedBox(height: 4),
          BlenderNumberField(
            value: state.opacity,
            label: 'Opacity',
            min: 0,
            max: 1,
            step: .05,
            onChanged: (value) => _update(state.copyWith(opacity: value)),
          ),
        ],
      ],
    ),
  );
}

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

/// Builds the compact menu descriptors shared by editor headers.
///
/// Applications provide the current menu labels and entries because command
/// execution remains host-owned. Keeping the descriptor construction here
/// prevents each application shell from recreating Blender's fallback menu
/// anatomy and selection wiring.
abstract final class BlenderEditorMenuCatalog {
  static List<BlenderMenuDescriptor<String>> build(
    List<String> labels, {
    Map<String, List<String>> menuItems = const <String, List<String>>{},
    Map<String, List<BlenderMenuItem<String>>> menuDescriptors =
        const <String, List<BlenderMenuItem<String>>>{},
    Map<String, Key> menuKeys = const <String, Key>{},
    ValueChanged<String>? onSelected,
  }) => <BlenderMenuDescriptor<String>>[
    for (final label in labels)
      BlenderMenuDescriptor<String>(
        key: menuKeys[label],
        label: label,
        items:
            menuDescriptors[label] ??
            <BlenderMenuItem<String>>[
              for (final item in menuItems[label] ?? <String>['$label Options'])
                BlenderMenuItem<String>(value: item, label: item),
            ],
        onSelected: onSelected,
      ),
  ];
}

/// Source-shaped header shared by Blender's utility and data editors.
///
/// Menu anatomy is library-owned. Applications provide editor switching,
/// current Outliner mode, and command execution without recreating the menus.
class BlenderUtilityEditorHeader extends StatelessWidget {
  const BlenderUtilityEditorHeader({
    super.key,
    required this.editorType,
    this.onEditorTypeChanged,
    this.onCommand,
    this.outlinerDataApi = false,
    this.menuDescriptors,
    this.actions = const <Widget>[
      BlenderIconButton(glyph: BlenderGlyph.more, tooltip: 'Editor options'),
    ],
    this.height = 30,
  });

  final BlenderEditorType editorType;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<String>? onCommand;
  final bool outlinerDataApi;
  final List<BlenderMenuDescriptorWidget>? menuDescriptors;
  final List<Widget> actions;
  final double height;

  @override
  Widget build(BuildContext context) {
    final labels = _labels();
    return BlenderAreaHeader(
      height: height,
      editorType: editorType,
      showEditorLabel: false,
      onEditorTypeChanged: onEditorTypeChanged,
      menuDescriptors:
          menuDescriptors ??
          BlenderEditorMenuCatalog.build(
            labels,
            menuItems: _items(),
            onSelected: onCommand,
          ),
      actions: actions,
    );
  }

  List<String> _labels() => switch (editorType) {
    BlenderEditorType.textEditor => <String>[
      'View',
      'Text',
      'Edit',
      'Select',
      'Format',
      'Templates',
    ],
    BlenderEditorType.pythonConsole => <String>['View', 'Console'],
    BlenderEditorType.infoEditor => <String>['View', 'Info'],
    BlenderEditorType.outliner when outlinerDataApi => <String>['Edit'],
    BlenderEditorType.outliner => <String>[],
    BlenderEditorType.fileBrowser ||
    BlenderEditorType.assetBrowser ||
    BlenderEditorType.spreadsheet => <String>['View', 'Select'],
    BlenderEditorType.project => <String>['View', 'Project'],
    _ => <String>['View'],
  };

  Map<String, List<String>> _items() => <String, List<String>>{
    'View': switch (editorType) {
      BlenderEditorType.textEditor => <String>[
        'Navigation',
        'Zoom In',
        'Zoom Out',
        'Toggle Word Wrap',
        'Toggle Line Numbers',
        'Sidebar',
      ],
      BlenderEditorType.pythonConsole => <String>[
        'Zoom In',
        'Zoom Out',
        'Move to Previous Word',
        'Move to Next Word',
        'Move to Line Begin',
        'Move to Line End',
        'Languages',
        'Area',
      ],
      BlenderEditorType.infoEditor => <String>['Area'],
      BlenderEditorType.outliner => <String>[
        'Toggle Sidebar',
        'Show Region Channels',
        'Show Region HUD',
        'Area',
      ],
      BlenderEditorType.spreadsheet => <String>[
        'Toolbar',
        'Sidebar',
        'Internal Attributes',
        'Area',
      ],
      BlenderEditorType.project => <String>['Sidebar', 'Area'],
      _ => <String>['${editorType.label} View Options'],
    },
    'Text': <String>[
      'New',
      'Open',
      'Reload',
      'Save',
      'Save As',
      'Resolve Conflict',
    ],
    'Edit': editorType == BlenderEditorType.outliner
        ? <String>[
            'Add Selected to Keying Set',
            'Remove Selected from Keying Set',
            'Add Drivers to Selected',
            'Remove Drivers from Selected',
          ]
        : <String>['Undo', 'Redo', 'Cut', 'Copy', 'Paste', 'Find', 'Replace'],
    'Select': <String>['All', 'Line', 'Word', 'Pick Linked'],
    'Format': <String>['Indent', 'Unindent', 'Auto Indent', 'Toggle Comment'],
    'Templates': <String>['Python', 'Open Shading Language', 'Application'],
    'Console': <String>[
      'Clear',
      'Clear Line',
      'Delete Previous Word',
      'Delete Next Word',
      'Copy as Script',
      'Cut',
      'Copy',
      'Paste',
      'Indent',
      'Unindent',
      'Backward in History',
      'Forward in History',
      'Autocomplete',
    ],
    'Info': <String>[
      'Select All',
      'Deselect All',
      'Invert Selection',
      'Toggle Selection',
      'Select Box',
      'Delete',
      'Copy',
    ],
    'Project': <String>['Auto-Save Project', 'Save Project'],
  };
}
