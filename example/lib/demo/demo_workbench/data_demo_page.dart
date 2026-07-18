part of '../demo_workbench.dart';

class _DataDemoPage extends StatelessWidget {
  const _DataDemoPage({required this.state, required this.onChanged});

  final DemoState state;
  final void Function(DemoState state, String message) onChanged;

  @override
  Widget build(BuildContext context) {
    return _DemoPageScroll(
      children: <Widget>[
        _DemoSection(
          title: 'Vector template',
          description: 'Compact axis fields remain caller-owned.',
          child: BlenderVectorField(
            values: state.vector,
            onChanged: (value) =>
                onChanged(state.copyWith(vector: value), 'Vector changed'),
          ),
        ),
        _DemoSection(
          title: 'Descriptor-driven Properties',
          description:
              'Property metadata is independent from domain models and can be searched or reordered.',
          child: SizedBox(
            height: 270,
            child: BlenderPropertiesEditor(
              title: 'Object',
              headerLeading: const BlenderIcon(BlenderGlyph.object, size: 18),
              groups: <BlenderPropertyGroup>[
                BlenderPropertyGroup(
                  id: 'demo-transform',
                  title: 'Transform',
                  properties: <BlenderPropertyDescriptor<dynamic>>[
                    BlenderPropertyDescriptor<double>(
                      id: 'amount',
                      label: 'Influence',
                      value: state.amount,
                      editorBuilder: (context, value, changed) =>
                          BlenderNumberField(
                            value: value,
                            min: 0,
                            max: 1,
                            step: .01,
                            onChanged: changed,
                          ),
                      onChanged: (value) => onChanged(
                        state.copyWith(amount: value),
                        'Property changed',
                      ),
                    ),
                    BlenderPropertyDescriptor<bool>(
                      id: 'enabled',
                      label: 'Enabled',
                      value: state.enabled,
                      editorBuilder: (context, value, changed) =>
                          BlenderCheckbox(value: value, onChanged: changed),
                      onChanged: (value) => onChanged(
                        state.copyWith(enabled: value),
                        'Property changed',
                      ),
                    ),
                  ],
                  children: const <BlenderPropertyGroup>[
                    BlenderPropertyGroup(
                      id: 'demo-delta',
                      title: 'Advanced',
                      initiallyExpanded: false,
                      properties: <BlenderPropertyDescriptor<dynamic>>[],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        _DemoSection(
          title: 'Lists and trees',
          description: 'Selection, hierarchy guides, and restriction controls.',
          child: SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: BlenderListView<String>(
                    selectedId: state.mode.toLowerCase(),
                    items: const <BlenderListItem<String>>[
                      BlenderListItem<String>(
                        id: 'object',
                        label: 'Object',
                        value: 'Object',
                        icon: BlenderGlyph.object,
                      ),
                      BlenderListItem<String>(
                        id: 'edit',
                        label: 'Edit',
                        value: 'Edit',
                        icon: BlenderGlyph.transform,
                      ),
                      BlenderListItem<String>(
                        id: 'sculpt',
                        label: 'Sculpt',
                        value: 'Sculpt',
                        icon: BlenderGlyph.modifier,
                      ),
                    ],
                    onSelected: (item) => onChanged(
                      state.copyWith(mode: item.value),
                      'List selection changed',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BlenderTree<String>(
                    selectedId: 'cube',
                    showVisibility: true,
                    showLock: true,
                    roots: const <BlenderTreeNode<String>>[
                      BlenderTreeNode<String>(
                        id: 'collection',
                        label: 'Collection',
                        icon: BlenderGlyph.collection,
                        initiallyExpanded: true,
                        children: <BlenderTreeNode<String>>[
                          BlenderTreeNode<String>(
                            id: 'cube',
                            label: 'Cube',
                            value: 'Cube',
                            icon: BlenderGlyph.object,
                          ),
                          BlenderTreeNode<String>(
                            id: 'light',
                            label: 'Light',
                            value: 'Light',
                            icon: BlenderGlyph.light,
                          ),
                        ],
                      ),
                    ],
                    onSelected: (_) {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
