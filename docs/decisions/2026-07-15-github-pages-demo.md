# Decision: Publish the Flutter showcase on GitHub Pages

Date: 2026-07-15

## Context

The repository's `examples/blenderui/` application is the primary visual showcase for
`blender_ui`. It already has a Flutter web target, but the package README only
describes local desktop launch commands. A public demo makes the current UI
surface easier to evaluate without requiring a desktop Flutter setup.

## Decision

Deploy the existing `examples/blenderui/` application to:

<https://aykutkilic.github.io/blenderui/>

The deployment is owned by `.github/workflows/deploy-demo.yml`. It builds from
the `examples/blenderui/` directory with the repository path as Flutter's base href,
uploads the generated `examples/blenderui/build/web` directory as a Pages artifact, and
deploys it with GitHub's Pages actions. The workflow runs for `main` pushes and
can also be started manually. The build uses `/blenderui/` as its base href,
matching the repository's GitHub Pages project path.

The web metadata uses the product name `blender_ui` and describes the page as
an interactive showcase. No separate demo application or committed build
output is introduced; the desktop and web demos therefore continue to exercise
the same source and remain covered by the same tests.

## Consequences

- GitHub repository Pages settings must use **GitHub Actions** as the build
  source for the deployment workflow to publish successfully.
- `--base-href /blenderui/` is required because the site is hosted below the
  repository path rather than at the domain root.
- A successful `main` deployment is the release history for the demo; generated
  web output remains a workflow artifact instead of repository source.
