part of '../showcase_app.dart';

extension _ShowcasePreferenceAnimation on _ShowcaseAppState {
  List<BlenderPreferenceSection>
  get _animationPreferenceSections => <BlenderPreferenceSection>[
    BlenderPreferenceSection.form('Animation', 'timeline', 'Timeline', <Widget>[
      BlenderStaticPropertyField.checkbox(
        'Allow Negative Frames',
        value: false,
      ),
      BlenderStaticPropertyField.number('Minimum Grid Spacing', 45),
      BlenderStaticPropertyField.menu(
        'Timecode Style',
        'Minimal Info',
        <String>['Minimal Info', 'SMPTE', 'Milliseconds'],
      ),
      BlenderStaticPropertyField.menu(
        'Zoom to Frame Type',
        'Keep Range',
        <String>['Keep Range', 'Seconds', 'Keyframes'],
      ),
    ], expanded: true),
    BlenderPreferenceSection.form(
      'Animation',
      'keyframes',
      'Keyframes',
      <Widget>[
        BlenderPropertyRow(
          label: 'Default Key Channels',
          editor: BlenderSegmentedControl<String>(
            value: 'Location',
            expanded: true,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Location', label: 'Location'),
              BlenderMenuItem<String>(value: 'Rotation', label: 'Rotation'),
              BlenderMenuItem<String>(value: 'Scale', label: 'Scale'),
              BlenderMenuItem<String>(
                value: 'Rotation Mode',
                label: 'Rotation Mode',
              ),
              BlenderMenuItem<String>(
                value: 'Custom Properties',
                label: 'Custom Properties',
              ),
            ],
            onChanged: (_) {},
          ),
        ),
        BlenderPropertyRow(
          label: 'Only Insert Needed',
          editor: BlenderSegmentedControl<String>(
            value: 'Auto',
            expanded: true,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Manual', label: 'Manual'),
              BlenderMenuItem<String>(value: 'Auto', label: 'Auto'),
            ],
            onChanged: (_) {},
          ),
        ),
        BlenderStaticPropertyField.checkbox('Visual Keying', value: false),
        BlenderStaticPropertyField.checkbox(
          'Enable in New Scenes',
          value: false,
        ),
        BlenderStaticPropertyField.checkbox('Show Warning'),
        BlenderStaticPropertyField.checkbox(
          'Only Insert Available',
          value: false,
        ),
      ],
      expanded: true,
    ),
    BlenderPreferenceSection.form('Animation', 'fcurves', 'F-Curves', <Widget>[
      BlenderPropertyRow(
        label: 'Unselected Opacity',
        editor: BlenderSlider(value: .25, onChanged: (_) {}),
      ),
      BlenderStaticPropertyField.menu(
        'Default Smoothing Mode',
        'Continuous Acceleration',
        <String>['Continuous Acceleration', 'None'],
      ),
      BlenderStaticPropertyField.menu(
        'Default Interpolation',
        'Bezier',
        <String>['Bezier', 'Linear', 'Constant'],
      ),
      BlenderStaticPropertyField.menu(
        'Default Handles',
        'Auto Clamped',
        <String>['Auto Clamped', 'Automatic', 'Vector'],
      ),
      BlenderStaticPropertyField.checkbox('XYZ to RGB'),
      BlenderStaticPropertyField.checkbox('Channel Group Colors', value: false),
    ], expanded: true),
    BlenderPreferenceSection.form('Animation', 'advanced', 'Advanced', <Widget>[
      BlenderStaticPropertyField.checkbox('Only Insert Available'),
      BlenderStaticPropertyField.number('Slowdown Factor', 0),
    ]),
  ];
}
