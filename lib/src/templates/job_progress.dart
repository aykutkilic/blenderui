part of '../templates.dart';

/// A compact running-job row matching Blender's status and progress template.
class BlenderJobProgress extends StatelessWidget {
  const BlenderJobProgress({
    super.key,
    required this.name,
    required this.progress,
    this.icon = BlenderGlyph.refresh,
    this.onCancel,
    this.cancelLabel = 'Stop this job',
    this.active = true,
    this.onIconPressed,
    this.iconTooltip,
    this.remainingTime,
    this.elapsedTime,
    this.statusLabel,
  });

  final String name;
  final double progress;
  final BlenderGlyph icon;
  final VoidCallback? onCancel;
  final String cancelLabel;
  final bool active;
  final VoidCallback? onIconPressed;
  final String? iconTooltip;
  final String? remainingTime;
  final String? elapsedTime;
  final String? statusLabel;

  String? get _progressTooltip {
    if (remainingTime == null && elapsedTime == null) return null;
    return 'Time Remaining: ${remainingTime ?? 'Unknown'}\n'
        'Time Elapsed: ${elapsedTime ?? 'Unknown'}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final clampedProgress = progress.clamp(0, 1).toDouble();
    final status =
        statusLabel ??
        (active ? '${(clampedProgress * 100).round()}%' : 'Canceling...');
    Widget jobIcon = BlenderIcon(
      icon,
      size: 14,
      color: theme.colors.foregroundMuted,
    );
    if (onIconPressed != null) {
      jobIcon = BlenderIconButton(
        glyph: icon,
        onPressed: onIconPressed,
        tooltip: iconTooltip,
        size: 22,
        iconSize: 14,
      );
    }
    Widget progressBar = SizedBox(
      width: 92,
      child: BlenderProgressBar(
        value: clampedProgress,
        label: status,
        height: 16,
      ),
    );
    final tooltip = _progressTooltip;
    if (tooltip != null) {
      progressBar = BlenderTooltip(message: tooltip, child: progressBar);
    }
    return Semantics(
      label: name,
      value: status,
      child: Row(
        children: <Widget>[
          jobIcon,
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              active ? name : statusLabel ?? 'Canceling...',
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.label,
            ),
          ),
          const SizedBox(width: 6),
          progressBar,
          if (onCancel != null) ...<Widget>[
            const SizedBox(width: 2),
            BlenderIconButton(
              glyph: BlenderGlyph.close,
              onPressed: active ? onCancel : null,
              tooltip: cancelLabel,
              size: 22,
            ),
          ],
        ],
      ),
    );
  }
}

/// The complete running-jobs strip used by Blender headers and status areas.
///
/// Blender's native template can also expose animation playback and remote
/// asset downloads next to the ordinary job row. [service] binds the panel to
/// the reusable job model while [jobs] remains available for custom visual
/// compositions and backwards compatibility.
class BlenderRunningJobsPanel extends StatelessWidget {
  const BlenderRunningJobsPanel({
    super.key,
    this.jobs = const <BlenderJobProgress>[],
    this.service,
    this.onStopAnimation,
    this.animationLabel = 'Anim Player',
    this.assetDownloadProgress,
    this.onCancelAssetDownloads,
    this.assetDownloadsLabel = 'Downloading Assets',
  });

  final List<BlenderJobProgress> jobs;
  final BlenderJobService? service;
  final VoidCallback? onStopAnimation;
  final String animationLabel;
  final double? assetDownloadProgress;
  final VoidCallback? onCancelAssetDownloads;
  final String assetDownloadsLabel;

  @override
  Widget build(BuildContext context) {
    final service = this.service;
    if (service != null) {
      return AnimatedBuilder(
        animation: service,
        builder: (context, _) => _build(context, <BlenderJobProgress>[
          for (final job in service.jobs) _jobProgress(service, job),
        ]),
      );
    }
    return _build(context, jobs);
  }

  BlenderJobProgress _jobProgress(BlenderJobService service, BlenderJob job) {
    final (active, status) = switch (job.state) {
      BlenderJobState.running => (true, null),
      BlenderJobState.cancelRequested => (false, 'Canceling...'),
      BlenderJobState.completed => (true, '100%'),
      BlenderJobState.failed => (false, 'Failed'),
    };
    return BlenderJobProgress(
      name: job.name,
      progress: job.progress,
      active: active,
      statusLabel: status,
      remainingTime: job.remainingTime,
      elapsedTime: job.elapsedTime,
      onCancel: job.canCancel ? () => unawaited(service.cancel(job.id)) : null,
    );
  }

  Widget _build(BuildContext context, List<BlenderJobProgress> visibleJobs) {
    final theme = BlenderTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (var index = 0; index < visibleJobs.length; index++) ...<Widget>[
          if (index > 0) const SizedBox(height: 2),
          visibleJobs[index],
        ],
        if (onStopAnimation != null) ...<Widget>[
          if (visibleJobs.isNotEmpty) const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: BlenderButton(
              label: animationLabel,
              onPressed: onStopAnimation,
              leading: BlenderIcon(
                BlenderGlyph.errorFilled,
                size: 14,
                color: theme.colors.foregroundMuted,
              ),
              width: 92,
            ),
          ),
        ],
        if (assetDownloadProgress != null) ...<Widget>[
          if (visibleJobs.isNotEmpty || onStopAnimation != null)
            const SizedBox(height: 4),
          Text(assetDownloadsLabel, style: theme.textTheme.label),
          const SizedBox(height: 2),
          Row(
            children: <Widget>[
              BlenderIcon(
                BlenderGlyph.assetManager,
                size: 14,
                color: theme.colors.foregroundMuted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: BlenderProgressBar(
                  value: assetDownloadProgress!,
                  label:
                      '${(assetDownloadProgress!.clamp(0, 1) * 100).round()}%',
                  height: 16,
                ),
              ),
              if (onCancelAssetDownloads != null) ...<Widget>[
                const SizedBox(width: 2),
                BlenderIconButton(
                  glyph: BlenderGlyph.close,
                  onPressed: onCancelAssetDownloads,
                  tooltip: 'Cancel all asset downloads',
                  size: 22,
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
