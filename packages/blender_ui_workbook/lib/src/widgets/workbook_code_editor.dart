import 'dart:async';
import 'dart:io';

import 'package:code_forge/code_forge.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:re_highlight/languages/python.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/vs2015.dart';

import '../services/ai_completion.dart';
import '../services/ai_completion_coordinator.dart';
import 'workbook_palette.dart';

bool _workbookEditorInitialized = false;
Object? _workbookEditorInitializationError;

bool get isWorkbookEditorInitialized => _workbookEditorInitialized;
Object? get workbookEditorInitializationError =>
    _workbookEditorInitializationError;

/// Initializes CodeForge's optional native acceleration.
///
/// Failure is recorded instead of propagated so a host can still open with
/// the built-in plain-text editor. Native editor availability must never be a
/// prerequisite for reading or editing a workbook.
Future<void> initializeWorkbookEditor() async {
  if (_workbookEditorInitialized) return;
  try {
    await RustLib.init();
    _workbookEditorInitialized = true;
    _workbookEditorInitializationError = null;
  } on Object catch (error) {
    _workbookEditorInitializationError = error;
    debugPrint(
      'CodeForge native editor unavailable (${error.runtimeType}); '
      'using fallback.',
    );
  }
}

final class WorkbookCodeEditor extends StatefulWidget {
  const WorkbookCodeEditor({
    this.controller,
    this.findController,
    this.undoController,
    this.lspConfig,
    this.initialText,
    this.filePath,
    this.onChanged,
    this.aiCompletionProvider,
    this.aiCompletionDebounce = const Duration(milliseconds: 550),
    this.editorTheme,
    this.language,
    this.extraLanguages = const <Mode>[],
    this.customCodeSnippets,
    this.focusNode,
    this.verticalScrollController,
    this.horizontalScrollController,
    this.verticalScrollPhysics = const ClampingScrollPhysics(),
    this.scrollbarDecoration,
    this.innerPadding,
    this.keyboardShortcuts = const CodeForgeKeyboardShortcuts(),
    this.selectionStyle,
    this.gutterBuilder,
    this.gutterStyle,
    this.suggestionStyle,
    this.hoverDetailsStyle,
    this.matchHighlightStyle,
    this.finderBuilder,
    this.readOnly = false,
    this.autoFocus = false,
    this.lineWrap = false,
    this.enableFolding = true,
    this.enableGuideLines = true,
    this.enableGutter = true,
    this.enableGutterDivider = true,
    this.enableLocalSuggestions = true,
    this.enableKeyboardSuggestions = true,
    this.keyboardType = TextInputType.multiline,
    this.textDirection = TextDirection.ltr,
    this.tabSize = 4,
    this.useSpaceAsTab = true,
    this.deleteFoldRangeOnDeletingFirstLine = false,
    this.persistFileChanges = true,
    this.textStyle = const TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      height: 1.35,
    ),
    super.key,
  }) : assert(
         controller == null || lspConfig == null,
         'Pass LSP configuration through the controller or lspConfig, not both.',
       ),
       assert(
         filePath == null || initialText == null,
         'CodeForge loads filePath directly; initialText cannot also be set.',
       );

  final CodeForgeController? controller;
  final FindController? findController;
  final UndoRedoController? undoController;
  final LspConfig? lspConfig;
  final String? initialText;
  final String? filePath;
  final ValueChanged<String>? onChanged;
  final WorkbookAiCompletionProvider? aiCompletionProvider;
  final Duration aiCompletionDebounce;
  final Map<String, TextStyle>? editorTheme;
  final Mode? language;
  final List<Mode> extraLanguages;
  final List<CustomCodeSnippet>? customCodeSnippets;
  final FocusNode? focusNode;
  final ScrollController? verticalScrollController;
  final ScrollController? horizontalScrollController;
  final ScrollPhysics verticalScrollPhysics;
  final ScrollbarDecoration? scrollbarDecoration;
  final EdgeInsets? innerPadding;
  final CodeForgeKeyboardShortcuts keyboardShortcuts;
  final CodeSelectionStyle? selectionStyle;
  final GutterBuilder? gutterBuilder;
  final GutterStyle? gutterStyle;
  final SuggestionStyle? suggestionStyle;
  final HoverDetailsStyle? hoverDetailsStyle;
  final MatchHighlightStyle? matchHighlightStyle;
  final PreferredSizeWidget Function(BuildContext, FindController)?
  finderBuilder;
  final bool readOnly;
  final bool autoFocus;
  final bool lineWrap;
  final bool enableFolding;
  final bool enableGuideLines;
  final bool enableGutter;
  final bool enableGutterDivider;
  final bool enableLocalSuggestions;
  final bool enableKeyboardSuggestions;
  final TextInputType keyboardType;
  final TextDirection textDirection;
  final int tabSize;
  final bool useSpaceAsTab;
  final bool deleteFoldRangeOnDeletingFirstLine;
  final bool persistFileChanges;
  final TextStyle textStyle;

  @override
  State<WorkbookCodeEditor> createState() => _WorkbookCodeEditorState();
}

final class _WorkbookCodeEditorState extends State<WorkbookCodeEditor> {
  late CodeForgeController _controller;
  late bool _ownsController;
  late bool _usingCodeForge;
  TextEditingController? _fallbackController;
  FocusNode? _fallbackFocusNode;
  Timer? _fileTimer;
  WorkbookAiCompletionCoordinator? _aiCoordinator;
  String? _previousText;
  String? _lastCompletionKey;
  String? _deferredText;
  var _textCallbackScheduled = false;
  var _fallbackHasLocalChanges = false;
  var _writingFallbackText = false;

  @override
  void initState() {
    super.initState();
    _usingCodeForge = widget.controller != null || isWorkbookEditorInitialized;
    if (_usingCodeForge) {
      _attachController();
    } else {
      _attachFallbackController();
    }
  }

  @override
  void didUpdateWidget(covariant WorkbookCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.lspConfig != widget.lspConfig) {
      if (_usingCodeForge) _detachController();
      _fallbackController?.dispose();
      _fallbackFocusNode?.dispose();
      _fallbackFocusNode = null;
      _usingCodeForge =
          widget.controller != null || isWorkbookEditorInitialized;
      if (_usingCodeForge) {
        _attachController();
      } else {
        _attachFallbackController();
      }
    } else if (oldWidget.aiCompletionProvider != widget.aiCompletionProvider ||
        oldWidget.aiCompletionDebounce != widget.aiCompletionDebounce) {
      if (_usingCodeForge) _attachAiCoordinator();
    } else if (!_usingCodeForge &&
        oldWidget.initialText != widget.initialText) {
      final text = widget.initialText ?? '';
      if (_fallbackController!.text != text) {
        _fallbackHasLocalChanges = false;
        _fallbackController!.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    }
  }

  void _attachFallbackController() {
    _fallbackHasLocalChanges = false;
    _fallbackController = TextEditingController(text: widget.initialText ?? '');
    if (widget.focusNode == null) _fallbackFocusNode = FocusNode();
    unawaited(_loadFallbackFile());
  }

  Future<void> _loadFallbackFile() async {
    if (widget.initialText != null) return;
    final path = widget.filePath;
    if (path == null) return;
    try {
      final text = await File(path).readAsString();
      final controller = _fallbackController;
      if (!mounted || controller == null || _fallbackHasLocalChanges) return;
      _writingFallbackText = true;
      controller.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } on FileSystemException {
      // The host may still be preparing a shadow file. The editor remains
      // usable with its empty/text-provided fallback until that path exists.
    } finally {
      _writingFallbackText = false;
    }
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ?? CodeForgeController(lspConfig: widget.lspConfig);
    _previousText = _controller.text;
    _controller.addListener(_controllerChanged);
    _attachAiCoordinator();
  }

  void _attachAiCoordinator() {
    _aiCoordinator?.dispose();
    _aiCoordinator = null;
    _lastCompletionKey = null;
    final provider = widget.aiCompletionProvider;
    if (provider == null) {
      // CodeForge's cleanup method always notifies its listeners, including
      // when no ghost text is present.  This method can run from
      // initState/didUpdateWidget while the element tree is being built, so a
      // synchronous notification would make the render tree dirty during
      // build.  Defer only the meaningful cleanup to the next frame.
      if (_controller.ghostText != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _controller.ghostText != null) {
            _controller.clearGhostText();
          }
        });
      }
      return;
    }
    _aiCoordinator = WorkbookAiCompletionCoordinator(
      provider: provider,
      debounce: widget.aiCompletionDebounce,
      onClear: _controller.clearGhostText,
      onCompletion: (request, completion) {
        if (!mounted ||
            _controller.text != request.source ||
            _controller.selection.extentOffset != request.cursorOffset) {
          return;
        }
        final line = _controller.getLineAtOffset(request.cursorOffset);
        final column =
            request.cursorOffset - _controller.getLineStartOffset(line);
        _controller.setGhostText(
          GhostText(line: line, column: column, text: completion),
        );
      },
    );
  }

  void _detachController() {
    _aiCoordinator?.dispose();
    _fileTimer?.cancel();
    _controller.removeListener(_controllerChanged);
    if (_ownsController) _controller.dispose();
  }

  void _controllerChanged() {
    final text = _controller.text;
    if (text != _previousText) {
      _previousText = text;
      _notifyHostOfTextChange(text);
      _scheduleFilePersistence(text);
    }
    _scheduleAiCompletion();
  }

  void _notifyHostOfTextChange(String text) {
    final callback = widget.onChanged;
    if (callback == null) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      callback(text);
      return;
    }
    _deferredText = text;
    if (_textCallbackScheduled) return;
    _textCallbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textCallbackScheduled = false;
      final deferred = _deferredText;
      _deferredText = null;
      if (mounted && deferred != null) widget.onChanged?.call(deferred);
    });
  }

  void _scheduleFilePersistence(String text) {
    final filePath = widget.filePath;
    if (!widget.persistFileChanges || filePath == null) return;
    _fileTimer?.cancel();
    _fileTimer = Timer(const Duration(milliseconds: 250), () async {
      try {
        await File(filePath).writeAsString(text, flush: true);
      } on Object {
        // The host receives the same text through onChanged and may surface its
        // own persistence policy. Editor typing must not be interrupted here.
      }
    });
  }

  void _scheduleAiCompletion() {
    final provider = widget.aiCompletionProvider;
    if (provider == null || widget.readOnly) return;
    final source = _controller.text;
    final offset = _controller.selection.extentOffset.clamp(0, source.length);
    final key = '$offset:$source';
    if (key == _lastCompletionKey) return;
    _lastCompletionKey = key;
    _aiCoordinator?.request(
      WorkbookCompletionRequest(
        source: source,
        cursorOffset: offset,
        language: 'python',
        filePath: widget.filePath,
      ),
    );
  }

  @override
  void dispose() {
    _deferredText = null;
    if (_usingCodeForge) _detachController();
    _fallbackController?.dispose();
    _fallbackFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = WorkbookPalette.of(context);
    final baseStyle = widget.textStyle.copyWith(color: palette.foreground);
    if (!_usingCodeForge) {
      return ColoredBox(
        color: palette.canvas,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: EditableText(
            controller: _fallbackController!,
            focusNode: widget.focusNode ?? _fallbackFocusNode!,
            autofocus: widget.autoFocus,
            readOnly: widget.readOnly,
            maxLines: null,
            keyboardType: widget.keyboardType,
            textDirection: widget.textDirection,
            style: baseStyle,
            cursorColor: palette.focus,
            backgroundCursorColor: palette.muted,
            selectionColor: palette.accent.withValues(alpha: 0.38),
            onChanged: (text) {
              if (!_writingFallbackText) _fallbackHasLocalChanges = true;
              widget.onChanged?.call(text);
              _scheduleFilePersistence(text);
            },
          ),
        ),
      );
    }
    final configuredTheme = widget.editorTheme ?? vs2015Theme;
    final rootStyle = configuredTheme['root'] ?? const TextStyle();
    final editorTheme = <String, TextStyle>{
      ...configuredTheme,
      'root': rootStyle.copyWith(
        color: palette.foreground,
        backgroundColor: palette.canvas,
      ),
    };
    return CodeForge(
      controller: _controller,
      findController: widget.findController,
      undoController: widget.undoController,
      editorTheme: editorTheme,
      language: widget.language ?? langPython,
      extraLanguages: widget.extraLanguages,
      filePath: widget.filePath,
      initialText: widget.filePath == null ? widget.initialText : null,
      focusNode: widget.focusNode,
      verticalScrollController: widget.verticalScrollController,
      horizontalScrollController: widget.horizontalScrollController,
      verticalScrollPhysics: widget.verticalScrollPhysics,
      scrollbarDecoration: widget.scrollbarDecoration,
      innerPadding: widget.innerPadding,
      keyboardShotcuts: widget.keyboardShortcuts,
      textStyle: baseStyle,
      ghostTextStyle: baseStyle.copyWith(
        color: palette.focus.withValues(alpha: 0.55),
        fontStyle: FontStyle.italic,
      ),
      customCodeSnippets: widget.customCodeSnippets,
      readOnly: widget.readOnly,
      autoFocus: widget.autoFocus,
      lineWrap: widget.lineWrap,
      enableFolding: widget.enableFolding,
      enableGuideLines: widget.enableGuideLines,
      enableGutter: widget.enableGutter,
      enableGutterDivider: widget.enableGutterDivider,
      enableLocalSuggestions: widget.enableLocalSuggestions,
      enableKeyboardSuggestions: widget.enableKeyboardSuggestions,
      keyboardType: widget.keyboardType,
      textDirection: widget.textDirection,
      useSpaceAsTab: widget.useSpaceAsTab,
      tabSize: widget.tabSize,
      deleteFoldRangeOnDeletingFirstLine:
          widget.deleteFoldRangeOnDeletingFirstLine,
      selectionStyle:
          widget.selectionStyle ??
          CodeSelectionStyle(
            cursorColor: palette.focus,
            selectionColor: palette.accent.withValues(alpha: 0.38),
            cursorBubbleColor: palette.focus,
          ),
      gutterBuilder: widget.gutterBuilder,
      gutterStyle:
          widget.gutterStyle ??
          GutterStyle(
            backgroundColor: palette.canvas,
            activeLineNumberColor: palette.foreground,
            inactiveLineNumberColor: palette.muted,
            foldedIconColor: palette.muted,
            unfoldedIconColor: palette.muted,
            errorLineNumberColor: palette.error,
            warningLineNumberColor: palette.warning,
          ),
      suggestionStyle:
          widget.suggestionStyle ??
          SuggestionStyle(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            backgroundColor: palette.raised,
            focusColor: palette.focus.withValues(alpha: 0.22),
            hoverColor: palette.foreground.withValues(alpha: 0.08),
            splashColor: palette.accent.withValues(alpha: 0.12),
            selectedBackgroundColor: palette.accent.withValues(alpha: 0.32),
            textStyle: TextStyle(color: palette.foreground, fontSize: 12),
            borderColor: palette.outline,
          ),
      hoverDetailsStyle:
          widget.hoverDetailsStyle ??
          HoverDetailsStyle(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
            ),
            backgroundColor: palette.raised,
            focusColor: palette.focus.withValues(alpha: 0.22),
            hoverColor: palette.foreground.withValues(alpha: 0.08),
            splashColor: palette.accent.withValues(alpha: 0.12),
            textStyle: TextStyle(color: palette.foreground, fontSize: 12),
          ),
      matchHighlightStyle: widget.matchHighlightStyle,
      finderBuilder: widget.finderBuilder,
    );
  }
}
