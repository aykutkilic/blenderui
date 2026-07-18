part of '../specialized_templates.dart';

/// Data for Blender's cache-file template and its compact time settings.
@immutable
class BlenderCacheFileSettings {
  const BlenderCacheFileSettings({
    this.path = '',
    this.manualScale = 1,
    this.showManualScale = true,
    this.isSequence = false,
    this.overrideFrame = false,
    this.frame = 1,
    this.frameOffset = 0,
    this.velocityName = '',
    this.velocityUnit = 'Frame',
  });

  final String path;
  final double manualScale;
  final bool showManualScale;
  final bool isSequence;
  final bool overrideFrame;
  final double frame;
  final double frameOffset;
  final String velocityName;
  final String velocityUnit;

  BlenderCacheFileSettings copyWith({
    String? path,
    double? manualScale,
    bool? showManualScale,
    bool? isSequence,
    bool? overrideFrame,
    double? frame,
    double? frameOffset,
    String? velocityName,
    String? velocityUnit,
  }) {
    return BlenderCacheFileSettings(
      path: path ?? this.path,
      manualScale: manualScale ?? this.manualScale,
      showManualScale: showManualScale ?? this.showManualScale,
      isSequence: isSequence ?? this.isSequence,
      overrideFrame: overrideFrame ?? this.overrideFrame,
      frame: frame ?? this.frame,
      frameOffset: frameOffset ?? this.frameOffset,
      velocityName: velocityName ?? this.velocityName,
      velocityUnit: velocityUnit ?? this.velocityUnit,
    );
  }
}

/// Cache-file path, reload, scale, time, and velocity property panels.
class BlenderCacheFilePanel extends StatefulWidget {
  const BlenderCacheFilePanel({
    super.key,
    required this.settings,
    required this.onChanged,
    this.onBrowse,
    this.onReload,
    this.title = 'Cache File',
  });

  final BlenderCacheFileSettings settings;
  final ValueChanged<BlenderCacheFileSettings> onChanged;
  final VoidCallback? onBrowse;
  final VoidCallback? onReload;
  final String title;

  @override
  State<BlenderCacheFilePanel> createState() => _BlenderCacheFilePanelState();
}

class _BlenderCacheFilePanelState extends State<BlenderCacheFilePanel> {
  late final TextEditingController _pathController;
  late final TextEditingController _velocityController;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(text: widget.settings.path);
    _velocityController = TextEditingController(
      text: widget.settings.velocityName,
    );
  }

  @override
  void didUpdateWidget(BlenderCacheFilePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.settings.path != widget.settings.path &&
        _pathController.text != widget.settings.path) {
      _pathController.value = TextEditingValue(
        text: widget.settings.path,
        selection: TextSelection.collapsed(offset: widget.settings.path.length),
      );
    }
    if (oldWidget.settings.velocityName != widget.settings.velocityName &&
        _velocityController.text != widget.settings.velocityName) {
      _velocityController.value = TextEditingValue(
        text: widget.settings.velocityName,
        selection: TextSelection.collapsed(
          offset: widget.settings.velocityName.length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    _velocityController.dispose();
    super.dispose();
  }

  void _change(BlenderCacheFileSettings next) => widget.onChanged(next);

  Widget _propertyRow(String label, Widget child) {
    return BlenderPropertyRow(label: label, editor: child);
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.settings;
    return BlenderPanel(
      title: widget.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _propertyRow(
            'Filepath',
            Row(
              children: <Widget>[
                Expanded(
                  child: BlenderTextField(
                    controller: _pathController,
                    placeholder: 'Cache file path',
                    onChanged: (value) =>
                        _change(settings.copyWith(path: value)),
                  ),
                ),
                const SizedBox(width: 4),
                BlenderIconButton(
                  glyph: BlenderGlyph.refresh,
                  onPressed: widget.onReload,
                  tooltip: 'Reload cache file',
                  size: 24,
                ),
                BlenderIconButton(
                  glyph: BlenderGlyph.folder,
                  onPressed: widget.onBrowse,
                  tooltip: 'Browse cache file',
                  size: 24,
                ),
              ],
            ),
          ),
          if (settings.showManualScale) ...<Widget>[
            const SizedBox(height: 6),
            _propertyRow(
              'Manual Scale',
              BlenderNumberField(
                value: settings.manualScale,
                min: 0,
                step: .01,
                onChanged: (value) =>
                    _change(settings.copyWith(manualScale: value)),
              ),
            ),
          ],
          const SizedBox(height: 8),
          BlenderPanel(
            title: 'Time Settings',
            collapsible: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _propertyRow(
                  'Is Sequence',
                  BlenderCheckbox(
                    value: settings.isSequence,
                    label: '',
                    onChanged: (value) =>
                        _change(settings.copyWith(isSequence: value)),
                  ),
                ),
                _propertyRow(
                  'Override Frame',
                  Row(
                    children: <Widget>[
                      BlenderCheckbox(
                        value: settings.overrideFrame,
                        label: '',
                        onChanged: (value) =>
                            _change(settings.copyWith(overrideFrame: value)),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: BlenderNumberField(
                          value: settings.frame,
                          decimalDigits: 0,
                          enabled: settings.overrideFrame,
                          onChanged: (value) =>
                              _change(settings.copyWith(frame: value)),
                        ),
                      ),
                    ],
                  ),
                ),
                _propertyRow(
                  'Frame Offset',
                  BlenderNumberField(
                    value: settings.frameOffset,
                    decimalDigits: 0,
                    enabled: !settings.isSequence,
                    onChanged: (value) =>
                        _change(settings.copyWith(frameOffset: value)),
                  ),
                ),
              ],
            ),
          ),
          if (settings.velocityName.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            BlenderPanel(
              title: 'Velocity',
              collapsible: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _propertyRow(
                    'Name',
                    BlenderTextField(
                      controller: _velocityController,
                      onChanged: (value) =>
                          _change(settings.copyWith(velocityName: value)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  _propertyRow(
                    'Unit',
                    BlenderDropdown<String>(
                      value: settings.velocityUnit,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
                        BlenderMenuItem<String>(
                          value: 'Second',
                          label: 'Second',
                        ),
                      ],
                      onChanged: (value) =>
                          _change(settings.copyWith(velocityUnit: value)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
