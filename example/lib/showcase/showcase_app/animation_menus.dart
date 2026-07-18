part of '../showcase_app.dart';

extension _ShowcaseAnimationMenus on _ShowcaseAppState {
  Widget _buildAnimationPopoverPanel(String title, List<Widget> children) {
    return BlenderPopoverPanel(
      title: title,
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildAnimationFiltersPopover() {
    return _buildAnimationPopoverPanel('Filters', <Widget>[
      BlenderCheckbox(
        value: true,
        label: 'Summary',
        onChanged: (value) =>
            _setStatus('Summary filter ${value ? 'on' : 'off'}'),
      ),
      BlenderCheckbox(
        value: _animationSelectedOnly,
        label: 'Only Selected',
        onChanged: (value) => _update(() => _animationSelectedOnly = value),
      ),
      BlenderCheckbox(
        value: false,
        label: 'Show Hidden',
        onChanged: (value) => _setStatus('Hidden-channel filter toggled'),
      ),
      BlenderCheckbox(
        value: _animationShowErrors,
        label: 'Only Errors',
        onChanged: (value) => _update(() => _animationShowErrors = value),
      ),
      const BlenderSeparator(),
      const Text('Filter by Type'),
      BlenderCheckbox(
        value: true,
        label: 'Scenes',
        onChanged: (value) => _setStatus('Scene filter toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Objects',
        onChanged: (value) => _setStatus('Object filter toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Materials',
        onChanged: (value) => _setStatus('Material filter toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Transforms',
        onChanged: (value) => _setStatus('Transform filter toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Modifiers',
        onChanged: (value) => _setStatus('Modifier filter toggled'),
      ),
    ]);
  }

  Widget _buildAnimationSnappingPopover() {
    return _buildAnimationPopoverPanel('Snapping', <Widget>[
      const Text('Snap To'),
      BlenderDropdown<String>(
        value: 'Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
          BlenderMenuItem<String>(value: 'Second', label: 'Second'),
          BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
          BlenderMenuItem<String>(
            value: 'Absolute Time',
            label: 'Absolute Time',
          ),
        ],
        onChanged: (value) => _setStatus('Snap to $value'),
      ),
      const SizedBox(height: 6),
      BlenderCheckbox(
        value: false,
        label: 'Absolute Time',
        onChanged: (value) => _setStatus('Absolute snap toggled'),
      ),
      BlenderCheckbox(
        value: false,
        label: 'Snap Playhead',
        onChanged: (value) => _setStatus('Playhead snap toggled'),
      ),
    ]);
  }

  Widget _buildAnimationOverlayPopover() {
    return _buildAnimationPopoverPanel('Overlays', <Widget>[
      BlenderCheckbox(
        value: _animationOverlays,
        label: 'Show Overlays',
        onChanged: (value) => _update(() => _animationOverlays = value),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Show Markers',
        onChanged: (value) => _setStatus('Markers toggled'),
      ),
      BlenderCheckbox(
        value: _animationShowSeconds,
        label: 'Show Seconds',
        onChanged: (value) => _update(() => _animationShowSeconds = value),
      ),
      BlenderCheckbox(
        value: _animationShowLockedTime,
        label: 'Show Locked Time',
        onChanged: (value) => _update(() => _animationShowLockedTime = value),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Only Selected Keys',
        onChanged: (value) => _setStatus('Selected keys toggled'),
      ),
    ]);
  }

  Widget _buildProportionalEditingPopover() {
    return _buildAnimationPopoverPanel('Proportional Editing', <Widget>[
      BlenderDropdown<String>(
        value: 'Connected',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Connected', label: 'Connected'),
          BlenderMenuItem<String>(value: 'Projected', label: 'Projected'),
        ],
        onChanged: (value) => _setStatus('Proportional falloff $value'),
      ),
      const SizedBox(height: 6),
      BlenderNumberField(
        value: 1,
        min: 0,
        max: 10,
        step: .1,
        label: 'Size',
        onChanged: (_) {},
      ),
    ]);
  }

  List<BlenderMenuItem<String>> _animationViewMenuItems({
    required bool timeline,
  }) {
    if (timeline) {
      return <BlenderMenuItem<String>>[
        const BlenderMenuItem<String>(
          value: 'Show Region UI',
          label: 'Show Region UI',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Region HUD',
          label: 'Show Region HUD',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Region Channels',
          label: 'Show Region Channels',
        ),
        const BlenderMenuItem<String>(
          value: 'Playback Controls',
          label: 'Playback Controls',
        ),
        const BlenderMenuItem<String>(value: 'Frame All', label: 'Frame All'),
        const BlenderMenuItem<String>(
          value: 'Frame Scene Range',
          label: 'Frame Scene Range',
        ),
        const BlenderMenuItem<String>(value: 'View Frame', label: 'View Frame'),
        const BlenderMenuItem<String>(
          value: 'Show Markers',
          label: 'Show Markers',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Seconds',
          label: 'Show Seconds',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Locked Time',
          label: 'Show Locked Time',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Only Selected',
          label: 'Show Only Selected',
        ),
        const BlenderMenuItem<String>(
          value: 'Show Errors',
          label: 'Show Errors',
        ),
        const BlenderMenuItem<String>(value: 'Cache', label: 'Cache'),
        const BlenderMenuItem<String>(value: 'Area', label: 'Area'),
      ];
    }
    return <BlenderMenuItem<String>>[
      const BlenderMenuItem<String>(
        value: 'Show Region UI',
        label: 'Show Region UI',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Region HUD',
        label: 'Show Region HUD',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Region Channels',
        label: 'Show Region Channels',
      ),
      const BlenderMenuItem<String>(
        value: 'Playback Controls',
        label: 'Playback Controls',
      ),
      const BlenderMenuItem<String>(
        value: 'View Selected',
        label: 'View Selected',
      ),
      const BlenderMenuItem<String>(value: 'Frame All', label: 'View All'),
      const BlenderMenuItem<String>(
        value: 'Frame Scene Range',
        label: 'Frame Scene Range',
      ),
      const BlenderMenuItem<String>(value: 'View Frame', label: 'View Frame'),
      const BlenderMenuItem<String>(
        value: 'Multi-Word Match Search',
        label: 'Multi-Word Match Search',
      ),
      const BlenderMenuItem<String>(
        value: 'Realtime Update',
        label: 'Realtime Update',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Sliders',
        label: 'Show Sliders',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Interpolation',
        label: 'Show Interpolation',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Extremes',
        label: 'Show Extremes',
      ),
      const BlenderMenuItem<String>(
        value: 'Auto Merge Keyframes',
        label: 'Auto Merge Keyframes',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Markers',
        label: 'Show Markers',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Seconds',
        label: 'Show Seconds',
      ),
      const BlenderMenuItem<String>(
        value: 'Show Locked Time',
        label: 'Show Locked Time',
      ),
      const BlenderMenuItem<String>(
        value: 'Set Preview Range',
        label: 'Set Preview Range',
      ),
      const BlenderMenuItem<String>(
        value: 'Clear Preview Range',
        label: 'Clear Preview Range',
      ),
      const BlenderMenuItem<String>(
        value: 'Toggle Graph Editor',
        label: 'Toggle Graph Editor',
      ),
      const BlenderMenuItem<String>(value: 'Cache', label: 'Cache'),
      const BlenderMenuItem<String>(value: 'Area', label: 'Area'),
    ];
  }

  List<BlenderMenuItem<String>> _animationMarkerMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Lock Markers', label: 'Lock Markers'),
        BlenderMenuItem<String>(
          value: 'Jump to Previous Marker',
          label: 'Jump to Previous Marker',
        ),
        BlenderMenuItem<String>(
          value: 'Jump to Next Marker',
          label: 'Jump to Next Marker',
        ),
        BlenderMenuItem<String>(
          value: 'Bind Camera to Marker',
          label: 'Bind Camera to Marker',
        ),
        BlenderMenuItem<String>(value: 'Select Marker', label: 'Select Marker'),
        BlenderMenuItem<String>(value: 'Move Marker', label: 'Move Marker'),
        BlenderMenuItem<String>(value: 'Rename Marker', label: 'Rename Marker'),
        BlenderMenuItem<String>(value: 'Delete Marker', label: 'Delete Marker'),
        BlenderMenuItem<String>(
          value: 'Duplicate Marker',
          label: 'Duplicate Marker',
        ),
        BlenderMenuItem<String>(value: 'Add Marker', label: 'Add Marker'),
      ];

  List<BlenderMenuItem<String>> _animationSelectMenuItems() =>
      const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'All', label: 'All'),
        BlenderMenuItem<String>(value: 'None', label: 'None'),
        BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
        BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
        BlenderMenuItem<String>(
          value: 'Box Select (Axis Range)',
          label: 'Box Select (Axis Range)',
        ),
        BlenderMenuItem<String>(value: 'Circle Select', label: 'Circle Select'),
        BlenderMenuItem<String>(value: 'Lasso Select', label: 'Lasso Select'),
        BlenderMenuItem<String>(value: 'More', label: 'More'),
        BlenderMenuItem<String>(value: 'Less', label: 'Less'),
        BlenderMenuItem<String>(value: 'Select Linked', label: 'Select Linked'),
        BlenderMenuItem<String>(
          value: 'Select by Type',
          label: 'Select by Type',
        ),
        BlenderMenuItem<String>(
          value: 'Columns on Selected Keys',
          label: 'Columns on Selected Keys',
        ),
        BlenderMenuItem<String>(
          value: 'Before Current Frame',
          label: 'Before Current Frame',
        ),
        BlenderMenuItem<String>(
          value: 'After Current Frame',
          label: 'After Current Frame',
        ),
      ];

  List<BlenderMenuItem<String>>
  _animationChannelMenuItems() => const <BlenderMenuItem<String>>[
    BlenderMenuItem<String>(value: 'Delete Channels', label: 'Delete Channels'),
    BlenderMenuItem<String>(value: 'Clean Channels', label: 'Clean Channels'),
    BlenderMenuItem<String>(value: 'Group Channels', label: 'Group Channels'),
    BlenderMenuItem<String>(
      value: 'Ungroup Channels',
      label: 'Ungroup Channels',
    ),
    BlenderMenuItem<String>(
      value: 'Toggle Channel Setting',
      label: 'Toggle Channel Setting',
    ),
    BlenderMenuItem<String>(
      value: 'Enable Channel Setting',
      label: 'Enable Channel Setting',
    ),
    BlenderMenuItem<String>(
      value: 'Disable Channel Setting',
      label: 'Disable Channel Setting',
    ),
    BlenderMenuItem<String>(value: 'Toggle Editable', label: 'Toggle Editable'),
    BlenderMenuItem<String>(
      value: 'Extrapolation Mode',
      label: 'Extrapolation Mode',
    ),
    BlenderMenuItem<String>(value: 'Expand Channels', label: 'Expand Channels'),
    BlenderMenuItem<String>(
      value: 'Collapse Channels',
      label: 'Collapse Channels',
    ),
    BlenderMenuItem<String>(value: 'Move Channels', label: 'Move Channels'),
    BlenderMenuItem<String>(value: 'Bake Channels', label: 'Bake Channels'),
    BlenderMenuItem<String>(
      value: 'View Selected Channels',
      label: 'View Selected Channels',
    ),
  ];

  List<BlenderMenuItem<String>>
  _animationKeyMenuItems() => const <BlenderMenuItem<String>>[
    BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
    BlenderMenuItem<String>(value: 'Mirror', label: 'Mirror'),
    BlenderMenuItem<String>(value: 'Snap', label: 'Snap'),
    BlenderMenuItem<String>(
      value: 'Jump to Selected',
      label: 'Jump to Selected',
    ),
    BlenderMenuItem<String>(value: 'Copy', label: 'Copy'),
    BlenderMenuItem<String>(value: 'Paste', label: 'Paste'),
    BlenderMenuItem<String>(value: 'Paste Flipped', label: 'Paste Flipped'),
    BlenderMenuItem<String>(value: 'Insert Keyframe', label: 'Insert Keyframe'),
    BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
    BlenderMenuItem<String>(value: 'Keyframe Type', label: 'Keyframe Type'),
    BlenderMenuItem<String>(value: 'Handle Type', label: 'Handle Type'),
    BlenderMenuItem<String>(
      value: 'Interpolation Mode',
      label: 'Interpolation Mode',
    ),
    BlenderMenuItem<String>(value: 'Easing Mode', label: 'Easing Mode'),
    BlenderMenuItem<String>(value: 'Clean Keyframes', label: 'Clean Keyframes'),
    BlenderMenuItem<String>(value: 'Bake Keyframes', label: 'Bake Keyframes'),
    BlenderMenuItem<String>(
      value: 'Discontinuity (Euler) Filter',
      label: 'Discontinuity (Euler) Filter',
    ),
    BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
  ];

  List<BlenderMenuItem<String>>
  _animationActionMenuItems() => const <BlenderMenuItem<String>>[
    BlenderMenuItem<String>(value: 'Merge Animation', label: 'Merge Animation'),
    BlenderMenuItem<String>(value: 'Separate Slots', label: 'Separate Slots'),
    BlenderMenuItem<String>(value: 'Replace Action', label: 'Replace Action'),
    BlenderMenuItem<String>(
      value: 'Replace Action New',
      label: 'Replace Action New',
    ),
    BlenderMenuItem<String>(
      value: 'Replace Action Duplicate',
      label: 'Replace Action Duplicate',
    ),
    BlenderMenuItem<String>(
      value: 'Move Channels to New Action',
      label: 'Move Channels to New Action',
    ),
    BlenderMenuItem<String>(
      value: 'Push Down Action',
      label: 'Push Down Action',
    ),
    BlenderMenuItem<String>(value: 'Stash Action', label: 'Stash Action'),
  ];

  Widget _buildAnimationPlaybackPopover() {
    return _buildAnimationPopoverPanel('Playback', <Widget>[
      BlenderDropdown<String>(
        value: 'Play Every Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Play Every Frame',
            label: 'Play Every Frame',
          ),
          BlenderMenuItem<String>(
            value: 'Frame Dropping',
            label: 'Frame Dropping',
          ),
        ],
        onChanged: (value) => _setStatus('Playback sync $value'),
      ),
      const SizedBox(height: 6),
      BlenderCheckbox(
        value: true,
        label: 'Audio Scrubbing',
        onChanged: (value) => _setStatus('Audio scrubbing toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Use Audio',
        onChanged: (value) => _setStatus('Audio playback toggled'),
      ),
      BlenderCheckbox(
        value: false,
        label: 'Limit to Frame Range',
        onChanged: (value) => _setStatus('Frame range limit toggled'),
      ),
      BlenderCheckbox(
        value: true,
        label: 'Follow Current Frame',
        onChanged: (value) => _setStatus('Follow current frame toggled'),
      ),
      BlenderDropdown<String>(
        value: 'Cycle',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Cycle', label: 'Cycle'),
          BlenderMenuItem<String>(value: 'Hold', label: 'Hold'),
          BlenderMenuItem<String>(value: 'Ping-Pong', label: 'Ping-Pong'),
        ],
        onChanged: (value) => _setStatus('Playback loop $value'),
      ),
    ]);
  }

  Widget _buildAnimationAutoKeyingPopover() {
    return _buildAnimationPopoverPanel('Auto Keying', <Widget>[
      BlenderSegmentedControl<String>(
        value: 'Add & Replace',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Add & Replace',
            label: 'Add & Replace',
          ),
          BlenderMenuItem<String>(value: 'Replace', label: 'Replace'),
        ],
        onChanged: (value) => _setStatus('Auto keying mode $value'),
      ),
      const SizedBox(height: 6),
      BlenderCheckbox(
        value: false,
        label: 'Only Active Keying Set',
        onChanged: (value) =>
            _setStatus('Active keying set restriction toggled'),
      ),
      BlenderCheckbox(
        value: false,
        label: 'Layered Recording',
        onChanged: (value) => _setStatus('Layered recording toggled'),
      ),
    ]);
  }

  Widget _buildAnimationTimeJumpPopover() {
    return _buildAnimationPopoverPanel('Time Jump', <Widget>[
      const Text('Jump Unit'),
      BlenderSegmentedControl<String>(
        value: 'Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
          BlenderMenuItem<String>(value: 'Second', label: 'Second'),
        ],
        onChanged: (value) => _setStatus('Jump unit $value'),
      ),
      const SizedBox(height: 6),
      BlenderNumberField(
        value: 1,
        min: 1,
        max: 120,
        step: 1,
        decimalDigits: 0,
        label: 'Delta',
        onChanged: (value) => _setStatus('Jump delta $value'),
      ),
    ]);
  }

  Widget _buildAnimationPlayheadSnappingPopover() {
    return _buildAnimationPopoverPanel('Playhead', <Widget>[
      BlenderNumberField(
        value: 2,
        min: 0,
        max: 20,
        step: 1,
        decimalDigits: 0,
        label: 'Snap Distance',
        onChanged: (_) {},
      ),
      const SizedBox(height: 6),
      const Text('Snap Target'),
      BlenderSegmentedControl<String>(
        value: 'Frame',
        items: const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
          BlenderMenuItem<String>(value: 'Second', label: 'Second'),
          BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
        ],
        onChanged: (value) => _setStatus('Playhead snap target $value'),
      ),
      const SizedBox(height: 6),
      BlenderNumberField(
        value: 1,
        min: 1,
        max: 120,
        step: 1,
        decimalDigits: 0,
        label: 'Frame Step',
        onChanged: (_) {},
      ),
    ]);
  }
}
