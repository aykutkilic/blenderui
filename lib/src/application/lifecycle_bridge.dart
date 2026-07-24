part of '../application.dart';

/// Bridges host-window lifecycle requests into reusable application actions.
///
/// Desktop example hosts share the same native channel. Keeping that protocol
/// here prevents every host from duplicating the channel name, dispatch, and
/// teardown rules.
final class BlenderApplicationLifecycleBridge {
  static const _channel = MethodChannel('blender_ui/application_lifecycle');
  static final Map<String, BlenderApplicationLifecycleBridge> _bridges =
      <String, BlenderApplicationLifecycleBridge>{};
  static var _nextId = 0;
  static String? _activeId;

  BlenderApplicationLifecycleBridge({String? applicationId})
    : applicationId = applicationId ?? 'application-${++_nextId}';

  /// The host may target a particular window with this id. Untargeted calls
  /// retain the historical single-window behaviour by reaching the most
  /// recently attached bridge.
  final String applicationId;

  FutureOr<void> Function()? _onPreferencesRequested;
  FutureOr<void> Function(MethodCall call)? _onUnhandledMethodCall;

  void attach({
    required FutureOr<void> Function() onPreferencesRequested,
    FutureOr<void> Function(MethodCall call)? onUnhandledMethodCall,
  }) {
    _onPreferencesRequested = onPreferencesRequested;
    _onUnhandledMethodCall = onUnhandledMethodCall;
    _bridges[applicationId] = this;
    _activeId = applicationId;
    _channel.setMethodCallHandler(_dispatchMethodCall);
  }

  static Future<void> _dispatchMethodCall(MethodCall call) async {
    final arguments = call.arguments;
    final id = arguments is Map ? arguments['applicationId'] as String? : null;
    final bridge = _bridges[id ?? _activeId];
    if (bridge == null) return;
    await bridge._handleMethodCall(call);
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method == 'preferencesRequested') {
      await _onPreferencesRequested?.call();
      return;
    }
    await _onUnhandledMethodCall?.call(call);
  }

  Future<T?> invoke<T>(String method, [Object? arguments]) =>
      _channel.invokeMethod<T>(method, arguments);

  void dispose() {
    _onPreferencesRequested = null;
    _onUnhandledMethodCall = null;
    _bridges.remove(applicationId);
    if (_activeId == applicationId) {
      _activeId = _bridges.isEmpty ? null : _bridges.keys.last;
    }
    if (_bridges.isEmpty) _channel.setMethodCallHandler(null);
  }
}
