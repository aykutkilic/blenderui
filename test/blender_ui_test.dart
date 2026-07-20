import 'dart:ui' as ui;

import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

part 'blender_ui/multi_column_menu_reuses_compact_editor_menu.dart';
part 'blender_ui/dialog_routes_retain_a_live_blender_theme.dart';
part 'blender_ui/light_top_bar_menus_use_blender_themetopbar.dart';
part 'blender_ui/workspace_service_clears_a_durable_session_after.dart';
part 'blender_ui/color_picker_emits_a_changed_color.dart';
part 'blender_ui/running_jobs_panel_includes_source_status_rows.dart';
part 'blender_ui/properties_context_tiles_fill_their_navigation_rail.dart';
part 'blender_ui/operator_redo_and_property_dialog_preserve_popup.dart';
part 'blender_ui/status_info_preserves_version_extension_and_warning.dart';
part 'blender_ui/view3d_chrome_is_library_owned.dart';
part 'blender_ui/context_menus_follow_blender_regions_and_targets.dart';
part 'blender_ui/resolution_scale_scales_menu_and_tab_geometry.dart';

Widget _harness(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: BlenderTheme(child: child),
  );
}

class _TreeFixture {
  const _TreeFixture(
    this.id,
    this.initiallyExpanded, [
    this.children = const [],
  ]);

  final String id;
  final bool initiallyExpanded;
  final List<_TreeFixture> children;
}

void main() {
  registerMultiColumnMenuReusesCompactEditorMenuTests();
  registerDialogRoutesRetainALiveBlenderThemeTests();
  registerLightTopBarMenusUseBlenderThemetopbarTests();
  registerWorkspaceServiceClearsADurableSessionAfterTests();
  registerColorPickerEmitsAChangedColorTests();
  registerRunningJobsPanelIncludesSourceStatusRowsTests();
  registerPropertiesContextTilesFillTheirNavigationRailTests();
  registerOperatorRedoAndPropertyDialogPreservePopupTests();
  registerStatusInfoPreservesVersionExtensionAndWarningTests();
  registerView3dChromeIsLibraryOwnedTests();
  registerContextMenusFollowBlenderRegionsAndTargetsTests();
  registerResolutionScaleScalesMenuAndTabGeometryTests();
}

void _ignoreDouble(double value) {}

Widget _emptyDoubleEditor(
  BuildContext context,
  double value,
  ValueChanged<double> onChanged,
) => const SizedBox(height: 20);

void _ignoreString(String value) {}

void _ignoreStringSet(Set<String> value) {}

void _ignoreBool(bool value) {}

void _ignoreInt(int value) {}

void _ignoreMenuItem(BlenderMenuItem<String> item) {}

void _ignoreVoid() {}

void _ignoreOffset(Offset value) {}

void _ignoreMatrix(List<List<double>> value) {}

void _ignoreCacheFileSettings(BlenderCacheFileSettings value) {}

String _workspaceStringToJson(String value) => value;

String _workspaceStringFromJson(Object? value) {
  if (value is! String) throw const FormatException('Expected an editor id.');
  return value;
}

String? _workspaceNullableStringToJson(String? value) => value;

String? _workspaceNullableStringFromJson(Object? value) {
  if (value == null || value is String) return value as String?;
  throw const FormatException('Expected a nullable value.');
}

BlenderWorkspaceService<String> _persistentWorkspaceService(
  BlenderWorkspacePersistence<String> persistence, {
  BlenderWorkspaceSessionState? sessionState,
}) => BlenderWorkspaceService<String>(
  persistence: persistence,
  workspaces: <BlenderWorkspaceDefinition<String>>[
    BlenderWorkspaceDefinition<String>(
      id: 'folders',
      sessionState: sessionState,
      layout: const BlenderDockAreaNode<String>(
        id: 'folders-outliner',
        value: 'outliner',
      ),
    ),
    const BlenderWorkspaceDefinition<String>(
      id: 'authoring',
      layout: BlenderDockAreaNode<String>(
        id: 'authoring-page',
        value: 'page-editor',
      ),
    ),
  ],
);

class _WorkspaceMemoryStorage implements BlenderWorkspaceStorage {
  final Map<String, String> values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> remove(String key) async {
    values.remove(key);
  }

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}

class _RetainedWorkspaceProbe extends StatefulWidget {
  const _RetainedWorkspaceProbe({required this.label});

  final String label;

  @override
  State<_RetainedWorkspaceProbe> createState() =>
      _RetainedWorkspaceProbeState();
}

class _RetainedWorkspaceProbeState extends State<_RetainedWorkspaceProbe> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('${widget.label}: $_count'),
        GestureDetector(
          key: ValueKey<String>('${widget.label}-increment'),
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _count++),
          child: const SizedBox(width: 40, height: 24),
        ),
      ],
    );
  }
}
