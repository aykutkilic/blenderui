part of '../non3d_editors.dart';

/// Source-shaped strip Properties context for the Video Sequencer.
///
/// The panel tree follows `properties_strip.py`; it is intentionally a
/// descriptor-only surface so strip evaluation, media loading, and sequencer
/// operators remain owned by the embedding application.
class BlenderStripProperties extends StatelessWidget {
  const BlenderStripProperties({super.key, this.title = 'Strip'});

  final String title;

  List<BlenderPropertyGroup> _groups() {
    const blendModes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Replace', label: 'Replace'),
      BlenderMenuItem<String>(value: 'Alpha Over', label: 'Alpha Over'),
      BlenderMenuItem<String>(value: 'Add', label: 'Add'),
    ];
    const stripTypes = <BlenderMenuItem<String>>[
      BlenderMenuItem<String>(value: 'Movie', label: 'Movie'),
      BlenderMenuItem<String>(value: 'Image', label: 'Image'),
      BlenderMenuItem<String>(value: 'Text', label: 'Text'),
      BlenderMenuItem<String>(value: 'Color', label: 'Color'),
      BlenderMenuItem<String>(value: 'Sound', label: 'Sound'),
    ];

    return <BlenderPropertyGroup>[
      BlenderPropertyFactory.panel(
        'strip-crop',
        'Crop',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'strip-crop-min-x',
            'Min X',
            0,
            min: -10000,
            max: 10000,
          ),
          BlenderPropertyFactory.number(
            'strip-crop-max-x',
            'Max X',
            1920,
            min: -10000,
            max: 10000,
          ),
          BlenderPropertyFactory.number(
            'strip-crop-max-y',
            'Max Y',
            1080,
            min: -10000,
            max: 10000,
          ),
          BlenderPropertyFactory.number(
            'strip-crop-min-y',
            'Min Y',
            0,
            min: -10000,
            max: 10000,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-effect',
        'Effect Strip',
        initiallyExpanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.menu(
            'strip-effect-type',
            'Type',
            'Color',
            stripTypes,
          ),
          BlenderPropertyFactory.boolean(
            'strip-default-fade',
            'Default Fade',
            true,
          ),
          BlenderPropertyFactory.number(
            'strip-effect-fader',
            'Effect Fader',
            1,
            min: 0,
            max: 1,
          ),
          BlenderPropertyFactory.menu(
            'strip-blend-mode',
            'Blend Mode',
            'Replace',
            blendModes,
          ),
          BlenderPropertyFactory.number(
            'strip-factor',
            'Factor',
            1,
            min: 0,
            max: 1,
          ),
        ],
        children: <BlenderPropertyGroup>[
          BlenderPropertyFactory.panel(
            'strip-effect-layout',
            'Layout',
            initiallyExpanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'strip-text-location-x',
                'Location X',
                0,
              ),
              BlenderPropertyFactory.number(
                'strip-text-location-y',
                'Location Y',
                0,
              ),
              BlenderPropertyFactory.menu(
                'strip-text-alignment',
                'Alignment',
                'Center',
                const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Left', label: 'Left'),
                  BlenderMenuItem<String>(value: 'Center', label: 'Center'),
                  BlenderMenuItem<String>(value: 'Right', label: 'Right'),
                ],
              ),
              BlenderPropertyFactory.number(
                'strip-text-anchor-x',
                'Anchor X',
                .5,
                min: 0,
                max: 1,
              ),
              BlenderPropertyFactory.number(
                'strip-text-anchor-y',
                'Anchor Y',
                .5,
                min: 0,
                max: 1,
              ),
            ],
          ),
          BlenderPropertyFactory.panel(
            'strip-effect-style',
            'Style',
            initiallyExpanded: true,
            properties: <BlenderPropertyDescriptor<dynamic>>[
              BlenderPropertyFactory.number(
                'strip-font-size',
                'Font Size',
                48,
                min: 1,
                max: 512,
                decimalDigits: 0,
              ),
              BlenderPropertyFactory.boolean('strip-bold', 'Bold', false),
              BlenderPropertyFactory.boolean('strip-italic', 'Italic', false),
              BlenderPropertyFactory.number(
                'strip-line-spacing',
                'Line Spacing',
                1,
                min: 0,
              ),
            ],
            children: <BlenderPropertyGroup>[
              BlenderPropertyFactory.panel(
                'strip-effect-outline',
                'Outline',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'strip-outline-enabled',
                    'Enabled',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'strip-outline-width',
                    'Width',
                    1,
                    min: 0,
                  ),
                ],
              ),
              BlenderPropertyFactory.panel(
                'strip-effect-shadow',
                'Shadow',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'strip-shadow-enabled',
                    'Enabled',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'strip-shadow-angle',
                    'Angle',
                    45,
                    min: -180,
                    max: 180,
                  ),
                  BlenderPropertyFactory.number(
                    'strip-shadow-offset',
                    'Offset',
                    2,
                    min: 0,
                  ),
                  BlenderPropertyFactory.number(
                    'strip-shadow-blur',
                    'Blur',
                    0,
                    min: 0,
                  ),
                ],
              ),
              BlenderPropertyFactory.panel(
                'strip-effect-box',
                'Box',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyFactory.boolean(
                    'strip-box-enabled',
                    'Enabled',
                    false,
                  ),
                  BlenderPropertyFactory.number(
                    'strip-box-margin',
                    'Margin',
                    .05,
                    min: 0,
                    max: 1,
                  ),
                  BlenderPropertyFactory.number(
                    'strip-box-roundness',
                    'Roundness',
                    .1,
                    min: 0,
                    max: 1,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-source',
        'Source',
        initiallyExpanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.menu(
            'strip-source-type',
            'Type',
            'Movie',
            stripTypes,
          ),
          BlenderPropertyFactory.boolean(
            'strip-use-memory-cache',
            'Memory Cache',
            true,
          ),
          BlenderPropertyFactory.menu(
            'strip-alpha-mode',
            'Alpha',
            'Straight',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Straight', label: 'Straight'),
              BlenderMenuItem<String>(
                value: 'Premultiplied',
                label: 'Premultiplied',
              ),
            ],
          ),
          BlenderPropertyFactory.number(
            'strip-stream-index',
            'Stream Index',
            0,
            min: 0,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.boolean(
            'strip-deinterlace',
            'Deinterlace',
            false,
          ),
          BlenderPropertyFactory.boolean('strip-multiview', 'Multiview', false),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-movie-clip',
        'Movie Clip',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.menu(
            'strip-movie-clip-id',
            'Clip',
            'Tracking Clip',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Tracking Clip',
                label: 'Tracking Clip',
              ),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          BlenderPropertyFactory.boolean(
            'strip-stabilize',
            '2D Stabilized Clip',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'strip-undistort',
            'Undistorted Clip',
            false,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-scene',
        'Scene',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.menu(
            'strip-scene-id',
            'Scene',
            'Scene',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Scene', label: 'Scene'),
              BlenderMenuItem<String>(value: 'Scene.001', label: 'Scene.001'),
            ],
          ),
          BlenderPropertyFactory.menu(
            'strip-scene-input',
            'Input',
            'Camera',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Camera', label: 'Camera'),
              BlenderMenuItem<String>(value: 'Sequencer', label: 'Sequencer'),
            ],
          ),
          BlenderPropertyFactory.boolean(
            'strip-scene-annotations',
            'Annotations',
            false,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-sound',
        'Sound',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'strip-volume',
            'Volume',
            1,
            min: 0,
            max: 2,
          ),
          BlenderPropertyFactory.number('strip-pan', 'Pan', 0, min: -1, max: 1),
          BlenderPropertyFactory.boolean(
            'strip-pitch-correction',
            'Pitch Correction',
            false,
          ),
          BlenderPropertyFactory.boolean('strip-waveform', 'Waveform', true),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-mask',
        'Mask',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.menu(
            'strip-mask-id',
            'Mask',
            'Roto Mask',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Roto Mask', label: 'Roto Mask'),
              BlenderMenuItem<String>(value: 'None', label: 'None'),
            ],
          ),
          BlenderPropertyFactory.boolean('strip-mask-use', 'Use Mask', true),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-time',
        'Time',
        initiallyExpanded: true,
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'strip-channel',
            'Channel',
            1,
            min: 1,
            max: 128,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'strip-left-handle',
            'Left Handle',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'strip-right-handle',
            'Right Handle',
            48,
            min: 1,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'strip-content-start',
            'Content Start',
            1,
            min: 0,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'strip-content-duration',
            'Content Duration',
            48,
            min: 1,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.number(
            'strip-playhead-offset',
            'Playhead Offset',
            0,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.boolean('strip-lock', 'Lock', false),
          BlenderPropertyFactory.boolean(
            'strip-show-retiming-keys',
            'Retiming Keys',
            true,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-adjust-sound',
        'Sound Adjustment',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'strip-adjust-volume',
            'Volume',
            1,
            min: 0,
            max: 2,
          ),
          BlenderPropertyFactory.number(
            'strip-adjust-pan',
            'Pan',
            0,
            min: -1,
            max: 1,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-compositing',
        'Compositing',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.menu(
            'strip-compositing-blend',
            'Blend',
            'Replace',
            blendModes,
          ),
          BlenderPropertyFactory.number(
            'strip-compositing-opacity',
            'Opacity',
            1,
            min: 0,
            max: 1,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-transform',
        'Transform',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.menu(
            'strip-transform-filter',
            'Filter',
            'Bilinear',
            const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'Nearest', label: 'Nearest'),
              BlenderMenuItem<String>(value: 'Bilinear', label: 'Bilinear'),
            ],
          ),
          BlenderPropertyFactory.number(
            'strip-transform-position-x',
            'Position X',
            0,
          ),
          BlenderPropertyFactory.number(
            'strip-transform-position-y',
            'Position Y',
            0,
          ),
          BlenderPropertyFactory.number(
            'strip-transform-scale-x',
            'Scale X',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'strip-transform-scale-y',
            'Scale Y',
            1,
            min: 0,
          ),
          BlenderPropertyFactory.number(
            'strip-transform-rotation',
            'Rotation',
            0,
            min: -360,
            max: 360,
          ),
          BlenderPropertyFactory.boolean('strip-flip-x', 'Flip X', false),
          BlenderPropertyFactory.boolean('strip-flip-y', 'Flip Y', false),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-video',
        'Video',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'strip-strobe',
            'Strobe',
            1,
            min: 1,
            decimalDigits: 0,
          ),
          BlenderPropertyFactory.boolean(
            'strip-reverse-frames',
            'Reverse Frames',
            false,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-color',
        'Color',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'strip-saturation',
            'Saturation',
            1,
            min: 0,
            max: 2,
          ),
          BlenderPropertyFactory.number(
            'strip-multiply',
            'Multiply',
            1,
            min: 0,
            max: 2,
          ),
          BlenderPropertyFactory.boolean(
            'strip-multiply-alpha',
            'Multiply Alpha',
            false,
          ),
          BlenderPropertyFactory.boolean(
            'strip-use-float',
            'Convert to Float',
            false,
          ),
        ],
      ),
      BlenderPropertyFactory.panel(
        'strip-custom-properties',
        'Custom Properties',
        properties: <BlenderPropertyDescriptor<dynamic>>[
          BlenderPropertyFactory.number(
            'strip-custom-value',
            'example_value',
            1,
          ),
        ],
      ),
      const BlenderPropertyGroup(
        id: 'strip-modifiers',
        title: 'Modifiers',
        initiallyExpanded: false,
        properties: const <BlenderPropertyDescriptor<dynamic>>[],
        content: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderButton(label: 'Add Modifier', onPressed: _noop),
            const SizedBox(height: 6),
            BlenderPanel(
              title: 'Color Balance',
              initiallyExpanded: true,
              child: const BlenderPropertyRow(
                label: 'Lift',
                editor: BlenderNumberField(value: 1, onChanged: _noopDouble),
              ),
            ),
            const SizedBox(height: 4),
            BlenderPanel(
              title: 'Transform',
              initiallyExpanded: false,
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BlenderPropertiesEditor(title: title, groups: _groups());
  }
}

void _noop() {}

void _noopDouble(double _) {}
