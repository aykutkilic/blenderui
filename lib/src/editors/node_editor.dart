part of '../editors.dart';

/// Source-shaped sidebar panels for Blender's Node Editor.
///
/// Node selection, node-tree evaluation, and operator execution remain
/// caller-owned; this widget provides the Tool, Node, View, Options, and Group
/// panel composition from `space_node.py`.
class BlenderNodeEditorSidebar extends StatelessWidget {
  const BlenderNodeEditorSidebar({
    super.key,
    this.geometryNodeEditor = false,
    this.compositor = false,
    this.activeNode,
    this.treeName = 'Node Group',
    this.showNamedAttributes = false,
    this.showTimings = false,
  });

  final bool geometryNodeEditor;
  final bool compositor;
  final BlenderGraphNode? activeNode;
  final String treeName;
  final bool showNamedAttributes;
  final bool showTimings;

  @override
  Widget build(BuildContext context) {
    final toolPanels = <Widget>[
      BlenderStaticPropertyField.panel('Tool', <Widget>[
        BlenderStaticPropertyField.checkbox('Select'),
        BlenderStaticPropertyField.checkbox('Tweak'),
        BlenderStaticPropertyField.menu('Node Tool', 'Select Box', <String>[
          'Select Box',
          'Tweak',
        ]),
      ], expanded: true),
      if (geometryNodeEditor) ...<Widget>[
        BlenderStaticPropertyField.panel('Object Types', <Widget>[
          BlenderStaticPropertyField.checkbox('Mesh'),
          BlenderStaticPropertyField.checkbox('Curve'),
          BlenderStaticPropertyField.checkbox('Volume'),
        ]),
        BlenderStaticPropertyField.panel('Modes', <Widget>[
          BlenderStaticPropertyField.checkbox('Object Mode'),
          BlenderStaticPropertyField.checkbox('Edit Mode'),
        ]),
        BlenderStaticPropertyField.panel('Options', <Widget>[
          BlenderStaticPropertyField.checkbox('Auto Offset'),
          BlenderStaticPropertyField.checkbox('Transform Node Parents'),
        ]),
      ],
    ];
    final nodePanels = <Widget>[
      BlenderStaticPropertyField.panel('Node', <Widget>[
        BlenderStaticPropertyField.menu(
          'Name',
          activeNode?.title ?? 'Node',
          <String>[activeNode?.title ?? 'Node', 'Active Node'],
        ),
        BlenderStaticPropertyField.menu(
          'Label',
          activeNode?.label ?? 'Custom Label',
          <String>[activeNode?.label ?? 'Custom Label', 'Node Name', 'Hidden'],
        ),
        BlenderStaticPropertyField.checkbox('Use Custom Color'),
        BlenderStaticPropertyField.checkbox('Show Options'),
        BlenderStaticPropertyField.checkbox('Mute'),
        if (geometryNodeEditor || compositor)
          BlenderStaticPropertyField.checkbox('Propagate Warnings'),
      ], expanded: true),
      BlenderStaticPropertyField.panel('Properties', <Widget>[
        BlenderStaticPropertyField.menu('Input', 'Value', <String>[
          'Value',
          'Default',
          'Linked',
        ]),
        BlenderStaticPropertyField.checkbox('Use Default'),
      ]),
      if (activeNode != null)
        BlenderStaticPropertyField.panel('Sockets', <Widget>[
          for (final socket in activeNode!.inputs)
            BlenderStaticPropertyField.menu(
              socket.label,
              socket.detail ?? (socket.connected ? 'Linked' : 'Default'),
              <String>[
                socket.detail ?? (socket.connected ? 'Linked' : 'Default'),
              ],
            ),
        ]),
      if (geometryNodeEditor && showNamedAttributes)
        BlenderStaticPropertyField.panel('Named Attributes', <Widget>[
          BlenderStaticPropertyField.menu('Attribute', 'id', <String>[
            'id',
            'position',
            'normal',
          ]),
        ]),
      if ((geometryNodeEditor || compositor) && showTimings)
        BlenderStaticPropertyField.panel('Evaluation', <Widget>[
          BlenderStaticPropertyField.menu(
            'Execution Time',
            activeNode?.executionTime ?? '-',
            <String>[activeNode?.executionTime ?? '-'],
          ),
        ]),
      BlenderStaticPropertyField.panel('Custom Properties', <Widget>[
        BlenderStaticPropertyField.number('example_value', 1),
      ]),
      BlenderStaticPropertyField.panel('Texture Mapping', <Widget>[
        BlenderStaticPropertyField.menu('Vector', 'Generated', <String>[
          'Generated',
          'Normal',
          'UV',
        ]),
        BlenderStaticPropertyField.menu('Projection X', 'Flat', <String>[
          'Flat',
          'Box',
          'Sphere',
        ]),
        BlenderStaticPropertyField.menu('Projection Y', 'Flat', <String>[
          'Flat',
          'Box',
          'Sphere',
        ]),
        BlenderStaticPropertyField.menu('Projection Z', 'Flat', <String>[
          'Flat',
          'Box',
          'Sphere',
        ]),
        BlenderStaticPropertyField.number('Scale', 1),
      ]),
    ];
    final viewPanels = <Widget>[
      if (compositor)
        BlenderStaticPropertyField.panel('Backdrop', <Widget>[
          BlenderStaticPropertyField.menu('Channels', 'Color', <String>[
            'Color',
            'Color and Alpha',
            'Alpha',
          ]),
          BlenderStaticPropertyField.number('Zoom', 1),
          BlenderStaticPropertyField.number('Offset X', 0),
          BlenderStaticPropertyField.number('Offset Y', 0),
          BlenderStaticPropertyField.checkbox('Show Backdrop'),
          BlenderStaticPropertyField.checkbox('Fit to Available Space'),
        ]),
      const BlenderAnnotationSettingsPanel(),
    ];
    final optionPanels = <Widget>[
      if (compositor)
        BlenderStaticPropertyField.panel('Performance', <Widget>[
          BlenderStaticPropertyField.menu('Device', 'CPU', <String>[
            'CPU',
            'GPU',
          ]),
          BlenderStaticPropertyField.menu('Precision', 'Full', <String>[
            'Full',
            'Half',
          ]),
          BlenderStaticPropertyField.checkbox('Cache Frames'),
        ], expanded: true),
    ];
    final groupPanels = <Widget>[
      BlenderStaticPropertyField.panel('Group', <Widget>[
        BlenderStaticPropertyField.menu('Name', treeName, <String>[
          treeName,
          'Group',
        ]),
        BlenderStaticPropertyField.menu(
          'Description',
          'Node group description',
          <String>['Node group description', 'Empty'],
        ),
        BlenderStaticPropertyField.menu('Color Tag', 'None', <String>[
          'None',
          'Attribute',
          'Geometry',
          'Shader',
        ]),
        BlenderStaticPropertyField.number('Node Width', 140),
        if (geometryNodeEditor) BlenderStaticPropertyField.checkbox('Modifier'),
        if (geometryNodeEditor) BlenderStaticPropertyField.checkbox('Tool'),
        if (compositor) BlenderStaticPropertyField.checkbox('Strip Modifier'),
      ], expanded: true),
      BlenderStaticPropertyField.panel('Animation', <Widget>[
        BlenderStaticPropertyField.menu('Action', 'NodeGroupAction', <String>[
          'NodeGroupAction',
          'None',
        ]),
        BlenderStaticPropertyField.menu('Slot', 'Node Group', <String>[
          'Node Group',
          'None',
        ]),
      ]),
    ];
    return ListView(
      padding: const EdgeInsets.all(4),
      children: <Widget>[
        ...toolPanels,
        ...nodePanels,
        BlenderStaticPropertyField.panel('View', viewPanels),
        ...optionPanels,
        ...groupPanels,
      ],
    );
  }
}
