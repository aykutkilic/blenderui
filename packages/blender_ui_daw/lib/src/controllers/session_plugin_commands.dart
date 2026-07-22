import '../model/project.dart';
import 'session_controller.dart';

/// Plug-in chain mutations kept separate from timeline editing concerns.
extension DawSessionPluginCommands on DawSessionController {
  void addPlugin(String trackId, DawPluginSlot plugin, {int? index}) {
    updateTrack(trackId, (track) {
      final plugins = List<DawPluginSlot>.of(track.plugins);
      plugins.insert(
        (index ?? plugins.length).clamp(0, plugins.length),
        plugin,
      );
      return track.copyWith(plugins: plugins);
    });
  }

  void removePlugin(String trackId, String slotId) => updateTrack(
    trackId,
    (track) => track.copyWith(
      plugins: track.plugins.where((plugin) => plugin.id != slotId).toList(),
    ),
  );

  void movePlugin(String trackId, int oldIndex, int newIndex) {
    updateTrack(trackId, (track) {
      if (oldIndex < 0 || oldIndex >= track.plugins.length) return track;
      final plugins = List<DawPluginSlot>.of(track.plugins);
      final plugin = plugins.removeAt(oldIndex);
      plugins.insert(newIndex.clamp(0, plugins.length), plugin);
      return track.copyWith(plugins: plugins);
    });
  }

  void setPluginEnabled(String trackId, String slotId, bool enabled) =>
      updateTrack(
        trackId,
        (track) => track.copyWith(
          plugins: <DawPluginSlot>[
            for (final plugin in track.plugins)
              if (plugin.id == slotId)
                plugin.copyWith(enabled: enabled)
              else
                plugin,
          ],
        ),
      );

  void setPluginWet(String trackId, String slotId, double wet) => updateTrack(
    trackId,
    (track) => track.copyWith(
      plugins: <DawPluginSlot>[
        for (final plugin in track.plugins)
          if (plugin.id == slotId) plugin.copyWith(wet: wet) else plugin,
      ],
    ),
  );
}
