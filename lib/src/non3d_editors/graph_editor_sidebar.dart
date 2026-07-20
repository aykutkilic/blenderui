part of '../non3d_editors.dart';

/// Source-shaped Graph/Drivers N-panel families.
///
/// Curve data, modifiers, driver expressions, and variable mutation stay
/// caller-owned; this widget supplies the stable panel hierarchy.
class BlenderGraphEditorSidebar extends StatelessWidget {
  const BlenderGraphEditorSidebar({
    super.key,
    this.drivers = false,
    this.width,
  });

  final bool drivers;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(6),
      children: <Widget>[
        BlenderStaticPropertyField.panel('View', <Widget>[
          BlenderStaticPropertyField.number('Cursor X', 24),
          BlenderStaticPropertyField.number('Cursor Y', 0),
          BlenderStaticPropertyField.checkbox('Show Cursor', value: true),
        ], expanded: true),
        BlenderStaticPropertyField.panel('Active F-Curve', <Widget>[
          BlenderStaticPropertyField.menu('Data Path', 'location.x', <String>[
            'location.x',
          ]),
          BlenderStaticPropertyField.number('Array Index', 0),
          BlenderStaticPropertyField.menu('Extrapolation', 'Constant', <String>[
            'Constant',
            'Linear',
            'Make Cyclic',
          ]),
          BlenderStaticPropertyField.checkbox('Muted'),
          BlenderStaticPropertyField.checkbox('Lock'),
        ], expanded: true),
        if (drivers)
          BlenderStaticPropertyField.panel('Driver', <Widget>[
            BlenderStaticPropertyField.menu(
              'Type',
              'Scripted Expression',
              <String>[
                'Scripted Expression',
                'Averaged Value',
                'Sum Values',
                'Minimum Value',
                'Maximum Value',
              ],
            ),
            BlenderStaticPropertyField.menu('Expression', 'var', <String>[
              'var',
            ]),
            BlenderStaticPropertyField.checkbox('Use Self'),
            BlenderStaticPropertyField.panel('Variables', <Widget>[
              BlenderStaticPropertyField.menu('Name', 'var', <String>['var']),
              BlenderStaticPropertyField.menu(
                'Type',
                'Transform Channel',
                <String>[
                  'Single Property',
                  'Transform Channel',
                  'Distance',
                  'Rotational Difference',
                  'Context Property',
                ],
              ),
              BlenderStaticPropertyField.menu('Object', 'Cube', <String>[
                'Cube',
              ]),
              BlenderStaticPropertyField.menu('Channel', 'X Location', <String>[
                'X Location',
                'Y Location',
                'Z Location',
                'X Rotation',
                'Y Rotation',
                'Z Rotation',
                'X Scale',
                'Y Scale',
                'Z Scale',
              ]),
            ], expanded: true),
          ], expanded: true),
        BlenderStaticPropertyField.panel('Modifiers', <Widget>[
          BlenderStaticPropertyField.menu('Add Modifier', 'Cycles', <String>[
            'Generator',
            'Built-In Function',
            'Envelope',
            'Cycles',
            'Noise',
            'Limits',
            'Stepped Interpolation',
          ]),
        ]),
      ],
    );
    if (width == null) return content;
    return SizedBox(width: width, child: content);
  }
}
