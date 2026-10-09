# Repository workflow kit

> **Adaptable template:** This whole kit is a starting point. Adjust its workflow, guides, and templates case by case to suit the project, team, and change. Keep the process proportionate and document project-specific choices in `CONTRIBUTING.md`; the project’s documented policy takes precedence over these defaults.

This is a portable standard for personal, collaborative, and public repositories. It is intentionally independent of SettingsKit. Keep the canonical copy in the shared GUIDE directory, then copy a versioned snapshot into each project. A dedicated standards repository can host the canonical copy later. A project should never have to borrow its policy from another product repository.

Start with [the full standard](STANDARD.md), then use the guides at the point of work:

| Document | Purpose |
| --- | --- |
| [STANDARD.md](STANDARD.md) | Branches, commits, PRs, review, releases, compatibility, and exceptions |
| [CONTRIBUTOR-GUIDE.md](CONTRIBUTOR-GUIDE.md) | Everyday commands for maintainers and fork contributors |
| [RELEASE-GUIDE.md](RELEASE-GUIDE.md) | Small releases, larger releases, prereleases, and urgent fixes |
| [ADOPTION.md](ADOPTION.md) | Keeping a canonical copy and adopting it in other projects |
| [Issue template](templates/ISSUE_TEMPLATE.md) | Copy to `.github/ISSUE_TEMPLATE/issue.md` and adapt as needed |
| [PR template](templates/PULL_REQUEST_TEMPLATE.md) | Copy into a repository's `.github/` directory |
| [Release notes template](templates/RELEASE_NOTES.md) | Copy into a draft release |

The default is **branch → PR → main → version tag → release**. One fix can be one release; several completed changes can share a release. There is no permanent `develop` branch and no requirement to release after every merge.

Kit version: **1.0.0**. Updated: **2026-10-09**. This versions the workflow documents, independently of any product version.

Each adopting project's local policy and canonical-source provenance live in its root `CONTRIBUTING.md`, outside this portable kit. Update the canonical kit first, then refresh project snapshots.
