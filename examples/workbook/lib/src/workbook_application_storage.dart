import 'dart:io';

import 'package:blender_ui/blender_ui.dart';
import 'package:path_provider/path_provider.dart';

/// File-backed storage shared by BlenderUI's application services.
///
/// The directory is resolved lazily so services can be created before the
/// first frame while still persisting into the platform application-support
/// location rather than the process working directory.
final class WorkbookApplicationStorage implements BlenderWorkspaceStorage {
  Future<Directory> _root() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/blenderui-state');
    await directory.create(recursive: true);
    return directory;
  }

  Future<File> _file(String key) async {
    final root = await _root();
    final safe = key.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    return File('${root.path}/$safe.json');
  }

  @override
  Future<String?> read(String key) async {
    final file = await _file(key);
    return await file.exists() ? file.readAsString() : null;
  }

  @override
  Future<void> write(String key, String value) async {
    final file = await _file(key);
    await file.writeAsString(value, flush: true);
  }

  @override
  Future<void> remove(String key) async {
    final file = await _file(key);
    if (await file.exists()) await file.delete();
  }
}
