import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'layout.dart';
import 'services.dart';

/// Stable conversion between an editor value and its persisted view ID.
class BlenderEditorViewCodec<T> {
  const BlenderEditorViewCodec({required this.encode, required this.decode});

  final String Function(T value) encode;
  final T? Function(String id) decode;
}

/// Source-of-truth controller for one session-backed editor area.
class BlenderEditorAreaController<T> extends ChangeNotifier {
  BlenderEditorAreaController({
    required BlenderEditorSessionService session,
    required this.workspaceId,
    required this.areaId,
    required T initialValue,
    required this.codec,
    Iterable<T>? availableValues,
  }) : _session = session,
       _availableIds = availableValues == null
           ? null
           : <String>{for (final value in availableValues) codec.encode(value)},
       _value = initialValue {
    final persisted = session.viewForArea(
      workspaceId: workspaceId,
      areaId: areaId,
    );
    final restored = persisted == null ? null : codec.decode(persisted);
    if (restored != null && _isAvailable(restored)) {
      _value = restored;
    } else {
      // Area controllers are commonly created lazily by a dock LayoutBuilder.
      // Persist after that build completes so the session notifier never marks
      // its inherited scope dirty from inside layout.
      Future<void>.microtask(() {
        if (_session.viewForArea(workspaceId: workspaceId, areaId: areaId) ==
            null) {
          _persist(_value);
        }
      });
    }
  }

  final BlenderEditorSessionService _session;
  final String workspaceId;
  final String areaId;
  final BlenderEditorViewCodec<T> codec;
  Set<String>? _availableIds;
  T _value;

  T get value => _value;

  bool _isAvailable(T value) =>
      _availableIds?.contains(codec.encode(value)) ?? true;

  bool select(T next) {
    if (!_isAvailable(next)) return false;
    if (_value == next) return false;
    _value = next;
    _persist(next);
    notifyListeners();
    return true;
  }

  /// Replaces the registered view set and falls back when the active view was
  /// removed by an application update or plugin change.
  void setAvailableValues(Iterable<T> values, {required T fallback}) {
    _availableIds = <String>{for (final value in values) codec.encode(value)};
    if (_isAvailable(_value)) return;
    _value = fallback;
    _persist(fallback);
    notifyListeners();
  }

  void _persist(T value) {
    _session.selectView(
      workspaceId: workspaceId,
      areaId: areaId,
      viewId: codec.encode(value),
    );
  }
}

/// One application-owned editor implementation registered with an area host.
class BlenderEditorAreaView<T> {
  const BlenderEditorAreaView({required this.value, required this.builder});

  final T value;
  final WidgetBuilder builder;
}

typedef BlenderEditorAreaFrameBuilder<T> =
    Widget Function(
      BuildContext context,
      T value,
      ValueChanged<T> select,
      Widget editor,
    );

/// Renders the active implementation for a session-backed editor area.
class BlenderEditorAreaHost<T> extends StatefulWidget {
  const BlenderEditorAreaHost({
    super.key,
    required this.controller,
    required this.views,
    this.frameBuilder,
  });

  final BlenderEditorAreaController<T> controller;
  final List<BlenderEditorAreaView<T>> views;
  final BlenderEditorAreaFrameBuilder<T>? frameBuilder;

  @override
  State<BlenderEditorAreaHost<T>> createState() =>
      _BlenderEditorAreaHostState<T>();
}

class _BlenderEditorAreaHostState<T> extends State<BlenderEditorAreaHost<T>> {
  @override
  void initState() {
    super.initState();
    _syncViews();
  }

  @override
  void didUpdateWidget(BlenderEditorAreaHost<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.views, widget.views) ||
        oldWidget.controller != widget.controller) {
      _syncViews();
    }
  }

  void _syncViews() {
    if (widget.views.isEmpty) return;
    widget.controller.setAvailableValues(
      widget.views.map((view) => view.value),
      fallback: widget.views.first.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final active = widget.views.where(
          (view) => view.value == widget.controller.value,
        );
        final view = active.isEmpty
            ? (widget.views.isEmpty ? null : widget.views.first)
            : active.first;
        if (view == null) return const SizedBox.shrink();
        final editor = view.builder(context);
        return widget.frameBuilder?.call(
              context,
              view.value,
              widget.controller.select,
              editor,
            ) ??
            editor;
      },
    );
  }
}

/// Stable codec for the built-in editor type catalog.
final BlenderEditorViewCodec<BlenderEditorType> blenderEditorTypeViewCodec =
    BlenderEditorViewCodec<BlenderEditorType>(
      encode: (value) => value.name,
      decode: (id) {
        for (final value in BlenderEditorType.values) {
          if (value.name == id) return value;
        }
        return null;
      },
    );
