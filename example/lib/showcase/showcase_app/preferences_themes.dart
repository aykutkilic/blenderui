part of '../showcase_app.dart';

extension _ShowcasePreferenceThemes on _ShowcaseAppState {
  List<BlenderPreferenceSection> get _themesPreferenceSections =>
      <BlenderPreferenceSection>[
        BlenderPreferenceSection.form('Themes', 'presets', 'Presets', <Widget>[
          _preferenceButtons(<String>['Default', 'Save Theme', 'Load Theme']),
        ], expanded: true),
        BlenderPreferenceSection.form('Themes', 'themes', 'Themes', <Widget>[
          BlenderStaticPropertyField.menu('Theme', 'Blender Dark', <String>[
            'Blender Dark',
            'Blender Light',
          ]),
        ]),
        BlenderPreferenceSection.form(
          'Themes',
          'interface',
          'User Interface',
          <Widget>[
            BlenderStaticPropertyField.panel('Panel', <Widget>[
              BlenderStaticPropertyField.number('Header', 1),
              BlenderStaticPropertyField.number('Panel', 1),
            ]),
            BlenderStaticPropertyField.panel('State', <Widget>[
              BlenderStaticPropertyField.checkbox('Selected'),
              BlenderStaticPropertyField.checkbox('Active'),
            ]),
            BlenderStaticPropertyField.panel('Editor & Widgets', <Widget>[
              BlenderStaticPropertyField.checkbox('Widget Emboss'),
              BlenderStaticPropertyField.checkbox('Rounded Corners'),
              BlenderStaticPropertyField.panel(
                'Transparent Checkerboard',
                <Widget>[
                  BlenderStaticPropertyField.menu(
                    'Primary Color',
                    'Light',
                    <String>['Light', 'Dark'],
                  ),
                  BlenderStaticPropertyField.menu(
                    'Secondary Color',
                    'Dark',
                    <String>['Dark', 'Light'],
                  ),
                  BlenderStaticPropertyField.number('Size', 8),
                ],
              ),
            ]),
            BlenderStaticPropertyField.panel('Axes & Gizmos', <Widget>[
              BlenderStaticPropertyField.checkbox('Show Gizmos'),
              BlenderStaticPropertyField.checkbox('Show Navigation Gizmo'),
            ]),
            BlenderStaticPropertyField.panel('Icons', <Widget>[
              BlenderStaticPropertyField.number('Icon Saturation', 1),
              BlenderStaticPropertyField.number('Icon Contrast', 1),
            ]),
            BlenderStaticPropertyField.panel('Text Style', <Widget>[
              BlenderStaticPropertyField.menu('Font Style', 'Regular', <String>[
                'Regular',
                'Bold',
                'Italic',
              ]),
            ]),
          ],
        ),
        BlenderPreferenceSection.form(
          'Themes',
          'color-sets',
          'Color Sets',
          <Widget>[
            BlenderStaticPropertyField.panel('Bone Color Sets', <Widget>[
              BlenderStaticPropertyField.checkbox('Use Theme Colors'),
            ]),
            BlenderStaticPropertyField.panel('Collection Colors', <Widget>[
              BlenderStaticPropertyField.checkbox('Use Collection Colors'),
            ]),
            BlenderStaticPropertyField.panel(
              'Sequencer Strip Color Tags',
              <Widget>[BlenderStaticPropertyField.checkbox('Use Strip Tags')],
            ),
          ],
        ),
      ];
}
