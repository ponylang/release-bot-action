## Add `create-empty-github-release` entrypoint

There is a new `create-empty-github-release` entrypoint that creates an empty GitHub release for the tag being released. This lets release workflows attach build artefacts to the GitHub release as they are produced, rather than waiting until `publish-release-notes-to-github` runs to create the release.

If a release already exists for the tag, `create-empty-github-release` leaves it alone, so the entrypoint is safe to run from a restarted release workflow.

Example use:

```yaml
- name: Create empty GitHub release
  uses: docker://ghcr.io/ponylang/release-bot-action:X.Y.Z
  with:
    entrypoint: create-empty-github-release
  env:
    RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}
```

## GitHub's `releases/latest` URL now points to the newest release

`publish-release-notes-to-github` now enables GitHub's default "latest release" selection (by semantic version and creation date) when it publishes release notes. Previously, `https://github.com/OWNER/REPO/releases/latest` did not reliably point to the most recent release for repositories using this action.

Re-running the announcement workflow against an older tag will not flip the `releases/latest` pointer away from a newer release — GitHub continues to pick the newest release by semver and date.
