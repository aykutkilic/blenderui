part of '../specialized_templates.dart';

/// Blender's transient report banner: a severity-colored icon segment joined
/// to a muted message segment that can open the Info editor.
class BlenderReportBanner extends StatelessWidget {
  const BlenderReportBanner({
    super.key,
    required this.message,
    this.level = BlenderNoticeLevel.info,
    this.onPressed,
    this.maxWidth = 800,
  });

  final String message;
  final BlenderNoticeLevel level;
  final VoidCallback? onPressed;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final color = switch (level) {
      BlenderNoticeLevel.info => theme.colors.info,
      BlenderNoticeLevel.success => theme.colors.success,
      BlenderNoticeLevel.warning => theme.colors.warning,
      BlenderNoticeLevel.error => theme.colors.error,
    };
    final glyph = switch (level) {
      BlenderNoticeLevel.info => BlenderGlyph.info,
      BlenderNoticeLevel.success => BlenderGlyph.checkCircle,
      BlenderNoticeLevel.warning => BlenderGlyph.warning,
      BlenderNoticeLevel.error => BlenderGlyph.error,
    };
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ColoredBox(
            color: color,
            child: SizedBox(
              width: 30,
              height: 26,
              child: Center(
                child: BlenderIcon(
                  glyph,
                  size: 16,
                  color: theme.colors.foreground,
                ),
              ),
            ),
          ),
          Flexible(
            child: ColoredBox(
              color: color.withValues(alpha: .22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Text(
                  message,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.caption.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    final semantic = Semantics(
      container: true,
      button: onPressed != null,
      label: message,
      child: content,
    );
    return onPressed == null
        ? semantic
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: semantic,
          );
  }
}

/// Displays the latest report from an application report service.
class BlenderLatestReportBanner extends StatelessWidget {
  const BlenderLatestReportBanner({
    super.key,
    required this.reports,
    this.onPressed,
    this.maxWidth = 800,
  });

  final BlenderReportService reports;
  final ValueChanged<BlenderReport>? onPressed;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: reports,
      builder: (context, _) {
        final report = reports.latest;
        if (report == null) return const SizedBox.shrink();
        return BlenderReportBanner(
          message: report.message,
          level: switch (report.level) {
            BlenderStatusLevel.info => BlenderNoticeLevel.info,
            BlenderStatusLevel.success => BlenderNoticeLevel.success,
            BlenderStatusLevel.warning => BlenderNoticeLevel.warning,
            BlenderStatusLevel.error => BlenderNoticeLevel.error,
          },
          maxWidth: maxWidth,
          onPressed: onPressed == null ? null : () => onPressed!(report),
        );
      },
    );
  }
}

/// The extension/update portion of Blender's status-info template.
enum BlenderExtensionStatus { hidden, offline, checking, updates, blocked }

/// A compact status-info strip matching `uiTemplateStatusInfo`.
///
/// Blender derives the text from the current file, scene, view layer, and
/// extension manager. This widget keeps those values as plain descriptors so
/// callers can reproduce the visual states without coupling the package to
/// Blender's runtime context.
class BlenderStatusInfo extends StatelessWidget {
  const BlenderStatusInfo({
    super.key,
    this.statusText,
    this.versionText,
    this.showVersion = true,
    this.extensionStatus = BlenderExtensionStatus.hidden,
    this.extensionCount = 0,
    this.onExtensionPressed,
    this.warningMessage,
    this.warningTooltip,
    this.onWarningPressed,
    this.newerBlenderVersion,
    this.assetEditFile = false,
    this.missingColorManagement = false,
  });

  final String? statusText;
  final String? versionText;
  final bool showVersion;
  final BlenderExtensionStatus extensionStatus;
  final int extensionCount;
  final VoidCallback? onExtensionPressed;
  final String? warningMessage;
  final String? warningTooltip;
  final VoidCallback? onWarningPressed;
  final String? newerBlenderVersion;
  final bool assetEditFile;
  final bool missingColorManagement;

  String? get _effectiveWarningMessage {
    if (warningMessage != null && warningMessage!.isNotEmpty) {
      return warningMessage;
    }
    final parts = <String>[
      if (newerBlenderVersion != null && newerBlenderVersion!.isNotEmpty)
        newerBlenderVersion!,
      if (missingColorManagement) 'Color Management',
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }

  String? get _effectiveWarningTooltip {
    if (warningTooltip != null && warningTooltip!.isNotEmpty) {
      return warningTooltip;
    }
    final parts = <String>[
      if (newerBlenderVersion != null && newerBlenderVersion!.isNotEmpty)
        'File saved by newer Blender\n($newerBlenderVersion), expect loss of data',
      if (assetEditFile)
        'This file is managed by the Blender asset system and cannot be overridden',
      if (missingColorManagement)
        'Displays, views or color spaces in this file were missing and have been changed',
    ];
    return parts.isEmpty ? null : parts.join('\n\n');
  }

  Widget _separator(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text('|', style: theme.textTheme.caption),
    );
  }

  Widget _extension(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final glyph = switch (extensionStatus) {
      BlenderExtensionStatus.offline => BlenderGlyph.internetOffline,
      BlenderExtensionStatus.checking => BlenderGlyph.sync,
      BlenderExtensionStatus.updates => BlenderGlyph.internet,
      BlenderExtensionStatus.blocked => BlenderGlyph.warningFilled,
      BlenderExtensionStatus.hidden => BlenderGlyph.info,
    };
    final label = switch (extensionStatus) {
      BlenderExtensionStatus.offline => 'Extensions offline',
      BlenderExtensionStatus.checking => 'Checking extensions',
      BlenderExtensionStatus.updates => 'Extension updates',
      BlenderExtensionStatus.blocked => 'Extensions blocked',
      BlenderExtensionStatus.hidden => 'Extensions',
    };
    final icon = SizedBox(
      width: 24,
      height: theme.density.controlHeight,
      child: Stack(
        children: <Widget>[
          Positioned(
            left: 0,
            top: (theme.density.controlHeight - 15) / 2,
            child: BlenderIcon(glyph, size: 15),
          ),
          if (extensionCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colors.accent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    '$extensionCount',
                    style: theme.textTheme.caption.copyWith(
                      color: theme.colors.foreground,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    final button = Semantics(
      container: true,
      button: onExtensionPressed != null,
      label: label,
      child: BlenderButton(
        label: '',
        leading: icon,
        width: 24,
        enabled: onExtensionPressed != null,
        onPressed: onExtensionPressed,
        variant: BlenderButtonVariant.toolbar,
        padding: EdgeInsets.zero,
        showBorder: false,
      ),
    );
    return onExtensionPressed == null
        ? button
        : BlenderTooltip(message: label, child: button);
  }

  Widget _warning(BuildContext context, String? message) {
    final theme = BlenderTheme.of(context);
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ColoredBox(
          color: theme.colors.warning,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            child: BlenderIcon(
              BlenderGlyph.warningFilled,
              size: 14,
              color: theme.colors.foreground,
            ),
          ),
        ),
        if (message != null && message.isNotEmpty)
          Flexible(
            child: ColoredBox(
              color: theme.colors.warning.withValues(alpha: .22),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Text(
                  message,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.caption.copyWith(
                    color: theme.colors.foreground,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
    final semantic = Semantics(
      container: true,
      button: onWarningPressed != null,
      label: message ?? 'File warning',
      child: content,
    );
    final interactive = onWarningPressed == null
        ? semantic
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onWarningPressed,
            child: semantic,
          );
    final bounded = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160),
      child: interactive,
    );
    final tooltip = _effectiveWarningTooltip;
    return tooltip == null
        ? bounded
        : BlenderTooltip(message: tooltip, child: bounded);
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (statusText != null && statusText!.isNotEmpty) {
      children.add(
        SizedBox(
          width: 200,
          child: Text(statusText!, overflow: TextOverflow.ellipsis),
        ),
      );
    }
    if (extensionStatus != BlenderExtensionStatus.hidden) {
      if (children.isNotEmpty) children.add(_separator(context));
      children.add(_extension(context));
    }
    final effectiveWarning = _effectiveWarningMessage;
    final hasWarning = effectiveWarning != null || assetEditFile;
    if (showVersion &&
        versionText != null &&
        versionText!.isNotEmpty &&
        newerBlenderVersion == null) {
      if (children.isNotEmpty) children.add(_separator(context));
      children.add(Text(versionText!));
    }
    if (hasWarning) {
      if (children.isNotEmpty) children.add(const SizedBox(width: 8));
      children.add(_warning(context, effectiveWarning));
    }
    return DefaultTextStyle(
      style: BlenderTheme.of(context).textTheme.caption,
      child: Row(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
