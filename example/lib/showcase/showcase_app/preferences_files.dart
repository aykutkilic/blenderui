part of '../showcase_app.dart';

extension _ShowcasePreferenceFiles on _ShowcaseAppState {
  List<BlenderPreferenceSection> get _filesPreferenceSections =>
      <BlenderPreferenceSection>[
        BlenderPreferenceSection.form('File Paths', 'data', 'Data', <Widget>[
          BlenderPathField(
            controller: _galleryPathController,
            placeholder: 'Fonts',
          ),
          BlenderPathField(
            controller: _galleryPathController,
            placeholder: 'Textures',
          ),
          BlenderStaticPropertyField.panel('Render', <Widget>[
            BlenderPathField(
              controller: _galleryPathController,
              placeholder: 'Render Output',
            ),
          ]),
        ], expanded: true),
        BlenderPreferenceSection.form(
          'File Paths',
          'scripts',
          'Script Directories',
          <Widget>[
            _preferenceButtons(<String>['Add', 'Remove']),
            BlenderPathField(
              controller: _galleryPathController,
              placeholder: '/showcase/scripts',
            ),
          ],
        ),
        BlenderPreferenceSection.form(
          'File Paths',
          'applications',
          'Applications',
          <Widget>[
            BlenderStaticPropertyField.panel('Text Editor', <Widget>[
              BlenderPathField(
                controller: _galleryPathController,
                placeholder: 'Text Editor',
              ),
            ]),
          ],
        ),
        BlenderPreferenceSection.form(
          'File Paths',
          'development',
          'Development',
          <Widget>[BlenderStaticPropertyField.checkbox('Allow Online Access')],
        ),

        BlenderPreferenceSection.form(
          'Save & Load',
          'blend-files',
          'Blend Files',
          <Widget>[
            BlenderStaticPropertyField.number('Save Versions', 2),
            BlenderStaticPropertyField.checkbox('Auto Save'),
            BlenderStaticPropertyField.number('Auto Save Time', 2),
            BlenderStaticPropertyField.checkbox('Load UI'),
            BlenderStaticPropertyField.checkbox('Filter File Extensions'),
            BlenderStaticPropertyField.panel(
              'Auto Run Python Scripts',
              <Widget>[
                BlenderStaticPropertyField.checkbox('Enable Auto Run'),
                _preferenceButtons(<String>[
                  'Add Excluded Path',
                  'Remove Excluded Path',
                ]),
              ],
            ),
          ],
          expanded: true,
        ),
        BlenderPreferenceSection.form(
          'Save & Load',
          'file-browser',
          'File Browser',
          <Widget>[
            BlenderStaticPropertyField.checkbox('Show Thumbnails'),
            BlenderStaticPropertyField.checkbox('Show Recent Locations'),
            BlenderStaticPropertyField.checkbox('Show System Bookmarks'),
          ],
        ),
      ];
}
