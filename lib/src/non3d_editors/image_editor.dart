part of '../non3d_editors.dart';

class BlenderImageEditor extends StatefulWidget {
  const BlenderImageEditor({
    super.key,
    this.image,
    this.label = 'No Image',
    this.sidebar,
    this.sidebarWidth = 240,
    this.title = 'Image Editor',
  });

  final Widget? image;
  final String label;
  final Widget? sidebar;
  final double sidebarWidth;
  final String title;

  @override
  State<BlenderImageEditor> createState() => _BlenderImageEditorState();
}
