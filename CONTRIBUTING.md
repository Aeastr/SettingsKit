# Contributing to SettingsKit

SettingsKit adopts [repository workflow kit 1.0.0](docs/workflow/README.md). The canonical source is `/Users/aether/Documents/01 Projects/GUIDE/Contributing`, kit version **1.0.0**; `docs/workflow/` is the repository-local snapshot for contributors. General updates start in GUIDE, then are copied into this repository. No remote standards repository or published kit tag has been established. General workflow policy lives in [STANDARD.md](docs/workflow/STANDARD.md); this file records SettingsKit-specific details.

Start with [the contributor guide](docs/workflow/CONTRIBUTOR-GUIDE.md). Maintainers use [the release guide](docs/workflow/RELEASE-GUIDE.md).

The shared kit is an adaptable starting point. These project-specific details define SettingsKit’s current defaults; adjust the process proportionately and document deliberate changes in a PR.

## Issues

Use the issue template for bugs, feature requests, or documentation issues, keeping only the relevant sections. Include a small reproduction and SettingsKit, OS, Xcode, and Swift versions when they help diagnose a bug. A brief report is sufficient for a small issue; proposing or implementing a solution is optional.

## Branches, commits, and PRs

Use short-lived branches targeting `main`. Use names such as `fix/search-ranking`, `feat/custom-layout`, or `docs/getting-started`. Fork first if you do not have write access. Codex-created branches use the configured `codex/` prefix, for example `codex/fix-search-ranking`.

PR titles and final squash commits use Conventional Commit syntax. Suggested scopes include `search`, `indexing`, `navigation`, `styles`, `demo`, and `docs`; a scope is optional. Include a migration explanation and `!` for breaking changes.

Maintain a coherent package on `main`. There is no permanent `develop` branch. Review your own final diff; seek independent review for substantial changes when another maintainer is available.

## Toolchain and validation

The current manifest declares Swift tools **6.2** and minimum deployment targets of iOS 17, macOS 14, tvOS 17, watchOS 10, and visionOS 1. Use an appropriate Xcode/Apple SDK toolchain for SwiftUI. Check `Package.swift` when these requirements change.

Scale checks to the change:

- Documentation and copy: inspect the diff, local links, and examples; run `git diff --check` where applicable. A full build is normally unnecessary.
- Package behavior: run a relevant package build and focused tests on macOS with the required toolchain. For example, `swift test --scratch-path /private/tmp/settingskit-agent-validation --filter SettingsSearchTests` exercises the search test suite; select the suite affected by your change.
- Broader API or runtime changes: broaden package tests and verify relevant demo/consumer behavior. Platform-specific SwiftUI behavior needs suitable Xcode builds or simulator/device checks when warranted; a macOS package test does not establish correctness on every declared platform.

The scratch path above is a reusable agent-owned path for this checkout, not a per-retry directory. Coordinate conflicting runs with an atomic lock scoped to the canonical checkout and shared output path, recording the owning task/process until child processes finish. Another project's build is not a reason to wait. Check free disk space before heavy validation; below 20 GB, reclaim only verified unused agent-owned outputs and report a blocker if insufficient. Keep build data separate from interactive Xcode outputs. Clean disposable task-owned artifacts after their processes finish, preserving useful evidence and source changes.

Report commands, results, skipped checks, and remaining uncertainty in the PR. Do not claim a build or device check from source inspection.

## Releases

Existing tags use unprefixed versions (`1.0.0`, `1.0.1`, `2.0.0`, and `2.0.1` were present locally when this guide was written). Continue using tags such as `2.0.2`, and fetch current tags and inspect published releases before selecting the next version.

SettingsKit is distributed as a source Swift package. `Package.swift` has no explicit package version field; release versions are identified by Git tags. Prepare GitHub release notes for each stable release. No separate `CHANGELOG.md` is required by this adoption, and this documentation does not establish a binary or registry publication step.

Audit the complete diff from the last applicable stable release before deciding the version. Public API removals or incompatible changes, increased minimum requirements, and required consumer migration need breaking-change review. The amount of work alone does not determine the version. Do not assume the pending redesign is a patch simply because the latest local tag is `2.0.1`.

Check installation examples, DocC, demo usage, and any migration guidance against the selected release API. A published version must resolve to the verified source commit. One compatible fix may be released immediately; several ready changes may be bundled.

No additional maintained release line or support period is established by this guide. Before opening a maintenance line, explicitly record its scope and support window here.

## Enforcement and adoption

This adoption includes documentation, an issue template, and a PR description template. It does not configure remote branch protection, labels, required approvals, CI, tag rules, or automatic publication. Maintainers should inspect hosting settings and existing integrations before changing them or assuming a push has no publication side effects.

Apply the workflow to new work without rewriting old commits or tags. See [the adoption guide](docs/workflow/ADOPTION.md) for updating the snapshot from GUIDE and reusing the standard in other projects.
