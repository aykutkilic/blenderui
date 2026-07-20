part of '../showcase_app.dart';

extension _ShowcaseClipAndNlaHeaders on _ShowcaseAppState {
  BlenderClipEditorHeader _buildClipEditorHeader() {
    return BlenderClipEditorHeader(
      state: _clipHeaderState,
      onEditorTypeChanged: _mainEditorArea.select,
      onStateChanged: (value) => _update(() => _clipHeaderState = value),
      onCommand: _setStatus,
    );
  }

  BlenderAnimationPlaybackFooter _buildNlaPlaybackFooter() {
    return BlenderAnimationPlaybackFooter(
      state: _animationHeaderState,
      onStateChanged: (value) => _update(() => _animationHeaderState = value),
      playing: _playing,
      onFirst: () => _update(() => _frame = 1),
      onPrevious: () =>
          _update(() => _frame = (_frame - 1).clamp(1, 120).toDouble()),
      onPlay: () => _update(() => _playing = !_playing),
      onNext: () =>
          _update(() => _frame = (_frame + 1).clamp(1, 120).toDouble()),
      onLast: () => _update(() => _frame = 120),
      onRecord: () => _setStatus('Record toggled'),
      frame: _frame,
      frameMax: 120,
      onFrameChanged: (value) => _update(() => _frame = value),
      keyPrefix: 'nla-playback',
      background: BlenderTheme.of(context).colors.canvas,
    );
  }

  BlenderNlaEditorHeader _buildNlaEditorHeader() {
    return BlenderNlaEditorHeader(
      state: _nlaHeaderState,
      onEditorTypeChanged: _mainEditorArea.select,
      onStateChanged: (value) => _update(() => _nlaHeaderState = value),
      onCommand: _setStatus,
      fCurveSearchController: _nlaCurveSearchController,
      collectionSearchController: _nlaCollectionSearchController,
    );
  }
}
