part of '../showcase_app.dart';

extension _ShowcaseAnimationSequencerHeaders on _ShowcaseAppState {
  BlenderDopeSheetEditorHeader _buildAnimationEditorHeader(
    BlenderEditorType type,
  ) {
    return BlenderDopeSheetEditorHeader(
      editorType: type,
      state: _animationHeaderState,
      onEditorTypeChanged: _mainEditorArea.select,
      onStateChanged: (value) => _update(() => _animationHeaderState = value),
      onCommand: _setStatus,
      actionValue: _activeAction,
      actionItems: const <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: 'CubeAction', label: 'CubeAction'),
        BlenderMenuItem<String>(value: 'CameraAction', label: 'CameraAction'),
      ],
      onActionChanged: (value) => _update(() => _activeAction = value),
      onActionNew: () => _setStatus('New Action'),
      onActionUnlink: () => _setStatus('Unlink Action'),
      actionUserCount: 1,
      playing: _playback.playing,
      onFirst: _playback.jumpToStart,
      onPrevious: _playback.stepBackward,
      onPlay: _playback.togglePlaying,
      onNext: _playback.stepForward,
      onLast: _playback.jumpToEnd,
      onRecord: () => _setStatus('Record toggled'),
      onTimeBackward: _playback.stepBackward,
      onTimeForward: _playback.stepForward,
      frame: _frame,
      frameMax: 120,
      rangeStart: 1,
      rangeEnd: 120,
      onFrameChanged: _playback.seek,
    );
  }

  BlenderSequencerEditorHeader _buildSequencerEditorHeader(
    BlenderEditorType type,
  ) {
    return BlenderSequencerEditorHeader(
      editorType: type,
      state: _sequencerHeaderState,
      onEditorTypeChanged: _mainEditorArea.select,
      onStateChanged: (value) => _update(() => _sequencerHeaderState = value),
      onCommand: _setStatus,
    );
  }
}
