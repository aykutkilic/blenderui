import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ai_completion.dart';

final class OpenAiCompatibleWorkbookCompletionProvider
    implements WorkbookAiCompletionProvider {
  OpenAiCompatibleWorkbookCompletionProvider({
    required this.baseUri,
    required this.model,
    this.apiKey,
    this.timeout = const Duration(seconds: 20),
    http.Client? client,
  }) : _client = client ?? http.Client();

  final Uri baseUri;
  final String model;
  final String? apiKey;
  final Duration timeout;
  final http.Client _client;

  @override
  Future<String?> complete(WorkbookCompletionRequest request) async {
    final before = request.source.substring(0, request.cursorOffset);
    final after = request.source.substring(request.cursorOffset);
    final response = await _client
        .post(
          _endpoint('/v1/chat/completions'),
          headers: <String, String>{
            'content-type': 'application/json',
            if (apiKey case final value? when value.isNotEmpty)
              'authorization': 'Bearer $value',
          },
          body: jsonEncode(<String, Object?>{
            'model': model,
            'temperature': 0.1,
            'max_tokens': 160,
            'messages': <Map<String, String>>[
              <String, String>{
                'role': 'system',
                'content':
                    'Complete Python at the cursor. Return only the exact text '
                    'to insert, without Markdown fences or explanation.',
              },
              <String, String>{
                'role': 'user',
                'content': 'Before cursor:\n$before\n\nAfter cursor:\n$after',
              },
            ],
          }),
        )
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WorkbookAiCompletionException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    final body = jsonDecode(response.body);
    if (body is! Map) return null;
    final choices = body['choices'];
    if (choices is! List || choices.isEmpty || choices.first is! Map)
      return null;
    final choice = choices.first as Map;
    final message = choice['message'];
    final value = message is Map ? message['content'] : choice['text'];
    return _clean(value?.toString());
  }

  void close() => _client.close();

  Uri _endpoint(String path) => baseUri.replace(
    path: '${baseUri.path.replaceFirst(RegExp(r'/$'), '')}$path',
  );

  static String? _clean(String? value) {
    if (value == null) return null;
    var result = value.trimRight();
    if (result.startsWith('```')) {
      result = result.replaceFirst(RegExp(r'^```(?:python)?\s*'), '');
      result = result.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return result.isEmpty ? null : result;
  }
}

final class OllamaWorkbookCompletionProvider
    implements WorkbookAiCompletionProvider {
  OllamaWorkbookCompletionProvider({
    required this.model,
    Uri? baseUri,
    this.timeout = const Duration(seconds: 30),
    http.Client? client,
  }) : baseUri = baseUri ?? Uri.parse('http://127.0.0.1:11434'),
       _client = client ?? http.Client();

  final Uri baseUri;
  final String model;
  final Duration timeout;
  final http.Client _client;

  @override
  Future<String?> complete(WorkbookCompletionRequest request) async {
    final before = request.source.substring(0, request.cursorOffset);
    final after = request.source.substring(request.cursorOffset);
    final response = await _client
        .post(
          baseUri.resolve('/api/generate'),
          headers: const <String, String>{'content-type': 'application/json'},
          body: jsonEncode(<String, Object?>{
            'model': model,
            'stream': false,
            'prompt':
                'Complete Python at <CURSOR>. Return only inserted code.\n'
                '$before<CURSOR>$after',
            'options': const <String, Object?>{
              'temperature': 0.1,
              'num_predict': 160,
            },
          }),
        )
        .timeout(timeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WorkbookAiCompletionException(
        statusCode: response.statusCode,
        body: response.body,
      );
    }
    final body = jsonDecode(response.body);
    if (body is! Map) return null;
    return OpenAiCompatibleWorkbookCompletionProvider._clean(
      body['response']?.toString(),
    );
  }

  void close() => _client.close();
}

final class WorkbookAiCompletionException implements Exception {
  const WorkbookAiCompletionException({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;

  @override
  String toString() =>
      'WorkbookAiCompletionException (HTTP $statusCode): $body';
}
