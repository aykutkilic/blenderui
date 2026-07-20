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
      playing: _playing,
      onFirst: () => _update(() => _frame = 1),
      onPrevious: () =>
          _update(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
      onPlay: () => _update(() => _playing = !_playing),
      onNext: () =>
          _update(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
      onLast: () => _update(() => _frame = 120),
      onRecord: () => _setStatus('Record toggled'),
      onTimeBackward: () =>
          _update(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
      onTimeForward: () =>
          _update(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
      frame: _frame,
      frameMax: 120,
      onFrameChanged: (value) => _update(() => _frame = value),
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
