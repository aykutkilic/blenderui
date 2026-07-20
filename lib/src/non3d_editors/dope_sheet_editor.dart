part of '../non3d_editors.dart';

/// A Dope Sheet surface using the timeline model but with an editor-specific
/// title and dense channel layout.
class BlenderDopeSheetEditor extends StatelessWidget {
  const BlenderDopeSheetEditor({
    super.key,
    required this.model,
    required this.onCurrentFrameChanged,
    this.sidebar,
    this.sidebarWidth = 240,
    this.title,
  });

  final BlenderTimelineModel model;
  final ValueChanged<double> onCurrentFrameChanged;
  final Widget? sidebar;
  final double sidebarWidth;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final timeline = BlenderTimeline(
      model: model,
      onCurrentFrameChanged: onCurrentFrameChanged,
      title: title,
    );
    final resolvedSidebar = sidebar ?? const BlenderDopeSheetSidebar();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(child: timeline),
        SizedBox(width: sidebarWidth, child: resolvedSidebar),
      ],
    );
  }
}

/// Source-shaped Dope Sheet/Action sidebar panels from `space_dopesheet.py`.
///
/// Action datablocks, slots, keyframe operations, and shape-key state remain
/// caller-owned; this widget provides the visual panel hierarchy only.
class BlenderDopeSheetSidebar extends StatelessWidget {
  const BlenderDopeSheetSidebar({super.key, this.shapeKeyMode = false});

  final bool shapeKeyMode;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(6),
      children: <Widget>[
        BlenderStaticPropertyField.panel('Action', <Widget>[
          BlenderStaticPropertyField.menu(
            'Active Action',
            'CubeAction',
            <String>['CubeAction', 'IdleAction'],
          ),
          BlenderStaticPropertyField.checkbox('Use Frame Range', value: false),
          BlenderStaticPropertyField.number('Start', 1),
          BlenderStaticPropertyField.number('End', 120),
          BlenderStaticPropertyField.checkbox('Cyclic', value: false),
          BlenderStaticPropertyField.panel('Slot', <Widget>[
            BlenderStaticPropertyField.menu('Name', 'Object', <String>[
              'Object',
              'Camera',
            ]),
            BlenderStaticPropertyField.menu('Type', 'Object', <String>[
              'Object',
              'Armature',
            ]),
          ]),
          BlenderStaticPropertyField.panel('Custom Properties', <Widget>[
            BlenderStaticPropertyField.number('example_value', 1),
          ]),
        ], expanded: true),
        BlenderStaticPropertyField.panel('View', <Widget>[
          BlenderStaticPropertyField.checkbox('Scene Range'),
          BlenderStaticPropertyField.checkbox('Markers'),
          BlenderStaticPropertyField.checkbox('Seconds'),
          BlenderStaticPropertyField.checkbox('Show Region', value: false),
        ], expanded: true),
        if (shapeKeyMode)
          BlenderStaticPropertyField.panel('Shape Key', <Widget>[
            BlenderStaticPropertyField.number('Value', .5),
            BlenderStaticPropertyField.number('Frame', 1),
          ], expanded: true),
      ],
    );
  }
}
