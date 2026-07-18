part of '../editors.dart';

/// The independent tree displays provided by Blender's Outliner editor.
enum BlenderOutlinerDisplayMode {
  scenes,
  viewLayer,
  videoSequencer,
  blenderFile,
  dataApi,
  libraryOverrides,
  unusedData,
}

class BlenderOutlinerDisplayModePresentation {
  const BlenderOutlinerDisplayModePresentation._(this.label, this.glyph);

  final String label;
  final BlenderGlyph glyph;

  static BlenderOutlinerDisplayModePresentation of(
    BlenderOutlinerDisplayMode mode,
  ) => switch (mode) {
    BlenderOutlinerDisplayMode.scenes =>
      const BlenderOutlinerDisplayModePresentation._(
        'Scenes',
        BlenderGlyph.scene,
      ),
    BlenderOutlinerDisplayMode.viewLayer =>
      const BlenderOutlinerDisplayModePresentation._(
        'View Layer',
        BlenderGlyph.image,
      ),
    BlenderOutlinerDisplayMode.videoSequencer =>
      const BlenderOutlinerDisplayModePresentation._(
        'Video Sequencer',
        BlenderGlyph.sequence,
      ),
    BlenderOutlinerDisplayMode.blenderFile =>
      const BlenderOutlinerDisplayModePresentation._(
        'Blender File',
        BlenderGlyph.file,
      ),
    BlenderOutlinerDisplayMode.dataApi =>
      const BlenderOutlinerDisplayModePresentation._(
        'Data API',
        BlenderGlyph.link,
      ),
    BlenderOutlinerDisplayMode.libraryOverrides =>
      const BlenderOutlinerDisplayModePresentation._(
        'Library Overrides',
        BlenderGlyph.linkBroken,
      ),
    BlenderOutlinerDisplayMode.unusedData =>
      const BlenderOutlinerDisplayModePresentation._(
        'Unused Data',
        BlenderGlyph.material,
      ),
  };
}
