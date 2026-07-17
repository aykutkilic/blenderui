import 'package:flutter/widgets.dart';

@immutable
class BlenderColorScheme {
  const BlenderColorScheme({
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceRaised,
    required this.border,
    required this.borderSubtle,
    required this.foreground,
    required this.foregroundMuted,
    required this.foregroundDisabled,
    required this.accent,
    required this.accentHover,
    required this.selection,
    required this.focus,
    required this.warning,
    required this.error,
    required this.success,
    this.info = const Color(0xFF28487D),
    this.button = const Color(0xFF545454),
    this.buttonHover = const Color(0xFF606060),
    this.buttonPressed = const Color(0xFF222222),
    this.buttonSelected = const Color(0xFF4772B3),
    this.textField = const Color(0xFF1D1D1D),
    this.topBar = const Color(0xFF181818),
    this.menuBackground = const Color(0xFF181818),
    this.menuSelection = const Color(0xFF4772B3),
    this.propertiesBackground = const Color(0xFF303030),
    this.panelHeader = const Color(0xFF3D3D3D),
    this.panelBackground = const Color(0xFF3D3D3D),
    this.panelSubSurface = const Color(0x1F000000),
    this.panelOutline = const Color(0x11FFFFFF),
    this.tab = const Color(0xFF1D1D1D),
    this.tabSelected = const Color(0xFF303030),
    this.tabText = const Color(0xFF989898),
    this.tabTextSelected = const Color(0xFFFFFFFF),
    this.editorBorder = const Color(0xFF161616),
    this.editorOutline = const Color(0x15FFFFFF),
    this.editorOutlineActive = const Color(0x2AFFFFFF),
    this.link = const Color(0xFF6FA9E6),
    this.cursor = const Color(0xFF71A8FF),
    this.axisX = const Color(0xFFFF3352),
    this.axisY = const Color(0xFF8BDC00),
    this.axisZ = const Color(0xFF2890FF),
    this.axisW = const Color(0xFFEDBA18),
    this.iconScene = const Color(0xFFCCCCCC),
    this.iconCollection = const Color(0xFFFFFFFF),
    this.iconObject = const Color(0xFFE19658),
    this.iconObjectData = const Color(0xFF00D4A3),
    this.iconModifier = const Color(0xFF74A2FF),
    this.iconShading = const Color(0xFFCC6670),
    this.iconFolder = const Color(0xFFCCAD63),
  });

  const BlenderColorScheme.dark()
    : canvas = const Color(0xFF1D1D1D),
      surface = const Color(0xFF282828),
      surfaceElevated = const Color(0xFF323232),
      surfaceRaised = const Color(0xFF3D3D3D),
      border = const Color(0xFF111111),
      borderSubtle = const Color(0xFF494949),
      foreground = const Color(0xFFE6E6E6),
      foregroundMuted = const Color(0xFFAAAAAA),
      foregroundDisabled = const Color(0xFF666666),
      accent = const Color(0xFF4772B3),
      accentHover = const Color(0xFF5585C4),
      selection = const Color(0xFF4772B3),
      focus = const Color(0xFF71A8FF),
      warning = const Color(0xFFAC8737),
      error = const Color(0xFF991616),
      success = const Color(0xFF188625),
      info = const Color(0xFF28487D),
      button = const Color(0xFF545454),
      buttonHover = const Color(0xFF606060),
      buttonPressed = const Color(0xFF222222),
      buttonSelected = const Color(0xFF4772B3),
      textField = const Color(0xFF1D1D1D),
      topBar = const Color(0xFF181818),
      menuBackground = const Color(0xFF181818),
      menuSelection = const Color(0xFF4772B3),
      propertiesBackground = const Color(0xFF303030),
      panelHeader = const Color(0xFF3D3D3D),
      panelBackground = const Color(0xFF3D3D3D),
      panelSubSurface = const Color(0x1F000000),
      panelOutline = const Color(0x11FFFFFF),
      tab = const Color(0xFF1D1D1D),
      tabSelected = const Color(0xFF303030),
      tabText = const Color(0xFF989898),
      tabTextSelected = const Color(0xFFFFFFFF),
      editorBorder = const Color(0xFF161616),
      editorOutline = const Color(0x15FFFFFF),
      editorOutlineActive = const Color(0x2AFFFFFF),
      link = const Color(0xFF6FA9E6),
      cursor = const Color(0xFF71A8FF),
      axisX = const Color(0xFFFF3352),
      axisY = const Color(0xFF8BDC00),
      axisZ = const Color(0xFF2890FF),
      axisW = const Color(0xFFEDBA18),
      iconScene = const Color(0xFFCCCCCC),
      iconCollection = const Color(0xFFFFFFFF),
      iconObject = const Color(0xFFE19658),
      iconObjectData = const Color(0xFF00D4A3),
      iconModifier = const Color(0xFF74A2FF),
      iconShading = const Color(0xFFCC6670),
      iconFolder = const Color(0xFFCCAD63);

  /// Blender Light, transcribed from blenderapp's
  /// `scripts/presets/interface_theme/Blender_Light.xml` widget palette.
  ///
  /// The original keeps a dark toolbar and tooltip treatment for contrast;
  /// BlenderUI preserves that characteristic rather than using a generic
  /// white Material-style color scheme.
  const BlenderColorScheme.light()
    : canvas = const Color(0xFFB3B3B3),
      surface = const Color(0xFFC0C0C0),
      surfaceElevated = const Color(0xFFCCCCCC),
      surfaceRaised = const Color(0xFFDBDBDB),
      border = const Color(0xFF999999),
      borderSubtle = const Color(0xFFA6A6A6),
      foreground = const Color(0xFF1A1A1A),
      foregroundMuted = const Color(0xFF4D4D4D),
      foregroundDisabled = const Color(0xFF777777),
      accent = const Color(0xFF5680C2),
      accentHover = const Color(0xFF668CCC),
      selection = const Color(0xFF668CCC),
      focus = const Color(0xFF3399E6),
      warning = const Color(0xFFAC8737),
      error = const Color(0xFF991616),
      success = const Color(0xFF188625),
      info = const Color(0xFF28487D),
      button = const Color(0xFFDBDBDB),
      buttonHover = const Color(0xFFE6E6E6),
      buttonPressed = const Color(0xFFC0C0C0),
      buttonSelected = const Color(0xFF5680C2),
      textField = const Color(0xFFF4F4F4),
      // Blender Light's `ThemeTopBar.space.ThemeSpaceGeneric.back`.
      // `wcol_toolbar_item` is intentionally dark in Blender Light, but it
      // styles toolbar items rather than the application/area menu surface.
      topBar = const Color(0xFFB3B3B3),
      menuBackground = const Color(0xFFC0C0C0),
      menuSelection = const Color(0xFF5680C2),
      propertiesBackground = const Color(0xFFB3B3B3),
      panelHeader = const Color(0xFFCCCCCC),
      panelBackground = const Color(0xFFCCCCCC),
      panelSubSurface = const Color(0x1F000000),
      panelOutline = const Color(0x22FFFFFF),
      tab = const Color(0xCC808080),
      tabSelected = const Color(0xFFB3B3B3),
      tabText = const Color(0xFF1A1A1A),
      tabTextSelected = const Color(0xFF000000),
      editorBorder = const Color(0xFF999999),
      editorOutline = const Color(0xFFB3B3B3),
      editorOutlineActive = const Color(0xFFCCCCCC),
      link = const Color(0xFF6FA9E6),
      cursor = const Color(0xFF3399E6),
      axisX = const Color(0xFFFF3352),
      axisY = const Color(0xFF8BDC00),
      axisZ = const Color(0xFF2890FF),
      axisW = const Color(0xFFB47AFF),
      iconScene = const Color(0xFFE6E6E6),
      iconCollection = const Color(0xFFF4F4F4),
      iconObject = const Color(0xFFEE9E5D),
      iconObjectData = const Color(0xFF00D4A3),
      iconModifier = const Color(0xFF84B8FF),
      iconShading = const Color(0xFFEA7581),
      iconFolder = const Color(0xFFE3C16E);

  final Color canvas;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceRaised;
  final Color border;
  final Color borderSubtle;
  final Color foreground;
  final Color foregroundMuted;
  final Color foregroundDisabled;
  final Color accent;
  final Color accentHover;
  final Color selection;
  final Color focus;
  final Color warning;
  final Color error;
  final Color success;
  final Color info;
  final Color button;
  final Color buttonHover;
  final Color buttonPressed;
  final Color buttonSelected;
  final Color textField;
  final Color topBar;
  final Color menuBackground;
  final Color menuSelection;
  final Color propertiesBackground;
  final Color panelHeader;
  final Color panelBackground;
  final Color panelSubSurface;
  final Color panelOutline;
  final Color tab;
  final Color tabSelected;
  final Color tabText;
  final Color tabTextSelected;
  final Color editorBorder;
  final Color editorOutline;
  final Color editorOutlineActive;
  final Color link;
  final Color cursor;
  final Color axisX;
  final Color axisY;
  final Color axisZ;
  final Color axisW;
  final Color iconScene;
  final Color iconCollection;
  final Color iconObject;
  final Color iconObjectData;
  final Color iconModifier;
  final Color iconShading;
  final Color iconFolder;

  BlenderColorScheme copyWith({
    Color? canvas,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceRaised,
    Color? border,
    Color? borderSubtle,
    Color? foreground,
    Color? foregroundMuted,
    Color? foregroundDisabled,
    Color? accent,
    Color? accentHover,
    Color? selection,
    Color? focus,
    Color? warning,
    Color? error,
    Color? success,
    Color? info,
    Color? button,
    Color? buttonHover,
    Color? buttonPressed,
    Color? buttonSelected,
    Color? textField,
    Color? topBar,
    Color? menuBackground,
    Color? menuSelection,
    Color? propertiesBackground,
    Color? panelHeader,
    Color? panelBackground,
    Color? panelSubSurface,
    Color? panelOutline,
    Color? tab,
    Color? tabSelected,
    Color? tabText,
    Color? tabTextSelected,
    Color? editorBorder,
    Color? editorOutline,
    Color? editorOutlineActive,
    Color? link,
    Color? cursor,
    Color? axisX,
    Color? axisY,
    Color? axisZ,
    Color? axisW,
    Color? iconScene,
    Color? iconCollection,
    Color? iconObject,
    Color? iconObjectData,
    Color? iconModifier,
    Color? iconShading,
    Color? iconFolder,
  }) {
    return BlenderColorScheme(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      border: border ?? this.border,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      foreground: foreground ?? this.foreground,
      foregroundMuted: foregroundMuted ?? this.foregroundMuted,
      foregroundDisabled: foregroundDisabled ?? this.foregroundDisabled,
      accent: accent ?? this.accent,
      accentHover: accentHover ?? this.accentHover,
      selection: selection ?? this.selection,
      focus: focus ?? this.focus,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      success: success ?? this.success,
      info: info ?? this.info,
      button: button ?? this.button,
      buttonHover: buttonHover ?? this.buttonHover,
      buttonPressed: buttonPressed ?? this.buttonPressed,
      buttonSelected: buttonSelected ?? this.buttonSelected,
      textField: textField ?? this.textField,
      topBar: topBar ?? this.topBar,
      menuBackground: menuBackground ?? this.menuBackground,
      menuSelection: menuSelection ?? this.menuSelection,
      propertiesBackground: propertiesBackground ?? this.propertiesBackground,
      panelHeader: panelHeader ?? this.panelHeader,
      panelBackground: panelBackground ?? this.panelBackground,
      panelSubSurface: panelSubSurface ?? this.panelSubSurface,
      panelOutline: panelOutline ?? this.panelOutline,
      tab: tab ?? this.tab,
      tabSelected: tabSelected ?? this.tabSelected,
      tabText: tabText ?? this.tabText,
      tabTextSelected: tabTextSelected ?? this.tabTextSelected,
      editorBorder: editorBorder ?? this.editorBorder,
      editorOutline: editorOutline ?? this.editorOutline,
      editorOutlineActive: editorOutlineActive ?? this.editorOutlineActive,
      link: link ?? this.link,
      cursor: cursor ?? this.cursor,
      axisX: axisX ?? this.axisX,
      axisY: axisY ?? this.axisY,
      axisZ: axisZ ?? this.axisZ,
      axisW: axisW ?? this.axisW,
      iconScene: iconScene ?? this.iconScene,
      iconCollection: iconCollection ?? this.iconCollection,
      iconObject: iconObject ?? this.iconObject,
      iconObjectData: iconObjectData ?? this.iconObjectData,
      iconModifier: iconModifier ?? this.iconModifier,
      iconShading: iconShading ?? this.iconShading,
      iconFolder: iconFolder ?? this.iconFolder,
    );
  }
}

@immutable
class BlenderTextTheme {
  const BlenderTextTheme({
    this.body = const TextStyle(
      fontSize: 13,
      height: 1.2,
      shadows: <Shadow>[Shadow(color: Color(0x80000000), offset: Offset(0, 1))],
    ),
    this.label = const TextStyle(
      fontSize: 12,
      height: 1.15,
      shadows: <Shadow>[Shadow(color: Color(0x80000000), offset: Offset(0, 1))],
    ),
    this.caption = const TextStyle(
      fontSize: 11,
      height: 1.1,
      shadows: <Shadow>[Shadow(color: Color(0x80000000), offset: Offset(0, 1))],
    ),
    this.heading = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      shadows: <Shadow>[Shadow(color: Color(0x80000000), offset: Offset(0, 1))],
    ),
    this.panelTitle = const TextStyle(
      fontSize: 11,
      height: 1.2,
      shadows: <Shadow>[Shadow(color: Color(0x80000000), offset: Offset(0, 1))],
    ),
  });

  final TextStyle body;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle heading;
  final TextStyle panelTitle;

  BlenderTextTheme copyWith({
    TextStyle? body,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? heading,
    TextStyle? panelTitle,
  }) {
    return BlenderTextTheme(
      body: body ?? this.body,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      heading: heading ?? this.heading,
      panelTitle: panelTitle ?? this.panelTitle,
    );
  }

  BlenderTextTheme scaled(double factor) {
    TextStyle scale(TextStyle style) =>
        style.copyWith(fontSize: (style.fontSize ?? 14) * factor);
    return BlenderTextTheme(
      body: scale(body),
      label: scale(label),
      caption: scale(caption),
      heading: scale(heading),
      panelTitle: scale(panelTitle),
    );
  }
}

@immutable
class BlenderDensity {
  const BlenderDensity({
    this.controlHeight = 20,
    this.rowHeight = 22,
    this.headerHeight = 24,
    this.spacing = 4,
    this.panelPadding = 6,
    this.iconSize = 16,
  });

  final double controlHeight;
  final double rowHeight;
  final double headerHeight;
  final double spacing;
  final double panelPadding;
  final double iconSize;

  BlenderDensity copyWith({
    double? controlHeight,
    double? rowHeight,
    double? headerHeight,
    double? spacing,
    double? panelPadding,
    double? iconSize,
  }) {
    return BlenderDensity(
      controlHeight: controlHeight ?? this.controlHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      headerHeight: headerHeight ?? this.headerHeight,
      spacing: spacing ?? this.spacing,
      panelPadding: panelPadding ?? this.panelPadding,
      iconSize: iconSize ?? this.iconSize,
    );
  }

  BlenderDensity scaled(double factor) => BlenderDensity(
    controlHeight: controlHeight * factor,
    rowHeight: rowHeight * factor,
    headerHeight: headerHeight * factor,
    spacing: spacing * factor,
    panelPadding: panelPadding * factor,
    iconSize: iconSize * factor,
  );
}

@immutable
class BlenderShapeTheme {
  const BlenderShapeTheme({
    this.controlRadius = 3,
    this.tabRadius = 4,
    this.panelRadius = 4,
    this.menuRadius = 4,
    this.borderWidth = 1,
    this.focusWidth = 1,
  });

  final double controlRadius;
  final double tabRadius;
  final double panelRadius;
  final double menuRadius;
  final double borderWidth;
  final double focusWidth;

  BlenderShapeTheme copyWith({
    double? controlRadius,
    double? tabRadius,
    double? panelRadius,
    double? menuRadius,
    double? borderWidth,
    double? focusWidth,
  }) {
    return BlenderShapeTheme(
      controlRadius: controlRadius ?? this.controlRadius,
      tabRadius: tabRadius ?? this.tabRadius,
      panelRadius: panelRadius ?? this.panelRadius,
      menuRadius: menuRadius ?? this.menuRadius,
      borderWidth: borderWidth ?? this.borderWidth,
      focusWidth: focusWidth ?? this.focusWidth,
    );
  }
}

@immutable
class BlenderIconThemeData {
  const BlenderIconThemeData({this.color, this.size = 16});

  final Color? color;
  final double size;

  BlenderIconThemeData copyWith({Color? color, double? size}) {
    return BlenderIconThemeData(
      color: color ?? this.color,
      size: size ?? this.size,
    );
  }
}

@immutable
class BlenderThemeData {
  const BlenderThemeData({
    this.colors = const BlenderColorScheme.dark(),
    this.textTheme = const BlenderTextTheme(),
    this.density = const BlenderDensity(),
    this.shapes = const BlenderShapeTheme(),
    this.iconTheme = const BlenderIconThemeData(),
  });

  final BlenderColorScheme colors;
  final BlenderTextTheme textTheme;
  final BlenderDensity density;
  final BlenderShapeTheme shapes;
  final BlenderIconThemeData iconTheme;

  static const BlenderThemeData dark = BlenderThemeData();
  static const BlenderThemeData light = BlenderThemeData(
    colors: BlenderColorScheme.light(),
  );

  BlenderThemeData copyWith({
    BlenderColorScheme? colors,
    BlenderTextTheme? textTheme,
    BlenderDensity? density,
    BlenderShapeTheme? shapes,
    BlenderIconThemeData? iconTheme,
  }) {
    return BlenderThemeData(
      colors: colors ?? this.colors,
      textTheme: textTheme ?? this.textTheme,
      density: density ?? this.density,
      shapes: shapes ?? this.shapes,
      iconTheme: iconTheme ?? this.iconTheme,
    );
  }
}

class BlenderTheme extends InheritedTheme {
  const BlenderTheme({
    super.key,
    this.data = const BlenderThemeData(),
    required super.child,
  });

  final BlenderThemeData data;

  static BlenderThemeData of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BlenderTheme>()?.data ??
        const BlenderThemeData();
  }

  static BlenderThemeData maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<BlenderTheme>()?.data ??
        const BlenderThemeData();
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return BlenderTheme(data: data, child: child);
  }

  @override
  bool updateShouldNotify(BlenderTheme oldWidget) => data != oldWidget.data;
}

/// A live theme source that can be carried into an overlay route.
///
/// Flutter inserts dialog routes above the application subtree.  A regular
/// [InheritedTheme.captureAll] correctly preserves the theme visible when the
/// route opens, but it intentionally captures a snapshot.  Editor
/// applications need Preferences to repaint while it edits the active theme,
/// so [BlenderThemeScope] carries the source as well as its current value.
class BlenderThemeController extends ChangeNotifier {
  BlenderThemeController({
    required Listenable source,
    required BlenderThemeData Function() resolve,
  }) : _source = source,
       _resolve = resolve {
    _source.addListener(_notify);
  }

  Listenable _source;
  BlenderThemeData Function() _resolve;

  BlenderThemeData get data => _resolve();

  void update({
    required Listenable source,
    required BlenderThemeData Function() resolve,
  }) {
    if (!identical(_source, source)) {
      _source.removeListener(_notify);
      _source = source;
      _source.addListener(_notify);
    }
    _resolve = resolve;
    notifyListeners();
  }

  void _notify() => notifyListeners();

  @override
  void dispose() {
    _source.removeListener(_notify);
    super.dispose();
  }
}

/// Exposes a [BlenderThemeController] to route presenters.
///
/// Use this around an application theme when popovers or temporary windows
/// must follow live theme edits. It is deliberately separate from
/// [BlenderTheme]: callers that only need the current palette still use the
/// familiar [BlenderTheme.of] API.
class BlenderThemeScope extends InheritedNotifier<BlenderThemeController> {
  const BlenderThemeScope({
    super.key,
    required BlenderThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static BlenderThemeController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BlenderThemeScope>()?.notifier;
}

class BlenderApp extends StatelessWidget {
  const BlenderApp({
    super.key,
    required this.home,
    this.title = 'Blender UI',
    this.theme = const BlenderThemeData(),
    this.navigatorKey,
    this.locale,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.localizationsDelegates,
    this.builder,
  });

  final Widget home;
  final String title;
  final BlenderThemeData theme;
  final GlobalKey<NavigatorState>? navigatorKey;
  final Locale? locale;
  final List<Locale> supportedLocales;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;
  final TransitionBuilder? builder;

  @override
  Widget build(BuildContext context) {
    return BlenderTheme(
      data: theme,
      child: WidgetsApp(
        color: theme.colors.accent,
        title: title,
        home: home,
        navigatorKey: navigatorKey,
        locale: locale,
        supportedLocales: supportedLocales,
        localizationsDelegates: localizationsDelegates,
        builder: (context, child) {
          final themedChild = DefaultTextStyle(
            style: theme.textTheme.body.copyWith(
              color: theme.colors.foreground,
            ),
            child: child ?? const SizedBox.shrink(),
          );
          return builder?.call(context, themedChild) ?? themedChild;
        },
        pageRouteBuilder: <T>(RouteSettings settings, WidgetBuilder builder) =>
            PageRouteBuilder<T>(
              settings: settings,
              pageBuilder: (context, animation, secondaryAnimation) =>
                  builder(context),
            ),
      ),
    );
  }
}
