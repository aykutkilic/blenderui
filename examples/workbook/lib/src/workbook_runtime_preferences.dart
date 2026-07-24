import 'dart:async';

import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter/material.dart';

import 'workbook_runtime_settings.dart';

final class WorkbookRuntimePreferencesPanel extends StatefulWidget {
  const WorkbookRuntimePreferencesPanel({
    required this.settings,
    required this.installer,
    required this.runtimeStatus,
    required this.initialToken,
    required this.busy,
    required this.onSettingsChanged,
    required this.onTokenChanged,
    required this.onInstallAndConnect,
    required this.onConnect,
    required this.onDisconnect,
    super.key,
  });

  final WorkbookRuntimeSettings Function() settings;
  final JupyterRuntimeInstaller installer;
  final String Function() runtimeStatus;
  final String initialToken;
  final bool Function() busy;
  final Future<void> Function(WorkbookRuntimeSettings) onSettingsChanged;
  final ValueChanged<String> onTokenChanged;
  final Future<void> Function() onInstallAndConnect;
  final Future<void> Function() onConnect;
  final Future<void> Function() onDisconnect;

  @override
  State<WorkbookRuntimePreferencesPanel> createState() =>
      _WorkbookRuntimePreferencesPanelState();
}

final class _WorkbookRuntimePreferencesPanelState
    extends State<WorkbookRuntimePreferencesPanel> {
  late WorkbookRuntimeSettings _settings = widget.settings();
  late final TextEditingController _python = TextEditingController(
    text: _settings.pythonExecutable,
  );
  late final TextEditingController _server = TextEditingController(
    text: _settings.serverUrl,
  );
  late final TextEditingController _token = TextEditingController(
    text: widget.initialToken,
  );
  late final TextEditingController _lsp = TextEditingController(
    text: _settings.languageServerUrl,
  );
  var _acting = false;

  void _update(WorkbookRuntimeSettings value) {
    setState(() => _settings = value);
    unawaited(widget.onSettingsChanged(value));
  }

  Future<void> _perform(Future<void> Function() action) async {
    setState(() => _acting = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.installer,
    builder: (context, _) {
      final managed = _settings.mode == WorkbookRuntimeMode.managed;
      final remote = _settings.mode == WorkbookRuntimeMode.remote;
      final busy = _acting || widget.busy() || widget.installer.busy;
      return blenderFormColumn(<Widget>[
        Text(widget.runtimeStatus()),
        const SizedBox(height: 10),
        BlenderDropdown<WorkbookRuntimeMode>(
          value: _settings.mode,
          items: const <BlenderMenuItem<WorkbookRuntimeMode>>[
            BlenderMenuItem(
              value: WorkbookRuntimeMode.offline,
              label: 'Offline (edit and read files)',
            ),
            BlenderMenuItem(
              value: WorkbookRuntimeMode.managed,
              label: 'Managed local Jupyter',
            ),
            BlenderMenuItem(
              value: WorkbookRuntimeMode.custom,
              label: 'Custom local Python',
            ),
            BlenderMenuItem(
              value: WorkbookRuntimeMode.remote,
              label: 'Remote Jupyter Server',
            ),
          ],
          onChanged: busy
              ? null
              : (value) => _update(_settings.copyWith(mode: value)),
        ),
        const SizedBox(height: 8),
        BlenderCheckbox(
          value: _settings.autoConnect,
          label: 'Connect this runtime when the app starts',
          onChanged: (value) => _update(_settings.copyWith(autoConnect: value)),
        ),
        const SizedBox(height: 12),
        if (!remote) ...<Widget>[
          Text(managed ? 'Base Python used by installer' : 'Python executable'),
          const SizedBox(height: 4),
          BlenderTextField(
            controller: _python,
            placeholder: 'python3',
            onChanged: (value) =>
                _update(_settings.copyWith(pythonExecutable: value)),
          ),
        ],
        if (remote) ...<Widget>[
          const Text('Jupyter Server URL'),
          const SizedBox(height: 4),
          BlenderTextField(
            controller: _server,
            placeholder: 'http://127.0.0.1:8888',
            onChanged: (value) => _update(_settings.copyWith(serverUrl: value)),
          ),
          const SizedBox(height: 8),
          const Text('Access token (kept in memory; not persisted)'),
          const SizedBox(height: 4),
          BlenderTextField(
            controller: _token,
            obscureText: true,
            onChanged: widget.onTokenChanged,
          ),
        ],
        const SizedBox(height: 12),
        const Text('Language Server URL (optional for remote runtimes)'),
        const SizedBox(height: 4),
        BlenderTextField(
          controller: _lsp,
          placeholder: 'ws://127.0.0.1:3001',
          onChanged: (value) =>
              _update(_settings.copyWith(languageServerUrl: value)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            if (managed)
              BlenderButton(
                label: widget.installer.busy
                    ? 'Installing…'
                    : 'Install Jupyter and Connect',
                onPressed: busy
                    ? null
                    : () => _perform(widget.onInstallAndConnect),
              ),
            BlenderButton(
              label: 'Connect',
              onPressed: busy || _settings.mode == WorkbookRuntimeMode.offline
                  ? null
                  : () => _perform(widget.onConnect),
            ),
            BlenderButton(
              label: 'Disconnect',
              onPressed: busy ? null : () => _perform(widget.onDisconnect),
            ),
            if (widget.installer.busy)
              BlenderButton(
                label: 'Cancel Installation',
                onPressed: widget.installer.cancel,
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(widget.installer.detail),
        if (widget.installer.logs.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          SelectableText(
            widget.installer.logs
                .skip(
                  widget.installer.logs.length > 12
                      ? widget.installer.logs.length - 12
                      : 0,
                )
                .join('\n'),
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
          ),
        ],
      ]);
    },
  );

  @override
  void dispose() {
    _python.dispose();
    _server.dispose();
    _token.dispose();
    _lsp.dispose();
    super.dispose();
  }
}
