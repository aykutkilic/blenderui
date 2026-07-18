part of '../showcase_app.dart';

extension _ShowcasePreferenceViewport on _ShowcaseAppState {
  List<BlenderPreferenceSection>
  get _viewportPreferenceSections => <BlenderPreferenceSection>[
    BlenderPreferenceSection.form('Viewport', 'display', 'Display', <Widget>[
      BlenderStaticPropertyField.menu('3D Viewport Axes', 'Positive', <String>[
        'Positive',
        'Negative',
        'None',
      ]),
      BlenderStaticPropertyField.checkbox('Show Name'),
      BlenderStaticPropertyField.checkbox('Show Weight'),
      BlenderStaticPropertyField.checkbox('Show Text'),
    ], expanded: true),
    BlenderPreferenceSection.form('Viewport', 'quality', 'Quality', <Widget>[
      BlenderStaticPropertyField.number('Viewport Anti-Aliasing', 8),
      BlenderStaticPropertyField.checkbox('Use High Quality Normals'),
    ]),
    BlenderPreferenceSection.form('Viewport', 'textures', 'Textures', <Widget>[
      BlenderStaticPropertyField.menu(
        'Image Draw Method',
        '2D Textures',
        <String>['2D Textures', 'GLSL'],
      ),
      BlenderStaticPropertyField.number('Limit Size', 4096),
    ]),
    BlenderPreferenceSection.form(
      'Viewport',
      'subdivision',
      'Subdivision',
      <Widget>[
        BlenderStaticPropertyField.number('Viewport Levels', 1),
        BlenderStaticPropertyField.number('Render Levels', 2),
      ],
    ),
  ];
}
