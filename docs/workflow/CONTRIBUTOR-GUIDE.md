# Contributor guide

> **Adaptable template:** This whole kit is a starting point. Adjust its workflow, guides, and templates case by case to suit the project, team, and change. Keep the process proportionate and document project-specific choices in `CONTRIBUTING.md`; the project’s documented policy takes precedence over these defaults.

Use this guide with [STANDARD.md](STANDARD.md). Commands below are examples to run deliberately; replace repository URLs and branch names for your project. They assume Git is installed. `gh` commands additionally require an authenticated GitHub CLI.

## Start with write access

Start from a clean working tree. Inspect any existing changes before switching branches; do not discard, stash, or commit someone else's work merely to follow this recipe.

```sh
git status --short
git switch main
git pull --ff-only origin main
git switch -c fix/search-empty-query
```

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

The description file should explain the outcome, compatibility impact, and actual validation. Use `--draft` if the change is not ready. Use [the PR template](templates/PULL_REQUEST_TEMPLATE.md) as a starting point.

## Start without write access

Create a fork in GitHub first, then clone your fork. Substitute the real owner, contributor, and project names:

```sh
git clone https://github.com/CONTRIBUTOR/PROJECT.git
cd PROJECT
git remote add upstream https://github.com/OWNER/PROJECT.git
git fetch upstream
git switch main
git merge --ff-only upstream/main
git switch -c fix/search-empty-query
```

Commit and push to `origin` as above. In GitHub, open a PR from your fork's working branch to `OWNER/PROJECT:main`. The original maintainer reviews and merges it; access to your fork does not grant access to the original repository.

## Keep an open PR current

Update only when needed for conflicts, integration confidence, or repository requirements. With write access to the original repository:

```sh
git fetch origin
git switch fix/search-empty-query
git merge origin/main
```

From a fork, fetch and merge `upstream/main` instead. Resolve conflicts deliberately, inspect the resulting diff, rerun affected checks, and push the branch normally. Avoid force pushes on branches other people are using. If a fast-forward update fails, inspect the divergence instead of resetting away local commits.

## Review and merge

Before marking ready, confirm:

- The PR contains one coherent outcome and no unrelated working-tree changes.
- The title describes the final behavior and uses the agreed type.
- Validation evidence says what ran, what passed, and what remains unverified.
- Breaking changes include `!` and a migration explanation.

Maintainers inspect the final diff and squash merge. Edit the squash body to retain `BREAKING CHANGE:` details where applicable. For a solo project, self-review is acceptable. A PR is still useful as a durable explanation and review boundary.

After merge, ensure the working tree is clean, then update local `main`:

```sh
git switch main
git pull --ff-only origin main
```

Fork contributors fetch and fast-forward from `upstream/main`. Delete merged branches through the host or after verifying their PR was merged. A local `git branch -d` may refuse a squash-merged branch because the original commits are not ancestors of `main`; inspect the merged PR before deliberately removing it. Do not force-delete a branch just because this guide says cleanup is customary.

Start the next change from updated `main`, rather than continuing a previously squash-merged branch.

## Working with existing uncommitted work

If you already have changes on `main`, you can usually preserve them by creating a branch at the current commit:

```sh
git status --short
git switch -c feat/describe-the-change
```

This keeps the current files and local commits; it does not update the base or separate unrelated edits. Inspect the complete diff and stage only the intended scope. If the change contains local commits, verify which commits the PR will include. Do not run the clean-start recipe blindly over a dirty checkout.

## Small and large examples

**Typo:** `docs/fix-installation-example` → small PR → source/link inspection → squash merge. Usually no package release.

**Behavior fix:** `fix/search-empty-query` → focused regression coverage and relevant validation → PR → squash merge → patch release when useful.

**New API:** `feat/custom-layout` → examples, compatibility review, meaningful checks → PR → squash merge → compatible feature release or breaking release as appropriate.

**Major redesign:** several coherent PRs or one draft PR; keep unfinished behavior off `main`. Add migration guidance before publishing. See [the release guide](RELEASE-GUIDE.md).
