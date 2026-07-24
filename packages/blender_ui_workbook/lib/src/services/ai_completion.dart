final class WorkbookCompletionRequest {
  const WorkbookCompletionRequest({
    required this.source,
    required this.cursorOffset,
    required this.language,
    this.filePath,
    this.cellId,
  });

  final String source;
  final int cursorOffset;
  final String language;
  final String? filePath;
  final String? cellId;
}

abstract interface class WorkbookAiCompletionProvider {
  Future<String?> complete(WorkbookCompletionRequest request);
}

final class WorkbookNoopCompletionProvider
    implements WorkbookAiCompletionProvider {
  const WorkbookNoopCompletionProvider();

  @override
  Future<String?> complete(WorkbookCompletionRequest request) async => null;
}
