import 'package:blender_ui_daw/blender_ui_daw.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scale filters classify and snap MIDI pitches', () {
    const scale = DawMidiScaleFilter(
      rootPitchClass: 0,
      scale: DawScaleKind.major,
      enabled: true,
    );

    expect(scale.contains(60), isTrue);
    expect(scale.contains(61), isFalse);
    expect(scale.snapPitch(61), 60);
    expect(scale.snapPitch(66), 65);
  });

  test('disabled scale filters leave chromatic notes unchanged', () {
    const scale = DawMidiScaleFilter(
      rootPitchClass: 7,
      scale: DawScaleKind.blues,
    );
    expect(scale.snapPitch(61), 61);
  });
}
