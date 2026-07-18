part of '../showcase_app.dart';

extension _ShowcasePreferenceEditing on _ShowcaseAppState {
  List<BlenderPreferenceSection>
  get _editingPreferenceSections => <BlenderPreferenceSection>[
    BlenderPreferenceSection.form('Editing', 'objects', 'Objects', <Widget>[
      BlenderStaticPropertyField.panel('New Objects', <Widget>[
        BlenderStaticPropertyField.menu('Align To', 'World', <String>[
          'World',
          'View',
          '3D Cursor',
        ]),
        BlenderStaticPropertyField.checkbox('Enter Edit Mode'),
      ], expanded: true),
      BlenderStaticPropertyField.panel('Copy on Duplicate', <Widget>[
        BlenderStaticPropertyField.checkbox('Linked Data'),
        BlenderStaticPropertyField.checkbox('Object Data'),
        BlenderStaticPropertyField.checkbox('Materials'),
      ]),
    ], expanded: true),
    BlenderPreferenceSection.form('Editing', 'cursor', '3D Cursor', <Widget>[
      BlenderStaticPropertyField.menu('Rotation Mode', 'Euler', <String>[
        'Euler',
        'Quaternion',
      ]),
      BlenderStaticPropertyField.checkbox('Surface Project'),
    ]),
    BlenderPreferenceSection.form(
      'Editing',
      'grease-pencil',
      'Grease Pencil',
      <Widget>[
        BlenderStaticPropertyField.checkbox('Allow Overlap'),
        BlenderStaticPropertyField.number('Smooth Stroke', .5),
      ],
    ),
    BlenderPreferenceSection.form(
      'Editing',
      'annotations',
      'Annotations',
      <Widget>[
        BlenderStaticPropertyField.checkbox('Default Color'),
        BlenderStaticPropertyField.number('Default Thickness', 3),
      ],
    ),
    BlenderPreferenceSection.form(
      'Editing',
      'weight-paint',
      'Weight Paint',
      <Widget>[
        BlenderStaticPropertyField.checkbox('Use Multi-Paint'),
        BlenderStaticPropertyField.checkbox('Show Zero Weights'),
      ],
    ),
    BlenderPreferenceSection.form(
      'Editing',
      'text-editor',
      'Text Editor',
      <Widget>[
        BlenderStaticPropertyField.checkbox('Highlight Line'),
        BlenderStaticPropertyField.checkbox('Show Line Numbers'),
      ],
    ),
    BlenderPreferenceSection.form(
      'Editing',
      'node-editor',
      'Node Editor',
      <Widget>[
        BlenderStaticPropertyField.checkbox('Auto-Offset'),
        BlenderStaticPropertyField.checkbox('Synchronized Node Selection'),
      ],
    ),
    BlenderPreferenceSection.form(
      'Editing',
      'sequencer',
      'Video Sequencer',
      <Widget>[
        BlenderStaticPropertyField.checkbox('Use Insert Offset'),
        BlenderStaticPropertyField.menu(
          'Default Thumbnail Size',
          'Medium',
          <String>['Small', 'Medium', 'Large'],
        ),
      ],
    ),
    BlenderPreferenceSection.form('Editing', 'misc', 'Miscellaneous', <Widget>[
      BlenderStaticPropertyField.checkbox('Adjust Last Operation'),
      BlenderStaticPropertyField.checkbox('Emulate Numpad'),
    ]),
  ];
}
