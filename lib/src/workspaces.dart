import 'package:flutter/widgets.dart';

import 'docking.dart';
import 'docking_model.dart';
import 'services.dart';

/// Immutable definition of one named Blender-style workspace.
///
/// A workspace is a composition of editor areas, not an editor itself. Its
/// [layout] describes the default docking tree while a
/// [BlenderWorkspaceService] retains the user's live layout independently.
class BlenderWorkspaceDefinition<T> {
  const BlenderWorkspaceDefinition({required this.id, required this.layout});

  /// Stable application-owned identifier, such as `folders` or `authoring`.
  final String id;

  /// The immutable layout used for a new workspace and for reset.
  final BlenderDockNode<T> layout;
}

/// Owns the dock layouts for an application's named workspaces.
///
/// Applications keep their workspace switcher and editor builders, while this
/// service owns the reusable lifecycle: each workspace gets a controller,
/// changing workspace retains its layout, and a reset restores only that
/// workspace's declared default. Register the service in an application's
/// service container when editor code needs to select a workspace.
class BlenderWorkspaceService<T> extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderWorkspaceService({
    required Iterable<BlenderWorkspaceDefinition<T>> workspaces,
    String? initialWorkspaceId,
  }) {
    for (final definition in workspaces) {
      if (definition.id.isEmpty) {
        throw ArgumentError.value(
          definition.id,
          'workspaces.id',
          'Workspace ids must not be empty.',
        );
      }
      if (_definitions.containsKey(definition.id)) {
        throw ArgumentError.value(
          definition.id,
          'workspaces.id',
          'Workspace ids must be unique.',
        );
      }
      _definitions[definition.id] = definition;
      _controllers[definition.id] = BlenderDockingController<T>(
        root: definition.layout,
      );
    }
    if (_definitions.isEmpty) {
      throw ArgumentError.value(
        workspaces,
        'workspaces',
        'At least one workspace is required.',
      );
    }
    final initial = initialWorkspaceId ?? _definitions.keys.first;
    if (!_definitions.containsKey(initial)) {
      throw ArgumentError.value(
        initial,
        'initialWorkspaceId',
        'The initial workspace must be declared.',
      );
    }
    _activeWorkspaceId = initial;
  }

  final Map<String, BlenderWorkspaceDefinition<T>> _definitions =
      <String, BlenderWorkspaceDefinition<T>>{};
  final Map<String, BlenderDockingController<T>> _controllers =
      <String, BlenderDockingController<T>>{};
  late String _activeWorkspaceId;
  bool _disposed = false;

  /// The declared workspace definitions in their application-defined order.
  List<BlenderWorkspaceDefinition<T>> get workspaces =>
      List<BlenderWorkspaceDefinition<T>>.unmodifiable(_definitions.values);

  String get activeWorkspaceId => _activeWorkspaceId;

  BlenderWorkspaceDefinition<T> get activeWorkspace =>
      _definitions[_activeWorkspaceId]!;

  BlenderDockingController<T> get activeController =>
      _controllers[_activeWorkspaceId]!;

  BlenderDockingController<T> controllerFor(String workspaceId) {
    final controller = _controllers[workspaceId];
    if (controller == null) {
      throw ArgumentError.value(
        workspaceId,
        'workspaceId',
        'No workspace with this id is registered.',
      );
    }
    return controller;
  }

  /// Selects a workspace, retaining the other workspaces' live layouts.
  bool selectWorkspace(String workspaceId) {
    if (!_controllers.containsKey(workspaceId)) {
      throw ArgumentError.value(
        workspaceId,
        'workspaceId',
        'No workspace with this id is registered.',
      );
    }
    if (_activeWorkspaceId == workspaceId) return false;
    _activeWorkspaceId = workspaceId;
    notifyListeners();
    return true;
  }

  /// Restores a workspace to its declared default layout.
  void resetWorkspace(String workspaceId) {
    final definition = _definitions[workspaceId];
    if (definition == null) {
      throw ArgumentError.value(
        workspaceId,
        'workspaceId',
        'No workspace with this id is registered.',
      );
    }
    controllerFor(workspaceId).replaceRoot(definition.layout);
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// Renders the active layout from a [BlenderWorkspaceService].
///
/// The host is the reusable bridge between an application workspace switcher
/// and the lower-level [BlenderDockingWorkspace]. The application still owns
/// its editor-area composition; the service supplies the persistent layout.
class BlenderWorkspaceHost<T> extends StatelessWidget {
  const BlenderWorkspaceHost({
    super.key,
    required this.service,
    required this.areaBuilder,
    this.cloneArea,
    this.minimumAreaExtent = 52,
    this.cornerExtent = 14,
  });

  final BlenderWorkspaceService<T> service;
  final BlenderDockAreaBuilder<T> areaBuilder;
  final T Function(T value)? cloneArea;
  final double minimumAreaExtent;
  final double cornerExtent;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: service,
      builder: (context, _) => BlenderDockingWorkspace<T>(
        controller: service.activeController,
        areaBuilder: areaBuilder,
        cloneValue: cloneArea,
        minimumAreaExtent: minimumAreaExtent,
        cornerExtent: cornerExtent,
      ),
    );
  }
}
