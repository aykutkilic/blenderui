part of 'showcase_app.dart';

extension _ShowcaseCatalogActions on _ShowcaseAppState {
  void _addGalleryRampStop() {
    _update(() {
      _galleryRamp = <BlenderColorRampStop>[
        ..._galleryRamp,
        const BlenderColorRampStop(position: .5, color: Color(0xFFAC8737)),
      ];
    });
  }

  void _showCatalogAlert() {
    showBlenderAlertDialog(
      context: context,
      title: 'Unsaved Changes',
      message:
          'The current workspace has unsaved changes.\nSave before closing?',
      icon: BlenderGlyph.warning,
      confirmLabel: 'Save',
      onConfirm: () => _setStatus('Workspace saved'),
      onCancel: () => _setStatus('Save canceled'),
    );
  }

  void _showCatalogPropertyDialog() {
    showBlenderOperatorPropertiesDialog(
      context: context,
      title: 'Set Frame Range',
      message: 'Choose the range used by the active scene.',
      confirmLabel: 'Apply',
      onConfirm: () => _setStatus('Frame range updated'),
      properties: <BlenderPropertyDescriptor<dynamic>>[
        _frameRangeProperty('start', 'Start', _frameStart, (value) {
          _update(() => _frameStart = value);
        }),
        _frameRangeProperty('end', 'End', _frameEnd, (value) {
          _update(() => _frameEnd = value);
        }),
        BlenderPropertyDescriptor<bool>(
          id: 'preview',
          label: 'Use Preview Range',
          value: _renderRegion,
          editorBuilder: (context, value, onChanged) =>
              BlenderCheckbox(value: value, label: '', onChanged: onChanged),
          onChanged: (value) => _update(() => _renderRegion = value),
        ),
      ],
    );
  }

  BlenderPropertyDescriptor<double> _frameRangeProperty(
    String id,
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return BlenderPropertyDescriptor<double>(
      id: id,
      label: label,
      value: value,
      editorBuilder: (context, value, onChanged) => BlenderNumberField(
        value: value,
        min: 1,
        max: 10000,
        decimalDigits: 0,
        onChanged: onChanged,
      ),
      onChanged: onChanged,
    );
  }

  void _removeGalleryRampStop() {
    if (_galleryRamp.length <= 2) return;
    _update(
      () => _galleryRamp = _galleryRamp.sublist(0, _galleryRamp.length - 1),
    );
  }
}
