import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../services/midi_devices.dart';

class DawMidiPreferencesPanel extends StatelessWidget {
  const DawMidiPreferencesPanel({super.key, required this.devices});

  final DawNativeMidiDeviceService devices;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: devices,
    builder: (context, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _EndpointGroup(label: 'MIDI Inputs', endpoints: devices.inputs),
        const SizedBox(height: 8),
        _EndpointGroup(label: 'MIDI Outputs', endpoints: devices.outputs),
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            BlenderButton(
              label: devices.scanning ? 'Scanning…' : 'Refresh MIDI Devices',
              onPressed: devices.scanning ? null : devices.refresh,
            ),
            const SizedBox(width: 8),
            if (devices.error != null)
              Expanded(child: Text('MIDI error: ${devices.error}')),
          ],
        ),
      ],
    ),
  );
}

class _EndpointGroup extends StatelessWidget {
  const _EndpointGroup({required this.label, required this.endpoints});

  final String label;
  final List<DawMidiEndpoint> endpoints;

  @override
  Widget build(BuildContext context) => BlenderPanel(
    title: label,
    initiallyExpanded: true,
    child: endpoints.isEmpty
        ? const Padding(
            padding: EdgeInsets.all(8),
            child: Text('No endpoints discovered'),
          )
        : Column(
            children: <Widget>[
              for (final endpoint in endpoints)
                BlenderPropertyRow(
                  label: endpoint.name,
                  editor: Text(
                    <String>[
                      if (endpoint.manufacturer.isNotEmpty)
                        endpoint.manufacturer,
                      if (endpoint.model.isNotEmpty) endpoint.model,
                      endpoint.online ? 'Online' : 'Offline',
                    ].join(' · '),
                  ),
                ),
            ],
          ),
  );
}
