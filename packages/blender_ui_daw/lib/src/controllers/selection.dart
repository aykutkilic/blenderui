/// Transient editor selection. It intentionally lives outside [DawProject]
/// because selecting an item must not dirty, persist, or synchronize a song.
class DawSelection {
  DawSelection({
    this.trackId,
    this.clipId,
    Set<String> noteIds = const <String>{},
    this.automationLaneId,
    this.automationPointId,
  }) : noteIds = Set<String>.unmodifiable(noteIds);

  final String? trackId;
  final String? clipId;
  final Set<String> noteIds;
  final String? automationLaneId;
  final String? automationPointId;

  DawSelection copyWith({
    String? trackId,
    String? clipId,
    Set<String>? noteIds,
    String? automationLaneId,
    String? automationPointId,
    bool clearClip = false,
    bool clearNotes = false,
  }) => DawSelection(
    trackId: trackId ?? this.trackId,
    clipId: clearClip ? null : clipId ?? this.clipId,
    noteIds: clearNotes ? const <String>{} : noteIds ?? this.noteIds,
    automationLaneId: automationLaneId ?? this.automationLaneId,
    automationPointId: automationPointId ?? this.automationPointId,
  );
}
