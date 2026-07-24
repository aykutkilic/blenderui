# State integrity and host service boundaries

## Context

The DAW and workbook models exposed caller-owned collection instances despite
being used as history snapshots. The DAW also allowed a scheduled save to
rethrow outside a timer callback, represented a durable Save command with an
in-memory store, and changed project plug-in state before a native host had
accepted the operation. Native lifecycle-channel glue and persistence storage
keys were repeated across host applications and services.

## Decision

- Collection-bearing DAW and workbook model constructors copy into
  unmodifiable collections. JSON-like workbook display data is recursively
  frozen at maps and lists.
- DAW session commits coalesce history/playback notifications; selection is
  updated before its associated project change is published.
- Autosave captures its own failure after recording controller state. The DAW
  host reports explicit-save and engine-synchronization errors, and persists
  projects under application support through a host-owned store.
- Plug-in removal and bypass commit to the project only after the native host
  accepts the operation.
- `BlenderApplicationLifecycleBridge` owns the shared desktop channel and
  `BlenderPersistenceConfiguration` owns the common storage/key contract.
- A DAW session exposes separate document, selection, view, and playback
  notifiers. Persistence and engine synchronization subscribe only to document
  changes.
- A plug-in slot is the serializable source of truth for bypass, wet mix,
  normalized parameters, and opaque host state. The native/in-memory host is a
  projection of that state, not a competing persistence model. The generic
  plug-in rack is consequently an inspection surface; mutations are confined
  to the document-aware Effect Chain editor.
- Native audio synchronization receives the full versioned project JSON. The
  current macOS bridge validates and retains that document but explicitly does
  not claim offline rendering or graph processing before those native features
  exist.
- Lifecycle bridges register by application id and leave other registrations
  intact on disposal. Persistence exposes a value-notifier status alongside
  its captured error for host diagnostics.

## Consequences

History snapshots cannot be modified behind the state store's back, host and
project plug-in state stay durable across save/restore, and playback no longer
causes repeated autosave or project-graph synchronization. The DAW host now
has a dirty-save close path, while application lifecycle and persistence
failures remain observable to hosts. The showcase remains a composed fixture
application: its domain-specific property schemas intentionally stay outside
the reusable library API, while its shared native lifecycle protocol is no
longer duplicated.
