import 'package:blender_ui/blender_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BlenderIcon resolves a typed SVG asset', (tester) async {
    await tester.pumpWidget(
      const BlenderTheme(
        data: BlenderThemeData(
          iconTheme: BlenderIconThemeData(
            assetForGlyph: _svgAssetForGlyph,
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: BlenderIcon(BlenderGlyph.search),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == 'SvgPicture',
      ),
      findsOneWidget,
    );
  });

  test('asset variants preserve their intended tint policy', () {
    expect(const BlenderIconAsset.svg('icon.svg').tint, isTrue);
    expect(const BlenderIconAsset.raster('icon.png').tint, isFalse);
  });
}

BlenderIconAsset? _svgAssetForGlyph(String glyphName) =>
    glyphName == 'search' ? const BlenderIconAsset.svg('icon.svg') : null;
