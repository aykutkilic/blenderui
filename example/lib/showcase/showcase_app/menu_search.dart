part of '../showcase_app.dart';

extension _ShowcaseMenuSearch on _ShowcaseAppState {
  void _registerMenuSearchCommands() {
    void command({
      required String id,
      required String label,
      required List<String> path,
      required BlenderGlyph glyph,
      required VoidCallback execute,
      List<String> searchTerms = const <String>[],
      String? shortcut,
      bool searchable = true,
    }) {
      if (_application.commands[id] != null) return;
      _application.commands.register(
        BlenderCommand(
          id: id,
          label: label,
          menuPath: path,
          glyph: glyph,
          shortcut: shortcut,
          searchTerms: searchTerms,
          execute: execute,
          searchable: searchable,
        ),
      );
    }

    void addCommand(
      String id,
      String label,
      BlenderGlyph glyph, {
      List<String> parent = const <String>[],
      List<String> searchTerms = const <String>[],
    }) {
      command(
        id: 'view3d.add.$id',
        label: label,
        path: <String>['3D Viewport', 'Add', ...parent],
        glyph: glyph,
        searchTerms: searchTerms,
        execute: () => _setStatus('Add $label'),
      );
    }

    addCommand('armature', 'Armature', BlenderGlyph.armature);
    addCommand('camera', 'Camera', BlenderGlyph.camera);
    addCommand(
      'collection_instance',
      'Collection',
      BlenderGlyph.collection,
      parent: const <String>['Collection Instance'],
      searchTerms: const <String>['instance'],
    );
    addCommand(
      'bezier',
      'Bézier',
      BlenderGlyph.curve,
      parent: const <String>['Curve'],
    );
    addCommand(
      'circle',
      'Circle',
      BlenderGlyph.curve,
      parent: const <String>['Curve'],
    );
    addCommand(
      'empty_hair',
      'Empty Hair',
      BlenderGlyph.curves,
      parent: const <String>['Curve'],
    );
    addCommand(
      'fur',
      'Fur',
      BlenderGlyph.curves,
      parent: const <String>['Curve'],
    );
    addCommand(
      'nurbs_circle',
      'Nurbs Circle',
      BlenderGlyph.curve,
      parent: const <String>['Curve'],
    );
    addCommand(
      'nurbs_curve',
      'Nurbs Curve',
      BlenderGlyph.curve,
      parent: const <String>['Curve'],
    );
    addCommand(
      'path',
      'Path',
      BlenderGlyph.curve,
      parent: const <String>['Curve'],
    );

    command(
      id: 'application.preferences',
      label: 'Preferences...',
      path: const <String>['Edit'],
      glyph: BlenderGlyph.preferences,
      execute: _showPreferencesWindow,
    );
    command(
      id: 'application.file_browser',
      label: 'File Browser',
      path: const <String>['Window', 'Editor Type'],
      glyph: BlenderGlyph.folder,
      execute: () => _mainEditorArea.select(BlenderEditorType.fileBrowser),
    );
    command(
      id: 'application.asset_browser',
      label: 'Asset Browser',
      path: const <String>['Window', 'Editor Type'],
      glyph: BlenderGlyph.assetManager,
      execute: () => _mainEditorArea.select(BlenderEditorType.assetBrowser),
    );
    command(
      id: 'application.menu_search',
      label: 'Menu Search...',
      path: const <String>['Edit'],
      glyph: BlenderGlyph.search,
      shortcut: 'F3',
      searchable: false,
      execute: _showMenuSearch,
    );
    final activator = const SingleActivator(LogicalKeyboardKey.f3);
    if (_application.commandBindings.commandFor(activator) == null) {
      _application.commandBindings.register(
        const BlenderCommandBinding(
          commandId: 'application.menu_search',
          activator: SingleActivator(LogicalKeyboardKey.f3),
        ),
      );
    }
  }

  void _showMenuSearch() {
    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext == null) return;
    unawaited(
      showBlenderMenuSearch(
        context: navigatorContext,
        commands: _application.commands,
      ),
    );
  }
}
