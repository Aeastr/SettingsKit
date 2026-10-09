# Contributing to SettingsKit

This is the complete contribution and release workflow for SettingsKit. These guidelines can be adapted to the project; the defaults below apply to SettingsKit. Propose proportionate changes in a PR when needed. Keep the process proportionate to the change.

## Ways to contribute

Bug reports, documentation improvements, examples, focused fixes, and new capabilities are welcome. An issue is useful for discussing a substantial design before implementation, but is not required for a small correction. Keep each PR focused on one coherent outcome.

## Issues

Choose **Bug report**, **Feature request**, or **Documentation issue** in the issue chooser. Bug reports ask for the smallest useful reproduction, actual versus expected behavior, and the SettingsKit version or commit, Apple OS/platform, Xcode version, and Swift version. Feature requests ask for the use case and desired outcome; documentation issues identify missing, unclear, or incorrect guidance. Keep reports proportionate and remove irrelevant optional sections. Proposing or implementing a solution is optional.

## Branches, labels, tags, and releases

| Term | Example | Meaning |
| --- | --- | --- |
| Branch | `fix/search-empty-query` | A moving line of development |
| Fork | `contributor/project` | A separate repository used to propose changes |
| Commit type | `fix(search): handle empty queries` | The purpose of a committed change |
| PR label | `type: fix` | Optional metadata used to find or organize PRs |
| Version tag | `2.0.2` | A permanent name for the exact released commit |
| GitHub release | Release named `2.0.2` | Notes and optional assets associated with a tag |
| Package publication | A registry upload or source tag | What a package consumer actually installs |

Creating a branch, pushing commits, merging a PR, creating a tag, and publishing a release are separate actions. Each repository must document any automation that connects them.

## Forks and branches

With write access, create a working branch in the original repository. Without write access, fork first, create a working branch in your fork, and open a PR back to the original repository's `main`.

Use short-lived branches from current `main`. The default name is `<type>/<short-description>` in lowercase with hyphens, for example `fix/search-ranking`, `feat/custom-layout`, or `docs/getting-started`. An issue number is optional. Author names are unnecessary unless tooling requires a prefix.

Codex-created branches use the configured `codex/` prefix, for example `codex/fix-search-ranking`. Suggested commit scopes are `search`, `indexing`, `navigation`, `styles`, `demo`, and `docs`.

PRs normally target `main`. There is no permanent `develop` branch. Keep unfinished work on its branch or in a draft PR; merge when the change leaves the project coherent.

For a clean checkout with write access:

```sh
git status --short
git switch main
git pull --ff-only origin main
git switch -c fix/describe-the-change
```

From a fork, use `origin` for your fork and `upstream` for the original repository. Fetch and fast-forward from `upstream/main` before branching. If the checkout already contains changes, inspect them first; do not discard or commit unrelated work to follow this recipe. Creating a new branch at the current commit can preserve existing edits, but does not update the base or separate unrelated changes.

### Larger work

Prefer several independently useful PRs. Each merged PR must leave `main` coherent. If a change cannot be split safely, keep it on a working branch and use a draft PR until ready.

An integration branch such as `integration/new-runtime` is an exception for work requiring several dependent PRs. Those PRs target the integration branch; the final PR targets `main`. Record its purpose, owner, integration criteria, and deletion plan. It must not become a second permanent default branch.

## Commit messages and PR titles

Use [Conventional Commit](https://www.conventionalcommits.org/en/v1.0.0/) syntax for the PR title and final squash commit:

```text
<type>(<optional-scope>): <short imperative description>
```

| Type | Purpose |
| --- | --- |
| `feat` | New capability |
| `fix` | Correct incorrect behavior |
| `perf` | Performance improvement |
| `refactor` | Internal restructuring preserving observable behavior |
| `docs` | Documentation or examples of existing behavior |
| `test` | Test additions or corrections |
| `build` | Build system, packaging, dependencies, or toolchain |
| `ci` | CI and repository automation |
| `style` | Formatting only; visible UI changes use `fix` or `feat` |
| `chore` | Other maintenance |
| `revert` | Reverse an earlier change; reference its commit or PR |

Use `feat`, not `feature`. A scope is optional. Examples:

```text
fix(search): preserve result bindings
feat(layout): add a custom container
build!: raise the minimum supported toolchain
```

For a breaking change, add `!` before the colon and explain impact and migration under `BREAKING CHANGE:` in the final commit body. Changes to established behavior or minimum requirements can be breaking even without removing declarations.

Working commits may be informal while the PR evolves. Maintainers ensure the final squash message accurately describes the merged change and retains breaking-change details. If individual commits are deliberately preserved, each retained commit should follow the convention.

## Making a change

Follow existing code conventions and framework boundaries. Include related documentation, examples, and meaningful regression coverage where warranted.

Keep the README focused on purpose, support, a complete quick start, and links into DocC. Put workflows and concepts in the catalog, and public API contracts beside declarations in `///` comments. Each DocC topic folder has a matching landing page; the root and landing pages use `@TopicsVisualStyle(detailedGrid)` and explicit Topics links to guides and symbols. Session-specific validation results belong in the PR, not consumer documentation. Split unrelated cleanup from the requested behavior change. Explain consumer-facing differences and provide migration steps when existing integrations must change.

Complete a coherent set of edits before validating. Stage only intended paths, inspect `git diff --cached`, and run `git diff --cached --check` before committing. Do not sweep unrelated changes into the PR.

## Validation expectations

Match validation to the scope and risk:

- Documentation, copy, and spacing: inspect source, links, examples, and diff; lightweight checks are normally sufficient.
- Focused behavior fixes: run the relevant build/compiler check and a focused test or reproducible manual scenario.
- Substantial behavior or API changes: use appropriate builds, meaningful tests, compatibility review, and relevant consumer/example checks.

Repeat checks when failures, subsequent changes, or unresolved concerns warrant it. Report what actually ran, its result, what was skipped, and remaining uncertainty. Source inspection alone does not prove build or runtime correctness. Use the project-specific commands below.

## Opening a pull request

Push your working branch and open a PR to `main`, using the installed PR template. Use a draft while work is incomplete. Include:

- The problem and resulting behavior, with a before/after example when helpful.
- Validation performed and its result, plus skipped checks.
- Compatibility impact, minimum-requirement changes, and migration instructions.
- Relevant issue links and screenshots for visible behavior when useful.

Keep small PR descriptions concise. If the base changes and conflicts or integration questions arise, update the branch, inspect the combined diff, and rerun affected checks. Coordinate before rewriting a shared working branch.

## Git recipes

These are examples; substitute actual paths and repository names. Start with a clean checkout and inspect existing work before switching branches. GitHub CLI commands additionally require an authenticated `gh` installation.

Make the change. Stage specific paths so unrelated edits stay out of the PR:

```sh
git diff
git add Sources/Search.swift Tests/SearchTests.swift
git diff --cached
git diff --cached --check
git commit -m "fix(search): handle empty queries"
git push -u origin fix/search-empty-query
```

The example paths are placeholders. Use paths that actually belong to your change. Do not use `git add .` as a substitute for inspecting a mixed working tree.

Open a PR in the hosting UI with base `main`, or use:

```sh
gh pr create --base main --head fix/search-empty-query \
  --title "fix(search): handle empty queries" \
  --body-file /path/to/pr-description.md
```

The description file should explain the outcome, compatibility impact, and actual validation. Use `--draft` if the change is not ready. Use the installed PR template as a starting point.

### Starting from a fork

Create a fork in GitHub first, then clone your fork. Replace CONTRIBUTOR with your GitHub username:

```sh
git clone https://github.com/CONTRIBUTOR/SettingsKit.git
cd SettingsKit
git remote add upstream https://github.com/Aeastr/SettingsKit.git
git fetch upstream
git switch main
git merge --ff-only upstream/main
git switch -c fix/search-empty-query
```

Commit and push to `origin` as above. In GitHub, open a PR from your fork's working branch to `Aeastr/SettingsKit:main`. The original maintainer reviews and merges it; access to your fork does not grant access to the original repository.

### Keeping an open PR current

Update only when needed for conflicts, integration confidence, or repository requirements. With write access to the original repository:

```sh
git fetch origin
git switch fix/search-empty-query
git merge origin/main
```

From a fork, fetch and merge `upstream/main` instead. Resolve conflicts deliberately, inspect the resulting diff, rerun affected checks, and push the branch normally. Avoid force pushes on branches other people are using. If a fast-forward update fails, inspect the divergence instead of resetting away local commits.

## Review and merge

Maintainers review the final diff, resolve discussions, and confirm appropriate validation before squash merging. For a solo-maintained project, recorded self-review is sufficient; request independent review for substantial changes when another maintainer is available.

After merge, delete the completed working branch once its PR is verified as merged. Update `main` and start the next change from it. Do not continue a previously squash-merged branch, force push `main`, or rewrite released history.

Fork contributors fetch and fast-forward from `upstream/main`. Delete merged branches through the host or after verifying their PR was merged. A local `git branch -d` may refuse a squash-merged branch because the original commits are not ancestors of `main`; inspect the merged PR before deliberately removing it. Do not force-delete a branch just because this guide says cleanup is customary.

Start the next change from updated `main`, rather than continuing a previously squash-merged branch.

### Labels

Labels are optional organization, not Git tags or release commands. If used, keep this small vocabulary:

| Label | Purpose |
| --- | --- |
| `type: feat`, `type: fix`, `type: docs`, `type: maintenance` | Broad change category |
| `breaking` | Requires compatibility review and migration notes |
| `blocked` | Cannot proceed; explain the dependency in the PR |
| `needs-discussion` | A maintainer decision is needed |

Draft status already means unfinished. Do not add priority, size, release, or author labels unless they help the repository manage real work. A label never substitutes for an accurate final commit message or compatibility review.

## Release expectations

Merging integrates work; publishing a version releases it. A single useful fix can justify a release, and several ready changes may be bundled. There is no requirement to release after every merge.

### Compatibility and version selection

Use `MAJOR.MINOR.PATCH` as defined by [Semantic Versioning](https://semver.org/): incompatible public API changes raise major, compatible functionality or deprecation raises minor, and compatible bug fixes raise patch. Reset lower components after a higher-component increment. A prerelease has a suffix such as `3.0.0-beta.1` and precedes its corresponding stable version. Before `1.0.0`, the public API is unstable; this standard still requires migration notes for breaking changes.

Review the *entire unreleased diff*, not only the last PR. The highest compatibility impact determines the release. Commit types help find changes; they cannot prove compatibility.

| Situation | Local release policy |
| --- | --- |
| One compatible fix after `2.0.1` | `2.0.2` |
| Several compatible fixes | One patch release is sufficient |
| Compatible capability plus fixes after `2.0.1` | `2.1.0` |
| Consumers must adapt their existing integration | Review for `3.0.0`; include a migration guide |
| Only web-facing documentation changed | Merge; usually no package release |
| Published documentation or packaging needs correction | A patch may be useful to deliver corrected artifacts |
| Behavior is unchanged by internal cleanup | Release only when there is a reason to deliver it |

For public libraries, review more than exported declarations: established behavior, defaults, serialization, configuration, extension points, and supported compiler/platform requirements can affect consumers. Treat increased minimum compiler or OS requirements as breaking under this standard. A change hidden behind `refactor`, `build`, or `chore` does not get an exemption.

Large code volume alone does not imply a major release. A one-line signature change can require one. A fix that restores documented behavior still deserves migration notes if consumers are likely to depend on the old behavior; maintainers decide the version using the actual contract.

GitHub Releases holds release history and version-specific notes. Do not create a tracked `docs/releases/` archive or append release entries to this contribution guide; a separate changelog is optional. Maintainers publish a unique tag on a verified commit and follow the project's release instructions. Published version tags are not moved or reused.


## Project setup and validation commands

The current manifest declares Swift tools **6.2** and minimum deployment targets of iOS 17, macOS 14, tvOS 17, watchOS 10, and visionOS 1. Use an appropriate Xcode/Apple SDK toolchain for SwiftUI. Check `Package.swift` when these requirements change.

Scale checks to the change:

- Documentation and copy: inspect the diff, local links, and examples; run `git diff --check` where applicable. A full build is normally unnecessary.
- Package behavior: run a relevant package build and focused tests on macOS with the required toolchain. For example, `swift test --filter SettingsSearchTests` exercises the search test suite; select the suite affected by your change.
- Broader API or runtime changes: broaden package tests and verify relevant demo/consumer behavior. Platform-specific SwiftUI behavior needs suitable Xcode builds or simulator/device checks when warranted; a macOS package test does not establish correctness on every declared platform.

Coordinate conflicting runs with an atomic lock scoped to the canonical checkout and shared output path, recording the owning task/process until child processes finish. Another project's build is not a reason to wait. Check free disk space before heavy validation; below 20 GB, reclaim only verified unused agent-owned outputs and report a blocker if insufficient. Keep build data separate from interactive Xcode outputs. Clean disposable task-owned artifacts after their processes finish, preserving useful evidence and source changes.

Report commands, results, skipped checks, and remaining uncertainty in the PR. Do not claim a build or device check from source inspection.

## Project release details

Existing tags use unprefixed versions, including `3.0.0`. Continue that spelling and fetch current tags and inspect [published releases](https://github.com/Aeastr/SettingsKit/releases) before selecting the next version.

SettingsKit is distributed as a source Swift package. `Package.swift` has no explicit package version field; release versions are identified by Git tags. Prepare GitHub release notes for each stable release. GitHub Releases is the release record; do not maintain a duplicate `docs/releases/` archive. No separate `CHANGELOG.md` is required by this adoption, and this documentation does not establish a binary or registry publication step.

Audit the complete diff from the last applicable stable release before deciding the version. Public API removals or incompatible changes, increased minimum requirements, and required consumer migration need breaking-change review. The amount of work alone does not determine the version. Review the actual public contract before selecting a patch, minor, or major version.

Check installation examples, DocC, demo usage, and any migration guidance against the selected release API. A published version must resolve to the verified source commit. One compatible fix may be released immediately; several ready changes may be bundled.

No additional maintained release line or support period is established by this guide. Before opening a maintenance line, explicitly record its scope and support window here.

## Maintainer release process

Version numbers and commands below are illustrative; replace them for the release at hand. Publishing is separate from merging. These are process instructions, not a running release history.

### 1. Decide what consumers should receive

Choose the previous stable release for the line you are releasing. Inspect its full difference from the intended release commit, including changes that were merged weeks ago. Fetch remote tags before deciding:

```sh
git fetch origin --tags
git log --oneline 2.0.1..origin/main
git diff --stat 2.0.1..origin/main
git diff 2.0.1..origin/main
```

Replace `2.0.1` with the applicable existing tag. A tag list alone is not proof of which release is current or which lines are supported. Check the published releases and package destination too.

Apply the compatibility rules above. Do not select a patch version if the full diff includes a breaking change. If the upcoming release mixes fixes with new functionality, its notes must describe both.

### 2. Choose the smallest useful preparation path

For one ready fix, the existing merged PR can be enough. Write notes, verify the revision, and publish. There is no mandatory release branch or extra release-preparation PR.

For a larger release, create `chore/release-2.1.0` from `main` when version files, migration guides, bundled documentation, or other source changes are needed. Open a PR to `main`, validate the coherent changes, and merge. Release preparation is not a second integration phase.

If a project maintains `CHANGELOG.md`, update it consistently. If release pages are its release record, prepare notes in a GitHub draft or an untracked working file rather than creating an otherwise unnecessary source commit. Do not add a tracked `docs/releases/` directory by default. Keep substantial migration guides in project documentation when useful, linked from the release. Do not insert a version constant into a package that obtains its version from Git tags.

### 3. Pin and verify the source revision

Use a clean checkout. If the primary checkout contains unrelated work, use a separate release checkout/worktree and its own resource coordination. Do not stash or discard other work to release.

After fetching the merged result, record its full commit ID:

```sh
git fetch origin --tags
git rev-parse origin/main
```

Copy the intended full ID, then pin it explicitly:

```sh
release_commit=REPLACE_WITH_FULL_VERIFIED_COMMIT_ID
release_version=2.0.2
git show --no-patch --format=fuller "$release_commit"
git merge-base --is-ancestor "$release_commit" origin/main
```

Replace the placeholder before running dependent commands. Confirm the ancestry command succeeds for a normal main-line release. For a maintenance release, use its remote maintenance branch instead of `origin/main`.

Validate the selected revision using the repository's commands. A clean checkout may switch to `git switch --detach "$release_commit"` for this step. Builds against another commit or against extra uncommitted files do not validate this release snapshot. Reliable CI tied to the same revision can supply evidence; rerun locally only where it resolves an actual gap.

Record the revision, checks, results, and any accepted limitations in release evidence. Fix a failed requirement through the normal PR process, then select and verify a new commit. New merges on `main` do not change the pinned commit; deciding to include them requires reviewing and validating the expanded scope.

### 4. Create and push the exact version tag

Confirm the proposed version has not been used, including the alternative prefix spelling:

```sh
git tag --list "$release_version" "v$release_version"
git ls-remote --tags origin "refs/tags/$release_version" "refs/tags/v$release_version"
```

Stop if either command finds a conflicting version. Use the adopting repository's existing tag spelling. The examples use unprefixed tags.

Only after the release revision and version are confirmed:

```sh
git tag -a "$release_version" "$release_commit" -m "Release $release_version"
git rev-parse "$release_version^{commit}"
git push origin "refs/tags/$release_version"
```

Confirm the resolved tag commit equals `release_commit`. Push that single tag rather than every local tag. If a push is rejected because the tag already exists remotely, inspect it and stop; do not force replace it.

**Publication boundary:** a pushed source tag may already be installable. Finish the compatibility and validation decision before this step, even if the GitHub release page is still a draft.

### 5. Publish and verify

Write release notes under Added, Fixed, Changed, Deprecated, Removed, Requirements, Migration, and Known limitations headings as relevant. Omit empty sections. Describe consumer outcomes, compatibility information, migration steps, and relevant links. Generated PR lists can supply references but do not replace an explanation of impact.

In GitHub, select the existing tag rather than allowing the release form to tag whichever commit is currently at `main`. If using the optional GitHub CLI:

```sh
gh release create "$release_version" --verify-tag \
  --title "$release_version" --notes-file /path/to/release-notes.md
```

The GitHub UI also supports creating and publishing releases against tags; see [GitHub's release instructions](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository).

For projects with registries or binary artifacts, run their documented publication step from the selected revision and verify the resulting version and artifacts. For a source package, check that its normal consumer installation can resolve the new tag and that its instructions match the delivered API.

Confirm the release page, tag commit, notes, assets, and package destination agree. Do not mark an older maintenance release as the latest stable version for the whole project when a newer supported major exists.

### Prerelease path

Use the same review and verification process with an explicit prerelease version. Examples: `3.0.0-alpha.1`, `3.0.0-beta.1`, and `3.0.0-rc.1`. Each published revision receives a new tag. In the UI, mark it as a prerelease; with the CLI, include `--prerelease` when creating the release.

Write explicit opt-in installation instructions for the project's package manager. Do not assume stable dependency ranges select prereleases. Before stable publication, address findings, verify the final revision, and publish a new stable tag with complete notes.

### Urgent fix while main contains future work

1. Confirm the last suitable stable tag and which release line remains supported.
2. Create `maint/2.0` from `2.0.1` if that maintenance branch does not already exist; otherwise update from its existing remote branch.
3. Create a working branch such as `fix/2.0-search-crash` from the maintenance branch.
4. Implement or carefully port only the fix. A clean single-change commit can be cherry-picked with `git cherry-pick -x COMMIT_ID`; inspect it for dependencies on next-release APIs.
5. Open a PR to `maint/2.0`, validate it in that line, and merge.
6. Release the pinned maintenance commit through the same tagging and publication steps.
7. Land an equivalent fix on `main` if it is not already there. Link the two PRs and validate any adapted implementation.

Do not cherry-pick an entire mixed feature PR merely because it includes the fix. Do not merge the whole next-version branch into the patch line. Record the support period for the maintenance line.

### Recovery

If publication partially succeeds, inspect each destination before retrying. A tag push, release page, registry upload, and asset upload may succeed independently. Continue missing steps against the same verified source where possible; never reuse a published version for different source or binaries.

If the released product is wrong, prepare a corrective PR and a new version. Explain affected versions and the recommended upgrade. Keep the old tag's identity intact. The adopting repository specifies any registry-specific withdrawal mechanism.

### Final checklist

- [ ] Full release scope reviewed against the previous relevant stable tag.
- [ ] Version selected from compatibility impact; requirements and migration explained.
- [ ] Exact release commit recorded; appropriate validation covers that revision.
- [ ] Version files and bundled guidance agree where applicable.
- [ ] Unique tag resolves to the verified commit.
- [ ] Release page and required package/artifact publication completed.
- [ ] Consumer-facing version resolution or installation verified.
- [ ] Disposable task-owned validation outputs cleaned up when no process uses them.

## Repository settings and automation

Recommended hosting configuration:

- Default branch `main`, PR-based changes, and squash merging enabled.
- Automatic deletion of merged working branches where practical.
- Protection against force pushes and deletion of `main` and published tags.
- Required checks only for checks that exist, work reliably, and apply to that repository.
- Review requirements that reflect the actual number of maintainers.

Where a hosting plan cannot enforce a rule, maintainers follow it procedurally. Do not invent a required CI check name or make an unavailable approval a permanent merge blocker.

Start with manual version selection and release publication. Add PR-title checks, CI, changelog generation, or release PR automation when they reduce real work. Automation must leave the target commit and publication step understandable. Never silently turn every merge into a release unless the project explicitly adopts that behavior.

This adoption installs separate bug report, feature request, and documentation issue templates, plus a PR description template. It does not configure remote branch protection, labels, required approvals, CI, tag rules, or automatic publication. Inspect hosting settings and existing integrations before changing them or assuming a push has no publication side effects.
