part of 'workbook_app.dart';

extension _WorkbookApplicationCommands on _WorkbookExampleAppState {
  Future<void> _restoreApplicationServices() async {
    await Future.wait<bool>(<Future<bool>>[
      _interfacePreferences.restore(),
      _themeService.restore(),
      _editorSession.restore(),
    ]);
    try {
      final encoded = await _applicationStorage.read('workbook.keymap');
      if (encoded != null) _bindings.importConfiguration(encoded);
    } on Object catch (error) {
      _application.reports.report(
        'Keymap restore failed: $error',
        level: BlenderStatusLevel.warning,
      );
    }
    if (!mounted) return;
    _bindings.addListener(_scheduleKeymapPersistence);
    _application.status.report(_runtime.status);
  }

  void _scheduleKeymapPersistence() {
    _keymapPersistenceTimer?.cancel();
    _keymapPersistenceTimer = Timer(const Duration(milliseconds: 250), () {
      unawaited(
        _applicationStorage.write(
          'workbook.keymap',
          _bindings.exportConfiguration(),
        ),
      );
    });
  }

  void _registerCommandsAndKeymap() {
    void command(
      String id,
      String label,
      BlenderCommandCallback execute, {
      List<String> menuPath = const <String>[],
      bool Function()? enabled,
    }) {
      _commands.register(
        BlenderCommand(
          id: id,
          label: label,
          execute: execute,
          menuPath: menuPath,
          enabled: enabled,
        ),
      );
    }

    command(
      'workbook.file.open',
      'Open…',
      _openDocument,
      menuPath: const <String>['File'],
    );
    command(
      'workbook.preferences',
      'Preferences…',
      _showPreferences,
      menuPath: const <String>['Edit'],
    );
    command(
      'workbook.runtime.install',
      'Install Managed Jupyter and Connect',
      _runtime.installAndConnect,
      menuPath: const <String>['Kernel'],
      enabled: () => !_runtime.busy,
    );
    command(
      'workbook.runtime.connect',
      'Connect Runtime',
      _runtime.connect,
      menuPath: const <String>['Kernel'],
      enabled: () => !_runtime.busy && !_session.hasKernel,
    );
    command(
      'workbook.runtime.disconnect',
      'Disconnect Runtime',
      _runtime.disconnect,
      menuPath: const <String>['Kernel'],
      enabled: () => !_runtime.busy && _session.hasKernel,
    );
    command(
      'workbook.runAll',
      'Run All Cells',
      _session.runAll,
      menuPath: const <String>['Kernel'],
      enabled: () => _session.hasKernel,
    );
    command(
      'workbook.interrupt',
      'Interrupt Kernel',
      _session.interrupt,
      menuPath: const <String>['Kernel'],
      enabled: () => _session.hasKernel,
    );
    command(
      'workbook.restart',
      'Restart Kernel',
      _session.restart,
      menuPath: const <String>['Kernel'],
      enabled: () => _session.hasKernel,
    );
    command(
      'workbook.workspace.reset',
      'Reset Current Workspace',
      () => _workspaces.resetWorkspace(_workspaces.activeWorkspaceId),
      menuPath: const <String>['Window'],
    );
    command(
      'workbook.about',
      'About BlenderUI Workbook',
      _showAbout,
      menuPath: const <String>['Help'],
    );

    void bind(
      String commandId,
      SingleActivator activator, {
      String? bindingId,
    }) {
      if (_bindings.commandFor(activator) != null) return;
      _bindings.register(
        BlenderCommandBinding(
          commandId: commandId,
          activator: activator,
          bindingId: bindingId,
          keymap: 'Workbook Window',
        ),
      );
    }

    bind(
      'workbook.file.open',
      const SingleActivator(LogicalKeyboardKey.keyO, meta: true),
    );
    bind(
      'workbook.preferences',
      const SingleActivator(LogicalKeyboardKey.comma, meta: true),
    );
    bind(
      'workbook.runAll',
      const SingleActivator(LogicalKeyboardKey.enter, meta: true, shift: true),
    );
    bind(
      'workbook.interrupt',
      const SingleActivator(LogicalKeyboardKey.escape),
    );
    bind(
      'application.undo',
      const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
      bindingId: 'Workbook Window::global::application.undo.meta',
    );
    bind(
      'application.redo',
      const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true),
      bindingId: 'Workbook Window::global::application.redo.meta',
    );
  }

  void _showPreferences() {
    final context = _navigatorKey.currentContext;
    if (context != null) unawaited(_application.preferences?.show(context));
  }

  void _showAbout() {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      unawaited(_application.presentation.showAbout(context));
    }
  }

  void _synchronizeEditorSession() {
    if (_editorSyncScheduled) return;
    _editorSyncScheduled = true;
    scheduleMicrotask(() {
      _editorSyncScheduled = false;
      if (!mounted) return;
      final workspace = _workspaces.activeWorkspaceId;
      final selected = _session.selectedCellId;
      _editorSession.selectOutlinerItem(workspace, selected);
      _editorSession.inspectPropertiesTarget(workspace, selected);
    });
  }

  void _handleSessionChanged() {
    _synchronizeEditorSession();
    _scheduleShadowFilePreparation();
  }

  void _scheduleShadowFilePreparation() {
    if (_runtime.workspace == null) return;
    _shadowFilePreparationTimer?.cancel();
    _shadowFilePreparationTimer = Timer(const Duration(milliseconds: 250), () {
      unawaited(_prepareShadowFiles());
    });
  }

  Future<void> _prepareShadowFiles() async {
    try {
      await _runtime.prepareWorkspace();
      _refreshAfterShadowFilePreparation();
    } on Object catch (error, stackTrace) {
      _application.reports.report(
        'Workbook shadow-file synchronization failed: $error',
        level: BlenderStatusLevel.warning,
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
