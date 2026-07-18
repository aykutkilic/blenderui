part of '../component_catalog.dart';

extension _ComponentCatalogPreviewBuilder on _ComponentCatalogExampleState {
  Widget _buildPreview(
    BuildContext context,
    BlenderThemeData theme,
    String id,
  ) {
    return switch (id) {
      'button' => BlenderFlow(
        children: <Widget>[
          BlenderButton(
            label: 'Apply',
            onPressed: () => _setStatus('Apply pressed'),
          ),
          BlenderButton(
            label: 'Selected',
            selected: true,
            onPressed: () => _setStatus('Selected pressed'),
          ),
          BlenderButton(
            label: 'Toolbar',
            variant: BlenderButtonVariant.toolbar,
            onPressed: () => _setStatus('Toolbar pressed'),
          ),
        ],
      ),
      'checkbox' => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BlenderCheckbox(
            value: _enabled,
            label: 'Enabled',
            onChanged: (value) => _updatePreview(() {
              _enabled = value;
              _status = 'Enabled: $value';
            }),
          ),
          BlenderToggle(
            value: _liveUpdate,
            label: 'Live update',
            onChanged: (value) => _updatePreview(() {
              _liveUpdate = value;
              _status = 'Live update: $value';
            }),
          ),
          BlenderRadio<String>(
            value: 'Object',
            groupValue: _mode,
            label: 'Object mode',
            onChanged: (value) => _updatePreview(() {
              _mode = value;
              _status = 'Mode: $_mode';
            }),
          ),
        ],
      ),
      'slider' => Row(
        children: <Widget>[
          Expanded(
            child: BlenderSlider(
              value: _amount,
              onChanged: (value) => _updatePreview(() {
                _amount = value;
                _status = 'Value: ${value.toStringAsFixed(3)}';
              }),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: BlenderNumberField(
              value: _amount,
              min: 0,
              max: 1,
              step: .01,
              onChanged: (value) => _updatePreview(() {
                _amount = value;
                _status = 'Value: ${value.toStringAsFixed(3)}';
              }),
            ),
          ),
        ],
      ),
      'text-field' => Row(
        children: <Widget>[
          Expanded(
            child: BlenderTextField(
              controller: _text,
              onChanged: (value) => _setStatus('Editing: $value'),
              onSubmitted: (value) => _setStatus('Submitted: $value'),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: BlenderButton(
              label: 'Submit',
              onPressed: () => _setStatus('Submitted: ${_text.text}'),
            ),
          ),
        ],
      ),
      'dropdown' => SizedBox(
        width: 250,
        child: BlenderDropdown<String>(
          value: _mode,
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem(value: 'Object', label: 'Object'),
            BlenderMenuItem(value: 'Edit', label: 'Edit'),
            BlenderMenuItem(value: 'Sculpt', label: 'Sculpt'),
          ],
          onChanged: (value) => _updatePreview(() {
            _mode = value;
            _status = 'Mode: $_mode';
          }),
        ),
      ),
      'multi-column-menu' => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BlenderPopover(
            onOpenChanged: (open) {
              if (open) _setStatus('Multi-column menu opened');
            },
            child: IgnorePointer(
              child: BlenderButton(
                label: switch (_multiColumnSelection) {
                  'page' => 'Page Editor',
                  'level' => 'Level Editor',
                  'timeline' => 'Timeline',
                  'dopesheet' => 'Dope Sheet',
                  'text' => 'Text Editor',
                  'console' => 'Python Console',
                  'properties' => 'Properties',
                  'outliner' => 'Outliner',
                  _ => 'Choose Editor',
                },
                trailing: const BlenderIcon(
                  BlenderGlyph.panelDisclosureDown,
                  size: 9,
                ),
                selected: true,
                variant: BlenderButtonVariant.menuTrigger,
              ),
            ),
            popover: (context, close) => BlenderMultiColumnMenu<String>(
              key: const ValueKey<String>('catalog-multicolumn-menu'),
              menuId: 'catalog-multicolumn-menu',
              semanticLabel: 'Editor type menu',
              groups: const <BlenderMultiColumnMenuGroup<String>>[
                BlenderMultiColumnMenuGroup<String>(
                  id: 'general',
                  title: 'General',
                  items: <BlenderMultiColumnMenuItem<String>>[
                    BlenderMultiColumnMenuItem<String>(
                      id: 'page',
                      value: 'page',
                      label: 'Page Editor',
                      glyph: BlenderGlyph.file,
                    ),
                    BlenderMultiColumnMenuItem<String>(
                      id: 'level',
                      value: 'level',
                      label: 'Level Editor',
                      glyph: BlenderGlyph.grid,
                    ),
                  ],
                ),
                BlenderMultiColumnMenuGroup<String>(
                  id: 'animation',
                  title: 'Animation',
                  items: <BlenderMultiColumnMenuItem<String>>[
                    BlenderMultiColumnMenuItem<String>(
                      id: 'timeline',
                      value: 'timeline',
                      label: 'Timeline',
                      glyph: BlenderGlyph.timeline,
                    ),
                    BlenderMultiColumnMenuItem<String>(
                      id: 'dopesheet',
                      value: 'dopesheet',
                      label: 'Dope Sheet',
                      glyph: BlenderGlyph.action,
                    ),
                  ],
                ),
                BlenderMultiColumnMenuGroup<String>(
                  id: 'scripting',
                  title: 'Scripting',
                  items: <BlenderMultiColumnMenuItem<String>>[
                    BlenderMultiColumnMenuItem<String>(
                      id: 'text',
                      value: 'text',
                      label: 'Text Editor',
                      glyph: BlenderGlyph.text,
                    ),
                    BlenderMultiColumnMenuItem<String>(
                      id: 'console',
                      value: 'console',
                      label: 'Python Console',
                      glyph: BlenderGlyph.console,
                    ),
                  ],
                ),
                BlenderMultiColumnMenuGroup<String>(
                  id: 'data',
                  title: 'Data',
                  items: <BlenderMultiColumnMenuItem<String>>[
                    BlenderMultiColumnMenuItem<String>(
                      id: 'properties',
                      value: 'properties',
                      label: 'Properties',
                      glyph: BlenderGlyph.settings,
                    ),
                    BlenderMultiColumnMenuItem<String>(
                      id: 'outliner',
                      value: 'outliner',
                      label: 'Outliner',
                      glyph: BlenderGlyph.collection,
                    ),
                  ],
                ),
              ],
              selected: _multiColumnSelection,
              onSelected: (value) {
                _updatePreview(() {
                  _multiColumnSelection = value;
                  _status = 'Editor: $value';
                });
                close();
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Resize the window to switch between columns and a vertical menu.',
            style: theme.textTheme.caption.copyWith(
              color: theme.colors.foregroundMuted,
            ),
          ),
        ],
      ),
      'search-field' => SizedBox(
        width: 280,
        child: BlenderSearchField(
          controller: _search,
          placeholder: 'Search components',
          onChanged: (value) => _setStatus(
            value.isEmpty ? 'Search cleared' : 'Filtering: $value',
          ),
        ),
      ),
      'list-view' => SizedBox(
        height: 132,
        child: BlenderListView<String>(
          selectedId: _selectedListItem,
          items: const <BlenderListItem<String>>[
            BlenderListItem(
              id: 'scene',
              label: 'Scene Collection',
              detail: '12 objects',
              icon: BlenderGlyph.collection,
            ),
            BlenderListItem(
              id: 'camera',
              label: 'Camera',
              detail: 'Perspective',
              icon: BlenderGlyph.camera,
            ),
            BlenderListItem(
              id: 'light',
              label: 'Key Light',
              detail: 'Area',
              icon: BlenderGlyph.light,
            ),
          ],
          onSelected: (item) => _updatePreview(() {
            _selectedListItem = item.id;
            _status = 'Selected: ${item.label}';
          }),
        ),
      ),
      'tree' => SizedBox(
        height: 140,
        child: BlenderTree<String>(
          selectedId: _selectedTreeNode,
          roots: const <BlenderTreeNode<String>>[
            BlenderTreeNode(
              id: 'collection',
              label: 'Collection',
              icon: BlenderGlyph.collection,
              initiallyExpanded: true,
              children: <BlenderTreeNode<String>>[
                BlenderTreeNode(
                  id: 'cube',
                  label: 'Cube',
                  value: 'Cube',
                  icon: BlenderGlyph.object,
                ),
                BlenderTreeNode(
                  id: 'camera',
                  label: 'Camera',
                  value: 'Camera',
                  icon: BlenderGlyph.camera,
                ),
              ],
            ),
          ],
          onSelected: (node) => _updatePreview(() {
            _selectedTreeNode = node.id;
            _status = 'Selected: ${node.label}';
          }),
        ),
      ),
      'properties-editor' => _buildRenderPropertiesPreview(),
      'notice' => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const BlenderNoticeBanner(
            message: 'Changes saved successfully.',
            level: BlenderNoticeLevel.success,
          ),
          const SizedBox(height: 8),
          BlenderProgressBar(value: _amount, label: 'Building preview'),
          const SizedBox(height: 8),
          BlenderButton(
            label: 'Advance',
            onPressed: () => _updatePreview(() {
              _amount = (_amount + .1).clamp(0, 1);
              _status = 'Progress advanced';
            }),
          ),
        ],
      ),
      'tooltip' => BlenderTooltip(
        message: 'Tooltips wait 500ms before appearing',
        child: BlenderButton(
          label: 'Hover for help',
          onPressed: () => _setStatus('Help action pressed'),
        ),
      ),
      'popover' => BlenderPopover(
        child: BlenderButton(
          label: 'Open popover',
          onPressed: () => _setStatus('Popover opened'),
        ),
        popover: (context, close) => BlenderPanel(
          title: 'Popover',
          child: BlenderButton(
            label: 'Close',
            onPressed: () {
              close();
              _setStatus('Popover closed');
            },
          ),
        ),
      ),
      'panel' => BlenderPanel(
        title: 'Transform',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BlenderButton(
              label: 'Primary action',
              onPressed: () => _setStatus('Primary action pressed'),
            ),
            const SizedBox(height: 6),
            const BlenderPanel(
              title: 'Advanced',
              initiallyExpanded: false,
              child: const SizedBox(height: 24),
            ),
          ],
        ),
      ),
      'tabs' => BlenderTabBar(
        tabs: const <String>['Layout', 'Modeling', 'Sculpting'],
        selectedIndex: _selectedTab,
        onChanged: (index) => _updatePreview(() {
          _selectedTab = index;
          _status = 'Tab: ${['Layout', 'Modeling', 'Sculpting'][index]}';
        }),
      ),
      'breadcrumbs' => BlenderBreadcrumbs(
        items: const <String>['Scene', 'Collection', 'Cube'],
        onSelected: (index) => _setStatus('Breadcrumb $index selected'),
      ),
      'splitter' => SizedBox(
        height: 130,
        child: BlenderSplitter(
          initialFraction: _splitFraction,
          onFractionChanged: (value) => _updatePreview(() {
            _splitFraction = value;
            _status = 'Split: ${(value * 100).round()}%';
          }),
          first: ColoredBox(
            color: theme.colors.surface,
            child: const Center(child: Text('Editor')),
          ),
          second: ColoredBox(
            color: theme.colors.textField,
            child: const Center(child: Text('Inspector')),
          ),
        ),
      ),
      'toolbar' => BlenderToolbar(
        children: <Widget>[
          BlenderIconButton(
            glyph: BlenderGlyph.plus,
            onPressed: () => _setStatus('Add pressed'),
          ),
          BlenderButton(
            label: 'Layout',
            variant: BlenderButtonVariant.topBar,
            onPressed: () => _setStatus('Layout pressed'),
          ),
          BlenderIconButton(
            glyph: BlenderGlyph.settings,
            onPressed: () => _setStatus('Settings pressed'),
          ),
        ],
      ),
      'timeline' => BlenderTimeline(
        model: BlenderTimelineModel(
          start: 1,
          end: 48,
          currentFrame: _currentFrame,
          tracks: const <BlenderTimelineTrack>[
            BlenderTimelineTrack(
              id: 'cube',
              label: 'Cube',
              keyframes: <BlenderTimelineKeyframe>[
                BlenderTimelineKeyframe(1),
                BlenderTimelineKeyframe(18),
                BlenderTimelineKeyframe(42),
              ],
            ),
          ],
        ),
        onCurrentFrameChanged: (frame) => _updatePreview(() {
          _currentFrame = frame;
          _status = 'Frame: ${frame.round()}';
        }),
      ),
      'node-editor' => SizedBox(
        height: 180,
        child: BlenderNodeEditor(
          model: const BlenderNodeGraphModel(
            nodes: const <BlenderGraphNode>[
              BlenderGraphNode(
                id: 'input',
                title: 'Input',
                position: Offset(16, 30),
                outputs: <BlenderNodeSocketDefinition>[
                  BlenderNodeSocketDefinition(id: 'value', label: 'Value'),
                ],
              ),
              BlenderGraphNode(
                id: 'output',
                title: 'Output',
                position: Offset(250, 70),
                inputs: <BlenderNodeSocketDefinition>[
                  BlenderNodeSocketDefinition(id: 'value', label: 'Value'),
                ],
              ),
            ],
            links: <BlenderGraphLink>[
              BlenderGraphLink(from: 'input.value', to: 'output.value'),
            ],
          ),
          onNodeSelected: (node) => _setStatus('Selected node: ${node.title}'),
          onNodeMoved: (node, position) => _setStatus('Moved ${node.title}'),
        ),
      ),
      'file-browser' => SizedBox(
        height: 190,
        child: BlenderFileBrowser(
          selectedPath: _selectedPath,
          entries: const <BlenderFileEntry>[
            BlenderFileEntry(
              path: '/project/assets/scene.blend',
              name: 'scene.blend',
              detail: '2.4 MB',
            ),
            BlenderFileEntry(
              path: '/project/assets/props',
              name: 'props',
              isDirectory: true,
              detail: 'Folder',
            ),
          ],
          onSelected: (entry) => _updatePreview(() {
            _selectedPath = entry.path;
            _status = 'Selected: ${entry.name}';
          }),
          onOpen: (entry) => _setStatus('Opened: ${entry.name}'),
          pathSegments: const <String>['project', 'assets'],
          onPathSelected: (index) => _setStatus('Path segment $index'),
        ),
      ),
      'spreadsheet' => SizedBox(
        height: 170,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Expanded(
              child: const BlenderSpreadsheetEditor(
                columns: const <BlenderSpreadsheetColumn>[
                  BlenderSpreadsheetColumn(
                    id: 'name',
                    label: 'Name',
                    width: 170,
                  ),
                  BlenderSpreadsheetColumn(
                    id: 'type',
                    label: 'Type',
                    width: 110,
                  ),
                  BlenderSpreadsheetColumn(
                    id: 'value',
                    label: 'Value',
                    width: 110,
                  ),
                ],
                rows: const <BlenderSpreadsheetRow>[
                  BlenderSpreadsheetRow(
                    id: 'one',
                    values: <String>['Cube', 'Mesh', '1.00'],
                  ),
                  BlenderSpreadsheetRow(
                    id: 'two',
                    values: <String>['Camera', 'Object', '50mm'],
                  ),
                ],
              ),
            ),
            BlenderButton(
              label: 'Refresh data',
              onPressed: () => _setStatus('Spreadsheet refreshed'),
            ),
          ],
        ),
      ),
      'history-store' => _ServicePreview(
        title: 'HistoryStore<AppState>',
        rows: const <String>['Undo stack: 3 changes', 'Redo stack: empty'],
        onInvoked: () => _updatePreview(() {
          _serviceInvocations++;
          _status = 'History command $_serviceInvocations invoked';
        }),
      ),
      'command-registry' => _ServicePreview(
        title: 'CommandRegistry',
        rows: const <String>['Ctrl I  Increment Counter', 'Ctrl R  Reset Demo'],
        onInvoked: () => _updatePreview(() {
          _serviceInvocations++;
          _status = 'Command $_serviceInvocations invoked';
        }),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
