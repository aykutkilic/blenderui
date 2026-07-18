part of '../templates.dart';

class BlenderRecentFile {
  const BlenderRecentFile({
    required this.id,
    required this.name,
    required this.path,
    this.detail,
    this.isBackup = false,
  });

  final String id;
  final String name;
  final String path;
  final String? detail;
  final bool isBackup;
}

/// A compact recent-file template used by Blender's file and splash menus.
class BlenderRecentFiles extends StatelessWidget {
  const BlenderRecentFiles({
    super.key,
    required this.files,
    this.onSelected,
    this.onClear,
    this.title = 'Recent Files',
  });

  final List<BlenderRecentFile> files;
  final ValueChanged<BlenderRecentFile>? onSelected;
  final VoidCallback? onClear;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = BlenderTheme.of(context);
    return BlenderPanel(
      title: title,
      headerActions: onClear == null
          ? null
          : <Widget>[
              BlenderIconButton(
                glyph: BlenderGlyph.deleteIcon,
                onPressed: onClear,
                tooltip: 'Clear recent files',
                size: 22,
              ),
            ],
      padding: EdgeInsets.zero,
      child: files.isEmpty
          ? Center(
              child: Text(
                'No recent files',
                style: theme.textTheme.caption.copyWith(
                  color: theme.colors.foregroundMuted,
                ),
              ),
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final isBackup =
                    file.isBackup ||
                    RegExp(r'\.blend\d+$').hasMatch(file.path.toLowerCase());
                final row = GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onSelected == null ? null : () => onSelected!(file),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: <Widget>[
                        BlenderIcon(
                          isBackup
                              ? BlenderGlyph.fileBackup
                              : BlenderGlyph.fileBlend,
                          size: 16,
                          color: theme.colors.iconFolder,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            file.name,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                final tooltip = file.detail == null
                    ? file.path
                    : '${file.path}\n${file.detail}';
                return BlenderTooltip(message: tooltip, child: row);
              },
            ),
    );
  }
}
