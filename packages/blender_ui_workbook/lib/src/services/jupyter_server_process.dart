import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

final class JupyterServerConfiguration {
  const JupyterServerConfiguration({
    required this.workspacePath,
    this.pythonExecutable = 'python3',
    this.port,
    this.extraArguments = const <String>[],
    this.environment = const <String, String>{},
    this.startupTimeout = const Duration(seconds: 30),
  });

  final String workspacePath;
  final String pythonExecutable;
  final int? port;
  final List<String> extraArguments;
  final Map<String, String> environment;
  final Duration startupTimeout;
}

final class JupyterServerProcess {
  JupyterServerProcess._({
    required this.process,
    required this.baseUri,
    required this.token,
    required StreamController<String> logs,
  }) : _logs = logs;

  final Process process;
  final Uri baseUri;
  final String token;
  final StreamController<String> _logs;

  Stream<String> get logs => _logs.stream;

  static Future<JupyterServerProcess> start(
    JupyterServerConfiguration configuration,
  ) async {
    final workspace = Directory(configuration.workspacePath);
    if (!workspace.existsSync()) {
      await workspace.create(recursive: true);
    }
    final port = configuration.port ?? await _availablePort();
    final token = _secureToken();
    final logs = StreamController<String>.broadcast(sync: true);
    final process = await Process.start(
      configuration.pythonExecutable,
      <String>[
        '-m',
        'jupyter_server',
        '--no-browser',
        '--ServerApp.open_browser=False',
        '--ServerApp.port=$port',
        '--ServerApp.port_retries=0',
        '--ServerApp.root_dir=${workspace.absolute.path}',
        '--IdentityProvider.token=$token',
        ...configuration.extraArguments,
      ],
      environment: <String, String>{
        ...Platform.environment,
        ...configuration.environment,
      },
      workingDirectory: workspace.absolute.path,
    );
    final recentLogs = <String>[];
    void record(String line) {
      if (kDebugMode) debugPrint('[jupyter-server] $line');
      recentLogs.add(line);
      if (recentLogs.length > 80) recentLogs.removeAt(0);
      if (!logs.isClosed) logs.add(line);
    }

    final stdoutSubscription = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(record);
    final stderrSubscription = process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(record);
    final baseUri = Uri(scheme: 'http', host: '127.0.0.1', port: port);

    try {
      await _waitUntilReady(
        process: process,
        uri: baseUri.replace(
          path: '/api',
          queryParameters: <String, String>{'token': token},
        ),
        token: token,
        timeout: configuration.startupTimeout,
        recentLogs: recentLogs,
      );
    } on Object {
      process.kill(ProcessSignal.sigterm);
      await stdoutSubscription.cancel();
      await stderrSubscription.cancel();
      await logs.close();
      rethrow;
    }

    unawaited(
      process.exitCode.whenComplete(() async {
        await stdoutSubscription.cancel();
        await stderrSubscription.cancel();
        if (!logs.isClosed) await logs.close();
      }),
    );
    return JupyterServerProcess._(
      process: process,
      baseUri: baseUri,
      token: token,
      logs: logs,
    );
  }

  Future<void> stop({Duration timeout = const Duration(seconds: 5)}) async {
    if (!process.kill(ProcessSignal.sigterm)) return;
    try {
      await process.exitCode.timeout(timeout);
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      await process.exitCode;
    }
  }

  static Future<void> _waitUntilReady({
    required Process process,
    required Uri uri,
    required String token,
    required Duration timeout,
    required List<String> recentLogs,
  }) async {
    final client = http.Client();
    final deadline = DateTime.now().add(timeout);
    try {
      while (DateTime.now().isBefore(deadline)) {
        try {
          final response = await client
              .get(
                uri,
                headers: <String, String>{'authorization': 'token $token'},
              )
              .timeout(const Duration(seconds: 1));
          if (response.statusCode >= 200 && response.statusCode < 300) return;
        } on Object {
          // The server socket is expected to reject connections while booting.
        }
        final exited = await Future.any<Object?>(<Future<Object?>>[
          process.exitCode,
          Future<Object?>.delayed(const Duration(milliseconds: 150)),
        ]);
        if (exited is int) {
          throw JupyterServerStartException(
            'Jupyter exited with code $exited.\n${recentLogs.join('\n')}',
          );
        }
      }
      throw JupyterServerStartException(
        'Jupyter did not become ready within $timeout.\n${recentLogs.join('\n')}',
      );
    } finally {
      client.close();
    }
  }

  static Future<int> _availablePort() async {
    final socket = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = socket.port;
    await socket.close();
    return port;
  }

  static String _secureToken() {
    final random = Random.secure();
    return List<String>.generate(
      32,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}

final class JupyterServerStartException implements Exception {
  const JupyterServerStartException(this.message);

  final String message;

  @override
  String toString() => 'JupyterServerStartException: $message';
}
