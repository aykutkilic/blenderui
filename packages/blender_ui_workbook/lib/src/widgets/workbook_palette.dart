import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';

/// The workbook extension deliberately consumes BlenderUI's semantic colors
/// instead of leaking Material's ambient [ColorScheme] into editor surfaces.
///
/// Keeping this adapter in one place makes CodeForge, plots, and notebook
/// chrome respond consistently to BlenderUI light/dark theme changes.
final class WorkbookPalette {
  const WorkbookPalette._({required this.colors});

  factory WorkbookPalette.of(BuildContext context) =>
      WorkbookPalette._(colors: BlenderTheme.of(context).colors);

  final BlenderColorScheme colors;

  Color get canvas => colors.canvas;
  Color get surface => colors.surface;
  Color get elevated => colors.surfaceElevated;
  Color get raised => colors.surfaceRaised;
  Color get foreground => colors.foreground;
  Color get muted => colors.foregroundMuted;
  Color get disabled => colors.foregroundDisabled;
  Color get accent => colors.accent;
  Color get focus => colors.focus;
  Color get outline => colors.borderSubtle;
  Color get error => colors.error;
  Color get warning => colors.warning;
}
