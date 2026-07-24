import 'dart:async';
import 'dart:io';

import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'workbook_runtime_settings.dart';
import 'workbook_shadow_file_manager.dart';

/// Owns the optional Python/Jupyter capability of the workbook host.
///
/// The application shell and document session exist independently. This
/// controller owns only runtime discovery, installation, connection, language
/// tooling, and their application-support resources.
final class WorkbookRuntimeController extends ChangeNotifier {
  WorkbookRuntimeController({
    required this.session,
    required this.application,
    required this.installer,
    required this.shadowFiles,
  }) {
    installer.addListener(_synchronizeInstallerJob);
    application.status.report(_status);
  }

  final WorkbookSessionController session;
  final BlenderApplicationController<WorkbookDocument> application;
  final JupyterRuntimeInstaller installer;
  final WorkbookShadowFileManager shadowFiles;

  WorkbookRuntimeSettings _settings = const WorkbookRuntimeSettings();
  WorkbookRuntimeSettingsStore? _settingsStore;
  Directory? _supportDirectory;
  Directory? _workspace;
  JupyterServerProcess? _server;
  LspConfig? _lspConfig;
  WorkbookAiCompletionProvider? _aiProvider;
  var _busy = false;
  var _status = 'Offline — editing and file access are available';
  var _remoteToken = '';
  var _closed = false;

  WorkbookRuntimeSettings get settings => _settings;
  Directory? get workspace => _workspace;
  LspConfig? get lspConfig => _lspConfig;
  WorkbookAiCompletionProvider? get aiProvider => _aiProvider;
  bool get busy => _busy;
  String get status => _status;
  String get remoteToken => _remoteToken;

  Future<void> initialize() async {
    try {
      await _ensureSupportDirectory();
      final loaded = await _settingsStore!.load();
      _settings = _settingsFromEnvironment(loaded);
      await prepareWorkspace();
      _notifyIfOpen();
      if (Platform.environment['WORKBOOK_AUTOINSTALL_MANAGED'] == '1') {
        await installAndConnect();
        return;
      }
      if (_settings.autoConnect &&
          _settings.mode != WorkbookRuntimeMode.offline) {
        await connect();
      }
    } on Object catch (error) {
      report('Application support setup failed: $error');
    }
  }

  void updateRemoteToken(String value) {
    if (_remoteToken == value) return;
    _remoteToken = value;
    _notifyIfOpen();
  }

  Future<void> connect() async {
    if (_busy) return;
    if (_settings.mode == WorkbookRuntimeMode.offline) {
      await disconnect();
      report('Offline — editing and file access are available');
      return;
    }
    if (_localRuntimeBlockedBySandbox &&
        _settings.mode != WorkbookRuntimeMode.remote) {
      report(
        'Local Python is unavailable while this macOS host uses App Sandbox. '
        'Choose Remote Jupyter Server or Offline mode.',
        level: BlenderStatusLevel.warning,
      );
      return;
    }
    _setBusy(true, status: 'Connecting Python runtime…');
    try {
      await disconnect(updateStatus: false);
      await _ensureSupportDirectory();
      late final Uri serverUri;
      String? token;
      if (_settings.mode == WorkbookRuntimeMode.remote) {
        serverUri = Uri.parse(_settings.serverUrl.trim());
        token = _remoteToken.trim().isEmpty ? null : _remoteToken.trim();
      } else {
        final python = _localPythonExecutable;
        final inspection = await installer.inspect(python);
        if (!inspection.available) {
          throw JupyterRuntimeInstallException(
            '${inspection.detail} Install the managed runtime from Preferences, '
            'or choose a different Python executable.',
          );
        }
        final server = await JupyterServerProcess.start(
          JupyterServerConfiguration(
            workspacePath: _workspace!.path,
            pythonExecutable: python,
          ),
        );
        _server = server;
        serverUri = server.baseUri;
        token = server.token;
      }

      final kernel = JupyterKernel(serverUri: serverUri, token: token);
      await session.attachKernel(kernel);
      _lspConfig = await _startLanguageServer();
      _aiProvider = _buildAiProvider();
      report('Python kernel connected');
    } on Object catch (error) {
      await disconnect(updateStatus: false);
      report('Runtime unavailable: $error');
    } finally {
      _setBusy(false);
    }
  }

  Future<void> installAndConnect() async {
    if (_busy) return;
    if (_localRuntimeBlockedBySandbox) {
      report(
        'Managed local Jupyter requires either a non-sandboxed host or a '
        'Python distribution bundled and signed with the app. Choose Remote '
        'Jupyter Server or Offline mode in this sandboxed build.',
        level: BlenderStatusLevel.warning,
      );
      return;
    }
    application.jobs.remove('workbook-jupyter-install');
    application.jobs.register(
      BlenderJob(
        id: 'workbook-jupyter-install',
        name: 'Installing managed Jupyter',
        progress: .05,
        onCancel: () async => installer.cancel(),
      ),
    );
    _setBusy(true);
    try {
      await _ensureSupportDirectory();
      await installer.install(
        basePythonExecutable: _settings.pythonExecutable.trim().isEmpty
            ? 'python3'
            : _settings.pythonExecutable.trim(),
        runtimeDirectory: _managedRuntimeDirectory,
      );
      await updateSettings(
        _settings.copyWith(mode: WorkbookRuntimeMode.managed),
      );
      report('Managed Jupyter installed. Connecting…');
      application.jobs.complete('workbook-jupyter-install');
      application.reports.report(
        'Managed Jupyter runtime installed successfully.',
        level: BlenderStatusLevel.success,
      );
    } on JupyterRuntimeInstallCancelledException {
      application.jobs.remove('workbook-jupyter-install');
      report(
        'Jupyter installation cancelled',
        level: BlenderStatusLevel.warning,
      );
      _setBusy(false);
      return;
    } on Object catch (error) {
      application.jobs.fail('workbook-jupyter-install', error);
      application.reports.report(
        'Jupyter installation failed: $error',
        level: BlenderStatusLevel.error,
      );
      report(
        'Jupyter installation failed: $error',
        level: BlenderStatusLevel.error,
      );
      _setBusy(false);
      return;
    }
    _setBusy(false);
    await connect();
  }

  Future<void> prepareWorkspace() {
    final directory = _workspace;
    if (directory == null) return Future<void>.value();
    return shadowFiles.synchronize(
      workspace: directory,
      document: session.document,
    );
  }

  String? filePathForCell(WorkbookCell cell) =>
      shadowFiles.pathFor(_workspace, cell);

  Future<void> updateSettings(WorkbookRuntimeSettings value) async {
    _settings = value;
    _notifyIfOpen();
    await _settingsStore?.save(value);
  }

  void report(
    String message, {
    BlenderStatusLevel level = BlenderStatusLevel.info,
  }) {
    if (_closed) return;
    _status = message;
    application.status.report(message, level: level);
    _notifyIfOpen();
  }

  Future<void> disconnect({bool updateStatus = true}) async {
    await session.detachKernel();
    _disposeLanguageServices();
    await _server?.stop();
    _server = null;
    if (updateStatus) {
      report('Offline — editing and file access are available');
    } else {
      _notifyIfOpen();
    }
  }

  Future<void> _ensureSupportDirectory() async {
    if (_supportDirectory != null && _workspace != null) return;
    final support = await getApplicationSupportDirectory();
    final workspace = Directory('${support.path}/workspace');
    await workspace.create(recursive: true);
    _supportDirectory = support;
    _workspace = workspace;
    _settingsStore ??= WorkbookRuntimeSettingsStore(
      File('${support.path}/runtime-settings.json'),
    );
    await prepareWorkspace();
  }

  WorkbookRuntimeSettings _settingsFromEnvironment(
    WorkbookRuntimeSettings stored,
  ) {
    final serverUrl = Platform.environment['JUPYTER_SERVER_URL'];
    final python = Platform.environment['WORKBOOK_PYTHON'];
    if (serverUrl != null && serverUrl.isNotEmpty) {
      _remoteToken = Platform.environment['JUPYTER_TOKEN'] ?? '';
      return stored.copyWith(
        mode: WorkbookRuntimeMode.remote,
        serverUrl: serverUrl,
      );
    }
    if (python != null && python.isNotEmpty) {
      return stored.copyWith(
        mode: WorkbookRuntimeMode.custom,
        pythonExecutable: python,
      );
    }
    return stored;
  }

  String get _managedRuntimeDirectory =>
      '${_supportDirectory!.path}/managed-jupyter';

  bool get _localRuntimeBlockedBySandbox =>
      Platform.isMacOS &&
      Platform.environment.containsKey('APP_SANDBOX_CONTAINER_ID');

  String get _localPythonExecutable =>
      _settings.mode == WorkbookRuntimeMode.managed
      ? JupyterRuntimeInstaller.managedPythonExecutable(
          _managedRuntimeDirectory,
        )
      : _settings.pythonExecutable.trim();

  Future<LspConfig?> _startLanguageServer() async {
    final directory = _workspace;
    if (directory == null) return null;
    final socketUrl = _settings.languageServerUrl.trim();
    if (socketUrl.isNotEmpty) {
      return LspSocketConfig(
        workspacePath: directory.path,
        languageId: 'python',
        serverUrl: socketUrl,
        capabilities: const LspClientCapabilities(),
      );
    }
    if (_settings.mode == WorkbookRuntimeMode.remote) return null;
    final python = _localPythonExecutable;
    final bin = File(python).parent.path;
    final executable = Platform.isWindows
        ? '$bin/basedpyright-langserver.cmd'
        : '$bin/basedpyright-langserver';
    if (!File(executable).existsSync()) return null;
    try {
      return await LspStdioConfig.start(
        executable: executable,
        args: const <String>['--stdio'],
        workspacePath: directory.path,
        languageId: 'python',
        capabilities: const LspClientCapabilities(),
      );
    } on Object catch (error) {
      debugPrint('Python LSP unavailable: $error');
      return null;
    }
  }

  WorkbookAiCompletionProvider? _buildAiProvider() {
    final provider = Platform.environment['WORKBOOK_AI_PROVIDER'];
    final model = Platform.environment['WORKBOOK_AI_MODEL'];
    if (model == null || model.isEmpty) return null;
    final base = Uri.parse(
      Platform.environment['WORKBOOK_AI_BASE_URL'] ??
          (provider == 'ollama'
              ? 'http://127.0.0.1:11434'
              : 'http://127.0.0.1:1234'),
    );
    if (provider == 'ollama') {
      return OllamaWorkbookCompletionProvider(model: model, baseUri: base);
    }
    return OpenAiCompatibleWorkbookCompletionProvider(
      baseUri: base,
      model: model,
      apiKey: Platform.environment['WORKBOOK_AI_API_KEY'],
    );
  }

  void _setBusy(bool value, {String? status}) {
    _busy = value;
    if (status != null) _status = status;
    _notifyIfOpen();
  }

  void _notifyIfOpen() {
    if (!_closed) notifyListeners();
  }

  void _synchronizeInstallerJob() {
    final job = application.jobs['workbook-jupyter-install'];
    if (job == null ||
        job.state == BlenderJobState.completed ||
        job.state == BlenderJobState.failed) {
      return;
    }
    switch (installer.state) {
      case JupyterRuntimeInstallState.installing:
        application.jobs.reportProgress('workbook-jupyter-install', .55);
      case JupyterRuntimeInstallState.checking:
        application.jobs.reportProgress('workbook-jupyter-install', .9);
      case JupyterRuntimeInstallState.ready:
        application.jobs.complete('workbook-jupyter-install');
      case JupyterRuntimeInstallState.failed:
        application.jobs.fail('workbook-jupyter-install', installer.detail);
      case JupyterRuntimeInstallState.idle ||
          JupyterRuntimeInstallState.unavailable:
        break;
    }
  }

  void _disposeLanguageServices() {
    _lspConfig?.dispose();
    _lspConfig = null;
    if (_aiProvider
        case final OpenAiCompatibleWorkbookCompletionProvider provider) {
      provider.close();
    }
    if (_aiProvider case final OllamaWorkbookCompletionProvider provider) {
      provider.close();
    }
    _aiProvider = null;
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    installer.removeListener(_synchronizeInstallerJob);
    await session.detachKernel();
    _disposeLanguageServices();
    await _server?.stop();
    _server = null;
  }

  @override
  void dispose() {
    installer.removeListener(_synchronizeInstallerJob);
    _closed = true;
    _disposeLanguageServices();
    unawaited(_server?.stop());
    _server = null;
    super.dispose();
  }
}
