part of '../specialized_templates.dart';

/// The filename and execute/cancel side panel used by Blender's file
/// selector operator region.
class BlenderFileExecutionPanel extends StatelessWidget {
  const BlenderFileExecutionPanel({
    super.key,
    required this.filenameController,
    required this.onExecute,
    required this.onCancel,
    this.title = 'File Operation',
    this.executeLabel = 'Execute',
    this.overwriteAlert = false,
    this.onDecrement,
    this.onIncrement,
  });

  final TextEditingController filenameController;
  final VoidCallback? onExecute;
  final VoidCallback? onCancel;
  final String title;
  final String executeLabel;
  final bool overwriteAlert;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: BlenderTextField(
                  controller: filenameController,
                  placeholder: 'File name',
                  backgroundColor: overwriteAlert
                      ? theme.colors.warning.withValues(alpha: .16)
                      : null,
                ),
              ),
              if (onDecrement != null)
                BlenderIconButton(
                  glyph: BlenderGlyph.minus,
                  onPressed: onDecrement,
                  tooltip: 'Previous file name',
                  size: 24,
                ),
              if (onIncrement != null)
                BlenderIconButton(
                  glyph: BlenderGlyph.plus,
                  onPressed: onIncrement,
                  tooltip: 'Next file name',
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              BlenderButton(
                label: 'Cancel',
                onPressed: onCancel,
                enabled: onCancel != null,
                variant: BlenderButtonVariant.regular,
              ),
              const SizedBox(width: 6),
              BlenderButton(
                label: overwriteAlert ? 'Overwrite' : executeLabel,
                onPressed: onExecute,
                enabled: onExecute != null,
                selected: overwriteAlert,
                variant: BlenderButtonVariant.regular,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The active operator-property pane shown beside Blender's file selector.
/// File-path, directory, filename, and file-list RNA fields are intentionally
/// omitted by the caller because Blender owns those in the execution pane.
class BlenderFileOperatorPanel extends StatelessWidget {
  const BlenderFileOperatorPanel({
    super.key,
    required this.operatorName,
    required this.properties,
    this.enabled = true,
    this.initiallyExpanded = true,
  });

  final String operatorName;
  final List<BlenderPropertyDescriptor<dynamic>> properties;
  final bool enabled;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return BlenderPanel(
      title: operatorName,
      collapsible: true,
      initiallyExpanded: initiallyExpanded,
      child: Opacity(
        opacity: enabled ? 1 : .5,
        child: _buildOperatorProperties(context, properties),
      ),
    );
  }
}
