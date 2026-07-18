part of '../blender_ui_test.dart';

void registerRunningJobsPanelIncludesSourceStatusRowsTests() {
  testWidgets('running jobs panel includes source status rows', (tester) async {
    var renderOpened = false;
    var animationStopped = false;
    var assetsCanceled = false;
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 420,
          child: BlenderRunningJobsPanel(
            jobs: <BlenderJobProgress>[
              BlenderJobProgress(
                name: 'Rendering',
                progress: .42,
                icon: BlenderGlyph.scene,
                onIconPressed: () => renderOpened = true,
                iconTooltip: 'Show the render window',
                remainingTime: '00:18',
                elapsedTime: '00:07',
              ),
              const BlenderJobProgress(
                name: 'Preparing',
                progress: .8,
                active: false,
              ),
            ],
            onStopAnimation: () => animationStopped = true,
            assetDownloadProgress: .25,
            onCancelAssetDownloads: () => assetsCanceled = true,
          ),
        ),
      ),
    );

    expect(find.text('Rendering'), findsOneWidget);
    expect(find.text('42%'), findsOneWidget);
    expect(find.text('Canceling...'), findsNWidgets(2));
    expect(find.text('Anim Player'), findsOneWidget);
    expect(find.text('Downloading Assets'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is BlenderIcon && widget.glyph == BlenderGlyph.assetManager,
      ),
      findsOneWidget,
    );
    expect(find.byType(BlenderTooltip), findsNWidgets(3));

    await tester.tap(find.byType(BlenderIconButton).first);
    await tester.tap(find.text('Anim Player'));
    await tester.tap(find.byType(BlenderIconButton).last);
    expect(renderOpened, isTrue);
    expect(animationStopped, isTrue);
    expect(assetsCanceled, isTrue);
  });

  testWidgets('attribute search opens and selects an attribute', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: 360,
            child: BlenderAttributeSearch<String>(
              options: const <BlenderAttributeOption<String>>[
                BlenderAttributeOption<String>(
                  name: 'roughness',
                  value: 'roughness',
                  domain: 'Point',
                  dataType: 'Float',
                ),
                BlenderAttributeOption<String>(
                  name: 'uv_map',
                  value: 'uv_map',
                  domain: 'Corner',
                  dataType: 'Float2',
                ),
              ],
              value: selected,
              onChanged: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Attribute'), warnIfMissed: false);
    await tester.pump();
    expect(find.textContaining('roughness'), findsOneWidget);
    await tester.tap(find.textContaining('roughness'));
    await tester.pump();
    expect(selected, 'roughness');
  });

  testWidgets('property templates render and update', (tester) async {
    List<String> activeLayers = <String>['one'];
    var colorSettings = const BlenderColorManagementSettings();
    var profile = const <Offset>[Offset(0, 0), Offset(1, 1)];
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 520,
          height: 720,
          child: ListView(
            children: <Widget>[
              BlenderLayerSelector(
                layers: <BlenderLayerItem>[
                  BlenderLayerItem(
                    id: 'one',
                    label: '1',
                    active: activeLayers.contains('one'),
                  ),
                  BlenderLayerItem(
                    id: 'two',
                    label: '2',
                    active: activeLayers.contains('two'),
                    used: true,
                  ),
                ],
                onChanged: (value) => activeLayers = value,
              ),
              BlenderColorManagement(
                settings: colorSettings,
                onChanged: (value) => colorSettings = value,
              ),
              BlenderCurveProfile(
                points: profile,
                presets: const <BlenderCurveProfilePreset>[
                  BlenderCurveProfilePreset(
                    name: 'Default',
                    points: <Offset>[Offset(0, 0), Offset(1, 1)],
                  ),
                ],
                onChanged: (value) => profile = value,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Color Management'), findsOneWidget);
    expect(find.text('Curve Profile'), findsOneWidget);
    await tester.tap(find.text('2'));
    await tester.pump();
    expect(activeLayers, <String>['two']);
  });

  testWidgets('scope templates preserve Blender resize grip anatomy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const UnconstrainedBox(
          constrainedAxis: Axis.horizontal,
          child: SizedBox(
            width: 360,
            child: BlenderScopeView(
              type: BlenderScopeType.waveform,
              series: <BlenderScopeSeries>[
                BlenderScopeSeries(
                  color: Color(0xFF71A8FF),
                  points: <Offset>[Offset(0, .2), Offset(1, .8)],
                ),
              ],
              height: 120,
            ),
          ),
        ),
      ),
    );

    final scope = find.byType(BlenderScopeView);
    final before = tester.getSize(scope).height;
    expect(
      find.byWidgetPredicate(
        (widget) => widget is BlenderIcon && widget.glyph == BlenderGlyph.grip,
      ),
      findsOneWidget,
    );
    await tester.drag(
      find.byWidgetPredicate(
        (widget) => widget is BlenderIcon && widget.glyph == BlenderGlyph.grip,
      ),
      const Offset(0, 24),
    );
    await tester.pump();
    expect(tester.getSize(scope).height, greaterThan(before));
  });

  testWidgets('modifier and node-input templates render', (tester) async {
    await tester.pumpWidget(
      _harness(
        SizedBox(
          width: 520,
          height: 360,
          child: ListView(
            children: <Widget>[
              const BlenderModifierStack(
                modifiers: <BlenderModifierDescriptor>[
                  BlenderModifierDescriptor(
                    id: 'bevel',
                    name: 'Bevel',
                    child: const BlenderButton(label: 'Amount'),
                  ),
                ],
              ),
              const BlenderNodeInputs(
                groups: <BlenderNodeInputGroup>[
                  BlenderNodeInputGroup(
                    id: 'surface',
                    title: 'Surface',
                    inputs: <BlenderNodeInputDescriptor>[
                      BlenderNodeInputDescriptor(
                        id: 'color',
                        label: 'Base Color',
                        editor: BlenderButton(label: 'Color'),
                      ),
                      BlenderNodeInputDescriptor(
                        id: 'normal',
                        label: 'Normal',
                        editor: SizedBox.shrink(),
                        linked: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Bevel'), findsOneWidget);
    expect(find.text('Surface'), findsOneWidget);
    expect(find.text('Linked'), findsOneWidget);
  });

  testWidgets('remaining Blender widget styles render', (tester) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 320,
          height: 180,
          child: Column(
            children: <Widget>[
              const BlenderIconLabel(
                label: 'Linked Object',
                icon: BlenderGlyph.object,
              ),
              const SizedBox(height: 4),
              const BlenderLinkLabel(label: 'Cube Data'),
              const SizedBox(height: 4),
              const BlenderOperatorButton(
                label: 'Apply',
                icon: BlenderGlyph.check,
              ),
              const SizedBox(height: 4),
              const BlenderNoticeBanner(
                message: 'Changes saved',
                level: BlenderNoticeLevel.success,
                onDismiss: _ignoreVoid,
              ),
              const SizedBox(height: 4),
              const BlenderUnitVector(
                value: Offset.zero,
                onChanged: _ignoreOffset,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Linked Object'), findsOneWidget);
    expect(find.text('Cube Data'), findsOneWidget);
    expect(find.text('Changes saved'), findsOneWidget);
  });

  testWidgets('popover opens an anchored interactive surface', (tester) async {
    var selected = false;
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: BlenderTheme(
            child: SizedBox(
              width: 180,
              height: 40,
              child: BlenderPopover(
                child: const BlenderButton(label: 'Options'),
                popover: (context, close) => SizedBox(
                  width: 180,
                  height: 100,
                  child: BlenderPanel(
                    title: 'Popover',
                    child: BlenderButton(
                      label: 'Choose',
                      onPressed: () {
                        selected = true;
                        close();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Options'));
    await tester.pump();
    expect(find.text('Popover'), findsOneWidget);
    await tester.tap(find.text('Choose'));
    await tester.pump();
    expect(selected, isTrue);
    expect(find.text('Popover'), findsNothing);
  });

  testWidgets('pie menu exposes radial command entries', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _harness(
        BlenderPieMenu<String>(
          items: const <BlenderPieMenuItem<String>>[
            BlenderPieMenuItem<String>(value: 'move', label: 'Move'),
            BlenderPieMenuItem<String>(value: 'rotate', label: 'Rotate'),
          ],
          onSelected: (item) => selected = item.value,
        ),
      ),
    );

    expect(find.text('Move'), findsOneWidget);
    await tester.tap(find.text('Rotate'));
    await tester.pump();
    expect(selected, 'rotate');
  });

  testWidgets('non-3D editor surfaces render independently', (tester) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 600,
          height: 360,
          child: BlenderVideoSequencerEditor(
            strips: const <BlenderSequencerStrip>[
              BlenderSequencerStrip(
                id: 'clip',
                label: 'Clip',
                start: 1,
                end: 40,
              ),
            ],
            start: 1,
            end: 60,
          ),
        ),
      ),
    );
    expect(find.text('Video Sequencer'), findsOneWidget);

    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 600,
          height: 360,
          child: BlenderPreferencesEditor(
            categories: const <String>['Interface'],
            sections: const <BlenderPreferenceSection>[
              BlenderPreferenceSection(
                id: 'theme',
                category: 'Interface',
                title: 'Theme',
                child: const Text('Theme settings'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Theme'), findsWidgets);
  });

  testWidgets('Preferences sections expose reorder handles in stable order', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 600,
          height: 420,
          child: BlenderPreferencesEditor(
            categories: <String>['Input'],
            selectedCategory: 'Input',
            sections: <BlenderPreferenceSection>[
              BlenderPreferenceSection(
                id: 'keyboard',
                category: 'Input',
                title: 'Keyboard',
                child: SizedBox.shrink(),
              ),
              BlenderPreferenceSection(
                id: 'mouse',
                category: 'Input',
                title: 'Mouse',
                child: SizedBox.shrink(),
              ),
              BlenderPreferenceSection(
                id: 'tablet',
                category: 'Input',
                title: 'Tablet',
                child: SizedBox.shrink(),
              ),
              BlenderPreferenceSection(
                id: 'touchpad',
                category: 'Input',
                title: 'Touchpad',
                child: SizedBox.shrink(),
              ),
              BlenderPreferenceSection(
                id: 'ndof',
                category: 'Input',
                title: 'NDOF',
                child: SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );

    final titles = <String>['Keyboard', 'Mouse', 'Tablet', 'Touchpad', 'NDOF'];
    for (var index = 0; index < titles.length - 1; index++) {
      expect(
        tester.getTopLeft(find.text(titles[index])).dy,
        lessThan(tester.getTopLeft(find.text(titles[index + 1])).dy),
      );
    }
    for (final id in <String>[
      'keyboard',
      'mouse',
      'tablet',
      'touchpad',
      'ndof',
    ]) {
      expect(
        find.byKey(ValueKey<String>('preference-section-handle-$id')),
        findsOneWidget,
      );
    }
  });

  testWidgets('Clip Editor exposes source-shaped Mask Properties', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 720,
          height: 420,
          child: BlenderClipEditor(
            markers: <BlenderClipMarker>[
              BlenderClipMarker(id: 'mask-point', position: Offset(80, 70)),
            ],
            maskSidebar: BlenderMaskProperties(),
          ),
        ),
      ),
    );

    expect(find.text('Movie Clip Editor'), findsOneWidget);
    expect(find.text('Mask'), findsOneWidget);
    expect(find.text('Mask Settings'), findsOneWidget);
    expect(find.text('Mask Layers'), findsOneWidget);
    expect(find.text('Active Spline'), findsOneWidget);
    expect(find.text('Active Point'), findsOneWidget);
    expect(find.text('Mask Display'), findsOneWidget);
    expect(find.text('Transforms'), findsOneWidget);
    expect(find.text('Mask Layer'), findsOneWidget);
    final maskEditor = tester.widget<BlenderPropertiesEditor>(
      find.byType(BlenderPropertiesEditor),
    );
    expect(
      maskEditor.groups.map((group) => group.title),
      containsAll(<String>[
        'Mask Settings',
        'Mask Layers',
        'Active Spline',
        'Active Point',
        'Animation',
        'Mask Display',
        'Transforms',
        'Mask Tools',
      ]),
    );
  });

  testWidgets('info editor renders report severity and timestamp', (
    tester,
  ) async {
    await tester.pumpWidget(
      _harness(
        const SizedBox(
          width: 420,
          height: 180,
          child: BlenderInfoEditor(
            reports: <BlenderInfoReport>[
              BlenderInfoReport(
                id: 'saved',
                message: 'Saved showcase.blend',
                level: BlenderNoticeLevel.success,
                timestamp: 'Now',
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Saved showcase.blend'), findsOneWidget);
    expect(find.text('Now'), findsOneWidget);
  });

  testWidgets('Properties visible-tabs menu opens and updates visibility', (
    tester,
  ) async {
    var visible = <String>{'tool', 'render'};
    const tabs = <BlenderPropertyTab>[
      BlenderPropertyTab(id: 'tool', label: 'Tool', glyph: BlenderGlyph.tool),
      BlenderPropertyTab(
        id: 'render',
        label: 'Render',
        glyph: BlenderGlyph.render,
      ),
    ];
    await tester.pumpWidget(
      BlenderApp(
        home: Directionality(
          textDirection: TextDirection.ltr,
          child: BlenderTheme(
            child: SizedBox(
              width: 160,
              height: 40,
              child: StatefulBuilder(
                builder: (context, setState) => Align(
                  alignment: Alignment.centerLeft,
                  child: BlenderPropertyTabVisibilityMenu(
                    tabs: tabs,
                    visibleTabIds: visible,
                    onVisibilityChanged: (value) =>
                        setState(() => visible = value),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(BlenderPropertyTabVisibilityMenu));
    await tester.pump();
    expect(find.text('Visible Tabs'), findsOneWidget);
    expect(find.text('Tool'), findsOneWidget);

    await tester.tap(find.byType(BlenderCheckbox).last);
    await tester.pump();
    expect(visible, <String>{'tool'});
  });
}
