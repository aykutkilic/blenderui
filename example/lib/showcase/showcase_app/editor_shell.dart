part of '../showcase_app.dart';

extension _ShowcaseEditorShell on _ShowcaseAppState {
  Widget _buildDockedArea(
    BuildContext context,
    BlenderDockAreaNode<String> area,
  ) {
    return switch (area.value) {
      'main' => _buildEditorAreaHost(_mainEditorArea, _buildMainEditor),
      'bottom' => _buildBottomEditor(),
      'right-top' => _buildEditorAreaHost(
        _rightTopEditorArea,
        _buildRightTopArea,
      ),
      'right-bottom' => _buildEditorAreaHost(
        _rightBottomEditorArea,
        _buildRightBottomArea,
      ),
      _ => _buildEditorAreaHost(_mainEditorArea, _buildMainEditor),
    };
  }

  Widget _buildEditorAreaHost(
    BlenderEditorAreaController<BlenderEditorType> controller,
    Widget Function() builder,
  ) => BlenderEditorAreaHost<BlenderEditorType>(
    controller: controller,
    views: <BlenderEditorAreaView<BlenderEditorType>>[
      for (final type in BlenderEditorType.values)
        BlenderEditorAreaView<BlenderEditorType>(
          value: type,
          builder: (_) => builder(),
        ),
    ],
  );

  Widget _buildMainToolbar() =>
      Builder(builder: (context) => _buildMainToolbarForTheme(context));

  Widget _buildLeftSidebar({bool floating = false}) {
    return BlenderView3dToolShelf(
      key: floating ? const ValueKey<String>('viewport-tool-shelf') : null,
      width: floating ? 42 : 48,
      floating: floating,
      selectedIndex: _toolIndex,
      onChanged: (value) {
        _update(() => _toolIndex = value);
        _setStatus('Tool changed');
      },
      onOptionSelected: (option) => _setStatus('Tool: ${option.label}'),
      onContextMenuSelected: (tool, index, action) =>
          _setStatus('${tool.tooltip}: $action'),
    );
  }

  Widget _buildMainEditor() {
    return Column(
      children: <Widget>[
        _buildMainEditorHeader(),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (_mainEditorType != BlenderEditorType.view3d &&
                  _mainEditorType != BlenderEditorType.imageEditor &&
                  _mainEditorType != BlenderEditorType.uvEditor &&
                  _mainEditorType != BlenderEditorType.shaderEditor &&
                  _mainEditorType != BlenderEditorType.geometryNodeEditor &&
                  _mainEditorType != BlenderEditorType.compositor &&
                  _mainEditorType != BlenderEditorType.textureNodeEditor)
                _buildLeftSidebar(),
              Expanded(child: _buildMainEditorSurface()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainEditorHeader() {
    return switch (_mainEditorType) {
      BlenderEditorType.view3d => _buildView3dHeader(),
      BlenderEditorType.imageEditor ||
      BlenderEditorType.uvEditor => _buildImageEditorHeader(_mainEditorType),
      BlenderEditorType.timeline || BlenderEditorType.dopeSheet =>
        _buildAnimationEditorHeader(_mainEditorType),
      BlenderEditorType.nlaEditor => _buildNlaEditorHeader(),
      BlenderEditorType.graphEditor ||
      BlenderEditorType.drivers => _buildGraphEditorHeader(_mainEditorType),
      BlenderEditorType.sequencer || BlenderEditorType.videoEditing =>
        _buildSequencerEditorHeader(_mainEditorType),
      BlenderEditorType.shaderEditor ||
      BlenderEditorType.geometryNodeEditor ||
      BlenderEditorType.compositor ||
      BlenderEditorType.textureNodeEditor => _buildNodeEditorHeader(
        _mainEditorType,
      ),
      BlenderEditorType.clipEditor => _buildClipEditorHeader(),
      BlenderEditorType.spreadsheet => _buildSpreadsheetEditorHeader(),
      _ => _buildUtilityEditorHeader(_mainEditorType),
    };
  }

  BlenderView3dEditorHeader _buildView3dHeader() {
    return BlenderView3dEditorHeader(
      state: _view3dHeaderState,
      onEditorTypeChanged: _mainEditorArea.select,
      onStateChanged: (value) => _update(() => _view3dHeaderState = value),
      onCommand: _setStatus,
    );
  }

  BlenderImageEditorHeader _buildImageEditorHeader(BlenderEditorType type) {
    return BlenderImageEditorHeader(
      editorType: type,
      state: _imageHeaderState,
      onEditorTypeChanged: _mainEditorArea.select,
      onStateChanged: (value) => _update(() {
        if (value.mode != _imageHeaderState.mode) _imageToolIndex = 0;
        _imageHeaderState = value;
      }),
      onCommand: _setStatus,
    );
  }

  BlenderSpreadsheetEditorHeader _buildSpreadsheetEditorHeader() {
    return BlenderSpreadsheetEditorHeader(
      state: _spreadsheetHeaderState,
      onEditorTypeChanged: _mainEditorArea.select,
      onStateChanged: (value) => _update(() => _spreadsheetHeaderState = value),
      onCommand: _setStatus,
    );
  }
}
