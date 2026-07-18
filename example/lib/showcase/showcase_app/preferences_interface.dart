part of '../showcase_app.dart';

extension _ShowcasePreferenceInterface on _ShowcaseAppState {
  List<BlenderPreferenceSection> get _interfacePreferenceSections =>
      <BlenderPreferenceSection>[
        BlenderPreferenceSection.form(
          'Interface',
          'text',
          'Text Rendering',
          <Widget>[
            BlenderStaticPropertyField.checkbox('Anti-Aliasing'),
            BlenderStaticPropertyField.menu('Hinting', 'Auto', <String>[
              'Auto',
              'None',
              'Slight',
              'Full',
            ]),
            BlenderStaticPropertyField.panel('Text Editor Font', <Widget>[
              BlenderPathField(
                controller: _searchController,
                placeholder: 'UI Font',
              ),
              BlenderPathField(
                controller: _searchController,
                placeholder: 'Monospace Font',
              ),
            ]),
          ],
        ),
        BlenderPreferenceSection.form(
          'Interface',
          'language',
          'Language',
          <Widget>[
            BlenderStaticPropertyField.menu('Language', 'English', <String>[
              'English',
              'Turkish',
              'German',
            ]),
            BlenderStaticPropertyField.checkbox('Tooltips'),
            BlenderStaticPropertyField.checkbox('Interface'),
            BlenderStaticPropertyField.checkbox('Reports'),
            BlenderStaticPropertyField.menu(
              'Date Format',
              'Automatic',
              <String>['Automatic', 'International', 'US'],
            ),
          ],
        ),
        BlenderPreferenceSection.form(
          'Interface',
          'accessibility',
          'Accessibility',
          <Widget>[
            BlenderStaticPropertyField.checkbox('Reduce Motion', value: false),
          ],
        ),
        BlenderPreferenceSection.form('Interface', 'menus', 'Menus', <Widget>[
          BlenderStaticPropertyField.checkbox('Close Menus on Mouse Click'),
          BlenderStaticPropertyField.panel('Open on Mouse Over', <Widget>[
            BlenderStaticPropertyField.number('Top Level Delay', .3),
            BlenderStaticPropertyField.number('Sub Level Delay', .1),
          ]),
          BlenderStaticPropertyField.panel('Pie Menus', <Widget>[
            BlenderStaticPropertyField.number('Animation Timeout', .3),
            BlenderStaticPropertyField.number('Tap Timeout', .2),
            BlenderStaticPropertyField.number('Menu Radius', 100),
            BlenderStaticPropertyField.number('Threshold', 12),
          ]),
        ]),
      ];
}
