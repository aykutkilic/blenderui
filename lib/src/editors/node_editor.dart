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
  });

  final bool geometryNodeEditor;
  final bool compositor;

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
        BlenderStaticPropertyField.menu('Name', 'Node', <String>[
          'Node',
          'Active Node',
        ]),
        BlenderStaticPropertyField.menu('Label', 'Custom Label', <String>[
          'Custom Label',
          'Node Name',
          'Hidden',
        ]),
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
      BlenderStaticPropertyField.panel('Annotation', <Widget>[
        BlenderStaticPropertyField.checkbox('Use Annotation'),
        BlenderStaticPropertyField.menu('Layer', 'Main', <String>[
          'Main',
          'Notes',
        ]),
      ]),
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
        BlenderStaticPropertyField.menu('Name', 'Node Group', <String>[
          'Node Group',
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

class _BlenderNodeBody extends StatelessWidget {
  const _BlenderNodeBody({required this.node});

  final BlenderGraphNode node;

  @override
  Widget build(BuildContext context) {
    if (node.inputs.isEmpty && node.outputs.isEmpty) {
      return const Align(
        alignment: Alignment.topLeft,
        child: BlenderIcon(BlenderGlyph.cube, size: 18),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final socket in node.inputs)
                BlenderNodeSocket(
                  label: socket.label,
                  color: socket.color,
                  detail: socket.detail,
                ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final socket in node.outputs)
                BlenderNodeSocket(
                  label: socket.label,
                  color: socket.color,
                  detail: socket.detail,
                  output: true,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlenderGraphPainter extends CustomPainter {
  _BlenderGraphPainter({required this.model, required this.color});

  final BlenderNodeGraphModel model;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = <String, BlenderGraphNode>{
      for (final node in model.nodes) node.id: node,
    };
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final link in model.links) {
      final from = nodes[link.from];
      final to = nodes[link.to];
      if (from == null || to == null) continue;
      final start =
          from.position + Offset(from.size.width, from.size.height / 2);
      final end = to.position + Offset(0, to.size.height / 2);
      final curve = Path()..moveTo(start.dx, start.dy);
      final midpoint = (start.dx + end.dx) / 2;
      curve.cubicTo(midpoint, start.dy, midpoint, end.dy, end.dx, end.dy);
      canvas.drawPath(curve, paint);
    }
  }

  @override
  bool shouldRepaint(_BlenderGraphPainter oldDelegate) {
    return model != oldDelegate.model || color != oldDelegate.color;
  }
}
