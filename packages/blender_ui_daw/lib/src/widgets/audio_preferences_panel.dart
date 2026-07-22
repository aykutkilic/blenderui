import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/audio_device_controller.dart';

class DawAudioPreferencesPanel extends StatelessWidget {
  const DawAudioPreferencesPanel({super.key, required this.controller});

  final DawAudioDeviceController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final configuration = controller.configuration;
      return blenderFormColumn(<Widget>[
        BlenderPropertyRow(
          label: 'Output Device',
          editor: BlenderDropdown<String>(
            value: configuration?.deviceId,
            items: <BlenderMenuItem<String>>[
              for (final device in controller.devices)
                if (device.outputChannels > 0)
                  BlenderMenuItem<String>(
                    value: device.id,
                    label:
                        '${device.name} (${device.inputChannels} in / '
                        '${device.outputChannels} out)',
                  ),
            ],
            onChanged: controller.busy ? null : controller.selectDevice,
          ),
        ),
        BlenderPropertyRow(
          label: 'Input Device',
          editor: BlenderDropdown<String>(
            value: configuration?.inputDeviceId,
            selectedLabel: configuration?.inputDeviceId == null
                ? 'System Default'
                : null,
            items: <BlenderMenuItem<String>>[
              for (final device in controller.devices)
                if (device.inputChannels > 0)
                  BlenderMenuItem<String>(
                    value: device.id,
                    label: '${device.name} (${device.inputChannels} inputs)',
                  ),
            ],
            onChanged: controller.busy ? null : controller.selectInputDevice,
          ),
        ),
        BlenderPropertyRow(
          label: 'Sample Rate',
          editor: BlenderDropdown<int>(
            value: configuration?.sampleRate ?? 48000,
            items: const <BlenderMenuItem<int>>[
              BlenderMenuItem<int>(value: 44100, label: '44.1 kHz'),
              BlenderMenuItem<int>(value: 48000, label: '48 kHz'),
              BlenderMenuItem<int>(value: 88200, label: '88.2 kHz'),
              BlenderMenuItem<int>(value: 96000, label: '96 kHz'),
            ],
            onChanged: controller.busy ? null : controller.setSampleRate,
          ),
        ),
        BlenderPropertyRow(
          label: 'Buffer Size',
          editor: BlenderDropdown<int>(
            value: configuration?.bufferFrames ?? 256,
            items: const <BlenderMenuItem<int>>[
              BlenderMenuItem<int>(value: 32, label: '32 samples'),
              BlenderMenuItem<int>(value: 64, label: '64 samples'),
              BlenderMenuItem<int>(value: 128, label: '128 samples'),
              BlenderMenuItem<int>(value: 256, label: '256 samples'),
              BlenderMenuItem<int>(value: 512, label: '512 samples'),
              BlenderMenuItem<int>(value: 1024, label: '1024 samples'),
            ],
            onChanged: controller.busy ? null : controller.setBufferFrames,
          ),
        ),
        Row(
          children: <Widget>[
            BlenderButton(
              label: controller.busy ? 'Refreshing…' : 'Refresh Devices',
              onPressed: controller.busy ? null : controller.refreshDevices,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                controller.error == null
                    ? 'Engine: ${controller.engine.state.name}'
                    : 'Audio error: ${controller.error}',
              ),
            ),
          ],
        ),
      ]);
    },
  );
}
