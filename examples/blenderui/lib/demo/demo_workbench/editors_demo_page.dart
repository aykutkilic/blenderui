part of '../demo_workbench.dart';

class _EditorsDemoPage extends StatelessWidget {
  const _EditorsDemoPage({
    required this.state,
    required this.fileSearchController,
    required this.onChanged,
    required this.onStatus,
  });

  final DemoState state;
  final TextEditingController fileSearchController;
  final void Function(DemoState state, String message) onChanged;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    return _DemoPageScroll(
      children: <Widget>[
        _DemoSection(
          title: 'Timeline',
          description: 'Generic tracks and keyframes with pointer scrubbing.',
          child: BlenderTimeline(
            model: BlenderTimelineModel(
              start: 1,
              end: 120,
              currentFrame: state.frame,
              tracks: const <BlenderTimelineTrack>[
                BlenderTimelineTrack(
                  id: 'cube',
                  label: 'Cube',
                  keyframes: <BlenderTimelineKeyframe>[
                    BlenderTimelineKeyframe(1),
                    BlenderTimelineKeyframe(42),
                    BlenderTimelineKeyframe(96),
                  ],
                ),
                BlenderTimelineTrack(
                  id: 'camera',
                  label: 'Camera',
                  keyframes: <BlenderTimelineKeyframe>[
                    BlenderTimelineKeyframe(20),
                    BlenderTimelineKeyframe(84),
                  ],
                ),
              ],
            ),
            onCurrentFrameChanged: (frame) =>
                onChanged(state.copyWith(frame: frame), 'Timeline scrubbed'),
          ),
        ),
        _DemoSection(
          title: 'Console and spreadsheet',
          description: 'Complete non-3D editor surfaces compose like controls.',
          child: SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: BlenderConsoleEditor(
                    lines: const <BlenderConsoleLine>[
                      BlenderConsoleLine(
                        'Blender UI component workbench',
                        kind: BlenderConsoleLineKind.info,
                      ),
                      BlenderConsoleLine('>>> scene.objects.length'),
                      BlenderConsoleLine('3'),
                    ],
                    onCommand: (value) => onStatus('Console: $value'),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: BlenderSpreadsheetEditor(
                    columns: <BlenderSpreadsheetColumn>[
                      BlenderSpreadsheetColumn(id: 'name', label: 'Name'),
                      BlenderSpreadsheetColumn(id: 'type', label: 'Type'),
                    ],
                    rows: <BlenderSpreadsheetRow>[
                      BlenderSpreadsheetRow(
                        id: 'cube',
                        values: <String>['Cube', 'Mesh'],
                      ),
                      BlenderSpreadsheetRow(
                        id: 'light',
                        values: <String>['Light', 'Point'],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _DemoSection(
          title: 'File browser',
          description: 'Searchable caller-owned entries with list/grid modes.',
          child: SizedBox(
            height: 210,
            child: BlenderFileBrowser(
              searchController: fileSearchController,
              pathSegments: const <String>['/', 'demo', 'assets'],
              entries: const <BlenderFileEntry>[
                BlenderFileEntry(
                  path: '/demo/assets/materials.blend',
                  name: 'materials.blend',
                  detail: '1.2 MB',
                ),
                BlenderFileEntry(
                  path: '/demo/assets/textures',
                  name: 'textures',
                  isDirectory: true,
                  detail: 'Folder',
                ),
              ],
              onSelected: (entry) => onStatus('Selected ${entry.name}'),
              onOpen: (entry) => onStatus('Opened ${entry.name}'),
            ),
          ),
        ),
      ],
    );
  }
}
