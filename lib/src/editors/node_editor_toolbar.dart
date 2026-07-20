part of '../editors.dart';

/// Standard floating Node Editor tools from Blender's tool system.
class BlenderNodeToolShelf extends StatelessWidget {
  const BlenderNodeToolShelf({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    this.onOptionSelected,
    this.width = 42,
    this.floating = true,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final ValueChanged<BlenderToolOption>? onOptionSelected;
  final double width;
  final bool floating;

  static const List<BlenderToolDefinition> tools = <BlenderToolDefinition>[
    BlenderToolDefinition(
      glyph: BlenderGlyph.pointer,
      tooltip: 'Select',
      options: <BlenderToolOption>[
        BlenderToolOption(
          label: 'Tweak',
          glyph: BlenderGlyph.pointer,
          description: 'Select and move nodes directly.',
        ),
        BlenderToolOption(
          label: 'Select Box',
          glyph: BlenderGlyph.selectBox,
          shortcut: 'W',
          description: 'Select nodes inside a rectangular region.',
        ),
        BlenderToolOption(
          label: 'Select Circle',
          glyph: BlenderGlyph.radio,
          shortcut: 'C',
          description: 'Select nodes inside a circular region.',
        ),
        BlenderToolOption(
          label: 'Select Lasso',
          glyph: BlenderGlyph.pointer,
          description: 'Select nodes inside a freeform region.',
        ),
      ],
    ),
    BlenderToolDefinition(glyph: BlenderGlyph.pan, tooltip: 'Move View'),
    BlenderToolDefinition(
      glyph: BlenderGlyph.link,
      tooltip: 'Cut Links',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.linkBroken,
      tooltip: 'Mute Links',
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.tool,
      tooltip: 'Annotate',
      groupBreakBefore: true,
    ),
    BlenderToolDefinition(
      glyph: BlenderGlyph.plus,
      tooltip: 'Add Node',
      groupBreakBefore: true,
    ),
  ];

  @override
  Widget build(BuildContext context) => BlenderToolShelf(
    tools: tools,
    selectedIndex: selectedIndex,
    onChanged: onChanged,
    onOptionSelected: onOptionSelected,
    width: width,
    floating: floating,
  );
}
