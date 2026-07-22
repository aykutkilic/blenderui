part of '../showcase_app.dart';

/// Example-owned builder for the brush-setting vocabulary shared by paint,
/// sculpt, and Grease Pencil demonstrations.
///
/// Values remain fixtures owned by the showcase; this class only removes the
/// three parallel widget DSLs that previously constructed identical controls.
class _ShowcaseBrushControls {
  const _ShowcaseBrushControls(this.owner);

  final _ShowcaseAppState owner;

  Widget checkbox(String label, {bool value = true}) =>
      owner._buildToolCheckbox(value: value, label: label, onChanged: (_) {});

  Widget number(String label, double value) => BlenderPropertyRow(
    label: label,
    editor: BlenderNumberField(
      value: value,
      decimalDigits: 2,
      onChanged: (_) {},
    ),
  );

  Widget dropdown(String label, String value, List<String> values) =>
      BlenderPropertyRow(
        label: label,
        editor: BlenderDropdown<String>(
          value: value,
          items: <BlenderMenuItem<String>>[
            for (final item in values)
              BlenderMenuItem<String>(value: item, label: item),
          ],
          onChanged: (_) {},
        ),
      );

  Widget nested(String title, Widget child) {
    final expanded = owner._toolBrushPanelExpanded[title] ?? false;
    return owner._buildNestedToolPanel(
      title: title,
      expanded: expanded,
      onToggle: () => owner._update(() {
        owner._toolBrushPanelExpanded[title] = !expanded;
      }),
      child: child,
    );
  }
}
