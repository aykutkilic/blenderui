part of '../services.dart';

/// The event families represented by Blender's keymap editor.
enum BlenderKeymapEventType { keyboard, mouse, textInput, timer, ndof }

/// Whether Preferences searches operator names or key event descriptions.
enum BlenderKeymapFilterType { name, keyBinding }

/// Portable codec for the keyboard subset Flutter can dispatch through
/// [Shortcuts]. Other Blender event families remain expressible as metadata on
/// [BlenderCommandBinding] and can be dispatched by editor-specific handlers.
abstract final class BlenderShortcutCodec {
  static Map<String, Object?>? encode(ShortcutActivator activator) {
    if (activator is! SingleActivator) return null;
    return <String, Object?>{
      'keyId': activator.trigger.keyId,
      'keyLabel': activator.trigger.keyLabel,
      'control': activator.control,
      'shift': activator.shift,
      'alt': activator.alt,
      'meta': activator.meta,
    };
  }

  static SingleActivator? decode(Object? value) {
    if (value is! Map) return null;
    final keyId = value['keyId'];
    if (keyId is! int) return null;
    return SingleActivator(
      LogicalKeyboardKey(keyId),
      control: value['control'] == true,
      shift: value['shift'] == true,
      alt: value['alt'] == true,
      meta: value['meta'] == true,
    );
  }

  static String label(ShortcutActivator activator) {
    if (activator is! SingleActivator) return activator.toString();
    final parts = <String>[
      if (activator.control) 'Ctrl',
      if (activator.alt)
        defaultTargetPlatform == TargetPlatform.macOS ? 'Option' : 'Alt',
      if (activator.shift) 'Shift',
      if (activator.meta)
        defaultTargetPlatform == TargetPlatform.macOS ? 'Cmd' : 'OS',
    ];
    final key = activator.trigger.keyLabel.trim();
    parts.add(
      key.isEmpty ? 'Key ${activator.trigger.keyId}' : key.toUpperCase(),
    );
    return parts.join(' ');
  }

  /// Flutter activators intentionally use identity equality. Keymap editing
  /// needs value equality so reconstructed/imported chords still conflict and
  /// resolve like the originals.
  static bool equivalent(ShortcutActivator a, ShortcutActivator b) {
    if (identical(a, b)) return true;
    if (a is SingleActivator && b is SingleActivator) {
      return a.trigger.keyId == b.trigger.keyId &&
          a.control == b.control &&
          a.shift == b.shift &&
          a.alt == b.alt &&
          a.meta == b.meta &&
          a.numLock == b.numLock &&
          a.includeRepeats == b.includeRepeats;
    }
    return a == b;
  }
}

/// A conflict between two active items in the same dispatch context.
class BlenderKeymapConflict {
  const BlenderKeymapConflict(this.first, this.second);

  final BlenderCommandBinding first;
  final BlenderCommandBinding second;
}

/// Serializable snapshot used by import/export and host persistence.
class BlenderKeymapConfiguration {
  const BlenderKeymapConfiguration({required this.name, required this.items});

  final String name;
  final List<BlenderCommandBinding> items;

  Map<String, Object?> toJson() => <String, Object?>{
    'version': 1,
    'name': name,
    'items': <Object?>[
      for (final item in items)
        if (item.toJson() case final json?) json,
    ],
  };

  String encode() => const JsonEncoder.withIndent('  ').convert(toJson());
}
