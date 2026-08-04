import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tool options open on press and hold', (tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: BlenderTheme(
            child: StatefulBuilder(
              builder: (context, setState) => BlenderToolShelf(
                tools: const <BlenderToolDefinition>[
                  BlenderToolDefinition(
                    glyph: BlenderGlyph.pointer,
                    tooltip: 'Select',
                    options: <BlenderToolOption>[
                      BlenderToolOption(
                        label: 'Box Select',
                        glyph: BlenderGlyph.selectBox,
                      ),
                    ],
                  ),
                  BlenderToolDefinition(
                    glyph: BlenderGlyph.text,
                    tooltip: 'Text',
                  ),
                ],
                selectedIndex: selected,
                onChanged: (value) => setState(() => selected = value),
              ),
            ),
          ),
        ),
      ),
    );

    final firstButton = find
        .descendant(
          of: find.byType(BlenderToolShelf),
          matching: find.byType(BlenderIconButton),
        )
        .first;
    await tester.tap(firstButton);
    await tester.pump();
    expect(selected, 0);

    await tester.longPress(firstButton);
    await tester.pumpAndSettle();
    expect(find.text('Box Select'), findsOneWidget);
  });
}
