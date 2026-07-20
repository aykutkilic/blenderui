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
    this.cursor = const Offset(1, 0),
    this.onCursorChanged,
    this.activeChannel,
    this.driverType = 'Scripted Expression',
    this.driverExpression = 'var',
    this.driverVariables = const <String>['var'],
    this.modifiers = const <String>[],
    this.onCommand,
  });

  final bool drivers;
  final double? width;
  final Offset cursor;
  final ValueChanged<Offset>? onCursorChanged;
  final BlenderCurveChannel? activeChannel;
  final String driverType;
  final String driverExpression;
  final List<String> driverVariables;
  final List<String> modifiers;
  final ValueChanged<String>? onCommand;

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.all(6),
      children: <Widget>[
        BlenderStaticPropertyField.panel('View', <Widget>[
          BlenderNumberField(
            value: cursor.dx,
            label: 'Cursor X',
            onChanged: (value) =>
                onCursorChanged?.call(Offset(value, cursor.dy)),
          ),
          BlenderNumberField(
            value: cursor.dy,
            label: 'Cursor Y',
            onChanged: (value) =>
                onCursorChanged?.call(Offset(cursor.dx, value)),
          ),
          BlenderStaticPropertyField.checkbox('Show Cursor', value: true),
        ], expanded: true),
        BlenderStaticPropertyField.panel('Active F-Curve', <Widget>[
          BlenderStaticPropertyField.menu(
            'Data Path',
            activeChannel?.dataPath ?? 'No active F-Curve',
            <String>[activeChannel?.dataPath ?? 'No active F-Curve'],
          ),
          BlenderStaticPropertyField.number(
            'Array Index',
            activeChannel?.arrayIndex?.toDouble() ?? 0,
          ),
          BlenderStaticPropertyField.menu(
            'Extrapolation',
            activeChannel?.extrapolation.name ?? 'constant',
            const <String>['constant', 'linear', 'Make Cyclic'],
          ),
          BlenderStaticPropertyField.checkbox(
            'Muted',
            value: activeChannel?.muted ?? false,
          ),
          BlenderStaticPropertyField.checkbox(
            'Lock',
            value: activeChannel?.locked ?? false,
          ),
        ], expanded: true),
        if (drivers)
          BlenderStaticPropertyField.panel('Driver', <Widget>[
            BlenderStaticPropertyField.menu('Type', driverType, <String>[
              'Scripted Expression',
              'Averaged Value',
              'Sum Values',
              'Minimum Value',
              'Maximum Value',
            ]),
            BlenderStaticPropertyField.menu(
              'Expression',
              driverExpression,
              <String>[driverExpression],
            ),
            BlenderStaticPropertyField.checkbox('Use Self'),
            BlenderStaticPropertyField.panel('Variables', <Widget>[
              for (final variable in driverVariables)
                BlenderStaticPropertyField.menu('Name', variable, <String>[
                  variable,
                ]),
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
          for (final modifier in modifiers)
            BlenderStaticPropertyField.menu(modifier, 'Enabled', const <String>[
              'Enabled',
              'Muted',
            ]),
          BlenderStaticPropertyField.menu('Add Modifier', 'Cycles', <String>[
            'Generator',
            'Built-In Function',
            'Envelope',
            'Cycles',
            'Noise',
            'Limits',
            'Stepped Interpolation',
          ]),
          BlenderButton(
            label: 'Add Modifier',
            onPressed: () => onCommand?.call('add-modifier'),
          ),
        ]),
      ],
    );
    if (width == null) return content;
    return SizedBox(width: width, child: content);
  }
}
