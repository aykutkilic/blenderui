part of '../showcase_app.dart';

extension _ShowcasePreferenceDeveloper on _ShowcaseAppState {
  List<BlenderPreferenceSection>
  get _developerPreferenceSections => <BlenderPreferenceSection>[
    BlenderPreferenceSection.form('Lights', 'matcaps', 'MatCaps', <Widget>[
      _preferenceButtons(<String>['Add MatCap', 'Remove']),
      BlenderStaticPropertyField.checkbox('Studio Light Rotation'),
    ], expanded: true),
    BlenderPreferenceSection.form('Lights', 'hdris', 'HDRIs', <Widget>[
      _preferenceButtons(<String>['Add HDRI', 'Remove']),
    ]),
    BlenderPreferenceSection.form(
      'Lights',
      'studio-lights',
      'Studio Lights',
      <Widget>[
        BlenderStaticPropertyField.panel('Editor', <Widget>[
          BlenderStaticPropertyField.menu('Light Type', 'Area', <String>[
            'Area',
            'Sun',
            'Spot',
          ]),
          BlenderStaticPropertyField.number('Rotation', 0),
          BlenderStaticPropertyField.number('Energy', 1),
        ]),
      ],
    ),

    BlenderPreferenceSection.form('Developer Tools', 'debug', 'Debug', <Widget>[
      BlenderStaticPropertyField.checkbox('Developer UI'),
      BlenderStaticPropertyField.checkbox('Debug Value'),
      _preferenceButtons(<String>['Reload Scripts']),
    ], expanded: true),
    BlenderPreferenceSection.form(
      'Experimental',
      'virtual-reality',
      'Virtual Reality',
      <Widget>[
        BlenderStaticPropertyField.checkbox(
          'Enable Virtual Reality',
          value: false,
        ),
      ],
      expanded: true,
    ),
    BlenderPreferenceSection.form(
      'Experimental',
      'new-features',
      'New Features',
      <Widget>[
        BlenderStaticPropertyField.checkbox('Experimental Features'),
        BlenderStaticPropertyField.checkbox('Extensions Development'),
      ],
    ),
    BlenderPreferenceSection.form(
      'Experimental',
      'prototypes',
      'Prototypes',
      <Widget>[
        BlenderStaticPropertyField.checkbox('Prototype Features', value: false),
      ],
    ),
    BlenderPreferenceSection.form('Experimental', 'tweaks', 'Tweaks', <Widget>[
      BlenderStaticPropertyField.checkbox('Developer Tweaks', value: false),
    ]),
  ];
}
