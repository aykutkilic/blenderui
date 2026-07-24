import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

import '../model/workbook_output.dart';
import 'workbook_kernel.dart';

final class JupyterKernel implements WorkbookKernel {
  JupyterKernel({
    required this.serverUri,
    this.token,
    this.kernelName = 'python3',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  final Uri serverUri;
  final String? token;
  final String kernelName;
  final http.Client _httpClient;
  final StreamController<WorkbookKernelState> _stateController =
      StreamController<WorkbookKernelState>.broadcast(sync: true);
  final Map<String, _PendingExecution> _pending = <String, _PendingExecution>{};

  IOWebSocketChannel? _channel;
  StreamSubscription<Object?>? _channelSubscription;
  String? _kernelId;
  var _messageSequence = 0;
  WorkbookKernelState _state = WorkbookKernelState.disconnected;

  String? get kernelId => _kernelId;

  @override
  WorkbookKernelState get state => _state;

  @override
  Stream<WorkbookKernelState> get states => _stateController.stream;

  @override
  Future<void> connect() async {
    if (_state == WorkbookKernelState.idle ||
        _state == WorkbookKernelState.busy) {
      return;
    }
    if (_state == WorkbookKernelState.disposed) {
      throw StateError('The Jupyter kernel has been disposed.');
    }
    _setState(WorkbookKernelState.connecting);
    try {
      final response = await _httpClient.post(
        _apiUri('/api/kernels'),
        headers: _headers(json: true),
        body: jsonEncode(<String, Object?>{'name': kernelName}),
      );
      _requireSuccess(response, 'start kernel');
      final body = _jsonMap(response.body);
      final id = body['id'];
      if (id is! String || id.isEmpty) {
        throw const FormatException('Jupyter did not return a kernel id.');
      }
      _kernelId = id;
      await _openChannels();
      _setState(WorkbookKernelState.idle);
    } catch (_) {
      _setState(WorkbookKernelState.failed);
      rethrow;
    }
  }

  @override
  Future<WorkbookExecutionResult> execute(
    String code, {
    void Function(WorkbookOutput output)? onOutput,
  }) async {
    if (_state == WorkbookKernelState.disconnected) await connect();
    final channel = _channel;
    if (channel == null || _kernelId == null) {
      throw StateError('The Jupyter channels are not connected.');
    }

    final messageId = _nextMessageId('execute');
    final pending = _PendingExecution(messageId, onOutput);
    _pending[messageId] = pending;
    channel.sink.add(
      jsonEncode(<String, Object?>{
        'header': _header(messageId, 'execute_request'),
        'parent_header': const <String, Object?>{},
        'metadata': const <String, Object?>{},
        'content': <String, Object?>{
          'code': code,
          'silent': false,
          'store_history': true,
          'user_expressions': const <String, Object?>{},
          'allow_stdin': false,
          'stop_on_error': true,
        },
        'channel': 'shell',
        'buffers': const <Object?>[],
      }),
    );
    return pending.completer.future.whenComplete(() {
      _pending.remove(messageId);
    });
  }

  @override
  Future<void> interrupt() async {
    final id = _requireKernelId();
    final response = await _httpClient.post(
      _apiUri('/api/kernels/$id/interrupt'),
      headers: _headers(),
    );
    _requireSuccess(response, 'interrupt kernel');
  }

  @override
  Future<void> restart() async {
    final id = _requireKernelId();
    _setState(WorkbookKernelState.restarting);
    try {
      final response = await _httpClient.post(
        _apiUri('/api/kernels/$id/restart'),
        headers: _headers(),
      );
      _requireSuccess(response, 'restart kernel');
      await _closeChannels();
      _failPending(StateError('The Jupyter kernel was restarted.'));
      await _openChannels();
      _setState(WorkbookKernelState.idle);
    } catch (_) {
      _setState(WorkbookKernelState.failed);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    if (_state == WorkbookKernelState.disposed) return;
    await _closeChannels();
    _failPending(StateError('The Jupyter kernel was disposed.'));
    final id = _kernelId;
    _kernelId = null;
    if (id != null) {
      try {
        await _httpClient.delete(
          _apiUri('/api/kernels/$id'),
          headers: _headers(),
        );
      } on Object {
        // Disposal remains best-effort when the server has already exited.
      }
    }
    _httpClient.close();
    _setState(WorkbookKernelState.disposed);
    await _stateController.close();
  }

  Future<void> _openChannels() async {
    final id = _requireKernelId();
    final uri = _webSocketUri('/api/kernels/$id/channels').replace(
      queryParameters: <String, String>{
        ..._webSocketUri('/api/kernels/$id/channels').queryParameters,
        'session_id': _nextMessageId('session'),
        if (token case final value? when value.isNotEmpty) 'token': value,
      },
    );
    final channel = IOWebSocketChannel.connect(
      uri,
      headers: _headers(),
      pingInterval: const Duration(seconds: 20),
    );
    await channel.ready;
    _channel = channel;
    _channelSubscription = channel.stream.listen(
      _handleChannelData,
      onError: _handleChannelError,
      onDone: _handleChannelDone,
      cancelOnError: false,
    );
  }

  Future<void> _closeChannels() async {
    await _channelSubscription?.cancel();
    _channelSubscription = null;
    await _channel?.sink.close();
    _channel = null;
  }

  void _handleChannelData(Object? raw) {
    try {
      final text = switch (raw) {
        String value => value,
        List<int> value => utf8.decode(value),
        _ => throw FormatException(
          'Unsupported Jupyter frame: ${raw.runtimeType}',
        ),
      };
      final message = _jsonMap(text);
      final header = _asMap(message['header']);
      final parent = _asMap(message['parent_header']);
      final content = _asMap(message['content']);
      final type = header['msg_type'];
      final parentId = parent['msg_id'];

      if (type == 'status') {
        final executionState = content['execution_state'];
        if (executionState == 'busy') _setState(WorkbookKernelState.busy);
        if (executionState == 'idle') {
          _setState(WorkbookKernelState.idle);
          if (parentId is String) _complete(parentId);
        }
      }
      if (parentId is! String) return;
      final pending = _pending[parentId];
      if (pending == null) return;

      switch (type) {
        case 'execute_input':
          pending.executionCount = _asInt(content['execution_count']);
        case 'execute_reply':
          pending.executionCount ??= _asInt(content['execution_count']);
          pending.succeeded = content['status'] == 'ok';
        case 'stream':
          pending.add(
            WorkbookStreamOutput(
              stream: content['name'] == 'stderr'
                  ? WorkbookStream.stderr
                  : WorkbookStream.stdout,
              text: _joinedText(content['text']),
            ),
          );
        case 'display_data' || 'execute_result' || 'update_display_data':
          pending.add(
            WorkbookDisplayOutput(
              data: _asMap(content['data']),
              metadata: _asMap(content['metadata']),
              executionCount: _asInt(content['execution_count']),
            ),
          );
        case 'error':
          pending.succeeded = false;
          pending.add(
            WorkbookErrorOutput(
              name: content['ename']?.toString() ?? 'Error',
              message: content['evalue']?.toString() ?? '',
              traceback: _stringList(content['traceback']),
            ),
          );
        case 'clear_output':
          final clear = WorkbookClearOutput(wait: content['wait'] == true);
          if (!clear.wait) pending.outputs.clear();
          pending.add(clear, retain: false);
      }
    } on Object catch (error, stackTrace) {
      _handleChannelError(error, stackTrace);
    }
  }

  void _complete(String messageId) {
    final pending = _pending[messageId];
    if (pending == null || pending.completer.isCompleted) return;
    pending.completer.complete(
      WorkbookExecutionResult(
        messageId: messageId,
        outputs: List<WorkbookOutput>.unmodifiable(pending.outputs),
        succeeded: pending.succeeded,
        executionCount: pending.executionCount,
      ),
    );
  }

  void _handleChannelError(Object error, [StackTrace? stackTrace]) {
    _setState(WorkbookKernelState.failed);
    _failPending(error, stackTrace);
  }

  void _handleChannelDone() {
    if (_state != WorkbookKernelState.restarting &&
        _state != WorkbookKernelState.disposed) {
      _handleChannelError(
        StateError('The Jupyter channels connection closed.'),
      );
    }
  }

  void _failPending(Object error, [StackTrace? stackTrace]) {
    for (final pending in _pending.values) {
      if (!pending.completer.isCompleted) {
        pending.completer.completeError(
          error,
          stackTrace ?? StackTrace.current,
        );
      }
    }
    _pending.clear();
  }

  Uri _apiUri(String path) => serverUri.replace(
    path: '${serverUri.path.replaceFirst(RegExp(r'/$'), '')}$path',
    queryParameters: token == null || token!.isEmpty
        ? serverUri.queryParameters
        : <String, String>{...serverUri.queryParameters, 'token': token!},
  );

  Uri _webSocketUri(String path) =>
      _apiUri(path).replace(scheme: serverUri.scheme == 'https' ? 'wss' : 'ws');

  Map<String, String> _headers({bool json = false}) => <String, String>{
    if (json) 'content-type': 'application/json',
    if (token case final value? when value.isNotEmpty)
      'authorization': 'token $value',
  };

  Map<String, Object?> _header(String messageId, String type) =>
      <String, Object?>{
        'msg_id': messageId,
        'username': 'blenderui-workbook',
        'session': 'blenderui-workbook',
        'date': DateTime.now().toUtc().toIso8601String(),
        'msg_type': type,
        'version': '5.3',
      };

  String _nextMessageId(String kind) {
    _messageSequence += 1;
    return 'blenderui-$kind-${DateTime.now().microsecondsSinceEpoch}-$_messageSequence';
  }

  String _requireKernelId() {
    final id = _kernelId;
    if (id == null) throw StateError('No Jupyter kernel has been started.');
    return id;
  }

  void _setState(WorkbookKernelState value) {
    if (_state == value) return;
    _state = value;
    if (!_stateController.isClosed) _stateController.add(value);
  }

  static void _requireSuccess(http.Response response, String operation) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw JupyterRequestException(
      operation: operation,
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  static Map<String, Object?> _jsonMap(String value) =>
      _asMap(jsonDecode(value));

  static Map<String, Object?> _asMap(Object? value) {
    if (value is! Map) return const <String, Object?>{};
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static int? _asInt(Object? value) => switch (value) {
    int item => item,
    num item => item.toInt(),
    _ => null,
  };

  static String _joinedText(Object? value) => switch (value) {
    String item => item,
    List<Object?> item => item.join(),
    _ => value?.toString() ?? '',
  };

  static List<String> _stringList(Object? value) => switch (value) {
    List<Object?> items => <String>[for (final item in items) item.toString()],
    _ => const <String>[],
  };
}

final class JupyterRequestException implements Exception {
  const JupyterRequestException({
    required this.operation,
    required this.statusCode,
    required this.body,
  });

  final String operation;
  final int statusCode;
  final String body;

  @override
  String toString() =>
      'JupyterRequestException: could not $operation (HTTP $statusCode): $body';
}

final class _PendingExecution {
  _PendingExecution(this.messageId, this.onOutput);

  final String messageId;
  final void Function(WorkbookOutput output)? onOutput;
  final Completer<WorkbookExecutionResult> completer =
      Completer<WorkbookExecutionResult>();
  final List<WorkbookOutput> outputs = <WorkbookOutput>[];
  int? executionCount;
  bool succeeded = true;

  void add(WorkbookOutput output, {bool retain = true}) {
    if (retain) outputs.add(output);
    onOutput?.call(output);
  }
}
