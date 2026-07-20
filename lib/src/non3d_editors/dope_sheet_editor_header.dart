part of '../non3d_editors.dart';

/// Host-owned state shared by Timeline and Dope Sheet header controls.
@immutable
class BlenderDopeSheetEditorHeaderState {
  const BlenderDopeSheetEditorHeaderState({
    this.overlays = true,
    this.autoKeying = false,
    this.playheadSnapping = false,
    this.animationSnapping = false,
    this.proportionalEditing = false,
    this.onlySelected = true,
    this.showHidden = false,
    this.onlyErrors = false,
    this.showMarkers = true,
    this.showSeconds = false,
    this.showLockedTime = false,
    this.snapTarget = 'Frame',
    this.absoluteTime = false,
    this.snapPlayhead = false,
    this.proportionalMode = 'Connected',
    this.proportionalSize = 1,
    this.playbackSync = 'Play Every Frame',
    this.audioScrubbing = true,
    this.useAudio = true,
    this.limitToFrameRange = false,
    this.followCurrentFrame = true,
    this.playbackLoop = 'Cycle',
    this.autoKeyingMode = 'Add & Replace',
    this.onlyActiveKeyingSet = false,
    this.layeredRecording = false,
    this.jumpUnit = 'Frame',
    this.jumpDelta = 1,
    this.playheadSnapDistance = 2,
    this.playheadSnapTarget = 'Frame',
    this.playheadFrameStep = 1,
  });

  final bool overlays;
  final bool autoKeying;
  final bool playheadSnapping;
  final bool animationSnapping;
  final bool proportionalEditing;
  final bool onlySelected;
  final bool showHidden;
  final bool onlyErrors;
  final bool showMarkers;
  final bool showSeconds;
  final bool showLockedTime;
  final String snapTarget;
  final bool absoluteTime;
  final bool snapPlayhead;
  final String proportionalMode;
  final double proportionalSize;
  final String playbackSync;
  final bool audioScrubbing;
  final bool useAudio;
  final bool limitToFrameRange;
  final bool followCurrentFrame;
  final String playbackLoop;
  final String autoKeyingMode;
  final bool onlyActiveKeyingSet;
  final bool layeredRecording;
  final String jumpUnit;
  final double jumpDelta;
  final double playheadSnapDistance;
  final String playheadSnapTarget;
  final double playheadFrameStep;

  BlenderDopeSheetEditorHeaderState copyWith({
    bool? overlays,
    bool? autoKeying,
    bool? playheadSnapping,
    bool? animationSnapping,
    bool? proportionalEditing,
    bool? onlySelected,
    bool? showHidden,
    bool? onlyErrors,
    bool? showMarkers,
    bool? showSeconds,
    bool? showLockedTime,
    String? snapTarget,
    bool? absoluteTime,
    bool? snapPlayhead,
    String? proportionalMode,
    double? proportionalSize,
    String? playbackSync,
    bool? audioScrubbing,
    bool? useAudio,
    bool? limitToFrameRange,
    bool? followCurrentFrame,
    String? playbackLoop,
    String? autoKeyingMode,
    bool? onlyActiveKeyingSet,
    bool? layeredRecording,
    String? jumpUnit,
    double? jumpDelta,
    double? playheadSnapDistance,
    String? playheadSnapTarget,
    double? playheadFrameStep,
  }) => BlenderDopeSheetEditorHeaderState(
    overlays: overlays ?? this.overlays,
    autoKeying: autoKeying ?? this.autoKeying,
    playheadSnapping: playheadSnapping ?? this.playheadSnapping,
    animationSnapping: animationSnapping ?? this.animationSnapping,
    proportionalEditing: proportionalEditing ?? this.proportionalEditing,
    onlySelected: onlySelected ?? this.onlySelected,
    showHidden: showHidden ?? this.showHidden,
    onlyErrors: onlyErrors ?? this.onlyErrors,
    showMarkers: showMarkers ?? this.showMarkers,
    showSeconds: showSeconds ?? this.showSeconds,
    showLockedTime: showLockedTime ?? this.showLockedTime,
    snapTarget: snapTarget ?? this.snapTarget,
    absoluteTime: absoluteTime ?? this.absoluteTime,
    snapPlayhead: snapPlayhead ?? this.snapPlayhead,
    proportionalMode: proportionalMode ?? this.proportionalMode,
    proportionalSize: proportionalSize ?? this.proportionalSize,
    playbackSync: playbackSync ?? this.playbackSync,
    audioScrubbing: audioScrubbing ?? this.audioScrubbing,
    useAudio: useAudio ?? this.useAudio,
    limitToFrameRange: limitToFrameRange ?? this.limitToFrameRange,
    followCurrentFrame: followCurrentFrame ?? this.followCurrentFrame,
    playbackLoop: playbackLoop ?? this.playbackLoop,
    autoKeyingMode: autoKeyingMode ?? this.autoKeyingMode,
    onlyActiveKeyingSet: onlyActiveKeyingSet ?? this.onlyActiveKeyingSet,
    layeredRecording: layeredRecording ?? this.layeredRecording,
    jumpUnit: jumpUnit ?? this.jumpUnit,
    jumpDelta: jumpDelta ?? this.jumpDelta,
    playheadSnapDistance: playheadSnapDistance ?? this.playheadSnapDistance,
    playheadSnapTarget: playheadSnapTarget ?? this.playheadSnapTarget,
    playheadFrameStep: playheadFrameStep ?? this.playheadFrameStep,
  );
}

/// Source-shaped header shared by Timeline and Dope Sheet editor modes.
class BlenderDopeSheetEditorHeader extends StatelessWidget {
  const BlenderDopeSheetEditorHeader({
    super.key,
    required this.editorType,
    this.state = const BlenderDopeSheetEditorHeaderState(),
    this.onEditorTypeChanged,
    this.onStateChanged,
    this.onCommand,
    this.keyPrefix = 'main-animation',
    this.editorSelector,
    this.editorSelectorWidth,
    this.playheadSnapKey,
    this.overlayKey,
    this.actionValue,
    this.actionItems = const <BlenderMenuItem<String>>[],
    this.onActionChanged,
    this.onActionNew,
    this.onActionUnlink,
    this.actionUserCount,
    this.playing = false,
    this.onFirst,
    this.onPrevious,
    this.onPlayReverse,
    this.onPlay,
    this.onNext,
    this.onLast,
    this.onRecord,
    this.onTimeBackward,
    this.onTimeForward,
    this.frame = 1,
    this.frameMin = 1,
    this.frameMax = 250,
    this.rangeStart = 1,
    this.rangeEnd = 250,
    this.onFrameChanged,
    this.onRangeStartChanged,
    this.onRangeEndChanged,
    this.height = 30,
  }) : assert(
         editorType == BlenderEditorType.timeline ||
             editorType == BlenderEditorType.dopeSheet,
         'BlenderDopeSheetEditorHeader supports Timeline and Dope Sheet.',
       );

  final BlenderEditorType editorType;
  final BlenderDopeSheetEditorHeaderState state;
  final ValueChanged<BlenderEditorType>? onEditorTypeChanged;
  final ValueChanged<BlenderDopeSheetEditorHeaderState>? onStateChanged;
  final ValueChanged<String>? onCommand;
  final String keyPrefix;
  final Widget? editorSelector;
  final double? editorSelectorWidth;
  final Key? playheadSnapKey;
  final Key? overlayKey;
  final String? actionValue;
  final List<BlenderMenuItem<String>> actionItems;
  final ValueChanged<String>? onActionChanged;
  final VoidCallback? onActionNew;
  final VoidCallback? onActionUnlink;
  final int? actionUserCount;
  final bool playing;
  final VoidCallback? onFirst;
  final VoidCallback? onPrevious;
  final VoidCallback? onPlayReverse;
  final VoidCallback? onPlay;
  final VoidCallback? onNext;
  final VoidCallback? onLast;
  final VoidCallback? onRecord;
  final VoidCallback? onTimeBackward;
  final VoidCallback? onTimeForward;
  final double frame;
  final double frameMin;
  final double frameMax;
  final double rangeStart;
  final double rangeEnd;
  final ValueChanged<double>? onFrameChanged;
  final ValueChanged<double>? onRangeStartChanged;
  final ValueChanged<double>? onRangeEndChanged;
  final double height;

  bool get _timeline => editorType == BlenderEditorType.timeline;
  Key _key(String suffix) => ValueKey<String>('$keyPrefix-$suffix');
  void _update(BlenderDopeSheetEditorHeaderState value) =>
      onStateChanged?.call(value);

  @override
  Widget build(BuildContext context) {
    final labels = _timeline
        ? const <String>['View', 'Marker']
        : const <String>[
            'View',
            'Select',
            'Marker',
            'Channel',
            'Key',
            'Action',
          ];
    return BlenderAreaHeader(
      height: height,
      editorType: editorType,
      showEditorLabel: false,
      onEditorTypeChanged: onEditorTypeChanged,
      editorSelector: editorSelector,
      editorSelectorWidth: editorSelectorWidth,
      actionsScrollable: true,
      splitScrollableActions: !_timeline,
      leading: <Widget>[
        if (!_timeline && actionValue != null)
          SizedBox(
            width: 220,
            child: BlenderActionSelector<String>(
              key: _key('action-selector'),
              value: actionValue!,
              items: actionItems,
              onChanged: onActionChanged,
              onNew: onActionNew,
              onUnlink: onActionUnlink,
              userCount: actionUserCount ?? 0,
            ),
          ),
      ],
      menuDescriptors: BlenderEditorMenuCatalog.build(
        labels,
        menuItems: _menuItems,
        menuKeys: <String, Key>{
          for (final label in labels)
            label: _key('${label.toLowerCase()}-menu'),
        },
        onSelected: onCommand,
      ),
      actions: _timeline
          ? _timelineActions(context)
          : _dopeSheetActions(context),
    );
  }

  List<Widget> _timelineActions(BuildContext context) => <Widget>[
    BlenderPopover(
      key: _key('playback-button'),
      child: const IgnorePointer(
        child: BlenderButton(
          label: 'Playback',
          variant: BlenderButtonVariant.topBar,
          onPressed: _noopAnimationHeaderControl,
        ),
      ),
      popover: (context, close) => _playbackPopover(context),
    ),
    BlenderIconButton(
      key: _key('autokey-toggle-button'),
      glyph: BlenderGlyph.record,
      selected: state.autoKeying,
      onPressed: () => _update(state.copyWith(autoKeying: !state.autoKeying)),
      tooltip: 'Toggle Auto Keying',
      size: 24,
    ),
    BlenderPopover(
      key: _key('autokey-button'),
      child: IgnorePointer(
        child: BlenderIconButton(
          glyph: BlenderGlyph.chevronDown,
          selected: state.autoKeying,
          tooltip: 'Auto Keying settings',
          size: 24,
          onPressed: _noopAnimationHeaderControl,
        ),
      ),
      popover: (context, close) => _autoKeyingPopover(context),
    ),
    BlenderPlaybackControls(
      playing: playing,
      onFirst: onFirst,
      onPrevious: onPrevious,
      onPlayReverse: onPlayReverse,
      onPlay: onPlay,
      onNext: onNext,
      onLast: onLast,
      showRecord: false,
    ),
    BlenderTimeJumpControls(
      key: _key('time-jump-controls'),
      onBackward: onTimeBackward,
      onForward: onTimeForward,
      popover: (context, close) => _timeJumpPopover(context),
    ),
    BlenderIconButton(
      key: _key('playhead-snap-toggle-button'),
      glyph: BlenderGlyph.snap,
      selected: state.playheadSnapping,
      onPressed: () =>
          _update(state.copyWith(playheadSnapping: !state.playheadSnapping)),
      tooltip: 'Toggle playhead snapping',
      size: 24,
    ),
    BlenderPopover(
      key: playheadSnapKey ?? _key('playhead-snap'),
      child: IgnorePointer(
        child: BlenderIconButton(
          glyph: BlenderGlyph.chevronDown,
          selected: state.playheadSnapping,
          tooltip: 'Playhead snapping settings',
          size: 24,
          onPressed: _noopAnimationHeaderControl,
        ),
      ),
      popover: (context, close) => _playheadPopover(context),
    ),
    const SizedBox(width: 8),
    SizedBox(
      key: _key('current-frame-field'),
      width: 92,
      child: BlenderNumberField(
        value: frame,
        min: frameMin,
        max: frameMax,
        step: 1,
        decimalDigits: 0,
        onChanged: (value) => onFrameChanged?.call(value),
      ),
    ),
    BlenderIconButton(
      glyph: BlenderGlyph.timeline,
      tooltip: 'Use preview range',
      size: 24,
      onPressed: () {},
    ),
    SizedBox(
      key: _key('range-start-field'),
      width: 100,
      child: BlenderNumberField(
        value: rangeStart,
        min: frameMin,
        max: rangeEnd,
        step: 1,
        decimalDigits: 0,
        label: 'Start',
        onChanged: (value) => onRangeStartChanged?.call(value),
      ),
    ),
    SizedBox(
      key: _key('range-end-field'),
      width: 100,
      child: BlenderNumberField(
        value: rangeEnd,
        min: rangeStart,
        max: frameMax,
        step: 1,
        decimalDigits: 0,
        label: 'End',
        onChanged: (value) => onRangeEndChanged?.call(value),
      ),
    ),
    const SizedBox(width: 6),
    ..._overlayControls(context),
    const BlenderIconButton(
      glyph: BlenderGlyph.more,
      tooltip: 'Editor options',
    ),
  ];

  List<Widget> _dopeSheetActions(BuildContext context) => <Widget>[
    BlenderPopover(
      child: BlenderIconButton(
        key: _key('filters-button'),
        glyph: BlenderGlyph.filter,
        tooltip: 'Animation filters',
        size: 24,
      ),
      popover: (context, close) => _filtersPopover(context),
    ),
    BlenderIconButton(
      key: _key('snapping-toggle-button'),
      glyph: BlenderGlyph.snap,
      selected: state.animationSnapping,
      onPressed: () =>
          _update(state.copyWith(animationSnapping: !state.animationSnapping)),
      tooltip: 'Toggle animation snapping',
      size: 24,
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: _key('snapping-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.animationSnapping,
        tooltip: 'Animation snapping settings',
        size: 24,
      ),
      popover: (context, close) => _snappingPopover(context),
    ),
    BlenderIconButton(
      key: _key('proportional-toggle-button'),
      glyph: BlenderGlyph.transform,
      selected: state.proportionalEditing,
      onPressed: () => _update(
        state.copyWith(proportionalEditing: !state.proportionalEditing),
      ),
      tooltip: 'Toggle proportional editing',
      size: 24,
    ),
    BlenderPopover(
      child: BlenderIconButton(
        key: _key('proportional-button'),
        glyph: BlenderGlyph.chevronDown,
        selected: state.proportionalEditing,
        tooltip: 'Proportional editing settings',
        size: 24,
      ),
      popover: (context, close) => _proportionalPopover(context),
    ),
    ..._overlayControls(context),
    const BlenderIconButton(
      glyph: BlenderGlyph.more,
      tooltip: 'Editor options',
    ),
  ];

  List<Widget> _overlayControls(BuildContext context) => <Widget>[
    BlenderIconButton(
      key: _key('overlay-toggle-button'),
      glyph: BlenderGlyph.overlay,
      selected: state.overlays,
      onPressed: () => _update(state.copyWith(overlays: !state.overlays)),
      tooltip: 'Toggle animation overlays',
      size: 24,
    ),
    BlenderPopover(
      key:
          overlayKey ??
          _key(_timeline ? 'overlay-button' : 'dope-overlay-button'),
      child: IgnorePointer(
        child: BlenderIconButton(
          glyph: BlenderGlyph.chevronDown,
          selected: state.overlays,
          tooltip: 'Animation overlay settings',
          size: 24,
          onPressed: _noopAnimationHeaderControl,
        ),
      ),
      popover: (context, close) => _overlayPopover(context),
    ),
  ];

  Widget _filtersPopover(BuildContext context) => BlenderPopoverPanel.settings(
    'Filters',
    <Widget>[
      BlenderCheckbox(
        value: state.onlySelected,
        label: 'Only Selected',
        onChanged: (value) => _update(state.copyWith(onlySelected: value)),
      ),
      BlenderCheckbox(
        value: state.showHidden,
        label: 'Show Hidden',
        onChanged: (value) => _update(state.copyWith(showHidden: value)),
      ),
      BlenderCheckbox(
        value: state.onlyErrors,
        label: 'Only Errors',
        onChanged: (value) => _update(state.copyWith(onlyErrors: value)),
      ),
      const BlenderSeparator(),
      Text('Filter by Type', style: BlenderTheme.of(context).textTheme.caption),
      for (final label in const <String>[
        'Scenes',
        'Objects',
        'Materials',
        'Transforms',
        'Modifiers',
      ])
        BlenderCheckbox(
          value: true,
          label: label,
          onChanged: (_) => onCommand?.call('Filter $label'),
        ),
    ],
  );

  Widget _snappingPopover(BuildContext context) =>
      BlenderPopoverPanel.settings('Snapping', <Widget>[
        Text('Snap To', style: BlenderTheme.of(context).textTheme.caption),
        BlenderDropdown<String>(
          value: state.snapTarget,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
            BlenderMenuItem<String>(value: 'Second', label: 'Second'),
            BlenderMenuItem<String>(value: 'Marker', label: 'Marker'),
            BlenderMenuItem<String>(
              value: 'Absolute Time',
              label: 'Absolute Time',
            ),
          ],
          onChanged: (value) => _update(state.copyWith(snapTarget: value)),
        ),
        BlenderCheckbox(
          value: state.absoluteTime,
          label: 'Absolute Time',
          onChanged: (value) => _update(state.copyWith(absoluteTime: value)),
        ),
        BlenderCheckbox(
          value: state.snapPlayhead,
          label: 'Snap Playhead',
          onChanged: (value) => _update(state.copyWith(snapPlayhead: value)),
        ),
      ]);

  Widget _proportionalPopover(BuildContext context) =>
      BlenderPopoverPanel.settings('Proportional Editing', <Widget>[
        BlenderDropdown<String>(
          value: state.proportionalMode,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Connected', label: 'Connected'),
            BlenderMenuItem<String>(value: 'Projected', label: 'Projected'),
          ],
          onChanged: (value) =>
              _update(state.copyWith(proportionalMode: value)),
        ),
        BlenderNumberField(
          value: state.proportionalSize,
          min: 0,
          max: 10,
          step: .1,
          label: 'Size',
          onChanged: (value) =>
              _update(state.copyWith(proportionalSize: value)),
        ),
      ]);

  Widget _overlayPopover(BuildContext context) =>
      BlenderPopoverPanel.settings('Overlays', <Widget>[
        BlenderCheckbox(
          value: state.overlays,
          label: 'Show Overlays',
          onChanged: (value) => _update(state.copyWith(overlays: value)),
        ),
        BlenderCheckbox(
          value: state.showMarkers,
          label: 'Show Markers',
          onChanged: (value) => _update(state.copyWith(showMarkers: value)),
        ),
        BlenderCheckbox(
          value: state.showSeconds,
          label: 'Show Seconds',
          onChanged: (value) => _update(state.copyWith(showSeconds: value)),
        ),
        BlenderCheckbox(
          value: state.showLockedTime,
          label: 'Show Locked Time',
          onChanged: (value) => _update(state.copyWith(showLockedTime: value)),
        ),
      ]);

  Widget _playbackPopover(BuildContext context) =>
      _blenderAnimationPlaybackPanel(context, state, onStateChanged);

  Widget _autoKeyingPopover(BuildContext context) =>
      BlenderPopoverPanel.settings('Auto Keying', <Widget>[
        BlenderSegmentedControl<String>(
          value: state.autoKeyingMode,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: 'Add & Replace',
              label: 'Add & Replace',
            ),
            BlenderMenuItem<String>(value: 'Replace', label: 'Replace'),
          ],
          onChanged: (value) => _update(state.copyWith(autoKeyingMode: value)),
        ),
        BlenderCheckbox(
          value: state.onlyActiveKeyingSet,
          label: 'Only Active Keying Set',
          onChanged: (value) =>
              _update(state.copyWith(onlyActiveKeyingSet: value)),
        ),
        BlenderCheckbox(
          value: state.layeredRecording,
          label: 'Layered Recording',
          onChanged: (value) =>
              _update(state.copyWith(layeredRecording: value)),
        ),
      ]);

  Widget _timeJumpPopover(BuildContext context) =>
      BlenderPopoverPanel.settings('Time Jump', <Widget>[
        Text('Jump Unit', style: BlenderTheme.of(context).textTheme.caption),
        BlenderSegmentedControl<String>(
          value: state.jumpUnit,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
            BlenderMenuItem<String>(value: 'Second', label: 'Second'),
          ],
          onChanged: (value) => _update(state.copyWith(jumpUnit: value)),
        ),
        BlenderNumberField(
          value: state.jumpDelta,
          min: 1,
          max: 120,
          step: 1,
          decimalDigits: 0,
          label: 'Delta',
          onChanged: (value) => _update(state.copyWith(jumpDelta: value)),
        ),
      ]);

  Widget _playheadPopover(BuildContext context) =>
      _blenderAnimationPlayheadPanel(context, state, onStateChanged);
}

void _noopAnimationHeaderControl() {}
