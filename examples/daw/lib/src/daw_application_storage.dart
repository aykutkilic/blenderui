import 'dart:convert';
import 'dart:io';

import 'package:blender_ui_daw/blender_ui_daw.dart';
import 'package:path_provider/path_provider.dart';

/// App-owned project storage for the DAW example.
///
/// The extension package stays storage-agnostic; this native host deliberately
/// persists named `.buidaw` documents in application support rather than
/// presenting an in-memory save operation as durable storage.
final class DawApplicationStorage implements DawProjectStore {
  Future<Directory> _root() async {
    final support = await getApplicationSupportDirectory();
    final directory = Directory('${support.path}/projects');
    await directory.create(recursive: true);
    return directory;
  }

  Future<File> _file(String location) async {
    final root = await _root();
    // A reversible key avoids collisions such as `mix:a` and `mix/a` while
    // keeping app-support storage independent from user-visible filenames.
    final key = base64Url.encode(utf8.encode(location)).replaceAll('=', '');
    return File('${root.path}/$key.buidaw');
  }

  @override
  Future<String?> read(String location) async {
    final file = await _file(location);
    return await file.exists() ? file.readAsString() : null;
  }

  @override
  Future<void> write(String location, String contents) async {
    final file = await _file(location);
    await file.writeAsString(contents, flush: true);
  }
}
