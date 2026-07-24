import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'OpenAI-compatible provider returns insertion-only completion text',
    () async {
      late http.Request captured;
      final provider = OpenAiCompatibleWorkbookCompletionProvider(
        baseUri: Uri.parse('http://localhost:1234'),
        model: 'coder',
        apiKey: 'secret',
        client: MockClient((request) async {
          captured = request;
          return http.Response(
            '{"choices":[{"message":{"content":"```python\\nreturn 1\\n```"}}]}',
            200,
          );
        }),
      );

      final completion = await provider.complete(
        const WorkbookCompletionRequest(
          source: 'def answer():\n    ',
          cursorOffset: 18,
          language: 'python',
        ),
      );

      expect(completion, 'return 1');
      expect(captured.url.path, '/v1/chat/completions');
      expect(captured.headers['authorization'], 'Bearer secret');
      provider.close();
    },
  );
}
