import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BlenderCommandRegistry registry() => BlenderCommandRegistry()
    ..register(
      BlenderCommand(
        id: 'view3d.add.armature',
        label: 'Armature',
        menuPath: const <String>['3D Viewport', 'Add'],
        glyph: BlenderGlyph.armature,
        execute: () {},
      ),
    )
    ..register(
      BlenderCommand(
        id: 'view3d.add.camera',
        label: 'Camera',
        menuPath: const <String>['3D Viewport', 'Add'],
        glyph: BlenderGlyph.camera,
        execute: () {},
      ),
    )
    ..register(
      BlenderCommand(
        id: 'file.save',
        label: 'Save Mainfile',
        menuPath: const <String>['File'],
        shortcut: 'Ctrl S',
        execute: () {},
      ),
    );

  test(
    'command search ranks labels paths fuzzy matches and recent use',
    () async {
      final commands = registry();
      addTearDown(commands.dispose);

      expect(commands.search('camera').first.id, 'view3d.add.camera');
      expect(commands.search('').first.id, 'view3d.add.armature');
      expect(commands.search('viewport arm').single.id, 'view3d.add.armature');
      expect(commands.search('cmra').single.id, 'view3d.add.camera');
      expect(commands.search('not present'), isEmpty);

      await commands.execute('file.save');
      expect(commands.search('').first.id, 'file.save');
    },
  );

  testWidgets('menu search supports filtering keyboard selection and icons', (
    tester,
  ) async {
    final commands = registry();
    addTearDown(commands.dispose);
    BlenderCommand? selected;
    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 720,
          height: 360,
          child: BlenderMenuSearch(
            commands: commands,
            onSelected: (command) => selected = command,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.textContaining('3D Viewport'), findsWidgets);
    expect(find.byType(BlenderIcon), findsWidgets);

    final field = find.descendant(
      of: find.byKey(const ValueKey<String>('menu-search-field')),
      matching: find.byType(EditableText),
    );
    await tester.enterText(field, 'camera');
    await tester.pump();
    expect(find.textContaining('Camera'), findsOneWidget);
    expect(find.textContaining('Armature'), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(selected?.id, 'view3d.add.camera');
  });
}
