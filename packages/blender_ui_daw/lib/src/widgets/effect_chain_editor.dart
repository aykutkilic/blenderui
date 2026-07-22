import 'dart:async';

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/session_controller.dart';
import '../controllers/session_plugin_commands.dart';
import '../model/project.dart';
import '../services/audio_engine.dart';
import '../services/plugin_host.dart';
import 'compact_level_meter.dart';
import 'editor_shared.dart';
import 'plugin_drag.dart';

/// Horizontal, track-owned device chain with typed plug-in drop insertion.
/// DSP hosting and metering remain behind service interfaces.
class DawEffectChainEditor extends StatefulWidget {
  const DawEffectChainEditor({
    super.key,
    required this.session,
    required this.host,
    required this.audioEngine,
  });

  final DawSessionController session;
  final DawPluginHost host;
  final DawAudioEngine audioEngine;

  @override
  State<DawEffectChainEditor> createState() => _DawEffectChainEditorState();
}

class _DawEffectChainEditorState extends State<DawEffectChainEditor> {
  String? _trackId;
  String? _loadError;

  DawTrack get _track {
    final id = _trackId ?? widget.session.selection.trackId;
    if (id == widget.session.project.master.id) {
      return widget.session.project.master;
    }
    return widget.session.project.tracks.firstWhere(
      (track) => track.id == id,
      orElse: () => widget.session.project.master,
    );
  }

  List<DawTrack> get _tracks => <DawTrack>[
    ...widget.session.project.tracks,
    widget.session.project.master,
  ];

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge(<Listenable>[
      widget.session,
      widget.host,
      widget.audioEngine,
    ]),
    builder: (context, _) {
      final track = _track;
      final peak =
          widget.audioEngine.meters.trackPeaks[track.id] ??
          widget.audioEngine.meters.masterPeak;
      return BlenderEditorFrame(
        child: Column(
          children: <Widget>[
            DawEditorHeader(
              title: 'Effect Chain',
              menus: const <String>['View', 'Select', 'Device'],
              actions: <Widget>[
                SizedBox(
                  width: 150,
                  child: BlenderDropdown<String>(
                    value: track.id,
                    items: <BlenderMenuItem<String>>[
                      for (final candidate in _tracks)
                        BlenderMenuItem<String>(
                          value: candidate.id,
                          label: candidate.name,
                        ),
                    ],
                    onChanged: (value) => setState(() => _trackId = value),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: BlenderDropdown<String>(
                    value: null,
                    selectedLabel: 'Add Effect',
                    items: <BlenderMenuItem<String>>[
                      for (final plugin in widget.host.catalog)
                        if (plugin.category != DawPluginCategory.instrument)
                          BlenderMenuItem<String>(
                            value: plugin.id,
                            label: plugin.name,
                            enabled: plugin.loadable,
                            description: plugin.unavailableReason,
                          ),
                    ],
                    onChanged: (pluginId) =>
                        _addPlugin(track.id, pluginId, track.plugins.length),
                  ),
                ),
              ],
            ),
            if (_loadError != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: BlenderTheme.of(context).colors.error,
                child: Text(
                  _loadError!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(10),
                  child: SizedBox(
                    height: constraints.maxHeight - 20,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _EndpointCard(label: '${track.name} In', peak: peak),
                        _ChainDropTarget(
                          index: 0,
                          onDrop: (payload) =>
                              _addPlugin(track.id, payload.descriptor.id, 0),
                        ),
                        for (
                          var index = 0;
                          index < track.plugins.length;
                          index++
                        ) ...<Widget>[
                          _EffectCard(
                            plugin: track.plugins[index],
                            instance: _instanceFor(track.plugins[index].id),
                            peak:
                                widget.audioEngine.meters.devicePeaks[track
                                    .plugins[index]
                                    .id] ??
                                peak,
                            canMoveLeft: index > 0,
                            canMoveRight: index < track.plugins.length - 1,
                            onMoveLeft: () => widget.session.movePlugin(
                              track.id,
                              index,
                              index - 1,
                            ),
                            onMoveRight: () => widget.session.movePlugin(
                              track.id,
                              index,
                              index + 1,
                            ),
                            onEnabled: (value) => _setPluginEnabled(
                              track.id,
                              track.plugins[index].id,
                              value,
                            ),
                            onWet: (value) => widget.session.setPluginWet(
                              track.id,
                              track.plugins[index].id,
                              value,
                            ),
                            onParameter: (parameter, value) =>
                                widget.host.setParameter(
                                  track.plugins[index].id,
                                  parameter.id,
                                  value,
                                ),
                            onRemove: () => _removePlugin(track, index),
                          ),
                          _ChainDropTarget(
                            index: index + 1,
                            onDrop: (payload) => _addPlugin(
                              track.id,
                              payload.descriptor.id,
                              index + 1,
                            ),
                          ),
                        ],
                        _EndpointCard(label: 'Chain Out', peak: peak),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );

  DawPluginInstance? _instanceFor(String instanceId) {
    for (final instance in widget.host.instances) {
      if (instance.instanceId == instanceId) return instance;
    }
    return null;
  }

  Future<void> _addPlugin(String trackId, String pluginId, int index) async {
    setState(() => _loadError = null);
    try {
      final instance = await widget.host.instantiate(pluginId);
      if (!mounted) {
        await widget.host.remove(instance.instanceId);
        return;
      }
      widget.session.addPlugin(
        trackId,
        DawPluginSlot(
          id: instance.instanceId,
          pluginId: pluginId,
          name: instance.descriptor.name,
        ),
        index: index,
      );
    } catch (error) {
      if (mounted) setState(() => _loadError = 'Could not load device: $error');
    }
  }

  Future<void> _removePlugin(DawTrack track, int index) async {
    final slot = track.plugins[index];
    widget.session.removePlugin(track.id, slot.id);
    try {
      await widget.host.remove(slot.id);
    } catch (error) {
      if (mounted)
        setState(() => _loadError = 'Could not unload device: $error');
    }
  }

  void _setPluginEnabled(String trackId, String instanceId, bool enabled) {
    widget.session.setPluginEnabled(trackId, instanceId, enabled);
    unawaited(
      widget.host.setEnabled(instanceId, enabled).catchError((Object error) {
        if (mounted) {
          setState(() => _loadError = 'Could not change device bypass: $error');
        }
      }),
    );
  }
}

class _ChainDropTarget extends StatefulWidget {
  const _ChainDropTarget({required this.index, required this.onDrop});

  final int index;
  final ValueChanged<DawPluginDragPayload> onDrop;

  @override
  State<_ChainDropTarget> createState() => _ChainDropTargetState();
}

class _ChainDropTargetState extends State<_ChainDropTarget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => DragTarget<DawPluginDragPayload>(
    onWillAcceptWithDetails: (details) => details.data.descriptor.loadable,
    onMove: (_) {
      if (!_hovered) setState(() => _hovered = true);
    },
    onLeave: (_) => setState(() => _hovered = false),
    onAcceptWithDetails: (details) {
      setState(() => _hovered = false);
      widget.onDrop(details.data);
    },
    builder: (context, _, _) => AnimatedContainer(
      key: ValueKey<String>('daw-effect-chain-drop-${widget.index}'),
      duration: const Duration(milliseconds: 90),
      width: _hovered ? 34 : 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: _hovered ? BlenderTheme.of(context).colors.selection : null,
        borderRadius: BorderRadius.circular(3),
      ),
      child: _hovered
          ? const Center(child: BlenderIcon(BlenderGlyph.plus, size: 13))
          : null,
    ),
  );
}

class _EndpointCard extends StatelessWidget {
  const _EndpointCard({required this.label, required this.peak});

  final String label;
  final double peak;

  @override
  Widget build(BuildContext context) => Container(
    width: 82,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: BlenderTheme.of(context).colors.surface,
      border: Border.all(color: BlenderTheme.of(context).colors.border),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DawCompactLevelMeter(level: peak),
        const SizedBox(width: 7),
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    ),
  );
}

class _EffectCard extends StatelessWidget {
  const _EffectCard({
    required this.plugin,
    required this.instance,
    required this.peak,
    required this.canMoveLeft,
    required this.canMoveRight,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onEnabled,
    required this.onWet,
    required this.onParameter,
    required this.onRemove,
  });

  final DawPluginSlot plugin;
  final DawPluginInstance? instance;
  final double peak;
  final bool canMoveLeft;
  final bool canMoveRight;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<double> onWet;
  final void Function(DawPluginParameter parameter, double value) onParameter;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = BlenderTheme.of(context).colors;
    final parameters =
        instance?.parameters.take(3) ?? const <DawPluginParameter>[];
    return Container(
      width: 188,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.panelBackground,
        border: Border.all(
          color: plugin.enabled ? colors.accent : colors.border,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.radio,
                size: 20,
                iconSize: 11,
                selected: plugin.enabled,
                tooltip: plugin.enabled ? 'Disable Device' : 'Enable Device',
                onPressed: () => onEnabled(!plugin.enabled),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  plugin.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DawCompactLevelMeter(level: plugin.enabled ? peak : 0),
              const SizedBox(width: 3),
              BlenderIconButton(
                glyph: BlenderGlyph.close,
                size: 20,
                iconSize: 11,
                tooltip: 'Remove Device',
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final parameter in parameters)
            _ParameterRow(
              parameter: parameter,
              onChanged: (value) => onParameter(parameter, value),
            ),
          const Text('Dry / Wet'),
          BlenderSlider(value: plugin.wet, onChanged: onWet),
          const Spacer(),
          Row(
            children: <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.stepBack,
                size: 20,
                iconSize: 11,
                enabled: canMoveLeft,
                onPressed: onMoveLeft,
              ),
              BlenderIconButton(
                glyph: BlenderGlyph.stepForward,
                size: 20,
                iconSize: 11,
                enabled: canMoveRight,
                onPressed: onMoveRight,
              ),
              const Spacer(),
              Text('${(plugin.wet * 100).round()}%'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ParameterRow extends StatelessWidget {
  const _ParameterRow({required this.parameter, required this.onChanged});

  final DawPluginParameter parameter;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 3),
    child: Row(
      children: <Widget>[
        SizedBox(
          width: 58,
          child: Text(
            parameter.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: BlenderSlider(value: parameter.value, onChanged: onChanged),
        ),
      ],
    ),
  );
}
