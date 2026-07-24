import 'dart:convert';
import 'dart:typed_data';

sealed class WorkbookOutput {
  const WorkbookOutput();
}

final class WorkbookClearOutput extends WorkbookOutput {
  const WorkbookClearOutput({this.wait = false});

  final bool wait;
}

enum WorkbookStream { stdout, stderr }

final class WorkbookStreamOutput extends WorkbookOutput {
  const WorkbookStreamOutput({required this.stream, required this.text});

  final WorkbookStream stream;
  final String text;
}

final class WorkbookErrorOutput extends WorkbookOutput {
  WorkbookErrorOutput({
    required this.name,
    required this.message,
    List<String> traceback = const <String>[],
  }) : traceback = List<String>.unmodifiable(traceback);

  final String name;
  final String message;
  final List<String> traceback;
}

final class WorkbookDisplayOutput extends WorkbookOutput {
  WorkbookDisplayOutput({
    required Map<String, Object?> data,
    Map<String, Object?> metadata = const <String, Object?>{},
    this.executionCount,
  }) : data = Map<String, Object?>.unmodifiable(_freezeJsonMap(data)),
       metadata = Map<String, Object?>.unmodifiable(_freezeJsonMap(metadata));

  final Map<String, Object?> data;
  final Map<String, Object?> metadata;
  final int? executionCount;

  String? text(String mimeType) {
    final value = data[mimeType];
    if (value is String) return value;
    if (value is List<Object?>) return value.join();
    return value == null ? null : jsonEncode(value);
  }

  Uint8List? bytes(String mimeType) {
    final value = text(mimeType);
    if (value == null) return null;
    try {
      return base64Decode(value.replaceAll(RegExp(r'\s'), ''));
    } on FormatException {
      return null;
    }
  }
}

Map<String, Object?> _freezeJsonMap(Map<String, Object?> source) =>
    <String, Object?>{
      for (final entry in source.entries) entry.key: _freezeJson(entry.value),
    };

Object? _freezeJson(Object? value) => switch (value) {
  Map<Object?, Object?> map => Map<Object?, Object?>.unmodifiable(
    <Object?, Object?>{
      for (final entry in map.entries) entry.key: _freezeJson(entry.value),
    },
  ),
  List<Object?> list => List<Object?>.unmodifiable(<Object?>[
    for (final item in list) _freezeJson(item),
  ]),
  _ => value,
};
