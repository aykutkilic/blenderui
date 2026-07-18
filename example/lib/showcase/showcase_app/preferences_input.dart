part of '../showcase_app.dart';

extension _ShowcasePreferenceInput on _ShowcaseAppState {
  List<BlenderPreferenceSection> get _inputPreferenceSections =>
      <BlenderPreferenceSection>[
        BlenderPreferenceSection.form('Input', 'keyboard', 'Keyboard', <Widget>[
          BlenderStaticPropertyField.checkbox('Emulate Numpad'),
          BlenderStaticPropertyField.checkbox('Orbit Around Selection'),
        ], expanded: true),
        BlenderPreferenceSection.form('Input', 'mouse', 'Mouse', <Widget>[
          BlenderStaticPropertyField.menu('Select With', 'Left', <String>[
            'Left',
            'Right',
          ]),
          BlenderStaticPropertyField.checkbox('Continuous Grab'),
        ]),
        BlenderPreferenceSection.form('Input', 'tablet', 'Tablet', <Widget>[
          BlenderStaticPropertyField.menu('Tablet API', 'Automatic', <String>[
            'Automatic',
            'Wintab',
            'Windows Ink',
          ]),
          BlenderStaticPropertyField.number('Pressure Softness', .5),
        ]),
        BlenderPreferenceSection.form('Input', 'touchpad', 'Touchpad', <Widget>[
          BlenderStaticPropertyField.checkbox('Natural Trackpad Direction'),
          BlenderStaticPropertyField.number('Scroll Sensitivity', 1),
        ]),
        BlenderPreferenceSection.form('Input', 'ndof', 'NDOF', <Widget>[
          BlenderStaticPropertyField.checkbox('Pan'),
          BlenderStaticPropertyField.checkbox('Orbit'),
          BlenderStaticPropertyField.checkbox('Zoom'),
        ]),

        BlenderPreferenceSection.form(
          'Navigation',
          'orbit',
          'Orbit & Pan',
          <Widget>[
            BlenderStaticPropertyField.menu(
              'Orbit Method',
              'Turntable',
              <String>['Turntable', 'Trackball'],
            ),
            BlenderStaticPropertyField.checkbox('Orbit Around Selection'),
            BlenderStaticPropertyField.checkbox('Auto Perspective'),
          ],
          expanded: true,
        ),
        BlenderPreferenceSection.form('Navigation', 'zoom', 'Zoom', <Widget>[
          BlenderStaticPropertyField.menu('Zoom Method', 'Continue', <String>[
            'Continue',
            'Dolly',
            'Scale',
          ]),
          BlenderStaticPropertyField.checkbox('Zoom to Mouse Position'),
        ]),
        BlenderPreferenceSection.form(
          'Navigation',
          'fly-walk',
          'Fly & Walk',
          <Widget>[
            BlenderStaticPropertyField.menu('View Axis', 'Forward', <String>[
              'Forward',
              'Up',
            ]),
            BlenderStaticPropertyField.panel('Walk', <Widget>[
              BlenderStaticPropertyField.number('Speed', 2.5),
              BlenderStaticPropertyField.checkbox('Gravity'),
            ]),
            BlenderStaticPropertyField.panel('Gravity', <Widget>[
              BlenderStaticPropertyField.number('Weight', 1),
              BlenderStaticPropertyField.number('Jump Height', 1),
            ]),
          ],
        ),

        BlenderPreferenceSection.form(
          'Keymap',
          'presets',
          'KeyPresets',
          <Widget>[
            BlenderStaticPropertyField.menu('Preset', 'Blender', <String>[
              'Blender',
              'Industry Compatible',
            ]),
            _preferenceButtons(<String>['Restore', 'Save']),
          ],
          expanded: true,
        ),
        BlenderPreferenceSection.form('Keymap', 'keymap', 'Keymap', <Widget>[
          BlenderPathField(
            controller: _keymapSearchController,
            placeholder: 'Search Keymap',
          ),
          BlenderStaticPropertyField.checkbox('Emulate Numpad'),
          BlenderStaticPropertyField.checkbox('Select Mouse Button'),
        ]),
      ];
}
