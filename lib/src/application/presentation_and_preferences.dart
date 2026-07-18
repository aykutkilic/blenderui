part of '../application.dart';

/// Immutable inputs for the optional Preferences window in a
/// [BlenderWorkspaceShell].
///
/// Preference values and persistence remain application-owned. This object
/// only describes how the reusable Preferences editor is presented.
class BlenderPreferencesConfiguration {
  const BlenderPreferencesConfiguration({
    required this.categories,
    required this.sections,
    this.categoryGroups = const <BlenderPreferenceCategoryGroup>[],
    this.initialCategory,
    this.title = 'Preferences',
    this.width = 1040,
    this.height = 700,
    this.onCategoryChanged,
    this.onMinimize,
    this.onMaximize,
  });

  final List<String> categories;
  final List<BlenderPreferenceSection> sections;
  final List<BlenderPreferenceCategoryGroup> categoryGroups;
  final String? initialCategory;
  final String title;
  final double width;
  final double height;
  final ValueChanged<String>? onCategoryChanged;

  /// Delegates minimization to a host-native temporary window when supplied.
  /// Otherwise BlenderUI's embedded presenter collapses the Preferences
  /// window to its title bar.
  final VoidCallback? onMinimize;

  /// Delegates maximization to a host-native temporary window when supplied.
  /// Otherwise BlenderUI's embedded presenter fills its safe viewport.
  final VoidCallback? onMaximize;
}

/// Framework-owned presenter for an application's temporary Preferences
/// window.
///
/// Applications own the actual preference sections and persistence. This
/// service owns only the menu-safe temporary-window presentation, so Edit >
/// Preferences has the same behavior in every BlenderUI application.
class BlenderPreferencesService {
  BlenderPreferencesService({required this.configuration});

  final BlenderPreferencesConfiguration configuration;
  BlenderThemeController? _themeController;

  /// Binds the app-scoped theme source used when Preferences is opened from a
  /// Navigator context above the application scope.
  ///
  /// Blender menus commonly dispatch global commands through that Navigator,
  /// so relying only on inherited lookup would otherwise capture the root
  /// default palette. Applications normally receive this binding
  /// automatically from [BlenderApplicationController].
  void bindThemeController(BlenderThemeController? controller) {
    _themeController = controller;
  }

  Future<void> show(BuildContext context) => showBlenderPreferencesWindow(
    context,
    configuration: configuration,
    themeController: _themeController,
  );
}

/// Describes the optional startup splash presented by an application shell.
class BlenderSplashScreenConfiguration {
  const BlenderSplashScreenConfiguration({
    required this.title,
    this.message,
    this.content,
    this.width = 520,
    this.showOnStartup = false,
  });

  final String title;
  final String? message;
  final Widget? content;
  final double width;
  final bool showOnStartup;
}

/// Describes the reusable About dialog for an application shell.
class BlenderAboutDialogConfiguration {
  const BlenderAboutDialogConfiguration({
    required this.title,
    this.version,
    this.message,
    this.content,
    this.width = 460,
  });

  final String title;
  final String? version;
  final String? message;
  final Widget? content;
  final double width;
}

/// Owns the app-level splash and About presentation lifecycle.
///
/// Like blenderapp's window-manager operators, this service owns when and how
/// transient presentation surfaces open. Applications still own their branding
/// content, release notes, and legal copy through the immutable descriptors.
class BlenderApplicationPresentationService
    implements BlenderServiceDisposable {
  BlenderApplicationPresentationService({this.splash, this.about});

  final BlenderSplashScreenConfiguration? splash;
  final BlenderAboutDialogConfiguration? about;
  bool _startupSplashShown = false;
  bool _disposed = false;

  Future<bool> showStartupSplash(
    BuildContext context, {
    bool enabled = true,
  }) async {
    final splash = this.splash;
    if (_disposed ||
        _startupSplashShown ||
        !enabled ||
        splash == null ||
        !splash.showOnStartup) {
      return false;
    }
    _startupSplashShown = true;
    await showSplash(context);
    return true;
  }

  Future<bool> showSplash(BuildContext context) async {
    final splash = this.splash;
    if (_disposed || splash == null || !context.mounted) return false;
    await showBlenderDialog<void>(
      context: context,
      barrierLabel: 'Dismiss ${splash.title} splash screen',
      builder: (dialogContext) => BlenderDialog(
        title: splash.title,
        message: splash.message,
        content: splash.content,
        width: splash.width,
        actions: <BlenderDialogAction>[
          BlenderDialogAction(
            label: 'Continue',
            primary: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
    return true;
  }

  Future<bool> showAbout(BuildContext context) async {
    final about = this.about;
    if (_disposed || about == null || !context.mounted) return false;
    final message = switch ((about.version, about.message)) {
      (null, final message) => message,
      (final version?, null) => version,
      (final version?, final message?) => '$version\n$message',
    };
    await showBlenderDialog<void>(
      context: context,
      barrierLabel: 'Dismiss ${about.title} information',
      builder: (dialogContext) => BlenderDialog(
        title: about.title,
        message: message,
        content: about.content,
        width: about.width,
        actions: <BlenderDialogAction>[
          BlenderDialogAction(
            label: 'Close',
            primary: true,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
        ],
      ),
    );
    return true;
  }

  @override
  void dispose() => _disposed = true;
}

/// A service-backed status bar for application shells.
class BlenderApplicationStatusBar extends StatelessWidget {
  const BlenderApplicationStatusBar({
    super.key,
    required this.status,
    this.jobs,
    this.reports,
    this.onReportPressed,
    this.center = const <Widget>[],
    this.right = const <Widget>[],
  });

  final BlenderStatusService status;
  final BlenderJobService? jobs;
  final BlenderReportService? reports;
  final ValueChanged<BlenderReport>? onReportPressed;
  final List<Widget> center;
  final List<Widget> right;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: status,
      builder: (context, _) {
        final message = status.message;
        final theme = BlenderTheme.of(context);
        final color = switch (message?.level) {
          BlenderStatusLevel.success => theme.colors.success,
          BlenderStatusLevel.warning => theme.colors.warning,
          BlenderStatusLevel.error => theme.colors.error,
          _ => theme.colors.foregroundMuted,
        };
        return BlenderStatusBar(
          left: message == null
              ? const <Widget>[]
              : <Widget>[
                  Text(
                    message.text,
                    style: theme.textTheme.caption.copyWith(color: color),
                  ),
                ],
          center: <Widget>[
            if (reports != null)
              BlenderLatestReportBanner(
                reports: reports!,
                onPressed: onReportPressed,
              ),
            if (jobs != null) ...<Widget>[
              if (reports != null) const SizedBox(width: 8),
              SizedBox(
                width: 268,
                child: BlenderRunningJobsPanel(service: jobs!),
              ),
            ],
            ...center,
          ],
          right: right,
        );
      },
    );
  }
}

/// Opens a source-shaped temporary Preferences window.
///
/// Use this from a menu command after the menu route has closed. The returned
/// future completes when the window is dismissed.
Future<void> showBlenderPreferencesWindow(
  BuildContext context, {
  required BlenderPreferencesConfiguration configuration,
  BlenderThemeController? themeController,
}) {
  // A menu item removes its own popover route after its callback returns. Open
  // the temporary Preferences window in the next frame so that cleanup cannot
  // pop the newly created window. Centralizing this here lets every app use
  // the same safe presentation path, rather than repeating the workaround at
  // each Edit > Preferences command.
  final completion = Completer<void>();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    if (!context.mounted) {
      completion.complete();
      return;
    }
    try {
      await showBlenderDialog<void>(
        context: context,
        barrierLabel: 'Dismiss ${configuration.title}',
        themeController: themeController,
        builder: (dialogContext) => BlenderPreferencesWindow(
          categories: configuration.categories,
          categoryGroups: configuration.categoryGroups,
          sections: configuration.sections,
          initialCategory: configuration.initialCategory,
          title: configuration.title,
          width: configuration.width,
          height: configuration.height,
          onCategoryChanged: configuration.onCategoryChanged,
          onClose: () => Navigator.of(dialogContext, rootNavigator: true).pop(),
          onMinimize: configuration.onMinimize,
          onMaximize: configuration.onMaximize,
        ),
      );
      completion.complete();
    } catch (error, stackTrace) {
      completion.completeError(error, stackTrace);
    }
  });
  return completion.future;
}
