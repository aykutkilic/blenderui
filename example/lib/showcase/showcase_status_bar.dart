import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

/// Showcase-specific status content composed from reusable library blocks.
class ShowcaseStatusBar extends StatelessWidget {
  const ShowcaseStatusBar({
    super.key,
    required this.status,
    required this.onStatus,
  });

  final String status;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    return BlenderStatusBar(
      left: <Widget>[
        const BlenderInputStatus(
          padding: EdgeInsets.zero,
          showBorder: false,
          items: <BlenderInputStatusItem>[
            BlenderInputStatusItem(event: 'LMB', label: 'Select'),
            BlenderInputStatusItem(event: 'MMB', label: 'Pan'),
          ],
        ),
        const SizedBox(width: 10),
        Text('Blender UI showcase  •  $status'),
      ],
      center: <Widget>[
        BlenderReportBanner(
          message: 'Saved "scene.blend"',
          level: BlenderNoticeLevel.success,
          onPressed: () => onStatus('Report details'),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 268,
          child: BlenderRunningJobsPanel(
            jobs: <BlenderJobProgress>[
              BlenderJobProgress(
                name: 'Building Asset Preview',
                progress: .68,
                icon: BlenderGlyph.assetManager,
                remainingTime: '00:12',
                elapsedTime: '00:08',
                onCancel: () => onStatus('Job canceled'),
              ),
            ],
          ),
        ),
      ],
      right: const <Widget>[
        BlenderStatusInfo(
          statusText: 'Scene 1  |  Collection  |  12 Objects',
          extensionStatus: BlenderExtensionStatus.updates,
          extensionCount: 2,
          versionText: 'Blender 4.5.0',
        ),
      ],
    );
  }
}
