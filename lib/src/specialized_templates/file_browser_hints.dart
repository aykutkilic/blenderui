part of '../specialized_templates.dart';

/// An in-editor file-browser hint card used for asset-library availability
/// and remote-library loading failures.
///
/// Blender draws these as centered round-box cards over the asset view rather
/// than as modal dialogs. The host owns network state and action behavior;
/// this widget preserves the source-defined heading, message, icon, and
/// optional action row.
@immutable
class BlenderFileBrowserHintAction {
  const BlenderFileBrowserHintAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.enabled = true,
  });

  final String label;
  final BlenderGlyph? icon;
  final VoidCallback? onPressed;
  final bool enabled;
}

class BlenderFileBrowserHint extends StatelessWidget {
  const BlenderFileBrowserHint({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.actions = const <BlenderFileBrowserHintAction>[],
    this.width = 360,
  });

  final String title;
  final String message;
  final BlenderGlyph icon;
  final List<BlenderFileBrowserHintAction> actions;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, minWidth: 220),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colors.panelBackground,
            border: Border.all(color: theme.colors.borderSubtle),
            borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      BlenderIcon(icon, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(title, style: theme.textTheme.heading),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(message, style: theme.textTheme.body),
                  if (actions.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    Row(
                      children: <Widget>[
                        for (var index = 0; index < actions.length; index++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: index == 0 ? 0 : 4,
                              ),
                              child: BlenderButton(
                                label: actions[index].label,
                                leading: actions[index].icon == null
                                    ? null
                                    : BlenderIcon(
                                        actions[index].icon!,
                                        size: 14,
                                      ),
                                enabled: actions[index].enabled,
                                onPressed: actions[index].onPressed,
                                variant: BlenderButtonVariant.regular,
                                width: double.infinity,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The top-left invalid-local-library state drawn by Blender's asset browser.
@immutable
class BlenderFileBrowserLibraryPathHint extends StatelessWidget {
  const BlenderFileBrowserLibraryPathHint({
    super.key,
    required this.title,
    required this.path,
    required this.message,
    this.onOpenPreferences,
    this.width = 420,
  });

  final String title;
  final String path;
  final String message;
  final VoidCallback? onOpenPreferences;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title, style: theme.textTheme.body),
              const SizedBox(height: 3),
              Text(
                path,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.body,
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const BlenderIcon(BlenderGlyph.statusInfo, size: 16),
                  const SizedBox(width: 6),
                  Expanded(child: Text(message, style: theme.textTheme.body)),
                ],
              ),
              if (onOpenPreferences != null) ...<Widget>[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: BlenderButton(
                    label: 'Open Preferences',
                    leading: const BlenderIcon(
                      BlenderGlyph.preferences,
                      size: 14,
                    ),
                    onPressed: onOpenPreferences,
                    variant: BlenderButtonVariant.regular,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A top-left diagnostic state for an unreadable Blender library file.
///
/// Blender renders the path first and then places non-info reports below it,
/// with an info or warning icon beside each message. File loading and report
/// ownership remain with the host application.
@immutable
class BlenderFileBrowserReport {
  const BlenderFileBrowserReport({
    required this.message,
    this.level = BlenderNoticeLevel.info,
  });

  final String message;
  final BlenderNoticeLevel level;
}

class BlenderFileBrowserUnreadableLibraryHint extends StatelessWidget {
  const BlenderFileBrowserUnreadableLibraryHint({
    super.key,
    required this.path,
    required this.reports,
    this.title = 'Unreadable Blender library file:',
    this.width = 420,
  });

  final String title;
  final String path;
  final List<BlenderFileBrowserReport> reports;
  final double width;

  BlenderGlyph _reportIcon(BlenderFileBrowserReport report) {
    return report.level == BlenderNoticeLevel.info
        ? BlenderGlyph.statusInfo
        : BlenderGlyph.warningFilled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title, style: theme.textTheme.body),
              const SizedBox(height: 3),
              Text(
                path,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.body,
              ),
              if (reports.isNotEmpty) ...<Widget>[
                const SizedBox(height: 18),
                for (
                  var index = 0;
                  index < reports.length;
                  index++
                ) ...<Widget>[
                  if (index > 0) const SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      BlenderIcon(_reportIcon(reports[index]), size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          reports[index].message,
                          style: theme.textTheme.body,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
