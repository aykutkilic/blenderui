import 'package:blender_ui_example/main.dart';
import 'package:blender_ui_example/demo/demo_workbench.dart';
import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/gestures.dart' show kSecondaryMouseButton;
import 'package:flutter/widgets.dart'
    show
        BoxDecoration,
        CustomPaint,
        DecoratedBox,
        GestureDetector,
        Offset,
        Scrollable,
        Size,
        SizedBox,
        ValueKey;
import 'package:flutter_test/flutter_test.dart';

import '../lib/showcase_viewport.dart';

part 'showcase/showcase_boots_with_blender_like_editor_regions.dart';
part 'showcase/normal_outliner_header_keeps_source_display_controls.dart';
part 'showcase/node_editor_exposes_source_sidebar_families.dart';
part 'showcase/tool_properties_follows_blender_sculpt_mode_panel.dart';
part 'showcase/scene_properties_follows_blender_panel_anatomy.dart';
part 'showcase/lattice_data_follows_blender_source_panel_anatomy.dart';
part 'showcase/physics_properties_follows_blender_source_panel_anatomy.dart';
part 'showcase/timeline_header_popovers_expose_source_time_settings.dart';
part 'showcase/context_menus_follow_the_pointed_entity.dart';

Future<void> tapPropertyTab(WidgetTester tester, String id) async {
  final tab = find.byKey(ValueKey<String>('property-tab-$id'));
  final rail = find.byType(BlenderPropertyTabs);
  final scrollable = find.descendant(
    of: rail,
    matching: find.byType(Scrollable),
  );
  for (var attempt = 0; attempt < 10; attempt++) {
    if (tab.evaluate().isNotEmpty) {
      await tester.tap(tab);
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(scrollable, const Offset(0, -420));
    await tester.pumpAndSettle();
  }
  throw StateError('Properties tab $id was not mounted after scrolling');
}

void main() {
  registerShowcaseBootsWithBlenderLikeEditorRegionsTests();
  registerNormalOutlinerHeaderKeepsSourceDisplayControlsTests();
  registerNodeEditorExposesSourceSidebarFamiliesTests();
  registerToolPropertiesFollowsBlenderSculptModePanelTests();
  registerScenePropertiesFollowsBlenderPanelAnatomyTests();
  registerLatticeDataFollowsBlenderSourcePanelAnatomyTests();
  registerPhysicsPropertiesFollowsBlenderSourcePanelAnatomyTests();
  registerTimelineHeaderPopoversExposeSourceTimeSettingsTests();
  registerContextMenusFollowThePointedEntityTests();
}
