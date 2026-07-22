part of '../showcase_app.dart';

extension _ShowcasePreferenceExtensions on _ShowcaseAppState {
  List<BlenderPreferenceSection> get _extensionsPreferenceSections =>
      <BlenderPreferenceSection>[
        BlenderPreferenceSection.form(
          'Get Extensions',
          'extensions',
          'Extensions',
          <Widget>[
            BlenderStaticPropertyField.checkbox('Allow Online Access'),
            _preferenceButtons(<String>['Refresh', 'Install']),
          ],
          expanded: true,
        ),
        BlenderPreferenceSection.form(
          'Get Extensions',
          'repositories',
          'Repositories',
          <Widget>[
            _preferenceButtons(<String>['Add Repository', 'Remove Repository']),
            BlenderStaticPropertyField.menu(
              'Active Repository',
              'Official',
              <String>['Official', 'User'],
            ),
          ],
        ),
        BlenderPreferenceSection.form(
          'Get Extensions',
          'repository-actions',
          'Active Repository',
          <Widget>[
            BlenderPathField(
              controller: _galleryPathController,
              placeholder: 'Repository URL',
            ),
            BlenderStaticPropertyField.checkbox('Check for Updates'),
          ],
        ),
        BlenderPreferenceSection.form(
          'Get Extensions',
          'remove-repository',
          'Remove Extension Repository',
          <Widget>[
            _preferenceButtons(<String>['Remove']),
          ],
        ),

        BlenderPreferenceSection.form(
          'Add-ons',
          'filter',
          'Add-ons Filter',
          <Widget>[
            BlenderPathField(
              controller: _searchController,
              placeholder: 'Search Add-ons',
            ),
            BlenderStaticPropertyField.menu('Category', 'All', <String>[
              'All',
              '3D View',
              'Add Curve',
              'Render',
            ]),
          ],
          expanded: true,
        ),
        BlenderPreferenceSection.form('Add-ons', 'addons', 'Add-ons', <Widget>[
          BlenderStaticPropertyField.checkbox('Enabled Add-on'),
          BlenderStaticPropertyField.checkbox('Community'),
          _preferenceButtons(<String>['Install from Disk']),
        ]),

        BlenderPreferenceSection.form('Assets', 'assets', 'Assets', <Widget>[
          BlenderAssetLibrariesPreferencesPanel(
            selectedId: 'studio',
            libraries: const <BlenderAssetLibraryPreference>[
              BlenderAssetLibraryPreference(
                id: 'all',
                name: 'All',
                builtIn: true,
              ),
              BlenderAssetLibraryPreference(
                id: 'essentials',
                name: 'Essentials',
                builtIn: true,
                isEssentials: true,
                includeOnlineEssentials: true,
              ),
              BlenderAssetLibraryPreference(
                id: 'studio',
                name: 'Studio Assets',
                path: '/showcase/assets',
                useRelativePath: true,
              ),
              BlenderAssetLibraryPreference(
                id: 'remote',
                name: 'Remote Repository',
                isRemote: true,
                remoteUrl: 'https://assets.example.test',
                importMethod: 'Append',
                invalid: true,
              ),
            ],
            onSelected: (library) =>
                _setStatus('Asset library: ${library.name}'),
            onEnabledChanged: (library, value) =>
                _setStatus('${library.name}: enabled $value'),
            onPathChanged: (library, value) =>
                _setStatus('${library.name}: $value'),
            onImportMethodChanged: (library, value) =>
                _setStatus('${library.name}: import $value'),
            onRelativePathChanged: (library, value) =>
                _setStatus('${library.name}: relative $value'),
            onIncludeOnlineEssentialsChanged: (value) =>
                _setStatus('Online Essentials: $value'),
            onAdd: () => _setStatus('Add asset library'),
            onRemove: () => _setStatus('Remove asset library'),
          ),
        ], expanded: true),
      ];
}
