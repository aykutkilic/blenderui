import 'package:flutter/widgets.dart';

import 'advanced_controls.dart';
import 'controls.dart';
import 'editors.dart';
import 'icons.dart';
import 'layout.dart';
import 'non3d_editors.dart';
import 'theme_service.dart';

/// Host-owned file interaction for the portable theme Preferences editor.
///
/// BlenderUI supplies XML parsing and serialization, while each app chooses
/// the platform file picker, sandbox entitlement, and destination directory.
class BlenderThemeFileActions {
  const BlenderThemeFileActions({this.onInstall, this.onSave});

  /// Opens a Blender XML theme and returns its text plus an optional filename.
  final Future<BlenderThemeFileContent?> Function()? onInstall;

  /// Saves a Blender-compatible XML document using the suggested filename.
  final Future<void> Function(BlenderThemeFileContent content)? onSave;
}

@immutable
class BlenderThemeFileContent {
  const BlenderThemeFileContent({required this.name, required this.xml});

  final String name;
  final String xml;
}

/// Blender-like Themes preference surface for [BlenderThemeService].
class BlenderThemePreferencesEditor extends StatelessWidget {
  const BlenderThemePreferencesEditor({
    super.key,
    required this.service,
    this.fileActions = const BlenderThemeFileActions(),
  });

  final BlenderThemeService service;
  final BlenderThemeFileActions fileActions;

  Future<void> _install() async {
    final content = await fileActions.onInstall?.call();
    if (content == null) return;
    final importedName = _themeName(content.name);
    service.importBlenderXml(
      content.xml,
      name: importedName.isEmpty ? null : importedName,
      sourceFileName: content.name,
    );
  }

  Future<void> _save() async {
    final theme = service.activeTheme;
    await fileActions.onSave?.call(
      BlenderThemeFileContent(
        name: '${_fileStem(theme.name)}.xml',
        xml: service.exportActiveBlenderXml(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: service,
      builder: (context, child) {
        final active = service.activeTheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: BlenderDropdown<String>(
                    value: active.id,
                    items: <BlenderMenuItem<String>>[
                      for (final theme in service.themes)
                        BlenderMenuItem<String>(
                          value: theme.id,
                          label: theme.name,
                        ),
                    ],
                    onChanged: service.select,
                  ),
                ),
                const SizedBox(width: 4),
                BlenderIconButton(
                  key: const ValueKey<String>('blender-theme-new'),
                  glyph: BlenderGlyph.plus,
                  tooltip: 'New theme',
                  size: 24,
                  iconSize: 14,
                  onPressed: () {
                    service.create();
                  },
                ),
                BlenderIconButton(
                  key: const ValueKey<String>('blender-theme-remove'),
                  glyph: BlenderGlyph.deleteIcon,
                  tooltip: 'Remove theme',
                  size: 24,
                  iconSize: 14,
                  enabled: !active.isBuiltIn,
                  onPressed: () {
                    service.removeActive();
                  },
                ),
                BlenderIconButton(
                  key: const ValueKey<String>('blender-theme-save'),
                  glyph: BlenderGlyph.save,
                  tooltip: 'Save theme',
                  size: 24,
                  iconSize: 14,
                  enabled: fileActions.onSave != null,
                  onPressed: fileActions.onSave == null ? null : _save,
                ),
                BlenderIconButton(
                  key: const ValueKey<String>('blender-theme-install'),
                  glyph: BlenderGlyph.open,
                  tooltip: 'Install theme',
                  size: 24,
                  iconSize: 14,
                  enabled: fileActions.onInstall != null,
                  onPressed: fileActions.onInstall == null ? null : _install,
                ),
                BlenderIconButton(
                  key: const ValueKey<String>('blender-theme-reset'),
                  glyph: BlenderGlyph.undo,
                  tooltip: 'Reset to Blender Dark',
                  size: 24,
                  iconSize: 14,
                  onPressed: service.resetToDefault,
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlenderPanel(
              title: 'User Interface',
              collapsible: true,
              initiallyExpanded: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ThemeNameField(service: service, theme: active),
                  _colorRow(BlenderThemeColorRole.canvas),
                  _colorRow(BlenderThemeColorRole.foreground),
                  _colorRow(BlenderThemeColorRole.accent),
                  _colorRow(BlenderThemeColorRole.selection),
                  _colorRow(BlenderThemeColorRole.focus),
                  _colorRow(BlenderThemeColorRole.editorBorder),
                  _colorRow(BlenderThemeColorRole.editorOutline),
                ],
              ),
            ),
            const SizedBox(height: 6),
            BlenderPanel(
              title: 'Widgets',
              collapsible: true,
              initiallyExpanded: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _colorRow(BlenderThemeColorRole.button),
                  _colorRow(BlenderThemeColorRole.buttonSelected),
                  _colorRow(BlenderThemeColorRole.textField),
                  _colorRow(BlenderThemeColorRole.menuBackground),
                  _colorRow(BlenderThemeColorRole.menuSelection),
                  _colorRow(BlenderThemeColorRole.tab),
                  _colorRow(BlenderThemeColorRole.tabSelected),
                ],
              ),
            ),
            const SizedBox(height: 6),
            BlenderPanel(
              title: 'Regions',
              collapsible: true,
              initiallyExpanded: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _colorRow(BlenderThemeColorRole.topBar),
                  _colorRow(BlenderThemeColorRole.propertiesBackground),
                  _colorRow(BlenderThemeColorRole.panelHeader),
                  _colorRow(BlenderThemeColorRole.panelBackground),
                  _colorRow(BlenderThemeColorRole.link),
                  _colorRow(BlenderThemeColorRole.cursor),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _colorRow(BlenderThemeColorRole role) {
    final color = service.activeTheme.colorFor(role);
    return BlenderPropertyRow(
      label: role.label,
      editor: BlenderPopover(
        child: BlenderColorField(color: color),
        popover: (context, close) => SizedBox(
          width: 300,
          child: BlenderColorPicker(
            color: color,
            onChanged: (next) => service.updateActiveColor(role, next),
          ),
        ),
      ),
    );
  }

  static String _fileStem(String value) {
    final stem = value
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    return stem.isEmpty ? 'Theme' : stem;
  }

  static String _themeName(String filename) => filename
      .replaceFirst(RegExp(r'\.xml$', caseSensitive: false), '')
      .replaceAll('_', ' ')
      .trim();
}

class _ThemeNameField extends StatefulWidget {
  const _ThemeNameField({required this.service, required this.theme});

  final BlenderThemeService service;
  final BlenderThemeDefinition theme;

  @override
  State<_ThemeNameField> createState() => _ThemeNameFieldState();
}

class _ThemeNameFieldState extends State<_ThemeNameField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.theme.name,
  );

  @override
  void didUpdateWidget(_ThemeNameField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.theme.id != widget.theme.id ||
        oldWidget.theme.name != widget.theme.name) {
      _controller.value = TextEditingValue(
        text: widget.theme.name,
        selection: TextSelection.collapsed(offset: widget.theme.name.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlenderPropertyRow(
    label: 'Name',
    editor: BlenderTextField(
      controller: _controller,
      onSubmitted: widget.service.renameActive,
    ),
  );
}

/// A standard Themes-category section for [BlenderPreferencesConfiguration].
BlenderPreferenceSection blenderThemePreferenceSection({
  required BlenderThemeService service,
  String category = 'Themes',
  String id = 'blenderui-theme',
  BlenderThemeFileActions fileActions = const BlenderThemeFileActions(),
}) => BlenderPreferenceSection(
  id: id,
  category: category,
  title: 'Themes',
  searchTerms: const <String>[
    'Blender Dark',
    'Blender Light',
    'User Interface',
    'Widgets',
    'Regions',
    'Install',
    'Save',
  ],
  child: BlenderThemePreferencesEditor(
    service: service,
    fileActions: fileActions,
  ),
);
