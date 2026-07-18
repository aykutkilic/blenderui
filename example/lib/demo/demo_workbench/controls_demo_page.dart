part of '../demo_workbench.dart';

class _ControlsDemoPage extends StatelessWidget {
  const _ControlsDemoPage({
    required this.state,
    required this.textController,
    required this.onChanged,
    required this.onStatus,
  });

  final DemoState state;
  final TextEditingController textController;
  final void Function(DemoState state, String message) onChanged;
  final ValueChanged<String> onStatus;

  @override
  Widget build(BuildContext context) {
    return _DemoPageScroll(
      children: <Widget>[
        _DemoSection(
          title: 'Buttons and actions',
          description: 'Standard, toolbar, tab, menu, and selected states.',
          child: BlenderFlow(
            children: <Widget>[
              for (final variant in BlenderButtonVariant.values)
                BlenderButton(
                  label: variant.name,
                  variant: variant,
                  onPressed: () => onStatus('${variant.name} button pressed'),
                ),
              BlenderIconButton(
                glyph: BlenderGlyph.settings,
                selected: state.enabled,
                onPressed: () => onChanged(
                  state.copyWith(enabled: !state.enabled),
                  'Icon button toggled',
                ),
                tooltip: 'Toggle enabled state',
              ),
              BlenderButton(
                label: 'Disabled',
                enabled: false,
                onPressed: () {},
              ),
            ],
          ),
        ),
        _DemoSection(
          title: 'Selection controls',
          description: 'Checkbox, toggle, radio, and segmented selection.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              BlenderFlow(
                children: <Widget>[
                  BlenderCheckbox(
                    value: state.enabled,
                    label: 'Enabled',
                    onChanged: (value) => onChanged(
                      state.copyWith(enabled: value),
                      'Checkbox changed',
                    ),
                  ),
                  BlenderToggle(
                    value: state.toggle,
                    label: 'Toggle',
                    onChanged: (value) => onChanged(
                      state.copyWith(toggle: value),
                      'Toggle changed',
                    ),
                  ),
                  BlenderRadio<String>(
                    value: 'Object',
                    groupValue: state.mode,
                    label: 'Object mode',
                    onChanged: (value) =>
                        onChanged(state.copyWith(mode: value), 'Radio changed'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              BlenderSegmentedControl<String>(
                value: state.mode,
                items: const <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(value: 'Object', label: 'Object'),
                  BlenderMenuItem<String>(value: 'Edit', label: 'Edit'),
                  BlenderMenuItem<String>(value: 'Sculpt', label: 'Sculpt'),
                ],
                onChanged: (value) =>
                    onChanged(state.copyWith(mode: value), 'Segment changed'),
              ),
            ],
          ),
        ),
        _DemoSection(
          title: 'Numeric and text input',
          description: 'Drag, edit, constrain, and combine compact fields.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: BlenderSlider(
                      value: state.amount,
                      onChanged: (value) => onChanged(
                        state.copyWith(amount: value),
                        'Slider changed',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 130,
                    child: BlenderNumberField(
                      value: state.amount,
                      min: 0,
                      max: 1,
                      step: .01,
                      onChanged: (value) => onChanged(
                        state.copyWith(amount: value),
                        'Number changed',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(child: BlenderTextField(controller: textController)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BlenderDropdown<String>(
                      value: state.mode,
                      items: const <BlenderMenuItem<String>>[
                        BlenderMenuItem<String>(
                          value: 'Object',
                          label: 'Object',
                        ),
                        BlenderMenuItem<String>(value: 'Edit', label: 'Edit'),
                        BlenderMenuItem<String>(
                          value: 'Sculpt',
                          label: 'Sculpt',
                        ),
                      ],
                      onChanged: (value) => onChanged(
                        state.copyWith(mode: value),
                        'Dropdown changed',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _DemoSection(
          title: 'Feedback surfaces',
          description: 'Notices, progress, tooltips, and shortcut hints.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const BlenderNoticeBanner(
                message: 'Settings were applied successfully.',
                level: BlenderNoticeLevel.success,
              ),
              const SizedBox(height: 6),
              BlenderProgressBar(
                value: state.amount,
                label: 'Building preview',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
