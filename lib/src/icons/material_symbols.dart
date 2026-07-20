part of '../icons.dart';

/// Apache-licensed Material Symbols equivalents for Blender's semantic icon
/// catalog. The mapping deliberately follows meaning instead of code-point or
/// silhouette identity so it remains stable as either catalog evolves.
IconData _materialSymbolFor(BlenderGlyph glyph) => switch (glyph) {
  BlenderGlyph.menu => Symbols.menu,
  BlenderGlyph.close => Symbols.close,
  BlenderGlyph.chevronDown ||
  BlenderGlyph.panelDisclosureDown => Symbols.keyboard_arrow_down,
  BlenderGlyph.chevronUp => Symbols.keyboard_arrow_up,
  BlenderGlyph.chevronRight ||
  BlenderGlyph.panelDisclosureRight => Symbols.keyboard_arrow_right,
  BlenderGlyph.plus => Symbols.add,
  BlenderGlyph.minus => Symbols.remove,
  BlenderGlyph.search => Symbols.search,
  BlenderGlyph.settings => Symbols.settings,
  BlenderGlyph.preferences || BlenderGlyph.preset => Symbols.tune,
  BlenderGlyph.arrowLeftRight || BlenderGlyph.areaSwap => Symbols.swap_horiz,
  BlenderGlyph.folder => Symbols.folder,
  BlenderGlyph.play => Symbols.play_arrow,
  BlenderGlyph.pause => Symbols.pause,
  BlenderGlyph.eye => Symbols.visibility,
  BlenderGlyph.lock => Symbols.lock,
  BlenderGlyph.unlock => Symbols.lock_open,
  BlenderGlyph.link => Symbols.link,
  BlenderGlyph.internet => Symbols.public,
  BlenderGlyph.internetOffline => Symbols.cloud_off,
  BlenderGlyph.diskDrive => Symbols.hard_drive,
  BlenderGlyph.keyShift ||
  BlenderGlyph.keyControl ||
  BlenderGlyph.keyOption ||
  BlenderGlyph.keyWindows => Symbols.keyboard,
  BlenderGlyph.keyCommand => Symbols.keyboard_command_key,
  BlenderGlyph.mouseLeft ||
  BlenderGlyph.mouseRight ||
  BlenderGlyph.mouseMiddle ||
  BlenderGlyph.mouseLeftDrag ||
  BlenderGlyph.mouseRightDrag ||
  BlenderGlyph.mouseMiddleDrag => Symbols.mouse,
  BlenderGlyph.pointer => Symbols.arrow_selector_tool,
  BlenderGlyph.selectBox => Symbols.select_all,
  BlenderGlyph.selectExtend => Symbols.select_check_box,
  BlenderGlyph.selectSubtract => Symbols.deselect,
  BlenderGlyph.selectDifference => Symbols.difference,
  BlenderGlyph.selectIntersect => Symbols.filter_center_focus,
  BlenderGlyph.check => Symbols.check,
  BlenderGlyph.radio => Symbols.radio_button_checked,
  BlenderGlyph.dragHandle || BlenderGlyph.grip => Symbols.drag_indicator,
  BlenderGlyph.cube ||
  BlenderGlyph.mesh ||
  BlenderGlyph.solid ||
  BlenderGlyph.wireframe => Symbols.deployed_code,
  BlenderGlyph.image => Symbols.image,
  BlenderGlyph.texture => Symbols.texture,
  BlenderGlyph.assetManager => Symbols.inventory_2,
  BlenderGlyph.uv || BlenderGlyph.lattice => Symbols.grid_on,
  BlenderGlyph.node || BlenderGlyph.outliner => Symbols.account_tree,
  BlenderGlyph.timeline => Symbols.timeline,
  BlenderGlyph.sequence => Symbols.video_library,
  BlenderGlyph.action => Symbols.animation,
  BlenderGlyph.movie => Symbols.movie,
  BlenderGlyph.text => Symbols.text_fields,
  BlenderGlyph.console => Symbols.terminal,
  BlenderGlyph.properties => Symbols.tune,
  BlenderGlyph.spreadsheet => Symbols.table,
  BlenderGlyph.collection => Symbols.folder_copy,
  BlenderGlyph.object => Symbols.category,
  BlenderGlyph.curve => Symbols.gesture,
  BlenderGlyph.curves => Symbols.polyline,
  BlenderGlyph.pointcloud => Symbols.scatter_plot,
  BlenderGlyph.speaker => Symbols.volume_up,
  BlenderGlyph.volume || BlenderGlyph.metaball => Symbols.blur_on,
  BlenderGlyph.empty => Symbols.crop,
  BlenderGlyph.lightprobe || BlenderGlyph.light => Symbols.lightbulb,
  BlenderGlyph.greasepencil => Symbols.draw,
  BlenderGlyph.armature => Symbols.accessibility_new,
  BlenderGlyph.bone => Symbols.schema,
  BlenderGlyph.shaderfx => Symbols.experiment,
  BlenderGlyph.viewLayer || BlenderGlyph.overlay => Symbols.layers,
  BlenderGlyph.camera => Symbols.camera,
  BlenderGlyph.material || BlenderGlyph.materialPreview => Symbols.palette,
  BlenderGlyph.gizmo ||
  BlenderGlyph.transform ||
  BlenderGlyph.scale => Symbols.open_with,
  BlenderGlyph.xray => Symbols.visibility,
  BlenderGlyph.rendered || BlenderGlyph.render => Symbols.videocam,
  BlenderGlyph.modifier => Symbols.construction,
  BlenderGlyph.physics => Symbols.science,
  BlenderGlyph.scene => Symbols.scene,
  BlenderGlyph.world => Symbols.public,
  BlenderGlyph.output => Symbols.output,
  BlenderGlyph.tool => Symbols.build,
  BlenderGlyph.rotate => Symbols.rotate_right,
  BlenderGlyph.pan => Symbols.pan_tool,
  BlenderGlyph.zoom => Symbols.zoom_in,
  BlenderGlyph.deleteIcon => Symbols.delete,
  BlenderGlyph.duplicate => Symbols.content_copy,
  BlenderGlyph.record => Symbols.fiber_manual_record,
  BlenderGlyph.stepBack => Symbols.skip_previous,
  BlenderGlyph.stepForward => Symbols.skip_next,
  BlenderGlyph.undo => Symbols.undo,
  BlenderGlyph.redo => Symbols.redo,
  BlenderGlyph.snap => Symbols.filter_center_focus,
  BlenderGlyph.pin => Symbols.push_pin,
  BlenderGlyph.filter => Symbols.filter_alt,
  BlenderGlyph.sort || BlenderGlyph.sortDescending => Symbols.sort,
  BlenderGlyph.sortAlphabetically => Symbols.sort_by_alpha,
  BlenderGlyph.refresh => Symbols.refresh,
  BlenderGlyph.sync => Symbols.sync,
  BlenderGlyph.maximize => Symbols.fullscreen,
  BlenderGlyph.minimize => Symbols.fullscreen_exit,
  BlenderGlyph.split => Symbols.splitscreen,
  BlenderGlyph.splitHorizontal => Symbols.horizontal_split,
  BlenderGlyph.splitVertical => Symbols.vertical_split,
  BlenderGlyph.areaJoinRight => Symbols.arrow_right_alt,
  BlenderGlyph.areaJoinLeft => Symbols.arrow_left_alt,
  BlenderGlyph.areaJoinUp => Symbols.arrow_upward_alt,
  BlenderGlyph.areaJoinDown => Symbols.arrow_downward_alt,
  BlenderGlyph.more => Symbols.more_horiz,
  BlenderGlyph.color => Symbols.colors,
  BlenderGlyph.eyedropper => Symbols.colorize,
  BlenderGlyph.linkBroken => Symbols.link_off,
  BlenderGlyph.keyframe => Symbols.key,
  BlenderGlyph.warning || BlenderGlyph.warningFilled => Symbols.warning,
  BlenderGlyph.info || BlenderGlyph.statusInfo => Symbols.info,
  BlenderGlyph.error || BlenderGlyph.errorFilled => Symbols.error,
  BlenderGlyph.checkCircle => Symbols.check_circle,
  BlenderGlyph.home => Symbols.home,
  BlenderGlyph.file => Symbols.draft,
  BlenderGlyph.fileBlend || BlenderGlyph.open => Symbols.file_open,
  BlenderGlyph.fileBackup => Symbols.backup,
  BlenderGlyph.save => Symbols.save,
  BlenderGlyph.export => Symbols.ios_share,
  BlenderGlyph.grid => Symbols.grid_4x4,
};

bool _materialSymbolIsFilled(BlenderGlyph glyph) => switch (glyph) {
  BlenderGlyph.warningFilled ||
  BlenderGlyph.errorFilled ||
  BlenderGlyph.record ||
  BlenderGlyph.radio => true,
  _ => false,
};
