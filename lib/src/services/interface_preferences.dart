part of '../services.dart';

/// Built-in color presets carried from blenderapp's interface-theme presets.
///
/// Applications can still provide a custom [BlenderThemeData] as their base
/// theme. This preference only selects the portable Blender Dark or Blender
/// Light palette layered over that base theme.
enum BlenderThemePreset { dark, light }

/// Blender-style outline thickness preference.
///
/// Blender stores this as an offset from the DPI-derived line width. Flutter
/// does not expose that runtime pixel size, so BlenderUI applies the same
/// intent as a multiplier to its outline widths.
enum BlenderInterfaceLineWidth { thin, automatic, thick }

/// Portable color-picker presentations shared by editor applications.
enum BlenderColorPickerType {
  circleHsv,
  circleHsl,
  squareSv,
  squareHs,
  squareHv,
}

/// How normalized factor values should be presented to people.
enum BlenderFactorDisplayType { factor, percentage }

/// Immutable, app-wide interface preferences inspired by blenderapp's
/// `PreferencesView` settings.
///
/// This intentionally contains only settings that can be meaningful to a
/// broad editor application. Domain concerns such as 3D viewport overlays,
/// scene memory statistics, and add-on discovery remain app-owned.
@immutable
class BlenderInterfacePreferences {
  const BlenderInterfacePreferences({
    this.theme = BlenderThemePreset.dark,
    this.uiScale = 1,
    this.lineWidth = BlenderInterfaceLineWidth.automatic,
    this.showSplash = true,
    this.showTooltips = true,
    this.showDeveloperExtras = false,
    this.useRegionOverlap = true,
    this.showCornerHandles = false,
    this.showNumericInputArrows = false,
    this.showNavigationControls = true,
    this.borderWidth = 2,
    this.colorPickerType = BlenderColorPickerType.circleHsv,
    this.factorDisplayType = BlenderFactorDisplayType.factor,
  }) : assert(uiScale >= .5 && uiScale <= 6),
       assert(borderWidth >= 1 && borderWidth <= 10);

  final BlenderThemePreset theme;
  final double uiScale;
  final BlenderInterfaceLineWidth lineWidth;
  final bool showSplash;
  final bool showTooltips;
  final bool showDeveloperExtras;
  final bool useRegionOverlap;
  final bool showCornerHandles;
  final bool showNumericInputArrows;
  final bool showNavigationControls;
  final double borderWidth;
  final BlenderColorPickerType colorPickerType;
  final BlenderFactorDisplayType factorDisplayType;

  BlenderInterfacePreferences copyWith({
    BlenderThemePreset? theme,
    double? uiScale,
    BlenderInterfaceLineWidth? lineWidth,
    bool? showSplash,
    bool? showTooltips,
    bool? showDeveloperExtras,
    bool? useRegionOverlap,
    bool? showCornerHandles,
    bool? showNumericInputArrows,
    bool? showNavigationControls,
    double? borderWidth,
    BlenderColorPickerType? colorPickerType,
    BlenderFactorDisplayType? factorDisplayType,
  }) {
    return BlenderInterfacePreferences(
      theme: theme ?? this.theme,
      uiScale: (uiScale ?? this.uiScale).clamp(.5, 6).toDouble(),
      lineWidth: lineWidth ?? this.lineWidth,
      showSplash: showSplash ?? this.showSplash,
      showTooltips: showTooltips ?? this.showTooltips,
      showDeveloperExtras: showDeveloperExtras ?? this.showDeveloperExtras,
      useRegionOverlap: useRegionOverlap ?? this.useRegionOverlap,
      showCornerHandles: showCornerHandles ?? this.showCornerHandles,
      showNumericInputArrows:
          showNumericInputArrows ?? this.showNumericInputArrows,
      showNavigationControls:
          showNavigationControls ?? this.showNavigationControls,
      borderWidth: (borderWidth ?? this.borderWidth).clamp(1, 10).toDouble(),
      colorPickerType: colorPickerType ?? this.colorPickerType,
      factorDisplayType: factorDisplayType ?? this.factorDisplayType,
    );
  }

  Map<String, Object> toJson() => <String, Object>{
    'version': 1,
    'theme': theme.name,
    'uiScale': uiScale,
    'lineWidth': lineWidth.name,
    'showSplash': showSplash,
    'showTooltips': showTooltips,
    'showDeveloperExtras': showDeveloperExtras,
    'useRegionOverlap': useRegionOverlap,
    'showCornerHandles': showCornerHandles,
    'showNumericInputArrows': showNumericInputArrows,
    'showNavigationControls': showNavigationControls,
    'borderWidth': borderWidth,
    'colorPickerType': colorPickerType.name,
    'factorDisplayType': factorDisplayType.name,
  };

  static BlenderInterfacePreferences? fromJson(Object? value) {
    if (value is! Map<Object?, Object?> || value['version'] != 1) return null;
    final theme = _enumByName(BlenderThemePreset.values, value['theme']);
    final lineWidth = _enumByName(
      BlenderInterfaceLineWidth.values,
      value['lineWidth'],
    );
    final picker = _enumByName(
      BlenderColorPickerType.values,
      value['colorPickerType'],
    );
    final factor = _enumByName(
      BlenderFactorDisplayType.values,
      value['factorDisplayType'],
    );
    final uiScale = value['uiScale'];
    final borderWidth = value['borderWidth'];
    if (theme == null ||
        lineWidth == null ||
        picker == null ||
        factor == null ||
        uiScale is! num ||
        borderWidth is! num) {
      return null;
    }
    bool readBool(String key, bool fallback) =>
        value[key] is bool ? value[key]! as bool : fallback;
    return BlenderInterfacePreferences(
      theme: theme,
      uiScale: uiScale.toDouble().clamp(.5, 6).toDouble(),
      lineWidth: lineWidth,
      showSplash: readBool('showSplash', true),
      showTooltips: readBool('showTooltips', true),
      showDeveloperExtras: readBool('showDeveloperExtras', false),
      useRegionOverlap: readBool('useRegionOverlap', true),
      showCornerHandles: readBool('showCornerHandles', false),
      showNumericInputArrows: readBool('showNumericInputArrows', false),
      showNavigationControls: readBool('showNavigationControls', true),
      borderWidth: borderWidth.toDouble().clamp(1, 10).toDouble(),
      colorPickerType: picker,
      factorDisplayType: factor,
    );
  }

  static T? _enumByName<T extends Enum>(Iterable<T> values, Object? value) {
    if (value is! String) return null;
    for (final candidate in values) {
      if (candidate.name == value) return candidate;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is BlenderInterfacePreferences &&
      other.theme == theme &&
      other.uiScale == uiScale &&
      other.lineWidth == lineWidth &&
      other.showSplash == showSplash &&
      other.showTooltips == showTooltips &&
      other.showDeveloperExtras == showDeveloperExtras &&
      other.useRegionOverlap == useRegionOverlap &&
      other.showCornerHandles == showCornerHandles &&
      other.showNumericInputArrows == showNumericInputArrows &&
      other.showNavigationControls == showNavigationControls &&
      other.borderWidth == borderWidth &&
      other.colorPickerType == colorPickerType &&
      other.factorDisplayType == factorDisplayType;

  @override
  int get hashCode => Object.hash(
    theme,
    uiScale,
    lineWidth,
    showSplash,
    showTooltips,
    showDeveloperExtras,
    useRegionOverlap,
    showCornerHandles,
    showNumericInputArrows,
    showNavigationControls,
    borderWidth,
    colorPickerType,
    factorDisplayType,
  );
}

/// Optional storage adapter for [BlenderInterfacePreferencesService].
class BlenderInterfacePreferencesPersistence {
  const BlenderInterfacePreferencesPersistence({
    required this.storage,
    this.storageKey = 'blenderui.interface-preferences',
  });

  final BlenderPersistentStorage storage;
  final String storageKey;
}

/// Observable, persistable interface preferences shared across an app.
///
/// The service is intentionally app-scoped rather than global. Hosts choose
/// their own storage implementation and may register the service in a
/// [BlenderApplicationController] or use it around a smaller window subtree.
class BlenderInterfacePreferencesService extends ChangeNotifier
    implements BlenderServiceDisposable {
  BlenderInterfacePreferencesService({
    BlenderInterfacePreferences initial = const BlenderInterfacePreferences(),
    this.persistence,
  }) : _value = initial {
    final persistence = this.persistence;
    if (persistence != null) {
      _persistenceCoordinator = BlenderPersistenceCoordinator(
        storage: persistence.storage,
        storageKey: persistence.storageKey,
        serialize: () => jsonEncode(_value.toJson()),
      );
    }
  }

  final BlenderInterfacePreferencesPersistence? persistence;
  BlenderInterfacePreferences _value;
  BlenderPersistenceCoordinator? _persistenceCoordinator;
  bool _disposed = false;

  BlenderInterfacePreferences get value => _value;
  Object? get lastPersistenceError => _persistenceCoordinator?.lastError;

  bool replace(BlenderInterfacePreferences next) {
    if (_value == next) return false;
    _value = next;
    notifyListeners();
    _scheduleWrite();
    return true;
  }

  bool update(
    BlenderInterfacePreferences Function(BlenderInterfacePreferences value)
    change,
  ) => replace(change(_value));

  Future<bool> restore() {
    final coordinator = _persistenceCoordinator;
    if (coordinator == null) return Future<bool>.value(false);
    return coordinator.restore((raw) {
      final restored = BlenderInterfacePreferences.fromJson(jsonDecode(raw));
      if (restored == null) return false;
      _value = restored;
      notifyListeners();
      return true;
    });
  }

  Future<void> flush() =>
      _persistenceCoordinator?.flush() ?? Future<void>.value();

  Future<void> clearPersistedPreferences() =>
      _persistenceCoordinator?.clear() ?? Future<void>.value();

  void _scheduleWrite() => _persistenceCoordinator?.scheduleWrite();

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    final coordinator = _persistenceCoordinator;
    if (coordinator != null) unawaited(coordinator.dispose());
    super.dispose();
  }
}
