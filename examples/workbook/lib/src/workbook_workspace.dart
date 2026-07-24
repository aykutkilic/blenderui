import 'dart:async';

import 'package:blender_ui/blender_ui.dart';
import 'package:blender_ui_workbook/blender_ui_workbook.dart';
import 'package:flutter/material.dart';

enum WorkbookEditorView { workbook, outline, runtime, reports }

extension WorkbookEditorViewPresentation on WorkbookEditorView {
  String get label => switch (this) {
    WorkbookEditorView.workbook => 'Workbook',
    WorkbookEditorView.outline => 'Document Outline',
    WorkbookEditorView.runtime => 'Python Runtime',
    WorkbookEditorView.reports => 'Info and Reports',
  };

  BlenderGlyph get glyph => switch (this) {
    WorkbookEditorView.workbook => BlenderGlyph.text,
    WorkbookEditorView.outline => BlenderGlyph.outliner,
    WorkbookEditorView.runtime => BlenderGlyph.console,
    WorkbookEditorView.reports => BlenderGlyph.info,
  };
}

final workbookEditorViewCodec = BlenderEditorViewCodec<WorkbookEditorView>(
  encode: (value) => value.name,
  decode: (id) =>
      WorkbookEditorView.values.where((value) => value.name == id).firstOrNull,
);

const workbookWorkspaceDefinitions = <BlenderWorkspaceDefinition<String>>[
  BlenderWorkspaceDefinition<String>(
    id: 'workbook',
    layout: BlenderDockAreaNode<String>(id: 'workbook-main', value: 'workbook'),
  ),
  BlenderWorkspaceDefinition<String>(
    id: 'scripting',
    layout: BlenderDockSplitNode<String>(
      id: 'scripting-root',
      direction: BlenderSplitDirection.horizontal,
      fraction: .74,
      first: BlenderDockAreaNode<String>(
        id: 'scripting-main',
        value: 'workbook',
      ),
      second: BlenderDockAreaNode<String>(
        id: 'scripting-outline',
        value: 'outline',
      ),
    ),
  ),
  BlenderWorkspaceDefinition<String>(
    id: 'inspect',
    layout: BlenderDockSplitNode<String>(
      id: 'inspect-root',
      direction: BlenderSplitDirection.horizontal,
      fraction: .68,
      first: BlenderDockAreaNode<String>(id: 'inspect-main', value: 'workbook'),
      second: BlenderDockSplitNode<String>(
        id: 'inspect-side',
        direction: BlenderSplitDirection.vertical,
        fraction: .55,
        first: BlenderDockAreaNode<String>(
          id: 'inspect-runtime',
          value: 'runtime',
        ),
        second: BlenderDockAreaNode<String>(
          id: 'inspect-reports',
          value: 'reports',
        ),
      ),
    ),
  ),
];

final class WorkbookEditorAreaFrame extends StatelessWidget {
  const WorkbookEditorAreaFrame({
    required this.view,
    required this.onViewSelected,
    required this.child,
    super.key,
  });

  final WorkbookEditorView view;
  final ValueChanged<WorkbookEditorView> onViewSelected;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      BlenderAreaHeader(
        editorType: BlenderEditorType.textEditor,
        showEditorLabel: false,
        editorSelectorWidth: 184,
        editorSelector: BlenderDropdown<WorkbookEditorView>(
          value: view,
          selectedLabel: view.label,
          items: <BlenderMenuItem<WorkbookEditorView>>[
            for (final candidate in WorkbookEditorView.values)
              BlenderMenuItem<WorkbookEditorView>(
                value: candidate,
                label: candidate.label,
                icon: BlenderIcon(candidate.glyph, size: 14),
              ),
          ],
          onChanged: onViewSelected,
        ),
      ),
      Expanded(child: child),
    ],
  );
}

final class WorkbookRuntimeInspector extends StatelessWidget {
  const WorkbookRuntimeInspector({
    required this.session,
    required this.installer,
    required this.status,
    required this.busy,
    required this.onConnect,
    required this.onDisconnect,
    required this.onInstall,
    super.key,
  });

  final WorkbookSessionController session;
  final JupyterRuntimeInstaller installer;
  final String Function() status;
  final bool Function() busy;
  final Future<void> Function() onConnect;
  final Future<void> Function() onDisconnect;
  final Future<void> Function() onInstall;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge(<Listenable>[session, installer]),
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        BlenderPanel(
          title: 'Runtime',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(status()),
              const SizedBox(height: 8),
              Text('Kernel: ${session.kernelState.name}'),
              Text(installer.detail),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  BlenderButton(
                    label: 'Connect',
                    onPressed: busy() ? null : () => unawaited(onConnect()),
                  ),
                  BlenderButton(
                    label: 'Disconnect',
                    onPressed: busy() ? null : () => unawaited(onDisconnect()),
                  ),
                  BlenderButton(
                    label: 'Install Managed Jupyter',
                    onPressed: busy() ? null : () => unawaited(onInstall()),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (installer.logs.isNotEmpty) ...<Widget>[
          const SizedBox(height: 8),
          BlenderPanel(
            title: 'Installer Log',
            child: SelectableText(
              installer.logs
                  .skip(
                    installer.logs.length > 40 ? installer.logs.length - 40 : 0,
                  )
                  .join('\n'),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ],
      ],
    ),
  );
}

final class WorkbookReportsView extends StatelessWidget {
  const WorkbookReportsView({required this.reports, super.key});

  final BlenderReportService reports;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: reports,
    builder: (context, _) => BlenderInfoEditor(
      title: null,
      reports: <BlenderInfoReport>[
        for (final report in reports.reports.reversed)
          BlenderInfoReport(
            id: report.id,
            message: report.message,
            level: switch (report.level) {
              BlenderStatusLevel.success => BlenderNoticeLevel.success,
              BlenderStatusLevel.warning => BlenderNoticeLevel.warning,
              BlenderStatusLevel.error => BlenderNoticeLevel.error,
              BlenderStatusLevel.info => BlenderNoticeLevel.info,
            },
            timestamp: report.timestamp.toLocal().toIso8601String(),
          ),
      ],
      onDismiss: (report) => reports.remove(report.id),
    ),
  );
}
