part of '../showcase_app.dart';

extension _ShowcaseClipAndNlaHeaders on _ShowcaseAppState {
  List<BlenderMenuItem<String>> _clipMenuItems(String menu) {
    return switch (menu) {
      'View' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Toolbar', label: 'Toolbar'),
        BlenderMenuItem<String>(value: 'Sidebar', label: 'Sidebar'),
        BlenderMenuItem<String>(value: 'View All', label: 'View All'),
        BlenderMenuItem<String>(value: 'View Selected', label: 'View Selected'),
        BlenderMenuItem<String>(value: 'Zoom In', label: 'Zoom In'),
        BlenderMenuItem<String>(value: 'Zoom Out', label: 'Zoom Out'),
        BlenderMenuItem<String>(value: 'Area', label: 'Area'),
      ],
      'Select' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'All', label: 'All'),
        BlenderMenuItem<String>(value: 'None', label: 'None'),
        BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
        BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
        BlenderMenuItem<String>(value: 'Circle Select', label: 'Circle Select'),
        BlenderMenuItem<String>(value: 'Lasso Select', label: 'Lasso Select'),
        BlenderMenuItem<String>(
          value: 'Select Grouped',
          label: 'Select Grouped',
        ),
      ],
      'Clip' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Open Clip', label: 'Open Clip'),
        BlenderMenuItem<String>(value: 'Reload', label: 'Reload'),
        BlenderMenuItem<String>(
          value: 'Set Scene Frames',
          label: 'Set Scene Frames',
        ),
        BlenderMenuItem<String>(value: 'Prefetch', label: 'Prefetch'),
        BlenderMenuItem<String>(value: 'Refine', label: 'Refine'),
      ],
      'Track' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Track Motion', label: 'Track Motion'),
        BlenderMenuItem<String>(
          value: 'Clear Track Path',
          label: 'Clear Track Path',
        ),
        BlenderMenuItem<String>(
          value: 'Refine Markers',
          label: 'Refine Markers',
        ),
        BlenderMenuItem<String>(
          value: 'Solve Camera Motion',
          label: 'Solve Camera Motion',
        ),
        BlenderMenuItem<String>(value: 'Clean Tracks', label: 'Clean Tracks'),
      ],
      'Reconstruction' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Set Floor', label: 'Set Floor'),
        BlenderMenuItem<String>(value: 'Set Wall', label: 'Set Wall'),
        BlenderMenuItem<String>(value: 'Set Origin', label: 'Set Origin'),
        BlenderMenuItem<String>(
          value: 'Apply Solution Scale',
          label: 'Apply Solution Scale',
        ),
      ],
      'Add' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Add Marker', label: 'Add Marker'),
        BlenderMenuItem<String>(
          value: 'Add Plane Track',
          label: 'Add Plane Track',
        ),
        BlenderMenuItem<String>(value: 'Add Mask', label: 'Add Mask'),
      ],
      'Mask' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'New Mask', label: 'New Mask'),
        BlenderMenuItem<String>(value: 'New Layer', label: 'New Layer'),
        BlenderMenuItem<String>(
          value: 'Duplicate Layer',
          label: 'Duplicate Layer',
        ),
        BlenderMenuItem<String>(value: 'Delete Layer', label: 'Delete Layer'),
      ],
      _ => const <BlenderMenuItem<String>>[],
    };
  }

  Widget _buildClipGizmoPopover() =>
      _buildAnimationPopoverPanel('Gizmos', <Widget>[
        BlenderCheckbox(
          value: _clipGizmos,
          label: 'Show Gizmos',
          onChanged: (value) => _update(() => _clipGizmos = value),
        ),
        BlenderCheckbox(
          value: true,
          label: 'Navigate Gizmo',
          onChanged: (_) {},
        ),
        BlenderCheckbox(value: true, label: 'Tool Gizmos', onChanged: (_) {}),
      ]);

  Widget _buildClipOverlayPopover() =>
      _buildAnimationPopoverPanel('Overlays', <Widget>[
        BlenderCheckbox(
          value: _clipOverlays,
          label: 'Show Overlays',
          onChanged: (value) => _update(() => _clipOverlays = value),
        ),
        BlenderCheckbox(value: true, label: '3D Markers', onChanged: (_) {}),
        BlenderCheckbox(value: true, label: 'Grid', onChanged: (_) {}),
        BlenderCheckbox(value: true, label: 'Annotation', onChanged: (_) {}),
        BlenderCheckbox(value: false, label: 'Names', onChanged: (_) {}),
      ]);

  BlenderAreaHeader _buildClipEditorHeader() {
    final masking = _clipMode == 'Mask';
    final graph = _clipView == 'Graph';
    final menus = masking
        ? <String>['View', 'Select', 'Clip', 'Add', 'Mask']
        : graph
        ? <String>['View', 'Select']
        : <String>['View', 'Select', 'Clip', 'Track', 'Reconstruction'];
    final menuItems = <String, List<String>>{
      for (final menu in menus)
        menu: _clipMenuItems(menu).map((item) => item.label).toList(),
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: BlenderEditorType.clipEditor,
      showEditorLabel: false,
      onEditorTypeChanged: _mainEditorArea.select,
      leading: <Widget>[
        SizedBox(
          width: 82,
          child: BlenderDropdown<String>(
            key: const ValueKey<String>('clip-mode-selector'),
            value: _clipMode,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Tracking', label: 'Tracking'),
              BlenderMenuItem<String>(value: 'Mask', label: 'Mask'),
            ],
            onChanged: (value) => _update(() => _clipMode = value),
          ),
        ),
        if (!masking)
          SizedBox(
            width: 70,
            child: BlenderDropdown<String>(
              key: const ValueKey<String>('clip-view-selector'),
              value: _clipView,
              items: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(value: 'Clip', label: 'Clip'),
                BlenderMenuItem<String>(value: 'Graph', label: 'Graph'),
                BlenderMenuItem<String>(
                  value: 'Dope Sheet',
                  label: 'Dope Sheet',
                ),
              ],
              onChanged: (value) => _update(() => _clipView = value),
            ),
          ),
      ],
      menuDescriptors: _editorMenuDescriptors(menus, menuItems: menuItems),
      actions: <Widget>[
        if (masking)
          BlenderIconButton(
            key: const ValueKey<String>('clip-proportional-button'),
            glyph: BlenderGlyph.transform,
            selected: _clipProportional,
            onPressed: () =>
                _update(() => _clipProportional = !_clipProportional),
            tooltip: 'Proportional editing',
          ),
        const BlenderIconButton(
          key: const ValueKey<String>('clip-lock-button'),
          glyph: BlenderGlyph.lock,
          tooltip: 'Lock selection',
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('clip-gizmo-button'),
            glyph: BlenderGlyph.gizmo,
            selected: _clipGizmos,
            tooltip: 'Clip gizmos',
          ),
          popover: (context, close) => _buildClipGizmoPopover(),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('clip-overlay-button'),
            glyph: BlenderGlyph.overlay,
            selected: _clipOverlays,
            tooltip: 'Clip overlays',
          ),
          popover: (context, close) => _buildClipOverlayPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }

  List<BlenderMenuItem<String>> _nlaMenuItems(String menu) {
    return switch (menu) {
      'View' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Sidebar', label: 'Sidebar'),
        BlenderMenuItem<String>(value: 'Channels', label: 'Channels'),
        BlenderMenuItem<String>(
          value: 'Playback Controls',
          label: 'Playback Controls',
        ),
        BlenderMenuItem<String>(value: 'View Selected', label: 'View Selected'),
        BlenderMenuItem<String>(value: 'View All', label: 'View All'),
        BlenderMenuItem<String>(
          value: 'Frame Scene Range',
          label: 'Frame Scene Range',
        ),
        BlenderMenuItem<String>(value: 'View Frame', label: 'View Frame'),
        BlenderMenuItem<String>(
          value: 'Realtime Update',
          label: 'Realtime Update',
        ),
        BlenderMenuItem<String>(
          value: 'Show Strip Curves',
          label: 'Show Strip Curves',
        ),
        BlenderMenuItem<String>(value: 'Show Markers', label: 'Show Markers'),
        BlenderMenuItem<String>(
          value: 'Show Local Markers',
          label: 'Show Local Markers',
        ),
        BlenderMenuItem<String>(value: 'Show Seconds', label: 'Show Seconds'),
        BlenderMenuItem<String>(
          value: 'Show Locked Time',
          label: 'Show Locked Time',
        ),
        BlenderMenuItem<String>(
          value: 'Set Preview Range',
          label: 'Set Preview Range',
        ),
        BlenderMenuItem<String>(
          value: 'Clear Preview Range',
          label: 'Clear Preview Range',
        ),
        BlenderMenuItem<String>(
          value: 'Set NLA Preview Range',
          label: 'Set NLA Preview Range',
        ),
        BlenderMenuItem<String>(value: 'Area', label: 'Area'),
      ],
      'Select' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'All', label: 'All'),
        BlenderMenuItem<String>(value: 'None', label: 'None'),
        BlenderMenuItem<String>(value: 'Invert', label: 'Invert'),
        BlenderMenuItem<String>(value: 'Box Select', label: 'Box Select'),
        BlenderMenuItem<String>(
          value: 'Box Select (Axis Range)',
          label: 'Box Select (Axis Range)',
        ),
        BlenderMenuItem<String>(
          value: 'Before Current Frame',
          label: 'Before Current Frame',
        ),
        BlenderMenuItem<String>(
          value: 'After Current Frame',
          label: 'After Current Frame',
        ),
      ],
      'Marker' => _animationMarkerMenuItems(),
      'Add' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Action', label: 'Action'),
        BlenderMenuItem<String>(value: 'Transition', label: 'Transition'),
        BlenderMenuItem<String>(value: 'Sound', label: 'Sound'),
        BlenderMenuItem<String>(
          value: 'Selected Objects',
          label: 'Selected Objects',
        ),
      ],
      'Track' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Add', label: 'Add'),
        BlenderMenuItem<String>(
          value: 'Add Above Selected',
          label: 'Add Above Selected',
        ),
        BlenderMenuItem<String>(value: 'Move', label: 'Move'),
        BlenderMenuItem<String>(value: 'Clean Empty', label: 'Clean Empty'),
        BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
      ],
      'Strip' => const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'Transform', label: 'Transform'),
        BlenderMenuItem<String>(value: 'Snap', label: 'Snap'),
        BlenderMenuItem<String>(value: 'Duplicate', label: 'Duplicate'),
        BlenderMenuItem<String>(
          value: 'Linked Duplicate',
          label: 'Linked Duplicate',
        ),
        BlenderMenuItem<String>(value: 'Make Meta', label: 'Make Meta'),
        BlenderMenuItem<String>(value: 'Remove Meta', label: 'Remove Meta'),
        BlenderMenuItem<String>(value: 'Split', label: 'Split'),
        BlenderMenuItem<String>(value: 'Mute', label: 'Mute'),
        BlenderMenuItem<String>(value: 'Bake Action', label: 'Bake Action'),
        BlenderMenuItem<String>(value: 'Apply Scale', label: 'Apply Scale'),
        BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
      ],
      _ => const <BlenderMenuItem<String>>[],
    };
  }

  Widget _buildNlaFiltersPopover() =>
      _buildAnimationPopoverPanel('Filters', <Widget>[
        BlenderCheckbox(
          value: _nlaSelectedOnly,
          label: 'Only Selected',
          onChanged: (value) => _update(() => _nlaSelectedOnly = value),
        ),
        BlenderCheckbox(
          value: _nlaShowHidden,
          label: 'Show Hidden',
          onChanged: (value) => _update(() => _nlaShowHidden = value),
        ),
        BlenderCheckbox(
          value: _nlaShowMissing,
          label: 'Show Missing',
          onChanged: (value) => _update(() => _nlaShowMissing = value),
        ),
        BlenderCheckbox(
          value: _nlaShowErrors,
          label: 'Only Errors',
          onChanged: (value) => _update(() => _nlaShowErrors = value),
        ),
        const BlenderSeparator(),
        BlenderPropertyRow(
          label: 'F-Curve Name',
          editor: BlenderTextField(
            controller: TextEditingController(),
            placeholder: 'Search F-Curves',
          ),
        ),
        BlenderPropertyRow(
          label: 'Collection',
          editor: BlenderTextField(
            controller: TextEditingController(),
            placeholder: 'Search Collections',
          ),
        ),
        const BlenderSeparator(),
        const Text('Filter by Type'),
        for (final label in const <String>[
          'Scenes',
          'Node Trees',
          'Armatures',
          'Cameras',
          'Grease Pencil Objects',
          'Lights',
          'Meshes',
          'Curves',
          'Lattices',
          'Metaballs',
          'Volumes',
          'Worlds',
          'Particles',
          'Speakers',
          'Materials',
          'Textures',
          'Shape Keys',
          'Movie Clips',
        ])
          BlenderCheckbox(value: true, label: label, onChanged: (_) {}),
        const BlenderSeparator(),
        BlenderCheckbox(value: true, label: 'Transforms', onChanged: (_) {}),
        BlenderCheckbox(value: true, label: 'Modifiers', onChanged: (_) {}),
        const BlenderSeparator(),
        BlenderCheckbox(
          value: true,
          label: 'Use Data-Block Sort',
          onChanged: (_) {},
        ),
      ]);

  Widget _buildNlaSnappingPopover() =>
      _buildAnimationPopoverPanel('Snapping', <Widget>[
        const Text('Snap To'),
        BlenderDropdown<String>(
          value: 'Frame',
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
            BlenderMenuItem<String>(value: 'Second', label: 'Second'),
            BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
          ],
          onChanged: (value) => _setStatus('NLA snap target $value'),
        ),
        BlenderCheckbox(
          value: _nlaSnap,
          label: 'Absolute Time',
          onChanged: (value) => _update(() => _nlaSnap = value),
        ),
      ]);

  Widget _buildNlaPlaybackFooter() {
    return BlenderToolbar(
      key: const ValueKey<String>('nla-playback-footer'),
      height: 30,
      scrollable: true,
      background: BlenderTheme.of(context).colors.canvas,
      children: <Widget>[
        BlenderPopover(
          child: const BlenderButton(
            key: ValueKey<String>('nla-playback-settings-button'),
            label: 'Playback',
            variant: BlenderButtonVariant.topBar,
          ),
          popover: (context, close) => _buildAnimationPlaybackPopover(),
        ),
        BlenderPlaybackControls(
          playing: _playing,
          onFirst: () => _update(() => _frame = 1),
          onPrevious: () =>
              _update(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
          onPlay: () => _update(() => _playing = !_playing),
          onNext: () =>
              _update(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
          onLast: () => _update(() => _frame = 120),
          onRecord: () => _setStatus('Record toggled'),
        ),
        SizedBox(
          width: 92,
          child: BlenderNumberField(
            value: _frame,
            min: 1,
            max: 120,
            step: 1,
            decimalDigits: 0,
            onChanged: (value) => _update(() => _frame = value),
          ),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('nla-playhead-snap-button'),
            glyph: BlenderGlyph.snap,
            selected: _nlaSnap,
            tooltip: 'NLA playhead snapping',
          ),
          popover: (context, close) => _buildAnimationPlayheadSnappingPopover(),
        ),
      ],
    );
  }

  BlenderAreaHeader _buildNlaEditorHeader() {
    final menuItems = <String, List<String>>{
      for (final menu in const <String>[
        'View',
        'Select',
        'Marker',
        'Add',
        'Track',
        'Strip',
      ])
        menu: _nlaMenuItems(menu).map((item) => item.label).toList(),
    };
    return BlenderAreaHeader(
      height: 30,
      editorType: BlenderEditorType.nlaEditor,
      showEditorLabel: false,
      onEditorTypeChanged: _mainEditorArea.select,
      actionsScrollable: true,
      menuDescriptors: _editorMenuDescriptors(const <String>[
        'View',
        'Select',
        'Marker',
        'Add',
        'Track',
        'Strip',
      ], menuItems: menuItems),
      actions: <Widget>[
        BlenderIconButton(
          key: const ValueKey<String>('nla-only-selected-button'),
          glyph: BlenderGlyph.object,
          selected: _nlaSelectedOnly,
          onPressed: () => _update(() => _nlaSelectedOnly = !_nlaSelectedOnly),
          tooltip: 'Only Selected',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('nla-show-hidden-button'),
          glyph: BlenderGlyph.eye,
          selected: _nlaShowHidden,
          onPressed: () => _update(() => _nlaShowHidden = !_nlaShowHidden),
          tooltip: 'Show Hidden',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('nla-show-missing-button'),
          glyph: BlenderGlyph.warning,
          selected: _nlaShowMissing,
          onPressed: () => _update(() => _nlaShowMissing = !_nlaShowMissing),
          tooltip: 'Show Missing',
        ),
        BlenderIconButton(
          key: const ValueKey<String>('nla-only-errors-button'),
          glyph: BlenderGlyph.error,
          selected: _nlaShowErrors,
          onPressed: () => _update(() => _nlaShowErrors = !_nlaShowErrors),
          tooltip: 'Only Errors',
        ),
        BlenderPopover(
          child: const BlenderIconButton(
            key: ValueKey<String>('nla-filters-button'),
            glyph: BlenderGlyph.filter,
            tooltip: 'NLA filters',
          ),
          popover: (context, close) => _buildNlaFiltersPopover(),
        ),
        BlenderPopover(
          child: BlenderIconButton(
            key: const ValueKey<String>('nla-snapping-button'),
            glyph: BlenderGlyph.snap,
            selected: _nlaSnap,
            tooltip: 'NLA snapping',
          ),
          popover: (context, close) => _buildNlaSnappingPopover(),
        ),
        const BlenderIconButton(
          glyph: BlenderGlyph.more,
          tooltip: 'Editor options',
        ),
      ],
    );
  }
}
