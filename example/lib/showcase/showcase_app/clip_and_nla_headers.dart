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
      playing: _playback.playing,
      onFirst: _playback.jumpToStart,
      onPrevious: _playback.stepBackward,
      onPlay: _playback.togglePlaying,
      onNext: _playback.stepForward,
      onLast: _playback.jumpToEnd,
      onRecord: () => _setStatus('Record toggled'),
      frame: _frame,
      frameMax: 120,
      onFrameChanged: _playback.seek,
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
