part of '../non3d_editors.dart';

class BlenderImageEditor extends StatefulWidget {
  const BlenderImageEditor({
    super.key,
    this.image,
    this.label = 'No Image',
    this.toolShelf,
    this.sidebar,
    this.assetShelf,
    this.toolShelfWidth = 42,
    this.sidebarWidth = 240,
    this.assetShelfHeight = 144,
    this.title,
  });

  final Widget? image;
  final String label;
  final Widget? toolShelf;
  final Widget? sidebar;
  final Widget? assetShelf;
  final double toolShelfWidth;
  final double sidebarWidth;
  final double assetShelfHeight;
  final String? title;

  @override
  State<BlenderImageEditor> createState() => _BlenderImageEditorState();
}
