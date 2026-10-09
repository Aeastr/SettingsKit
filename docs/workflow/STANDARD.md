# Repository contribution and release standard

> **Adaptable template:** This whole kit is a starting point. Adjust its workflow, guides, and templates case by case to suit the project, team, and change. Keep the process proportionate and document project-specific choices in `CONTRIBUTING.md`; the project’s documented policy takes precedence over these defaults.

Workflow kit version: **1.0.0**. Applies when adopted by a repository's contribution guide. This document describes the default policy; the adopting repository records its tooling, release destinations, and deliberate exceptions separately.

## 1. The default process

1. Start a short-lived branch from an up-to-date `main`.
2. Make one coherent change and validate it in proportion to its risk.
3. Open a pull request targeting `main`.
4. Review the final diff, compatibility impact, and validation evidence.
5. Squash merge with a descriptive Conventional Commit title.
6. Delete the completed branch.
7. When there is a useful deliverable, select a tested commit on `main`, tag it, and publish a release.

`main` holds integrated work intended for the next release. It should build and have no knowingly unfinished user experience. The most recent stable tag identifies the latest published product; `main` may be ahead of it.

This is a local policy built around [GitHub flow](https://docs.github.com/en/get-started/using-github/github-flow). Branch naming, review thresholds, and release cadence below are choices made by this standard rather than Git requirements.

## 2. Terms that must stay distinct

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

## 3. Branches and forks

### Permanent branch

Use `main` as the default integration branch. Do not create a permanent `develop`, `dev`, or `staging` branch merely to collect work for a release. Collect ready changes on `main` and release them when useful.

Applications may have preview or production environments without matching permanent Git branches. The adopting repository defines deployment behavior separately.

### Working branch names

Use `<type>/<short-description>` in lowercase with hyphens:

```text
feat/custom-layout
fix/search-empty-query
docs/installation-guide
refactor/index-registry
test/search-ranking
ci/package-checks
build/swift-toolchain
chore/repository-workflow
perf/index-traversal
revert/search-ranking-change
```

Use `feat`, not `feature`, so terminology stays consistent with commit titles. An issue number is optional: `fix/123-search-empty-query`.

Do not add the author's name by default. Git and the PR already record authorship. Use an identity prefix only when a repository or tool requires it, and document the exception. For example, a Codex-created branch may be `codex/fix-search-empty-query`; its PR title still uses `fix(search): ...`.

Branches describe work, not eventual versions. Avoid `new-version`, `updates`, and `aeastr-changes`. Use `chore/release-2.1.0` only for a release-preparation PR.

### When to fork

- With write access: create a working branch in the original repository.
- Without write access: fork the repository, create a working branch in the fork, and open a PR from that branch to the original repository's `main`.
- Keep working branches in forks too. This keeps the fork's default branch available for synchronization.

A fork does not replace the branch or PR process. Use `origin` for the repository you push to and `upstream` for the original project when working from a fork.

### Larger work

Prefer several independently useful PRs. Each merged PR must leave `main` coherent. If a change cannot be split safely, keep it on a working branch and use a draft PR until ready.

An integration branch such as `integration/new-runtime` is an exception for work requiring several dependent PRs. Those PRs target the integration branch; the final PR targets `main`. Record its purpose, owner, integration criteria, and deletion plan. It must not become a second permanent default branch.

## 4. Commits and PR titles

Use this format for the final squash commit and PR title:

```text
<type>(<optional-scope>)!: <short imperative description>
```

Omit the parentheses when there is no useful scope. Omit `!` when there is no breaking change. Use a lowercase type, a specific description, and no trailing period.

The syntax follows [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/). This standard chooses the following additional type vocabulary:

| Type | Use for |
| --- | --- |
| `feat` | A new capability |
| `fix` | Incorrect behavior being corrected |
| `perf` | A performance improvement |
| `refactor` | Internal restructuring that preserves observable behavior |
| `docs` | Documentation and examples explaining existing behavior |
| `test` | Test additions or corrections |
| `build` | Build system, packaging, dependencies, or toolchain configuration |
| `ci` | Continuous integration and repository automation |
| `style` | Formatting only; use `fix` or `feat` for visible UI changes |
| `chore` | Maintenance that does not fit another type |
| `revert` | Reversing an earlier change; reference its commit or PR |

Choose the purpose of the change, not the file extension. A dependency update that fixes a runtime bug can be `fix(deps)`. Tests and documentation accompanying a feature normally belong in the feature PR.

```text
fix(search): preserve bindings in search results
feat(layout): add a custom container API
docs: explain the release process
build!: raise the minimum supported toolchain
```

For breaking work, include both `!` in the final title and a `BREAKING CHANGE:` paragraph in the final commit body explaining impact and migration. Ensure squash editing preserves that paragraph.

Working commits may be informal while a PR is in progress. The maintainer owns the final squash message. If a repository deliberately preserves individual commits instead, every retained commit must follow this convention. Never rewrite already released history solely to tidy messages.

## 5. Pull requests

### Scope and destination

Open one PR per coherent outcome. Include related tests, examples, and documentation. Split unrelated cleanup and separate fixes. An issue is useful for substantial design work but is not mandatory for a small correction.

Target `main` except for an explicitly documented integration or maintenance branch. Use draft status while the work is incomplete or awaiting a design decision.

### Description

Explain the problem and resulting behavior so someone who has not seen the conversation can assess the change. Include:

- What changed and why; a before/after example when useful.
- Actual validation, including commands or manual scenarios and their results.
- Skipped checks and remaining uncertainty.
- Public API, supported-platform, toolchain, or behavioral compatibility impact.
- Migration instructions when consumers must change code or configuration.

Use screenshots for visible changes when they help review. Avoid filling a small PR with ceremonial detail. A two-sentence documentation fix is acceptable.

### Labels

Labels are optional organization, not Git tags or release commands. If used, keep this small vocabulary:

| Label | Purpose |
| --- | --- |
| `type: feat`, `type: fix`, `type: docs`, `type: maintenance` | Broad change category |
| `breaking` | Requires compatibility review and migration notes |
| `blocked` | Cannot proceed; explain the dependency in the PR |
| `needs-discussion` | A maintainer decision is needed |

Draft status already means unfinished. Do not add priority, size, release, or author labels unless they help the repository manage real work. A label never substitutes for an accurate final commit message or compatibility review.

### Review and merge

Before merge, inspect the final diff, ensure the title matches the implementation, resolve discussions, and run the checks required by the adopting repository. Revalidate when subsequent changes invalidate earlier results.

For a solo-maintained repository, recorded self-review is sufficient; do not require an approval the author cannot provide. When another maintainer is available, request independent review for substantial API, compatibility, security, or data changes. The repository may set stricter review requirements.

Squash merge by default to leave one coherent change on `main`. Confirm the final message, including breaking-change details, before merging. Delete the source branch after merge and start future work from updated `main`.

Do not force push `main` or rewrite shared release history. Coordinate before rewriting a collaborative working branch; prefer a normal merge from its base when other people depend on it.

## 6. Proportionate validation

| Change | Expected evidence |
| --- | --- |
| Copy, spacing, or documentation | Inspect source, links, examples, and diff; lightweight checks as useful |
| Focused behavior fix | Relevant compiler/build check and focused test or reproducible manual scenario |
| Public API or substantial behavior | Appropriate builds, meaningful tests, compatibility review, and relevant consumer/example checks |
| Release | Verify the selected revision and review evidence for the complete release scope |

Finish a coherent set of edits before validating. Repeat checks only when a failure, later change, or unresolved concern warrants it. A docs-only release does not require an unrelated full test suite. Source inspection alone is not evidence of build or runtime correctness.

Respect the adopting repository's resource rules. Coordinate only conflicting validation runs; unrelated projects may validate concurrently. Keep task-owned build outputs separate from interactive development outputs and clean up disposable artifacts once their processes finish.

## 7. Compatibility and version selection

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

## 8. What makes a release

A release is a deliberate, reproducible product snapshot with a unique version, a recorded source commit, release notes, and any required published artifacts. Merging is integration; releasing is making that snapshot available to consumers.

Release when a useful change is ready. A single important fix is enough. Bundle related work when that improves communication or verification. Do not wait for an arbitrary number of commits and do not require an empty queue of planned features.

Default release sequence:

1. Review changes since the previous relevant stable tag and choose the version.
2. Prepare notes, migration guidance, and any actual version metadata in a PR.
3. Merge that PR, or use the already merged change PR when no preparation files are needed.
4. Pin the exact release commit on `main` and validate that revision as appropriate.
5. Create the version tag on that exact commit.
6. Publish release notes and any package/artifact outputs from that revision.
7. Verify the consumer-facing result and record any limitations.

Use an annotated Git tag. Default tag spelling is `1.2.3`; repositories already using `v1.2.3` should retain their existing convention. Check both spellings before creating a tag to avoid duplicate names for the same version.

Never move or reuse a published version tag. Correct a broken release with a new version. Keep old source history available; explain withdrawn or unsuitable releases in their notes. Cosmetic release-note corrections can be edited without changing the source tag.

A GitHub release and a registry upload may have separate publication steps. The project records what consumers need and how to verify it. Publishing a tag can itself make source available to package consumers before a release page is published. A draft release page does not keep an already pushed tag private.

### Release notes

Describe consumer outcomes under Added, Fixed, Changed, Deprecated, Removed, and Migration headings as relevant. Omit empty headings. Include minimum requirements, important limitations, and credit where useful. Generated PR lists can supply links, but do not replace an explanation of impact.

The default durable record is the published release notes. A `CHANGELOG.md` is optional; if adopted, keep it consistent with those notes. Do not require a changelog-only PR for every typo.

## 9. Prereleases and maintenance exceptions

### Prereleases

Use `alpha` for early integration, `beta` for wider testing, and `rc` for a candidate expected to ship. These meanings are local policy. Increment the suffix for each published revision. Mark prerelease pages accordingly and explain how to opt in.

A stable release gets its own tag after final verification, even if its commit matches the last candidate. Consumers should use the adoption guide's stable installation path unless deliberately testing a prerelease.

### A patch while main contains next-release work

If `main` contains unreleased additions or breaking changes that must not enter the patch, branch from the last applicable stable tag using `maint/2.0`. Port only the fix to that branch, review it in a PR targeting that branch, and release from the tested maintenance commit. Ensure an equivalent fix lands on `main` too; reference both PRs. Do not merge unrelated next-release work into the maintenance line.

Maintenance branches exist only for explicit supported release lines. Record which lines are supported and when to remove their branches. Their existence does not introduce a general `develop` workflow.

### Reverting and recovery

Revert an unreleased regression through a PR, then reassess the full remaining release diff. For a published regression, deliver a new corrective release and explain affected versions. A rollback must not silently restore an older API incompatibly under a patch number.

## 10. Repository settings and automation

Recommended hosting configuration:

- Default branch `main`, PR-based changes, and squash merging enabled.
- Automatic deletion of merged working branches where practical.
- Protection against force pushes and deletion of `main` and published tags.
- Required checks only for checks that exist, work reliably, and apply to that repository.
- Review requirements that reflect the actual number of maintainers.

Where a hosting plan cannot enforce a rule, maintainers follow it procedurally. Do not invent a required CI check name or make an unavailable approval a permanent merge blocker.

Start with manual version selection and release publication. Add PR-title checks, CI, changelog generation, or release PR automation when they reduce real work. Automation must leave the target commit and publication step understandable. Never silently turn every merge into a release unless the project explicitly adopts that behavior.

## 11. Adopting and changing this standard

The repository's `CONTRIBUTING.md` identifies the adopted kit version and documents toolchain, validation, tag spelling, release destinations, maintainers, support policy, and exceptions. Read [ADOPTION.md](ADOPTION.md) before copying the kit elsewhere.

Apply this convention to new work. Keep existing tags and released history intact. Update policy deliberately through a PR; adopting a standard is not permission to publish, merge pending work, or reconfigure hosting automatically.

## 12. Quick answers

| Question | Default answer |
| --- | --- |
| Fork or branch? | Branch with write access; fork plus branch without it |
| Include my name? | No, unless tooling or repository policy requires a prefix |
| `feature` or `feat`? | `feat` |
| PRs merge into what? | `main` |
| Permanent development branch? | No |
| Must every merge release? | No |
| Can one fix get a release? | Yes |
| Must releases be large? | No; compatibility determines version significance |
| Can unreleased changes accumulate? | Yes, if each merged change keeps `main` coherent |
| Can I keep developing during a release? | Yes; release a pinned, verified commit |
| How do I ship a patch without next-major changes? | Use a temporary supported maintenance line from the stable tag |
| Is this automatically enforced? | Only where the project has configured enforcement |
