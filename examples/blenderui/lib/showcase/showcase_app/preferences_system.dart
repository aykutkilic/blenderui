part of '../showcase_app.dart';

extension _ShowcasePreferenceSystem on _ShowcaseAppState {
  List<BlenderPreferenceSection> get _systemPreferenceSections =>
      <BlenderPreferenceSection>[
        BlenderPreferenceSection.form('System', 'sound', 'Sound', <Widget>[
          BlenderStaticPropertyField.menu('Audio Device', 'None', <String>[
            'None',
            'System Default',
          ]),
          BlenderStaticPropertyField.menu('Speaker', 'SDL', <String>[
            'SDL',
            'OpenAL',
          ]),
          BlenderStaticPropertyField.number('Sample Rate', 48),
          BlenderStaticPropertyField.number('Channels', 2),
        ], expanded: true),
        BlenderPreferenceSection.form(
          'System',
          'cycles',
          'Cycles Render Devices',
          <Widget>[
            BlenderStaticPropertyField.menu('Device', 'CPU', <String>[
              'CPU',
              'GPU Compute',
            ]),
            _preferenceButtons(<String>['Refresh']),
          ],
        ),
        BlenderPreferenceSection.form(
          'System',
          'graphics',
          'Display Graphics',
          <Widget>[
            BlenderStaticPropertyField.menu('GPU Backend', 'OpenGL', <String>[
              'OpenGL',
              'Metal',
              'Vulkan',
            ]),
            BlenderStaticPropertyField.checkbox('Texture Limit'),
          ],
        ),
        BlenderPreferenceSection.form(
          'System',
          'os',
          'Operating System Settings',
          <Widget>[
            BlenderStaticPropertyField.checkbox('Use Native Windows'),
            BlenderStaticPropertyField.checkbox('Open File Browser'),
          ],
        ),
        BlenderPreferenceSection.form('System', 'network', 'Network', <Widget>[
          BlenderStaticPropertyField.checkbox('Allow Online Access'),
          BlenderStaticPropertyField.number('Connection Timeout', 10),
        ]),
        BlenderPreferenceSection.form(
          'System',
          'memory',
          'Memory & Limits',
          <Widget>[
            BlenderStaticPropertyField.number('Undo Steps', 32),
            BlenderStaticPropertyField.number('Undo Memory Limit', 256),
            BlenderStaticPropertyField.number('Console Scrollback Lines', 256),
          ],
        ),
        BlenderPreferenceSection.form(
          'System',
          'video-sequencer',
          'Video Sequencer',
          <Widget>[
            BlenderStaticPropertyField.checkbox('Prefetch Frames'),
            BlenderStaticPropertyField.number('Memory Cache Limit', 1024),
          ],
        ),
      ];
}
