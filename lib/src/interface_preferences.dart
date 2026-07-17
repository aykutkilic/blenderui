import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'editors.dart';
import 'layout.dart';
import 'non3d_editors.dart';
import 'services.dart';
import 'theme.dart';
import 'theme_preferences.dart';
import 'theme_service.dart';

/// Applies the portable interface preferences to a BlenderUI subtree.
///
/// It listens to [preferences], so a scale or theme selection made in a
/// Preferences window updates the open application immediately. The optional
/// [baseTheme] retains an application's typography and density customizations
/// while Blender Dark and Blender Light provide the shared palette.
class BlenderInterfaceTheme extends StatefulWidget {
  const BlenderInterfaceTheme({
    super.key,
    required this.preferences,
    required this.child,
    this.baseTheme = const BlenderThemeData(),
    this.themeService,
  });

  final BlenderInterfacePreferencesService preferences;
  final BlenderThemeData baseTheme;
  final BlenderThemeService? themeService;
  final Widget child;

  @override
  State<BlenderInterfaceTheme> createState() => _BlenderInterfaceThemeState();
}

class _BlenderInterfaceThemeState extends State<BlenderInterfaceTheme> {
  late BlenderThemeController _themeController;

  Listenable get _source => Listenable.merge(<Listenable>[
    widget.preferences,
    if (widget.themeService != null) widget.themeService!,
  ]);

  BlenderThemeData _resolveTheme() {
    final activeTheme = widget.themeService?.activeTheme;
    return activeTheme == null
        ? widget.baseTheme.withInterfacePreferences(widget.preferences.value)
        : widget.baseTheme
              .copyWith(colors: activeTheme.colors)
              .withInterfaceMetrics(widget.preferences.value);
  }

  @override
  void initState() {
    super.initState();
    _themeController = BlenderThemeController(
      source: _source,
      resolve: _resolveTheme,
    );
  }

  @override
  void didUpdateWidget(BlenderInterfaceTheme oldWidget) {
    super.didUpdateWidget(oldWidget);
    _themeController.update(source: _source, resolve: _resolveTheme);
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlenderThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (context, child) {
          final theme = _themeController.data;
          return BlenderTheme(
            data: theme,
            child: DefaultTextStyle(
              style: theme.textTheme.body.copyWith(
                color: theme.colors.foreground,
              ),
              child: child!,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Reusable controls for BlenderUI's portable Interface preferences.
///
/// This intentionally renders only app-neutral values. An editor can append
/// domain panels (for example a 3D viewport's overlays) beside these controls
/// without having to fork the underlying app preference state.
class BlenderInterfacePreferencesEditor extends StatelessWidget {
  const BlenderInterfacePreferencesEditor({
    super.key,
    required this.preferences,
    this.includeTheme = true,
    this.includeDisplayOptions = true,
    this.includeEditorOptions = true,
  });

  final BlenderInterfacePreferencesService preferences;
  final bool includeTheme;
  final bool includeDisplayOptions;
  final bool includeEditorOptions;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: preferences,
      builder: (context, child) {
        final value = preferences.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (includeTheme)
              BlenderPropertyRow(
                label: 'Theme',
                tooltip:
                    'Choose Blender Dark or the source-matched Blender Light palette.',
                editor: BlenderDropdown<BlenderThemePreset>(
                  value: value.theme,
                  items: const <BlenderMenuItem<BlenderThemePreset>>[
                    BlenderMenuItem<BlenderThemePreset>(
                      value: BlenderThemePreset.dark,
                      label: 'Blender Dark',
                    ),
                    BlenderMenuItem<BlenderThemePreset>(
                      value: BlenderThemePreset.light,
                      label: 'Blender Light',
                    ),
                  ],
                  onChanged: (theme) => preferences.update(
                    (value) => value.copyWith(theme: theme),
                  ),
                ),
              ),
            if (includeDisplayOptions) ...<Widget>[
              BlenderPropertyRow(
                label: 'Resolution Scale',
                tooltip:
                    'Changes the size of fonts and widgets in the interface.',
                editor: BlenderNumberField(
                  value: value.uiScale,
                  min: .5,
                  max: 3,
                  step: .05,
                  decimalDigits: 2,
                  onChanged: (scale) => preferences.update(
                    (value) => value.copyWith(uiScale: scale),
                  ),
                ),
              ),
              BlenderPropertyRow(
                label: 'Line Width',
                tooltip: 'Changes the thickness of widget outlines and lines.',
                editor: BlenderDropdown<BlenderInterfaceLineWidth>(
                  value: value.lineWidth,
                  items: const <BlenderMenuItem<BlenderInterfaceLineWidth>>[
                    BlenderMenuItem<BlenderInterfaceLineWidth>(
                      value: BlenderInterfaceLineWidth.thin,
                      label: 'Thin',
                    ),
                    BlenderMenuItem<BlenderInterfaceLineWidth>(
                      value: BlenderInterfaceLineWidth.automatic,
                      label: 'Default',
                    ),
                    BlenderMenuItem<BlenderInterfaceLineWidth>(
                      value: BlenderInterfaceLineWidth.thick,
                      label: 'Thick',
                    ),
                  ],
                  onChanged: (lineWidth) => preferences.update(
                    (value) => value.copyWith(lineWidth: lineWidth),
                  ),
                ),
              ),
              _check(
                'Splash Screen',
                value.showSplash,
                (next) => preferences.update(
                  (value) => value.copyWith(showSplash: next),
                ),
              ),
              _check(
                'Developer Extras',
                value.showDeveloperExtras,
                (next) => preferences.update(
                  (value) => value.copyWith(showDeveloperExtras: next),
                ),
              ),
              BlenderPanel(
                title: 'Tooltips',
                collapsible: true,
                initiallyExpanded: true,
                child: _check(
                  'User Tooltips',
                  value.showTooltips,
                  (next) => preferences.update(
                    (value) => value.copyWith(showTooltips: next),
                  ),
                ),
              ),
            ],
            if (includeEditorOptions) ...<Widget>[
              const SizedBox(height: 8),
              BlenderPanel(
                title: 'Editors',
                collapsible: true,
                initiallyExpanded: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _check(
                      'Region Overlap',
                      value.useRegionOverlap,
                      (next) => preferences.update(
                        (value) => value.copyWith(useRegionOverlap: next),
                      ),
                    ),
                    _check(
                      'Corner Handles',
                      value.showCornerHandles,
                      (next) => preferences.update(
                        (value) => value.copyWith(showCornerHandles: next),
                      ),
                    ),
                    _check(
                      'Numeric Input Arrows',
                      value.showNumericInputArrows,
                      (next) => preferences.update(
                        (value) => value.copyWith(showNumericInputArrows: next),
                      ),
                    ),
                    _check(
                      'Navigation Controls',
                      value.showNavigationControls,
                      (next) => preferences.update(
                        (value) => value.copyWith(showNavigationControls: next),
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Border Width',
                      editor: BlenderNumberField(
                        value: value.borderWidth,
                        min: 1,
                        max: 10,
                        decimalDigits: 0,
                        onChanged: (borderWidth) => preferences.update(
                          (value) => value.copyWith(borderWidth: borderWidth),
                        ),
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Color Picker Type',
                      editor: BlenderDropdown<BlenderColorPickerType>(
                        value: value.colorPickerType,
                        items: const <BlenderMenuItem<BlenderColorPickerType>>[
                          BlenderMenuItem<BlenderColorPickerType>(
                            value: BlenderColorPickerType.circleHsv,
                            label: 'Circle (HSV)',
                          ),
                          BlenderMenuItem<BlenderColorPickerType>(
                            value: BlenderColorPickerType.circleHsl,
                            label: 'Circle (HSL)',
                          ),
                          BlenderMenuItem<BlenderColorPickerType>(
                            value: BlenderColorPickerType.squareSv,
                            label: 'Square (SV + H)',
                          ),
                          BlenderMenuItem<BlenderColorPickerType>(
                            value: BlenderColorPickerType.squareHs,
                            label: 'Square (HS + V)',
                          ),
                          BlenderMenuItem<BlenderColorPickerType>(
                            value: BlenderColorPickerType.squareHv,
                            label: 'Square (HV + S)',
                          ),
                        ],
                        onChanged: (colorPickerType) => preferences.update(
                          (value) =>
                              value.copyWith(colorPickerType: colorPickerType),
                        ),
                      ),
                    ),
                    BlenderPropertyRow(
                      label: 'Factor Display Type',
                      editor: BlenderDropdown<BlenderFactorDisplayType>(
                        value: value.factorDisplayType,
                        items:
                            const <BlenderMenuItem<BlenderFactorDisplayType>>[
                              BlenderMenuItem<BlenderFactorDisplayType>(
                                value: BlenderFactorDisplayType.factor,
                                label: 'Factor',
                              ),
                              BlenderMenuItem<BlenderFactorDisplayType>(
                                value: BlenderFactorDisplayType.percentage,
                                label: 'Percentage',
                              ),
                            ],
                        onChanged: (factorDisplayType) => preferences.update(
                          (value) => value.copyWith(
                            factorDisplayType: factorDisplayType,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _check(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: BlenderCheckbox(label: label, value: value, onChanged: onChanged),
    );
  }
}

/// Builds the standard sections that an application can add to its existing
/// [BlenderPreferencesConfiguration].
///
/// The `Themes` section is separate to mirror blenderapp's category layout;
/// hosts without a Themes category may pass [themesCategory] as `null` and the
/// selector will stay with the Interface display controls.
List<BlenderPreferenceSection> blenderInterfacePreferenceSections({
  required BlenderInterfacePreferencesService preferences,
  BlenderThemeService? themeService,
  BlenderThemeFileActions themeFileActions = const BlenderThemeFileActions(),
  String interfaceCategory = 'Interface',
  String? themesCategory = 'Themes',
  String idPrefix = 'blenderui-interface',
}) {
  return <BlenderPreferenceSection>[
    BlenderPreferenceSection(
      id: '$idPrefix-display',
      category: interfaceCategory,
      title: 'Display',
      searchTerms: const <String>[
        'Resolution Scale',
        'Line Width',
        'Splash Screen',
        'Developer Extras',
        'User Tooltips',
      ],
      child: BlenderInterfacePreferencesEditor(
        preferences: preferences,
        includeTheme: themesCategory == null,
        includeEditorOptions: false,
      ),
    ),
    BlenderPreferenceSection(
      id: '$idPrefix-editors',
      category: interfaceCategory,
      title: 'Editors',
      searchTerms: const <String>[
        'Region Overlap',
        'Corner Handles',
        'Numeric Input Arrows',
        'Navigation Controls',
        'Border Width',
        'Color Picker Type',
        'Factor Display Type',
      ],
      child: BlenderInterfacePreferencesEditor(
        preferences: preferences,
        includeTheme: false,
        includeDisplayOptions: false,
      ),
    ),
    if (themesCategory != null && themeService != null)
      blenderThemePreferenceSection(
        service: themeService,
        category: themesCategory,
        id: '$idPrefix-theme',
        fileActions: themeFileActions,
      )
    else if (themesCategory != null)
      BlenderPreferenceSection(
        id: '$idPrefix-theme',
        category: themesCategory,
        title: 'Theme',
        searchTerms: const <String>['Blender Dark', 'Blender Light'],
        child: BlenderInterfacePreferencesEditor(
          preferences: preferences,
          includeDisplayOptions: false,
          includeEditorOptions: false,
        ),
      ),
  ];
}

extension BlenderThemeDataInterfacePreferences on BlenderThemeData {
  /// Applies a portable interface preference snapshot to this theme.
  BlenderThemeData withInterfacePreferences(
    BlenderInterfacePreferences preferences,
  ) {
    final palette = preferences.theme == BlenderThemePreset.light
        ? const BlenderColorScheme.light()
        : const BlenderColorScheme.dark();
    return copyWith(colors: palette).withInterfaceMetrics(preferences);
  }

  /// Applies display-scale and line-width preferences without selecting a
  /// palette. Theme services use this path for imported/custom XML themes.
  BlenderThemeData withInterfaceMetrics(
    BlenderInterfacePreferences preferences,
  ) {
    final scale = preferences.uiScale;
    final lineWidth = switch (preferences.lineWidth) {
      BlenderInterfaceLineWidth.thin => .75,
      BlenderInterfaceLineWidth.automatic => 1.0,
      BlenderInterfaceLineWidth.thick => 1.5,
    };
    return copyWith(
      textTheme: textTheme.scaled(scale),
      density: density.scaled(scale),
      shapes: shapes.copyWith(borderWidth: lineWidth, focusWidth: lineWidth),
      iconTheme: iconTheme.copyWith(size: iconTheme.size * scale),
    );
  }
}
