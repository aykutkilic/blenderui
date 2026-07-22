import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';

const int maxLines = 750;
const Set<String> duplicateHelperNames = <String>{
  '_body',
  '_panel',
  '_check',
  '_number',
  '_choice',
  '_flatten',
};

void main(List<String> arguments) {
  final roots = arguments.isEmpty
      ? const <String>[
          'lib',
          'examples/blenderui/lib',
          'test',
          'examples/blenderui/test',
          'examples/components/lib',
          'examples/components/test',
          'packages/blender_ui_daw/lib',
          'packages/blender_ui_daw/test',
          'examples/daw/lib',
          'examples/daw/test',
        ]
      : arguments;
  final files = <File>[for (final root in roots) ..._dartFiles(root)]
    ..sort((a, b) => a.path.compareTo(b.path));
  final violations = <String>[];
  final helpers = <String, List<String>>{};

  for (final file in files) {
    final normalizedPath = file.path.replaceAll('\\', '/');
    final basename = file.uri.pathSegments.last;
    if (normalizedPath.startsWith('lib/src/parts/')) {
      violations.add(
        '${file.path}: flat generated parts directory is prohibited; use a '
        'descriptive domain folder',
      );
    }
    if (RegExp(r'^[a-z0-9_]+_\d{2}_[a-z0-9_]+\.dart$').hasMatch(basename)) {
      violations.add(
        '${file.path}: generated numeric ordering prefix is prohibited',
      );
    }
    final source = file.readAsStringSync();
    final lineCount = '\n'.allMatches(source).length + 1;
    if (lineCount > maxLines) {
      violations.add('${file.path}: file has $lineCount lines');
    }
    final result = parseString(
      content: source,
      path: file.absolute.path,
      throwIfDiagnostics: false,
    );
    final visitor = _DeclarationVisitor(
      path: file.path,
      lineInfo: result.lineInfo,
      violations: violations,
      helpers: helpers,
    );
    result.unit.accept(visitor);
  }

  final duplicateReports = <String>[
    for (final entry in helpers.entries)
      if (entry.value.length > 1)
        '${entry.key}: ${entry.value.length} declarations\n'
            '  ${entry.value.join('\n  ')}',
  ];
  if (duplicateReports.isNotEmpty) {
    stdout.writeln('Known helper-name duplication report:');
    stdout.writeln(duplicateReports.join('\n'));
  }
  if (violations.isNotEmpty) {
    stderr.writeln('Structural size violations (maximum $maxLines lines):');
    for (final violation in violations) {
      stderr.writeln('  $violation');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Structural guard passed for ${files.length} Dart files '
    '(maximum $maxLines lines).',
  );
}

Iterable<File> _dartFiles(String root) sync* {
  final entity = FileSystemEntity.typeSync(root);
  if (entity == FileSystemEntityType.file) {
    if (root.endsWith('.dart')) yield File(root);
    return;
  }
  final directory = Directory(root);
  if (!directory.existsSync()) return;
  for (final child in directory.listSync(recursive: true, followLinks: false)) {
    if (child is File && child.path.endsWith('.dart')) yield child;
  }
}

class _DeclarationVisitor extends RecursiveAstVisitor<void> {
  _DeclarationVisitor({
    required this.path,
    required this.lineInfo,
    required this.violations,
    required this.helpers,
  });

  final String path;
  final LineInfo lineInfo;
  final List<String> violations;
  final Map<String, List<String>> helpers;

  void _check(AstNode node, String kind, String name) {
    final start = lineInfo.getLocation(node.offset).lineNumber;
    final end = lineInfo.getLocation(node.end).lineNumber;
    final lines = end - start + 1;
    if (lines > maxLines) {
      violations.add('$path:$start $kind $name has $lines lines');
    }
    if (duplicateHelperNames.contains(name)) {
      helpers.putIfAbsent(name, () => <String>[]).add('$path:$start');
    }
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    _check(node, 'class', node.namePart.typeName.lexeme);
    super.visitClassDeclaration(node);
  }

  @override
  void visitExtensionDeclaration(ExtensionDeclaration node) {
    _check(node, 'extension', node.name?.lexeme ?? '<unnamed>');
    super.visitExtensionDeclaration(node);
  }

  @override
  void visitMixinDeclaration(MixinDeclaration node) {
    _check(node, 'mixin', node.name.lexeme);
    super.visitMixinDeclaration(node);
  }

  @override
  void visitEnumDeclaration(EnumDeclaration node) {
    _check(node, 'enum', node.namePart.typeName.lexeme);
    super.visitEnumDeclaration(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _check(node, 'function', node.name.lexeme);
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _check(node, 'method', node.name.lexeme);
    super.visitMethodDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _check(
      node,
      'constructor',
      node.name?.lexeme ?? node.typeName?.token.lexeme ?? '<primary>',
    );
    super.visitConstructorDeclaration(node);
  }
}
