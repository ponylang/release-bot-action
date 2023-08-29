# Release-bot action

The release-bot action brings together several parts of the Pony repository maintenance ecosystem to create a flexible tool for building a release process driven by GitHub actions.

The release-bot has commands to work with existing Pony tools for managing changelogs and release-notes along with other commands that allow anyone to have a release process that mirrors the one used by the Ponylang developers to create arbitrary release artefacts, rotate CHANGELOGs, rotate release-notes, and post release announcements to a variety of locations.

Additional actions that you might be interested in:

- [changelog-bot](https://github.com/ponylang/changelog-bot-action)
- [library-documentation-action](https://github.com/ponylang/library-documentation-action)
- [release-notes-bot](https://github.com/ponylang/release-notes-bot-action)

## Using the release-bot

Multiple workflows are required as part of the standard Pony release process that this bot encompasses. You will need 3 different workflow files.

A release is started by tagging the HEAD commit of a repo with a tag that looks like:

`release-x.y.z` where `x.y.z` is the version to release; e.g. 0.1.0

There are three workflows that you should set up to use the release-bot action. Each is detailed later.

- prepare-a-release
- release
- announce-a-release

The process is broken down into three workflows to make it easier to recover from errors.

Each library or application will have its own release steps that are needed. These "artefact building steps" should be supplied as a series of steps in `release` workflow (see below).

You can check out [this repository](https://github.com/ponylang/release-bot-action/tree/main/.github/workflows) as well as just about any [ponylang repository](https://github.com/ponylang/) for "live" examples of using this action. You can also receive assistance in the [#release stream of the Pony Zulip](https://ponylang.zulipchat.com/#narrow/stream/190364-release).

Please note, the release-bot works by tagging the primary branch of a repository for release. It doesn't support having a separate release branch.

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

In addition to the "prepare for release" step commands, there is a final "trigger" command that must be run after all the other steps. The trigger command, `trigger-artefact-creation`, starts the next workflow `release`.

**prepare-for-a-release.yml**:

```yml
name: Prepare for a release

on:
  push:
    tags: 'release-[0-9]+.[0-9]+.[0-9]+'

concurrency: prepare-for-a-release

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
        uses: actions/checkout@v3
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Update CHANGELOG.md
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: update-changelog-for-release
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
      - name: Update VERSION
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: update-version-in-VERSION
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
      - name: Update version in README
        uses: ponylang/release-bot-action@0.6.2
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
        uses: actions/checkout@v3
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Trigger artefact creation
        uses: ponylang/release-bot-action@0.6.2
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
        uses: actions/checkout@v3
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Add "unreleased" section to CHANGELOG.md
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: add-unreleased-section-to-changelog
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### Release

The meat of the release process. This is the workflow that builds our actual release artefacts, updates documentation and whatever else. Release-bot only provides two commands to be used in this workflow.

- pre-artefact-changelog-check

Can be used to verify that the release workflow wasn't "accidentally" triggered.

- trigger-release-announcement

Is used to start the `announce-a-release` workflow and is meant to be run after all artefact building has completed.

**release.yml**:

```yml
name: Release

on:
  push:
    tags:
      - '[0-9]+.[0-9]+.[0-9]+'

concurrency: release

jobs:
  # validation to assure that we should in fact continue with the release should
  # be done here. the primary reason for this step is to verify that the release
  # was started correctly by pushing a `release-X.Y.Z` tag rather than `X.Y.Z`.
  pre-artefact-creation:
    name: Tasks to run before artefact creation
    runs-on: ubuntu-latest
    steps:
      - name: Checkout main
        uses: actions/checkout@v3
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Validate CHANGELOG
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: pre-artefact-changelog-check

  # Artefact building steps go here
  # they should all depend on the `pre-artefact-creation` job finishing

  trigger-release-announcement:
    name: Trigger release announcement
    runs-on: ubuntu-latest
    needs: [ARTEFACT_BUILDING_JOBS_HERE]
    steps:
      - uses: actions/checkout@v3
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Trigger
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: trigger-release-announcement
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

trigger-release-announcement, by default, will extract the version being released from the GITHUB_REF environment variable. For this default action to work, trigger-release-announcement must be kicked off by a tag being pushed. If you set up the step to be triggered in any other fashion it will not work unless you supply the version yourself. You can supply the version by providing an optional environment variable `VERSION` set to the version being released.

### Announce a release

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
    tags: 'announce-[0-9]+.[0-9]+.[0-9]+'

concurrency: announce-a-release

jobs:
  announce:
    name: Announcements
    runs-on: ubuntu-latest
    steps:
      - name: Checkout main
        uses: actions/checkout@v3
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Release notes
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: publish-release-notes-to-github
        env:
          RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}
      - name: Zulip
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: send-announcement-to-pony-zulip
        env:
          ZULIP_API_KEY: ${{ secrets.ZULIP_RELEASE_API_KEY }}
          ZULIP_EMAIL: ${{ secrets.ZULIP_RELEASE_EMAIL }}
      - name: Last Week in Pony
        uses: ponylang/release-bot-action@0.6.2
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
        uses: actions/checkout@v3
        with:
          ref: "main"
          token: ${{ secrets.RELEASE_TOKEN }}
      - name: Rotate release notes
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: rotate-release-notes
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
      - name: Delete announcement trigger tag
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: delete-announcement-tag
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### Examples notes

- In the examples above, any time you see `ref: main` as part of `actions/checkout@v3` setup, you should replace `main` with the name of your default branch.

- The environment variable `RELEASE_TOKEN` that is required by various steps **must** be a personal access token with `public_repo` access. You can not use the `GITHUB_TOKEN` environment variable provided by GitHub's action environment. If you try to use `GITHUB_TOKEN`, no additional steps will trigger after start-a-release has completed.

- The environment variables `GIT_USER_NAME` and `GIT_USER_EMAIL` are used to set the username and email that commits that commands create will appear under.

- The `needs: [ARTEFACT_BUILDING_JOBS_HERE]` would have the `ARTEFACT_BUILDING_JOBS_HERE` text replaced with the names of all the artefact building jobs that need to be completed before the core of the release process is considered "done". See the [GitHub actions documentation](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions) for more information on [dependent jobs](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idneeds).

- `ZULIP_API_KEY` and `ZULIP_EMAIL` are covered in more detail in the `send-announcement-to-pony-zulip` command section

## Commands

### add-announcement-to-last-week-in-pony

Posts a notice about the release to the Last Week in Pony issue on the `ponylang/ponylang-website` repo. Posting to the Last Week in Pony issue will result in your release announcement going out in the weekly Pony newsletter.

**Must** be triggered by an `announce-X.Y.Z` tag push.

`add-announcement-to-last-week-in-pony` requires a GitHub personal access token with `public_repo` access to be used to post to the issue. The personal access token needs to be passed in the environment variable `RELEASE_TOKEN`.

An example step config:

```yml
      - name: Last Week in Pony
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: add-announcement-to-last-week-in-pony
        env:
          RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}
```

### add-unreleased-section-to-changelog

Adds an unreleased section to a standard pony CHANGELOG.md after a release has been tagged.

- **Must** be triggered by an `release-X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`
- **Should** be run **AFTER** the `trigger-artefact-creation` command

An example step config:

```yml
      - name: Add "unreleased" section to CHANGELOG.md
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: add-unreleased-section-to-changelog
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### delete-announcement-tag

Deletes the `announce-X.Y.Z` tag that is used to kick off various release announcement commands.

- **Must** be triggered by an `announce-X.Y.Z` tag push.
- **Must** be run **AFTER** all other `announce-X.Y.Z` triggered command
- **Must** be run in a job after `actions/checkout`

An example step config:

```yml
      - name: Delete announcement trigger tag
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: delete-announcement-tag
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### pre-artefact-changelog-check

The `pre-artefact-changelog-check` exists because we are all human. The release-bot is designed to be run via a process that starts with pushing a `release-X.Y.Z` tag. However, we guarantee that eventually someone will slip up and push a `X.Y.Z` tag instead and that will mess up your release.

The `pre-artefact-changelog-check` command is designed to be run as a the first job in the `release.yml` part of the release process. It will check to make sure that the CHANGELOG.md has been correctly versioned for release; as such, it's only a good gate if you are using a standard pony CHANGELOG.md with your project.

- **Must** be triggered by an `X.Y.Z` tag push.
- **Must** be run after `update-changelog-for-release`
- **Must** be run in a job after `actions/checkout`

An example step config:

```yml
      - name: Validate CHANGELOG
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: pre-artefact-changelog-check
```

### publish-release-notes-to-github

Publishes release notes to the GitHub release associated with the release.
If the project uses the standard Pony release-notes tools then those will be included as text on the release. If the project uses the standard Pony CHANGELOG.md, then the CHANGELOG for this release will also be included.

- **Must** be triggered by an `announce-X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`

`publish-release-notes-to-github` requires a GitHub personal access token with `public_repo` access to be used to post to the issue. The personal access token needs to be passed in the environment variable `RELEASE_TOKEN`.

An example step config:

```yml
      - name: Release notes
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: publish-release-notes-to-github
        env:
          RELEASE_TOKEN: ${{ secrets.RELEASE_TOKEN }}
```

### rotate-release-notes

Rotates the release notes for the project after the release is completed.

- **Must** be triggered by an `announce-X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`
- **Should not** be run before any other release-notes related commands.

An example step config:

```yml
      - name: Rotate release notes
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: rotate-release-notes
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### send-announcement-to-pony-zulip

Posts information about the release to the [Pony Zulip](https://ponylang.zulipchat.com/) in the `announce` stream. This command requires an api key and associated email address.

If you don't already have an Pony Zulip account, you'll need to create one. Once you've created an account, you'll need to create a bot that will be used to post release messages on your behalf.

In Zulip, go to your account settings. There will be a menu option `Your bots`.
Select the `Add new bot` option.

When setting up the bot you want to:

- Set the `type` to `Incoming webhook`
- Give the bot a meaningful `Full Name` like "My Package Release Bot" or "Sean's Release Bot". All release notices will appear under that name.
- Supply a `Email` that matches your `Full Name` like `sean-release`

After you push `Create Bot`, you'll be taken to your list of active bots. Copy the `BOT EMAIL` and `API KEY` for your bot. These values will be used as environment variables when setting up the add-announcement-to-last-week-in-pony.

- **Must** be triggered by an `announce-X.Y.Z` tag push.

An example step config:

```yml
      - name: Zulip
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: send-announcement-to-pony-zulip
        env:
          ZULIP_API_KEY: ${{ secrets.ZULIP_RELEASE_API_KEY }}
          ZULIP_EMAIL: ${{ secrets.ZULIP_RELEASE_EMAIL }}
```

### trigger-artefact-creation

Tags a release and starts the process of moving from the `prepare-for-release` to the `release` workflows in our release process.

- **Must** be triggered by an `release-X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`
- **Should** be run after all 'pre-tagging' commands otherwise, your tagged release won't be accurate.

An example step config:

```yml
      - name: Trigger artefact creation
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: trigger-artefact-creation
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### trigger-release-announcement

Starts the process of moving from the `release` to `announce-a-release` workflows.

- **Must** be triggered by an `X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`
- **Should** be run after all release related tasks otherwise your release will be announced "early"

An example step config:

```yml
      - name: Trigger
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: trigger-release-announcement
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### update-action-to-use-docker-image-to-run-action

Useful if you are using the release-bot with a GitHub action like the release-bot (we have many GitHub action projects that are part of the ponylang organization).

If you build a docker image as part of your action release process, this command will update your action.yml file to use that image instead of building the action each time from source. It's advised that you use this with any action to prevent your action from breaking if any dependencies in your Dockerfile change after you tag your release.

- **Must** be triggered by an `release-X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`
- **Must** be run before `update-action-to-use-dockerfile-to-run-action`
- **Should** be run before `trigger-artefact-creation` or the entire purpose of this command will be defeated

An example step config:

```yml
      - name: Set action to run using prebuilt image
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: update-action-to-use-docker-image-to-run-action
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

To use a registry other than DockerHub, add the registry in the REGISTRY environment variable. For example to use GitHub Container Registry:

```yml
      - name: Set action to run using prebuilt image
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: update-action-to-use-docker-image-to-run-action
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
          REGISTRY: "ghcr.io"
```

Current valid entries for `REGISTRY` are '', 'docker.io', and 'ghcr.io'.

### update-action-to-use-dockerfile-to-run-action

The companion to `update-action-to-use-docker-image-to-run-action`. It switches back to running the action by building each time from the Dockerfile. This allows for easier testing of functionality when developing new versions of the action.

- **Must** be triggered by an `announce-X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`
- **Must** be run after `update-action-to-use-docker-image-to-run-action`
- **Should** be run after `trigger-artefact-creation` or the entire purpose of the `update-action-to-use-docker-image-to-run-action` will be defeated

An example step config:

```yml
      - name: Set action to run using Dockerfile
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: update-action-to-use-dockerfile-to-run-action
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### update-changelog-for-release

Updates a standard Pony CHANGELOG.md for release. It takes the current "unreleased" section and turns it into a section for the about to be released version.

- **Must** be triggered by an `announce-X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`
- **Should** be run **BEFORE** the `trigger-artefact-creation` command

An example step config:

```yml
      - name: Update CHANGELOG.md
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: update-changelog-for-release
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### update-version-in-corral-json

Updates the version in a corral.json to match the release. Should be used with any Pony library.

- **Must** be triggered by an `announce-X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`
- **Should** be run **BEFORE** the `trigger-artefact-creation` command

An example step config:

```yml
      - name: Update corral.json
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: update-version-in-corral-json
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### update-version-in-README

Updates a variety of "version formats" in a project's README. Generally used to update usage examples that include the version.

Works with either README.md or README.rst files.

Can update the following version patterns:

- corral add github.com/REPO.git --version \d+\.\d+\.\d+
- REPO@\d+\.\d+\.\d+ <== standard action url
- docker://REPO:\d+\.\d+\.\d+ <== docker hub url
- docker://ghcr.io/REPO:\d+\.\d+\.\d+ <== github container registry url

- **Must** be triggered by an `announce-X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`
- **Should** be run **BEFORE** the `trigger-artefact-creation` command

An example step config:

```yml
      - name: Update version in README
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: update-version-in-README
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```

### update-version-in-VERSION

Updates the version in a VERSION file. VERSION files are used in many Pony projects.

- **Must** be triggered by an `announce-X.Y.Z` tag push.
- **Must** be run in a job after `actions/checkout`
- **Should** be run **BEFORE** the `trigger-artefact-creation` command

An example step config:

```yml
      - name: Update VERSION
        uses: ponylang/release-bot-action@0.6.2
        with:
          entrypoint: update-version-in-VERSION
        env:
          GIT_USER_NAME: "Ponylang Main Bot"
          GIT_USER_EMAIL: "ponylang.main@gmail.com"
```
