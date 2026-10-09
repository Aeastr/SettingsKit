# Maintainer release guide

> **Adaptable template:** This whole kit is a starting point. Adjust its workflow, guides, and templates case by case to suit the project, team, and change. Keep the process proportionate and document project-specific choices in `CONTRIBUTING.md`; the project’s documented policy takes precedence over these defaults.

Use this guide with [STANDARD.md](STANDARD.md). The adopting repository defines actual validation commands and publication destinations. Version and commit values here are illustrative. These instructions do not assume that merging a PR automatically publishes anything.

## 1. Decide what consumers should receive

Choose the previous stable release for the line you are releasing. Inspect its full difference from the intended release commit, including changes that were merged weeks ago. Fetch remote tags before deciding:

```sh
git fetch origin --tags
git log --oneline 2.0.1..origin/main
git diff --stat 2.0.1..origin/main
git diff 2.0.1..origin/main
```

Replace `2.0.1` with the applicable existing tag. A tag list alone is not proof of which release is current or which lines are supported. Check the published releases and package destination too.

Apply the compatibility rules in the standard. Do not select a patch version if the full diff includes a breaking change. If the upcoming release mixes fixes with new functionality, its notes must describe both.

## 2. Choose the smallest useful preparation path

For one ready fix, the existing merged PR can be enough. Write notes, verify the revision, and publish. There is no mandatory release branch or extra release-preparation PR.

For a larger release, create `chore/release-2.1.0` from `main` when version files, migration guides, bundled documentation, or other source changes are needed. Open a PR to `main`, validate the coherent changes, and merge. Release preparation is not a second integration phase.

If a project maintains `CHANGELOG.md`, update it consistently. If release pages are its release record, prepare notes in a draft rather than creating an otherwise unnecessary source commit. Do not insert a version constant into a package that obtains its version from Git tags.

## 3. Pin and verify the source revision

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

## 4. Create and push the exact version tag

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

## 5. Publish and verify

Use [the release notes template](templates/RELEASE_NOTES.md). Include outcomes, compatibility information, migration instructions, and relevant links. Remove sections that do not apply.

In GitHub, select the existing tag rather than allowing the release form to tag whichever commit is currently at `main`. If using the optional GitHub CLI:

```sh
gh release create "$release_version" --verify-tag \
  --title "$release_version" --notes-file /path/to/release-notes.md
```

The GitHub UI also supports creating and publishing releases against tags; see [GitHub's release instructions](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository).

For projects with registries or binary artifacts, run their documented publication step from the selected revision and verify the resulting version and artifacts. For a source package, check that its normal consumer installation can resolve the new tag and that its instructions match the delivered API.

Confirm the release page, tag commit, notes, assets, and package destination agree. Do not mark an older maintenance release as the latest stable version for the whole project when a newer supported major exists.

## Prerelease path

Use the same review and verification process with an explicit prerelease version. Examples: `3.0.0-alpha.1`, `3.0.0-beta.1`, and `3.0.0-rc.1`. Each published revision receives a new tag. In the UI, mark it as a prerelease; with the CLI, include `--prerelease` when creating the release.

Write explicit opt-in installation instructions for the project's package manager. Do not assume stable dependency ranges select prereleases. Before stable publication, address findings, verify the final revision, and publish a new stable tag with complete notes.

## Urgent fix while main contains future work

1. Confirm the last suitable stable tag and which release line remains supported.
2. Create `maint/2.0` from `2.0.1` if that maintenance branch does not already exist; otherwise update from its existing remote branch.
3. Create a working branch such as `fix/2.0-search-crash` from the maintenance branch.
4. Implement or carefully port only the fix. A clean single-change commit can be cherry-picked with `git cherry-pick -x COMMIT_ID`; inspect it for dependencies on next-release APIs.
5. Open a PR to `maint/2.0`, validate it in that line, and merge.
6. Release the pinned maintenance commit through the same tagging and publication steps.
7. Land an equivalent fix on `main` if it is not already there. Link the two PRs and validate any adapted implementation.

Do not cherry-pick an entire mixed feature PR merely because it includes the fix. Do not merge the whole next-version branch into the patch line. Record the support period for the maintenance line.

## Recovery

If publication partially succeeds, inspect each destination before retrying. A tag push, release page, registry upload, and asset upload may succeed independently. Continue missing steps against the same verified source where possible; never reuse a published version for different source or binaries.

If the released product is wrong, prepare a corrective PR and a new version. Explain affected versions and the recommended upgrade. Keep the old tag's identity intact. The adopting repository specifies any registry-specific withdrawal mechanism.

## Final checklist

- [ ] Full release scope reviewed against the previous relevant stable tag.
- [ ] Version selected from compatibility impact; requirements and migration explained.
- [ ] Exact release commit recorded; appropriate validation covers that revision.
- [ ] Version files and bundled guidance agree where applicable.
- [ ] Unique tag resolves to the verified commit.
- [ ] Release page and required package/artifact publication completed.
- [ ] Consumer-facing version resolution or installation verified.
- [ ] Disposable task-owned validation outputs cleaned up when no process uses them.
