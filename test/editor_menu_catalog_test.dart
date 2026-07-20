import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('editor menu catalog centralizes fallback and detailed entries', () {
    String? selected;
    final menus = BlenderEditorMenuCatalog.build(
      const <String>['View', 'Select', 'Node'],
      menuItems: const <String, List<String>>{
        'View': <String>['Frame All', 'Sidebar'],
      },
      menuDescriptors: const <String, List<BlenderMenuItem<String>>>{
        'Node': <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Mute', label: 'Mute'),
          BlenderMenuItem<String>(value: 'Delete', label: 'Delete'),
        ],
      },
      onSelected: (value) => selected = value,
    );

    expect(menus.map((menu) => menu.label), <String>['View', 'Select', 'Node']);
    expect(menus[0].items.map((item) => item.label), <String>[
      'Frame All',
      'Sidebar',
    ]);
    expect(menus[1].items.single.label, 'Select Options');
    expect(menus[2].items.map((item) => item.label), <String>[
      'Mute',
      'Delete',
    ]);

    menus[2].onSelected?.call('Mute');
    expect(selected, 'Mute');
  });

  testWidgets('utility header owns source menu families', (tester) async {
    Future<List<String>> pumpHeader(
      BlenderEditorType editorType, {
      bool outlinerDataApi = false,
    }) async {
      await tester.pumpWidget(
        WidgetsApp(
          color: const Color(0xFF202020),
          builder: (context, child) => BlenderTheme(
            child: BlenderUtilityEditorHeader(
              editorType: editorType,
              outlinerDataApi: outlinerDataApi,
            ),
          ),
        ),
      );
      final header = tester.widget<BlenderAreaHeader>(
        find.byType(BlenderAreaHeader),
      );
      return header.menuDescriptors
          .map((menu) => (menu as BlenderMenuDescriptor<String>).label)
          .toList(growable: false);
    }

    expect(await pumpHeader(BlenderEditorType.textEditor), <String>[
      'View',
      'Text',
      'Edit',
      'Select',
      'Format',
      'Templates',
    ]);
    expect(await pumpHeader(BlenderEditorType.outliner), isEmpty);
    expect(
      await pumpHeader(BlenderEditorType.outliner, outlinerDataApi: true),
      <String>['Edit'],
    );
  });
}
