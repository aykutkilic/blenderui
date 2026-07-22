part of '../showcase_app.dart';

extension _ShowcasePreferences on _ShowcaseAppState {
  List<String> get _preferenceCategories => const <String>[
    'Interface',
    'Viewport',
    'Lights',
    'Editing',
    'Animation',
    'Get Extensions',
    'Add-ons',
    'Themes',
    'Input',
    'Navigation',
    'Keymap',
    'System',
    'Save & Load',
    'File Paths',
    'Assets',
    'Developer Tools',
    'Experimental',
  ];

  List<BlenderPreferenceCategoryGroup> get _preferenceCategoryGroups =>
      const <BlenderPreferenceCategoryGroup>[
        BlenderPreferenceCategoryGroup(
          id: 'core',
          categories: <String>[
            'Interface',
            'Viewport',
            'Lights',
            'Editing',
            'Animation',
          ],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'extensions',
          categories: <String>['Get Extensions'],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'addons',
          categories: <String>['Add-ons', 'Themes'],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'assets',
          categories: <String>['Assets'],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'input',
          categories: <String>['Input', 'Navigation', 'Keymap'],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'system',
          categories: <String>['System', 'Save & Load', 'File Paths'],
        ),
        BlenderPreferenceCategoryGroup(
          id: 'developer',
          categories: <String>['Developer Tools', 'Experimental'],
        ),
      ];

  List<BlenderPreferenceSection> get _preferenceSections =>
      <BlenderPreferenceSection>[
        ...blenderInterfacePreferenceSections(
          preferences: _interfacePreferences,
          themeService: _themeService,
          idPrefix: 'showcase-interface',
        ),
        ..._interfacePreferenceSections,
        ..._editingPreferenceSections,
        ..._animationPreferenceSections,
        ..._systemPreferenceSections,
        ..._viewportPreferenceSections,
        ..._themesPreferenceSections,
        ..._filesPreferenceSections,
        ..._inputPreferenceSections,
        ..._extensionsPreferenceSections,
        ..._developerPreferenceSections,
      ];

  Widget _preferenceButtons(List<String> labels) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: <Widget>[
        for (final label in labels)
          BlenderButton(label: label, onPressed: () => _setStatus(label)),
      ],
    );
  }
}
