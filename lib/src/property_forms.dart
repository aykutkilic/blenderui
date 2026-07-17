import 'package:flutter/widgets.dart';

import 'controls.dart';
import 'editors.dart';
import 'icons.dart';
import 'layout.dart';
import 'theme.dart';

/// Immutable list updates used by vector and multi-axis property editors.
///
/// Applications retain ownership of the resulting value and persistence; this
/// helper prevents editor catalogs from reimplementing safe copy/update logic.
abstract final class BlenderPropertyValues {
  static List<T> replaceAt<T>(List<T> values, int index, T value) {
    RangeError.checkValidIndex(index, values);
    return List<T>.of(values)..[index] = value;
  }

  static List<bool> toggleAt(List<bool> values, int index) {
    RangeError.checkValidIndex(index, values);
    return List<bool>.of(values)..[index] = !values[index];
  }
}

/// A compact numeric transform axis editor with lock and keyframe decorators.
///
/// Values and editing callbacks remain caller-owned so the field works with
/// any transform model, property system, or animation service.
class BlenderTransformAxisField extends StatelessWidget {
  const BlenderTransformAxisField({
    super.key,
    required this.value,
    required this.decimalDigits,
    required this.locked,
    required this.onChanged,
    required this.onLockChanged,
    required this.onKeyframe,
    this.suffix,
    this.lockButtonKey,
    this.keyframeButtonKey,
  });

  final double value;
  final int decimalDigits;
  final bool locked;
  final ValueChanged<double> onChanged;
  final VoidCallback onLockChanged;
  final VoidCallback onKeyframe;
  final String? suffix;
  final Key? lockButtonKey;
  final Key? keyframeButtonKey;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: BlenderNumberField(
            value: value,
            step: decimalDigits == 0 ? 1 : .1,
            decimalDigits: decimalDigits,
            suffix: suffix,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 3),
        Semantics(
          button: true,
          label: locked ? 'Unlock transform axis' : 'Lock transform axis',
          child: BlenderIconButton(
            key: lockButtonKey,
            glyph: locked ? BlenderGlyph.lock : BlenderGlyph.unlock,
            selected: locked,
            tooltip: locked ? 'Unlock transform axis' : 'Lock transform axis',
            size: 20,
            onPressed: onLockChanged,
          ),
        ),
        BlenderKeyframeButton(
          key: keyframeButtonKey,
          color: theme.colors.foreground,
          onPressed: onKeyframe,
        ),
      ],
    );
  }
}

/// A compact rotation-mode selector with an animation keyframe decorator.
class BlenderRotationModeField extends StatelessWidget {
  const BlenderRotationModeField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onKeyframe,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onKeyframe;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: BlenderDropdown<String>(
            value: value,
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'XYZ Euler', label: 'XYZ Euler'),
              BlenderMenuItem<String>(value: 'XZY Euler', label: 'XZY Euler'),
              BlenderMenuItem<String>(value: 'YXZ Euler', label: 'YXZ Euler'),
              BlenderMenuItem<String>(value: 'Quaternion', label: 'Quaternion'),
              BlenderMenuItem<String>(value: 'Axis Angle', label: 'Axis Angle'),
            ],
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 23),
        BlenderKeyframeButton(
          color: BlenderTheme.of(context).colors.foreground,
          onPressed: onKeyframe,
        ),
      ],
    );
  }
}

/// A small animation decorator that invokes the caller's keyframe action.
class BlenderKeyframeButton extends StatelessWidget {
  const BlenderKeyframeButton({
    super.key,
    required this.color,
    required this.onPressed,
  });

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Insert keyframe',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: SizedBox(
          width: 14,
          height: 20,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: const SizedBox.square(dimension: 5),
            ),
          ),
        ),
      ),
    );
  }
}

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
    bool? showSteppers,
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
        showSteppers: showSteppers,
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
    return choice<String>(
      id,
      label,
      value,
      items,
      enabled: enabled,
      onChanged: onChanged,
      tooltip: tooltip,
    );
  }

  static BlenderPropertyDescriptor<T> choice<T>(
    String id,
    String label,
    T value,
    List<Object> items, {
    bool enabled = true,
    ValueChanged<T>? onChanged,
    String? tooltip,
  }) {
    final normalizedItems = <BlenderMenuItem<T>>[
      for (final item in items)
        if (item is BlenderMenuItem<T>)
          item
        else
          BlenderMenuItem<T>(value: item as T, label: item.toString()),
    ];
    return BlenderPropertyDescriptor<T>(
      id: id,
      label: label,
      value: value,
      enabled: enabled,
      tooltip: tooltip,
      editorBuilder: (context, current, update) => BlenderDropdown<T>(
        value: current,
        items: normalizedItems,
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
    bool? expanded,
    bool toggle = false,
    bool enabled = true,
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
      initiallyExpanded: expanded ?? initiallyExpanded,
      enabled: enabled,
      headerLeading:
          headerLeading ??
          (toggle ? const BlenderCheckbox(value: true, onChanged: null) : null),
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
