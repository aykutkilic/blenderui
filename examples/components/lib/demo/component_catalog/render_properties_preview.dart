part of '../component_catalog.dart';

extension _ComponentCatalogRenderPropertiesPreview
    on _ComponentCatalogExampleState {
  Widget _buildRenderPropertiesPreview() {
    return SizedBox(
      height: 430,
      child: BlenderPropertiesEditor(
        title: 'Render Engine',
        groups: <BlenderPropertyGroup>[
          BlenderPropertyGroup(
            id: 'sampling',
            title: 'Sampling',
            properties: const <BlenderPropertyDescriptor<dynamic>>[],
            children: <BlenderPropertyGroup>[
              BlenderPropertyGroup(
                id: 'viewport',
                title: 'Viewport',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<double>(
                    id: 'viewport-samples',
                    label: 'Samples',
                    value: _viewportSamples,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 1,
                          max: 128,
                          decimalDigits: 0,
                          onChanged: changed,
                        ),
                    onChanged: (value) => _updatePreview(() {
                      _viewportSamples = value;
                      _status = 'Viewport samples: ${value.round()}';
                    }),
                  ),
                  BlenderPropertyDescriptor<bool>(
                    id: 'temporal-reprojection',
                    label: 'Temporal Reprojection',
                    value: _temporalReprojection,
                    editorBuilder: (context, value, changed) =>
                        BlenderCheckbox(value: value, onChanged: changed),
                    onChanged: (value) => _updatePreview(() {
                      _temporalReprojection = value;
                      _status = 'Temporal reprojection: $value';
                    }),
                  ),
                  BlenderPropertyDescriptor<bool>(
                    id: 'jittered-shadows',
                    label: 'Jittered Shadows',
                    value: _jitteredShadows,
                    editorBuilder: (context, value, changed) =>
                        BlenderCheckbox(value: value, onChanged: changed),
                    onChanged: (value) => _updatePreview(() {
                      _jitteredShadows = value;
                      _status = 'Jittered shadows: $value';
                    }),
                  ),
                ],
              ),
              BlenderPropertyGroup(
                id: 'render',
                title: 'Render',
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<double>(
                    id: 'render-samples',
                    label: 'Samples',
                    value: _renderSamples,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 1,
                          max: 256,
                          decimalDigits: 0,
                          onChanged: changed,
                        ),
                    onChanged: (value) => _updatePreview(() {
                      _renderSamples = value;
                      _status = 'Render samples: ${value.round()}';
                    }),
                  ),
                ],
              ),
              BlenderPropertyGroup(
                id: 'shadows',
                title: 'Shadows',
                enabled: _shadowsEnabled,
                headerLeading: BlenderCheckbox(
                  value: _shadowsEnabled,
                  onChanged: (value) => _updatePreview(() {
                    _shadowsEnabled = value;
                    _status = 'Shadows: ${value ? 'enabled' : 'disabled'}';
                  }),
                ),
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<double>(
                    id: 'shadow-rays',
                    label: 'Rays',
                    value: _shadowRays,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 1,
                          max: 16,
                          decimalDigits: 0,
                          onChanged: changed,
                        ),
                    onChanged: (value) => _updatePreview(() {
                      _shadowRays = value;
                      _status = 'Shadow rays: ${value.round()}';
                    }),
                  ),
                  BlenderPropertyDescriptor<double>(
                    id: 'shadow-steps',
                    label: 'Steps',
                    value: _shadowSteps,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 1,
                          max: 16,
                          decimalDigits: 0,
                          onChanged: changed,
                        ),
                    onChanged: (value) => _updatePreview(() {
                      _shadowSteps = value;
                      _status = 'Shadow steps: ${value.round()}';
                    }),
                  ),
                  BlenderPropertyDescriptor<double>(
                    id: 'shadow-resolution',
                    label: 'Resolution',
                    value: _shadowResolution,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 0,
                          max: 1,
                          step: .01,
                          showSteppers: false,
                          onChanged: changed,
                        ),
                    onChanged: (value) => _updatePreview(() {
                      _shadowResolution = value;
                      _status = 'Resolution: ${(value * 100).round()}%';
                    }),
                  ),
                ],
                children: <BlenderPropertyGroup>[
                  BlenderPropertyGroup(
                    id: 'volume-shadows',
                    title: 'Volume Shadows',
                    enabled: _volumeShadowsEnabled,
                    headerLeading: BlenderCheckbox(
                      value: _volumeShadowsEnabled,
                      onChanged: _shadowsEnabled
                          ? (value) => _updatePreview(() {
                              _volumeShadowsEnabled = value;
                              _status =
                                  'Volume Shadows: ${value ? 'enabled' : 'disabled'}';
                            })
                          : null,
                    ),
                    properties: <BlenderPropertyDescriptor<dynamic>>[
                      BlenderPropertyDescriptor<double>(
                        id: 'volume-shadow-steps',
                        label: 'Steps',
                        value: _volumeShadowSteps,
                        editorBuilder: (context, value, changed) =>
                            BlenderNumberField(
                              value: value,
                              min: 1,
                              max: 64,
                              decimalDigits: 0,
                              onChanged: changed,
                            ),
                        onChanged: (value) => _updatePreview(() {
                          _volumeShadowSteps = value;
                          _status = 'Volume shadow steps: ${value.round()}';
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              BlenderPropertyGroup(
                id: 'advanced',
                title: 'Advanced',
                initiallyExpanded: false,
                properties: <BlenderPropertyDescriptor<dynamic>>[
                  BlenderPropertyDescriptor<double>(
                    id: 'light-threshold',
                    label: 'Light Threshold',
                    value: _lightThreshold,
                    editorBuilder: (context, value, changed) =>
                        BlenderNumberField(
                          value: value,
                          min: 0,
                          max: 1,
                          step: .01,
                          onChanged: changed,
                        ),
                    onChanged: (value) => _updatePreview(() {
                      _lightThreshold = value;
                      _status = 'Light threshold: ${value.toStringAsFixed(2)}';
                    }),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
