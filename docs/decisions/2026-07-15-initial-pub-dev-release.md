# Initial pub.dev release

**Date:** 2026-07-15  
**Status:** accepted

## Context

`blender_ui` has reached a cohesive initial public API: independently-created
Blender-inspired Flutter desktop controls, editor surfaces, layouts, and an
executable example. The package already uses `0.1.0`, which communicates an
early but usable API more accurately than a `0.0.x` placeholder.

## Decision

Publish the first public package as **`blender_ui 0.1.0`** on pub.dev. Keep the
top-level documentation in `docs/`, the directory recognized by pub tooling.
The example's generated desktop plugin registrants remain checked in because
they are part of the Flutter runner template; `.gitignore` explicitly unignores
them so package validation reflects that deliberate choice.

## Verification

`flutter pub publish --dry-run` is the release gate. Its package-content
warnings must be resolved before the authenticated `flutter pub publish`
command is run. The first dry run exposed two packaging issues: the plural
`docs/` convention warning and checked-in generated runner files being ignored.
This decision records their structural resolution for future releases. The
remaining clean-git-state advisory is resolved by committing the intended
release contents, rather than publishing an unrecorded working tree.

## Operational note

The local Flutter SDK writes its engine stamp during pub commands. In this
environment, that shared SDK-cache write requires explicit execution approval;
the publish validation itself is otherwise repeatable.
