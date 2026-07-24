# Workbook host file and execution boundary

## Context

The workbook host prepared Python shadow files from a callback used while
building workbook cells. That made rendering perform synchronous file-system
work. Kernel execution also recorded a failed cell and then rethrew the same
failure, while UI actions intentionally invoked execution without awaiting it.

## Decision

- Keep shadow-file creation and synchronization in the workbook host because
  application-support paths and file-retention policy are host concerns. A
  dedicated `WorkbookShadowFileManager` owns serialized, deduplicated
  synchronization rather than growing the application state object.
- Prepare shadow files asynchronously after session changes; the view only
  consumes paths that were already prepared.
- Let the workbook session translate expected execution failures into a failed
  `WorkbookExecutionResult` and typed cell output. UI commands can therefore
  remain fire-and-forget without producing unhandled failures.
- Keep the session's split between undoable authoring state and transient
  execution state. It is deliberate: execution output must not create an undo
  entry for every stream event.

## Consequences

Rendering has no synchronous file writes, newly created code cells receive a
shadow path after preparation, and runtime errors are visible in the cell and
result instead of escaping the UI event boundary. CodeForge remains a direct
dependency of the native workbook extension because its public editor widget
accepts CodeForge controller/configuration types; hiding that dependency would
require a new adapter API, not a barrel-file change.
