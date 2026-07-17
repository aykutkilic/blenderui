import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

/// Showcase-specific status content composed from reusable library blocks.
class ShowcaseStatusBar extends StatelessWidget {
  const ShowcaseStatusBar({
    super.key,
    required this.status,
    required this.jobs,
    required this.reports,
    required this.onStatus,
  });

  final BlenderStatusService status;
  final BlenderJobService jobs;
  final BlenderReportService reports;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    return BlenderApplicationStatusBar(
      status: status,
      jobs: jobs,
      reports: reports,
      onReportPressed: (report) => onStatus('Report: ${report.message}'),
      center: const <Widget>[
        BlenderInputStatus(
          padding: EdgeInsets.zero,
          showBorder: false,
          items: <BlenderInputStatusItem>[
            BlenderInputStatusItem(event: 'LMB', label: 'Select'),
            BlenderInputStatusItem(event: 'MMB', label: 'Pan'),
          ],
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
