part of '../non3d_editors.dart';

/// Source-shaped Project editor from `space_project.py`.
///
/// Project discovery, saving, and filesystem operations remain caller-owned;
/// this widget mirrors Blender's Navigation, General, Project, and Save
/// Project surfaces.
class BlenderProjectEditor extends StatelessWidget {
  const BlenderProjectEditor({
    super.key,
    this.projectName = 'Showcase Project',
    this.rootPath = '/showcase',
    this.hasProject = true,
    this.title = 'Project',
  });

  final String projectName;
  final String rootPath;
  final bool hasProject;
  final String title;

  Widget _field(String label, String value) => BlenderPropertyRow(
    label: label,
    editor: BlenderDropdown<String>(
      value: value,
      items: <BlenderMenuItem<String>>[
        BlenderMenuItem<String>(value: value, label: value),
      ],
      onChanged: _noopString,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    final content = hasProject
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlenderPanel(
                title: 'Project',
                collapsible: false,
                initiallyExpanded: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _field('Name', projectName),
                    _field('Root Path', rootPath),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              BlenderPanel(
                title: 'Save Project',
                collapsible: false,
                initiallyExpanded: true,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Project changes are saved with the current file.',
                        style: theme.textTheme.caption.copyWith(
                          color: theme.colors.foregroundMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const BlenderButton(
                      label: 'Save Project',
                      onPressed: _noop,
                    ),
                  ],
                ),
              ),
            ],
          )
        : BlenderPanel(
            title: 'No Project',
            collapsible: false,
            initiallyExpanded: true,
            child: Column(
              children: <Widget>[
                Text(
                  'No active project.',
                  style: theme.textTheme.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Save the current file or open a file inside a project directory.',
                  style: theme.textTheme.caption.copyWith(
                    color: theme.colors.foregroundMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const BlenderButton(
                      label: 'Save File...',
                      onPressed: _noop,
                    ),
                    const SizedBox(width: 6),
                    const BlenderButton(
                      label: 'Open in Project',
                      onPressed: _noop,
                    ),
                  ],
                ),
              ],
            ),
          );
    return BlenderPanel(
      title: title,
      padding: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            width: 150,
            child: BlenderPanel(
              title: 'Navigation',
              collapsible: false,
              initiallyExpanded: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const BlenderButton(
                    label: 'General',
                    variant: BlenderButtonVariant.tab,
                    onPressed: _noop,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Project',
                    style: theme.textTheme.caption.copyWith(
                      color: theme.colors.foregroundMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(child: SingleChildScrollView(child: content)),
        ],
      ),
    );
  }
}
