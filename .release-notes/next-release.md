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
- trigger-artefact-creation.bash
- update-changelog-for-release.bash
- update-version-corral-json.bash
- update-version-in-VERSION.bash

Other commands will be forthcoming.

## Add README version updater command

A new "readme version updater" command is now available for use as a pre-tagging step. The command is based on the [readme-version-updater-action](https://github.com/ponylang/readme-version-updater-action).

## Add command to update the runner in action.yml files

The best way to run a released GitHub action is to use a prebuilt docker
image. This saves time with building the image and guarantees that each
run will be using exactly the same action code.

This is best accomplished by settings runs.image to the image in question
in action.yml.

However, this does have a drawback of not being able to use arbitrary commits
to run with as that commit will be grabbed BUT... the image in its action.yml
will be used. This is problematic for testing actions.

The two commands included in this commit address both issues.

### update-action-to-use-docker-image-to-run-action.py

Updates runs.image to a docker image with the version we are releasing.
As part of the release process for an action, it should then also make
sure to push a prebuilt image to DockerHub for the action in question.

This command should be run in the pre-tagging job.

### update-action-to-use-dockerfile-to-run-action.py

Switches back to using `Dockerfile` for how to run the action.

This command should be run in the post-tagging job.

## Add preartefact-changelog-check.bash command

The preartefact-changelog-check.bash command validates that the changelog contains an entry for `X.Y.Z` where `X.Y.Z` is the release that is underway.

The command can be used to protect against misconfiguration of workflows and more importantly, a user inadvertently pushing a `X.Y.Z` tag to start a release rather than the correct `release-X.Y.Z`.

## Split "announce-a-release" into multiple different commands

Previously, release-bot-action had a command `announce-a-release` that did multiple things. It:

- Published release notes to GitHub
- Announced the release in the #announce stream of the Pony Zulip
- Added a note about the release to LWIP
- Deleted the `announce-X.Y.Z` tag used to trigger the command
- Rotated the release notes

In keeping with our project to break release-bot-action into a series of fine-grained commands, announce-a-release has been broken apart into multiple commands that can be called from steps in a GitHub actions workflow to compose functionality together on a per-project basis.

Those new commands covered in detail in our updated `announce-a-release` example in README.md. The new step commands are:

- add-announcement-to-last-week-in-pony.bash
- delete-announcement-tag.bash
- publish-release-notes-to-github.bash
- rotate-release-notes.bash
- send-announcement-to-pony-zulip.bash

## Replaced all .bash commands with equivalent .py commands

As part of an internal cleanup, all commands written in bash have been rewritten to python and in the process, each was renamed. Full list of changes is below:

- add-announcement-to-last-week-in-pony.bash => add-announcement-to-last-week-in-pony.py
- add-unreleased-section-to-changelog.bash => add-unreleased-section-to-changelog.py
- delete-announcement-tag.bash => delete-announcement-tag.py
- pre-artefact-changelog-check.bash => pre-artefact-changelog-check.py
- publish-release-notes-to-github.bash => publish-release-notes-to-github.py
- rotate-release-notes.bash => rotate-release-notes.py
- send-announcement-to-pony-zulip.bash => send-announcement-to-pony-zulip.py
- trigger-artefact-creation.bash => trigger-artefact-creation.py
- trigger-release-announcement.bash => trigger-release-announcement.py
- update-changelog-for-release.bash => update-changelog-for-release.py
- update-version-in-corral-json.bash => update-version-in-corral-json.py
- update-version-in-VERSION.bash => update-version-in-VERSION.py

As part of this change, the input values to `send-announcement-to-pony-zulip.py` have changed from those to `send-announcement-to-pony-zulip.bash`. Whereas previously, a single environment variable called `ZULIP_TOKEN` was expected, we now need two `ZULIP_API_KEY` and `ZULIP_EMAIL`.

## Remove file extension from commands

Previously all the release-bot-commands included a file extension like '.py'. We've removed all file extensions to allow for us to change the implementation language in the future without it being a breaking change.

Where a command might previously have been `foo.py` it is now simply `foo`.

