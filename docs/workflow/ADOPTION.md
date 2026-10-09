# Adopt and maintain the workflow kit

> **Adaptable template:** This whole kit is a starting point. Adjust its workflow, guides, and templates case by case to suit the project, team, and change. Keep the process proportionate and document project-specific choices in `CONTRIBUTING.md`; the project’s documented policy takes precedence over these defaults.

The purpose of this kit is one reusable standard with a known source. The canonical kit lives in the shared GUIDE directory, independently of any adopting product repository.

## Maintain the canonical copy

Use `GUIDE/Contributing/` as the source for new adoptions and general workflow changes. Its structure is:

```text
GUIDE/
  Contributing/
    README.md
    STANDARD.md
    CONTRIBUTOR-GUIDE.md
    RELEASE-GUIDE.md
    ADOPTION.md
    templates/
      ISSUE_TEMPLATE.md
      PULL_REQUEST_TEMPLATE.md
      RELEASE_NOTES.md
```

Project-specific configuration belongs in each project's root `CONTRIBUTING.md`.

Make future general policy changes here first. If the kit later moves into a dedicated standards repository, preserve its version history and update each project's provenance. No remote standards repository or published kit tag is assumed to exist yet.

## Copy a versioned snapshot into each project

Prefer a committed copy over a submodule or a live external-only link. Contributors can read the policy offline, and later upstream edits do not silently change the project's rules.

1. Obtain a specific version of the canonical kit from GUIDE, or a tagged version if it is later hosted in a repository.
2. Copy the portable files and `templates/` into the project's `docs/workflow/`.
3. Add or update root `CONTRIBUTING.md` with the project profile below.
4. Copy `templates/PULL_REQUEST_TEMPLATE.md` to `.github/PULL_REQUEST_TEMPLATE.md` and `templates/ISSUE_TEMPLATE.md` to `.github/ISSUE_TEMPLATE/issue.md`. Adapt their prompts and sections to the project; split the issue template into bug reports and feature requests if useful.
5. Add a contribution link to the project's README when appropriate.
6. Review repository settings and configure the controls the maintainers actually intend to enforce.
7. Open a normal PR for adoption. Leave existing release tags and published history alone.

Record the actual canonical location and adopted kit version in the project's profile. For a local GUIDE source, record its filesystem path; for a hosted source, include its URL, tag, and preferably commit. Do not invent a remote URL or tag. Project-facing policy links should point to the committed snapshot so contributors do not need access to your filesystem.

## Project profile template

Keep local details outside the portable kit so copying an updated kit does not overwrite them:

```markdown
# Contributing to PROJECT

This project adopts [workflow kit VERSION](docs/workflow/README.md).
Canonical source: ACTUAL_GUIDE_PATH, kit version VERSION.
If hosted later: ACTUAL_STANDARDS_REPOSITORY_URL, tag TAG, commit COMMIT.

## Project details

- Integration branch: main.
- Branch exception: TOOL_PREFIX if required; otherwise none.
- Commit scopes: a short suggested list, or no prescribed scopes.
- Toolchain and supported platforms: actual requirements.
- Validation: actual commands and manual scenarios, scaled to the change.
- Release tag spelling: 1.2.3 or v1.2.3, matching existing tags.
- Version metadata: actual files, or Git tags only.
- Publication destinations: release pages, source tags, registries, or artifacts.
- Release record: release notes and optionally CHANGELOG.md.
- Maintainers and review: actual ownership and practical review expectations.
- Supported release lines: actual policy, without implying indefinite support.
- Deployment behavior: actual triggers and environments, if applicable.
- Automation and protection: what is configured, what is procedural.
- Exceptions: deliberate differences from the portable standard.

See the [contributor guide](docs/workflow/CONTRIBUTOR-GUIDE.md)
and [release guide](docs/workflow/RELEASE-GUIDE.md).
```

Replace every placeholder before merging. Do not copy a Swift project's commands into an unrelated project. Confirm existing automation before describing what a merge or tag push does.

## Update policy without drift

Make generally useful improvements in the canonical kit, record a new kit version, then adopt it through a PR in each project. Review the kit diff, preserve the project's profile, and reconcile installed issue and PR templates with their updated defaults while preserving useful project adaptations.

Local exceptions belong in the project profile with a reason. If an exception becomes widely useful, propose it upstream. Avoid editing several copies independently and later guessing which is authoritative.

Version the kit separately from products. For this kit, raise major for incompatible workflow requirements, minor for compatible process additions, and patch for clarifications or corrections. Record notable changes in the canonical kit documentation, or its release notes if hosted. A product can remain at version `2.0.1` while adopting kit `1.0.0`.

## Optional automation later

The kit can operate manually. Add automation only when its behavior is clear and useful:

- PR-title checks after adopting squash titles consistently.
- Relevant builds and tests with repository-specific tooling.
- Release-note drafting or release PRs when manual preparation becomes repetitive.
- Snapshot update PRs from the canonical standards repository.

Choose one authoritative publisher for each destination. Test publication behavior before enabling automatic releases, and document its triggers in the project profile. Installing Markdown templates does not configure branch rules, labels, CI, or release automation. GitHub issue templates use YAML front matter with `name` and `about` and live in `.github/ISSUE_TEMPLATE/`; see [GitHub’s template documentation](https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/about-issue-and-pull-request-templates).
