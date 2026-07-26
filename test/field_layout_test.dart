import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('text fields do not overflow while a dock area collapses', (
    tester,
  ) async {
    await tester.pumpWidget(
      const BlenderApp(
        home: SizedBox(
          width: 16.1,
          height: 30,
          child: _NarrowSearchFieldHost(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('search fields remain usable with a trailing clear action', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'query');
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 16.1,
          height: 30,
          child: BlenderSearchField(controller: controller),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('search fields can be hosted in a horizontal scroll view', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      BlenderApp(
        home: SizedBox(
          width: 266.3,
          height: 30,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[BlenderSearchField(controller: controller)],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

class _NarrowSearchFieldHost extends StatefulWidget {
  const _NarrowSearchFieldHost();

  @override
  State<_NarrowSearchFieldHost> createState() => _NarrowSearchFieldHostState();
}

class _NarrowSearchFieldHostState extends State<_NarrowSearchFieldHost> {
  late final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlenderSearchField(controller: _controller);
  }
}
