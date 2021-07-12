# Release-bot action

Multiple workflows are required as part of the standard Pony release process that this bot encompasses. You will need 3 different workflow files.

A release is started by tagging the HEAD commit of a repo with a tag that looks like:

`release-x.y.z` where `x.y.z` is the version to release; e.g. 0.1.0

When the tag is pushed, it will trigger the start-a-release section of the workflow below. See [scripts/start-a-release.bash](scripts/start-a-release.bash) for full-details. When start-a-release finishes, it will delete the `release-x.y.z` tag and push a new tag `x.y.z` that triggers the release step.

Each library or application will have it's own release steps that are needed. They should be supplied as a series of steps in a **release.yml** (see below). Each of those steps will be a requirement to trigger the trigger-release-announcement step.

trigger-release-announcement pushes a new tag `announce-x.y.z` that will trigger the next and final step in the process. The trigger-release-announcement step exists so that if any build artefact portion of the release process fails, it can be completed by hand and then, a human can push a `announce-x.y.z` tag to start the final step in the release process.

announce-a-release will post:

- Post the release notes to the release section of GitHub
- Post a notification of the release to the #announce stream on Zulip
- Add a notice to the open Last Week in Pony issue

Once announce-a-release has completed, the release process is done. For more in-depth details, please see each of the respective scripts in [scripts](scripts/).

## Example workflows

### Prepare for release

Starts the release process.

There are several "pre-release" step commands that can be used together in a job to execute various pre-release updates:

- update-changelog-for-release
- add-unreleased-section-to-changelog

Every project that includes a standard Pony CHANGELOG.md should include these steps.

- update-version-corral-json

All Pony library projects should include this step.

- update-version-in-VERSION

All standard Pony projects that include a VERSION file should include this step.

In addition to the "prepare for release" step commands, there is a final "trigger" command that must be run after all the other steps. If the trigger step, `trigger-artefact-creation` isn't run. Then the release process will not actually start.

**prepare-for-a-release.yml**:

```yml
name: Prepare for a release

on:
  push:
    tags: release-\d+.\d+.\d+

jobs:
  # all tasks that need to be done before we add an X.Y.Z tag
  # should be done as a step in the pre-tagging job.
  # think of it like this... if when you later checkout the tag for a release,
  # should the change be there? if yes, do it here.
  pre-tagging:
    name: Tasks run before tagging the release
    runs-on: ubuntu-latest
    steps:
      - name: Checkout main
        uses: actions/checkout@v2
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Update CHANGELOG.md
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: update-changelog-for-release
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
      - name: Update VERSION
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: update-version-in-VERSION
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
      - name: Update version in README
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: update-version-in-README
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"

  # tag for release
  # this will kick off the next stage of the release process
  # no additional steps should be added to this job
  tag-release:
    name: Tag the release
    needs:
      - pre-tagging
    runs-on: ubuntu-latest
    steps:
      - name: Checkout main
        uses: actions/checkout@v2
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Trigger artefact creation
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: trigger-artefact-creation
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"

  # all cleanup tags that should happen after tagging for release should happen
  # in the post-tagging job. examples of things you might do:
  # add a new unreleased section to a changelog
  # set a version back to "snapshot"
  # in general, post-tagging is for "going back to normal" from tasks that were
  # done during the pre-tagging job
  post-tagging:
    name: Tasks run after tagging the release
    needs:
      - tag-release
    runs-on: ubuntu-latest
    steps:
      - name: Checkout main
        uses: actions/checkout@v2
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Add "unreleased" section to CHANGELOG.md
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: add-unreleased-section-to-changelog
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

## trigger-release-announcement

Triggers the announcement of the release.

Should be run after all release artefact building steps are done. For an application, this would mean that all artefacts have been uploaded to Cloudsmith and any Docker images were built.

**release.yml**:

```yml
name: Release

on:
  push:
    tags:
      - \d+.\d+.\d+

jobs:
  # validation to assure that we should in fact continue with the release should
  # be done here. the primary reason for this step is to verify that the release
  # was started correctly by pushing a `release-X.Y.Z` tag rather than `X.Y.Z`.
  pre-artefact-creation:
    name: Tasks to run before artefact creation
    runs-on: ubuntu-latest
    steps:
      - name: Checkout main
        uses: actions/checkout@v2
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Validate CHANGELOG
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: pre-artefact-changelog-check

  # Artefact building steps go here
  # they should all depend on the `pre-artefact-creation` job finishing

  trigger-release-announcement:
    name: Trigger release announcement
    runs-on: ubuntu-latest
    needs: [ARTEFACT_BUILDING_STEPS_HERE]
    steps:
      - uses: actions/checkout@v2
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Trigger
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: trigger-release-announcement
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

trigger-release-announcement, by default, will extract the version being released from the GITHUB_REF environment variable. For this default action to work, trigger-release-announcement must be kicked off by a tag being pushed. If you set up the step to be triggered in any other fashion it will not work unless you supply the version yourself. You can supply the version by providing an optional environment variable `VERSION` set to the version being released.

## announce-a-release

Announces the release in a variety of channels.

There are currently three possible channels that you can announce your release: GitHub release notes, the Ponylang Zulip, and the Pony newsletter "Last Week In Pony". There are corresponding commands for each.

- publish-release-notes-to-github
- send-announcement-to-pony-zulip
- add-announcement-to-last-week-in-pony

In addition there are normal cleanup actions that need to be taken as part of the release process and should be done after all announcements are done.

- rotate-release-notes

Any project that uses release notes needs to run this command as part of post-announcement cleanup.

- delete-announcement-tag

All projects should run this command to clean up the tag used to trigger the announce-a-release step. `delete-announcement-tag` should be run after all other announcement commands have been run as they all depend on the `announce-X.Y.Z` existing.

**announce-a-release.yml**:

```yml
name: Announce a release

on:
  push:
    tags: announce-\d+.\d+.\d+

jobs:
  announce:
    name: Announcements
    runs-on: ubuntu-latest
    steps:
      - name: Checkout main
        uses: actions/checkout@v2
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Release notes
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: publish-release-notes-to-github
        env:
          RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}
      - name: Zulip
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: send-announcement-to-pony-zulip
        env:
          ZULIP_API_KEY: ${{ secrets.ZULIP_API_KEY }}
          ZULIP_EMAIL: ${{ secrets.ZULIP_EMAIL }}
      - name: Last Week in Pony
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: add-announcement-to-last-week-in-pony
        env:
          RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}

  post-announcement:
    name: Tasks to run after the release has been announced
    needs:
      - announce
    runs-on: ubuntu-latest
    steps:
      - name: Checkout main
        uses: actions/checkout@v2
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Rotate release notes
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: rotate-release-notes
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
      - name: Delete announcement trigger tag
        uses: ponylang/release-bot-action@0.5.0
        with:
          entrypoint: delete-announcement-tag
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

**N.B.** The environment variable `RELEASE_TOKEN` that is required by each step **must** be a personal access token with `public_repo` access. You can not use the `GITHUB_TOKEN` environment variable provided by GitHub's action environment. If you try to use `GITHUB_TOKEN`, no additional steps will trigger after start-a-release has completed.

**N.B.** you should set the `ref` input value to `actions/checkout@v2` to whatever the default branch of your repository is. The examples above assume that your default branch name is `main`.
