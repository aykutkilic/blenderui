part of '../showcase_app.dart';

extension _ShowcaseBaseProperties on _ShowcaseAppState {
  List<BlenderPropertyGroup> get _propertyGroups {
    return <BlenderPropertyGroup>[
      BlenderPropertyGroup(
        id: 'format',
        title: 'Format',
        headerActions: <Widget>[_buildFormatPresetButton()],
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'resolution-x',
            label: 'Resolution X',
            value: _resolutionX,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 1,
              max: 16384,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => _update(() => _resolutionX = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'resolution-y',
            label: 'Y',
            value: _resolutionY,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 1,
              max: 16384,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => _update(() => _resolutionY = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'resolution-percentage',
            label: '%',
            value: _resolutionPercentage,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 100,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => _update(() => _resolutionPercentage = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'aspect-x',
            label: 'Aspect X',
            value: _aspectX,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              step: .001,
              decimalDigits: 3,
              onChanged: onChanged,
            ),
            onChanged: (value) => _update(() => _aspectX = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'aspect-y',
            label: 'Y',
            value: _aspectY,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              step: .001,
              decimalDigits: 3,
              onChanged: onChanged,
            ),
            onChanged: (value) => _update(() => _aspectY = value),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'render-region',
            label: 'Render Region',
            value: _renderRegion,
            editorBuilder: (context, value, onChanged) =>
                BlenderCheckbox(value: value, onChanged: onChanged),
            onChanged: (value) => _update(() => _renderRegion = value),
          ),
          BlenderPropertyDescriptor<bool>(
            id: 'crop-render-region',
            label: 'Crop to Render Region',
            value: _cropToRenderRegion,
            enabled: _renderRegion,
            editorBuilder: (context, value, onChanged) => BlenderCheckbox(
              value: value,
              enabled: _renderRegion,
              onChanged: onChanged,
            ),
            onChanged: (value) => _update(() => _cropToRenderRegion = value),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'frame-rate',
            label: 'Frame Rate',
            value: _frameRate,
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: '24 fps', label: '24 fps'),
                    BlenderMenuItem<String>(value: '30 fps', label: '30 fps'),
                    BlenderMenuItem<String>(value: '60 fps', label: '60 fps'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (value) => _update(() => _frameRate = value),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'frame-range',
        title: 'Frame Range',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<double>(
            id: 'frame-start',
            label: 'Frame Start',
            value: _frameStart,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 100000,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => _update(() => _frameStart = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'frame-end',
            label: 'End',
            value: _frameEnd,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 100000,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => _update(() => _frameEnd = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'frame-step',
            label: 'Step',
            value: _frameStep,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 1,
              max: 1000,
              decimalDigits: 0,
              onChanged: onChanged,
            ),
            onChanged: (value) => _update(() => _frameStep = value),
          ),
        ],
      ),
      const BlenderPropertyGroup(
        id: 'time-stretching',
        title: 'Time Stretching',
        properties: <BlenderPropertyDescriptor<dynamic>>[],
        initiallyExpanded: false,
      ),
      BlenderPropertyGroup(
        id: 'stereoscopy',
        title: 'Stereoscopy',
        properties: <BlenderPropertyDescriptor<dynamic>>[],
        initiallyExpanded: false,
        headerLeading: BlenderCheckbox(
          key: const ValueKey<String>('stereoscopy-header-checkbox'),
          value: _stereoscopy,
          onChanged: _setStereoscopy,
        ),
      ),
      BlenderPropertyGroup(
        id: 'output',
        title: 'Output',
        initiallyExpanded: true,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderPathField(
              controller: _galleryPathController,
              onBrowse: () => _setStatus('Browse output path'),
              placeholder: '/tmp/',
            ),
            const SizedBox(height: 4),
            BlenderPropertyRow(
              label: 'Saving',
              editor: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  BlenderCheckbox(
                    value: _fileExtensions,
                    label: 'File Extensions',
                    onChanged: (value) =>
                        _update(() => _fileExtensions = value),
                  ),
                  BlenderCheckbox(
                    value: _cacheResult,
                    label: 'Cache Result',
                    onChanged: (value) => _update(() => _cacheResult = value),
                  ),
                ],
              ),
            ),
          ],
        ),
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyDescriptor<String>(
            id: 'media-type',
            label: 'Media Type',
            value: _mediaType,
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'Image', label: 'Image'),
                    BlenderMenuItem<String>(value: 'Movie', label: 'Movie'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (value) => _update(() => _mediaType = value),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'file-format',
            label: 'File Format',
            value: _fileFormat,
            editorBuilder: (context, value, onChanged) =>
                BlenderDropdown<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(
                      value: 'PNG (.png)',
                      label: 'PNG (.png)',
                    ),
                    BlenderMenuItem<String>(value: 'JPEG', label: 'JPEG'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (value) => _update(() => _fileFormat = value),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'color-mode',
            label: 'Color',
            value: _colorMode,
            editorBuilder: (context, value, onChanged) =>
                BlenderSegmentedControl<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: 'BW', label: 'BW'),
                    BlenderMenuItem<String>(value: 'RGB', label: 'RGB'),
                    BlenderMenuItem<String>(value: 'RGBA', label: 'RGBA'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (value) => _update(() => _colorMode = value),
          ),
          BlenderPropertyDescriptor<String>(
            id: 'color-depth',
            label: 'Color Depth',
            value: _colorDepth,
            editorBuilder: (context, value, onChanged) =>
                BlenderSegmentedControl<String>(
                  value: value,
                  items: const <BlenderMenuItem<String>>[
                    BlenderMenuItem<String>(value: '8', label: '8'),
                    BlenderMenuItem<String>(value: '16', label: '16'),
                  ],
                  onChanged: onChanged,
                ),
            onChanged: (value) => _update(() => _colorDepth = value),
          ),
          BlenderPropertyDescriptor<double>(
            id: 'compression',
            label: 'Compression',
            value: _compression,
            editorBuilder: (context, value, onChanged) => BlenderNumberField(
              value: value,
              min: 0,
              max: 100,
              decimalDigits: 0,
              suffix: '%',
              onChanged: onChanged,
            ),
            onChanged: (value) => _update(() => _compression = value),
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'post-processing',
        title: 'Post Processing',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.boolean(
            'post-compositing',
            'Compositing',
            true,
          ),
          BlenderPropertyFactory.boolean('post-sequencer', 'Sequencer', true),
          BlenderPropertyFactory.number(
            'post-dither',
            'Dither',
            1,
            min: 0,
            max: 2,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'metadata',
        title: 'Metadata',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'metadata-input',
            'Input',
            'Scene',
            <String>['Scene', 'Strip'],
          ),
          BlenderPropertyFactory.boolean('metadata-date', 'Date', true),
          BlenderPropertyFactory.boolean('metadata-time', 'Time', true),
          BlenderPropertyFactory.boolean('metadata-frame', 'Frame', true),
          BlenderPropertyFactory.boolean('metadata-camera', 'Camera', false),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'metadata-note',
            title: 'Note',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'metadata-note-enabled',
                'Use Note',
                false,
              ),
              BlenderPropertyFactory.choice<String>(
                'metadata-note-text',
                'Text',
                'Showcase render',
                <String>['Showcase render', 'Preview output'],
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'metadata-burn',
            title: 'Burn Into Image',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.boolean(
                'metadata-burn-enabled',
                'Use Stamp',
                false,
              ),
              BlenderPropertyFactory.number(
                'metadata-font-size',
                'Font Size',
                24,
                min: 8,
                max: 128,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.boolean(
                'metadata-labels',
                'Include Labels',
                true,
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'views',
        title: 'Views',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'views-format',
            'Views Format',
            'Individual',
            <String>['Individual', 'Stereo 3D'],
          ),
          BlenderPropertyFactory.boolean('views-left', 'Left', true),
          BlenderPropertyFactory.boolean('views-right', 'Right', true),
        ],
      ),
      BlenderPropertyGroup(
        id: 'output-color-management',
        title: 'Color Management',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'output-color-mode',
            'Color Management',
            'Follow Scene',
            <String>['Follow Scene', 'Override'],
          ),
          BlenderPropertyFactory.choice<String>(
            'output-display-device',
            'Display Device',
            'sRGB',
            <String>['sRGB', 'Display P3'],
          ),
          BlenderPropertyFactory.choice<String>(
            'output-view-transform',
            'View Transform',
            'AgX',
            <String>['AgX', 'Standard'],
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'pixel-density',
        title: 'Pixel Density',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'pixel-density-pixels',
            'Pixels',
            72,
            min: 1,
            max: 10000,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.choice<String>(
            'pixel-density-unit',
            'Unit',
            'Inch',
            <String>['Inch', 'Centimeter', 'Meter', 'Custom'],
          ),
          BlenderPropertyFactory.number(
            'pixel-density-base',
            'Base',
            .0254,
            min: 0,
          ),
        ],
      ),
      BlenderPropertyGroup(
        id: 'encoding',
        title: 'Encoding',
        initiallyExpanded: false,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.choice<String>(
            'encoding-container',
            'Container',
            'MPEG-4',
            <String>['MPEG-4', 'Matroska', 'WebM'],
          ),
          BlenderPropertyFactory.boolean(
            'encoding-autosplit',
            'Autosplit Output',
            false,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'encoding-video',
            title: 'Video',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'encoding-codec',
                'Codec',
                'H.264',
                <String>['H.264', 'H.265', 'AV1'],
              ),
              BlenderPropertyFactory.choice<String>(
                'encoding-quality',
                'Quality',
                'Medium',
                <String>['Low', 'Medium', 'High'],
              ),
              BlenderPropertyFactory.number(
                'encoding-bitrate',
                'Bitrate',
                8,
                min: 1,
                max: 1000,
                decimalDigits: 0,
              ),
            ],
          ),
          BlenderPropertyGroup(
            id: 'encoding-audio',
            title: 'Audio',
            initiallyExpanded: false,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.choice<String>(
                'encoding-audio-codec',
                'Audio Codec',
                'AAC',
                <String>['AAC', 'FLAC', 'PCM'],
              ),
              BlenderPropertyFactory.choice<String>(
                'encoding-audio-channels',
                'Channels',
                'Stereo',
                <String>['Mono', 'Stereo', '5.1'],
              ),
              BlenderPropertyFactory.number(
                'encoding-sample-rate',
                'Sample Rate',
                48000,
                min: 8000,
                max: 192000,
                decimalDigits: 0,
              ),
            ],
          ),
        ],
      ),
    ];
  }
}
