import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

enum JupyterRuntimeInstallState {
  idle,
  checking,
  unavailable,
  installing,
  ready,
  failed,
}

final class JupyterRuntimeInspection {
  const JupyterRuntimeInspection({
    required this.pythonExecutable,
    required this.available,
    required this.detail,
  });

  final String pythonExecutable;
  final bool available;
  final String detail;
}

/// Installs and inspects an isolated Python/Jupyter runtime owned by the host.
///
/// The caller chooses an application-support directory; repository-relative
/// virtual environments are deliberately not assumed. Installation is an
/// explicit user action because it downloads packages and may take time.
final class JupyterRuntimeInstaller extends ChangeNotifier {
  static const _pipLauncher =
      'import mimetypes, runpy, sys; '
      'mimetypes.knownfiles.clear(); '
      'sys.argv[0] = "pip"; '
      'runpy.run_module("pip", run_name="__main__")';

  static const _siteCustomize = '''
# Managed by BlenderUI Workbook for sandbox-compatible Python startup.
import mimetypes
mimetypes.knownfiles.clear()
''';

  static const defaultPackages = <String>[
    'ipython>=8.0',
    'jupyter-server>=2.0',
    'ipykernel>=6.0',
    'websockets>=14.0',
    'basedpyright>=1.29.0',
  ];

  JupyterRuntimeInstallState _state = JupyterRuntimeInstallState.idle;
  String _detail = 'Runtime has not been checked.';
  List<String> _logs = const <String>[];
  Process? _activeProcess;
  var _disposed = false;
  var _cancelRequested = false;

  JupyterRuntimeInstallState get state => _state;
  String get detail => _detail;
  List<String> get logs => _logs;
  bool get busy =>
      _state == JupyterRuntimeInstallState.checking ||
      _state == JupyterRuntimeInstallState.installing;

  Future<JupyterRuntimeInspection> inspect(String pythonExecutable) async {
    _setState(JupyterRuntimeInstallState.checking, 'Checking Jupyter runtime…');
    try {
      final result = await Process.run(pythonExecutable, const <String>[
        '-c',
        'from importlib.metadata import version; '
            'print(version("jupyter-server"), version("ipykernel"))',
      ]);
      final available = result.exitCode == 0;
      final detail = available
          ? 'Jupyter Server ${'${result.stdout}'.trim()} is available.'
          : _processFailure(result);
      _setState(
        available
            ? JupyterRuntimeInstallState.ready
            : JupyterRuntimeInstallState.unavailable,
        detail,
      );
      return JupyterRuntimeInspection(
        pythonExecutable: pythonExecutable,
        available: available,
        detail: detail,
      );
    } on ProcessException catch (error) {
      final detail = 'Python could not start: ${error.message}';
      _setState(JupyterRuntimeInstallState.unavailable, detail);
      return JupyterRuntimeInspection(
        pythonExecutable: pythonExecutable,
        available: false,
        detail: detail,
      );
    }
  }

  Future<String> install({
    required String basePythonExecutable,
    required String runtimeDirectory,
    List<String> packages = defaultPackages,
  }) async {
    if (busy) throw StateError('A runtime operation is already in progress.');
    _cancelRequested = false;
    _logs = const <String>[];
    _setState(
      JupyterRuntimeInstallState.installing,
      'Creating managed Python environment…',
    );
    final directory = Directory(runtimeDirectory);
    await directory.parent.create(recursive: true);
    final python = managedPythonExecutable(runtimeDirectory);
    try {
      if (!File(python).existsSync()) {
        await _run(basePythonExecutable, <String>[
          '-m',
          'venv',
          '--without-pip',
          runtimeDirectory,
        ]);
      }
      await _installSandboxCompatibility(python);
      final hasPip = await _hasPip(python);
      if (hasPip && listEquals(packages, defaultPackages)) {
        final existing = await inspect(python);
        if (existing.available) return python;
      }
      if (!hasPip) {
        _setState(
          JupyterRuntimeInstallState.installing,
          'Bootstrapping pip without venv ensurepip…',
        );
        await _run(basePythonExecutable, <String>[
          '-s',
          '-c',
          _pipLauncher,
          '--python',
          python,
          'install',
          '--disable-pip-version-check',
          '--upgrade',
          'pip',
        ]);
      }
      _setState(
        JupyterRuntimeInstallState.installing,
        'Installing Jupyter and Python tooling…',
      );
      await _run(python, <String>[
        '-m',
        'pip',
        'install',
        '--disable-pip-version-check',
        ...packages,
      ]);
      final inspection = await inspect(python);
      if (!inspection.available) {
        throw JupyterRuntimeInstallException(inspection.detail);
      }
      return python;
    } on JupyterRuntimeInstallCancelledException {
      _setState(JupyterRuntimeInstallState.idle, 'Installation cancelled.');
      rethrow;
    } on Object catch (error) {
      _setState(JupyterRuntimeInstallState.failed, '$error');
      rethrow;
    } finally {
      _activeProcess = null;
    }
  }

  bool cancel() {
    final process = _activeProcess;
    if (process == null) return false;
    _cancelRequested = true;
    final killed = process.kill(ProcessSignal.sigterm);
    if (killed) {
      _setState(JupyterRuntimeInstallState.idle, 'Installation cancelled.');
    }
    return killed;
  }

  Future<bool> _hasPip(String pythonExecutable) async {
    try {
      final result = await Process.run(pythonExecutable, const <String>[
        '-m',
        'pip',
        '--version',
      ]);
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }

  Future<void> _installSandboxCompatibility(String pythonExecutable) async {
    final result = await Process.run(pythonExecutable, const <String>[
      '-c',
      'import sysconfig; print(sysconfig.get_path("purelib"))',
    ]);
    if (result.exitCode != 0) {
      throw JupyterRuntimeInstallException(
        'Could not locate the managed Python site-packages directory.\n'
        '${_processFailure(result)}',
      );
    }
    final sitePackages = '${result.stdout}'.trim();
    if (sitePackages.isEmpty) {
      throw const JupyterRuntimeInstallException(
        'Managed Python returned an empty site-packages directory.',
      );
    }
    final customization = File('$sitePackages/sitecustomize.py');
    await customization.parent.create(recursive: true);
    if (!await customization.exists() ||
        await customization.readAsString() != _siteCustomize) {
      await customization.writeAsString(_siteCustomize);
    }
    _appendLog('Prepared sandbox-compatible Python startup.');
  }

  Future<void> _run(String executable, List<String> arguments) async {
    _appendLog('\$ $executable ${arguments.join(' ')}');
    final process = await Process.start(executable, arguments);
    _activeProcess = process;
    final output = <String>[];
    final subscriptions = <StreamSubscription<String>>[
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            output.add(line);
            _appendLog(line);
          }),
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
            output.add(line);
            _appendLog(line);
          }),
    ];
    final exitCode = await process.exitCode;
    _activeProcess = null;
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    if (exitCode != 0) {
      if (_cancelRequested) {
        throw const JupyterRuntimeInstallCancelledException();
      }
      throw JupyterRuntimeInstallException(
        'Command exited with code $exitCode.\n${output.takeLast(24).join('\n')}',
      );
    }
  }

  void _appendLog(String line) {
    if (_disposed) return;
    if (kDebugMode) debugPrint('[managed-jupyter] $line');
    _logs = <String>[..._logs, line];
    if (_logs.length > 160) _logs = _logs.sublist(_logs.length - 160);
    notifyListeners();
  }

  void _setState(JupyterRuntimeInstallState state, String detail) {
    if (_disposed) return;
    _state = state;
    _detail = detail;
    notifyListeners();
  }

  static String managedPythonExecutable(String runtimeDirectory) =>
      Platform.isWindows
      ? '$runtimeDirectory\\Scripts\\python.exe'
      : '$runtimeDirectory/bin/python';

  static String _processFailure(ProcessResult result) {
    final stderr = '${result.stderr}'.trim();
    final stdout = '${result.stdout}'.trim();
    return stderr.isNotEmpty
        ? stderr
        : stdout.isNotEmpty
        ? stdout
        : 'Python exited with code ${result.exitCode}.';
  }

  @override
  void dispose() {
    _disposed = true;
    _activeProcess?.kill(ProcessSignal.sigterm);
    super.dispose();
  }
}

final class JupyterRuntimeInstallException implements Exception {
  const JupyterRuntimeInstallException(this.message);

  final String message;

  @override
  String toString() => 'JupyterRuntimeInstallException: $message';
}

final class JupyterRuntimeInstallCancelledException implements Exception {
  const JupyterRuntimeInstallCancelledException();

  @override
  String toString() => 'Jupyter runtime installation was cancelled.';
}

extension<T> on List<T> {
  Iterable<T> takeLast(int count) => skip(length > count ? length - count : 0);
}
