# Release-bot action

Multiple workflows are required as part of the standard Pony release process that this bot encompasses. You will need 3 different workflow files.

A release is started by tagging the HEAD commit of a repo with a tag that looks like:

`release-x.y.z` where `x.y.z` is the version to release; e.g. 0.1.0

When the tag is pushed, it will trigger the start-a-release section of the workflow below. See [scripts/start-a-release.bash](scripts/start-a-release.bash) for full-details. When start-a-release finishes, it will delete the `release-x.y.z` tag and push a new tag `x.y.z` that triggers the release step.

Each library or application will have it's own release steps that are needed. They should be supplied as a series of steps in a **release.yml** (see below). Each of those steps will be a requirement to trigger the trigger-release-announcement step.

trigger-release-announcement pushes a new tag `announce-x.y.z` that will trigger the next and final step in the process. The trigger-release-announcement step exists so that if any build artifact portion of the release process fails, it can be completed by hand and then, a human can push a `announce-x.y.z` tag to start the final step in the release process.

announce-a-release will post:

- Post the release notes to the release section of GitHub
- Post a notification of the release to the #announce stream on Zulip
- Add a notice to the open Last Week in Pony issue

Once announce-a-release has completed, the release process is done. For more in-depth details, please see each of the respective scripts in [scripts](scripts/).

## Example workflows

### Prepare for release

Starts the release process.

There are several "pre-release" step commands that can be used together in a job to execute various pre-release updates:

- update-changelog-for-release.bash
- add-unreleased-section-to-changelog.bash

Every project that includes a standard Pony CHANGELOG.md should include these steps.

- update-version-corral-json.bash

All Pony library projects should include this step.

- update-version-in-VERSION.bash

All standard Pony projects that include a VERSION file should include this step.

In addition to the "prepare for release" step commands, there is a final "trigger" command that must be run after all the other steps. If the trigger step, `trigger-artifact-creation.bash` isn't run. Then the release process will not actually start.

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
        uses: docker://ponylang/release-bot-action:0.5.0
        with:
          entrypoint: update-changelog-for-release.bash
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
      - name: Update VERSION
        uses: docker://ponylang/release-bot-action:0.5.0
        with:
          entrypoint: update-version-in-VERSION.bash
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
      - name: Update version in README
        uses: docker://ponylang/release-bot-action:0.5.0
        with:
          entrypoint: update-version-in-README.py
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"

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
      - name: Trigger artifact creation
        uses: docker://ponylang/release-bot-action:0.5.0
        with:
          entrypoint: trigger-artifact-creation.bash
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"

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
        uses: docker://ponylang/release-bot-action:0.5.0
        with:
          entrypoint: add-unreleased-section-to-changelog.bash
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
```

## trigger-release-announcement

Triggers the announcement of the release.

Should be run after all release artifact building steps are done. For an application, this would mean that all artifacts have been uploaded to Cloudsmith and any Docker images were built.

**release.yml**:

```yml
name: Release

on:
  push:
    tags:
      - \d+.\d+.\d+

jobs:
  # Artifact building steps go here

  trigger-release-announcement:
    name: Trigger release announcement
    runs-on: ubuntu-latest
    needs: [ARTIFACT_BUILDING_STEPS_HERE]
    steps:
      - uses: actions/checkout@v2
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Trigger
        uses: docker://ponylang/release-bot-action:0.5.0
        with:
          entrypoint: trigger-release-announcement.bash
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
```

trigger-release-announcement, by default, will extract the version being released from the GITHUB_REF environment variable. For this default action to work, trigger-release-announcement must be kicked off by a tag being pushed. If you set up the step to be triggered in any other fashion it will not work unless you supply the version yourself. You can supply the version by providing an optional environment variable `VERSION` set to the version being released.

## announce-a-release

Announces a release after artifacts have been built:

- Publishes release notes to GitHub
- Announces in the #announce stream of Zulip
- Adds a note about the release to LWIP

**announce-a-release.yml**:

```yml
name: Announce a release

on:
  push:
    tags: announce-\d+.\d+.\d+

jobs:
  announce-a-release:
    name: Announce a release
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Announce
        uses: docker://ponylang/release-bot-action:0.5.0
        with:
          entrypoint: announce-a-release.bash
          git_user_name: "Ponylang Main Bot"
          git_user_email: "ponylang.main@gmail.com"
        env:
          RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}
          ZULIP_TOKEN: ${{ secrets.ZULIP_TOKEN }}
```

**N.B.** The environment variable `RELEASE_TOKEN` that is required by each step **must** be a personal access token with `public_repo` access. You can not use the `GITHUB_TOKEN` environment variable provided by GitHub's action environment. If you try to use `GITHUB_TOKEN`, no additional steps will trigger after start-a-release has completed.

**N.B.** you should set the `ref` input value to `actions/checkout@v2` to whatever the default branch of your repository is. The examples above assume that your default branch name is `main`.
