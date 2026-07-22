import 'dart:async';

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

import '../controllers/session_controller.dart';
import '../controllers/session_plugin_commands.dart';
import '../model/project.dart';
import '../services/plugin_host.dart';
import 'editor_shared.dart';

/// Node-graph projection of a track or master DSP chain.
///
/// The ordered plug-in list is the canonical audio graph. Node positions are
/// presentation state; creating a connection reorders the target device after
/// the source, so the graphical and rack editors always remain synchronized.
class DawAudioGraphEditor extends StatefulWidget {
  const DawAudioGraphEditor({
    super.key,
    required this.session,
    required this.host,
  });

  final DawSessionController session;
  final DawPluginHost host;

  @override
  State<DawAudioGraphEditor> createState() => _DawAudioGraphEditorState();
}

class _DawAudioGraphEditorState extends State<DawAudioGraphEditor> {
  final Map<String, Map<String, Offset>> _positions =
      <String, Map<String, Offset>>{};
  String? _trackId;
  Set<String> _selectedNodes = const <String>{};

  DawTrack get _track {
    final id = _trackId ?? widget.session.selection.trackId;
    if (id == widget.session.project.master.id)
      return widget.session.project.master;
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
    animation: Listenable.merge(<Listenable>[widget.session, widget.host]),
    builder: (context, _) {
      final track = _track;
      final model = _modelFor(track);
      return BlenderEditorFrame(
        child: Column(
          children: <Widget>[
            DawEditorHeader(
              title: 'Audio Graph',
              menus: const <String>['View', 'Select', 'Add', 'Node'],
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
                    onChanged: (value) => setState(() {
                      _trackId = value;
                      _selectedNodes = const <String>{};
                    }),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: BlenderDropdown<String>(
                    value: null,
                    selectedLabel: 'Add Audio Node',
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
                    onChanged: (pluginId) => _addPlugin(track.id, pluginId),
                  ),
                ),
              ],
            ),
            Expanded(
              child: BlenderNodeEditor(
                key: ValueKey<String>('daw-audio-graph-${track.id}'),
                title: null,
                model: model,
                selectedNodeIds: _selectedNodes,
                onNodeSelectionChanged: (ids) =>
                    setState(() => _selectedNodes = ids),
                onNodesMoved: (moves) => setState(() {
                  final positions = _positions.putIfAbsent(
                    track.id,
                    () => <String, Offset>{},
                  );
                  for (final entry in moves.entries) {
                    positions[entry.key.id] = entry.value;
                  }
                }),
                onLinkCreated: (link) => _connect(track, link),
                snapIncrement: 20,
              ),
            ),
          ],
        ),
      );
    },
  );

  BlenderNodeGraphModel _modelFor(DawTrack track) {
    const socketColor = Color(0xFF79B8E8);
    final positions = _positions[track.id] ?? const <String, Offset>{};
    final nodes = <BlenderGraphNode>[
      BlenderGraphNode(
        id: 'input',
        title: '${track.name} Input',
        position: positions['input'] ?? const Offset(80, 220),
        size: const Size(170, 92),
        headerColor: Color(track.colorValue),
        outputs: const <BlenderNodeSocketDefinition>[
          BlenderNodeSocketDefinition(
            id: 'audio-out',
            label: 'Audio',
            color: socketColor,
          ),
        ],
      ),
      for (var index = 0; index < track.plugins.length; index++)
        BlenderGraphNode(
          id: track.plugins[index].id,
          title: track.plugins[index].name,
          position:
              positions[track.plugins[index].id] ??
              Offset(330 + index * 240, 190),
          size: const Size(190, 126),
          muted: !track.plugins[index].enabled,
          label: 'Wet ${(track.plugins[index].wet * 100).round()}%',
          inputs: const <BlenderNodeSocketDefinition>[
            BlenderNodeSocketDefinition(
              id: 'audio-in',
              label: 'Audio',
              color: socketColor,
            ),
          ],
          outputs: const <BlenderNodeSocketDefinition>[
            BlenderNodeSocketDefinition(
              id: 'audio-out',
              label: 'Audio',
              color: socketColor,
            ),
          ],
        ),
      BlenderGraphNode(
        id: 'output',
        title: track.id == widget.session.project.master.id
            ? 'Audio Device'
            : '${track.name} Output',
        position:
            positions['output'] ??
            Offset(350 + track.plugins.length * 240, 220),
        size: const Size(180, 92),
        headerColor: const Color(0xFF7A4F86),
        inputs: const <BlenderNodeSocketDefinition>[
          BlenderNodeSocketDefinition(
            id: 'audio-in',
            label: 'Audio',
            color: socketColor,
          ),
        ],
      ),
    ];
    final chain = <String>[
      'input',
      for (final plugin in track.plugins) plugin.id,
      'output',
    ];
    return BlenderNodeGraphModel(
      nodes: nodes,
      links: <BlenderGraphLink>[
        for (var index = 0; index < chain.length - 1; index++)
          BlenderGraphLink(
            from: chain[index],
            fromSocket: 'audio-out',
            to: chain[index + 1],
            toSocket: 'audio-in',
            color: socketColor,
          ),
      ],
    );
  }

  void _connect(DawTrack track, BlenderGraphLink link) {
    final sourceIndex = track.plugins.indexWhere(
      (slot) => slot.id == link.from,
    );
    final targetIndex = track.plugins.indexWhere((slot) => slot.id == link.to);
    if (sourceIndex < 0 || targetIndex < 0 || sourceIndex == targetIndex) {
      return;
    }
    final insertion = targetIndex < sourceIndex ? sourceIndex : sourceIndex + 1;
    widget.session.movePlugin(track.id, targetIndex, insertion);
  }

  Future<void> _addPlugin(String trackId, String pluginId) async {
    final instance = await widget.host.instantiate(pluginId);
    widget.session.addPlugin(
      trackId,
      DawPluginSlot(
        id: instance.instanceId,
        pluginId: pluginId,
        name: instance.descriptor.name,
      ),
    );
  }
}
