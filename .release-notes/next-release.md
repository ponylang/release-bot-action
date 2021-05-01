## Create images on release

Permanant, unchanging images for this action are now available in DockerHub and will be updated on each release. See our examples for more details on how to use.

## Replace "step" input parameter with overriding of entrypoint

Previously, when configuring the release-bot, you would indicate which step should be run like:

```yml
        with:
          step: start-a-release
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
```

`step` as an input option has been removed and replaced by `entrypoint`. `entrypoint` is an existing option that GitHub actions supports for changing the script to run from within an action.

Previously, the steps where:

- start-a-release
- trigger-release-announcement
- announce-a-release

Those steps have been replaced with the following corresponding entrypoints:

- start-a-release.bash
- trigger-release-announcement.bash
- announce-a-release.bash

The aforementioned configuration from above would now be:

```yml
        with:
          entrypoint: start-a-release.bash
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
```

## Switch supported actions/checkout from v1 to v2

We've switched from supporting `actions/checkout@v1` to `actions/checkout@v2`.

The are a few changes to configuration of release-bot that come along with this change. You should check out the examples in the README.md to see the latest on how to configure.

Highlights of changes:

- Use `actions/checkout@v2`
- `action/checkout` requires the setting `token` and `ref` values.
- Most workflows no longer require a release token being passed to the action, only to `actions/checkout`.
- Workflows no longer take a default branch. The default branch is now handled by `actions/checkout@v2`.

## Split "start-a-release" into multiple different commands

Previously, release-bot-action had a command `start-a-release` that did multiple things. It:

- Updated the version in `VERSION`
- It ran the `changelog-tool` `release` command to version `CHANGELOG.md`
- It updated the version in `corral.json` if `corral.json` existed

AND...

It kicked off the next stage of the release process by pushing back a new tag for the actual release itself like 1.0.0.

This was all well and good but as part of the release process, not all projects needs `corral.json` updated. Many projects don't have a `corral.json` to update. Others have other files they need updated as part of pre-release process. Our emacs mode for example have version information that needs to be updated in .el files in order to get [MELPA](https://melpa.org/) to pick up a new version.

Rather than shove more and more functionality into a single script, start-a-release has been broken apart into multiple commands that can be called from steps in a GitHub actions workflow to compose functionality together on a per-project basis.

Those new commands covered in detail in our updated `prepare-for-a-release` example in README.md. The new step commands are:

- add-unreleased-section-to-changelog.bash
- triger-artifact-creation.bash
- update-changelog-for-release.bash
- update-version-corral-json.bash
- update-version-in-VERSION.bash

Other commands will be forthcoming.

