import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:xml/xml.dart';

import 'services.dart';
import 'theme.dart';

/// The portable color tokens BlenderUI can read from and write to a Blender
/// interface-theme XML preset.
///
/// Blender presets contain many editor-specific colors. These roles cover the
/// `ThemeUserInterface` and widget colors that BlenderUI itself renders; other
/// Blender-only regions are deliberately ignored rather than misapplied.
enum BlenderThemeColorRole {
  canvas,
  surface,
  surfaceElevated,
  surfaceRaised,
  border,
  borderSubtle,
  foreground,
  foregroundMuted,
  foregroundDisabled,
  accent,
  accentHover,
  selection,
  focus,
  button,
  buttonHover,
  buttonPressed,
  buttonSelected,
  textField,
  topBar,
  menuBackground,
  menuSelection,
  propertiesBackground,
  panelHeader,
  panelBackground,
  panelSubSurface,
  panelOutline,
  tab,
  tabSelected,
  tabText,
  tabTextSelected,
  editorBorder,
  editorOutline,
  editorOutlineActive,
  link,
  cursor,
  warning,
  error,
  success,
}

extension BlenderThemeColorRolePresentation on BlenderThemeColorRole {
  String get label => switch (this) {
    BlenderThemeColorRole.canvas => 'Editor Background',
    BlenderThemeColorRole.surface => 'Surface',
    BlenderThemeColorRole.surfaceElevated => 'Raised Surface',
    BlenderThemeColorRole.surfaceRaised => 'Active Surface',
    BlenderThemeColorRole.border => 'Border',
    BlenderThemeColorRole.borderSubtle => 'Widget Outline',
    BlenderThemeColorRole.foreground => 'Text',
    BlenderThemeColorRole.foregroundMuted => 'Muted Text',
    BlenderThemeColorRole.foregroundDisabled => 'Disabled Text',
    BlenderThemeColorRole.accent => 'Accent',
    BlenderThemeColorRole.accentHover => 'Accent Hover',
    BlenderThemeColorRole.selection => 'Selection',
    BlenderThemeColorRole.focus => 'Focus',
    BlenderThemeColorRole.button => 'Button',
    BlenderThemeColorRole.buttonHover => 'Button Hover',
    BlenderThemeColorRole.buttonPressed => 'Button Pressed',
    BlenderThemeColorRole.buttonSelected => 'Button Selected',
    BlenderThemeColorRole.textField => 'Text Field',
    BlenderThemeColorRole.topBar => 'Top Bar',
    BlenderThemeColorRole.menuBackground => 'Menu Background',
    BlenderThemeColorRole.menuSelection => 'Menu Selection',
    BlenderThemeColorRole.propertiesBackground => 'Properties Background',
    BlenderThemeColorRole.panelHeader => 'Panel Header',
    BlenderThemeColorRole.panelBackground => 'Panel Background',
    BlenderThemeColorRole.panelSubSurface => 'Panel Subsurface',
    BlenderThemeColorRole.panelOutline => 'Panel Outline',
    BlenderThemeColorRole.tab => 'Tab',
    BlenderThemeColorRole.tabSelected => 'Selected Tab',
    BlenderThemeColorRole.tabText => 'Tab Text',
    BlenderThemeColorRole.tabTextSelected => 'Selected Tab Text',
    BlenderThemeColorRole.editorBorder => 'Editor Border',
    BlenderThemeColorRole.editorOutline => 'Editor Outline',
    BlenderThemeColorRole.editorOutlineActive => 'Active Editor Outline',
    BlenderThemeColorRole.link => 'Link',
    BlenderThemeColorRole.cursor => 'Text Cursor',
    BlenderThemeColorRole.warning => 'Warning',
    BlenderThemeColorRole.error => 'Error',
    BlenderThemeColorRole.success => 'Success',
  };

  String get token => name;
}

/// A named BlenderUI theme, either built in or created/imported by the user.
@immutable
class BlenderThemeDefinition {
  const BlenderThemeDefinition({
    required this.id,
    required this.name,
    required this.colors,
    this.isBuiltIn = false,
    this.sourceFileName,
  });

  final String id;
  final String name;
  final BlenderColorScheme colors;
  final bool isBuiltIn;
  final String? sourceFileName;

  BlenderThemeData get data => BlenderThemeData(colors: colors);

  Color colorFor(BlenderThemeColorRole role) => switch (role) {
    BlenderThemeColorRole.canvas => colors.canvas,
    BlenderThemeColorRole.surface => colors.surface,
    BlenderThemeColorRole.surfaceElevated => colors.surfaceElevated,
    BlenderThemeColorRole.surfaceRaised => colors.surfaceRaised,
    BlenderThemeColorRole.border => colors.border,
    BlenderThemeColorRole.borderSubtle => colors.borderSubtle,
    BlenderThemeColorRole.foreground => colors.foreground,
    BlenderThemeColorRole.foregroundMuted => colors.foregroundMuted,
    BlenderThemeColorRole.foregroundDisabled => colors.foregroundDisabled,
    BlenderThemeColorRole.accent => colors.accent,
    BlenderThemeColorRole.accentHover => colors.accentHover,
    BlenderThemeColorRole.selection => colors.selection,
    BlenderThemeColorRole.focus => colors.focus,
    BlenderThemeColorRole.button => colors.button,
    BlenderThemeColorRole.buttonHover => colors.buttonHover,
    BlenderThemeColorRole.buttonPressed => colors.buttonPressed,
    BlenderThemeColorRole.buttonSelected => colors.buttonSelected,
    BlenderThemeColorRole.textField => colors.textField,
    BlenderThemeColorRole.topBar => colors.topBar,
    BlenderThemeColorRole.menuBackground => colors.menuBackground,
    BlenderThemeColorRole.menuSelection => colors.menuSelection,
    BlenderThemeColorRole.propertiesBackground => colors.propertiesBackground,
    BlenderThemeColorRole.panelHeader => colors.panelHeader,
    BlenderThemeColorRole.panelBackground => colors.panelBackground,
    BlenderThemeColorRole.panelSubSurface => colors.panelSubSurface,
    BlenderThemeColorRole.panelOutline => colors.panelOutline,
    BlenderThemeColorRole.tab => colors.tab,
    BlenderThemeColorRole.tabSelected => colors.tabSelected,
    BlenderThemeColorRole.tabText => colors.tabText,
    BlenderThemeColorRole.tabTextSelected => colors.tabTextSelected,
    BlenderThemeColorRole.editorBorder => colors.editorBorder,
    BlenderThemeColorRole.editorOutline => colors.editorOutline,
    BlenderThemeColorRole.editorOutlineActive => colors.editorOutlineActive,
    BlenderThemeColorRole.link => colors.link,
    BlenderThemeColorRole.cursor => colors.cursor,
    BlenderThemeColorRole.warning => colors.warning,
    BlenderThemeColorRole.error => colors.error,
    BlenderThemeColorRole.success => colors.success,
  };

  BlenderThemeDefinition copyWith({
    String? id,
    String? name,
    BlenderColorScheme? colors,
    bool? isBuiltIn,
    String? sourceFileName,
  }) => BlenderThemeDefinition(
    id: id ?? this.id,
    name: name ?? this.name,
    colors: colors ?? this.colors,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    sourceFileName: sourceFileName ?? this.sourceFileName,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'name': name,
    'sourceFileName': sourceFileName,
    'colors': <String, String>{
      for (final role in BlenderThemeColorRole.values)
        role.token: _encodeColor(colorFor(role)),
    },
  };

  static BlenderThemeDefinition? fromJson(Object? value) {
    if (value is! Map<Object?, Object?> ||
        value['id'] is! String ||
        value['name'] is! String ||
        value['colors'] is! Map<Object?, Object?>) {
      return null;
    }
    final colorJson = value['colors']! as Map<Object?, Object?>;
    final values = <BlenderThemeColorRole, Color>{};
    for (final role in BlenderThemeColorRole.values) {
      final color = _decodeColor(colorJson[role.token]);
      if (color != null) values[role] = color;
    }
    return BlenderThemeDefinition(
      id: value['id']! as String,
      name: value['name']! as String,
      colors: _colorsFromValues(values, const BlenderColorScheme.dark()),
      sourceFileName: value['sourceFileName'] as String?,
    );
  }
}

/// Storage contract for user-created BlenderUI themes.
class BlenderThemePersistence {
  const BlenderThemePersistence({
    required this.storage,
    this.storageKey = 'blenderui.themes',
  });

  final BlenderPersistentStorage storage;
  final String storageKey;
}

/// Raised when an XML file is not a usable Blender theme preset.
class BlenderThemeXmlException implements Exception {
  const BlenderThemeXmlException(this.message);

  final String message;

  @override
  String toString() => 'BlenderThemeXmlException: $message';
}

/// Parses and writes Blender's XML interface-theme format for BlenderUI's
/// portable UI and widget palette.
class BlenderThemeXmlCodec {
  const BlenderThemeXmlCodec();

  BlenderThemeDefinition decode(
    String xml, {
    required String id,
    String? name,
    BlenderColorScheme fallback = const BlenderColorScheme.dark(),
  }) {
    if (xml.length > 1024 * 1024) {
      throw const BlenderThemeXmlException('Theme XML exceeds 1 MiB.');
    }
    final XmlDocument document;
    try {
      document = XmlDocument.parse(xml);
    } on XmlException catch (error) {
      throw BlenderThemeXmlException('Invalid Blender theme XML: $error');
    }
    final bpy = document.rootElement;
    if (bpy.name.local != 'bpy') {
      throw const BlenderThemeXmlException('Expected a <bpy> root element.');
    }
    final theme = _first(document, 'Theme');
    if (theme == null) {
      throw const BlenderThemeXmlException(
        'Expected a Blender <Theme> element.',
      );
    }
    final values = <BlenderThemeColorRole, Color>{};
    void read(
      XmlElement? element,
      Map<String, BlenderThemeColorRole> attributes,
    ) {
      if (element == null) return;
      for (final entry in attributes.entries) {
        final color = _decodeColor(element.getAttribute(entry.key));
        if (color != null) values[entry.value] = color;
      }
    }

    final ui = _first(theme, 'ThemeUserInterface');
    read(ui, const <String, BlenderThemeColorRole>{
      'editor_border': BlenderThemeColorRole.editorBorder,
      'editor_outline': BlenderThemeColorRole.editorOutline,
      'editor_outline_active': BlenderThemeColorRole.editorOutlineActive,
      'widget_text_cursor': BlenderThemeColorRole.cursor,
      'link': BlenderThemeColorRole.link,
      'panel_header': BlenderThemeColorRole.panelHeader,
      'panel_back': BlenderThemeColorRole.panelBackground,
      'panel_sub_back': BlenderThemeColorRole.panelSubSurface,
      'panel_outline': BlenderThemeColorRole.panelOutline,
    });
    read(_widget(ui, 'wcol_regular'), const <String, BlenderThemeColorRole>{
      'outline': BlenderThemeColorRole.borderSubtle,
      'inner': BlenderThemeColorRole.button,
      'inner_sel': BlenderThemeColorRole.buttonSelected,
      'text': BlenderThemeColorRole.foreground,
    });
    read(_widget(ui, 'wcol_text'), const <String, BlenderThemeColorRole>{
      'inner': BlenderThemeColorRole.textField,
      'text': BlenderThemeColorRole.foreground,
    });
    read(_widget(ui, 'wcol_menu_back'), const <String, BlenderThemeColorRole>{
      'inner': BlenderThemeColorRole.menuBackground,
      'inner_sel': BlenderThemeColorRole.menuSelection,
      'text': BlenderThemeColorRole.foregroundMuted,
    });
    read(_widget(ui, 'wcol_tab'), const <String, BlenderThemeColorRole>{
      'inner': BlenderThemeColorRole.tab,
      'inner_sel': BlenderThemeColorRole.tabSelected,
      'text': BlenderThemeColorRole.tabText,
      'text_sel': BlenderThemeColorRole.tabTextSelected,
    });
    read(_widget(ui, 'wcol_list_item'), const <String, BlenderThemeColorRole>{
      'inner_sel': BlenderThemeColorRole.selection,
    });
    read(_widget(ui, 'wcol_state'), const <String, BlenderThemeColorRole>{
      'warning': BlenderThemeColorRole.warning,
      'error': BlenderThemeColorRole.error,
      'success': BlenderThemeColorRole.success,
    });
    final preferences = _first(theme, 'ThemePreferences');
    read(preferences, const <String, BlenderThemeColorRole>{
      'back': BlenderThemeColorRole.canvas,
      'title': BlenderThemeColorRole.foreground,
    });
    final properties = _first(theme, 'ThemeProperties');
    if (properties != null) {
      read(
        _first(properties, 'ThemeSpaceGeneric'),
        const <String, BlenderThemeColorRole>{
          'back': BlenderThemeColorRole.propertiesBackground,
        },
      );
    }
    final topBar = _first(theme, 'ThemeTopBar');
    if (topBar != null) {
      read(
        _first(topBar, 'ThemeSpaceGeneric'),
        const <String, BlenderThemeColorRole>{
          'back': BlenderThemeColorRole.topBar,
        },
      );
    }
    final resolvedName = name ?? theme.getAttribute('name') ?? 'Imported Theme';
    return BlenderThemeDefinition(
      id: id,
      name: resolvedName,
      colors: _colorsFromValues(values, fallback),
    );
  }

  String encode(BlenderThemeDefinition theme) {
    String color(BlenderThemeColorRole role) =>
        _encodeColor(theme.colorFor(role));
    return '''<bpy>
  <Theme name="${_escape(theme.name)}">
    <user_interface>
      <ThemeUserInterface editor_border="${color(BlenderThemeColorRole.editorBorder)}" editor_outline="${color(BlenderThemeColorRole.editorOutline)}" editor_outline_active="${color(BlenderThemeColorRole.editorOutlineActive)}" widget_text_cursor="${color(BlenderThemeColorRole.cursor)}" link="${color(BlenderThemeColorRole.link)}" panel_header="${color(BlenderThemeColorRole.panelHeader)}" panel_back="${color(BlenderThemeColorRole.panelBackground)}" panel_sub_back="${color(BlenderThemeColorRole.panelSubSurface)}" panel_outline="${color(BlenderThemeColorRole.panelOutline)}">
        <wcol_regular><ThemeWidgetColors outline="${color(BlenderThemeColorRole.borderSubtle)}" inner="${color(BlenderThemeColorRole.button)}" inner_sel="${color(BlenderThemeColorRole.buttonSelected)}" text="${color(BlenderThemeColorRole.foreground)}" text_sel="#FFFFFFFF" /></wcol_regular>
        <wcol_text><ThemeWidgetColors inner="${color(BlenderThemeColorRole.textField)}" text="${color(BlenderThemeColorRole.foreground)}" /></wcol_text>
        <wcol_toolbar_item><ThemeWidgetColors inner="${color(BlenderThemeColorRole.topBar)}" /></wcol_toolbar_item>
        <wcol_menu_back><ThemeWidgetColors inner="${color(BlenderThemeColorRole.menuBackground)}" inner_sel="${color(BlenderThemeColorRole.menuSelection)}" text="${color(BlenderThemeColorRole.foregroundMuted)}" /></wcol_menu_back>
        <wcol_tab><ThemeWidgetColors inner="${color(BlenderThemeColorRole.tab)}" inner_sel="${color(BlenderThemeColorRole.tabSelected)}" text="${color(BlenderThemeColorRole.tabText)}" text_sel="${color(BlenderThemeColorRole.tabTextSelected)}" /></wcol_tab>
        <wcol_list_item><ThemeWidgetColors inner_sel="${color(BlenderThemeColorRole.selection)}" /></wcol_list_item>
        <wcol_state><ThemeWidgetStateColors warning="${color(BlenderThemeColorRole.warning)}" error="${color(BlenderThemeColorRole.error)}" success="${color(BlenderThemeColorRole.success)}" /></wcol_state>
      </ThemeUserInterface>
    </user_interface>
    <preferences><ThemePreferences back="${color(BlenderThemeColorRole.canvas)}" /></preferences>
    <properties>
      <ThemeProperties><space><ThemeSpaceGeneric back="${color(BlenderThemeColorRole.propertiesBackground)}" /></space></ThemeProperties>
    </properties>
    <topbar>
      <ThemeTopBar><space><ThemeSpaceGeneric back="${color(BlenderThemeColorRole.topBar)}" /></space></ThemeTopBar>
    </topbar>
  </Theme>
  <ThemeStyle />
</bpy>
''';
  }

  static XmlElement? _first(XmlNode root, String localName) {
    for (final element in root.descendants.whereType<XmlElement>()) {
      if (element.name.local == localName) return element;
    }
    return null;
  }

  static XmlElement? _widget(XmlElement? ui, String container) {
    if (ui == null) return null;
    for (final child in ui.childElements) {
      if (child.name.local != container) continue;
      return _first(child, 'ThemeWidgetColors') ??
          _first(child, 'ThemeWidgetStateColors');
    }
    return null;
  }

  static String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

/// App-scoped registry, editor state, and persistence for Blender themes.
class BlenderThemeService extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderThemeService({
    this.persistence,
    List<BlenderThemeDefinition>? builtIns,
    String selectedThemeId = 'blender-dark',
  }) : _themes = <BlenderThemeDefinition>[...(builtIns ?? _defaultThemes)],
       _selectedThemeId = selectedThemeId;

  static const List<BlenderThemeDefinition> _defaultThemes =
      <BlenderThemeDefinition>[
        BlenderThemeDefinition(
          id: 'blender-dark',
          name: 'Blender Dark',
          colors: BlenderColorScheme.dark(),
          isBuiltIn: true,
        ),
        BlenderThemeDefinition(
          id: 'blender-light',
          name: 'Blender Light',
          colors: BlenderColorScheme.light(),
          isBuiltIn: true,
        ),
      ];

  final BlenderThemePersistence? persistence;
  final List<BlenderThemeDefinition> _themes;
  String _selectedThemeId;
  Future<bool>? _restoreFuture;
  Future<void> _pendingWrite = Future<void>.value();
  bool _writeScheduled = false;
  bool _disposed = false;
  Object? lastPersistenceError;

  List<BlenderThemeDefinition> get themes =>
      List<BlenderThemeDefinition>.unmodifiable(_themes);
  String get selectedThemeId => _selectedThemeId;
  BlenderThemeDefinition get activeTheme =>
      _themes.where((theme) => theme.id == _selectedThemeId).firstOrNull ??
      _themes.first;

  bool select(String id) {
    if (!_themes.any((theme) => theme.id == id) || _selectedThemeId == id) {
      return false;
    }
    _selectedThemeId = id;
    _changed();
    return true;
  }

  BlenderThemeDefinition create({String name = 'Custom Theme'}) {
    final theme = activeTheme;
    final definition = BlenderThemeDefinition(
      id: _nextId('custom-theme'),
      name: _uniqueName(name),
      colors: theme.colors,
    );
    _themes.add(definition);
    _selectedThemeId = definition.id;
    _changed();
    return definition;
  }

  bool removeActive() {
    final active = activeTheme;
    if (active.isBuiltIn) return false;
    _themes.removeWhere((theme) => theme.id == active.id);
    _selectedThemeId = 'blender-dark';
    _changed();
    return true;
  }

  void resetToDefault() {
    _selectedThemeId = 'blender-dark';
    _changed();
  }

  void renameActive(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) return;
    _replaceActive(
      (theme) =>
          theme.copyWith(name: _uniqueName(normalized, except: theme.id)),
    );
  }

  void updateActiveColor(BlenderThemeColorRole role, Color color) {
    _replaceActive(
      (theme) => theme.copyWith(colors: _setColor(theme.colors, role, color)),
    );
  }

  BlenderThemeDefinition importBlenderXml(
    String xml, {
    String? name,
    String? sourceFileName,
  }) {
    const codec = BlenderThemeXmlCodec();
    final definition = codec
        .decode(
          xml,
          id: _nextId('imported-theme'),
          name: name,
          fallback: activeTheme.colors,
        )
        .copyWith(sourceFileName: sourceFileName);
    _themes.add(definition);
    _selectedThemeId = definition.id;
    _changed();
    return definition;
  }

  String exportActiveBlenderXml() =>
      const BlenderThemeXmlCodec().encode(activeTheme);

  Future<bool> restore() => _restoreFuture ??= _restore();

  Future<bool> _restore() async {
    final persistence = this.persistence;
    if (persistence == null) return false;
    try {
      final raw = await persistence.storage.read(persistence.storageKey);
      if (raw == null || raw.isEmpty) return false;
      final root = jsonDecode(raw);
      if (root is! Map<Object?, Object?> || root['version'] != 1) return false;
      final themes = root['themes'];
      if (themes is! List<Object?> || root['selectedThemeId'] is! String)
        return false;
      final restored = themes
          .map(BlenderThemeDefinition.fromJson)
          .whereType<BlenderThemeDefinition>()
          .toList();
      if (restored.length != themes.length) return false;
      _themes.removeWhere((theme) => !theme.isBuiltIn);
      _themes.addAll(restored);
      _selectedThemeId = root['selectedThemeId'] as String;
      if (!_themes.any((theme) => theme.id == _selectedThemeId)) {
        _selectedThemeId = 'blender-dark';
      }
      lastPersistenceError = null;
      notifyListeners();
      return true;
    } catch (error) {
      lastPersistenceError = error;
      return false;
    }
  }

  Future<void> flush() {
    final persistence = this.persistence;
    if (persistence == null) return Future<void>.value();
    _writeScheduled = false;
    _pendingWrite = _pendingWrite.then((_) async {
      try {
        await persistence.storage.write(
          persistence.storageKey,
          jsonEncode(<String, Object?>{
            'version': 1,
            'selectedThemeId': _selectedThemeId,
            'themes': <Map<String, Object?>>[
              for (final theme in _themes)
                if (!theme.isBuiltIn) theme.toJson(),
            ],
          }),
        );
        lastPersistenceError = null;
      } catch (error) {
        lastPersistenceError = error;
      }
    });
    return _pendingWrite;
  }

  void _replaceActive(
    BlenderThemeDefinition Function(BlenderThemeDefinition theme) change,
  ) {
    final active = activeTheme;
    final index = _themes.indexOf(active);
    if (active.isBuiltIn) {
      final copy = BlenderThemeDefinition(
        id: _nextId('custom-theme'),
        name: _uniqueName('${active.name} Custom'),
        colors: active.colors,
      );
      _themes.add(copy);
      _selectedThemeId = copy.id;
      _themes[_themes.length - 1] = change(copy);
    } else {
      _themes[index] = change(active);
    }
    _changed();
  }

  void _changed() {
    notifyListeners();
    if (_disposed || persistence == null || _writeScheduled) return;
    _writeScheduled = true;
    scheduleMicrotask(() {
      if (_disposed || !_writeScheduled) return;
      unawaited(flush());
    });
  }

  String _nextId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_themes.length}';

  String _uniqueName(String candidate, {String? except}) {
    final names = <String>{
      for (final theme in _themes)
        if (theme.id != except) theme.name.toLowerCase(),
    };
    if (!names.contains(candidate.toLowerCase())) return candidate;
    var index = 2;
    while (names.contains('$candidate $index'.toLowerCase())) {
      index++;
    }
    return '$candidate $index';
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(flush());
    super.dispose();
  }
}

Color? _decodeColor(Object? source) {
  if (source is! String || !source.startsWith('#')) return null;
  final value = source.substring(1);
  if (value.length != 6 && value.length != 8) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  final rgba = value.length == 6 ? (parsed << 8) | 0xFF : parsed;
  return Color.fromARGB(
    rgba & 0xFF,
    (rgba >> 24) & 0xFF,
    (rgba >> 16) & 0xFF,
    (rgba >> 8) & 0xFF,
  );
}

String _encodeColor(Color color) {
  final value = color.toARGB32();
  final rgba = ((value & 0x00FFFFFF) << 8) | ((value >> 24) & 0xFF);
  return '#${rgba.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

BlenderColorScheme _colorsFromValues(
  Map<BlenderThemeColorRole, Color> values,
  BlenderColorScheme fallback,
) => fallback.copyWith(
  canvas: values[BlenderThemeColorRole.canvas],
  surface: values[BlenderThemeColorRole.surface],
  surfaceElevated: values[BlenderThemeColorRole.surfaceElevated],
  surfaceRaised: values[BlenderThemeColorRole.surfaceRaised],
  border: values[BlenderThemeColorRole.border],
  borderSubtle: values[BlenderThemeColorRole.borderSubtle],
  foreground: values[BlenderThemeColorRole.foreground],
  foregroundMuted: values[BlenderThemeColorRole.foregroundMuted],
  foregroundDisabled: values[BlenderThemeColorRole.foregroundDisabled],
  accent: values[BlenderThemeColorRole.accent],
  accentHover: values[BlenderThemeColorRole.accentHover],
  selection: values[BlenderThemeColorRole.selection],
  focus: values[BlenderThemeColorRole.focus],
  button: values[BlenderThemeColorRole.button],
  buttonHover: values[BlenderThemeColorRole.buttonHover],
  buttonPressed: values[BlenderThemeColorRole.buttonPressed],
  buttonSelected: values[BlenderThemeColorRole.buttonSelected],
  textField: values[BlenderThemeColorRole.textField],
  topBar: values[BlenderThemeColorRole.topBar],
  menuBackground: values[BlenderThemeColorRole.menuBackground],
  menuSelection: values[BlenderThemeColorRole.menuSelection],
  propertiesBackground: values[BlenderThemeColorRole.propertiesBackground],
  panelHeader: values[BlenderThemeColorRole.panelHeader],
  panelBackground: values[BlenderThemeColorRole.panelBackground],
  panelSubSurface: values[BlenderThemeColorRole.panelSubSurface],
  panelOutline: values[BlenderThemeColorRole.panelOutline],
  tab: values[BlenderThemeColorRole.tab],
  tabSelected: values[BlenderThemeColorRole.tabSelected],
  tabText: values[BlenderThemeColorRole.tabText],
  tabTextSelected: values[BlenderThemeColorRole.tabTextSelected],
  editorBorder: values[BlenderThemeColorRole.editorBorder],
  editorOutline: values[BlenderThemeColorRole.editorOutline],
  editorOutlineActive: values[BlenderThemeColorRole.editorOutlineActive],
  link: values[BlenderThemeColorRole.link],
  cursor: values[BlenderThemeColorRole.cursor],
  warning: values[BlenderThemeColorRole.warning],
  error: values[BlenderThemeColorRole.error],
  success: values[BlenderThemeColorRole.success],
);

BlenderColorScheme _setColor(
  BlenderColorScheme colors,
  BlenderThemeColorRole role,
  Color color,
) => _colorsFromValues(<BlenderThemeColorRole, Color>{role: color}, colors);
