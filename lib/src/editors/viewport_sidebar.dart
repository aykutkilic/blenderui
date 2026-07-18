part of '../editors.dart';

/// Source-shaped 3D Viewport sidebar panels from `space_view3d.py`,
/// `space_view3d_sidebar.py`, and the viewport transform template.
///
/// View state, object transforms, collections, and animation operators remain
/// caller-owned; this widget mirrors the visible N-panel families.
class BlenderViewportSidebar extends StatelessWidget {
  const BlenderViewportSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(6),
      children: <Widget>[
        BlenderStaticPropertyField.panel('View', <Widget>[
          BlenderStaticPropertyField.number('Focal Length', 50),
          BlenderStaticPropertyField.number('Clip Start', .01),
          BlenderStaticPropertyField.number('Clip End', 1000),
          BlenderStaticPropertyField.checkbox('Use Local Camera', value: false),
          BlenderStaticPropertyField.menu('Camera', 'Camera', <String>[
            'Camera',
            'None',
          ]),
          BlenderStaticPropertyField.checkbox('Passepartout', value: false),
          BlenderStaticPropertyField.checkbox('Render Region', value: false),
          BlenderStaticPropertyField.panel('View Lock', <Widget>[
            BlenderStaticPropertyField.menu('Lock Object', 'None', <String>[
              'None',
              'Cube',
              'Camera',
            ]),
            BlenderStaticPropertyField.checkbox('To 3D Cursor', value: false),
            BlenderStaticPropertyField.checkbox('Camera to View', value: false),
            BlenderStaticPropertyField.checkbox('Rotation', value: false),
          ]),
          BlenderStaticPropertyField.panel('3D Cursor', <Widget>[
            BlenderStaticPropertyField.number('Location X', 0),
            BlenderStaticPropertyField.number('Location Y', 0),
            BlenderStaticPropertyField.number('Location Z', 0),
            BlenderStaticPropertyField.number('Rotation X', 0),
            BlenderStaticPropertyField.number('Rotation Y', 0),
            BlenderStaticPropertyField.number('Rotation Z', 0),
            BlenderStaticPropertyField.menu(
              'Rotation Mode',
              'XYZ Euler',
              <String>['XYZ Euler', 'Quaternion', 'Axis Angle'],
            ),
          ]),
          BlenderStaticPropertyField.panel('Collections', <Widget>[
            BlenderStaticPropertyField.checkbox('Collection'),
            BlenderStaticPropertyField.checkbox('Environment', value: false),
            BlenderStaticPropertyField.checkbox('Characters', value: false),
          ]),
        ], expanded: true),
        BlenderStaticPropertyField.panel('Item', <Widget>[
          BlenderStaticPropertyField.panel('Transform', <Widget>[
            BlenderStaticPropertyField.number('Location X', 0),
            BlenderStaticPropertyField.number('Location Y', 0),
            BlenderStaticPropertyField.number('Location Z', 0),
            BlenderStaticPropertyField.number('Rotation X', 0),
            BlenderStaticPropertyField.number('Rotation Y', 0),
            BlenderStaticPropertyField.number('Rotation Z', 0),
            BlenderStaticPropertyField.number('Scale X', 1),
            BlenderStaticPropertyField.number('Scale Y', 1),
            BlenderStaticPropertyField.number('Scale Z', 1),
          ], expanded: true),
          BlenderStaticPropertyField.menu('Mode', 'Object', <String>[
            'Object',
            'Edit',
            'Pose',
          ]),
        ], expanded: true),
        BlenderStaticPropertyField.panel('Global Transform', <Widget>[
          const BlenderButton(label: 'Copy', onPressed: _viewportNoop),
          const SizedBox(height: 4),
          const Row(
            children: <Widget>[
              Expanded(
                child: BlenderButton(label: 'Paste', onPressed: _viewportNoop),
              ),
              SizedBox(width: 4),
              Expanded(
                child: BlenderButton(
                  label: 'Mirrored',
                  onPressed: _viewportNoop,
                ),
              ),
            ],
          ),
          BlenderStaticPropertyField.panel('Fix to Camera', <Widget>[
            BlenderStaticPropertyField.checkbox('Location'),
            BlenderStaticPropertyField.checkbox('Rotation'),
            BlenderStaticPropertyField.checkbox('Scale'),
          ]),
          BlenderStaticPropertyField.panel('Mirror', <Widget>[
            BlenderStaticPropertyField.menu(
              'Object',
              'Active Armature',
              <String>['Active Armature', 'None'],
            ),
            BlenderStaticPropertyField.menu('Bone', 'Bone', <String>[
              'Bone',
              'Root',
            ]),
          ]),
          BlenderStaticPropertyField.panel('Relative', <Widget>[
            BlenderStaticPropertyField.menu('Object', 'Active Camera', <String>[
              'Active Camera',
              'None',
            ]),
          ]),
        ]),
      ],
    );
  }
}

void _viewportNoop() {}
