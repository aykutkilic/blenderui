part of '../showcase_app.dart';

extension _ShowcaseMainToolbar on _ShowcaseAppState {
  void _selectWorkspace(int index) {
    final primaryEditor = switch (index) {
      0 || 1 || 2 => BlenderEditorType.view3d,
      3 => BlenderEditorType.uvEditor,
      4 || 7 => BlenderEditorType.imageEditor,
      5 => BlenderEditorType.shaderEditor,
      6 => BlenderEditorType.dopeSheet,
      8 => BlenderEditorType.compositor,
      9 => BlenderEditorType.geometryNodeEditor,
      _ => BlenderEditorType.view3d,
    };
    final lowerEditor = switch (index) {
      5 => 2,
      9 => 3,
      10 => 5,
      _ => 0,
    };
    final viewMode = switch (index) {
      2 => 'Sculpt Mode',
      4 => 'Texture Paint',
      _ => 'Object Mode',
    };
    final viewShading = switch (index) {
      5 => 'Material Preview',
      7 => 'Rendered',
      _ => _view3dHeaderState.shading,
    };
    _update(() {
      _workspaceIndex = index;
      _bottomTab = lowerEditor;
      _view3dHeaderState = _view3dHeaderState.copyWith(
        mode: viewMode,
        shading: viewShading,
      );
    });
    _mainEditorArea.select(primaryEditor);
  }

  Widget _buildMainToolbarForTheme(BuildContext context) {
    BlenderApplicationMenu<String> menu(
      String label,
      List<BlenderMenuItem<String>> items, {
      ValueChanged<String>? onSelected,
    }) {
      return BlenderApplicationMenu<String>(
        label: label,
        items: items,
        onSelected:
            onSelected ??
            (value) {
              if (value == 'Quit') {
                _requestQuit();
              } else if (value == 'Save' || value == 'Save As') {
                _hasUnsavedChanges = false;
                _setStatus('Saved "Untitled.blend"');
              } else {
                _setStatus(value);
              }
            },
      );
    }

    final theme = BlenderTheme.of(context);
    return BlenderApplicationTopBar<String, int>(
      overflow: BlenderApplicationTopBarOverflow.shared,
      leading: <Widget>[
        BlenderPopover(
          child: const BlenderIconButton(
            glyph: BlenderGlyph.cube,
            tooltip: 'Blender',
            size: 30,
          ),
          popover: (context, close) => BlenderMenu<String>(
            items: const <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Splash Screen',
                label: 'Splash Screen',
              ),
              BlenderMenuItem<String>(
                value: 'About Blender',
                label: 'About Blender',
              ),
              BlenderMenuItem<String>(
                value: 'separator',
                label: '',
                separator: true,
              ),
              BlenderMenuItem<String>(
                value: 'Install Application Template...',
                label: 'Install Application Template...',
              ),
              BlenderMenuItem<String>(
                value: 'System',
                label: 'System',
                submenu: <BlenderMenuItem<String>>[
                  BlenderMenuItem<String>(
                    value: 'Reload Scripts',
                    label: 'Reload Scripts',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Memory Statistics',
                    label: 'Memory Statistics',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Debug Menu',
                    label: 'Debug Menu',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Redraw Timer',
                    label: 'Redraw Timer',
                    submenu: <BlenderMenuItem<String>>[
                      BlenderMenuItem<String>(value: 'Draw', label: 'Draw'),
                      BlenderMenuItem<String>(value: 'Swap', label: 'Swap'),
                      BlenderMenuItem<String>(value: 'Frame', label: 'Frame'),
                      BlenderMenuItem<String>(
                        value: 'Animation',
                        label: 'Animation',
                      ),
                    ],
                  ),
                  BlenderMenuItem<String>(
                    value: 'Clean Up Spacedata',
                    label: 'Clean Up Spacedata',
                  ),
                  BlenderMenuItem<String>(
                    value: 'Clean Up Operator Presets',
                    label: 'Clean Up Operator Presets',
                  ),
                ],
              ),
            ],
            onSelected: (item) {
              close();
              switch (item.value) {
                case 'Splash Screen':
                  unawaited(_application.presentation.showSplash(context));
                case 'About Blender':
                  unawaited(_application.presentation.showAbout(context));
                default:
                  _setStatus(item.value);
              }
            },
          ),
        ),
      ],
      menus: <BlenderApplicationMenu<String>>[
        menu('File', const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'New',
            label: 'New',
            shortcut: '⌘ N',
            icon: BlenderIcon(BlenderGlyph.file, size: 18),
            submenu: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(value: 'General', label: 'General'),
              BlenderMenuItem<String>(
                value: '2D Animation',
                label: '2D Animation',
              ),
              BlenderMenuItem<String>(value: 'Sculpting', label: 'Sculpting'),
              BlenderMenuItem<String>(
                value: 'Storyboarding',
                label: 'Storyboarding',
              ),
              BlenderMenuItem<String>(value: 'VFX', label: 'VFX'),
              BlenderMenuItem<String>(
                value: 'Video Editing',
                label: 'Video Editing',
              ),
            ],
          ),
          BlenderMenuItem<String>(
            value: 'Open',
            label: 'Open...',
            shortcut: '⌘ O',
            icon: BlenderIcon(BlenderGlyph.folder, size: 18),
          ),
          BlenderMenuItem<String>(
            value: 'Open Recent',
            label: 'Open Recent',
            shortcut: '⇧ ⌘ O',
            submenu: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Recent Scene',
                label: 'showcase.blend',
              ),
              BlenderMenuItem<String>(
                value: 'Recent Materials',
                label: 'materials.blend',
              ),
            ],
          ),
          BlenderMenuItem<String>(
            value: 'Revert',
            label: 'Revert',
            enabled: false,
          ),
          BlenderMenuItem<String>(
            value: 'Recover',
            label: 'Recover',
            submenu: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Recover Last Session',
                label: 'Last Session',
              ),
              BlenderMenuItem<String>(
                value: 'Recover Auto Save',
                label: 'Auto Save...',
              ),
            ],
          ),
          BlenderMenuItem<String>(
            value: 'separator-open',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'Save',
            label: 'Save',
            shortcut: '⌘ S',
            icon: BlenderIcon(BlenderGlyph.save, size: 18),
          ),
          BlenderMenuItem<String>(
            value: 'Save As',
            label: 'Save As...',
            shortcut: '⇧ ⌘ S',
          ),
          BlenderMenuItem<String>(value: 'Save Copy', label: 'Save Copy...'),
          BlenderMenuItem<String>(
            value: 'Save Incremental',
            label: 'Save Incremental',
            enabled: false,
          ),
          BlenderMenuItem<String>(
            value: 'separator-save',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'Link',
            label: 'Link...',
            icon: BlenderIcon(BlenderGlyph.link, size: 18),
          ),
          BlenderMenuItem<String>(
            value: 'Append',
            label: 'Append...',
            icon: BlenderIcon(BlenderGlyph.link, size: 18),
          ),
          BlenderMenuItem<String>(
            value: 'Data Previews',
            label: 'Data Previews',
            submenu: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Update Data Previews',
                label: 'Update Data Previews',
              ),
              BlenderMenuItem<String>(
                value: 'Remove Data Previews',
                label: 'Remove Data Previews',
              ),
            ],
          ),
          BlenderMenuItem<String>(
            value: 'separator-data',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'Import',
            label: 'Import',
            icon: BlenderIcon(BlenderGlyph.open, size: 18),
            submenu: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Import Alembic',
                label: 'Alembic (.abc)',
              ),
              BlenderMenuItem<String>(
                value: 'Import USD',
                label: 'Universal Scene Description (.usd*)',
              ),
              BlenderMenuItem<String>(
                value: 'Import SVG',
                label: 'SVG as Grease Pencil',
              ),
              BlenderMenuItem<String>(
                value: 'Import OBJ',
                label: 'Wavefront (.obj)',
              ),
              BlenderMenuItem<String>(
                value: 'Import PLY',
                label: 'Stanford PLY (.ply)',
              ),
              BlenderMenuItem<String>(value: 'Import STL', label: 'STL (.stl)'),
              BlenderMenuItem<String>(value: 'Import FBX', label: 'FBX (.fbx)'),
              BlenderMenuItem<String>(
                value: 'Import BVH',
                label: 'Motion Capture (.bvh)',
              ),
              BlenderMenuItem<String>(
                value: 'Import SVG2',
                label: 'Scalable Vector Graphics (.svg)',
              ),
              BlenderMenuItem<String>(
                value: 'Import FBX Legacy',
                label: 'FBX (.fbx) (Legacy)',
              ),
              BlenderMenuItem<String>(
                value: 'Import glTF',
                label: 'glTF 2.0 (.glb/.gltf)',
              ),
            ],
          ),
          BlenderMenuItem<String>(
            value: 'Export',
            label: 'Export',
            icon: BlenderIcon(BlenderGlyph.save, size: 18),
            submenu: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Export OBJ',
                label: 'Wavefront (.obj)',
              ),
              BlenderMenuItem<String>(value: 'Export FBX', label: 'FBX (.fbx)'),
              BlenderMenuItem<String>(
                value: 'Export glTF',
                label: 'glTF 2.0 (.glb/.gltf)',
              ),
            ],
          ),
          BlenderMenuItem<String>(
            value: 'Export All Collections',
            label: 'Export All Collections',
            enabled: false,
          ),
          BlenderMenuItem<String>(
            value: 'separator-export',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'External Data',
            label: 'External Data',
            submenu: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Pack Resources',
                label: 'Pack Resources',
              ),
              BlenderMenuItem<String>(
                value: 'Unpack Resources',
                label: 'Unpack Resources',
              ),
              BlenderMenuItem<String>(
                value: 'Make Paths Relative',
                label: 'Make Paths Relative',
              ),
              BlenderMenuItem<String>(
                value: 'Make Paths Absolute',
                label: 'Make Paths Absolute',
              ),
              BlenderMenuItem<String>(
                value: 'Report Missing Files',
                label: 'Report Missing Files',
              ),
              BlenderMenuItem<String>(
                value: 'Find Missing Files...',
                label: 'Find Missing Files...',
              ),
            ],
          ),
          BlenderMenuItem<String>(
            value: 'Clean Up',
            label: 'Clean Up',
            submenu: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Unused Data',
                label: 'Purge Unused Data...',
              ),
              BlenderMenuItem<String>(
                value: 'Manage Unused Data',
                label: 'Manage Unused Data...',
              ),
            ],
          ),
          BlenderMenuItem<String>(
            value: 'separator-cleanup',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'Defaults',
            label: 'Defaults',
            submenu: <BlenderMenuItem<String>>[
              BlenderMenuItem<String>(
                value: 'Save Startup File',
                label: 'Save Startup File',
              ),
              BlenderMenuItem<String>(
                value: 'Load Factory Settings',
                label: 'Load Factory Settings',
              ),
            ],
          ),
          BlenderMenuItem<String>(
            value: 'separator-quit',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'Quit',
            label: 'Quit',
            shortcut: '⌘ Q',
            icon: BlenderIcon(BlenderGlyph.close, size: 18),
          ),
        ]),
        menu(
          'Edit',
          <BlenderMenuItem<String>>[
            const BlenderMenuItem<String>(
              value: 'Undo',
              label: 'Undo',
              shortcut: '⌘ Z',
              icon: const BlenderIcon(BlenderGlyph.undo, size: 18),
            ),
            const BlenderMenuItem<String>(
              value: 'Redo',
              label: 'Redo',
              shortcut: '⇧ ⌘ Z',
              enabled: false,
              icon: const BlenderIcon(BlenderGlyph.redo, size: 18),
            ),
            const BlenderMenuItem<String>(
              value: 'Undo History',
              label: 'Undo History',
              submenu: const <BlenderMenuItem<String>>[
                BlenderMenuItem<String>(
                  value: 'Undo History Initial State',
                  label: 'Initial State',
                ),
              ],
            ),
            const BlenderMenuItem<String>(
              value: 'separator-edit-history',
              label: '',
              separator: true,
            ),
            const BlenderMenuItem<String>(
              value: 'Adjust Last Operation...',
              label: 'Adjust Last Operation...',
              shortcut: 'F9',
            ),
            const BlenderMenuItem<String>(
              value: 'Repeat Last',
              label: 'Repeat Last',
              shortcut: '⇧ R',
            ),
            const BlenderMenuItem<String>(
              value: 'Repeat History...',
              label: 'Repeat History...',
            ),
            const BlenderMenuItem<String>(
              value: 'separator-edit-search',
              label: '',
              separator: true,
            ),
            const BlenderMenuItem<String>(
              value: 'Menu Search...',
              label: 'Menu Search...',
              shortcut: 'F3',
              icon: const BlenderIcon(BlenderGlyph.search, size: 18),
            ),
            const BlenderMenuItem<String>(
              value: 'Operator Search...',
              label: 'Operator Search...',
              shortcut: 'F3',
              icon: const BlenderIcon(BlenderGlyph.search, size: 18),
            ),
            const BlenderMenuItem<String>(
              value: 'separator-edit-rename',
              label: '',
              separator: true,
            ),
            const BlenderMenuItem<String>(
              value: 'Rename Active Item...',
              label: 'Rename Active Item...',
              shortcut: 'F2',
            ),
            const BlenderMenuItem<String>(
              value: 'Batch Rename...',
              label: 'Batch Rename...',
              shortcut: '⌘ F2',
            ),
            const BlenderMenuItem<String>(
              value: 'separator-edit-preferences',
              label: '',
              separator: true,
            ),
            BlenderMenuItem<String>(
              value: 'Lock Object Modes',
              label: 'Lock Object Modes',
              checked: _lockObjectModes,
            ),
            const BlenderMenuItem<String>(
              value: 'Preferences...',
              label: 'Preferences...',
              shortcut: '⌘ ,',
              icon: const BlenderIcon(BlenderGlyph.preferences, size: 18),
            ),
            const BlenderMenuItem<String>(
              value: 'Project Setup...',
              label: 'Project Setup...',
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'Lock Object Modes':
                _update(() => _lockObjectModes = !_lockObjectModes);
                _setStatus(
                  _lockObjectModes
                      ? 'Lock Object Modes enabled'
                      : 'Lock Object Modes disabled',
                );
              case 'Preferences...':
                _showPreferencesWindow();
              case 'Menu Search...' || 'Operator Search...':
                _showMenuSearch();
              default:
                _setStatus(value);
            }
          },
        ),
        menu('Render', const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(
            value: 'Render Image',
            label: 'Render Image',
            shortcut: 'F12',
          ),
          BlenderMenuItem<String>(
            value: 'Render Animation',
            label: 'Render Animation',
          ),
          BlenderMenuItem<String>(
            value: 'separator-render-view',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'Render Audio...',
            label: 'Render Audio...',
          ),
          BlenderMenuItem<String>(
            value: 'separator-render-result',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(value: 'View Render', label: 'View Render'),
          BlenderMenuItem<String>(
            value: 'View Animation',
            label: 'View Animation',
          ),
          BlenderMenuItem<String>(
            value: 'Lock Interface',
            label: 'Lock Interface',
          ),
        ]),
        menu('Window', const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'New Window', label: 'New Window'),
          BlenderMenuItem<String>(
            value: 'New Main Window',
            label: 'New Main Window',
          ),
          BlenderMenuItem<String>(
            value: 'separator-window-fullscreen',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'Toggle Fullscreen',
            label: 'Toggle Fullscreen',
          ),
          BlenderMenuItem<String>(
            value: 'separator-window-workspace',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'Next Workspace',
            label: 'Next Workspace',
          ),
          BlenderMenuItem<String>(
            value: 'Previous Workspace',
            label: 'Previous Workspace',
          ),
          BlenderMenuItem<String>(
            value: 'Show Status Bar',
            label: 'Show Status Bar',
          ),
          BlenderMenuItem<String>(
            value: 'separator-window-screenshot',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(
            value: 'Save Screenshot...',
            label: 'Save Screenshot...',
          ),
          BlenderMenuItem<String>(
            value: 'Save Screenshot (Editor)...',
            label: 'Save Screenshot (Editor)...',
          ),
        ]),
        menu('Help', const <BlenderMenuItem<String>>[
          BlenderMenuItem<String>(value: 'Manual', label: 'Manual'),
          BlenderMenuItem<String>(value: 'Support', label: 'Support'),
          BlenderMenuItem<String>(
            value: 'User Communities',
            label: 'User Communities',
          ),
          BlenderMenuItem<String>(value: 'Get Involved', label: 'Get Involved'),
          BlenderMenuItem<String>(
            value: 'Release Notes',
            label: 'Release Notes',
          ),
          BlenderMenuItem<String>(
            value: 'separator-help-report',
            label: '',
            separator: true,
          ),
          BlenderMenuItem<String>(value: 'Report a Bug', label: 'Report a Bug'),
          BlenderMenuItem<String>(
            value: 'System Information',
            label: 'System Information',
          ),
        ]),
      ],
      workspaces: _templateWorkspaces,
      activeWorkspace: _workspaceIndex,
      onWorkspaceSelected: (value) {
        if (_templateMode == _ShowcaseTemplateMode.general) {
          _selectWorkspace(value);
        } else {
          _selectTemplateWorkspace(value);
        }
        _setStatus('Workspace changed');
      },
      workspaceActions: <Widget>[
        BlenderPopover(
          child: BlenderIconButton(
            glyph: BlenderGlyph.plus,
            onPressed: () {},
            tooltip: 'Add Workspace',
            size: 26,
          ),
          popover: (context, close) => SizedBox(
            width: 260,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colors.menuBackground,
                border: Border.all(color: theme.colors.borderSubtle),
                borderRadius: BorderRadius.circular(theme.shapes.menuRadius),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text('Add Workspace', style: theme.textTheme.body),
                    const SizedBox(height: 6),
                    for (final workspace in <String>[
                      'General',
                      '2D Animation',
                      'Sculpting',
                      'Storyboarding',
                      'VFX',
                      'Video Editing',
                    ])
                      BlenderButton(
                        label: workspace,
                        variant: BlenderButtonVariant.menu,
                        onPressed: () {
                          _setStatus('Workspace added: $workspace');
                          close();
                        },
                      ),
                    const BlenderSeparator(),
                    BlenderButton(
                      label: 'Duplicate Current',
                      onPressed: () {
                        _setStatus('Workspace duplicated');
                        close();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      contextControls: <Widget>[
        BlenderDataBlockGroup<String>(
          value: 'Scene',
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: 'Scene',
              label: 'Scene',
              icon: BlenderIcon(BlenderGlyph.scene, size: 16),
            ),
            BlenderMenuItem<String>(value: 'Preview', label: 'Preview'),
          ],
          tooltip: 'Scene',
          onChanged: (value) => _setStatus('Scene: $value'),
          onNamePressed: () => _setStatus('Rename scene'),
          onPin: () => _setStatus('Pinned scene'),
          onDuplicate: () => _setStatus('Scene copied'),
          onClose: () => _setStatus('Scene view closed'),
        ),
        SizedBox(
          width: 1,
          height: 24,
          child: ColoredBox(color: theme.colors.editorOutline),
        ),
        BlenderDataBlockGroup<String>(
          value: 'ViewLayer',
          items: const <BlenderMenuItem<String>>[
            BlenderMenuItem<String>(
              value: 'ViewLayer',
              label: 'ViewLayer',
              icon: BlenderIcon(BlenderGlyph.image, size: 16),
            ),
            BlenderMenuItem<String>(
              value: 'Preview Layer',
              label: 'Preview Layer',
            ),
          ],
          tooltip: 'View Layer',
          onChanged: (value) => _setStatus('View layer: $value'),
          onNamePressed: () => _setStatus('Rename view layer'),
          onDuplicate: () => _setStatus('View layer copied'),
          onClose: () => _setStatus('View layer closed'),
        ),
      ],
    );
  }
}
