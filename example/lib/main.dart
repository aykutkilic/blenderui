import 'package:flutter/widgets.dart';

import 'showcase/showcase_app.dart';

export 'showcase/showcase_app.dart' show ShowcaseApp;

/// Starts the package showcase. All workspace composition lives in the
/// showcase module so this entrypoint remains application-launcher only.
void main() {
  runApp(const ShowcaseApp(showSplash: true));
}
