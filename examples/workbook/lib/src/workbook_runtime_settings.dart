import 'dart:convert';
import 'dart:io';

enum WorkbookRuntimeMode { offline, managed, custom, remote }

final class WorkbookRuntimeSettings {
  const WorkbookRuntimeSettings({
    this.mode = WorkbookRuntimeMode.offline,
    this.autoConnect = false,
    this.pythonExecutable = 'python3',
    this.serverUrl = 'http://127.0.0.1:8888',
    this.languageServerUrl = '',
  });

  final WorkbookRuntimeMode mode;
  final bool autoConnect;
  final String pythonExecutable;
  final String serverUrl;
  final String languageServerUrl;

  WorkbookRuntimeSettings copyWith({
    WorkbookRuntimeMode? mode,
    bool? autoConnect,
    String? pythonExecutable,
    String? serverUrl,
    String? languageServerUrl,
  }) => WorkbookRuntimeSettings(
    mode: mode ?? this.mode,
    autoConnect: autoConnect ?? this.autoConnect,
    pythonExecutable: pythonExecutable ?? this.pythonExecutable,
    serverUrl: serverUrl ?? this.serverUrl,
    languageServerUrl: languageServerUrl ?? this.languageServerUrl,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'mode': mode.name,
    'autoConnect': autoConnect,
    'pythonExecutable': pythonExecutable,
    'serverUrl': serverUrl,
    'languageServerUrl': languageServerUrl,
  };

  factory WorkbookRuntimeSettings.fromJson(Map<String, Object?> json) {
    final modeName = json['mode'];
    final mode = WorkbookRuntimeMode.values.firstWhere(
      (value) => value.name == modeName,
      orElse: () => WorkbookRuntimeMode.offline,
    );
    return WorkbookRuntimeSettings(
      mode: mode,
      autoConnect: json['autoConnect'] == true,
      pythonExecutable: json['pythonExecutable'] is String
          ? json['pythonExecutable']! as String
          : 'python3',
      serverUrl: json['serverUrl'] is String
          ? json['serverUrl']! as String
          : 'http://127.0.0.1:8888',
      languageServerUrl: json['languageServerUrl'] is String
          ? json['languageServerUrl']! as String
          : '',
    );
  }
}

/// Persists non-secret runtime choices in application support storage.
/// Tokens remain process-memory only and are never written to this JSON file.
final class WorkbookRuntimeSettingsStore {
  const WorkbookRuntimeSettingsStore(this.file);

  final File file;

  Future<WorkbookRuntimeSettings> load() async {
    if (!await file.exists()) return const WorkbookRuntimeSettings();
    try {
      final value = jsonDecode(await file.readAsString());
      return value is Map<String, Object?>
          ? WorkbookRuntimeSettings.fromJson(value)
          : const WorkbookRuntimeSettings();
    } on Object {
      return const WorkbookRuntimeSettings();
    }
  }

  Future<void> save(WorkbookRuntimeSettings settings) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(settings.toJson()),
      flush: true,
    );
  }
}
