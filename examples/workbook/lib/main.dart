import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter/widgets.dart';

import 'src/workbook_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeWorkbookEditor();
  runApp(const WorkbookExampleApp());
}
