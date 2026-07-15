import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'editors.dart';
import 'layout.dart';

/// Shared constructors for descriptor-backed Blender property forms.
///
/// Property catalogs should describe data and ownership, not repeat the
/// `BlenderPropertyDescriptor` plumbing for every boolean, number, and menu
/// field. Callers keep their state callbacks while this factory owns the
/// visual editor mapping.
abstract final class BlenderPropertyFactory {
  static BlenderPropertyDescriptor<bool> boolean(
    String id,
    String label,
    bool value, {
    bool enabled = true,
    ValueChanged<bool>? onChanged,
    String? tooltip,
  }) {
    return BlenderPropertyDescriptor<bool>(
      id: id,
      label: label,
      value: value,
      enabled: enabled,
      tooltip: tooltip,
      editorBuilder: (context, current, update) =>
          BlenderCheckbox(value: current, enabled: enabled, onChanged: update),
      onChanged: onChanged,
    );
  }

  static BlenderPropertyDescriptor<double> number(
    String id,
    String label,
    double value, {
    double? min,
    double? max,
    double step = 1,
    int decimalDigits = 2,
    String? suffix,
    bool enabled = true,
    ValueChanged<double>? onChanged,
    String? tooltip,
  }) {
    return BlenderPropertyDescriptor<double>(
      id: id,
      label: label,
      value: value,
      enabled: enabled,
      tooltip: tooltip,
      editorBuilder: (context, current, update) => BlenderNumberField(
        value: current,
        min: min,
        max: max,
        step: step,
        decimalDigits: decimalDigits,
        suffix: suffix,
        enabled: enabled,
        onChanged: update,
      ),
      onChanged: onChanged,
    );
  }

  static BlenderPropertyDescriptor<String> menu(
    String id,
    String label,
    String value,
    List<BlenderMenuItem<String>> items, {
    bool enabled = true,
    ValueChanged<String>? onChanged,
    String? tooltip,
  }) {
    return BlenderPropertyDescriptor<String>(
      id: id,
      label: label,
      value: value,
      enabled: enabled,
      tooltip: tooltip,
      editorBuilder: (context, current, update) => BlenderDropdown<String>(
        value: current,
        items: items,
        enabled: enabled,
        onChanged: update,
      ),
      onChanged: onChanged,
    );
  }

  static BlenderPropertyGroup panel(
    String id,
    String title, {
    bool initiallyExpanded = false,
    Widget? headerLeading,
    List<Widget>? headerActions,
    List<BlenderPropertyDescriptor<dynamic>> properties =
        const <BlenderPropertyDescriptor<dynamic>>[],
    List<BlenderPropertyGroup> children = const <BlenderPropertyGroup>[],
    Widget? content,
  }) {
    return BlenderPropertyGroup(
      id: id,
      title: title,
      initiallyExpanded: initiallyExpanded,
      headerLeading: headerLeading,
      headerActions: headerActions,
      properties: properties,
      children: children,
      content: content,
    );
  }
}

/// A compact descriptor for a sidebar section.
class BlenderSidebarSection {
  const BlenderSidebarSection({
    required this.id,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  final String id;
  final String title;
  final Widget child;
  final bool initiallyExpanded;
}

/// Reusable presentation for Blender editor sidebars made of collapsible
/// panels. It replaces the repeated `_body`/`_panel` helpers that had diverged
/// across individual editor implementations.
class BlenderSidebarSections extends StatelessWidget {
  const BlenderSidebarSections({
    super.key,
    required this.sections,
    this.padding = const EdgeInsets.all(6),
  });

  final List<BlenderSidebarSection> sections;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: padding,
      children: <Widget>[
        for (final section in sections)
          BlenderPanel(
            title: section.title,
            collapsible: true,
            initiallyExpanded: section.initiallyExpanded,
            child: section.child,
          ),
      ],
    );
  }
}

/// Builds a vertically-stretched static form body for sidebar sections.
Widget blenderFormColumn(List<Widget> children) =>
    Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);

/// Compact static form field helpers for documentation and visual-only
/// surfaces. Stateful applications should prefer [BlenderPropertyFactory].
abstract final class BlenderStaticPropertyField {
  static BlenderPropertyRow checkbox(String label, {bool value = true}) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderCheckbox(value: value, onChanged: (_) {}),
    );
  }

  static BlenderPropertyRow number(
    String label,
    double value, {
    int decimalDigits = 2,
  }) {
    return BlenderPropertyRow(
      label: label,
      editor: BlenderNumberField(
        value: value,
        decimalDigits: decimalDigits,
        onChanged: (_) {},
      ),
    );
  }

  static BlenderPropertyRow menu(
    String label,
    String value,
    List<String> values,
  ) {
    return BlenderPropertyRow(
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
  }
}
